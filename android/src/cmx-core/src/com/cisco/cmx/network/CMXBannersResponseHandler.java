package com.cisco.cmx.network;

import java.util.List;

import com.cisco.cmx.model.CMXBanner;

public class CMXBannersResponseHandler {
    /**
     * Fired when the request is started, override to handle in your own code
     */
    public void onStart() {
        // Initiated the request
    }

    /**
     * Fired when a request returns successfully, override to handle in your own
     * code
     * 
     * @param banners
     *            list of banners
     */
    public void onSuccess(List<CMXBanner> banners) {
        // Successfully got a response
    }

    /**
     * Fired when a request fails to complete, override to handle in your own
     * code
     * 
     * @param error
     *            the underlying cause of the failure
     */
    public void onFailure(Throwable error) {
        // Response failed :(
    }

}
