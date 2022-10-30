//
//  H5XSplashAdVC.h
//  fusion
//
//  Created by laole918 on 2022/7/4.
//

#import <Foundation/Foundation.h>
#import "H5XFusionAdPlugin.h"
#import <UIKit/UIKit.h>

@interface H5XSplashAdVC : UIViewController

- (instancetype)initWithSplashId:(NSString *)splashId plugin:(H5XFusionAdPlugin *) plugin;
- (void)loadAd;
@end
