//
//  MainViewController.m
//  HelloWebView
//
//  Created by chenjs on 13-7-1.
//  Copyright (c) 2013年 chenjs. All rights reserved.
//

#import "MainViewController.h"
#import "WebViewController.h"
#import "ZipArchive.h"

@interface MainViewController ()

- (IBAction)btnCopyTapped:(id)sender;
- (IBAction)btnDeleteTapped:(id)sender;

@end

@implementation MainViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        WebViewController *testVC = [[WebViewController alloc] init];
        //testVC.pageURL = @"page_a";   // a.html
        testVC.pageURL = @"page_a_new.html";
        
        [self.navigationController pushViewController:testVC animated:YES];
    }
}

#pragma mark - IBAction

- (IBAction)btnCopyTapped:(id)sender
{
    NSString *documentsDir = [self documentsDirectory];
    [self fileCopy:[[NSBundle mainBundle] pathForResource:@"jquery-1.7.2.min" ofType:@"js"]
                                                   toPath: [documentsDir stringByAppendingPathComponent:@"jquery-1.7.2.min.js"]];
    [self fileCopy:[[NSBundle mainBundle] pathForResource:@"NoClickDelay" ofType:@"js"]
                                                   toPath: [documentsDir stringByAppendingPathComponent:@"NoClickDelay.js"]];
    [self fileCopy:[[NSBundle mainBundle] pathForResource:@"page_a" ofType:@"html"]
            toPath: [documentsDir stringByAppendingPathComponent:@"page_a_new.html"]];
    [self fileCopy:[[NSBundle mainBundle] pathForResource:@"page_b" ofType:@"html"]
            toPath: [documentsDir stringByAppendingPathComponent:@"page_b.html"]];
    [self fileCopy:[[NSBundle mainBundle] pathForResource:@"page_c" ofType:@"html"]
                                                   toPath: [documentsDir stringByAppendingPathComponent:@"page_c.html"]];
    [self fileCopy:[[NSBundle mainBundle] pathForResource:@"bookshelf" ofType:@"png"]
            toPath: [documentsDir stringByAppendingPathComponent:@"bookshelf.png"]];
}

- (IBAction)btnDeleteTapped:(id)sender
{
    [self testUnzipFiles];
    
    NSString *documentsDir = [self documentsDirectory];
    
    [self fileDelete:[documentsDir stringByAppendingPathComponent:@"jquery-1.7.2.min.js"]];
    [self fileDelete:[documentsDir stringByAppendingPathComponent:@"NoClickDelay.js"]];
    [self fileDelete:[documentsDir stringByAppendingPathComponent:@"page_a_new.html"]];
    [self fileDelete:[documentsDir stringByAppendingPathComponent:@"page_b.html"]];
    [self fileDelete:[documentsDir stringByAppendingPathComponent:@"page_c.html"]];
    [self fileDelete:[documentsDir stringByAppendingPathComponent:@"bookshelf.png"]];
}

- (BOOL)fileCopy:(NSString *)srcPath toPath:(NSString *)dstPath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:dstPath]) {
        NSError *error;
        if (![fm removeItemAtPath:dstPath error:&error]) {
            NSLog(@"removeItemAtPath: %@ error: %@", dstPath, error);
            return FALSE;
        }
    }
    
    NSError *error;
    if (![fm copyItemAtPath:srcPath toPath:dstPath error:&error]) {
        NSLog(@"copyItem: %@ to %@ error: %@", srcPath, dstPath, error);
        return FALSE;
    }
    
    [self testZipFiles];

    return TRUE;
}

- (BOOL)fileDelete:(NSString *)filePath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
        NSError *error;
        if (![fm removeItemAtPath:filePath error:&error]) {
            NSLog(@"removeItemAtPath: %@ error: %@", filePath, error);
            return FALSE;
        }
    }
    
    return TRUE;
}


- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return documentsDir;
}

- (NSString *)dataStorePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"DataStore.sqlite"];
}


- (void)testZipFiles
{
    ZipArchive* zip = [[ZipArchive alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentpath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString* l_zipfile = [documentpath stringByAppendingString:@"/test.zip"] ;
    [self fileDelete:l_zipfile];
    
    NSString* html1 = [documentpath stringByAppendingString:@"/page_a_new.html"] ;
    NSString* html2 = [documentpath stringByAppendingString:@"/page_b.html"] ;
    NSString* html3 = [documentpath stringByAppendingString:@"/page_c.html"] ;

    
    BOOL ret = [zip CreateZipFile2:l_zipfile];
    ret = [zip addFileToZip:html1 newname:@"page_a_new.html"];
    ret = [zip addFileToZip:html2 newname:@"page_b.html"];
    ret = [zip addFileToZip:html3 newname:@"page_c.html"];
    if( ![zip CloseZipFile2] )
    {
        l_zipfile = @"";
    }
    zip = nil;
}

- (void)testUnzipFiles
{
    ZipArchive* zip = [[ZipArchive alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentpath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSString* l_zipfile = [documentpath stringByAppendingString:@"/test.zip"] ;
    NSString* unzipto = [documentpath stringByAppendingString:@"/test"] ;
    if( [zip UnzipOpenFile:l_zipfile] )
    {
        BOOL ret = [zip UnzipFileTo:unzipto overWrite:YES];
        if( NO==ret )
        {
        }
        [zip UnzipCloseFile];
    }
}


@end
