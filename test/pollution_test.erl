%%%-------------------------------------------------------------------
%%% @author mb
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Apr 2019 5:47 PM
%%%-------------------------------------------------------------------
-module(pollution_test).
-include_lib("eunit/include/eunit.hrl").
-author("mb").
-compile(export_all).

addStation_test() ->
  M = pollution:createMonitor(),
  ?assertEqual(pollution:addStation(M, "D17", {20.0, 50.5}), #{"D17" => {station, "D17", {20.0, 50.5}, []}}).

addValue_test() ->
  M1 = pollution:createMonitor(),
  M2 = pollution:addStation(M1, "D17", {20.0, 50.5}),
  T = #{"D17" =>
        {station,"D17",
        {20.0,50.5},
        [{measurement,"pm25",45,{{2019,4,10},{19, 12, 14}}}]}},
  ?assertEqual(pollution:addValue(M2, "D17", {{2019,4,10},{19, 12, 14}}, "pm25", 45), T).

getOneValue_test() ->
  M1 = pollution:createMonitor(),
  M2 = pollution:addStation(M1, "D17", {20.0, 50.5}),
  M3 = pollution:addValue(M2, "D17", {{2019,4,10},{19, 12, 14}}, "pm10", 45),
  ?assertEqual(pollution:getOneValue(M3, "D17", {{2019,4,10},{19, 12, 14}}, "pm10"), 45).




