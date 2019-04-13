%%%-------------------------------------------------------------------
%%% @author mb
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Apr 2019 6:39 PM
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("mb").

%% API
-export([start/0, stop/0, init/0]).
-export([addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2, getDailyOverLimit/3, debugprint/0]).

start() ->
  register(pollutionserver, spawn(pollution_server, init, [])).
stop() ->
  pollutionserver ! {request, self(), stop},
  receive
    {reply, Reply} -> Reply
  end.

debugprint() ->
  pollutionserver ! {request, self(), debugprint},
  receive
    {reply, Data} -> Data
  end.

init() ->
  loop(pollution:createMonitor()).

loop(Monitor) ->
  receive
    {request, Pid, addStation, {Name, Coords}} ->
      RequestResult = pollution:addStation(Monitor, Name, Coords),
      processResult(RequestResult, Pid, Monitor);

    {request, Pid, addValue, {{Lat, Lon}, Time, Type, Value}} ->
      RequestResult = pollution:addValue(Monitor, {Lat, Lon}, Time, Type, Value),
      processResult(RequestResult, Pid, Monitor);

    {request, Pid, addValue, {Name, Time, Type, Value}} ->
      RequestResult = pollution:addValue(Monitor, Name, Time, Type, Value),
      processResult(RequestResult, Pid, Monitor);

    {request, Pid, removeValue, {{Lat, Lon}, Time, Type}} ->
      RequestResult = pollution:removeValue(Monitor, {Lat, Lon}, Time, Type),
      processResult(RequestResult, Pid, Monitor);

    {request, Pid, removeValue, {Name, Time, Type}} ->
      RequestResult = pollution:removeValue(Monitor, Name, Time, Type),
      processResult(RequestResult, Pid, Monitor);

    {request, Pid, getOneValue, {{Lat, Lon}, Time, Type}} ->
      Pid ! {reply, pollution:getOneValue(Monitor, {Lat, Lon}, Time, Type)},
      loop(Monitor);

    {request, Pid, getOneValue, {Name, Time, Type}} ->
      Pid ! {reply, pollution:getOneValue(Monitor, Name, Time, Type)},
      loop(Monitor);

    {request, Pid, getStationMean, {{Lat, Lon}, Type}} ->
      Pid ! {reply, pollution:getStationMean(Monitor, {Lat, Lon}, Type)},
      loop(Monitor);

    {request, Pid, getStationMean, {Name, Type}} ->
      Pid ! {reply, pollution:getStationMean(Monitor, Name, Type)},
      loop(Monitor);

    {request, Pid, getDailyMean, {Date, Type}} ->
      Pid ! {reply, pollution:getDailyMean(Monitor, Date, Type)},
      loop(Monitor);

    {request, Pid, getDailyOverLimit, {Date, Type, Limit}} ->
      Pid ! {reply, pollution:getDailyOverLimit(Monitor, Date, Type, Limit)},
      loop(Monitor);

    {request, Pid, debugprint} ->
      Pid ! {reply, Monitor},
      loop(Monitor);

    {request, Pid, stop} ->
      Pid ! {reply, ok}
  end.


processResult(Result, Pid, Monitor) ->
  case Result of
    {error, Report} ->
      Pid ! {reply, Report},
      loop(Monitor);
    _ ->
      Pid ! {reply, ok},
      loop(Result)
  end.

call(Request, Args) ->
  pollutionserver ! {request, self(), Request, Args},
  receive
    {reply, Reply} -> Reply
  end.

addStation(Name, Coords) -> call(addStation, {Name, Coords}).
addValue({Lat, Lon}, Time, Type, Value) -> call(addValue, {{Lat, Lon}, Time, Type, Value});
addValue(Name, Time, Type, Value) -> call(addValue, {Name, Time, Type, Value}).
removeValue({Lat, Lon}, Time, Type) -> call(removeValue, {{Lat, Lon}, Time, Type});
removeValue(Name, Time, Type) -> call(removeValue, {Name, Time, Type}).
getOneValue({Lat, Lon}, Time, Type) -> call(getOneValue, {{Lat, Lon}, Time, Type});
getOneValue(Name, Time, Type) -> call(getOneValue, {Name, Time, Type}).
getStationMean({Lat, Lon}, Type) -> call(getStationMean, {{Lat, Lon}, Type});
getStationMean(Name, Type) -> call(getStationMean, {Name, Type}).
getDailyMean(Date, Type) -> call(getDailyMean, {Date, Type}).
getDailyOverLimit(Date, Type, Limit) -> call(getDailyOverLimit, {Date, Type, Limit}).

