//
//  HXWebView.h
//  WebviewProgressBar
//
//  Created by Zhiqiang Deng on 16/5/12.
//  Copyright © 2016年 Zhiqiang Deng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXWebView;
@protocol HXWebViewDelegate;

@interface HXWebView : UIView

@property(weak,nonatomic)_Nullable id<HXWebViewDelegate> delegate;

///内部使用的webView 如果有WKWebView则realWebView为WKWebView
@property (nonatomic, readonly) id _Nullable realWebView;
//加载进度
@property (nonatomic, readonly) double estimatedProgress;

@property (nonatomic, copy) NSString  * _Nullable title;
///---- UI 或者 WK 的API
@property (nonatomic, readonly) UIScrollView* _Nullable scrollView;

- (void)loadRequest:(NSURLRequest * _Nullable)request;
- (void)loadHTMLString:(NSString * _Nullable)string baseURL:(nullable NSURL *)baseURL;
- (nullable NSString *)stringByEvaluatingJavaScriptFromString:(NSString * _Nullable)script;



- (void)reload;
- (void)stopLoading;

- (void)goBack;
- (void)goForward;

@property (nullable, nonatomic, readonly, strong) NSURLRequest *request;
@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

@property (nonatomic) BOOL scalesPageToFit;

@end


@protocol HXWebViewDelegate <NSObject>
@optional
- (BOOL)webView:(HXWebView * _Nonnull)webView shouldStartLoadWithRequest:(NSURLRequest * _Nonnull)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(HXWebView * _Nonnull)webView;
- (void)webViewDidFinishLoad:(HXWebView * _Nonnull)webView;
- (void)webView:(HXWebView * _Nonnull)webView didFailLoadWithError:(nullable NSError *)error;
- (void)webView:(HXWebView * _Nonnull)webView updateProgress:(double)progress;
@end

