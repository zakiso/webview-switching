//
//  ViewController.m
//  WebviewProgressBar
//
//  Created by Zhiqiang Deng on 16/5/11.
//  Copyright © 2016年 Zhiqiang Deng. All rights reserved.
//

#import "ViewController.h"
#import "HXWebView.h"

@interface ViewController ()<HXWebViewDelegate>
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) HXWebView *webView;

@end

@implementation ViewController

//创建webView
- (HXWebView *)webView
{
    if ( !_webView) {
        CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _webView = [[HXWebView alloc] initWithFrame:frame];
        _webView.delegate = self;
    }
    return _webView;
}


- (void)viewDidLoad {

    [super viewDidLoad];
    [self.view addSubview:self.webView];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initProgress];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.qq.com/"]]];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)initProgress
{
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, [UIScreen mainScreen].bounds.size.width, progressBarHeight);
    self.progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = barFrame;
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.tintColor = [UIColor blueColor];
    self.progressView.trackTintColor=[UIColor clearColor];
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.progressView setProgress:0 animated:YES];
}

#pragma mark hxwebview 的代理方法
-(void)webViewDidFinishLoad:(HXWebView *)webView
{
    self.title = self.webView.title;
}

-(void)webView:(HXWebView *)webView updateProgress:(double)progress
{
    if (progress>=1.f) {
        [self.progressView setProgress:0.f animated:YES];
    }else{
        [self.progressView setProgress:progress animated:YES];
    }
}

-(void)webView:(HXWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error:%@",error);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
