package com.cisco.cmx.network;

import com.cisco.cmx.model.CMXClientLocation;

public class CMXClientLocationResponseHandler {

    /**
     * Fired when a request returns successfully, override to handle in your own
     * code
     * 
     * @param clientLocation
     *            the result
     */
    public void onUpdate(CMXClientLocation clientLocation) {
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
