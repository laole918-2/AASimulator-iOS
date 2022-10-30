//
//  H5XAppDelegate.h
//  library
//
//  Created by laole918 on 2022/6/28.
//

#import <UIKit/UIKit.h>
#import "H5XPlugin.h"

@interface H5XAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray<H5XPlugin *> * plugins;
- (NSArray<H5XPlugin*> *) getPlugins;
@end
