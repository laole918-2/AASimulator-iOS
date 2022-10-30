//
//  H5XFusionAdPlugin.m
//  fusion
//
//  Created by laole918 on 2022/6/30.
//

#import "H5XFusionAdPlugin.h"
#import "H5XRewardAd.h"
#import "H5XSplashAdVC.h"

@interface H5XFusionAdPlugin()

@property (assign, nonatomic) long uniqueId;
@property (strong, nonatomic) NSString * splashId;

@property (nonatomic, strong) H5XSplashAdVC *splashVC;

@property (nonatomic, assign) NSTimeInterval lastActiveTime;
@property (nonatomic, assign) BOOL didEnterBackground;

@end

@implementation H5XFusionAdPlugin

- (instancetype)init {
    if (self = [super init]) {
        self.ads = [NSMutableDictionary new];
        self.didEnterBackground = YES;
        self.lastActiveTime = 0;
    }
    return self;
}

- (NSString *)name {
    return @"Ad";
}

- (void)onAppDelegateCreate:(H5XAppDelegate *)delegate info:(NSDictionary *)info {
//    NSString *app_id = [info objectForKey:@"app_id"];
//    if ([[info allKeys] containsObject:@"splash_id"]) {
//        self.splashId = [info objectForKey:@"splash_id"];
//    }
    self.splashId = @"ca-app-pub-1144530986936310/8872733915";
}

- (void)onAppDidEnterBackground:(UIApplication *)application {
    self.didEnterBackground = YES;
}

- (void)onAppDidBecomeActive:(UIApplication *)app {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    //指定一个最小展示间隔
    if (time - self.lastActiveTime >= 60 && self.didEnterBackground) {
        if (self.splashVC) {
            [self.splashVC loadAd];
        }
    }
    self.lastActiveTime = time;
    self.didEnterBackground = NO;
}

- (void)onCreate {
    if (self.splashId && self.splashId.length > 0) {
        self.splashVC = [[H5XSplashAdVC alloc] initWithSplashId:self.splashId plugin:self];
    }
    [self regReward];
}

- (void)regReward {
    [self.bridge registerHandler:@"Ad.loadRewardVideo" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary * json = (NSDictionary *) data;
        NSString * unique_id = [NSString stringWithFormat:@"h5x_ad_%ld", ++self.uniqueId];
        H5XAd * ad = [[H5XRewardAd alloc] initWithHandlerName:@"Ad.loadRewardVideo" uniqueId:unique_id plugin:self];
        [ad loadAd:json];
        [self.ads setObject:ad forKey:unique_id];
        responseCallback(unique_id);
    }];
    [self.bridge registerHandler:@"Ad.showRewardVideo" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary * json = (NSDictionary *) data;
        NSString * unique_id = [json objectForKey:@"id"];
        H5XAd * ad = [self.ads objectForKey:unique_id];
        if (ad) {
            [ad showAd:nil];
        }
    }];
}

@end
