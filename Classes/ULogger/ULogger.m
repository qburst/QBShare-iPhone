//
//  ULogger.m
//  mrsmcommerce
//
//  Created by MIDHUN RAJ.T.S on 26/03/10.
//  Copyright 2010 Mobile Retail Solutions. All rights reserved.
//

#import "ULogger.h"


@implementation ULogger

static ULoggerLevel currentLoggerLevel = ULoggerLevelNONE;


+ (void) log:(NSString *) logMessage atLevel:(ULoggerLevel) level {
	
	NSString *levelString;
	
	if(level > currentLoggerLevel) return;
		
	switch (level) {
		case ULoggerLevelCRITICAL:
			levelString = @" CRITICAL : ";
			break;
		case ULoggerLevelERROR:
			levelString = @" ERROR : ";			
			break;
		case ULoggerLevelWARNING:
			levelString = @" WARNING : ";
			break;
		case ULoggerLevelINFORMATION:
			levelString = @" INFORMATION : ";
			break;
		case ULoggerLevelDEBUG:
			levelString = @" DEBUG : ";
			break;
		default:
			return; // If ULoggerLevelNONE or any unknown level, do not log.
	}
	
	NSLog(@"%@%@",levelString , logMessage);
	
}

+ (void) log:(NSString *) format, ... {
	va_list argumentList;
	va_start(argumentList, format); 
	NSString * message = [[NSString alloc] initWithFormat:format arguments:argumentList];
	[self log:message atLevel:ULoggerLevelDEBUG];
	va_end(argumentList);
	[message release];
}

+ (void) logCritical:(NSString *) format, ... {
	va_list argumentList;
	va_start(argumentList, format); 
	NSString * message = [[NSString alloc] initWithFormat:format arguments:argumentList];
	[self log:message atLevel:ULoggerLevelCRITICAL];
	va_end(argumentList);
	[message release];
}

+ (void) logError:(NSString *) format, ... {
	va_list argumentList;
	va_start(argumentList, format); 
	NSString * message = [[NSString alloc] initWithFormat:format arguments:argumentList];
	[self log:message atLevel:ULoggerLevelERROR];
	va_end(argumentList);
	[message release];
}

+ (void) logDebug:(NSString *) format, ... {
	va_list argumentList;
	va_start(argumentList, format); 
	NSString * message = [[NSString alloc] initWithFormat:format arguments:argumentList];
	[self log:message atLevel:ULoggerLevelDEBUG];
	va_end(argumentList);
	[message release];
}

+ (void) logWarning:(NSString *) format, ... {
	va_list argumentList;
	va_start(argumentList, format); 
	NSString * message = [[NSString alloc] initWithFormat:format arguments:argumentList];
	[self log:message atLevel:ULoggerLevelWARNING];
	va_end(argumentList);
	[message release];
}

+ (void) logInfo:(NSString *) format, ... {
	va_list argumentList;
	va_start(argumentList, format); 
	NSString * message = [[NSString alloc] initWithFormat:format arguments:argumentList];
	[self log:message atLevel:ULoggerLevelINFORMATION];
	va_end(argumentList);
	[message release];
}

@end
