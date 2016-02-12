package com.cisco.cmx.network;

import java.lang.reflect.Method;
import android.content.Context;
import android.net.wifi.WifiManager;
import android.os.Handler;

public class CMXWifiScanner {

    private final Handler handler = new Handler();

    int interval;

    WifiManager mainWifi;

    Runnable wifiScanner;

    Method startScanActiveMethod;

    Context context;

    public CMXWifiScanner(Context mcontext) {
        context = mcontext;
        mainWifi = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
        try {
            startScanActiveMethod = WifiManager.class.getMethod("startScanActive");
        }
        catch (Exception ex) {

        }
        wifiScanner = new Runnable() {
            public void run() {
                try {
                    startScanActiveMethod.invoke(mainWifi);
                }
                catch (Exception ex) {
                }
                handler.postDelayed(wifiScanner, interval);
            }
        };
    }

    public void startScan(int minterval) {
        interval = minterval;
        wifiScanner.run();
    }

    public void stopScan() {
        handler.removeCallbacks(wifiScanner);
    }
}
