//
//  NVMMasterViewController.h
//  Hospital Base Client
//
//  Created by Kevin Scardina on 3/10/14.
//  Copyright (c) 2014 com.kevinscardina.novum. All rights reserved.
//

#import <UIKit/UIKit.h>


@class NVMAtchImagesViewController;
@class NVMBaseUsers;

@interface NVMMasterViewController : UITableViewController

@property (strong, nonatomic) NVMAtchImagesViewController *detailViewController;
@property (readonly) NVMBaseUsers *baseUsers;
@property (readonly) NSDate *lastChecked;

@end
