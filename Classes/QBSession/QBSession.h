//
//  QBSession.h
//  iShare
//
//  Created by midhun on 22/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBAuthenticationView.h"

typedef enum {
	QBFaceBookSession = 0,
	QBTwitterSession,
	QBGoogleLatitudeSession,
	QBFourSquareSession,
	QBLinkedInSession
} QBSessionType;

@protocol QBSessionDelegate;


@interface QBSession : NSObject < UIWebViewDelegate,QBAuthenticationViewDelegate > {
	QBSessionType _sessionType;
	NSString	*_consumerKey;
	NSString	*_consumerSecret;
	NSString    *_clientID;
	NSString	*_requestToken;
	NSString	*_accessToken;
	NSString	*_authVerifier;
	NSString	*_baseURL;
	NSString	*_requestTokenSecret;
	NSString	*_accessTokenSecret;
	NSString	*_callbackURI;
	NSMutableDictionary * _session;
	NSString	*_sessionProxy;
	
	QBAuthenticationView *_qbAuthView;
	id			_delegate;
	NSArray		*_permissions;
	NSURLConnection *_activePostConnection;
}

@property(nonatomic,assign) NSObject <QBSessionDelegate> * delegate;

//- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret;
//- (id)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret;
- (void)getRequestToken;
- (void)launchWebAuthentication;
- (void)getAccessToken;
- (void)startSession;
- (NSString*)getCurrentAccessToken;
- (void) initParameters:(NSDictionary * )options;
- (NSString *) generateExtendPermissionString ;
- (id)initWithType:(QBSessionType)sessionType withOptions:(NSDictionary *)options;
- (void)getSessionFromProxy ;
- (void)postData:(NSDictionary *)data;
- (void)deleteFacebookCookies;
- (void)deleteLinkedInCookies;
- (void)clearCurrentAccessToken;
- (NSString *)preparePostBodyFromData:(NSDictionary *)data; 
- (NSString *)getCurrentAccessTokenSecret;

@end

@protocol QBSessionDelegate <NSObject>

@optional

- (void) sessionDidStarted;
- (void) webViewWillAppear;
- (void) webViewDidLoadForAuthentication:(UIView*)authView;
- (void) webViewWillDisappear;
- (void) sessionDidReceivedAccessToken:(NSString *)accessToken withSessionData:(NSDictionary*)sessionData;
- (void) sessionDidReceivedAccessToken:(NSString *)accessToken withTokenSecret:(NSString *)tokenSecret;
- (void) sessionDidFailedWithError:(NSError *)error;
- (void) sessionDidStopped;
- (void) userClosedAuthView;
- (void) dataPostedSuccessfully:(QBSession *)session;
- (void) dataPostFailed:(QBSession *)session withError:(NSError *)error;

@end


@interface NSString (OAURLEncodingAdditions)

- (NSString *)encodedURLString;
- (NSString *)encodedURLParameterString;
- (NSString *)decodedURLString;
- (NSString *)removeQuotes;
@end

@interface UIColor (SessionColorAdditions)
+ (UIColor*)twitterColor;
+ (UIColor*)faceBookColor;
+ (UIColor*)googleColor;
+ (UIColor*)foursquareColor;
+ (UIColor*)linkedInColor;
@end
