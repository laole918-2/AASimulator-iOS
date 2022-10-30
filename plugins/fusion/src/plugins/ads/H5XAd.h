//
//  H5XAd.h
//  fusion
//
//  Created by laole918 on 2022/7/2.
//

#import <Foundation/Foundation.h>
#import "H5XViewController.h"
#import "WKWebViewJavascriptBridge.h"
#import <WebKit/WebKit.h>

@class H5XFusionAdPlugin;

@interface H5XAd : NSObject

- (instancetype)initWithHandlerName:(NSString *) handlerName uniqueId:(NSString *) uniqueId plugin:(H5XFusionAdPlugin *) plugin;

- (H5XViewController *) viewController;
- (WKWebView *) webview;
- (WKWebViewJavascriptBridge *) bridge;

- (void)loadAd:(NSDictionary *) json;
- (void)showAd:(NSDictionary *) json;
- (void)destroy;
- (void)callbackHandler:(NSString *) event ext:(NSDictionary<NSString *, id> *) ext;
- (void)callbackHandler:(NSString *) event;

@end
