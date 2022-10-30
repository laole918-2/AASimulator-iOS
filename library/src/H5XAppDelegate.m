//
//  H5XAppDelegate.m
//  library
//
//  Created by laole918 on 2022/6/28.
//

#import "H5XAppDelegate.h"
#import "H5XViewController.h"
#import "H5XToastPlugin.h"
#import "GCDWebServer.h"


@interface H5XAppDelegate()
@property (strong, nonatomic) GCDWebServer* webServer;
@end

@implementation H5XAppDelegate

- (instancetype)init {
    if (self = [super init]) {
        self.plugins = [NSMutableArray new];
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self.plugins addObject:[[H5XToastPlugin alloc] init]];
    NSArray<H5XPlugin *> * plugins = [self getPlugins];
    if (plugins && plugins.count > 0) {
        [self.plugins addObjectsFromArray:plugins];
    }
//            JSONObject pluginsJSONObject = null;
//            if (manifestJSONObject != null) {
//                pluginsJSONObject = manifestJSONObject.optJSONObject("plugins");
//            }
    for (H5XPlugin * plugin in self.plugins) {
//                JSONObject infoJSONObject = null;
//                if (pluginsJSONObject != null) {
//                    infoJSONObject = pluginsJSONObject.optJSONObject(plugin.name());
//                    if (infoJSONObject != null && infoJSONObject.has("android")) {
//                        infoJSONObject = infoJSONObject.optJSONObject("android");
//                    }
//                }
//        plugin.onAppCreate(this, infoJSONObject != null ? infoJSONObject : new JSONObject());
        [plugin onAppDelegateCreate:self info:nil];
    }
    NSString * rootDir = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"/assets/h5x/games/AA Simulator/"];
    self.webServer = [[GCDWebServer alloc] init];
    [self.webServer addGETHandlerForBasePath:@"/" directoryPath:rootDir indexFilename:nil cacheAge:3600 allowRangeRequests:YES];
    [self.webServer startWithPort:18080 bonjourName:@""];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    H5XViewController *rootVC = [[H5XViewController alloc] init];
    rootVC.modalPresentationStyle = UIModalPresentationFullScreen;
//    [rootVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:rootVC];
//    nav.navigationBar.hidden = YES;
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    for (H5XPlugin * plugin in self.plugins) {
        [plugin onAppDidEnterBackground:application];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    for (H5XPlugin * plugin in self.plugins) {
        [plugin onAppDidBecomeActive:application];
    }
}

- (NSArray<H5XPlugin*> *) getPlugins {
    return nil;
}

@end
