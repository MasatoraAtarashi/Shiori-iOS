var MyPreprocessor = function() {};

// TODO: リファクタリング
MyPreprocessor.prototype = {
    run: function(arguments) {
        var body = document.body,
            html = document.documentElement,
            userAgent = navigator.userAgent;
            
        var scrollPositionX = document.documentElement.scrollLeft
        var scrollPositionY = document.documentElement.scrollTop
        var maxScrollPositionX = document.documentElement.scrollWidth
        var maxScrollPositionY = document.documentElement.scrollHeight

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
        } else if (url.match(/pornhub/) && time != "0") {
            url = url + "&t=" + time
        } else if (url.match(/nicovideo/) && time != "0") {
            url = url + "?from=" + time
        } else if (url.match(/dailymotion/) && time != "0") {
            url = url + "?start=" + time
//        } else if (url.match(/bilibili/) && time != "0") {
//            //機能しない
//            var video_id = document.URL.split('video/')[1];
//            video_id = video_id.split('.html')[0];
//            url = 'https://www.bilibili.com/video/' + video_id + "?t=" + time
        } else if (url.match(/redtube/) && time != "0") {
            url = url + "?t=" + time
        } else if (url.match(/xhamster/) && time != "0") {
            //アプリでは機能しない。safariで開くと機能する
            time = parseFloat(time)
            time = time.toFixed(2)
            url = url + "?t=" + time
        } else if (url.match(/tube8/) && time != "0") {
            url = url + "?t=" + time
        } else if (url.match(/twitch/) && time != "0") {
            // PCだといけるけどスマホだと機能しない
            var h = Math.floor(time / 3600);
            var m = Math.floor((time % 3600) / 60);
            var s = time % 60
            url = url + "?t=" + h + "h" + m + "m" + s + "s"
        }
        
        // 音声の再生位置を取得
        var audio= document.getElementsByTagName('audio')[0]
        var audioPlaybackPosition= 0;
        if (audio) {
            audioPlaybackPosition = audio.currentTime;
        }
        
        // サムネイル画像を取得
//        var pi = document.getElementsByTagName('meta');
//        var image = "";
//        for(i=0;i<pi.length;i++){
//            if(pi[i].getAttribute("property")=="og:image"){
//                 image = pi[i].getAttribute("content");
//            }
//        }
//        if(image == "") {
//            image = document.images[0].src;
//        }
        var image = ""
        if (document.URL.match(/youtube/)) {
            // youtubeのvideo-idを取得
            var videoId = document.URL.split('v=')[1];
            var ampersandPosition = videoId.indexOf('&');
            // video-idの&=以降を削除
            if (ampersandPosition != -1) {
                videoId = videoId.substring(0, ampersandPosition);
            }
            image = "http://img.youtube.com/vi/" + videoId + "/0.jpg";
        } else {
            var largest = 0;
            var largestImg;
            Array.from(document.body.getElementsByTagName('img')).forEach(function(e) {
                if (largest < e.height) {
                    largestImg = e;largest = e.height
                }
            });
            image = largestImg.src;
        }
        if(image == "") {
            image = document.images[0].src;
        }

        var dateString = ""
        var date = new Date();
        var year = String(date.getFullYear());
        var month = String(date.getMonth() + 1);
        var day = String(date.getDate());
        dateString = year + "." + month + "." + day

        var title = "";
        if(document.title) {
         title = document.title;
        }
        
        // ウィンドウサイズ
        var iw = window.innerWidth;
        var ih = window.innerHeight;
        var ow = window.outerWidth;
        var oh = window.outerHeight;
        
        // TODO: 変数名を合わせる
        arguments.completionFunction(
            {
                "url": url,
                "title": title,
                "userAgent": userAgent,
                "scrollPositionX": scrollPositionX,
                "scrollPositionY": scrollPositionY,
                "maxScrollPositionX": maxScrollPositionX,
                "maxScrollPositionY": maxScrollPositionY,
                "time": time,
                "image": image,
                "date": dateString,
                "videoPlaybackPosition": time,
                "audioPlaybackPosition": audioPlaybackPosition,
                "windowInnerWidth": iw,
                "windowInnerHeight": ih,
                "windowOuterWidth": ow,
                "windowOuterHeight": oh,
            }
         );
    },
    
    finalize: function(arguments) {
        location.reload();
    }
};

var ExtensionPreprocessingJS = new MyPreprocessor;

