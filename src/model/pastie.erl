-module(pastie, [Id, PasteString, Language, PasteTime, PasteName]).
-compile(export_all).

validation_tests() ->
    [{fun() -> length(string:strip(PasteString)) > 0 end,
        "Paste Text must not be empty!"},
     {fun() -> length(string:strip(PasteString)) < 20000 end,
        "Paste Text too long (must be <20000 long)!"},
     {fun() -> length(string:strip(PasteName)) < 50 end,
        "Paste Name too long (must be < 50 long)!"}].

get_paste_as_array() ->
    re:split(PasteString,"[\n]+",[{return,list},{newline,anycrlf}]).

get_pure_id() ->
    [_,X] = string:tokens(Id,"-"),
    X.

get_formatted_paste_time() ->
    {Date={Year,Month,Day},Time={Hour,Minutes,Seconds}} = PasteTime,
    lists:concat([Year, "-", Month, "-", Day, ", " ,Hour ,":" ,Minutes ,":" ,Seconds]).

iso_8601_fmt() ->
    {{Year,Month,Day},{Hour,Min,Sec}} = PasteTime,
    lists:flatten(io_lib:format("~4.10.0B-~2.10.0B-~2.10.0B ~2.10.0B:~2.10.0B:~2.10.0B",
        [Year, Month, Day, Hour, Min, Sec])).

after_create() ->
    boss_mq:push("new-pasties", [{id,Id},{get_pure_id,get_pure_id()},{iso_8601_fmt,iso_8601_fmt()},{paste_name,PasteName}]),
    case boss_db:count(pastie) =< 100 of
        true -> ok;
        _    -> [Oldest] = boss_db:find(pastie, [],[{limit,1},{order_by,paste_time},{descending,false}]),
                boss_db:delete(Oldest:id()),
                ok
    end.
