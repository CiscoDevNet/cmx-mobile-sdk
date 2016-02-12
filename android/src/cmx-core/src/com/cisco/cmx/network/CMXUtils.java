package com.cisco.cmx.network;

public class CMXUtils {
    
    public static boolean isEmulator() {
        if (android.os.Build.PRODUCT.startsWith("google_sdk")) {
            return true;
        }
        return false;
    }
}
