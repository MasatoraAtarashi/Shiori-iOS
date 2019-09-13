var MyPreprocessor = function() {};

MyPreprocessor.prototype = {
run: function(arguments) {
    var positionTop = document.body.scrollTop;
    positionTop = String(positionTop);
    arguments.completionFunction({"url": document.URL, "title": document.title, "position": positionTop});
    //arguments.completionFunction({"URL": document.URL, "pageSource": document.documentElement.outerHTML, "title": document.title, "selection": window.getSelection().toString()});
}
};

var ExtensionPreprocessingJS = new MyPreprocessor;
