// Copyright 2011 StackMob, Inc
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <Foundation/Foundation.h>


@interface StackMobSession : NSObject {
	NSMutableArray* _delegates;
	NSString* _apiKey;
	NSString* _apiSecret;
	NSString* _appName;
	NSString* _subDomain;
	NSString* _domain;
	NSString* _sessionKey;
	NSDate* _expirationDate;
	NSMutableArray* _requestQueue;
	NSDate* _lastRequestTime;
	int _requestBurstCount;
	NSTimer* _requestTimer;
  NSNumber* _apiVersionNumber;
}

/**
 * The URL used for API HTTP requests.
 */
@property(nonatomic,readonly) NSString* apiURL;

/**
 * The URL used for secure API HTTP requests.
 */
@property(nonatomic,readonly) NSString* apiSecureURL;

/**
 * Your application's API key, as passed to the constructor.
 */
@property(nonatomic,readonly) NSString* apiKey;

/**
 * Your application's API secret, as passed to the constructor.
 */
@property(nonatomic,readonly) NSString* apiSecret;

/**
 * Your application's name, as passed to the constructor.
 */
@property(nonatomic,readonly) NSString* appName;

/**
 * Your application's subdomain, as passed to the constructor.
 */
@property(nonatomic,readonly) NSString* subDomain;

/**
 * Your application's domain name which defaults to stackmob.com or as passed to the constructor.
 */
@property(nonatomic,readonly) NSString* domain;

/**
 * The API version number.
 */
@property(nonatomic,readonly) NSNumber* apiVersionNumber;

/**
 * The current user's session key.
 */
@property(nonatomic,readonly) NSString* sessionKey;

/**
 * The expiration date of the session key.
 */
@property(nonatomic,readonly) NSDate* expirationDate;


/**
 * The globally shared session instance.
 */
+ (StackMobSession*)session;


/**
 * Constructs a session and stores it as the globally shared session instance.
 * Assumes using the default domain of stackmob.com
 *
 * @param key the application api key
 * @param secret the application secret api key
 * @param appName the application name
 * @param subDomain the application subDomain
 *
 */
+ (StackMobSession*)sessionForApplication:(NSString*)key secret:(NSString*)secret
						   appName:(NSString*)appName subDomain:(NSString*)subDomain apiVersionNumber:(NSNumber*)apiVersionNumber;

/**
 * Constructs a session and stores it as the globally shared session instance.
 * Assumes using the default domain of stackmob.com
 *
 * @param key the application api key
 * @param secret the application secret api key
 * @param appName the application name
 * @param subDomain the application subDomain
 * @param domain overwrites the stackmob.com domain
 *
 */
+ (StackMobSession*)sessionForApplication:(NSString*)key secret:(NSString*)secret
								  appName:(NSString*)appName 
								  subDomain:(NSString*)subDomain
					  			  domain:(NSString*)domain
          apiVersionNumber:(NSNumber*)apiVersionNumber;
/**
 * Constructs a session for an application.
 *
 * @param key the application api key
 * @param secret the application secret api key
 * @param appName the application name
 * @param subDomain the application subDomain
 * @param domain overwrites the stackmob.com domain
 */
- (StackMobSession*)initWithKey:(NSString*)key secret:(NSString*)secret appName:(NSString*)appName
					  subDomain:(NSString*)subDomain domain:(NSString*)domain apiVersionNumber:(NSNumber*)apiVersionNumber;

/**
 * Returns the formatted url for the passedMethod.
 *
 * @param name of the method to be called
 */
- (NSMutableString*)urlForMethod:(NSString*)method;

/**
 * Returns the formatted SSL url for the passedMethod.
 *
 * @param name of the method to be called
 */
- (NSMutableString*)secureURLForMethod:(NSString*)method;

@end
