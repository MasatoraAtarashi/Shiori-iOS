var MyPreprocessor = function() {};

MyPreprocessor.prototype = {
    run: function(arguments) {
        var positionTop = String(document.body.scrollTop);
        var positionLeft = String(document.body.scrollLeft);
        
        var video_id = document.URL.split('v=')[1];
        var ampersandPosition = video_id.indexOf('&');
        if(ampersandPosition != -1) {
            video_id = video_id.substring(0, ampersandPosition);
        }
        
        var htmlVideoPlayer = document.getElementsByTagName('video')[0];
        
        var time = htmlVideoPlayer.currentTime;
        time = String(time);
        arguments.completionFunction({"url": document.URL, "title": document.title, "positionX": positionLeft, "positionY": positionTop, "time": time});
        //arguments.completionFunction({"URL": document.URL, "pageSource": document.documentElement.outerHTML, "title": document.title, "selection": window.getSelection().toString()});
    },
    
    finalize: function(arguments) {
        location.reload();
    }
};

function onYouTubeIframeAPIReady() {
    ytPlayer = new YT.Player(
                             'sample', // 埋め込む場所の指定
                             {
                             width: 640, // プレーヤーの幅
                             height: 390, // プレーヤーの高さ
                             videoId: video_id // YouTubeのID
                             }
                             );
}

var ExtensionPreprocessingJS = new MyPreprocessor;

