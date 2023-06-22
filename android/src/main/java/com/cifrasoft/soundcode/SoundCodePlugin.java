package com.cifrasoft.soundcode;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Handler;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;


import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.cifrasoft.services.SoundCode;
import com.cifrasoft.services.SoundCodeListener;
import com.cifrasoft.services.SoundCodeSettings;

import java.util.ArrayList;
import java.util.Arrays;

/**
 * SoundcodePlugin
 */
public class SoundCodePlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private static String TAG = SoundCodePlugin.class.getName();
    final int REQUEST_MICROPHONE = 1;
    private MethodChannel channel;

    Context context;
    Activity activity;
    Boolean initSuccess =false;
    Result requestPermissionsResult;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.cifrasoft.soundcode");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
        SoundCode.instance(context);
        Log.e(TAG, "onAttachedToEngine");
    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "start":
                Log.e(TAG, "start");
                if(initSuccess) {
                    SoundCode.instance().startSearch();
                }
                else {
                    SoundCode.instance(context);
                    SoundCodeSettings scs = new SoundCodeSettings();
                    scs.counterLength = 0;
                    initSuccess = true;
                    SoundCode.instance().prepare(scs, sclistener, true);
                }

                break;
            case "stop":
                Log.e(TAG, "stop");
                    SoundCode.instance().stopSearch();
                break;
            case "requestPermission":
                boolean granted = (ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED);
                if(granted) {
                    result.success(granted);
                }
                else{
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        requestPermissionsResult = result;
                        activity.requestPermissions(new String[]{Manifest.permission.RECORD_AUDIO,}, REQUEST_MICROPHONE);
                    }
                    else{
                        result.success(granted);
                    }
                }
                break;

            default:
                result.notImplemented();
        }

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.e(TAG, "onDetachedFromEngine");
        channel.setMethodCallHandler(null);
        SoundCode.release();
    }

    private final SoundCodeListener sclistener = new SoundCodeListener() {

        @Override
        public void onDetectedId(long[] result) {

            long ts = System.currentTimeMillis();

            String log = "CONTENT ID  " + "[" + Long.toString(result[1]) + "]" +
                    " COUNTER " + "[" + Long.toString(result[2]) + "]" +
                    " TIMESTAMP " + "[" + Float.toString((float) ((long) (result[3]) / 100) / 10) + "] sec.";

            Log.e(TAG, log);
            ArrayList<Long> args = new ArrayList<>();
            for (long r : result) {
                args.add(r);
            }
            channel.invokeMethod("onDetectedId", args);
        }

        @Override
        public void onAudioInitFailed() {
            Log.e("!!!", "AUDIO SEARCH\nSERVICE_UNAVAILABLE!");
            initSuccess = false;
            final ArrayList<Long> args = new ArrayList<>();
            SoundCodePlugin.this.activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    channel.invokeMethod("onAudioInitFailed", args);
                }
            });
        }
    };

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        Log.e(TAG, "onAttachedToActivity");
        activity = binding.getActivity();
        binding.addRequestPermissionsResultListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        Log.e(TAG, "onDetachedFromActivityForConfigChanges");
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        Log.e(TAG, "onReattachedToActivityForConfigChanges");
    }

    @Override
    public void onDetachedFromActivity() {
        Log.e(TAG, "onDetachedFromActivity");
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {

        Log.e(TAG, requestCode + " " + Arrays.toString(permissions) + " " + Arrays.toString(grantResults));
        switch (requestCode) {
            case REQUEST_MICROPHONE:
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    if(requestPermissionsResult !=null)
                        requestPermissionsResult.success(true);
                    return true;
                }
                if(requestPermissionsResult !=null)
                    requestPermissionsResult.success(false);
                break;
        }

        return false;
    }
}
