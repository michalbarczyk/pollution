%%%-------------------------------------------------------------------
%%% @author mb
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Apr 2019 9:25 PM
%%%-------------------------------------------------------------------
-module(pollution_server_test).
-include_lib("eunit/include/eunit.hrl").
-author("mb").
-compile(export_all).

%% API
-export([]).

addStation_test() ->
  pollution_server:start(),
  ?assertEqual(pollution_server:addStation("AL29", {13.33, 12.56}), ok),
  pollution_server:stop().

addValue_name_test() ->
  pollution_server:start(),
  pollution_server:addStation("AL29", {13.33, 12.56}),
  ?assertEqual(pollution_server:addValue("AL29", calendar:local_time(), "NO2", 35.0), ok),
  pollution_server:stop().

addValue_coords_test() ->
  pollution_server:start(),
  pollution_server:addStation("AL29", {13.33, 12.56}),
  ?assertEqual(pollution_server:addValue({13.33, 12.56}, calendar:local_time(), "NO2", 35.0), ok),
  pollution_server:stop().

removeValue_name_test() ->
  pollution_server:start(),
  pollution_server:addStation("AL29", {13.33, 12.56}),
  pollution_server:addValue("AL29", {{2019,3,6}, {12,3,12}}, "NO2", 35.4),
  ?assertEqual(pollution_server:removeValue("AL29", {{2019,3,6}, {12,3,12}}, "NO2"), ok),
  pollution_server:stop().

removeValue_coords_test() ->
  pollution_server:start(),
  pollution_server:addStation("AL29", {13.33, 12.56}),
  pollution_server:addValue({13.33, 12.56}, {{2019,3,6}, {12,3,12}}, "NO2", 35.0),
  ?assertEqual(pollution_server:removeValue({13.33, 12.56}, {{2019,3,6}, {12,3,12}}, "NO2"), ok),
  pollution_server:stop().

getOneValue_test() ->
  pollution_server:start(),
  pollution_server:addStation("AL29", {13.33, 12.56}),
  pollution_server:addValue({13.33, 12.56}, {{2019,3,6}, {12,3,12}}, "NO2", 35.0),
  ?assertEqual(pollution_server:getOneValue("AL29", {{2019,3,6}, {12,3,12}}, "NO2"), 35.0),
  pollution_server:stop().

getDailyOverLimit_test() ->
  pollution_server:start(),
  pollution_server:addStation("AL29", {13.33, 12.56}),
  pollution_server:addStation("Mickiewicza", {13.29, 11.23}),
  pollution_server:addValue({13.33, 12.56}, {{2019,3,6}, {12,3,18}}, "NO2", 35.0),
  pollution_server:addValue("AL29", {{2019,3,6}, {12,3,12}}, "NO2", 89.8),
  pollution_server:addValue("Mickiewicza", {{2019,3,6}, {12,2,12}}, "NO2", 15.0),
  pollution_server:addValue("Mickiewicza", {{2019,3,6}, {11,3,12}}, "pm10", 135.6),
  ?assertNotEqual(pollution_server:getDailyOverLimit({2019,3,6}, "NO2", 45), 2),
  pollution_server:stop().


