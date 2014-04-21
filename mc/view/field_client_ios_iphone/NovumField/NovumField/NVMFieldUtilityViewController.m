//
//  NVMFieldUtilityViewController.m
//  NovumField
//
//  Created by Kevin Scardina on 4/19/14.
//  Copyright (c) 2014 com.novumconcepts.novumField_ios. All rights reserved.
//

#import "NVMFieldUtilityViewController.h"
#import "NVMFieldHomeViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

#define PICTURES_PADDING 8.0f

@interface NVMFieldUtilityViewController ()

@end

@implementation NVMFieldUtilityViewController
{
    NSArray* destinations;
    NSArray* complaints;
    NSArray* ages;
    NSArray* genders;
    NSMutableArray* pictures;
}

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
    destinations = @[
                     @{
                        @"name":@"Novum",
                        @"id":@"1"
                     },
                     @{
                        @"name":@"PSL",
                        @"id":@"2"
                     }
                   ];
    complaints = @[
                   @"Card",
                   @"Stroke",
                   @"Trauma",
                   @"Other"
                 ];
    ages = @[
             @"< 1yr",
             @"1 ->",
             @"6 ->",
             @"13 ->",
             @"20's",
             @"30's",
             @"40's",
             @"50's",
             @"60's",
             @"70's",
             @"80's",
             @"90's",
             @"100 ->"
            ];
    genders = @[@"Fem", @"Male"];
    pictures = [NSMutableArray array];
    
    [self takePicture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addPictureButtonClicked:(id)sender
{
    [self takePicture];
}

- (void)reloadPictures
{
    while ([self.picturesScrollView.subviews count] > 0)
    {
        [[self.picturesScrollView.subviews objectAtIndex:0] removeFromSuperview];
    }
    CGFloat x = 0.0;
    for(int i = 0; i < pictures.count; i++)
    {
        UIImage* image = pictures[i];
        CGFloat scale = 44.0/image.size.height;
        CGFloat smallImageHeight = image.size.height*scale;
        CGFloat smallImageWidth = image.size.width*scale;
        CGSize size = CGSizeMake(smallImageWidth, smallImageHeight);
        CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
        [image drawInRect:rect];
        UIImage* smallImage = UIGraphicsGetImageFromCurrentImageContext();
        CGRect frameRect = CGRectMake(x, 0.0, size.width, size.height);
        x += size.width + PICTURES_PADDING;
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:frameRect];
        imageView.image = smallImage;
        [self.picturesScrollView addSubview:imageView];
    }
    CGSize contentSize = CGSizeMake(x, 44.0);
    [self.picturesScrollView setContentSize:contentSize];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    //NSString* title = NSLocalizedStringFromTable(@"Home Title", @"Localizable", @"Home");
    //NVMFieldHomeViewController* homeViewController = (NVMFieldHomeViewController*)self.parentViewController;
    //[homeViewController.homeNavigationItem setTitle:title];
}

#pragma mark - Pictures

-(void)takePicture
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = (id)self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = NO;
        picker.mediaTypes = @[(NSString*)kUTTypeImage];
        [self.navigationController presentViewController:picker animated:YES completion:nil];
    }
    
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if([mediaType isEqualToString:(NSString*)kUTTypeImage])
    {
        UIImage* image = info[UIImagePickerControllerOriginalImage];
        [pictures addObject:image];
        
        [self reloadPictures];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 4;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    if(component == 0){
        return complaints.count;
    }
    else if(component == 1){
        return ages.count;
    }
    else if(component == 2){
        return genders.count;
    }
    else if(component == 3){
        return destinations.count;
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    if(component == 0){
        return [complaints objectAtIndex:row];
    }
    else if(component == 1){
        return [ages objectAtIndex:row];
    }
    else if(component == 2){
        return [genders objectAtIndex:row];
    }
    else if(component == 3){
        NSDictionary* destination = [destinations objectAtIndex:row];
        return destination [@"name"];
    }
    return @"WhAt?";
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{
    
}
@end
