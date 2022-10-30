//
//  H5XSplashAdVC.m
//  fusion
//
//  Created by laole918 on 2022/7/4.
//

#import "H5XSplashAdVC.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "GoogleAdSplash4NativeAdView.h"
#import "H5XFusionAdPlugin.h"

@interface H5XSplashAdVC() <GADNativeAdLoaderDelegate, GADNativeAdDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIViewController * launchVC;
@property (strong, nonatomic) UIWindow * splashWindow;
@property (nonatomic, strong) GADAdLoader * adLoader;
@property (strong, nonatomic) NSString * splashId;

@property (weak, nonatomic) H5XFusionAdPlugin * plugin;

@property (strong, nonatomic) dispatch_source_t loadTimer;
@property (strong, nonatomic) dispatch_source_t skipTimer;

@property (assign, nonatomic) BOOL timeout;

@end

@implementation H5XSplashAdVC

- (instancetype)initWithSplashId:(NSString *)splashId plugin:(H5XFusionAdPlugin *) plugin {
    if (self = [super init]) {
        self.splashId = splashId;
        self.plugin = plugin;
        
        UIStoryboard* launchScreen = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
        self.launchVC = [launchScreen instantiateInitialViewController];
        self.launchVC.modalPresentationStyle = UIModalPresentationFullScreen;
        self.splashWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        self.splashWindow.windowLevel = UIWindowLevelAlert + 1;
        self.splashWindow.hidden = NO;
        self.splashWindow.rootViewController = self.launchVC;
    }
    return self;
}

- (void)loadAd {
    self.splashWindow.hidden = NO;
    self.splashWindow.rootViewController = self.launchVC;
    
    GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];
    videoOptions.startMuted = YES;
    
    self.adLoader = [[GADAdLoader alloc]
          initWithAdUnitID:self.splashId
        rootViewController:self
                   adTypes:@[ GADAdLoaderAdTypeNative ]
                   options:@[ videoOptions ]];
    self.adLoader.delegate = self;
    
    [self.adLoader loadRequest:[GADRequest request]];
    self.timeout = NO;
    [self starttimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)starttimer {
    __weak typeof(self) _weakSelf = self;
    self.loadTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.loadTimer, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), 1 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.loadTimer, ^{
        if (_weakSelf) {
            dispatch_source_cancel(_weakSelf.loadTimer);
            _weakSelf.loadTimer = nil;
            _weakSelf.timeout = YES;
            _weakSelf.splashWindow.hidden = YES;
            
            NSDictionary * ext = @{
                @"type": @(0),
                @"code": @(0),
                @"msg": @"time out"
            };
            [_weakSelf callbackHandler:@"onError" ext:ext];
        }
    });
    dispatch_resume(self.loadTimer);
}

- (void)stoptimer {
    if (self.loadTimer) {
        dispatch_source_cancel(self.loadTimer);
        self.loadTimer = nil;
    }
}

- (void)callbackHandler:(NSString *) event ext:(NSDictionary *) ext {
    NSMutableDictionary *data = [NSMutableDictionary new];
    [data setValue:@"h5x_ad_startup_splash" forKey:@"id"];
    [data setValue:event forKey:@"event"];
    if (ext) {
        [data addEntriesFromDictionary:ext];
    }
    [self.plugin.bridge callHandler:@"Ad.loadSplash" data:data responseCallback:nil];
}

- (void)callbackHandler:(NSString *)event {
    [self callbackHandler:event ext:nil];
}

/// Called when a native ad is received.
- (void)adLoader:(nonnull GADAdLoader *)adLoader didReceiveNativeAd:(nonnull GADNativeAd *)nativeAd {
    if (self.timeout) {
        return;
    }
    [self stoptimer];
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"GoogleAdSplash4Native" owner:nil options:nil];
    GoogleAdSplash4NativeAdView *nativeAdView = [nibObjects firstObject];
    [self populateNativeAdView:nativeAdView nativeAd:nativeAd];
    [self callbackHandler:@"onAdLoad"];
}

