//
//  H5XRewardAd.m
//  fusion
//
//  Created by laole918 on 2022/7/3.
//

#import "H5XRewardAd.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface H5XRewardAd() <GADFullScreenContentDelegate>
@property(nonatomic, strong) GADRewardedAd *rewardVideoAd;
@end

@implementation H5XRewardAd

- (void)loadAd:(NSDictionary *)json {
    NSString * slotId = [json objectForKey:@"slot_id"];
    NSString * userId = [json objectForKey:@"user_id"];
    NSString * ext = [json objectForKey:@"ext"];
    
    
    GADRequest *request = [GADRequest request];
    [GADRewardedAd loadWithAdUnitID:slotId request:request completionHandler:^(GADRewardedAd *ad, NSError *error) {
        if (error) {
            NSDictionary * map = @{
                @"type": @(0),
                @"code": @(error.code),
                @"msg": error.localizedDescription
            };
            [self callbackHandler:@"onError" ext:map];
            [self destroy];
            NSLog(@"Rewarded ad failed to load with error: %@", [error localizedDescription]);
            return;
        }
        self.rewardVideoAd = ad;
        self.rewardVideoAd.fullScreenContentDelegate = self;
        NSLog(@"Rewarded ad loaded.");
        [self callbackHandler:@"onAdLoad"];
    }];
}

- (void)showAd:(NSDictionary *) json {
    if (self.rewardVideoAd) {
        [self.rewardVideoAd presentFromRootViewController:self.viewController userDidEarnRewardHandler:^{
            [self callbackHandler:@"onVideoComplete"];
            NSDictionary * map = @{
                @"track_uid": @""
            };
            [self callbackHandler:@"onReward" ext:map];
        }];
    }
}

- (void)destroy {
    [super destroy];
    self.rewardVideoAd = nil;
}



/// Tells the delegate that an impression has been recorded for the ad.
- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
    [self callbackHandler:@"onAdShow"];
}

/// Tells the delegate that a click has been recorded for the ad.
- (void)adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>)ad {
    [self callbackHandler:@"onAdClicked"];
}

/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    
}

/// Tells the delegate that the ad will dismiss full screen content.
- (void)adWillDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    [self callbackHandler:@"onAdClosed"];
    [self destroy];
}

@end
