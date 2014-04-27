//
//  NVMAtchImagesViewCell.m
//  Hospital Base Client
//
//  Created by Kevin Scardina on 3/16/14.
//  Copyright (c) 2014 com.kevinscardina.novum. All rights reserved.
//

#import "NVMAtchImagesViewCell.h"
#import "UIImage+fixOrientation.h"

@implementation NVMAtchImagesViewCell
@synthesize imageView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) asyncLoadImageViewWithUrl:(NSURL*)url{
    [self.imageView setImage:NULL];
    UIActivityIndicatorView* aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    aiv.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    aiv.center = self.center;
    [self addSubview:aiv];
    [self bringSubviewToFront:aiv];
    [aiv startAnimating];
    dispatch_queue_t callerQueue = dispatch_get_current_queue();
    dispatch_queue_t downloadQueue = dispatch_queue_create("com.novumconcepts.fieldClient.downloadImageQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(downloadQueue, ^{
        NSData * imageData = [NSData dataWithContentsOfURL:url];
        dispatch_async(callerQueue, ^{
            [aiv stopAnimating];
            [aiv removeFromSuperview];
            UIImage* image = [UIImage imageWithData:imageData];
            [image fixOrientation];
            [self.imageView setImage:image];
        });
    });
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
