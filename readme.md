# 简述

兼容使用UIWebView和WKWebView,在iOS7上自动使用UIWebView，在iOS8及以上版本自动使用WKWebView，使用WKWebView能有效减少内存开销。

另外，实现了UIWebView和WKWebView的进度条。

其中进度条NJKWebViewProgress来自[NJKWebViewProgress](https://github.com/ninjinkun/NJKWebViewProgress)

# 使用方法

参见demo

将HXWebView和NJKWebViewProgress文件拖进项目目录下。直接使用HXWebView代替现有的UIWebView，使用方法和UIWebView一样。

 ![webviewimage](webviewimage.gif)
