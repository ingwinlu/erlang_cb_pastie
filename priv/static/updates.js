function listen_for_updates(timestamp){
    $.ajax("/pastie/update/"+timestamp, { success:
        function(data, code, xhr) {
            for (var i=0; i<data.new_pasties.length; i++){

                /*
                var msg = data.new_pasties[i].id;
                console.log(i+": "+msg); */
            }
            listen_for_updates(data.timestamp);
        } });
}

$(document).ready(function() {
    listen_for_updates(0);
});

