//
//  UIView+LoadingDialog.m
//  NovumField
//
//  Created by Kevin Scardina on 4/21/14.
//  Copyright (c) 2014 com.novumconcepts.novumField_ios. All rights reserved.
//

#import "UIView+LoadingDialog.h"

@implementation UIView (LoadingDialog)
-(void)showLoading
{
    [self showLoading:@"Loading..."];
}
-(void)showLoading:(NSString*)title
{
    UIView* _hudView = [[UIView alloc] initWithFrame:CGRectMake(75, 155, 170, 170)];
    _hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _hudView.clipsToBounds = YES;
    _hudView.layer.cornerRadius = 10.0;
    _hudView.tag = 313370621;
    
    UIActivityIndicatorView* _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicatorView.frame = CGRectMake(65, 40, _activityIndicatorView.bounds.size.width, _activityIndicatorView.bounds.size.height);
    [_hudView addSubview:_activityIndicatorView];
    [_activityIndicatorView startAnimating];
    
    UILabel* _captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, 130, 22)];
    _captionLabel.backgroundColor = [UIColor clearColor];
    _captionLabel.textColor = [UIColor whiteColor];
    _captionLabel.adjustsFontSizeToFitWidth = YES;
    _captionLabel.textAlignment = NSTextAlignmentCenter;
    _captionLabel.text = title;
    [_hudView addSubview:_captionLabel];
    
    [self addSubview:_hudView];
}
-(void)hideLoading
{
    [[self viewWithTag:313370621] removeFromSuperview];
}
@end
