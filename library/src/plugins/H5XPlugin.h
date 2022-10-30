//
//  H5XPlugin.h
//  h5x
//
//  Created by laole918 on 2022/6/28.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "H5XViewController.h"
#import "WKWebViewJavascriptBridge.h"

@class H5XAppDelegate;

@interface H5XPlugin : NSObject
@property (nonatomic, strong) NSString * name;

@property (nonatomic, strong) H5XViewController * viewController;
@property (nonatomic, strong) WKWebView * webview;
@property (nonatomic, strong) WKWebViewJavascriptBridge * bridge;

- (void)onAppDelegateCreate:(H5XAppDelegate *) delegate info:(NSDictionary *) info;
- (void)onAppDidEnterBackground:(UIApplication *)application;
- (void)onAppDidBecomeActive:(UIApplication *)aapplicationpp;
- (void)onCreate;
- (void)onStart;
- (void)onResume;
- (void)onPause;
- (void)onStop;
- (void)onDestroy;
@end
