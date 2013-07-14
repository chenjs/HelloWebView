//
//  CheckInViewController.h
//  HelloWebView
//
//  Created by chenjs on 13-6-29.
//  Copyright (c) 2013年 chenjs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyLocationManager.h"

@interface CheckInViewController : UIViewController <MyLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webview;

@end
