-module(erlang_server_controller, [Req]).
-compile(export_all).

blub('GET', []) ->
    {output, 'blubb!'}.