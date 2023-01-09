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
    NSString * appName = [[NSBundle mainBundle].infoDictionary objectForKey:@"H5X_APP_NAME"];
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"assets/h5x/games/%@/h5x/manifest.json", appName] ofType:nil];
    NSData *data = path ? [[NSData alloc] initWithContentsOfFile:path] : nil;
    NSDictionary * manifestJSONObject = data ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil] : nil;
    
    [self.plugins addObject:[[H5XToastPlugin alloc] init]];
    NSArray<H5XPlugin *> * plugins = [self getPlugins];
    if (plugins && plugins.count > 0) {
        [self.plugins addObjectsFromArray:plugins];
    }
    NSDictionary *pluginsJSONObject = nil;
    if (manifestJSONObject) {
        pluginsJSONObject = [manifestJSONObject valueForKey:@"plugins"];
    }
    for (H5XPlugin * plugin in self.plugins) {
        NSDictionary * infoJSONObject = nil;
        if (pluginsJSONObject) {
            infoJSONObject = [pluginsJSONObject valueForKey:plugin.name];
            if ([infoJSONObject valueForKey:@"ios"]) {
                infoJSONObject = [infoJSONObject valueForKey:@"ios"];
            }
        }
        [plugin onAppDelegateCreate:self info:infoJSONObject ? infoJSONObject : [NSDictionary new]];
    }
    NSString * rootDir = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/assets/h5x/games/%@/", appName]];
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
