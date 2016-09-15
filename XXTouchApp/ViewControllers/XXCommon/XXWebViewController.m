//
//  XXWebViewController.m
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "XXWebViewController.h"
#import "ARSafariActivity.h"
#import <Masonry/Masonry.h>

@interface XXWebViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate>
@property (nonatomic, strong) UIWebView *agreementWebView;
@property (nonatomic, strong) NJKWebViewProgressView *progressView;
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;
@property (nonatomic, strong) UIBarButtonItem *shareItem;
@property (nonatomic, strong) UIBarButtonItem *transferItem;

@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@end

@implementation XXWebViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.agreementWebView];
    [self.agreementWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NJKWebViewProgress *)progressProxy {
    if (!_progressProxy) {
        NJKWebViewProgress *progressProxy = [[NJKWebViewProgress alloc] init]; // instance variable
        progressProxy.webViewProxyDelegate = self;
        progressProxy.progressDelegate = self;
        _progressProxy = progressProxy;
    }
    return _progressProxy;
}

- (NJKWebViewProgressView *)progressView {
    if (!_progressView) {
        CGFloat progressBarHeight = 2.f;
        CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
        CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
        NJKWebViewProgressView *progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _progressView = progressView;
    }
    return _progressView;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self.agreementWebView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self updateViewConstraints];
}

- (UIWebView *)agreementWebView {
    if (!_agreementWebView) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        webView.delegate = self.progressProxy;
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
        [webView loadRequest:request];
        _agreementWebView = webView;
    }
    return _agreementWebView;
}

- (UIBarButtonItem *)shareItem {
    if (!_shareItem) {
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openDocumentSafari:) ];
        anotherButton.tintColor = [UIColor whiteColor];
        _shareItem = anotherButton;
    }
    return _shareItem;
}

- (UIBarButtonItem *)transferItem {
    if (!_transferItem) {
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(transferDocument:)];
        anotherButton.tintColor = [UIColor whiteColor];
        _transferItem = anotherButton;
    }
    return _transferItem;
}

- (void)openDocumentSafari:(id)sender {
    ARSafariActivity *safariActivity = [[ARSafariActivity alloc] init];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[self.url] applicationActivities:@[safariActivity]];
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

- (void)transferDocument:(id)sender {
    self.documentController.URL = self.url;
    BOOL didPresentOpenIn = [self.documentController presentOpenInMenuFromBarButtonItem:sender animated:YES];
    if (!didPresentOpenIn) {
        [self.navigationController.view makeToast:XXLString(@"No apps available")];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
    if ([[UIApplication sharedApplication] canOpenURL:self.url]) {
        self.navigationItem.rightBarButtonItem = self.shareItem;
    } else {
        self.navigationItem.rightBarButtonItem = self.transferItem;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView == _agreementWebView && _progressView) {
        [_progressView setProgress:0.0 animated:YES];
    }
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title.length > 0) {
        self.title = title;
    }
}

#pragma mark - DocumentInteractionController

- (UIDocumentInteractionController *)documentController {
    if (!_documentController) {
        UIDocumentInteractionController *documentController = [[UIDocumentInteractionController alloc] init];
        _documentController = documentController;
    }
    return _documentController;
}

#pragma mark - NJKWebViewProgressDelegate

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    [_progressView setProgress:progress animated:YES];
}

- (void)dealloc {
    CYLog(@"");
}

@end
