//
//  LaunchScreen.h
//  LaunchScreen
//
//  Created by LvothNrv on 06/02/2024.
//

#ifdef RCT_NEW_ARCH_ENABLED
    #import <LaunchScreenSpec/LaunchScreenSpec.h>
    @interface LaunchScreen : NSObject <NativeLaunchScreenSpec>
#else
    #import <React/RCTBridgeModule.h>
    @interface LaunchScreen : NSObject <RCTBridgeModule>
#endif

+ (void)initWithStoryboard:(NSString * _Nonnull)storyboardName
                  rootView:(UIView * _Nullable)rootView;

@end
