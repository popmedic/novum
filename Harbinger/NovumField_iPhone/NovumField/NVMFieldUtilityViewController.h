//
//  NVMFieldUtilityViewController.h
//  NovumField
//
//  Created by Kevin Scardina on 4/19/14.
//  Copyright (c) 2014 com.novumconcepts.novumField_ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface NVMFieldUtilityViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIScrollView *picturesScrollView;
- (IBAction)addPictureButtonClicked:(id)sender;
- (IBAction)sendButtonClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;

@end
