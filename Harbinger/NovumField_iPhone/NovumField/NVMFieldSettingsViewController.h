//
//  NVMFieldSettingsViewController.h
//  NovumField
//
//  Created by Kevin Scardina on 4/19/14.
//  Copyright (c) 2014 com.novumconcepts.novumField_ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NVMFieldSettingsViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *agencyTextField;
@property (strong, nonatomic) IBOutlet UITextField *unitTextField;

- (IBAction)applyButtonClicked:(id)sender;

@end
