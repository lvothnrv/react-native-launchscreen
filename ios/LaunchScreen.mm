//
//  LaunchScreen.mm
//  LaunchScreen
//
//  Created by LvothNrv on 06/02/2024.
//

#import "LaunchScreen.h"
#import <React/RCTUtils.h>

#if RCT_NEW_ARCH_ENABLED
#import <React/RCTSurfaceHostingProxyRootView.h>
#import <React/RCTSurfaceHostingView.h>
static RCTSurfaceHostingProxyRootView *_rootView = nil;
#else
#import <React/RCTRootView.h>
static UIView *_rootView = nil;
#endif

static UIView *_loadingView = nil;
static NSMutableArray<RCTPromiseResolveBlock> *_resolveQueue = [[NSMutableArray alloc] init];
static bool _nativeHidden = false;

@implementation LaunchScreen

RCT_EXPORT_MODULE();

+ (BOOL)requiresMainQueueSetup {
  return NO;
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

+ (bool)isLoadingViewVisible {
  return _loadingView != nil && ![_loadingView isHidden];
}

+ (void)clearResolveQueue {
  while ([_resolveQueue count] > 0) {
    RCTPromiseResolveBlock resolve = [_resolveQueue objectAtIndex:0];
    [_resolveQueue removeObjectAtIndex:0];
    resolve(@(true));
  }
}

+ (void)hideAndClearPromiseQueue {
  if (![self isLoadingViewVisible]) {
    return [LaunchScreen clearResolveQueue];
  }

  dispatch_async(dispatch_get_main_queue(), ^{
    [UIView transitionWithView:_rootView
                      duration:0.250
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
      _loadingView.hidden = YES;
    }
                    completion:^(__unused BOOL finished) {
      [_loadingView removeFromSuperview];
      _loadingView = nil;
      [LaunchScreen clearResolveQueue];
    }];
  });
}

+ (void)initWithStoryboard:(NSString * _Nonnull)storyboardName
                  rootView:(UIView * _Nullable)rootView {
  if (RCTRunningInAppExtension()) {
    return;
  }

  [NSTimer scheduledTimerWithTimeInterval:0.35
                                  repeats:NO
                                    block:^(NSTimer * _Nonnull timer) {
    // Attendre la fin de l'animation du launch screen natif
    _nativeHidden = true;

    if ([_resolveQueue count] > 0) {
      [self hideAndClearPromiseQueue];
    }
  }];

  if (rootView != nil) {
#ifdef RCT_NEW_ARCH_ENABLED
    _rootView = (RCTSurfaceHostingProxyRootView *)rootView;
#else
    _rootView = (RCTRootView *)rootView;
#endif

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];

    _loadingView = [[storyboard instantiateInitialViewController] view];
    _loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _loadingView.frame = _rootView.bounds;
    _loadingView.center = (CGPoint){CGRectGetMidX(_rootView.bounds), CGRectGetMidY(_rootView.bounds)};
    _loadingView.hidden = NO;

#if RCT_NEW_ARCH_ENABLED
    [_rootView disableActivityIndicatorAutoHide:YES];
    [_rootView setLoadingView:_loadingView];
#else
    [_rootView addSubview:_loadingView];
#endif

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onJavaScriptDidLoad)
                                                 name:RCTJavaScriptDidLoadNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onJavaScriptDidFailToLoad)
                                                 name:RCTJavaScriptDidFailToLoadNotification
                                               object:nil];
  }
}

+ (void)onJavaScriptDidLoad {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)onJavaScriptDidFailToLoad {
  [self hideAndClearPromiseQueue];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSDictionary *)constantsToExport {
  __block BOOL darkModeEnabled = NO;

  RCTUnsafeExecuteOnMainQueueSync(^{
    UIWindow *window = RCTKeyWindow();
    darkModeEnabled = window.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
  });

  return @{
    @"darkModeEnabled": @(darkModeEnabled)
  };
}

- (void)hideImpl:(RCTPromiseResolveBlock)resolve {
  if (RCTRunningInAppExtension()) {
    return resolve(@(true));
  }

  [_resolveQueue addObject:resolve];

  if (_nativeHidden) {
    return [LaunchScreen hideAndClearPromiseQueue];
  }
}

#ifdef RCT_NEW_ARCH_ENABLED
// Nouvelle architecture
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeLaunchScreenSpecJSI>(params);
}

- (void)hide:(RCTPromiseResolveBlock)resolve
      reject:(RCTPromiseRejectBlock)reject {
  [self hideImpl:resolve];
}
#else
// Ancienne architecture
RCT_EXPORT_METHOD(hide:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  [self hideImpl:resolve];
}
#endif

@end