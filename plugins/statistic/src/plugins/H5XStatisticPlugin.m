//
//  H5XStatisticPlugin.m
//  fusion
//
//  Created by laole918 on 2022/6/30.
//

#import "H5XStatisticPlugin.h"
#import <Flurry-iOS-SDK/Flurry.h>

@interface H5XStatisticPlugin()

@end

@implementation H5XStatisticPlugin

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (NSString *)name {
    return @"statistic";
}

- (void)onAppDelegateCreate:(H5XAppDelegate *)delegate info:(NSDictionary *)info {
    if ([[info allKeys] containsObject:@"app_key"]) {
        NSString *appKey = [info objectForKey:@"app_key"];
    #ifdef DEBUG
        FlurryLogLevel logLevel = FlurryLogLevelDebug;
    #else
        FlurryLogLevel logLevel = FlurryLogLevelNone;
    #endif
        [Flurry startSession:appKey
           withSessionBuilder:[[[FlurrySessionBuilder new]
              withCrashReporting:YES]
              withLogLevel:logLevel]];
    }
}

- (void)onCreate {
    [self.bridge registerHandler:@"Statistic.trackEvent" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSArray * array = (NSArray *) data;
        NSString * event = array.count > 0 ? [array objectAtIndex:0] : nil;
        NSDictionary * params = array.count > 1 ? [array objectAtIndex:1] : nil;
        NSNumber * timedNum = array.count > 2 ? [array objectAtIndex:2] : nil;
        if (params) {
            if (timedNum) {
                BOOL timed = [timedNum boolValue];
                [Flurry logEvent:event withParameters:params timed:timed];
            } else {
                [Flurry logEvent:event withParameters:params];
            }
        } else {
            if (timedNum) {
                BOOL timed = [timedNum boolValue];
                [Flurry logEvent:event timed:timed];
            } else {
                [Flurry logEvent:event];
            }
        }
    }];
    [self.bridge registerHandler:@"Statistic.endTrackEvent" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSArray * array = (NSArray *) data;
        NSString * event = array.count > 0 ? [array objectAtIndex:0] : nil;
        NSDictionary * params = array.count > 1 ? [array objectAtIndex:1] : nil;
        [Flurry endTimedEvent:event withParameters:params];
    }];
}

@end
