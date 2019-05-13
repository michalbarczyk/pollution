%%%-------------------------------------------------------------------
%%% @author mb
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Apr 2019 1:17 PM
%%%-------------------------------------------------------------------
-module(pollution_server_sup).
-author("mb").
-behaviour(supervisor).


%% API
-export([start/0, start_link/1, init/1]).

start() ->
  ets:new(monitorKeeper, [set, public, named_table]),
  M = pollution:createMonitor(),
  ets:insert(monitorKeeper, [{lastState, M}]),
  start_link(M).

start_link(InitialMonitor) ->
  supervisor:start_link({local, pollutionSupervisor}, ?MODULE, InitialMonitor).

init(InitialMonitor) ->
  {ok,
    {{one_for_one, 2, 1},
    [ {pollution_gen_server,
      {pollution_gen_server, start_link, [InitialMonitor]},
      permanent, brutal_kill, worker, [pollution_gen_server]}]
  }}.



