%%%-------------------------------------------------------------------
%%% @author mb
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. Mar 2019 10:45 AM
%%%-------------------------------------------------------------------
-module(pollution).
-author("mb").

-record(measurement, {type, value, time=calendar:local_time()}).

-record(station, {name, coords, measurements=[]}).

%% API
-export([createMonitor/0, addStation/3, addValue/5, removeValue/4, getOneValue/4, getStationMean/3, getDailyMean/3, getDailyOverLimit/4]).

createMonitor() ->
  #{}.

addStation(Monitor, Name, Coords) ->
  case maps:is_key(Name, Monitor) or isCoord(Coords, Monitor) of
    true  -> {error, "similar station exists"};
    _ ->
      Station = #station{name = Name, coords = Coords},
      Monitor#{Station#station.name => Station}
  end.

addValue(Monitor, {Lat, Lon}, Time, Type, Value) ->
  NameList = [S#station.name || S <- maps:values(Monitor), S#station.coords == {Lat, Lon}],
  case NameList of
    [] -> {error, "no station having this coords"};
    [Name] -> addValue(Monitor, Name, Time, Type, Value)
  end;
addValue(Monitor, Name, Time, Type, Value) ->
  Station = maps:get(Name, Monitor),
  case isMeasurement(Station#station.measurements, Type, Time) of
    true -> {error, "already existing measurement having this coords & type & time"};
    false ->
      Monitor#{Name := Station#station{measurements = [#measurement{type = Type, value = Value, time = Time}|Station#station.measurements]}}
  end.

removeValue(Monitor, {Lat, Lon}, Time, Type) ->
  NameList = [S#station.name || S <- maps:values(Monitor), S#station.coords == {Lat, Lon}],
  case NameList of
    [] -> {error, "no station having this coords"};
    [Name] -> removeValue(Monitor, Name, Time, Type)
  end;
removeValue(Monitor, Name, Time, Type) ->
  Station = maps:get(Name, Monitor),
  Monitor#{Name := Station#station{measurements = lists:delete(getMeasurement(Station#station.measurements, Type, Time), Station#station.measurements)}}.

getOneValue(Monitor, {Lat, Lon}, Time, Type) ->
  NameList = [S#station.name || S <- maps:values(Monitor), S#station.coords == {Lat, Lon}],
  case NameList of
    [] -> {error, "no station having this coords"};
    [Name] -> getOneValue(Monitor, Name, Time, Type)
  end;
getOneValue(Monitor, Name, Time, Type) ->
  Station = maps:get(Name, Monitor),
  [Value] = [M#measurement.value || M <- Station#station.measurements, M#measurement.time == Time, M#measurement.type == Type],
  Value.

getStationMean(Monitor, {Lat, Lon}, Type) ->
  NameList = [S#station.name || S <- maps:values(Monitor), S#station.coords == {Lat, Lon}],
  case NameList of
    [] -> {error, "no station having this coords"};
    [Name] -> getStationMean(Monitor, Name, Type)
  end;
getStationMean(Monitor, Name, Type) ->
  Station = maps:get(Name, Monitor),
  Values =[M#measurement.value || M <- Station#station.measurements, M#measurement.type == Type],
  lists:sum(Values) / length(Values).

getDailyMean(Monitor, Date, Type) ->
  Values = [M#measurement.value || M <- getAllMeasurements(Monitor), M#measurement.type == Type, extractDate(M#measurement.time) == Date],
  lists:sum(Values) / length(Values).

getDailyOverLimit(Monitor, Date, Type, Limit) ->
  StationsOverLimit = [S || S <- maps:values(Monitor), isOverLimit(S, Date, Type, Limit)],
  length(StationsOverLimit).

isOverLimit(Station, Date, Type, Norm) ->
  OverLimit = [M || M <- Station#station.measurements,
                        extractDate(M#measurement.time) == Date,
                        M#measurement.value > Norm,
                        M#measurement.type == Type],
  case OverLimit of
    [] -> false;
    _  -> true
  end.




%%Helper functions
getMeasurement(Measurements, Type, Time) ->
  [Meas] = [M || M <- Measurements, M#measurement.type == Type, M#measurement.time == Time],
  Meas.

isMeasurement(Measurements, Type, Time) ->
  MeasList = [M || M <- Measurements, M#measurement.type == Type, M#measurement.time == Time],
  case MeasList of
    [] -> false;
    _ -> true
  end.

isCoord({Lat, Lon}, Monitor) ->
  Stations = [S || S <- maps:values(Monitor), S#station.coords == {Lat, Lon}],
  case Stations of
    [] -> false;
    _  -> true
  end.

getAllMeasurements(Monitor) ->
  lists:merge([S#station.measurements || S <- maps:values(Monitor)]).

extractDate(Time) ->
  {Date, {_,_,_}} = Time,
  Date.

