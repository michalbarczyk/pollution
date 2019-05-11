%%%-------------------------------------------------------------------
%%% @author mb
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. May 2019 9:38 AM
%%%-------------------------------------------------------------------
-module(pollution_gen_server).
-author("mb").
-behaviour(gen_server).

%% API
-export([start_link/1, init/1, handle_cast/2, handle_call/3, stop/0, terminate/2]).
-export([addStation/2, addValue/4, getOneValue/3, debugPrint/0, crash/0]).


%% START

%%start() ->
 %% start_link().

start_link(InitialMonitor) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, InitialMonitor, []).


%% INIT

init(InitialMonitor) ->
  {ok, InitialMonitor}.


%% STOP & TERMINATE

stop() -> gen_server:cast(?MODULE, stop).

terminate(normal, M) -> io:format("Monitor final content: ~n~w~n", [M]).


%% CAST

addStation(Name, Coords) -> gen_server:cast(?MODULE, {addStation, Name, Coords}).
addValue({Lat, Lon}, Time, Type, Value) -> gen_server:cast(?MODULE, {addValue, {Lat, Lon}, Time, Type, Value});
addValue(Name, Time, Type, Value) -> gen_server:cast(?MODULE, {addValue, Name, Time, Type, Value}).

crash() -> gen_server:cast(?MODULE, crash).


%% CALL

getOneValue({Lat, Lon}, Time, Type) -> gen_server:call(?MODULE, {getOneValue, {Lat, Lon}, Time, Type});
getOneValue(Name, Time, Type) -> gen_server:call(?MODULE, {getOneValue, Name, Time, Type}).
debugPrint() -> gen_server:call(?MODULE, debugPrint).



%% HANDLERS

handle_cast({addStation, Name, Coords}, M) ->
  UpdatedM = error_check(M, pollution:addStation(M, Name, Coords)),
  {noreply, UpdatedM};

handle_cast({addValue, {Lat, Lon}, Time, Type, Value}, M) ->
  UpdatedM = error_check(M, pollution:addValue(M, {Lat, Lon}, Time, Type, Value)),
  {noreply, UpdatedM};

handle_cast({addValue, Name, Time, Type, Value}, M) ->
  UpdatedM = error_check(M, pollution:addValue(M, Name, Time, Type, Value)),
  {noreply, UpdatedM};

handle_cast(stop, M) ->
  {stop, normal, M};

handle_cast(crash, M) ->
  %ets:insert(monitorCopy, {lastState, M}),
  C = 1/0,
  {noreply, M}.


handle_call({getOneValue, {Lat, Lon}, Time, Type}, _From, M) ->
  Reply = error_check(M, pollution:getOneValue(M, {Lat, Lon}, Time, Type)),
  {reply, Reply, M};

handle_call({getOneValue, Name, Time, Type}, _From, M) ->
  Reply = error_check(M, pollution:getOneValue(M, Name, Time, Type)),
  {reply, Reply, M};

handle_call(debugPrint, _From, M) ->
  {reply, M, M}.



%% ERROR HANDLERS

error_check(M, {error, Desc}) ->
  io:format("ERROR: ~s~n", [Desc]),
  M;
error_check(M, Proper) ->
  Proper.







