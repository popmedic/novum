//
//  NVMFieldSettingsViewController.m
//  NovumField
//
//  Created by Kevin Scardina on 4/19/14.
//  Copyright (c) 2014 com.novumconcepts.novumField_ios. All rights reserved.
//

#import "NVMFieldSettingsViewController.h"
#import "NVMFieldHomeViewController.h"
#import "NVMFieldUser.h"

@interface NVMFieldSettingsViewController ()
{
    NVMFieldUser* fieldUser;
}

@end

@implementation NVMFieldSettingsViewController

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
    // Do any additional setup after loadin the view.
    fieldUser = [[NVMFieldUser alloc] init];
    [self.nameTextField setText:fieldUser.name];
    [self.phoneTextField setText:fieldUser.phone];
    [self.agencyTextField setText:fieldUser.agency];
    [self.unitTextField setText:fieldUser.unit];
    [self.navigationItem setTitle:fieldUser.macAddress];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)applyButtonClicked:(id)sender
{
    [self setUserDefaultValues];
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)setUserDefaultValues
{
    [fieldUser setName:self.nameTextField.text];
    [fieldUser setPhone:self.phoneTextField.text];
    [fieldUser setAgency:self.agencyTextField.text];
    [fieldUser setUnit:self.unitTextField.text];
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
@end
