//
//  QBWebView.m
//  iShare
//
//  Created by midhun on 22/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "QBWebView.h"



@implementation QBWebView



- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		    }
    return self;
}

- (void)loadRequest:(NSURLRequest *)request {
	[super loadRequest:request];
	
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//	
//	
//	//CGRect headerRect = CGRectMake(
////								   ceil(rect.origin.x + kBorderWidth), ceil(rect.origin.y + kBorderWidth),
////								   rect.size.width - kBorderWidth*2, _titleLabel.frame.size.height);
////	[self drawRect:headerRect fill:kFacebookBlue radius:0];
////	[self strokeLines:headerRect stroke:kBorderBlue];
////	
////	CGRect webRect = CGRectMake(
////								ceil(rect.origin.x + kBorderWidth), headerRect.origin.y + headerRect.size.height,
////								rect.size.width - kBorderWidth*2, _webView.frame.size.height+1);
////	[self strokeLines:webRect stroke:kBorderBlack];
//}



- (void)dealloc {
    [super dealloc];
}




@end
