//
//  AppDelegate.m
//  AA Simulator
//
//  Created by laole918 on 2022/10/30.
//

#import "AppDelegate.h"
#import "H5XStatisticPlugin.h"
#import "H5XFusionAdPlugin.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (NSArray<H5XPlugin *> *)getPlugins {
    NSMutableArray<H5XPlugin *> * plugins = [NSMutableArray new];
    [plugins addObject:[[H5XStatisticPlugin alloc] init]];
    [plugins addObject:[[H5XFusionAdPlugin alloc] init]];
    return plugins;
}


@end
