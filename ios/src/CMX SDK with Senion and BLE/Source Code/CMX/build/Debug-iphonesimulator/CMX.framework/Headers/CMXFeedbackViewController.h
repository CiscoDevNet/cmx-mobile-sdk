//
//  CMXFeedbackViewController.h
//  CMX
//
//  Created by abhisbha on 3/31/14.
//  Copyright (c) 2014 Cisco. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 * @header CMXFeedbackViewController
 * This View controller is meant for the feedback page which enables the user to send feedback to the cloud server
 * @copyright Cisco Systems
 */

/*!
 *  @class CMXFeedbackViewController
 *  @abstract View Controller that displays feedback options like comment and rating
 */
@interface CMXFeedbackViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>

@end
