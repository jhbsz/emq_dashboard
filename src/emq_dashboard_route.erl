%%--------------------------------------------------------------------
%% Copyright (c) 2015-2016 Feng Lee <feng@emqtt.io>.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

%% @doc Route API.
-module(emq_dashboard_route).

-include("emq_dashboard.hrl").

-include_lib("emqttd/include/emqttd.hrl").

-include_lib("stdlib/include/qlc.hrl").

-define(ROUTE, mqtt_route).

-http_api({"routes", list, [{"topic",     binary},
                            {"curr_page", int, 1},
                            {"page_size", int, 100}]}).

-export([list/3]).

list(Topic, PageNo, PageSize) when ?EMPTY_KEY(Topic) ->
    TotalNum = mnesia:table_info(?ROUTE, size),
    Qh = qlc:q([R || R <- mnesia:table(?ROUTE)]),
    mnesia:async_dirty(fun emq_dashboard:query_table/5,
                       [Qh, PageNo, PageSize, TotalNum, fun row/1]);

list(Topic, PageNo, PageSize) ->
    Fun = fun() -> mnesia:dirty_read(?ROUTE, Topic) end,
    emq_dashboard:lookup_table(Fun, PageNo, PageSize, fun row/1).

row(#mqtt_route{topic = Topic, node= Node}) ->
    [{topic, Topic}, {node, Node}].

