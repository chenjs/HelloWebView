//
//  WebViewController.m
//  HelloWebView
//
//  Created by chenjs on 13-7-1.
//  Copyright (c) 2013年 chenjs. All rights reserved.
//

#import "WebViewController.h"
#import "WebViewJavascriptBridge.h"


@interface WebViewController ()
@property (nonatomic, strong) UIWebView *webview;
@end

@implementation WebViewController {
    WebViewJavascriptBridge *javascriptBridge;
}
@synthesize webview = _webview;
@synthesize pageURL = _pageURL;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webview = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webview];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.pageURL;

    javascriptBridge = [WebViewJavascriptBridge bridgeForWebView:self.webview handler:^(id data, WVJBResponseCallback responseCallback) {
        //NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
    }];
    
    [self registerMethod_navigateTo];
    
    //NSString *pagePath = [[NSBundle mainBundle] pathForResource:self.pageURL ofType:@"html"];
    NSString *pagePath = [[self documentsDirectory] stringByAppendingPathComponent:self.pageURL];
    if (pagePath != nil) {
        NSURL *requestURL = [NSURL fileURLWithPath: pagePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
        [self.webview loadRequest:request];
    } else {
        NSLog(@"pathForResource: %@, return nil", [self.pageURL stringByAppendingString:@".html"]);
    }
    
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
    
    NSLog(@"WebViewController: %@, didReceiveMemoryWarning", self.pageURL);
    javascriptBridge = nil;
    self.webview = nil;
}

- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return documentsDir;
}

- (void)registerMethod_navigateTo
{
    [javascriptBridge registerHandler:@"navigateTo" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(@"OK");

        NSDictionary *params = (NSDictionary *)data;
        if (params[@"toURL"] != nil) {
            NSString *toURL = params[@"toURL"];
            
            NSLog(@"Begin navigate to: %@", toURL);
            
            WebViewController *nextVC = [[WebViewController alloc] init];
            nextVC.pageURL = toURL;
            [self.navigationController pushViewController:nextVC animated:YES];
        }
    }];
}

@end
