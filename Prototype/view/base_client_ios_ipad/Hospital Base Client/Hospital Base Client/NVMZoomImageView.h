//
//  NVMZoomImageView.h
//  Hospital Base Client
//
//  Created by Kevin Scardina on 3/22/14.
//  Copyright (c) 2014 com.kevinscardina.novum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITouch (TouchSorting)

- (NSComparisonResult)compareAddress:(id)obj;

@end

@interface NVMZoomImageView : UIImageView
{
    CGAffineTransform originalTransform;
    NSMutableDictionary *touchBeginPoints;
    //CFMutableDictionaryRef touchBeginPoints;
}
//@property (retain) NSMutableDictionary* touchBeginPoints;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

- (CGAffineTransform)incrementalTransformWithTouches:(NSSet *)touches;
- (void)updateOriginalTransformForTouches:(NSSet *)touches;

- (void)cacheBeginPointForTouches:(NSSet *)touches;
- (void)removeTouchesFromCache:(NSSet *)touches;
@end
