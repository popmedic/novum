//
//  NVMImageZoomViewController.h
//  Hospital Base Client
//
//  Created by Kevin Scardina on 3/16/14.
//  Copyright (c) 2014 com.kevinscardina.novum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NVMImageZoomViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage* image;
@end
