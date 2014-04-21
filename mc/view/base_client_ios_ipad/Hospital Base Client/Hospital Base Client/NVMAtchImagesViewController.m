//
//  NVMAtchImagesViewController.m
//  Hospital Base Client
//
//  Created by Kevin Scardina on 3/16/14.
//  Copyright (c) 2014 com.kevinscardina.novum. All rights reserved.
//

#import "NVMAtchImagesViewController.h"
#import "NVMAtchImagesViewCell.h"
#import "NVMImageZoomViewController.h"
#import "NVMBaseUsers.h"

@interface NVMAtchImagesViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@end

@implementation NVMAtchImagesViewController

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
    // Do any additional setup after loading the view.
    self.atchImages = @[];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section{
    return [self.atchImages count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NVMAtchImagesViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"idNVMAtchImagesViewCell" forIndexPath:indexPath];
    NVMBaseUsers* bu = [[NVMBaseUsers alloc] init];
    NSURL* url = [bu getAtchFileURL:[[self.atchImages objectAtIndex:indexPath.row] valueForKey:@"id"] Thumb:NO];
    //[cell asyncLoadImageViewWithUrl:url];
    NSData* imgData = [NSData dataWithContentsOfURL:url];
    UIImage* img = [UIImage imageWithData:imgData];
    [cell.imageView setImage:img];
    
    return cell;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Field Reports", @"Field Reports");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Prepare for Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NVMAtchImagesViewCell *cell = (NVMAtchImagesViewCell *)sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];

    NVMImageZoomViewController *imageDetailViewController = (NVMImageZoomViewController *)segue.destinationViewController;
    
    NVMBaseUsers* bu = [[NVMBaseUsers alloc] init];
    NSURL* url = [bu getAtchFileURL:[[self.atchImages objectAtIndex:indexPath.row] valueForKey:@"id"] Thumb:NO];
    //[cell asyncLoadImageViewWithUrl:url];
    NSData* imgData = [NSData dataWithContentsOfURL:url];
    UIImage* img = [UIImage imageWithData:imgData];
    
    imageDetailViewController.image = img;
}
@end
