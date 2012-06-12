//
//  QBShareViewController.h
//  QBShare
//
//  Created by midhun on 22/07/10.
//  Copyright QBurst 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBSession.h"

@interface QBShareViewController : UIViewController <QBSessionDelegate,UIAlertViewDelegate> {
	
	QBSession * fbSession;
	QBSession * twSession;
	QBSession * goSession;
	QBSession * fsSession;
	QBSession * lnSession;
	
	NSInteger selectedIndex_;
	NSString *accessToken_;
	NSString *tokenSecret_;
	
	IBOutlet UIActivityIndicatorView *activityIndicator_;
	
}

@property NSInteger selectedIndex;

- (IBAction)startLogin:(id)sender;
- (IBAction)barButtonPressed:(id)sender;

- (void)showCommentView:(QBSessionType)sessionType;


@end

