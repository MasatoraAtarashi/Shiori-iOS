var MyPreprocessor = function() {};

MyPreprocessor.prototype = {
    run: function(arguments) {
        var positionTop = String(Math.max(window.pageYOffset, document.documentElement.scrollTop, document.body.scrollTop));
        var positionLeft = String(Math.max(window.pageXOffset, document.documentElement.scrollLeft, document.body.scrollLeft));


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
        }
        
        var pi = document.getElementsByTagName('meta');
        var image = "";
        for(i=0;i<pi.length;i++){
            if(pi[i].getAttribute("property")=="og:image"){
                 image = pi[i].getAttribute("content");
            }
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
        arguments.completionFunction({"url": url, "title": title, "positionX": positionLeft, "positionY": positionTop, "time": time, "image": image, "date": dateString});
    },
    
    finalize: function(arguments) {
        location.reload();
    }
};

var ExtensionPreprocessingJS = new MyPreprocessor;

