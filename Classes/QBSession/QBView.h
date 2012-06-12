//
//  QBView.h
//  iShare
//
//  Created by midhun on 26/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QBView : UIView {

}
- (void)drawRect:(CGRect)rect fill:(const CGFloat*)fillColors radius:(CGFloat)radius;
- (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect radius:(float)radius;
- (void)strokeLines:(CGRect)rect stroke:(const CGFloat*)strokeColor;
@end
