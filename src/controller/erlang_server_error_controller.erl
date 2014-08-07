-module(erlang_server_error_controller, [Req]).
-compile(export_all).

lost('GET', []) ->
    {ok, []}.

calamity('GET', []) ->
    {output, "Hello on erlang_server, a calamity has occured."}.
