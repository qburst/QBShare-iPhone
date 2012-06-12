//
//  QBShareViewController.m
//  iShare
//
//  Created by midhun on 22/07/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "QBShareViewController.h"
#import "ULogger.h"
#import "QBShareAppDelegate.h"
#import <QuartzCore/QuartzCore.h>



@implementation QBShareViewController

@synthesize selectedIndex = selectedIndex_;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	/***** init method parameters ******
	 
	 Parameters are passed in a dictionairy.
	 
	 Keys
	 
	 client_ID				- To specify app ID or client ID for a session.
	 consumer_secret        - To specify consumer_secret or client_secret or application_secret
	 callback_uri			- To specify redirect_uri or registered callback_uri. This is optional for facebook. But for twitter, google latitude this is required field. Registered uri must be provided
	 
	 *///
	// Facebook usage with extended permissions 
    
	
    
	NSArray * extendedPermissions = [NSArray arrayWithObjects:@"offline_access",@"publish_stream",nil]; 
	NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:@"125121217532117",@"client_ID",@"e6431bf276d14ba4709195e39f0fd1c0",@"consumer_secret",extendedPermissions,@"scope",nil];
	
	fbSession = [[QBSession alloc] initWithType:QBFaceBookSession withOptions:options];
	fbSession.delegate = self;
	
	// Twitter usage
	options = [NSDictionary dictionaryWithObjectsAndKeys:@"aLzMXFqOTrEMGxwkAmLIqg",@"consumer_key",@"su3cjSQ852GBTGm6IBxtHdQRlYiHCtM7EQB0B9M",@"consumer_secret",@"http://api.twitter.com/callback",@"callback_uri",nil];
	
	twSession = [[QBSession alloc] initWithType:QBTwitterSession withOptions:options];
	twSession.delegate = self;
	
	//Linkedin usage 
	options = [NSDictionary dictionaryWithObjectsAndKeys:@"1Y9ZtUVGkjeW2sBZ3I6HdMMNW3yGGXERk5NRY5WhFUEzfWgpAEzy29C-q6BtBG9i",@"consumer_key",@"6sd_TtApBajshBAuxefOm94ZUjn0HIzQuldjREnZsnsbzIYn1bZXBEQDnVzBGITF",@"consumer_secret",@"http://api.linkedin.com/success",@"callback_uri",nil];
	
	lnSession = [[QBSession alloc] initWithType:QBLinkedInSession withOptions:options];
	lnSession.delegate = self;
	
}

/*
 Action for connect Button.
 */
- (IBAction)startLogin:(id)sender {
	
	switch (self.selectedIndex) {
		case 0:
			[fbSession startSession];
			break;
		case 1:
			[lnSession startSession];
			break;
        case 2:
            [twSession startSession];
		default:
			break;
	}
	
}

