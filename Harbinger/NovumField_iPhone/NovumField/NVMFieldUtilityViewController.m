//
//  NVMFieldUtilityViewController.m
//  NovumField
//
//  Created by Kevin Scardina on 4/19/14.
//  Copyright (c) 2014 com.novumconcepts.novumField_ios. All rights reserved.
//

#import "NVMFieldUtilityViewController.h"
#import "NVMFieldHomeViewController.h"
#import "NVMFieldUser.h"
#import "NVMConstants.h"
#import "UIView+LoadingDialog.h"

#define PICTURES_PADDING 8.0f
#define PICTURE_TAG_OFFSET 621
#define PICKER_COMPONENT_COMPLAINT 0
#define PICKER_COMPONENT_AGE 1
#define PICKER_COMPONENT_GENDER 2
#define PICKER_COMPONENT_DESTINATION 3

#define ALERTVIEW_MESSAGE_SENT 1
#define ALERTVIEW_DELETE_PICTURE 2

@interface NVMFieldUtilityViewController ()

@end

@implementation NVMFieldUtilityViewController
{
    NSArray* destinations;
    NSArray* complaints;
    NSArray* ages;
    NSArray* genders;
    NSMutableArray* pictures;
    BOOL sendMessageSuccess;
    NSInteger deleteIdx;
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
                   @"Cardiac",
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

- (IBAction)sendButtonClicked:(id)sender
{
    NSInteger toIdx = [self.pickerView selectedRowInComponent:PICKER_COMPONENT_DESTINATION];
    NSDictionary* toDic = destinations[toIdx];
    NSString* toId = toDic[@"id"];
    
    NSMutableDictionary* msgDic = [NSMutableDictionary dictionary];
    NSInteger selected = [self.pickerView selectedRowInComponent:PICKER_COMPONENT_GENDER];
    msgDic[@"gender"] = genders[selected];
    selected = [self.pickerView selectedRowInComponent:PICKER_COMPONENT_AGE];
    msgDic[@"age"] = ages[selected];
    selected = [self.pickerView selectedRowInComponent:PICKER_COMPONENT_COMPLAINT];
    msgDic[@"complaint"] = complaints[selected];
    
    NVMFieldUser* fieldUser = [[NVMFieldUser alloc] init];
    NSError *error;
    NSDictionary* vars = [fieldUser createVarsTo:toId Message:msgDic Error:&error];
    NSURLRequest* urlRequest = [fieldUser sendMessage:vars Attachments:pictures Error:&error];
    
    [self.view showLoading:@"Sending..."];
    
    NSOperationQueue* operationQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:operationQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [self sendMessageHandleResponse:response Data:data Error:error];
     }];
}

-(void) sendMessageHandleResponse:(NSURLResponse*)response Data:(NSData*)data Error:(NSError*)error
{
    [self.view hideLoading];
    sendMessageSuccess = NO;
    
    NSString* msg = kNVMSendMessageSuccess;
    
    if ([data length] == 0 && error == nil)
    {
        NSLog(@"%@", kNVMSendMessageErrorNoReplay);
        msg = kNVMSendMessageErrorNoReplay;
    }
    else if (error != nil && error.code == NSURLErrorTimedOut)
    {
        NSLog(@"%@", kNVMSendMessageErrorTimeOut);
        msg = kNVMSendMessageErrorTimeOut;
    }
    else if (error != nil)
    {
        NSLog(kNVMSendMessageErrorFormat, error.description);
        msg = [NSString stringWithFormat:kNVMSendMessageErrorFormat, error.description];
    }
    else
    {
        sendMessageSuccess = YES;
    }
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Novum Field"
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
    alertView.tag = ALERTVIEW_MESSAGE_SENT;
    [alertView show];
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
        imageView.tag = i+PICTURE_TAG_OFFSET;
        imageView.image = smallImage;
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
        [longPressGestureRecognizer addTarget:self action:@selector(pictureLongPressed:)];
        [imageView addGestureRecognizer:longPressGestureRecognizer];
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
    if(component == PICKER_COMPONENT_COMPLAINT)
    {
        return complaints.count;
    }
    else if(component == PICKER_COMPONENT_AGE)
    {
        return ages.count;
    }
    else if(component == PICKER_COMPONENT_GENDER)
    {
        return genders.count;
    }
    else if(component == PICKER_COMPONENT_DESTINATION)
    {
        return destinations.count;
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == PICKER_COMPONENT_COMPLAINT)
    {
        return [complaints objectAtIndex:row];
    }
    else if(component == PICKER_COMPONENT_AGE)
    {
        return [ages objectAtIndex:row];
    }
    else if(component == PICKER_COMPONENT_GENDER)
    {
        return [genders objectAtIndex:row];
    }
    else if(component == PICKER_COMPONENT_DESTINATION)
    {
        NSDictionary* destination = [destinations objectAtIndex:row];
        return destination [@"name"];
    }
    return @"WhAt?";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

#pragma mark - AlertView delegates

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case ALERTVIEW_MESSAGE_SENT:
            if(sendMessageSuccess)
            {
                [self dismissViewControllerAnimated:NO completion:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            break;
        case ALERTVIEW_DELETE_PICTURE:
            if(buttonIndex == 0)
            {
                
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - GestureRecognizers callbacks

-(void) pictureLongPressed:(UIGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        UIImageView *imageView = (UIImageView*)sender.view;
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Novum Field"
                                                            message:@"Delete picture?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Delete"
                                                  otherButtonTitles:@"Cancel", nil];
        alertView.tag = ALERTVIEW_DELETE_PICTURE;
        
        [alertView show];
    }
}

@end
