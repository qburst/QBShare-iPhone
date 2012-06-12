//
//  QBView.m
//  iShare
//
//  Created by midhun on 26/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "QBView.h"


@implementation QBView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

//static NSString* kDefaultTitle = @"Connect to Facebook";
//static NSString* kStringBoundary = @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3q2f";

//static CGFloat kFacebookBlue[4] = {0.42578125, 0.515625, 0.703125, 1.0};
static CGFloat kBorderGray[4] = {0.3, 0.3, 0.3, 0.8};
//static CGFloat kBorderBlack[4] = {0.3, 0.3, 0.3, 1};
//static CGFloat kBorderBlue[4] = {0.23, 0.35, 0.6, 1.0};

//static CGFloat kTransitionDuration = 0.3;

//static CGFloat kTitleMarginX = 8;
//static CGFloat kTitleMarginY = 4;
//static CGFloat kPadding = 10;
//static CGFloat kBorderWidth = 10;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
	CGRect grayRect = CGRectOffset(rect, -0.5, -0.5);
	[self drawRect:grayRect fill:kBorderGray radius:10.0];
}

- (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect radius:(float)radius {
	CGContextBeginPath(context);
	CGContextSaveGState(context);
	
	if (radius == 0) {
		CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
		CGContextAddRect(context, rect);
	} else {
		rect = CGRectOffset(CGRectInset(rect, 0.5, 0.5), 0.5, 0.5);
		CGContextTranslateCTM(context, CGRectGetMinX(rect)-0.5, CGRectGetMinY(rect)-0.5);
		CGContextScaleCTM(context, radius, radius);
		float fw = CGRectGetWidth(rect) / radius;
		float fh = CGRectGetHeight(rect) / radius;
		
		CGContextMoveToPoint(context, fw, fh/2);
		CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
		CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
		CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
		CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
	}
	
	CGContextClosePath(context);
	CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect fill:(const CGFloat*)fillColors radius:(CGFloat)radius {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	
	if (fillColors) {
		CGContextSaveGState(context);
		CGContextSetFillColor(context, fillColors);
		if (radius) {
			[self addRoundedRectToPath:context rect:rect radius:radius];
			CGContextFillPath(context);
		} else {
			CGContextFillRect(context, rect);
		}
		CGContextRestoreGState(context);
	}
	
	CGColorSpaceRelease(space);
}

- (void)strokeLines:(CGRect)rect stroke:(const CGFloat*)strokeColor {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	
	CGContextSaveGState(context);
	CGContextSetStrokeColorSpace(context, space);
	CGContextSetStrokeColor(context, strokeColor);
	CGContextSetLineWidth(context, 1.0);
    
	{
		CGPoint points[] = {rect.origin.x+0.5, rect.origin.y-0.5,
			rect.origin.x+rect.size.width, rect.origin.y-0.5};
		CGContextStrokeLineSegments(context, points, 2);
	}
	{
		CGPoint points[] = {rect.origin.x+0.5, rect.origin.y+rect.size.height-0.5,
			rect.origin.x+rect.size.width-0.5, rect.origin.y+rect.size.height-0.5};
		CGContextStrokeLineSegments(context, points, 2);
	}
	{
		CGPoint points[] = {rect.origin.x+rect.size.width-0.5, rect.origin.y,
			rect.origin.x+rect.size.width-0.5, rect.origin.y+rect.size.height};
		CGContextStrokeLineSegments(context, points, 2);
	}
	{
		CGPoint points[] = {rect.origin.x+0.5, rect.origin.y,
			rect.origin.x+0.5, rect.origin.y+rect.size.height};
		CGContextStrokeLineSegments(context, points, 2);
	}
	
	CGContextRestoreGState(context);
	
	CGColorSpaceRelease(space);
}


- (void)dealloc {
    [super dealloc];
}


@end
