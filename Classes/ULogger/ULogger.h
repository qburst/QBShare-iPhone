//
//  ULogger.h
//  mrsmcommerce
//
//  Created by MIDHUN RAJ.T.S on 26/03/10.
//  Copyright 2010 Mobile Retail Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef enum {
	ULoggerLevelNONE = 0,
	ULoggerLevelCRITICAL,
	ULoggerLevelERROR ,
	ULoggerLevelWARNING ,
	ULoggerLevelINFORMATION ,
	ULoggerLevelDEBUG ,
} ULoggerLevel;

@interface ULogger : NSObject {	
	
}


+ (void) log:(NSString *) logMessage atLevel:(ULoggerLevel) level;

+ (void) logCritical:(NSString *) format, ...;
+ (void) logError:(NSString *) format, ...;
+ (void) logDebug:(NSString *) format, ...;
+ (void) logWarning:(NSString *) format, ...;
+ (void) logInfo:(NSString *) format, ...;

+ (void) log:(NSString *) format, ...;

@end
