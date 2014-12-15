-module(erlang_server_pastie_controller, [Req]).
-compile(export_all).
-default_action(index).

index('GET', []) ->
    Counter = boss_db:count(pastie),
    {ok, [{counter, Counter}]}.

recent('GET', []) ->
    Pasties = boss_db:find(pastie, [],[{limit,20},{order_by,paste_time},{descending,true}]),
    Timestamp = boss_mq:now("new-pasties"),
    {ok, [{pasties, Pasties}, {timestamp,Timestamp}]}.

create('GET', []) ->
    ok;
create('POST', []) -> %% new pastie
    PastieNameParam = Req:post_param("pastie_name"),
    case PastieNameParam of
        [] -> PastieName = "No Name";
        _ -> PastieName = PastieNameParam
    end,
    PastieText = Req:post_param("pastie_text"),
    LanguageText = Req:post_param("language_text"),
    NewPastie = pastie:new(id, PastieText, LanguageText, erlang:now(), PastieName),
    case NewPastie:save() of
        {ok, SavedPastie} ->
            {redirect, "/pastie/view/" ++ SavedPastie:get_pure_id()};
        {error, ErrorList} ->
            {ok, [{errors, ErrorList}, {new_pastie, NewPastie}]}
    end;
create('GET', [PastieId]) -> %% repost a existing pastie
    case boss_db:find("pastie-" ++ PastieId) of
        Pastie ->
            {ok, [{new_pastie, Pastie}]};
        undefined ->
            {redirect, "/pastie/create"};
        {error, Reason} ->
            {redirect, "/pastie/create"}
    end.

view('GET', [PastieId]) ->
    case boss_db:find("pastie-" ++ PastieId) of
        Pastie ->
            {ok, [{pastieid, PastieId}, {foundpastie, Pastie}]};
        {error, Reason} ->
            {output, Reason}
    end.

raw('GET', [PastieId]) ->
    case boss_db:find("pastie-" ++ PastieId) of
        undefined ->
            {redirect, "/", [{errors, ["blub"]}]};
        Pastie ->
            {output, Pastie:paste_string(), [{"Content-Type", "text/plain"}]};
        {error, Reason} ->
            {output, Reason}
    end.

download('GET', [PastieId]) ->
    case boss_db:find("pastie-" ++ PastieId) of
        undefined ->
            {redirect, "/"};
        Pastie ->
            {output, Pastie:paste_string(), [{"Content-Type", "application/octet-stream"},{"Content-Disposition","attachement; filename='" ++ Pastie:id() ++ ".txt'"}]};
        {error, Reason} ->
            {output, Reason}
    end.

delete('GET', [PastieId]) ->
    case boss_db:find("pastie-" ++ PastieId) of
        undefined ->
            {redirect, "/"};
        Pastie ->
            {output, "TODO"};
        {error, Reason} ->
            {output, Reason}
    end.

update('GET', []) ->
    update('GET', ["0"]);
update('GET', [LastTimestamp]) ->
    {ok, Timestamp, NewPasties} = boss_mq:pull("new-pasties", list_to_integer(LastTimestamp)),
    {json, [{timestamp, Timestamp}, {new_pasties, NewPasties}]}.
