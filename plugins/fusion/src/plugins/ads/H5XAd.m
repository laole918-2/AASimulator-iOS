//
//  H5XAd.m
//  fusion
//
//  Created by laole918 on 2022/7/2.
//

#import "H5XAd.h"
#import "H5XFusionAdPlugin.h"

@interface H5XAd()

@property (strong, nonatomic) NSString * handlerName;
@property (strong, nonatomic) NSString * uniqueId;
@property (strong, nonatomic) H5XFusionAdPlugin * plugin;

@end

@implementation H5XAd

- (instancetype)initWithHandlerName:(NSString *)handlerName uniqueId:(NSString *)uniqueId plugin:(H5XFusionAdPlugin *)plugin {
    if (self = [super init]) {
        self.handlerName = handlerName;
        self.uniqueId = uniqueId;
        self.plugin = plugin;
    }
    return self;
}

- (H5XViewController *)viewController {
    return self.plugin.viewController;
}

- (WKWebView *)webview {
    return self.plugin.webview;
}

- (WKWebViewJavascriptBridge *)bridge {
    return self.plugin.bridge;
}

- (void)loadAd:(NSDictionary *)json {
    
}

- (void)showAd:(NSDictionary *)json {
    
}

- (void)destroy {
    [self.plugin.ads removeObjectForKey:self.uniqueId];
}

- (void)callbackHandler:(NSString *)event ext:(NSDictionary<NSString *,id> *)ext {
    NSMutableDictionary * map = [NSMutableDictionary new];
    [map setObject:self.uniqueId forKey:@"id"];
    [map setObject:event forKey:@"event"];
    if (ext) {
        [map addEntriesFromDictionary:ext];
    }
    [self.bridge callHandler:self.handlerName data:map responseCallback:nil];
}

- (void)callbackHandler:(NSString *)event {
    [self callbackHandler:event ext:nil];
}

@end
