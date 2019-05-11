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
-export([start_link/0, init/1]).

%start() ->
  %ets:new(monitorCopy, [set, named_table]),
  %ets:insert(monitorCopy, {lastState, pollution:createMonitor()}),
  %start_link().

start_link() ->
  supervisor:start_link({local, pollutionSupervisor}, ?MODULE, pollution:createMonitor()).

init(InitialMonitor) ->
  {ok,
    {{one_for_one, 2, 1},
    [ {pollution_gen_server,
      {pollution_gen_server, start_link, [InitialMonitor]},
      permanent, brutal_kill, worker, [pollution_gen_server]}]
  }}.







