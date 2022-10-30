//
//  H5XFusionAdPlugin.h
//  fusion
//
//  Created by laole918 on 2022/6/30.
//

#import <Foundation/Foundation.h>
#import "H5XPlugin.h"
#import "H5XAd.h"

@interface H5XFusionAdPlugin : H5XPlugin

@property (strong, nonatomic) NSMutableDictionary<NSString *, H5XAd *> * ads;

@end
