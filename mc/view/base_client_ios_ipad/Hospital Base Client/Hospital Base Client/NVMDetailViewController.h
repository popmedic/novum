//
//  NVMDetailViewController.h
//  Hospital Base Client
//
//  Created by Kevin Scardina on 3/10/14.
//  Copyright (c) 2014 com.kevinscardina.novum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NVMDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) IBOutlet UICollectionView *atchCollectionView;
@property (strong, nonatomic) NSArray* atchImages;
@property (strong, nonatomic) IBOutlet UILabel *complaintLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel1;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel2;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel3;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel4;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel5;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel6;

@end
