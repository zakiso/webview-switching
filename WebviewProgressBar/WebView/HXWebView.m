//
//  HXWebView.m
//  WebviewProgressBar
//
//  Created by Zhiqiang Deng on 16/5/12.
//  Copyright © 2016年 Zhiqiang Deng. All rights reserved.
//

#import "HXWebView.h"
#import <WebKit/WebKit.h>
#import "NJKWebViewProgress.h"

@interface HXWebView()<UIWebViewDelegate,WKUIDelegate,WKNavigationDelegate,NJKWebViewProgressDelegate>

@property (nonatomic,assign) double estimatedProgress;
@property (nonatomic,strong) NSURLRequest *originRequest;
@property (nonatomic,strong) NSURLRequest *currentRequest;
@property (nonatomic,assign) BOOL useUIWebView;

@property (nonatomic, strong) NJKWebViewProgress* njkWebViewProgress;

@end

@implementation HXWebView

@synthesize realWebView = _realWebView;


- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _initMyself];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _initMyself];
    }
    return self;
}

-(void)_initMyself
{
    Class wkWebView = NSClassFromString(@"WKWebView");
    if(wkWebView)
    {
        self.useUIWebView = NO;
        [self initWKWebView];
    }
    else
    {
        self.useUIWebView = YES;
        [self initUIWebView];
    }
    //    self.scalesPageToFit = YES;
    
    [self.realWebView setFrame:self.bounds];
    [self.realWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self addSubview:self.realWebView];
}

-(void)initWKWebView
{
    WKWebViewConfiguration* configuration = [[NSClassFromString(@"WKWebViewConfiguration") alloc] init];
    configuration.preferences = [NSClassFromString(@"WKPreferences") new];
    configuration.userContentController = [NSClassFromString(@"WKUserContentController") new];
    
    WKWebView* webView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:self.bounds configuration:configuration];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    
    _realWebView = webView;
}

-(void)initUIWebView
{
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.bounds];
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    for (UIView *subview in [webView.scrollView subviews])
    {
        if ([subview isKindOfClass:[UIImageView class]])
        {
            ((UIImageView *) subview).image = nil;
            subview.backgroundColor = [UIColor clearColor];
        }
    }
    self.njkWebViewProgress = [[NJKWebViewProgress alloc] init];
    webView.delegate = _njkWebViewProgress;
    _njkWebViewProgress.webViewProxyDelegate = self;
    _njkWebViewProgress.progressDelegate = self;
    _realWebView = webView;
}
-(void)loadRequest:(NSURLRequest *)request
{
    if (self.useUIWebView) {
        [(UIWebView*)self.realWebView loadRequest:request];
    }else{
        [(WKWebView*)self.realWebView loadRequest:request];
    }
}

- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL
{
    if (self.useUIWebView) {
        [(UIWebView*)self.realWebView loadHTMLString:string baseURL:baseURL];
    }else{
        [(WKWebView*)self.realWebView loadHTMLString:string baseURL:baseURL];
    }
}

//计算js代码
- (nullable NSString *)stringByEvaluatingJavaScriptFromString:(NSString * _Nullable)script
{
    if (self.useUIWebView) {
        return [(UIWebView*)self.realWebView stringByEvaluatingJavaScriptFromString:script];
    }else{
        //如果是用wkwebview 来获取title 可以直接使用title属性
        if ([script isEqualToString:@"document.title"]) {
            return ((WKWebView*)self.realWebView).title;
        }else{
            __block NSString *resultString = nil;
            [(WKWebView*)self.realWebView evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
                if (error == nil) {
                    if (result != nil) {
                        resultString = [NSString stringWithFormat:@"%@", result];
                    }
                } else {
                    NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
                }
            }];
            while (resultString == nil)
            {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
            return resultString;
        }
    }
}

-(void)reload
{
    [self.realWebView performSelector:@selector(reload)];
}

-(void)stopLoading
{
    [self.realWebView performSelector:@selector(stopLoading)];
}

-(void)goBack
{
    [self.realWebView performSelector:@selector(goBack)];
}

-(void)goForward
{
    [self.realWebView performSelector:@selector(goForward)];
}

-(BOOL)canGoBack
{
    return [self.realWebView performSelector:@selector(canGoBack)];
}

-(BOOL)canGoForward
{
    return [self.realWebView performSelector:@selector(canGoForward)];
}

-(BOOL)isLoading
{
    return [self.realWebView performSelector:@selector(isLoading)];
}

