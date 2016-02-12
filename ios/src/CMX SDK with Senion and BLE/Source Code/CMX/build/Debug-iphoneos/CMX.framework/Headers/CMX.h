//
//  CMX.h
//  CMX
//
//  Created by Kor  on 25/10/2013.
//  Copyright (c) 2013 Cisco. All rights reserved.
//

/*!
 * @header CMX
 * This includes all the CMX.framwork headers. Including this file in your project should 
 * suffice in importing all the CMX.framework headers.
 * @discussion This discussion includes brief introduction of :
 * 1. CMX Cloud Server Overview
 * 2. Power of the CMX SDK
 * 3. Brief Overview of the CMX SDK
 *
 *######################### CMX Cloud Server Overview ###################################
 *
 *The Cisco CMX Cloud server in conjunction with the Cisco Mobility Services Engine
 *provides mobile users the flexibility to easily obtain and embed indoor location
 *and location related services in their mobile applications. The Mobility Services 
 *or the MSE computes WiFi based indoor location using  the data obtained by the Cisco 
 *Controller managing a venue. The MSE then forwards this information to the Cloud 
 *Server via its Cloud Connector. The CMX SDK gets the information from the cloud server, 
 *processes it and provides access to it via its APIs to the mobile application.
 *So the flow of information is like :
 * 
 * AP <-> Controller -> Mobility Services Engine ->Cloud Server <-> CMX SDK -> Mobile App
 *
 *############################ Power of the SDK ##########################################
 *
 *The CMX SDK allows a mobile application to easily access the user's location on a floor, 
 *receive zone based push notifications, display points of interest, show routes to the
 *points of interest from the present location on the same floor, configure banners to show 
 *zone based advertisement, easily onboard the wifi of a venue,search for a point of interest on a floor.
 *
 *
 *############################ Brief Overview of the SDK architecture #####################
 *
 *The Application Delegate launches the Main View Controller which loads the Menu Views and the
 *content views. The content view is provided by the Launch View Controller which calls appropriate
 *methods to load data.
 *
 *Loading data is primarily accomplished by the CMXClient APIs. It manages the network connection, registration 
 *loading data including venues, floors, poi, banners , client location. The information for each of these 
 *features (floors,venues,pois,banners) are maintained in appropriate class instances and served through their
 *individual view controller.
 *
 *For a mobile application aiming to load data , it needs to reference the CMXClient APIs. It needs to get a 
 *push notification registration key, then get the venues from the cloud server , then register using the 
 *network information in the venues list and the push notification key. It will then be able to receive
 *client location.
 *From ios7 onwards, a device needs to be present at the venue and associated with an access point at the
 *venue in order to be registered successfully.
 * @copyright Cisco Systems
 */

#import "Model.h"
#import "Network.h"
#import "UI.h"
#import "Controller.h"
