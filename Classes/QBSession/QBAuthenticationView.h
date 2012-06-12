//
//  QBAuthenticationView.h
//  iShare
//
//  Created by midhun on 26/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBView.h"

@protocol QBAuthenticationViewDelegate <NSObject>

@optional

- (void)authViewCloseButtonPressed:(id)sender;

@end

@interface QBAuthenticationView : UIView {
	
	UIWebView				* _qbWebView;
	QBView					* _qbView;
	UIView					* _barView;
	UIButton				* _closeButton;
	UIActivityIndicatorView * _activityIndicator;
	id						_delegate;
}

@property (nonatomic, retain) UIWebView * qbWebView;
@property (nonatomic, assign) NSObject <QBAuthenticationViewDelegate> * delegate;
@property (nonatomic, retain) UIActivityIndicatorView * activityIndicator;

- (void)setBarColor:(UIColor *)aColor ;
@end
