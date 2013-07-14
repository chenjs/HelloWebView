//
//  CheckInViewController.m
//  HelloWebView
//
//  Created by chenjs on 13-6-29.
//  Copyright (c) 2013年 chenjs. All rights reserved.
//

#import "CheckInViewController.h"
#import "WebViewJavascriptBridge.h"
#import "MyLocationManager.h"

@interface CheckInViewController ()

@end

@implementation CheckInViewController {
    WebViewJavascriptBridge *javascriptBridge;
    MyLocationManager *myLocationManager;
}
@synthesize webview = _webview;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        myLocationManager = [[MyLocationManager alloc] init];
        myLocationManager.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:self.webview handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
    }];
    
    [javascriptBridge registerHandler:@"getAddress" handler:^(id data, WVJBResponseCallback responseCallback) {
        //NSLog(@"getAddress() called: %@", data);
        responseCallback(@"OK");
        
        //[self performSelector:@selector(reportAddress) withObject:self afterDelay:1.0f];
        [self startGetLocation];
    }];
    

    NSURL *requestURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"CheckIn" ofType:@"html"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    [self.webview loadRequest:request];
    
    self.webview.scalesPageToFit = NO;
    self.webview.opaque = NO;
    self.webview.backgroundColor = [UIColor clearColor];
    
    for (int x = 0; x < 10; ++x)
    {
        [[[[[self.webview subviews] objectAtIndex:0] subviews] objectAtIndex:x] setHidden:YES];
    } //Removes the webView shadows.
}

- (void)startGetLocation
{
    [myLocationManager startGetLocation];
}

- (void)reportAddress:(NSString *)address error:(NSString *)errorMsg
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    if (address != nil) {
        [data setObject:address forKey:@"address"];
    }
    if (errorMsg != nil) {
        [data setObject:errorMsg forKey:@"error"];
    }
    
    [javascriptBridge callHandler:@"addressUpdated" data:data];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MyLocationManagerDelegate

- (void)onLocationUpdated:(NSString *)address coornidate:(CLLocationCoordinate2D)locationCoordinate error:(NSString *)errorMsg;
{
    if (address != nil) {
        [self reportAddress:address error:errorMsg];
    }
}



@end
