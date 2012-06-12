//
//  QBSession.m
//  iShare
//
//  Created by midhun on 22/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "QBSession.h"
#import "CJSONDeserializer.h"
#import "TouchXML.h"
#import "QBSessionConstants.h"
#import "ULogger.h"

extern void hmac_sha1(const unsigned char *inText, size_t inTextLength, unsigned char* inKey, size_t inKeyLength, unsigned char *outDigest);
extern bool Base64EncodeData(const void *inInputData, size_t inInputDataSize, char *outOutputData, size_t *ioOutputDataSize);


@implementation UIColor (SessionColorAdditions)

+ (UIColor*)twitterColor {
    return [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:1.00];
	//return [UIColor colorWithRed:0.32 green:0.83 blue:1.00 alpha:1.00];
}
+ (UIColor*)faceBookColor {
	return [UIColor colorWithRed:0.10 green:0.19 blue:0.37 alpha:1.00];
}
+ (UIColor*)googleColor {
	return [UIColor colorWithRed:0.06 green:0.06 blue:0.80 alpha:1.00];
}
+ (UIColor*)foursquareColor {
	return [UIColor colorWithRed:0.04 green:0.72 blue:0.87 alpha:1.00];
}
+ (UIColor*)linkedInColor {
	return [UIColor colorWithRed:0.00 green:0.40 blue:0.60 alpha:1.00];
}
@end



@interface QBSession (ReleaseAdditions)
- (void)releaseIfNeeded:(id)object;
@end

@implementation QBSession (ReleaseAdditions)

- (void)releaseIfNeeded:(id)object {
	if (object!=nil) {
		[object release];
	}
}

@end


@implementation NSString (OAURLEncodingAdditions)
/*
 * Extended NSString methods for URL encoding and decoding.  
 */
- (NSString *)encodedURLString {
	NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,                   // characters to leave unescaped (NULL = all escaped sequences are replaced)
                                                                           CFSTR("?=&+"),          // legal URL characters to be escaped (NULL = all legal characters are replaced)
                                                                           kCFStringEncodingUTF8); // encoding
	return [result autorelease];
}

- (NSString *)encodedURLParameterString {
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,
                                                                           CFSTR(":/=,!$&'()*+;[]@#?"),
                                                                           kCFStringEncodingUTF8);
	return [result autorelease];
}

- (NSString *)decodedURLString {
	NSString *result = (NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																						  (CFStringRef)self,
																						  CFSTR(""),
																						  kCFStringEncodingUTF8);
	
	return [result autorelease];
	
}

/*
 * Extended NSString methods for removing quotes from string.  
 */
-(NSString *)removeQuotes
{
	NSUInteger length = [self length];
	NSString *ret = self;
	if ([self characterAtIndex:0] == '"') {
		ret = [ret substringFromIndex:1];
	}
	if ([self characterAtIndex:length - 1] == '"') {
		ret = [ret substringToIndex:length - 2];
	}
	
	return ret;
}

@end

@implementation QBSession

@synthesize delegate = _delegate;

- (id) init {
	self = [super init];
	if (self != nil) {
		
	}
	return self;
}

- (id)initWithType:(QBSessionType)sessionType withOptions:(NSDictionary *)options {
	if ((self=[[QBSession alloc] init])) {
		_sessionType = sessionType;
		_session = nil;
		_qbAuthView = nil;
		[self initParameters:options];
	}
	return self;
}

/*
 * According to the sessionType the different parameters get initialized.
 * The parameters are passed in the form of NSDictionairy
 * 
 * The key field for different parameters are 
 *  
 *		Key					Meaning
 * session_proxy	-       The url of session proxy server to get session info.
 * consumer_key		-		The api key or consumer key for app.
 * client_ID		-		The app ID or client ID for app.
 * consumer_secret	-		The consumer secret or app secret for app.
 * scope			-		This is the array with info about extended permissions.
 * callback_uri		-		This is redirecting uri or registered call back url for app.
 */

- (void) initParameters:(NSDictionary *)options {
	switch (_sessionType) {
		case QBFaceBookSession:
			if ([options objectForKey:@"session_proxy"]) {
				_sessionProxy = [[options objectForKey:@"session_proxy"] retain];
				_consumerKey = [[options objectForKey:@"consumer_key"] retain];
				_clientID = [[options objectForKey:@"client_ID"]  retain];
				_consumerSecret = nil;
			} else {
				_clientID = [[options objectForKey:@"client_ID"]  retain];
				_consumerSecret = nil;
				_consumerKey = nil;
			}			
			_baseURL = FACEBOOK_BASE_URL;
			_callbackURI = REDIRECT_URI;
			
			_permissions = nil;
			if ([options objectForKey:@"scope"]) {
				_permissions = [[options objectForKey:@"scope"] retain];
			}
			break;
		case QBTwitterSession:
			_consumerKey = [[options objectForKey:@"consumer_key"] retain];
			_consumerSecret = [[options objectForKey:@"consumer_secret"] retain];
			_baseURL = TWITTER_BASE_URL;
			_callbackURI = [[options objectForKey:@"callback_uri"] retain];
			_clientID = nil;
			_permissions = nil;
			break;
		case QBGoogleLatitudeSession:
			_consumerKey = [[options objectForKey:@"consumer_key"] retain];
			_consumerSecret = [[options objectForKey:@"consumer_secret"] retain];
			_baseURL = GOOGLE_LATITUDE_URL;
			_callbackURI = [[options objectForKey:@"callback_uri"] retain];
			_clientID = nil;
			_permissions = nil;
			break;
		case QBFourSquareSession:
			_consumerKey = [[options objectForKey:@"consumer_key"] retain];
			_consumerSecret = [[options objectForKey:@"consumer_secret"] retain];
			_baseURL = FOUR_SQUARE_URL;
			_callbackURI = [[options objectForKey:@"callback_uri"] retain];
			_clientID = nil;
			_permissions = nil;
			break;
		case QBLinkedInSession:
			_consumerKey = [[options objectForKey:@"consumer_key"] retain];
			_consumerSecret = [[options objectForKey:@"consumer_secret"] retain];
			_baseURL = LINKED_IN_URL;
			_callbackURI = [[options objectForKey:@"callback_uri"] retain];
			_clientID = nil;
			_permissions = nil;			
			break;

		default:
			
			break;
	}
	_requestToken = nil;
	_accessToken = nil;
	_requestTokenSecret = @"";
	_accessTokenSecret = @"";
	_authVerifier = nil;
}
/*
 * To generate comma seperated extended permission string.
 */
