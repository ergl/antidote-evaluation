#!/usr/bin/env escript

-mode(compile).
-export([main/1]).

%% Example configuration file:
%% ```cluster.config:
%% {latencies, #{
%%     nancy => [{rennes, 10}, {tolouse, 20}],
%%     rennes => [{nancy, 10}, {tolouse, 15}],
%%     tolouse => [{rennes, 15}, {nancy, 20}]
%% }}.
%%
%% {clusters, #{
%%     nancy => #{servers => ['apollo-1-1.imdea', ...],
%%                clients => ['apollo-2-1.imdea', ...]},
%%     rennes => #{servers => ['apollo-1-4.imdea', ...],
%%                 clients => ['apollo-2-4.imdea', ...]},
%%     tolouse => #{servers => ['apollo-1-7.imdea', ...],
%%                  clients => ['apollo-2-7.imdea', ...]}
%% }}.
%% ```

-define(SELF_DIR, "/Users/ryan/dev/imdea/code/lasp-bench/grid_tests/scripts").
-define(SSH_PRIV_KEY, "/Users/ryan/.ssh/imdea_id_ed25519").

-define(IN_NODES_PATH, unicode:characters_to_list(io_lib:format("~s/execute-in-nodes.sh", [?SELF_DIR]))).
-define(CONFIG_DIR, unicode:characters_to_list(io_lib:format("~s/configuration", [?SELF_DIR]))).

-define(ANTIDOTE_BRANCH, "pvc").
-define(LASP_BENCH_BRANCH, "coord").

-define(JOIN_TIMEOUT, timer:minutes(5)).

-define(COMMANDS, [ {check, false}
                  , {antidote, false}
                  , {clients, false}
                  , {prologue, false}

                  , {start, false}
                  , {stop, false}
                  , {join, false}
                  , {prepare, false}

                  , {load, false}
                  , {bench, false}
                  , {stats, false}

                  , {restart, false}
                  , {rebuild, false}
                  , {ring, true}
                  , {versions, true}
                  , {cleanup, false}]).

usage() ->
    Name = filename:basename(escript:script_name()),
    Commands = lists:foldl(fun(El, Acc) -> io_lib:format("~s | ~p", [Acc, El]) end, "", [C || {C, _} <- ?COMMANDS]),
    ok = io:fwrite(
        standard_error,
        "Usage: [-ds] ~s -f <config-file> -c <command=arg>~nCommands: ~s~n",
        [Name, Commands]
    ).

