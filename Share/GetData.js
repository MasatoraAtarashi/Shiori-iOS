var MyPreprocessor = function() {};

MyPreprocessor.prototype = {
    run: function(arguments) {
        var positionTop = String(document.body.scrollTop);
        var positionLeft = String(document.body.scrollLeft);

        
        var htmlVideoPlayer = document.getElementsByTagName('video')[0];
        var time = "0";
        if(htmlVideoPlayer) {
            time = htmlVideoPlayer.currentTime;
            time = parseInt(time);
            time = String(time);
        }
        
        var url = document.URL
        if (url.match(/youtube/) && time != "0") {
            var video_id = document.URL.split('v=')[1];
            var ampersandPosition = video_id.indexOf('&');
            if(ampersandPosition != -1) {
                video_id = video_id.substring(0, ampersandPosition);
            }
            url = "https://youtu.be/" + video_id + "?t=" + time;
        }
        
        arguments.completionFunction({"url": url, "title": document.title, "positionX": positionLeft, "positionY": positionTop, "time": time});
        //arguments.completionFunction({"URL": document.URL, "pageSource": document.documentElement.outerHTML, "title": document.title, "selection": window.getSelection().toString()});
    },
    
    finalize: function(arguments) {
        location.reload();
    }
};

var ExtensionPreprocessingJS = new MyPreprocessor;