- (NSString *) generateExtendPermissionString {
	
	NSString * extPermissionString = nil;
	if (_permissions) {
		
		if ([_permissions count]>1) {			
			extPermissionString = [_permissions componentsJoinedByString:@","];			
		} else if ([_permissions count]) {
			extPermissionString = [_permissions objectAtIndex:0];
		} else {
			return nil;
		}		
	}
	return extPermissionString;
}

/*
 * To generate request token with the given parameters.
 */
- (void)getRequestToken {
	
	NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
	
	//Generating time Stamp
	NSString * timestamp = [NSString stringWithFormat:@"%d", time(NULL)];
	
	[param setObject:timestamp forKey:@"oauth_timestamp"];
	
	//Generating nonce
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    NSMakeCollectable(theUUID);
	
    NSString * nonce = (NSString *)string;	
    
	[param setObject:nonce forKey:@"oauth_nonce"];
	CFRelease(theUUID);
	CFRelease(string);
	
	//Setting signature method and OAuth Version
	[param setObject:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
	[param setObject:@"1.0" forKey:@"oauth_version"];
	
	//Settings for google latitude service
	if (_sessionType == QBGoogleLatitudeSession) {
		
		[param setObject:@"google" forKey:@"oauth_callback"];
		[param setObject:@"https%3A%2F%2Fwww.googleapis.com%2Fauth%2Flatitude" forKey:@"scope"];
		[param setObject:@"shareThoughts" forKey:@"xoauth_displayname"];
	}	[param setObject:_consumerKey forKey:@"oauth_consumer_key"];
	
	//Generation of sorted and ecoded parameter list	
	NSArray * sortedKeys = [[param allKeys] sortedArrayUsingSelector:@selector(compare:)];	
	
	NSMutableArray * array = [[NSMutableArray alloc] init];	
	for (NSString * key in sortedKeys) {
		
		[array addObject:[NSString stringWithFormat:@"%@=%@",key,[param objectForKey:key]]];
		
	}	
	NSString * combinedString = [array componentsJoinedByString:@"&"];	
	[array release];
	
	//Request URL generation
	NSString * requestURL = nil;
	
	switch (_sessionType) {
		case QBTwitterSession:
			requestURL = [NSString stringWithFormat:@"%@request_token",_baseURL];
			break;
		case QBGoogleLatitudeSession:
			requestURL = [NSString stringWithFormat:@"%@OAuthGetRequestToken",_baseURL];
			break;
		case QBFourSquareSession:
			requestURL = [NSString stringWithFormat:@"%@request_token",_baseURL];
			break;
		case QBLinkedInSession:
			requestURL = [NSString stringWithFormat:@"%@requestToken",_baseURL];
			break;

		default:
			break;
	}
	
	//Base string generation for creating signature
	NSString * baseString = [NSString stringWithFormat:@"POST&%@&%@",[requestURL encodedURLParameterString],[combinedString encodedURLParameterString]];
	//Sign Key generation for creating signature
	NSString * signKey = [NSString stringWithFormat:@"%@&",[_consumerSecret encodedURLParameterString]];
	
#if DEBUG
	//[ULogger logDebug:@"Base string : %@",baseString];
	NSLog(@"Base string : %@",baseString);
#endif
	//Signing process
	NSData *secretData = [signKey dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [baseString dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
    hmac_sha1((unsigned char *)[clearTextData bytes], [clearTextData length], (unsigned char *)[secretData bytes], [secretData length], result);
    
    //Base64 Encoding
    
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(result, 20, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    
	//Encoded signature generation
    NSString *base64EncodedResult = [[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding] autorelease];
    [param setObject:base64EncodedResult forKey:@"oauth_signature"];
	
	
	
	//Genarating request for access token	
	
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
	
	[request setHTTPMethod:@"POST"];	
	
	// Authorization Header generation
	NSMutableArray *chunks = [[NSMutableArray alloc] init];
	
	[chunks addObject:[NSString stringWithFormat:@"oauth_nonce=\"%@\"",[[param objectForKey:@"oauth_nonce"] encodedURLParameterString]]];
	if (_sessionType == QBGoogleLatitudeSession) {
		[chunks addObject:[NSString stringWithFormat:@"oauth_callback=\"%@\"",[[param objectForKey:@"oauth_callback"] encodedURLParameterString]]];
	}
	[chunks addObject:[NSString stringWithFormat:@"oauth_signature_method=\"%@\"",[[param objectForKey:@"oauth_signature_method"] encodedURLParameterString]]];
	[chunks addObject:[NSString stringWithFormat:@"oauth_timestamp=\"%@\"",[[param objectForKey:@"oauth_timestamp"] encodedURLParameterString]]];
	[chunks addObject:[NSString stringWithFormat:@"oauth_consumer_key=\"%@\"",[[param objectForKey:@"oauth_consumer_key"] encodedURLParameterString]]];
	[chunks addObject:[NSString stringWithFormat:@"oauth_signature=\"%@\"",[[param objectForKey:@"oauth_signature"] encodedURLParameterString]]];
	[chunks addObject:[NSString stringWithFormat:@"oauth_version=\"%@\"",[[param objectForKey:@"oauth_version"] encodedURLParameterString]]];
	
	
	NSString *oauthHeader = [NSString stringWithFormat:@"OAuth %@", [chunks componentsJoinedByString:@", "]];
	[chunks release];
#if DEBUG
	//[ULogger logDebug:@"OAuthHeader ---- \n%@",oauthHeader];
	NSLog(@"OAuthHeader ---- \n%@",oauthHeader);
#endif
	// Authorization header is set
    [request setValue:oauthHeader forHTTPHeaderField:@"Authorization"];	
	
	// Setting the request for google latitude service
	if (_sessionType == QBGoogleLatitudeSession) {
		
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];		
		NSString * postBody = @"scope=https://www.googleapis.com/auth/latitude&xoauth_displayname=shareThoughts";
		
		NSData *bodyData = [postBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		[request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
		[request setHTTPBody:bodyData];
	}
	
	//All set and establishing connection to the server for request token
	NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
	[param release];
	[connection autorelease];
	
}

/*
 * The view for user authenication is generated.
 *
 */

- (void)launchWebAuthentication {
	
	//Authenication URL generation
	
	NSString * URLString = nil;
	
	
	switch (_sessionType) {
		case QBFaceBookSession:
		{
			[self deleteFacebookCookies];
			if (_sessionProxy) {
				
				URLString = [NSString stringWithFormat:@"http://www.facebook.com/login.php?api_key=%@&ext_perms=publish_stream&next=%@&connect_display=touch&fbconnect=1",[_consumerKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[REDIRECT_URI stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				
			} else {
				if (_permissions) {
					URLString = [NSString stringWithFormat:@"%@authorize?client_id=%@&redirect_uri=%@&scope=%@&type=user_agent&display=touch",_baseURL,[_clientID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[REDIRECT_URI stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[self generateExtendPermissionString]];
				} else {
					URLString = [NSString stringWithFormat:@"%@authorize?client_id=%@&redirect_uri=%@&type=user_agent&display=touch",_baseURL,[_clientID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[REDIRECT_URI stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
					
				}
			}					
			
		}
			break;
		case QBTwitterSession:
		{
			URLString = [NSString stringWithFormat:@"%@authorize?oauth_token=%@",_baseURL,[_requestToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		}
			break;
		case QBGoogleLatitudeSession:
		{
			URLString = [NSString stringWithFormat:@"%@OAuthAuthorizeToken?oauth_token=%@&btmpl=mobile",_baseURL,[_requestToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		}
			break;
		case QBFourSquareSession:
		{
			URLString = [NSString stringWithFormat:@"%@authorize?oauth_token=%@",_baseURL,[_requestToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		}
			break;
		case QBLinkedInSession:
		{
			[self deleteLinkedInCookies];
			URLString = [NSString stringWithFormat:@"https://www.linkedin.com/uas/oauth/authorize?oauth_token=%@",[_requestToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		}
			break;
	
			
		default:
			break;
	}
	
	//Web request creation
	
	NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
	
	if ([self.delegate respondsToSelector:@selector(webViewWillAppear)]) {
		[self.delegate webViewWillAppear];
	}
	//Webrequest is loaded in webView
	[_qbAuthView.qbWebView loadRequest:request];
	
	if ([self.delegate respondsToSelector:@selector(webViewDidLoadForAuthentication:)]) {
		
		[self.delegate webViewDidLoadForAuthentication:_qbAuthView ];
		
	}	
	
}

/*
 * To generate access token with the obtained request token and request token secret.
 */

- (void)getAccessToken {
	
	NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
	//Generating time Stamp
	NSString * timestamp = [NSString stringWithFormat:@"%d", time(NULL)];
	[param setObject:timestamp forKey:@"oauth_timestamp"];
	
	//Generating nonce
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    NSMakeCollectable(theUUID);
	
    NSString * nonce = (NSString *)string;
	[param setObject:nonce forKey:@"oauth_nonce"];
	CFRelease(theUUID);
	CFRelease(string);
	
	//Setting signature method and OAuth Version
	[param setObject:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
	[param setObject:@"1.0" forKey:@"oauth_version"];
	
	//Setting oauth_verfier for google latitude service
	if (_sessionType == QBGoogleLatitudeSession||_sessionType==QBLinkedInSession) {
		[param setObject:[_authVerifier encodedURLParameterString] forKey:@"oauth_verifier"];
	}
	
	[param setObject:[_consumerKey encodedURLParameterString] forKey:@"oauth_consumer_key"];
	[param setObject:[_requestToken encodedURLParameterString] forKey:@"oauth_token"];
	
	//Signature geration
	NSArray * sortedKeys = [[param allKeys] sortedArrayUsingSelector:@selector(compare:)];	
	NSMutableArray * array = [[NSMutableArray alloc] init];
	
	for (NSString * key in sortedKeys) {
		
		[array addObject:[NSString stringWithFormat:@"%@=%@",key,[param objectForKey:key]]];
		
	}
	
	NSString * combinedString = [array componentsJoinedByString:@"&"];
	
	[array release];
	
	
	//Request URL generation for access token
	NSString * requestURL = nil;
	
	switch (_sessionType) {
		case QBTwitterSession:
			requestURL = [NSString stringWithFormat:@"%@access_token",_baseURL];
			break;
		case QBGoogleLatitudeSession:
			requestURL = [NSString stringWithFormat:@"%@OAuthGetAccessToken",_baseURL];
			break;
		case QBFourSquareSession:
			requestURL = [NSString stringWithFormat:@"%@access_token",_baseURL];
			break;
		case QBLinkedInSession:
			requestURL = [NSString stringWithFormat:@"%@accessToken",_baseURL];
			break;			
		default:
			break;
	}
	//Base string generation for creating signature
	NSString * baseString = [NSString stringWithFormat:@"POST&%@&%@",[requestURL encodedURLParameterString],[combinedString encodedURLParameterString]];
	//Sign key generation for creating signature
	NSString * signKey = [NSString stringWithFormat:@"%@&%@",[_consumerSecret encodedURLParameterString],[_requestTokenSecret encodedURLParameterString]];
#if DEBUG
	//[ULogger logDebug:@"Base String : %@",baseString];
	NSLog(@"Base String : %@",baseString);
#endif	
	
	//Signing process
	NSData *secretData = [signKey dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [baseString dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
    hmac_sha1((unsigned char *)[clearTextData bytes], [clearTextData length], (unsigned char *)[secretData bytes], [secretData length], result);
    
    //Base64 Encoding
    
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(result, 20, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    
	//Encode signature genearation
    NSString *base64EncodedResult = [[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding] autorelease];
   	[param setObject:base64EncodedResult forKey:@"oauth_signature"];
	
	//Generating request for Access token
	
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
	
	[request setHTTPMethod:@"POST"];
	//Setting google latitude
	if (_sessionType == QBGoogleLatitudeSession) {
		
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];		
		
	}
	
	NSMutableArray *chunks = [[NSMutableArray alloc] init];
	
	//sortedKeys = [[param allKeys] sortedArrayUsingSelector:@selector(compare:)];	
	
	//for (NSString * key in sortedKeys) {
	if (_sessionType == QBGoogleLatitudeSession||_sessionType == QBLinkedInSession) {
		[chunks addObject:[NSString stringWithFormat:@"oauth_verifier=\"%@\"",[_authVerifier encodedURLParameterString]]];
	}
	[chunks addObject:[NSString stringWithFormat:@"oauth_nonce=\"%@\"",[[param objectForKey:@"oauth_nonce"] encodedURLParameterString]]];
	//[chunks addObject:[NSString stringWithFormat:@"oauth_callback=\"%@\"",[[param objectForKey:@"oauth_callback"] encodedURLParameterString]]];
	[chunks addObject:[NSString stringWithFormat:@"oauth_signature_method=\"%@\"",[[param objectForKey:@"oauth_signature_method"] encodedURLParameterString]]];
	[chunks addObject:[NSString stringWithFormat:@"oauth_timestamp=\"%@\"",[[param objectForKey:@"oauth_timestamp"] encodedURLParameterString]]];
	[chunks addObject:[NSString stringWithFormat:@"oauth_consumer_key=\"%@\"",[[param objectForKey:@"oauth_consumer_key"] encodedURLParameterString]]];
	[chunks addObject:[NSString stringWithFormat:@"oauth_token=\"%@\"",[_requestToken encodedURLParameterString]]];
	[chunks addObject:[NSString stringWithFormat:@"oauth_signature=\"%@\"",[[param objectForKey:@"oauth_signature"] encodedURLParameterString]]];
	[chunks addObject:[NSString stringWithFormat:@"oauth_version=\"%@\"",[[param objectForKey:@"oauth_version"] encodedURLParameterString]]];
	
	//}
	
	NSString *oauthHeader = [NSString stringWithFormat:@"OAuth %@", [chunks componentsJoinedByString:@", "]];
	[chunks release];
	
	//NSLog(@"OAuthHeader ---- \n%@",oauthHeader);
	
    [request setValue:oauthHeader forHTTPHeaderField:@"Authorization"];	
	
	//NSURLConnection  * connection = [NSURLConnection connectionWithRequest:request delegate:self];
	//	[connection start];
	NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
	[param release];
	[connection autorelease];
	
	
	
}

- (NSString *)getCurrentAccessToken {
	
	return _accessToken;
}

- (NSString *)getCurrentAccessTokenSecret{
	return _accessTokenSecret;
}

- (void)clearCurrentAccessToken {
	if (_accessToken) {
		[_accessToken release];
		_accessToken = nil;
	}
}

- (void)deleteFacebookCookies {
	NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray* facebookCookies = [cookies cookiesForURL:
								[NSURL URLWithString:@"http://graph.facebook.com"]];
	for (NSHTTPCookie* cookie in facebookCookies) {
		[cookies deleteCookie:cookie];
	}
}

- (void)deleteLinkedInCookies {
	NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray* facebookCookies = [cookies cookiesForURL:
								[NSURL URLWithString:@"https://www.linkedin.com"]];
	for (NSHTTPCookie* cookie in facebookCookies) {
		[cookies deleteCookie:cookie];
	}
}

- (void)startSession {
	
	
	
	//self.center = center;
	
	if (_qbAuthView==nil) {
		CGRect frame = [UIScreen mainScreen].applicationFrame;
		CGPoint center ;
		
		//CGFloat scale_factor = 1.0f;
		//if (FBIsDeviceIPad()) {
		// On the iPad the dialog's dimensions should only be 60% of the screen's
		CGFloat	scale_factor = 0.99f;
		//}
		
		CGFloat width = floor(scale_factor * frame.size.width) ;
		CGFloat height = floor(scale_factor * frame.size.height) ;
		CGRect targetFrame;
		
		UIInterfaceOrientation _orientation = [UIApplication sharedApplication].statusBarOrientation;
		if (UIInterfaceOrientationIsLandscape(_orientation)) {
			targetFrame = CGRectMake(0, 0, height, width);
			center = CGPointMake(frame.size.height/2, frame.size.width/2);
		} else {
			targetFrame = CGRectMake(0, 0, width, height);
			center = CGPointMake(frame.size.width/2, frame.size.height/2);
		}
		_qbAuthView = [[QBAuthenticationView alloc] initWithFrame:targetFrame];
		_qbAuthView.qbWebView.delegate = self;
		_qbAuthView.clipsToBounds = YES;
		_qbAuthView.center = center;
		_qbAuthView.delegate = self;
		_qbAuthView.activityIndicator.center = CGPointMake(_qbAuthView.frame.size.width/2.0, _qbAuthView.frame.size.height/2.0);
	}
	
	//_qbAuthView.center = CGPointMake(<#CGFloat x#>, <#CGFloat y#>);
	
	if ([self.delegate respondsToSelector:@selector(sessionDidStarted)]) {
		[self.delegate sessionDidStarted];
	}
	
	switch (_sessionType) {
		case QBFaceBookSession:
			[_qbAuthView setBarColor:[UIColor faceBookColor]];
			[self launchWebAuthentication];
			break;
		case QBTwitterSession:
			[_qbAuthView setBarColor:[UIColor twitterColor]];
			[self getRequestToken];
			break;
		case QBGoogleLatitudeSession:
			[_qbAuthView setBarColor:[UIColor googleColor]];
			[self getRequestToken];
			break;
		case QBFourSquareSession:
			[_qbAuthView setBarColor:[UIColor foursquareColor]];
			[self getRequestToken];
			break;
		case QBLinkedInSession:
			[_qbAuthView setBarColor:[UIColor linkedInColor]];
			[self getRequestToken];
			break;

		default:
			break;
	}
}

- (void)getSessionFromProxy {
	
	NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?auth_token=%@&generate_session_secret=1",_sessionProxy,_accessToken]];
	NSURLRequest * request = [NSURLRequest requestWithURL:url];
	NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	[connection autorelease];
}

/* This module can be used to tweet to twitter*/
- (void)postData:(NSDictionary *)data {
	
	
	NSString * requestURL = nil;
	NSMutableDictionary * param = nil;
	
	switch (_sessionType) {
		case QBTwitterSession:
			requestURL = @"https://api.twitter.com/1/statuses/update.json";
			break;
		case QBFaceBookSession:
			requestURL = @"https://graph.facebook.com/me/feed";
			break;
		case QBLinkedInSession:
			requestURL = @"https://api.linkedin.com/v1/people/~/shares";
			break;
		default:
			break;
	}
	
	if (_sessionType!=QBFaceBookSession) {
		param = [[NSMutableDictionary alloc] init];
		
		NSString * timestamp = [NSString stringWithFormat:@"%d", time(NULL)];
		
		[param setObject:timestamp forKey:@"oauth_timestamp"];
		
		
		CFUUIDRef theUUID = CFUUIDCreate(NULL);
		CFStringRef string = CFUUIDCreateString(NULL, theUUID);
		NSMakeCollectable(theUUID);
		
		NSString * nonce = (NSString *)string;
		
		//NSLog(@"\n\nNonce value : %@\n\n",string);
		//[ULogger logDebug:@"\n\nNonce value : %@\n\n",string];
		[param setObject:nonce forKey:@"oauth_nonce"];
		CFRelease(theUUID);
		CFRelease(string);
		[param setObject:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
		[param setObject:@"1.0" forKey:@"oauth_version"];
		[param setObject:[_consumerKey encodedURLParameterString] forKey:@"oauth_consumer_key"];
		[param setObject:[[data objectForKey:@"access_token"] encodedURLParameterString] forKey:@"oauth_token"];
		
		if (_sessionType != QBLinkedInSession) {
			[param setObject:[[data objectForKey:@"message"] encodedURLParameterString]  forKey:@"status"];
			
		}
		
		NSArray * sortedKeys = [[param allKeys] sortedArrayUsingSelector:@selector(compare:)];	
		NSMutableArray * array = [[NSMutableArray alloc] init];
		
		for (NSString * key in sortedKeys) {
			[array addObject:[NSString stringWithFormat:@"%@=%@",key,[param objectForKey:key]]];
		}
		
		NSString * combinedString = [array componentsJoinedByString:@"&"];
		
		[array release];
		
		NSString * baseString = [NSString stringWithFormat:@"POST&%@&%@",[requestURL encodedURLParameterString],[combinedString encodedURLParameterString]];
		
		NSString * signKey = [NSString stringWithFormat:@"%@&%@",[_consumerSecret encodedURLParameterString],[[data objectForKey:@"access_secret"] encodedURLParameterString]];
#if DEBUG
		//[ULogger logDebug:@"Base String : %@",baseString];
		NSLog(@"Base String : %@",baseString);
#endif	
		
		
		NSData *secretData = [signKey dataUsingEncoding:NSUTF8StringEncoding];
		NSData *clearTextData = [baseString dataUsingEncoding:NSUTF8StringEncoding];
		unsigned char result[20];
		hmac_sha1((unsigned char *)[clearTextData bytes], [clearTextData length], (unsigned char *)[secretData bytes], [secretData length], result);
		
		//Base64 Encoding
		
		char base64Result[32];
		size_t theResultLength = 32;
		Base64EncodeData(result, 20, base64Result, &theResultLength);
		NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
		
		NSString *base64EncodedResult = [[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding] autorelease];
		
		
		[param setObject:base64EncodedResult forKey:@"oauth_signature"];
	}
	
	
	//Setting request
	
	
	
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
	
	[request setHTTPMethod:@"POST"];
	
	//if (_sessionType == QBGoogleLatitudeSession) {
	if (_sessionType == QBLinkedInSession) {
		[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
	} else {
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	}

	NSString * postBody = nil;
	if (_sessionType == QBLinkedInSession) {
	//	postBody = @"body=Test";

		postBody = [NSString stringWithFormat:@"%@",[data objectForKey:@"message"]];
	} else if (_sessionType == QBTwitterSession) {
		postBody = [NSString stringWithFormat:@"status=%@",[[data objectForKey:@"message"] encodedURLString]];

	} else if (_sessionType == QBFaceBookSession) {
		postBody = [self preparePostBodyFromData:data];	
	} 	
	
	NSData *bodyData = [postBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	[request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody:bodyData];
	
	
	if (_sessionType!=QBFaceBookSession) {
		NSMutableArray *chunks = [[NSMutableArray alloc] init];
		
		
		[chunks addObject:[NSString stringWithFormat:@"oauth_nonce=\"%@\"",[[param objectForKey:@"oauth_nonce"] encodedURLParameterString]]];
		[chunks addObject:[NSString stringWithFormat:@"oauth_signature_method=\"%@\"",[[param objectForKey:@"oauth_signature_method"] encodedURLParameterString]]];
		[chunks addObject:[NSString stringWithFormat:@"oauth_timestamp=\"%@\"",[[param objectForKey:@"oauth_timestamp"] encodedURLParameterString]]];
		[chunks addObject:[NSString stringWithFormat:@"oauth_consumer_key=\"%@\"",[[param objectForKey:@"oauth_consumer_key"] encodedURLParameterString]]];
		[chunks addObject:[NSString stringWithFormat:@"oauth_token=\"%@\"",[[data objectForKey:@"access_token"] encodedURLParameterString]]];
		[chunks addObject:[NSString stringWithFormat:@"oauth_signature=\"%@\"",[[param objectForKey:@"oauth_signature"] encodedURLParameterString]]];
		[chunks addObject:[NSString stringWithFormat:@"oauth_version=\"%@\"",[[param objectForKey:@"oauth_version"] encodedURLParameterString]]];
		
		
		
		NSString *oauthHeader = [NSString stringWithFormat:@"OAuth %@", [chunks componentsJoinedByString:@", "]];
		[chunks release];
		
		NSLog(@"OAuthHeader ---- \n%@",oauthHeader);
		
		[request setValue:oauthHeader forHTTPHeaderField:@"Authorization"];
	}
	
	NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	_activePostConnection = connection;
	[param release];
	[connection autorelease];
}

-(NSString *)preparePostBodyFromData:(NSDictionary *)data {
	
	NSArray * allkeys =  [data allKeys];
	NSMutableString * preparedString = [[NSMutableString alloc] initWithString:@""];
	NSInteger i = [allkeys count];
	for (NSString * key in allkeys ) {
		i--;
		if ([[data objectForKey:key] length]) {
			[preparedString appendFormat:@"%@=%@",key,[[data objectForKey:key] encodedURLParameterString]];
			if (i!=0) {
				[preparedString appendString:@"&"];
			}
			
		}
		
	}
	return (NSString *)[preparedString autorelease];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
	
	NSString * urlString  = [request.URL absoluteString];
#if DEBUG
	//[ULogger logDebug:@"URL string :%@",urlString];
	NSLog(@"URL string :%@",urlString);
#endif		
	//
	
	if ([urlString isEqualToString:@"fbconnect:cancel"]) {
		
		if ([self.delegate respondsToSelector:@selector(webViewWillDisappear)]) {
			[self.delegate webViewWillDisappear];
		}
		
		[_qbAuthView removeFromSuperview];
		return NO;
	}
	
	//NSString * scheme = [request.URL scheme];
	
	
	NSRange oauth_problem_range = [urlString rangeOfString:@"oauth_problem="];
	
	if(oauth_problem_range.length > 0){
		
		int from_index = oauth_problem_range.location + oauth_problem_range.length;
		NSString *oauth_problem_reason = [urlString substringFromIndex:from_index];
		
		NSLog(@"Oauth Error : %@",oauth_problem_reason);
		
		[_requestToken release];
		_requestToken = nil;
		[_requestTokenSecret release];
		_requestTokenSecret = nil;
		
		if ([self.delegate respondsToSelector:@selector(webViewWillDisappear)]) {
			[self.delegate webViewWillDisappear];
		}
		
		[_qbAuthView removeFromSuperview];
		return NO;
	}
	
	
	NSRange oauth_verifier_range = [urlString rangeOfString:@"oauth_verifier="];
	
	if (oauth_verifier_range.length > 0) {
		[_qbAuthView removeFromSuperview];
		
		int from_index = oauth_verifier_range.location + oauth_verifier_range.length;
		NSString *auth_verifier = [urlString substringFromIndex:from_index];
#if DEBUG
		[ULogger logDebug:@"Auth_verifier:  %@", auth_verifier];
#endif	

		_authVerifier = [[[[auth_verifier componentsSeparatedByString:@"&"]objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ] retain];
		
		
		[self getAccessToken];
		return NO;
	}
	
	NSRange done_status_range = [urlString rangeOfString:[NSString stringWithFormat:@"%@?done=",_callbackURI]];
	
	if (done_status_range.length>0) {
		[_qbAuthView removeFromSuperview];
		[_requestToken release];
		_requestToken = nil;
		[_requestTokenSecret release];
		_requestTokenSecret = nil;
		return NO;
	}
	
	NSRange request_token_range = [urlString rangeOfString:[NSString stringWithFormat:@"%@?oauth_token=",_callbackURI]];
	
	if (request_token_range.length > 0) {
		[_qbAuthView removeFromSuperview];
		
		[self getAccessToken];
		return NO;
	}
	
	NSRange session_param_range = [urlString rangeOfString:@"&session="];
	
	if (session_param_range.length > 0 ) {
		int from_index = session_param_range.location + session_param_range.length;
		NSString *session_param = [urlString substringFromIndex:from_index];
		
		NSString * session_data = [session_param stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		CJSONDeserializer * deserializer = [CJSONDeserializer deserializer];
		NSError * error = nil;
		_session = (NSMutableDictionary *)[[deserializer deserialize:[session_data dataUsingEncoding:NSUTF32LittleEndianStringEncoding] error:&error] retain];
		
		if (error) {
			[ULogger logError:@"Error %@",[error description]];
		}
		
	}
	
	NSRange access_token_range = [urlString rangeOfString:@"access_token="];
	
	//coolio, we have a token, now let's parse it out....
	if (access_token_range.length > 0) {
		
		//we want everything after the 'access_token=' thus the position where it starts + it's length
		int from_index = access_token_range.location + access_token_range.length;
		NSString *access_token = [urlString substringFromIndex:from_index];
		
		_accessToken = [[[access_token componentsSeparatedByString:@"&"]objectAtIndex:0] retain];
		
		if ([self.delegate respondsToSelector:@selector(webViewWillDisappear)]) {
			[self.delegate webViewWillDisappear];
		}
		
		[_qbAuthView removeFromSuperview];
		
		if (_session) {
			if ([self.delegate respondsToSelector:@selector(sessionDidReceivedAccessToken:withSessionData:)]) {
				[self.delegate sessionDidReceivedAccessToken:_accessToken withSessionData:(NSDictionary *)_session ];
			}
		}
		
		if (_accessTokenSecret) {
			if ([self.delegate respondsToSelector:@selector(sessionDidReceivedAccessToken:withTokenSecret:)]) {
				[self.delegate sessionDidReceivedAccessToken:_accessToken withTokenSecret:_accessTokenSecret];
			}
		}		
		
		if (_sessionProxy) {
			[self getSessionFromProxy];
		}
		return NO;
	}
	
	NSRange auth_token_range = [urlString rangeOfString:@"?auth_token="];
	
	//coolio, we have a token, now let's parse it out....
	if (auth_token_range.length > 0) {
		
		//we want everything after the 'access_token=' thus the position where it starts + it's length
		int from_index = auth_token_range.location + auth_token_range.length;
		NSString *access_token = [urlString substringFromIndex:from_index];
		
		
		
		_accessToken = [[[access_token componentsSeparatedByString:@"&"]objectAtIndex:0] retain];
		
		if ([self.delegate respondsToSelector:@selector(webViewWillDisappear)]) {
			[self.delegate webViewWillDisappear];
		}
		
		[_qbAuthView removeFromSuperview];
		
		if (_session) {
			if ([self.delegate respondsToSelector:@selector(sessionDidReceivedAccessToken:withSessionData:)]) {
				[self.delegate sessionDidReceivedAccessToken:_accessToken withSessionData:(NSDictionary *)_session ];
			}
		}
		
		if (_accessTokenSecret) {
			if ([self.delegate respondsToSelector:@selector(sessionDidReceivedAccessToken:withTokenSecret:)]) {
				[self.delegate sessionDidReceivedAccessToken:_accessToken withTokenSecret:_accessTokenSecret];
			}
		}
		
		if (_sessionProxy) {
			[self getSessionFromProxy];
		}
		
		return NO;
	}
	
	NSRange errorRange = [urlString rangeOfString:@"error_reason=user_denied"];
	if (errorRange.length > 0) {
		
		if ([self.delegate respondsToSelector:@selector(userClosedAuthView)]) {
			[self.delegate userClosedAuthView];
		}
		
		if ([self.delegate respondsToSelector:@selector(webViewWillDisappear)]) {
			[self.delegate webViewWillDisappear];
		}
		
		[_qbAuthView removeFromSuperview];
		return NO;
	}
	
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		
		[[UIApplication sharedApplication] openURL:request.URL];
		return NO;
	}
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	
	if (_qbAuthView.activityIndicator.hidden) {
		[_qbAuthView.activityIndicator startAnimating];
	}	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	
	if (_qbAuthView.activityIndicator.hidden==NO) {
		[_qbAuthView.activityIndicator stopAnimating];
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	
	if (_qbAuthView.activityIndicator.hidden==NO) {
		[_qbAuthView.activityIndicator stopAnimating];
	}
	if([self.delegate respondsToSelector:@selector(sessionDidFailedWithError:)]){
		[self.delegate sessionDidFailedWithError:error];
	}
	
	if ([self.delegate respondsToSelector:@selector(webViewWillDisappear)]) {
		[self.delegate webViewWillDisappear];
	}
	[_qbAuthView removeFromSuperview];
	
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
	
	[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
}


- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
	
}



- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	
	NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
	
#if DEBUG	
	[ULogger logDebug:@"Status Code :%d", [httpResponse statusCode]];
#endif
	
	if (_sessionType == QBLinkedInSession && [httpResponse statusCode]==201&&_activePostConnection==connection) {
		//Success in posting
		if (self.delegate) {
			if ([self.delegate respondsToSelector:@selector(dataPostedSuccessfully:)]) {
				[self.delegate dataPostedSuccessfully:self];
			}
		}
	} else if(_activePostConnection==connection&&_sessionType == QBLinkedInSession){
		if (self.delegate) {
			if ([self.delegate respondsToSelector:@selector(dataPostFailed:withError:)]) {
				[self.delegate dataPostFailed:self withError:[NSError errorWithDomain:[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]] code:[httpResponse statusCode] userInfo:nil]];
			}
		}
	}

}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	NSString * response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
#if DEBUG
	[ULogger logDebug:@" response %@",response];
#endif
	
	NSRange request_token_range = [response rangeOfString:@"oauth_token="];
	if (request_token_range.length > 0) {
		
		NSArray * parts = [response componentsSeparatedByString:@"&"];
		for (NSString * part in parts) {
			NSArray * params = [part componentsSeparatedByString:@"="];
			if ([params count]>1) {
				NSString * value = [params objectAtIndex:1];
				NSString * key = [params objectAtIndex:0];
				if ([key isEqualToString:@"oauth_token"]) {
					if (_requestToken==nil) {
						_requestToken = [[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] retain];
					} else {
						_accessToken = [[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] retain];
					}					
				}
				if ([key isEqualToString:@"oauth_token_secret"]) {
					
					if ([_requestTokenSecret length]==0) {
						_requestTokenSecret = [[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] retain];
					} else {
						_accessTokenSecret = [[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] retain];
					}
				}
				if ([key isEqualToString:@"screen_name"]) {
					[ULogger logDebug:@"Screen Name %@",[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				}
				if ([key isEqualToString:@"user_id"]) {
					[ULogger logDebug:@"User ID : %@",[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				}
			}
		}
		
		if (_requestToken!=nil&&[_requestTokenSecret length]&&[_accessTokenSecret length]==0) {
			
			if ([self.delegate respondsToSelector:@selector(webViewWillAppear)]) {
				[self.delegate webViewWillAppear];
			}			
			[self launchWebAuthentication];
			
		} else if (_accessToken!=nil&&[_accessTokenSecret length]){
			
			if ([self.delegate respondsToSelector:@selector(webViewWillDisappear)]) {
				[self.delegate webViewWillDisappear];
			}
			
			[_qbAuthView removeFromSuperview];
			
			if ([self.delegate respondsToSelector:@selector(sessionDidReceivedAccessToken:withTokenSecret:)]) {
				[self.delegate sessionDidReceivedAccessToken:_accessToken withTokenSecret:_accessTokenSecret];
			}
			
		}
		
	}
	
	if (_sessionProxy) {
		//TODO XML Parsing
		
		CXMLDocument *xmlParser = [[[CXMLDocument alloc] 
									initWithXMLString:response options:0 error:nil] autorelease];
		

		NSArray *parsedData = [xmlParser children];
		
		
		
		for (CXMLElement * element in parsedData) {
			
			[ULogger logDebug:@"%@",element];
			if ([[element elementsForName:@"exception"] count]) {
				[ULogger logDebug:@"Error : %@",[[[element elementsForName:@"exception"]objectAtIndex:0]stringValue]];
				break;
			} else {
				NSArray * keys =  [NSArray arrayWithObjects:@"session_key",@"uid",@"expires",nil];
				_session = [[NSMutableDictionary alloc] init];
				for (NSString *key in keys) {
					if ([[element elementsForName:key] count]) {
						[_session setObject:[[[element elementsForName:key]objectAtIndex:0]stringValue] forKey:key];
					}
				}
				if ([[_session allKeys] count]) {
					if ([self.delegate respondsToSelector:@selector(sessionDidReceivedAccessToken:withSessionData:)]) {
						[self.delegate sessionDidReceivedAccessToken:_accessToken withSessionData:(NSDictionary *)_session ];
					}
				} else {
					[_session release];
					_session = nil;
				}
				
			}
			
		}		
	}
	
	if (_sessionType==QBFaceBookSession&&_sessionProxy==nil&&_activePostConnection==connection) {
		CJSONDeserializer * jsonParser = [CJSONDeserializer deserializer];
		NSError * error = nil;
		NSDictionary * parsedData = [jsonParser deserializeAsDictionary:[response dataUsingEncoding:NSUTF8StringEncoding] error:&error];
		if (parsedData==nil) {
			if (self.delegate) {
				if ([self.delegate respondsToSelector:@selector(dataPostFailed:withError:)]) {
					[self.delegate dataPostFailed:self withError:error];
				}
			}
		} else {
			NSLog(@"%@",parsedData);
			if ([parsedData objectForKey:@"id"]) {
				if (self.delegate) {
					if ([self.delegate respondsToSelector:@selector(dataPostedSuccessfully:)]) {
						[self.delegate dataPostedSuccessfully:self];
					}
				}
				
			} else {
				if (self.delegate) {
					if ([self.delegate respondsToSelector:@selector(dataPostFailed:withError:)]) {
						[self.delegate dataPostFailed:self withError:[NSError errorWithDomain:NSMachErrorDomain code:401 userInfo:parsedData]];
					}
				}
			}

		}
		
	} else if(_sessionType==QBTwitterSession&&_activePostConnection==connection){
        CJSONDeserializer * jsonParser = [CJSONDeserializer deserializer];
		NSError * error = nil;
		NSDictionary * parsedData = [jsonParser deserializeAsDictionary:[response dataUsingEncoding:NSUTF8StringEncoding] error:&error];
		if (parsedData==nil) {
			if (self.delegate) {
				if ([self.delegate respondsToSelector:@selector(dataPostFailed:withError:)]) {
					[self.delegate dataPostFailed:self withError:error];
				}
			}
		} else {
			
			if ([parsedData objectForKey:@"id"]) {
				if (self.delegate) {
					if ([self.delegate respondsToSelector:@selector(dataPostedSuccessfully:)]) {
						[self.delegate dataPostedSuccessfully:self];
					}
				}
				
			} else {
				if (self.delegate) {
					if ([self.delegate respondsToSelector:@selector(dataPostFailed:withError:)]) {
						[self.delegate dataPostFailed:self withError:[NSError errorWithDomain:NSMachErrorDomain code:401 userInfo:parsedData]];
					}
				}
			}
            
		}
    }
	
    NSRange oauth_problem_range = [response rangeOfString:@"oauth_problem="];
	if (oauth_problem_range.length > 0) {
        
        NSArray * components = [response componentsSeparatedByString:@"&"];
        
        NSString * errorReason = nil;
        
        for(NSString * component in components){
            
            NSArray * parts = [component componentsSeparatedByString:@"="];
            if([[parts objectAtIndex:0] isEqualToString:@"oauth_problem"]){
            
                errorReason = [parts objectAtIndex:1];
                break;
            }
            
        }
        
        if(errorReason){
        
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(sessionDidFailedWithError:)]) {
                    
                    [self.delegate sessionDidFailedWithError:[NSError errorWithDomain:NSPOSIXErrorDomain code:400 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorReason,@"oauth_problem",nil]]];
                }
            }
        }
        
    }
    
    
	[response release];
}


- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	if (_activePostConnection==connection) {
		_activePostConnection = nil;
	}
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	if([self.delegate respondsToSelector:@selector(sessionDidFailedWithError:)]){
		[self.delegate sessionDidFailedWithError:error];
	}	
}


- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
	return cachedResponse;
}

- (void) dealloc {
	
	if (_qbAuthView) {
		
		_qbAuthView.qbWebView.delegate = nil;
		[_qbAuthView release];
	}
	[self releaseIfNeeded:_permissions];
	[self releaseIfNeeded:_session];
	[self releaseIfNeeded:_consumerKey];
	[self releaseIfNeeded:_clientID];
	[self releaseIfNeeded:_callbackURI];
	[self releaseIfNeeded:_consumerSecret];
	[self releaseIfNeeded:_sessionProxy];
	[super dealloc];
}

#pragma mark 
#pragma mark QBAuthenticationView Delegate Methods

- (void)authViewCloseButtonPressed:(id)sender {
	
	if ([self.delegate respondsToSelector:@selector(userClosedAuthView)]) {
		[self.delegate userClosedAuthView];
	}
	
	[_qbAuthView removeFromSuperview];
	if (_sessionType==QBTwitterSession||_sessionType==QBGoogleLatitudeSession||_sessionType==QBLinkedInSession) {
		[self releaseIfNeeded:_requestToken];
		_requestToken = nil;
		[self releaseIfNeeded:_requestTokenSecret];
		_requestTokenSecret = nil;
	}
}


@end
