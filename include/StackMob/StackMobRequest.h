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


#import "StackMobSession.h"

typedef enum {
	GET,
	POST,
	PUT,
	DELETE
} SMHttpVerb;

@interface StackMobRequest : NSObject
{
	NSURLConnection*		mConnection;
	id						mDelegate;
	SEL						mSelector;
	NSString*				mMethod;
	NSMutableDictionary*	mArguments;
	NSMutableData*			mConnectionData;
	NSDictionary*			mResult;
	BOOL					_requestFinished;
	NSString*				mHttpMethod;
	NSHTTPURLResponse*		mHttpResponse;
	
	@protected
		StackMobSession *session;
}

@property(readwrite, retain) id delegate;
@property(readwrite, copy) NSString* method;
@property(readwrite, copy) NSString* httpMethod;
@property(readwrite, retain) NSURLConnection* connection;
@property(readwrite, retain) NSDictionary* result;
@property(readonly) BOOL finished;
@property(readonly) NSHTTPURLResponse* httpResponse;
@property(readonly, getter=getStatusCode) NSInteger statusCode;
@property(readonly, getter=getURL) NSURL* url;

+ (StackMobRequest*)request;
+ (StackMobRequest*)requestForMethod:(NSString*)method;
+ (StackMobRequest*)requestForMethod:(NSString*)method withHttpVerb:(SMHttpVerb) httpVerb;
+ (StackMobRequest*)requestForMethod:(NSString*)method withArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb) httpVerb;

+ (StackMobRequest*)pushRequestWithArguments:(NSDictionary*)arguments withHttpVerb:(SMHttpVerb) httpVerb;

+ (NSString*)stringFromHttpVerb:(SMHttpVerb)httpVerb;

- (void)setArguments:(NSDictionary*)arguments;
- (void)setValue:(NSString*)value forArgument:(NSString*)argument;
- (void)setInteger:(NSUInteger)value forArgument:(NSString*)argument;
- (void)setBool:(BOOL)value forArgument:(NSString*)argument;

- (void)sendRequest;
- (void)cancel;

- (id)sendSynchronousRequestProvidingError:(NSError**)error;


@end

@protocol SMRequestDelegate <NSObject>

@optional
- (void)requestCompleted:(StackMobRequest *)request;

@end


