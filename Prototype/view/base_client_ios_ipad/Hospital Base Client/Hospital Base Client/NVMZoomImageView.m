//
//  NVMZoomImageView.m
//  Hospital Base Client
//
//  Created by Kevin Scardina on 3/22/14.
//  Copyright (c) 2014 com.kevinscardina.novum. All rights reserved.
//

#import "NVMZoomImageView.h"

@implementation UITouch (TouchSorting)

- (NSComparisonResult)compareAddress:(id)obj
{
    if ((__bridge void *)self < (__bridge void *)obj) {
        return NSOrderedAscending;
    } else if ((__bridge void *)self == (__bridge void *)obj) {
        return NSOrderedSame;
    } else {
        return NSOrderedDescending;
    }
}

@end

@implementation NVMZoomImageView

//@synthesize touchBeginPoints;

- (id)init{
    return [super init];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        originalTransform = CGAffineTransformIdentity;
        //touchBeginPoints = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
        self->touchBeginPoints = [[NSMutableDictionary alloc] init];
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        self.exclusiveTouch = YES;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        originalTransform = CGAffineTransformIdentity;
        //touchBeginPoints = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
        self->touchBeginPoints = [[NSMutableDictionary alloc] init];
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        self.exclusiveTouch = YES;
    }
    return self;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan");
    NSMutableSet *currentTouches = [[event touchesForView:self] mutableCopy];
    [currentTouches minusSet:touches];
    if ([currentTouches count] > 0) {
        [self updateOriginalTransformForTouches:currentTouches];
        [self cacheBeginPointForTouches:currentTouches];
    }
    [self cacheBeginPointForTouches:touches];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
     NSLog(@"touchesMoved");
    CGAffineTransform incrementalTransform = [self incrementalTransformWithTouches:[event touchesForView:self]];
    self.transform = CGAffineTransformConcat(originalTransform, incrementalTransform);
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
     NSLog(@"touchesEnded");
    for (UITouch *touch in touches) {
        if (touch.tapCount >= 2) {
            [self.superview bringSubviewToFront:self];
        }
    }
    
    [self updateOriginalTransformForTouches:[event touchesForView:self]];
    [self removeTouchesFromCache:touches];
    
    NSMutableSet *remainingTouches = [[event touchesForView:self] mutableCopy];
    [remainingTouches minusSet:touches];
    [self cacheBeginPointForTouches:remainingTouches];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesCancelled");
    [self touchesEnded:touches withEvent:event];
}

- (CGAffineTransform)incrementalTransformWithTouches:(NSSet *)touches
{
    NSArray *sortedTouches = [touches allObjects];
    NSInteger numTouches = [sortedTouches count];
    
	// No touches
	if (numTouches == 0) {
        return CGAffineTransformIdentity;
    }
    
	// Single touch
	if (numTouches == 1) {
        UITouch *touch = [sortedTouches objectAtIndex:0];
        CGPoint beginPoint = [(NSValue*)[touchBeginPoints objectForKey:[NSString stringWithFormat:@"%d", (int)touch]] CGPointValue];
        CGPoint currentPoint = [touch locationInView:self.superview];
		return CGAffineTransformMakeTranslation(currentPoint.x - beginPoint.x, currentPoint.y - beginPoint.y);
	}
    
	// If two or more touches, go with the first two (sorted by address)
	UITouch *touch1 = [sortedTouches objectAtIndex:0];
	UITouch *touch2 = [sortedTouches objectAtIndex:1];
    
    NSValue* v1 = [touchBeginPoints objectForKey:[NSString stringWithFormat:@"%d", (int)touch1]];
    CGPoint beginPoint1 = [v1 CGPointValue];
    CGPoint currentPoint1 = [touch1 locationInView:self.superview];
    NSValue* v2 =[touchBeginPoints objectForKey:[NSString stringWithFormat:@"%d", (int)touch2]];
    CGPoint beginPoint2 = [v2 CGPointValue];
    CGPoint currentPoint2 = [touch2 locationInView:self.superview];
    
	double layerX = self.center.x;
	double layerY = self.center.y;
	
	double x1 = beginPoint1.x - layerX;
	double y1 = beginPoint1.y - layerY;
	double x2 = beginPoint2.x - layerX;
	double y2 = beginPoint2.y - layerY;
	double x3 = currentPoint1.x - layerX;
	double y3 = currentPoint1.y - layerY;
	double x4 = currentPoint2.x - layerX;
	double y4 = currentPoint2.y - layerY;
	
	// Solve the system:
	//   [a b t1, -b a t2, 0 0 1] * [x1, y1, 1] = [x3, y3, 1]
	//   [a b t1, -b a t2, 0 0 1] * [x2, y2, 1] = [x4, y4, 1]
	
	double D = (y1-y2)*(y1-y2) + (x1-x2)*(x1-x2);
	if (D < 0.1) {
        return CGAffineTransformMakeTranslation(x3-x1, y3-y1);
    }
    
	double a = (y1-y2)*(y3-y4) + (x1-x2)*(x3-x4);
	double b = (y1-y2)*(x3-x4) - (x1-x2)*(y3-y4);
	double tx = (y1*x2 - x1*y2)*(y4-y3) - (x1*x2 + y1*y2)*(x3+x4) + x3*(y2*y2 + x2*x2) + x4*(y1*y1 + x1*x1);
	double ty = (x1*x2 + y1*y2)*(-y4-y3) + (y1*x2 - x1*y2)*(x3-x4) + y3*(y2*y2 + x2*x2) + y4*(y1*y1 + x1*x1);
	
    return CGAffineTransformMake(a/D, -b/D, b/D, a/D, tx/D, ty/D);
}

- (void)updateOriginalTransformForTouches:(NSSet *)touches
{
    if ([touches count] > 0) {
        CGAffineTransform incrementalTransform = [self incrementalTransformWithTouches:touches];
        self.transform = CGAffineTransformConcat(originalTransform, incrementalTransform);
        originalTransform = self.transform;
    }
}

- (void)cacheBeginPointForTouches:(NSSet *)touches
{
    if ([touches count] > 0) {
        for (UITouch *touch in touches) {
           [touchBeginPoints setObject:[NSValue valueWithCGPoint:[touch locationInView:self.superview]] forKey:[NSString stringWithFormat:@"%d", (int)touch]];
        }
    }
}

- (void)removeTouchesFromCache:(NSSet *)touches
{
    for (UITouch *touch in touches) {
        [touchBeginPoints removeObjectForKey:touch];
    }
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
