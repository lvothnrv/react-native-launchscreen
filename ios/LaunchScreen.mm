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
#else
  #import <React/RCTRootView.h>
#endif

static NSMutableArray<RCTPromiseResolveBlock> *_resolveQueue = [[NSMutableArray alloc] init];
static UIView *_loadingView = nil;
static UIView *_rootView = nil;
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

      return [LaunchScreen clearResolveQueue];
    }];
  });
}

+ (void)initWithStoryboard:(NSString * _Nonnull)storyboardName
                  rootView:(UIView * _Nullable)rootView {
  if (RCTRunningInAppExtension()) {
    return;
  }

  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^(void) {
    [NSTimer scheduledTimerWithTimeInterval:0.35
                                    repeats:NO
                                      block:^(NSTimer * _Nonnull timer) {
      // wait for native iOS launch screen to fade out
      _nativeHidden = true;

      // hide has been called before native launch screen fade out
      if ([_resolveQueue count] > 0) {
        [self hideAndClearPromiseQueue];
      }
    }];

#ifdef RCT_NEW_ARCH_ENABLED
    if (rootView != nil && [rootView isKindOfClass:[RCTSurfaceHostingProxyRootView class]]) {
      _rootView = [(RCTSurfaceHostingProxyRootView *)rootView view];
#else
    if (rootView != nil && [rootView isKindOfClass:[RCTRootView class]]) {
      _rootView = (RCTRootView *)rootView;
#endif
      UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];

      _loadingView = [[storyboard instantiateInitialViewController] view];
      _loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      _loadingView.frame = _rootView.bounds;
      _loadingView.center = (CGPoint){CGRectGetMidX(_rootView.bounds), CGRectGetMidY(_rootView.bounds)};
      _loadingView.hidden = NO;

      [_rootView addSubview:_loadingView];

      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(onJavaScriptDidLoad)
                                                   name:RCTJavaScriptDidLoadNotification
                                                 object:nil];

      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(onJavaScriptDidFailToLoad)
                                                   name:RCTJavaScriptDidFailToLoadNotification
                                                 object:nil];
    }
  });
}

+ (void)onJavaScriptDidLoad {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)onJavaScriptDidFailToLoad {
  [self hideAndClearPromiseQueue];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSDictionary *)constantsToExport {
  return @{
    @"logoSizeRatio": @(1),
    @"navigationBarHeight": @(0),
    @"statusBarHeight": @(0)
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
  - (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeLaunchScreenSpecJSI>(params);
  }

  -(facebook::react::ModuleConstants<JS::NativeLaunchScreen::Constants::Builder>)getConstants {
    return [self constantsToExport];
  }

  - (void)hide:(RCTPromiseResolveBlock)resolve
        reject:(RCTPromiseRejectBlock)reject {
    [self hideImpl:resolve];    
  }
#else
  RCT_EXPORT_METHOD(hide:(RCTPromiseResolveBlock)resolve
                    reject:(RCTPromiseRejectBlock)reject) {
    [self hideImpl:resolve];    
  }
#endif

@end
