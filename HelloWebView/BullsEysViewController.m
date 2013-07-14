//
//  ViewController.m
//  HelloWebView
//
//  Created by chenjs on 13-6-27.
//  Copyright (c) 2013年 chenjs. All rights reserved.
//

#import "BullsEysViewController.h"

@interface BullsEysViewController ()

@end

@implementation BullsEysViewController
@synthesize webview = _webview;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSURL *requestURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"BullsEye" ofType:@"html"]];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
