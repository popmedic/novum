//
//  NVMFieldHomeViewController.h
//  NovumField
//
//  Created by Kevin Scardina on 4/19/14.
//  Copyright (c) 2014 com.novumconcepts.novumField_ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NVMFieldHomeViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *takePictureButton;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) IBOutlet UINavigationItem *homeNavigationItem;

- (IBAction)takePictureButtonClicked:(id)sender;
- (IBAction)settingsButtonClicked:(id)sender;

@end
