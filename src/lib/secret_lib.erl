-module(secret_lib).
-export([get_secret/1]).
%-compile(export_all).

%%public, will be exported
get_secret(Bytes) ->
    base64:encode(crypto:strong_rand_bytes(Bytes)).

