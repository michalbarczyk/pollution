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

%%%-record(coordinates, {latitude, longitude}).

-record(measurement, {type, value, time=calendar:local_time()}).

-record(station, {name, coords, measurements=[]}).

%% API
-export([createMonitor/0, addStation/3, addValue/5, is_coord/2]).

createMonitor() ->
  #{}.

addStation(Monitor, Name, Coords) ->
  case maps:is_key(Name, Monitor) or is_coord(Coords, Monitor) of
    true  -> "ERROR - similar station exists";
    _ ->
      Station = #station{name = Name, coords = Coords},
      Monitor#{Station#station.name => Station}
  end.


addValue(Monitor, Name, Time, Type, Value) ->
  Station = maps:get(Name, Monitor),
  Monitor#{Name := Station#station{measurements = [#measurement{type = Type, value = Value, time = Time}|Station#station.measurements]}};
addValue(Monitor, {Lat, Lon}, Time, Type, Value) ->
  NameList = [S#station.name || S <- maps:values(Monitor), S#station.coords == {Lat, Lon}],
  case NameList of
    [] -> "ERROR - no station having this coords";
    [Name] -> addValue(Monitor, Name, Time, Type, Value)
  end.


is_coord({Lat, Lon}, Monitor) ->
  Stations = [S || S <- maps:values(Monitor), S#station.coords == {Lat, Lon}],
  case Stations of
    [] -> false;
    _  -> true
  end.

