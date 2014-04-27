//
//  NVMFieldHomeViewController.m
//  NovumField
//
//  Created by Kevin Scardina on 4/19/14.
//  Copyright (c) 2014 com.novumconcepts.novumField_ios. All rights reserved.
//

#import "NVMFieldHomeViewController.h"
#import "NVMFieldSettingsViewController.h"
#import "NVMFieldUtilityViewController.h"

@interface NVMFieldHomeViewController ()

@end

@implementation NVMFieldHomeViewController

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
    NSString* title = NSLocalizedStringFromTable(@"Home Title", @"Localizable", @"Home");
    [self.homeNavigationItem setTitle:title];
    NSString* back = NSLocalizedStringFromTable(@"Back", @"Localizable", @"Back");
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithTitle:back
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:nil
                                                                     action:nil];
    [[self navigationItem] setBackBarButtonItem:barButtonItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePictureButtonClicked:(id)sender
{
    [self performSegueWithIdentifier:@"PushFieldUtilityViewController" sender: sender];
}

- (IBAction)settingsButtonClicked:(id)sender
{
    [self performSegueWithIdentifier:@"PushFieldSettingsViewController" sender: sender];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue destinationViewController] isKindOfClass:[NVMFieldSettingsViewController class]])
    {
        NSLog(@"Segue to settings");
    }
    else if([[segue destinationViewController] isKindOfClass:[NVMFieldUtilityViewController class]])
    {
        NSLog(@"Segue to utility");
    }
}


@end
