function listen_for_updates(timestamp){
    $.ajax("/pastie/update/"+timestamp, { success:
        function(data, code, xhr) {
            for (var i=0; i<data.new_pasties.length; i++){
                var block = '<a id="' + data.new_pasties[i].id + '" class="list-group-item" href="/pastie/view/' + data.new_pasties[i].get_pure_id + '">\n \
                                <span class="identifier">id: ' + data.new_pasties[i].id + '</span>, \
                                <span class="name">name: ' + data.new_pasties[i].paste_name + '</span>, \
                                <span class="timestamp">posted: ' + data.new_pasties[i].iso_8601_fmt + '</span> \
                            </a>\n'
                //console.log(i+": "+block);
                //$("#recent_pasties_list").prepend(block);
                $(block).hide().prependTo("#recent_pasties_list").fadeIn("slow");
            }
            listen_for_updates(data.timestamp);
        } });
}