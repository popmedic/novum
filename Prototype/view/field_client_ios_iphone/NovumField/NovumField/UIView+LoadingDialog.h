//
//  UIView+LoadingDialog.h
//  NovumField
//
//  Created by Kevin Scardina on 4/21/14.
//  Copyright (c) 2014 com.novumconcepts.novumField_ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LoadingDialog)
-(void)showLoading;
-(void)showLoading:(NSString*)title;
-(void)hideLoading;
@end
