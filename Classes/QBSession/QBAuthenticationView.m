//
//  QBAuthenticationView.m
//  iShare
//
//  Created by midhun on 26/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "QBAuthenticationView.h"
#import <QuartzCore/QuartzCore.h>

@implementation QBAuthenticationView

@synthesize qbWebView = _qbWebView;
@synthesize delegate = _delegate;
@synthesize activityIndicator = _activityIndicator;

- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		_qbView = [[QBView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
		_barView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 10.0, frame.size.width-20, frame.size.height-20)];
		_qbWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0,30.0,frame.size.width-20, frame.size.height-50.0)];
		_closeButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-50, 0.0, 30.0, 30.0)];
		[_closeButton setTitle:@"x" forState:UIControlStateNormal];
		[_closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
		[_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[_closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside]; 
		_qbWebView.scalesPageToFit = YES;
		
		_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_activityIndicator.hidesWhenStopped = YES;
		CALayer * tempLayer = [_barView layer];
		tempLayer.masksToBounds = YES;
		tempLayer.cornerRadius = 10.0;
		[_qbView addSubview:_barView];
		[_barView addSubview:_qbWebView];
		[_barView addSubview:_closeButton];
		[self addSubview:_qbView];
		[self addSubview:_activityIndicator];
		self.backgroundColor = [UIColor clearColor];
	  }
    return self;
}



- (void)closeButtonPressed{
		//Delegate call to remove view
	if (_delegate) {
		if ([_delegate respondsToSelector:@selector(authViewCloseButtonPressed:)]) {
			[_delegate authViewCloseButtonPressed:self];
		}
	}
}

- (void)setBarColor:(UIColor *)aColor {
	[_barView setBackgroundColor:aColor];
}

- (void)dealloc {
	[_barView release];
	[_closeButton release];
	[_qbWebView release];
	[_qbView release];
	[_activityIndicator release];
    [super dealloc];
}


@end