main(Args) ->
    case parse_args(Args) of
        {error, Reason} ->
            io:fwrite(standard_error, "Wrong option: reason ~s~n", [Reason]),
            usage(),
            halt(1);

        {ok, Opts = #{config := ConfigFile}} ->
            {ok, ConfigTerms} = file:consult(ConfigFile),
            {clusters, ClusterMap} = lists:keyfind(clusters, 1, ConfigTerms),

            erlang:put(dry_run, maps:get(dry_run, Opts, false)),
            erlang:put(silent, maps:get(verbose, Opts, false)),

            Command = maps:get(command, Opts),
            CommandArg = maps:get(command_arg, Opts, false),

            io:format("Running command: ~p (arg ~p)~n", [Command, CommandArg]),
            ok = do_command(Command, CommandArg, ClusterMap)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Commands

do_command(check, _, ClusterMap) -> ok = check_nodes(ClusterMap);
do_command(antidote, _, ClusterMap) -> ok = prepare_antidote(ClusterMap);
do_command(clients, _, ClusterMap) -> ok = prepare_lasp_bench(ClusterMap);
do_command(prologue, _, ClusterMap) ->
    ok = check_nodes(ClusterMap),
    ok = prepare_antidote(ClusterMap),
    ok = prepare_lasp_bench(ClusterMap),
    alert("Prologue finished!"),
    ok;

do_command(start, _, ClusterMap) ->
    do_in_nodes_par(server_command("start"), server_nodes(ClusterMap)),
    ok;

do_command(stop, _, ClusterMap) ->
    do_in_nodes_par(server_command("stop"), server_nodes(ClusterMap)),
    ok;

do_command(prepare, Arg, ClusterMap) ->
    ok = do_command(join, Arg, ClusterMap),
    ok = do_command(load, Arg, ClusterMap),
    alert("Prepare finished!"),
    ok;

do_command(join, _, ClusterMap) ->
    NodeNames = server_nodes(ClusterMap),
    Parent = self(),
    Reference = erlang:make_ref(),
    ChildFun = fun() ->
        Reply = do_in_nodes_seq(server_command("join", "/home/borja.deregil/cluster.config"), [hd(NodeNames)]),
        Parent ! {Reference, Reply}
    end,
    Start = erlang:timestamp(),
    ChildPid = erlang:spawn(ChildFun),
    receive
        {Reference, Reply} ->
            End = erlang:timestamp(),
            io:format("~p~n", [Reply]),
            io:format("Ring done after ~p~n", [timer:now_diff(End, Start)]),
            ok
    after ?JOIN_TIMEOUT ->
        io:fwrite(standard_error, "Ring timed out after ~b milis~n", [?JOIN_TIMEOUT]),
        erlang:exit(ChildPid, kill),
        error
    end;

do_command(load, _, ClusterMap) ->
    NodeNames = client_nodes(ClusterMap),
    TargetNode = hd(server_nodes(ClusterMap)),
    io:format("~p~n", [do_in_nodes_seq(client_command("-y load", atom_to_list(TargetNode)), [hd(NodeNames)])]),
    ok;

do_command(bench, _, ClusterMap) ->
    NodeNames = client_nodes(ClusterMap),
    pmap(fun(Node) -> transfer_config(Node, "run.config") end, NodeNames),
    do_in_nodes_par(client_command("run", "/home/borja.deregil/run.config"), NodeNames),
    alert("Benchmark finished!"),
    ok;

do_command(stats, _, ClusterMap) ->
    io:format(
        "~p~n",
        [do_in_nodes_par(
            client_command("report", "/home/borja.deregil/cluster.config"),
            [hd(client_nodes(ClusterMap))])]),
    ok;

do_command(restart, _, ClusterMap) ->
    io:format("~p~n", [do_in_nodes_par(server_command("restart"), server_nodes(ClusterMap))]),
    ok;

do_command(rebuild, _, ClusterMap) ->
    DBNodes = server_nodes(ClusterMap),
    ClientNodes = client_nodes(ClusterMap),

    do_in_nodes_par(server_command("rebuild"), DBNodes),
    do_in_nodes_par(client_command("rebuild"), ClientNodes),
    ok;

do_command(ring, {true, StrRingSize}, ClusterMap) ->
    io:format("~p~n", [do_in_nodes_par(server_command("ring", StrRingSize), server_nodes(ClusterMap))]),
    ok;

do_command(versions, {true, StrUpperVsn}, ClusterMap) ->
    io:format("~p~n", [do_in_nodes_par(server_command("versions", StrUpperVsn), server_nodes(ClusterMap))]),
    ok;

do_command(cleanup, _, ClusterMap) ->
    AllNodes = all_nodes(ClusterMap),
    ClientNodes = client_nodes(ClusterMap),

    io:format("~p~n", [do_in_nodes_par(client_command("tclean"), ClientNodes)]),
    io:format("~p~n", [do_in_nodes_par("rm -rf sources; mkdir -p sources", AllNodes)]),
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Command Impl

check_nodes(ClusterMap) ->
    io:format("Checking that all nodes are up and on the correct governor mode~n"),

    AllNodes = all_nodes(ClusterMap),

    UptimeRes = do_in_nodes_par("uptime", AllNodes),
    false = lists:any(fun(Res) -> string:str(Res, "timed out") =/= 0 end, UptimeRes),

    % Set all nodes to performance governor status, then verify
    _ = do_in_nodes_par("echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor", AllNodes),
    GovernorStatus = do_in_nodes_par("cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor", AllNodes),
    false = lists:any(fun(Res) -> string:str(Res, "powersave") =/= 0 end, GovernorStatus),

    % Transfer antidote, bench and cluster config
    io:format("Transfering benchmark config files (antidote, bench, cluster)...~n"),
    pmap(fun(Node) ->
        transfer_script(Node, "antidote.sh"),
        transfer_script(Node, "bench.sh"),
        transfer_config(Node, "cluster.config")
    end, AllNodes),
    ok.

prepare_antidote(ClusterMap) ->
    NodeNames = server_nodes(ClusterMap),
    io:format("~p~n", [do_in_nodes_par(server_command("dl"), NodeNames)]),
    _ = do_in_nodes_par(server_command("compile"), NodeNames),
    io:format("~p~n", [do_in_nodes_par(server_command("start"), NodeNames)]),
    ok.

prepare_lasp_bench(ClusterMap) ->
    NodeNames = client_nodes(ClusterMap),
    io:format("~p~n", [do_in_nodes_par(client_command("dl"), NodeNames)]),
    _ = do_in_nodes_par(client_command("compile"), NodeNames),
    ok = maps:fold(fun(ClusterName, #{clients := ClusterClients}, _Acc) ->
        io:format(
            "~p~n",
            [do_in_nodes_par(
                client_command("tc", atom_to_list(ClusterName), "/home/borja.deregil/cluster.config"),
                ClusterClients)
            ]
        ),
        ok
    end, ok, ClusterMap),
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Util

server_command(Command) ->
    io_lib:format("./antidote.sh -b ~s ~s", [?ANTIDOTE_BRANCH, Command]).
server_command(Command, Arg) ->
    io_lib:format("./antidote.sh -b ~s ~s ~s", [?ANTIDOTE_BRANCH, Command, Arg]).

client_command(Command) ->
    io_lib:format("./bench.sh -b ~s ~s", [?LASP_BENCH_BRANCH, Command]).

client_command(Command, Arg) ->
    io_lib:format("./bench.sh -b ~s ~s ~s", [?LASP_BENCH_BRANCH, Command, Arg]).

client_command(Command, Arg1, Arg2) ->
    io_lib:format("./bench.sh -b ~s ~s ~s ~s", [?LASP_BENCH_BRANCH, Command, Arg1, Arg2]).

transfer_script(Node, File) ->
    transfer_from(Node, ?SELF_DIR, File).

transfer_config(Node, File) ->
    transfer_from(Node, ?CONFIG_DIR, File).

transfer_from(Node, Path, File) ->
    Cmd = io_lib:format(
        "scp -i ~s ~s/~s borja.deregil@~s:/home/borja.deregil",
        [?SSH_PRIV_KEY, Path, File, atom_to_list(Node)]
    ),
    safe_cmd(Cmd).

all_nodes(Map) ->
    lists:usort(lists:flatten([S ++ C || #{servers := S, clients := C} <- maps:values(Map)])).
server_nodes(Map) ->
    lists:usort(lists:flatten([N || #{servers := N} <- maps:values(Map)])).
client_nodes(Map) ->
    lists:usort(lists:flatten([N || #{clients := N} <- maps:values(Map)])).


do_in_nodes_seq(Command, Nodes) ->
    Cmd = io_lib:format("~s \"~s\" ~s", [?IN_NODES_PATH, Command, list_to_str(Nodes)]),
    safe_cmd(Cmd).

do_in_nodes_par(Command, Nodes) ->
    pmap(fun(Node) ->
        Cmd = io_lib:format("~s \"~s\" ~s", [?IN_NODES_PATH, Command, atom_to_list(Node)]),
        safe_cmd(Cmd)
    end, Nodes).

list_to_str(Nodes) ->
    lists:foldl(fun(Elem, Acc) -> Acc ++ io_lib:format("~s ", [Elem]) end, "", Nodes).

safe_cmd(Cmd) ->
    case get_default(silent, false) of
        true -> ok;
        false -> ok = io:format("~s~n", [Cmd])
    end,
    case get_default(dry_run, false) of
        true -> "";
        false -> os:cmd(Cmd)
    end.

get_default(Key, Default) ->
    case erlang:get(Key) of
        undefined ->
            Default;
        Val ->
            Val
    end.

pmap(F, L) ->
    Parent = self(),
    lists:foldl(fun(X, N) ->
        spawn_link(fun() -> Parent ! {pmap, N, F(X)} end),
        N+1
    end, 0, L),
    L2 = [receive {pmap, N, R} -> {N,R} end || _ <- L],
    L3 = lists:keysort(1, L2),
    [R || {_,R} <- L3].

% Alert user with sound when benchmark is finished
alert(Msg) ->
    safe_cmd(io_lib:format("osascript -e 'display notification with title \"~s\"'", [Msg])),
    safe_cmd("afplay /System/Library/Sounds/Glass.aiff"),
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getopt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parse_args([]) -> {error, noargs};
parse_args(Args) ->
    case parse_args(Args, #{}) of
        {ok, Opts} -> required(Opts);
        Err -> Err
    end.

parse_args([], Acc) -> {ok, Acc};
parse_args([ [$- | Flag] | Args], Acc) ->
    case Flag of
        [$s] ->
            parse_args(Args, Acc#{silent => true});
        [$d] ->
            parse_args(Args, Acc#{dry_run => true});
        [$f] ->
            parse_flag(Flag, Args, fun(Arg) -> Acc#{config => Arg} end);
        [$c] ->
            parse_flag(Flag, Args, fun(Arg) -> parse_command(Arg, Acc) end);
        [$h] ->
            usage(),
            halt(0);
        _ ->
            {error, io_lib:format("badarg ~p", [Flag])}
    end;

parse_args(_, _) ->
    {error, "noarg"}.

parse_flag(Flag, Args, Fun) ->
    case Args of
        [FlagArg | Rest] -> parse_args(Rest, Fun(FlagArg));
        _ -> {error, io_lib:format("noarg ~p", [Flag])}
    end.

parse_command(Arg, Acc) ->
    case string:str(Arg, "=") of
        0 -> Acc#{command => list_to_atom(Arg)};
        _ ->
            % crash on malformed command for now
            [Command, CommandArg | _Ignore] = string:tokens(Arg, "="),
            Acc#{command_arg => {true, CommandArg}, command => list_to_atom(Command)}
    end.

required(Opts) ->
    Required = [config, command],
    Valid = lists:all(fun(F) -> maps:is_key(F, Opts) end, Required),
    case Valid of
        false ->
            {error, io_lib:format("Missing required fields: ~p", [Required])};
        true ->
            case maps:is_key(command, Opts) of
                true -> check_command(Opts);
                false -> {ok, Opts}
            end
    end.

check_command(Opts=#{command := Command}) ->
    case lists:member({Command, maps:is_key(command_arg, Opts)}, ?COMMANDS) of
        true ->
            {ok, Opts};
        false ->
            {error, io_lib:format("Bad command \"~p\", or command needs arg, but none was given", [Command])}
    end.
