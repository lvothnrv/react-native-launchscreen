package com.lvothnrv.launchscreen;

import android.app.Activity;
import android.app.Dialog;
import android.os.Build;
import android.view.WindowManager;

import java.lang.ref.WeakReference;

public class LaunchScreen {
    private static Dialog mLaunchDialog;
    private static WeakReference<Activity> mActivity;

    public static void show(final Activity activity, final int themeResId, final boolean fullScreen) {
        if (activity == null) return;
        mActivity = new WeakReference<Activity>(activity);
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (!activity.isFinishing()) {
                    mLaunchDialog = new Dialog(activity, themeResId);
                    mLaunchDialog.setContentView(R.layout.launch_screen);
                    mLaunchDialog.setCancelable(false);
                    if (fullScreen) {
                        setActivityAndroidP(mLaunchDialog);
                    }
                    if (!mLaunchDialog.isShowing()) {
                        mLaunchDialog.show();
                    }
                }
            }
        });
    }

    public static void show(final Activity activity, final boolean fullScreen) {
        int resourceId = fullScreen ? R.style.LaunchScreen_Fullscreen : R.style.LaunchScreen_LaunchTheme;

        show(activity, resourceId, fullScreen);
    }

    public static void show(final Activity activity) {
        show(activity, false);
    }

    public static void hide(Activity activity) {
        if (activity == null) {
            if (mActivity == null) {
                return;
            }
            activity = mActivity.get();
        }

        if (activity == null) return;

        final Activity _activity = activity;

        _activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (mLaunchDialog != null && mLaunchDialog.isShowing()) {
                    boolean isDestroyed = false;

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                        isDestroyed = _activity.isDestroyed();
                    }

                    if (!_activity.isFinishing() && !isDestroyed) {
                        mLaunchDialog.dismiss();
                    }
                    mLaunchDialog = null;
                }
            }
        });
    }

    private static void setActivityAndroidP(Dialog dialog) {
        if (Build.VERSION.SDK_INT >= 28) {
            if (dialog != null && dialog.getWindow() != null) {
                dialog.getWindow().addFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);
                WindowManager.LayoutParams lp = dialog.getWindow().getAttributes();
                lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
                dialog.getWindow().setAttributes(lp);
            }
        }
    }
}
