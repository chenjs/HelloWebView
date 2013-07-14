//
//  JQueryViewController.m
//  HelloWebView
//
//  Created by chenjs on 13-6-29.
//  Copyright (c) 2013年 chenjs. All rights reserved.
//

#import "JQueryViewController.h"

@interface JQueryViewController ()

@end

@implementation JQueryViewController
@synthesize webview = _webview;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSURL *requestURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"jQueryTest/pull-quote" ofType:@"html"]];
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