#pragma mark --> UIWebView的代理方法

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if(self.originRequest == nil)
    {
        self.originRequest = webView.request;
    }
    
    [self callback_webViewDidFinishLoad];
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self callback_webViewDidStartLoad];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self callback_webViewDidFailLoadWithError:error];
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL resultBOOL = [self callback_webViewShouldStartLoadWithRequest:request navigationType:navigationType];
    return resultBOOL;
}

#pragma mark --> WKWebView的代理方法

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    BOOL resultBOOL = [self callback_webViewShouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    BOOL isLoadingDisableScheme = [self isLoadingWKWebViewDisableScheme:navigationAction.request.URL];
    
    if(resultBOOL && !isLoadingDisableScheme)
    {
        self.currentRequest = navigationAction.request;
        if(navigationAction.targetFrame == nil)
        {
            [webView loadRequest:navigationAction.request];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    else
    {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self callback_webViewDidStartLoad];
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self callback_webViewDidFinishLoad];
}
- (void)webView:(WKWebView *) webView didFailProvisionalNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    [self callback_webViewDidFailLoadWithError:error];
}
- (void)webView: (WKWebView *)webView didFailNavigation:(WKNavigation *) navigation withError: (NSError *) error
{
    [self callback_webViewDidFailLoadWithError:error];
}


#pragma mark- CALLBACK IMYVKWebView Delegate

- (void)callback_webViewDidFinishLoad
{
    if([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
    {
        [self.delegate webViewDidFinishLoad:self];
    }
}
- (void)callback_webViewDidStartLoad
{
    if([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)])
    {
        [self.delegate webViewDidStartLoad:self];
    }
}
- (void)callback_webViewDidFailLoadWithError:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
    {
        [self.delegate webView:self didFailLoadWithError:error];
    }
}
-(BOOL)callback_webViewShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(NSInteger)navigationType
{
    BOOL resultBOOL = YES;
    if([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
    {
        if(navigationType == -1) {
            navigationType = UIWebViewNavigationTypeOther;
        }
        resultBOOL = [self.delegate webView:self shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return resultBOOL;
}
-(UIScrollView *)scrollView
{
    return [(id)self.realWebView scrollView];
}

#pragma mark- 基础方法
#pragma mark-  如果没有找到方法 去realWebView 中调用
-(BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL hasResponds = [super respondsToSelector:aSelector];
    if(hasResponds == NO)
    {
        hasResponds = [self.delegate respondsToSelector:aSelector];
    }
    if(hasResponds == NO)
    {
        hasResponds = [self.realWebView respondsToSelector:aSelector];
    }
    return hasResponds;
}


///判断当前加载的url是否是WKWebView不能打开的协议类型
- (BOOL)isLoadingWKWebViewDisableScheme:(NSURL *)url
{
    BOOL retValue = NO;
    
    //判断是否正在加载WKWebview不能识别的协议类型：phone numbers, email address, maps, etc.
    if([url.scheme isEqualToString:@"tel"]) {
        UIApplication *app = [UIApplication sharedApplication];
        if ([app canOpenURL:url]) {
            [app openURL:url];
            retValue = YES;
        }
    }
    
    return retValue;
}

//WkWebView的progress 回调
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"estimatedProgress"])
    {
        self.estimatedProgress = [change[NSKeyValueChangeNewKey] doubleValue];
        [self callback_webViewUpdateProgress:self.estimatedProgress];
    }
    else if([keyPath isEqualToString:@"title"])
    {
        self.title = change[NSKeyValueChangeNewKey];
    }
}

//uiwebview的progress njk progress的代理方法
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    self.estimatedProgress = progress;
    [self callback_webViewUpdateProgress:progress];
    
}
- (void)callback_webViewUpdateProgress:(float)progress
{
    if([self.delegate respondsToSelector:@selector(webView:updateProgress:)])
    {
        [self.delegate webView:self updateProgress:progress];
    }
}

#pragma mark- 清理
-(void)dealloc
{
    if(_useUIWebView)
    {
        UIWebView* webView = _realWebView;
        webView.delegate = nil;
    }
    else
    {
        WKWebView* webView = _realWebView;
        webView.UIDelegate = nil;
        webView.navigationDelegate = nil;
        
        [webView removeObserver:self forKeyPath:@"estimatedProgress"];
        [webView removeObserver:self forKeyPath:@"title"];
    }
    [_realWebView scrollView].delegate = nil;
    [_realWebView stopLoading];
    [(UIWebView*)_realWebView loadHTMLString:@"" baseURL:nil];
    [_realWebView stopLoading];
    [_realWebView removeFromSuperview];
    _realWebView = nil;
}

@end
