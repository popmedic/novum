//
//  NVMDetailViewController.m
//  Hospital Base Client
//
//  Created by Kevin Scardina on 3/10/14.
//  Copyright (c) 2014 com.kevinscardina.novum. All rights reserved.
//

#import "NVMDetailViewController.h"
#import "NVMAtchImagesViewCell.h"
#import "NVMBaseUsers.h"
#import "NVMImageZoomViewController.h"
#import "UIImage+fixOrientation.h"

@interface NVMDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation NVMDetailViewController

#pragma mark - Managing the detail item
/*
- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}
*/
- (void)configureView
{
    // Update the user interface for the detail item.
/*
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
*/
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    NSData* imgData = [NSData dataWithContentsOfURL:url];
    UIImage* img = [UIImage imageWithData:imgData];
    [img fixOrientation];
    
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
    //NSIndexPath *indexPath = [self.atchCollectionView indexPathForCell:cell];
    
    NVMImageZoomViewController *imageDetailViewController = (NVMImageZoomViewController *)segue.destinationViewController;
    
    /*NVMBaseUsers* bu = [[NVMBaseUsers alloc] init];
    NSURL* url = [bu getAtchFileURL:[[self.atchImages objectAtIndex:indexPath.row] valueForKey:@"id"] Thumb:NO];
    NSData* imgData = [NSData dataWithContentsOfURL:url];
    UIImage* img = [UIImage imageWithData:imgData];*/
    
    imageDetailViewController.image = cell.imageView.image;
}

@end