- (void)populateNativeAdView:(GoogleAdSplash4NativeAdView *) nativeAdView nativeAd:(GADNativeAd *) nativeAd {
    nativeAd.delegate = self;
    
    // Set the mediaContent on the GADMediaView to populate it with available
    // video/image asset.
    nativeAdView.mediaView.mediaContent = nativeAd.mediaContent;

    // Populate the native ad view with the native ad assets.
    // The headline is guaranteed to be present in every native ad.
    ((UILabel *)nativeAdView.headlineView).text = nativeAd.headline;

    // These assets are not guaranteed to be present. Check that they are before
    // showing or hiding them.
    ((UILabel *)nativeAdView.bodyView).text = nativeAd.body;
    nativeAdView.bodyView.hidden = nativeAd.body ? NO : YES;

    [((UIButton *)nativeAdView.callToActionView)setTitle:nativeAd.callToAction
                                                  forState:UIControlStateNormal];
    nativeAdView.callToActionView.hidden = nativeAd.callToAction ? NO : YES;
    
    [self startScaleAnimation:nativeAdView.callToActionView];

//    ((UIImageView *)nativeAdView.iconView).image = nativeAd.icon.image;
//      nativeAdView.iconView.hidden = nativeAd.icon ? NO : YES;

//      ((UIImageView *)nativeAdView.starRatingView).image = [self imageForStars:nativeAd.starRating];
//      nativeAdView.starRatingView.hidden = nativeAd.starRating ? NO : YES;

    ((UILabel *)nativeAdView.storeView).text = nativeAd.store;
    nativeAdView.storeView.hidden = nativeAd.store ? NO : YES;

    ((UILabel *)nativeAdView.priceView).text = nativeAd.price;
    nativeAdView.priceView.hidden = nativeAd.price ? NO : YES;

 
    ((UILabel *)nativeAdView.advertiserView).text = nativeAd.advertiser;
    nativeAdView.advertiserView.hidden = nativeAd.advertiser ? NO : YES;

    // In order for the SDK to process touch events properly, user interaction
    // should be disabled.
    nativeAdView.callToActionView.userInteractionEnabled = NO;

    // Associate the native ad view with the native ad object. This is
    // required to make the ad clickable.
    nativeAdView.nativeAd = nativeAd;
    
    nativeAdView.frame = self.view.bounds;
    [self.view addSubview:nativeAdView];
    
    __weak typeof(self) _weakSelf = self;
    __weak UILabel * _weakSkip = nativeAdView.skip;
    __block int second = 5;
    self.skipTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.skipTimer, DISPATCH_TIME_NOW, 1.2 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.skipTimer, ^{
        if (second == 0) {
            if (_weakSelf) {
                [_weakSelf onAdClosed];
                dispatch_source_cancel(_weakSelf.skipTimer);
                _weakSelf.skipTimer = nil;
            }
        } else {
            if (_weakSkip) {
                _weakSkip.text = [NSString stringWithFormat:@"Skip %d", second];
            }
            second--;
        }
    });
    dispatch_resume(self.skipTimer);
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapGesture.delegate = self;
    [nativeAdView.skip addGestureRecognizer:tapGesture];
    nativeAdView.skip.userInteractionEnabled = YES;
    self.splashWindow.rootViewController = self;
}

- (void)tapAction:(UITapGestureRecognizer *) sender {
    [self onAdClosed];
}

- (void)startScaleAnimation:(UIView *)view {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@1.f, @1.1f, @1.f];
    animation.keyTimes = @[@0.f, @0.5f, @1.f];
    animation.duration = 1; //1000ms
    animation.repeatCount = FLT_MAX;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    [animation setValue:kBreathAnimationKey forKey:kBreathAnimationName];
    [view.layer addAnimation:animation forKey:@"scale"];
}

/// Called when adLoader fails to load an ad.
- (void)adLoader:(nonnull GADAdLoader *)adLoader
didFailToReceiveAdWithError:(nonnull NSError *)error {
    if (self.timeout) {
        return;
    }
    [self stoptimer];
    NSDictionary * ext = @{
        @"type": @(0),
        @"code": @(error.code),
        @"msg": error.localizedDescription
    };
    [self callbackHandler:@"onError" ext:ext];
    self.splashWindow.hidden = YES;
}

- (void)onAdClosed {
    [self callbackHandler:@"onAdClosed"];
    self.splashWindow.hidden = YES;
}

#pragma mark - Ad Lifecycle Events

/// Called when an impression is recorded for an ad. Only called for Google ads and is not supported
/// for mediated ads.
- (void)nativeAdDidRecordImpression:(nonnull GADNativeAd *)nativeAd {
    [self callbackHandler:@"onAdShow"];
}

/// Called when a click is recorded for an ad. Only called for Google ads and is not supported for
/// mediated ads.
- (void)nativeAdDidRecordClick:(nonnull GADNativeAd *)nativeAd {
    [self callbackHandler:@"onAdClicked"];
}

#pragma mark - Click-Time Lifecycle Notifications

/// Called before presenting the user a full screen view in response to an ad action. Use this
/// opportunity to stop animations, time sensitive interactions, etc.
///
/// Normally the user looks at the ad, dismisses it, and control returns to your application with
/// the nativeAdDidDismissScreen: message. However, if the user hits the Home button or clicks on an
/// App Store link, your application will be backgrounded. The next method called will be the
/// applicationWillResignActive: of your UIApplicationDelegate object.
- (void)nativeAdWillPresentScreen:(nonnull GADNativeAd *)nativeAd {
    
}

/// Called before dismissing a full screen view.
- (void)nativeAdWillDismissScreen:(nonnull GADNativeAd *)nativeAd {
    
}

/// Called after dismissing a full screen view. Use this opportunity to restart anything you may
/// have stopped as part of nativeAdWillPresentScreen:.
- (void)nativeAdDidDismissScreen:(nonnull GADNativeAd *)nativeAd {
    
}

#pragma mark - Mute This Ad

/// Used for Mute This Ad feature. Called after the native ad is muted. Only called for Google ads
/// and is not supported for mediated ads.
- (void)nativeAdIsMuted:(nonnull GADNativeAd *)nativeAd {
    
}

@end
