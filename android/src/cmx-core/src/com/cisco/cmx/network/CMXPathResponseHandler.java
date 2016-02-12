package com.cisco.cmx.network;

import com.cisco.cmx.model.CMXPath;

public class CMXPathResponseHandler {

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
     * @param path
     *            the result
     */
    public void onSuccess(CMXPath path) {
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