-(IBAction)barButtonPressed:(id)sender{
	
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark Session Delegate functions

- (void) sessionDidStarted {
	
	//NSLog(@"---\nSession Started Successfully---\n");
	[ULogger logDebug:@"---\nSession Started Successfully---\n"];
}

- (void) webViewWillAppear {
	
	//NSLog(@"---\nWeb view will appear now . . .---\n");
	[ULogger logDebug:@"---\nWeb view will appear now . . .---\n"];
}

- (void) webViewDidLoadForAuthentication:(UIView*)authView {
	
	//NSLog(@"---\nWeb view appeared now---\n");
	[ULogger logDebug:@"---\nWeb view appeared now---\n"];
	[self.view addSubview:authView];
}

- (void) webViewWillDisappear {
	
	//NSLog(@"---\nUser is authenticated and can web view will disappear now---\n");
	[ULogger logDebug:@"---\nUser is authenticated and can web view will disappear now---\n"];
}

- (void) sessionDidReceivedAccessToken:(NSString *)accessToken withTokenSecret:(NSString *)tokenSecret {
	
	//NSLog(@"---\nAccess Token is obtained for Session as %@---\n",accessToken);
	[ULogger logDebug:@"---\nAccess Token is obtained for Session as %@---\n",accessToken];
	//NSLog(@"---\nToken Secret is obtained for Session as %@---\n",tokenSecret);
	[ULogger logDebug:@"---\nToken Secret is obtained for Session as %@---\n",tokenSecret];
	if (accessToken) {
		[accessToken release];
	}
	accessToken_ = [accessToken retain];
	if (tokenSecret) {
		[tokenSecret release];
	}
	tokenSecret_ = [tokenSecret retain];
	[self showCommentView:self.selectedIndex ];
}

- (void) sessionDidFailedWithError:(NSError *)error {
	NSDictionary *userInfo = [error userInfo];
	NSLog(@"User Info:%@",[error userInfo]);
	NSString *errorMessage;
	if ([[userInfo objectForKey:@"oauth_problem"] isEqualToString:@"timestamp_refused"]) {
		errorMessage = @"Please check your time settings";
	}else {
		errorMessage = @"Please try again after some time";
	}

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An Error Occurred" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void) sessionDidStopped {
	
	
}

- (void) dataPostedSuccessfully:(QBSession *)session {
	
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Data Posted" message:@"Posted Successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[activityIndicator_ stopAnimating];
}

- (void) dataPostFailed:(QBSession *)session withError:(NSError *)error {
	
	
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Data Post Failed" message:@"Posting Failed. Check console log for reason" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[activityIndicator_ stopAnimating];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
    [self barButtonPressed:alertView];
}

- (void)showCommentView:(QBSessionType)sessionType {
	
	UIWindow * mainWindow = [QBShareAppDelegate mainApplicationInstance].window;
	
	UIView * overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 20.0, self.view.frame.size.width, mainWindow.frame.size.height)];
	overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	UIView * backGroundView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 10.0, self.view.frame.size.width-20, 200.0)];
	
	UIView * commentView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,backGroundView.frame.size.width,backGroundView.frame.size.height)];
	
	commentView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.9];
	
	CALayer * layer = commentView.layer;
	layer.masksToBounds = YES;
	layer.cornerRadius = 10;
	
	[backGroundView addSubview:commentView];
	[commentView release];
	
	UITextField * commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 30.0, backGroundView.frame.size.width-20, 120)];
	commentTextField.font = [UIFont boldSystemFontOfSize:14];
	commentTextField.returnKeyType = UIReturnKeyDone;
	commentTextField.borderStyle = UITextBorderStyleRoundedRect;
	[commentTextField addTarget:self action:@selector(editingDidFinished:) forControlEvents:UIControlEventEditingDidEnd];
	[commentTextField addTarget:self action:@selector(editingDidFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
	commentTextField.placeholder = @"Enter Your Comment Here";
	[backGroundView addSubview:commentTextField];
	commentTextField.tag = 112;
	[commentTextField release];
	
	UIButton * shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[shareButton addTarget:self action:@selector(shareComment:) forControlEvents:UIControlEventTouchUpInside];
	[shareButton setTitle:@"Share" forState:UIControlStateNormal];
	[shareButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	shareButton.frame = CGRectMake(0, 0, 80.0, 30.0);
	shareButton.center = CGPointMake(60, backGroundView.frame.size.height-25);
	shareButton.tag = sessionType;
	
	[backGroundView addSubview:shareButton];
	
	
	UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[cancelButton addTarget:self action:@selector(cancelComment:) forControlEvents:UIControlEventTouchUpInside];
	[cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
	[cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	cancelButton.frame = CGRectMake(0.0, 0.0, 80.0, 30.0);
	cancelButton.center = CGPointMake(backGroundView.frame.size.width-60, backGroundView.frame.size.height-25);
	cancelButton.tag = sessionType;
	
	[backGroundView addSubview:cancelButton];
	
	backGroundView.tag = 111;
	
	backGroundView.center = CGPointMake(self.view.frame.size.width/2.0, mainWindow.frame.size.height/2.0);
	
	[mainWindow addSubview:overlayView];
	overlayView.tag = 113;
	[mainWindow addSubview:backGroundView];	
	[overlayView release];
	[backGroundView release];
}

-(void)editingDidFinished:(id)sender {
	
	UITextField * field = (UITextField *)sender;
	[field resignFirstResponder];	
}

-(void)cancelComment:(id)sender {
	
	UIWindow * mainWindow = [QBShareAppDelegate mainApplicationInstance].window;
	[[mainWindow viewWithTag:113]removeFromSuperview];
	[[mainWindow viewWithTag:111]removeFromSuperview];
}

/*
 Posts comment to facebook, twitter or linked in based on the selected one
 */
-(void)shareComment:(id)sender {
	
	UIWindow * mainWindow = [QBShareAppDelegate mainApplicationInstance].window;
	UIView * backGroundView = [mainWindow viewWithTag:111];
	UITextField * textField = (UITextField *)[backGroundView viewWithTag:112];
	if ([textField.text length]) {
		
		switch (self.selectedIndex) {
			case 0:{
				//  face book
				NSString * message = [NSString stringWithFormat:@"Test Message created at %@",textField.text];
				NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:accessToken_,@"access_token",message,@"message",@"http://www.google.com",@"link",@"http://www.google.com/intl/en_ALL/images/logos/images_logo_lg.gif",@"picture",@"Test_Title",@"name",@"Test_Caption",@"caption",@"Test_Description",@"description",@"{\"value\":\"EVERYONE\"}",@"privacy",nil];
				[fbSession postData:data];
			}			
				break;
			case 1:{
				//Linked in
				NSError * error = nil;
				
				NSString * messageFormat = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"format" ofType:@"xml"] encoding:NSUTF8StringEncoding error:&error];
				
				NSString * message = [NSString stringWithFormat:messageFormat,[NSString stringWithFormat:@"Test Message created at %@",textField.text],@"Test_Title",@"http://www.google.com",@"http://www.google.com/intl/en_ALL/images/logos/images_logo_lg.gif"];
				
				NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:accessToken_,@"access_token",tokenSecret_,@"access_secret",message,@"message",nil];
				
				[lnSession postData:data];
			}
				break;
			case 2:{
				//Twitter
				NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:accessToken_,@"access_token",tokenSecret_,@"access_secret",[NSString stringWithFormat:@"Test Message created at %@",textField.text],@"message",nil];
				[twSession postData:data];
			}
				break;
			default:
				break;
		}
	}
	[activityIndicator_ startAnimating];
	[[mainWindow viewWithTag:113]removeFromSuperview];
	[[mainWindow viewWithTag:111]removeFromSuperview];
}

- (void)dealloc {
	
	fbSession.delegate = nil;
	twSession.delegate = nil;
    lnSession.delegate = nil;
	[fbSession release];
    [lnSession release];
	[twSession release];
	[accessToken_ release];
	[tokenSecret_ release];
	[super dealloc];

}

@end
