# ⚡️ react-native-launchscreen

A React Native launch screen based on react-native-splash-screen and react-native-bootsplash, compatible with both iOS and Android platforms.

## Installation

```bash
npm install @lvothnrv/react-native-launchscreen
# --- or ---
yarn add @lvothnrv/react-native-launchscreen
```

### iOS

#### react-native 0.77+

Edit your `ios/YourApp/AppDelegate.swift` file:

```swift
import ReactAppDependencyProvider
import LaunchScreen // ⬅️ add this import

// …

@main
class AppDelegate: RCTAppDelegate {
  // …

  // ⬇️ override this method
  override func customize(_ rootView: RCTRootView!) {
    super.customize(rootView)
    LaunchScreen.initWithStoryboard("LaunchScreen", rootView: rootView) // ⬅️ initialize the splash screen
  }
}
```

#### react-native < 0.77

Edit your `ios/YourApp/AppDelegate.mm` file:

```obj-c
#import "AppDelegate.h"
#import "LaunchScreen.h" // ⬅️ add this import

// …

@implementation AppDelegate

// …

// ⬇️ Add this method before file @end (for react-native 0.74+)
- (void)customizeRootView:(RCTRootView *)rootView {
  [super customizeRootView:rootView];
  [LaunchScreen initWithStoryboard:@"LaunchScreen" rootView:rootView]; // ⬅️ initialize the splash screen
}

// OR

// ⬇️ Add this method before file @end (for react-native < 0.74)
- (UIView *)createRootViewWithBridge:(RCTBridge *)bridge
                          moduleName:(NSString *)moduleName
                           initProps:(NSDictionary *)initProps {
  UIView *rootView = [super createRootViewWithBridge:bridge moduleName:moduleName initProps:initProps];
  [LaunchScreen initWithStoryboard:@"LaunchScreen" rootView:rootView]; // ⬅️ initialize the splash screen
  return rootView;
}

@end
```

2. Create a `LaunchScreen.storyboard` (which is typically already created) and modify it as desired.

#### Android

Edit your `android/app/src/main/java/com/yourapp/MainActivity.{java,kt}` file:

#### Java (react-native < 0.73)

```java
// add these required imports:
import android.os.Bundle;
import com.lvothnrv.launchscreen.LaunchScreen;

public class MainActivity extends ReactActivity {

  // …

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    LaunchScreen.init(this, R.style.BootTheme); // ⬅️ initialize the splash screen
    super.onCreate(savedInstanceState); // super.onCreate(null) with react-native-screens
  }
}
```

#### Kotlin (react-native >= 0.73)
```kotlin
// add these required imports:
import android.os.Bundle
import com.lvothnrv.launchscreen.LaunchScreen

class MainActivity : ReactActivity() {

  // …

  override fun onCreate(savedInstanceState: Bundle?) {
    LaunchScreen.init(this, R.style.BootTheme) // ⬅️ initialize the splash screen
    super.onCreate(savedInstanceState) // super.onCreate(null) with react-native-screens
  }
}
```

2. Create a file called `launch_screen.xml` in `app/src/main/res/layout` (create the `layout`-folder if it doesn't exist). The contents of the file should be the following:

```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical" android:layout_width="match_parent"
    android:layout_height="match_parent">
    <ImageView android:layout_width="match_parent" android:layout_height="match_parent" android:src="@drawable/launch_screen" android:scaleType="centerCrop" />
</RelativeLayout>
```

Customize your launch screen by creating a `launch_screen.png`-file and placing it in an appropriate `drawable`-folder. Android automatically scales drawable, so you do not necessarily need to provide images for all phone densities.
You can create splash screens in the following folders:

- `drawable-ldpi`
- `drawable-mdpi`
- `drawable-hdpi`
- `drawable-xhdpi`
- `drawable-xxhdpi`
- `drawable-xxxhdpi`

## API

### hide()

Hide the splash screen with a fade out.

#### Method type

```ts
type hide = () => Promise<void>;
```

#### Usage

```tsx
import { useEffect } from "react";
import { Text } from "react-native";
import LaunchScreen from "react-native-launchscreen";

const App = () => {
  useEffect(() => {
    const init = async () => {
      // …do multiple sync or async tasks
    };

    init().finally(async () => {
      await LaunchScreen.hide();
      console.log("LaunchScreen has been hidden successfully");
    });
  }, []);

  return <Text>My awesome app</Text>;
};
```

## Why

This module is a combination of two existing modules: react-native-splash-screen and react-native-bootsplash. I developed this module by leveraging these two for two main reasons:

Firstly, on iOS, react-native-splash-screen didn't work properly with Firebase. Therefore, I chose to base my module on react-native-bootsplash, as it was compatible with Firebase.

Secondly, on Android, react-native-bootsplash doesn't simply allow displaying an image like react-native-splash-screen does. Since this functionality is important to me, I opted for react-native-splash-screen in this aspect.
