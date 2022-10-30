//
//  H5XViewController.m
//  library
//
//  Created by laole918 on 2022/6/28.
//

#import "H5XViewController.h"
#import <WebKit/WebKit.h>
#import "WKWebViewJavascriptBridge.h"
#import "H5XAppDelegate.h"

@interface H5XViewController () <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>
@property (nonatomic, strong, nonnull) WKWebView * webview;
@property (nonatomic, strong, nonnull) WKWebViewJavascriptBridge * bridge;
@end

@implementation H5XViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect bounds = self.view.bounds;
    if (bounds.size.width > bounds.size.height) {
        CGFloat h = bounds.size.width;
        bounds.size.width = bounds.size.height;
        bounds.size.height = h;
    }
    
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    WKUserScript *logScript = [[WKUserScript alloc] initWithSource:@"var console={};console.log=function(){for(var i=0;i<arguments.length;i++){window.webkit.messageHandlers['logger'].postMessage(JSON.stringify(arguments[i]))}};" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    WKWebViewConfiguration * configer = [[WKWebViewConfiguration alloc] init];
//    [userContentController addUserScript:logScript];
//    [userContentController addScriptMessageHandler:self name:@"logger"];
    configer.userContentController = userContentController;
    configer.selectionGranularity = YES;
    
    configer.preferences = [[WKPreferences alloc] init];
    configer.preferences.javaScriptEnabled = YES;
//    configer.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    
    // 默认是NO，这个值决定了用内嵌HTML5播放视频还是用本地的全屏控制
    configer.allowsInlineMediaPlayback = YES;
    // 自动播放, 不需要用户采取任何手势开启播放
    // WKAudiovisualMediaTypeNone 音视频的播放不需要用户手势触发, 即为自动播放
    if (@available(iOS 10.0, *)) {
        configer.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    }
    configer.allowsAirPlayForMediaPlayback = YES;
    configer.allowsPictureInPictureMediaPlayback = YES;
    
    self.webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height) configuration:configer];
    [self.view addSubview:self.webview];

    [self.webview setAllowsBackForwardNavigationGestures:true];
    
    self.webview.scrollView.alwaysBounceVertical = YES;
    self.webview.scrollView.showsHorizontalScrollIndicator = NO;
    self.webview.scrollView.bouncesZoom = NO;
    
    
    if (self.modalPresentationStyle == UIModalPresentationFullScreen) {
        if (@available(iOS 11.0, *)) {
            self.webview.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    
    self.webview.navigationDelegate = self;
    self.webview.UIDelegate = self;
    
    
    self.bridge = [[WKWebViewJavascriptBridge alloc] initWithWebView:self.webview];
    
    [self initPlugins];
    
//////    NSString *urlStr = @"https://www.baidu.com";
//////    NSString *urlStr = @"http://192.168.0.106:8080/index.html";
//    NSString *urlStr = @"http://192.168.0.109:5500/index.html";
    NSString *urlStr = @"http://127.0.0.1:18080/index.html";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webview loadRequest:request];
    
//
//    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"assets/h5x/games/Iceland Farm/"];
//
//    NSURL * pathURL = [NSURL fileURLWithPath:filePath];
//    NSString * dir = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"/assets/h5x/games/Iceland Farm/"];
//    [self.webview loadFileURL:pathURL allowingReadAccessToURL:[NSURL fileURLWithPath:dir]];
}

- (void)initPlugins {
    NSArray<H5XPlugin *> * plugins = ((H5XAppDelegate *)[UIApplication sharedApplication].delegate).plugins;
    for (H5XPlugin * plugin in plugins) {
        plugin.viewController = self;
        plugin.webview = self.webview;
        plugin.bridge = self.bridge;
        
        [plugin onCreate];
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
#ifdef DEBUG
    if ([@"logger" compare: message.name] == NSOrderedSame) {
        NSLog(@"console: %@", message.body);
    }
#endif
}

//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
//    //如果是跳转一个新页面
//    if (navigationAction.targetFrame == nil) {
//        [webView loadRequest:navigationAction.request];
//    }
//    decisionHandler(WKNavigationActionPolicyAllow);
//}

//是否旋转
-(BOOL)shouldAutorotate {
    return NO;
}
//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
//viewController初始显示的方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
