package com.lvothnrv.launchscreen;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;

public class LaunchScreenModule extends ReactContextBaseJavaModule{
    public LaunchScreenModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "LaunchScreen";
    }

    @ReactMethod
    public void hide(Promise promise) {
        try {
            LaunchScreen.hide(getCurrentActivity());
            promise.resolve("Hidden splash screen");
        } catch(Exception e) {
            promise.reject("Something went wrong", e);
        }
    }
}