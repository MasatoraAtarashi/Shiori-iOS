var MyPreprocessor = function() {};

MyPreprocessor.prototype = {
    run: function(arguments) {
        var positionTop = String(document.body.scrollTop);
        var positionLeft = String(document.body.scrollLeft);
        
        time = String(video.currentTime);
        if(!time) {
            time = "unko"
        } else {
            time = "げぼ"
        }
        arguments.completionFunction({"url": document.URL, "title": document.title, "positionX": positionLeft, "positionY": positionTop, "time": time});
        //arguments.completionFunction({"URL": document.URL, "pageSource": document.documentElement.outerHTML, "title": document.title, "selection": window.getSelection().toString()});
    },
    
    finalize: function(arguments) {
        location.reload();
    }
};

var ExtensionPreprocessingJS = new MyPreprocessor;

