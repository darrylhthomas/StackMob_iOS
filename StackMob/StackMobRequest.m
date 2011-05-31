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

#import "StackMobRequest.h"
#import "Reachability.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "StackMobClientData.h"
#import "StackMobSession.h"

@implementation StackMobRequest;

@synthesize connection = mConnection;
@synthesize delegate = mDelegate;
@synthesize method = mMethod;
@synthesize result = mResult;
@synthesize httpMethod = mHttpMethod;
@synthesize httpResponse = mHttpResponse;
@synthesize finished = _requestFinished;


+ (StackMobRequest*)request	
{
	return [[[StackMobRequest alloc] init] autorelease];
}

+ (StackMobRequest*)requestForMethod:(NSString*)method
{
	return [StackMobRequest requestForMethod:method withHttpVerb:GET];
}	

+ (StackMobRequest*)requestForMethod:(NSString*)method withHttpVerb:(SMHttpVerb) httpVerb
{
	return [StackMobRequest requestForMethod:method withArguments:nil withHttpVerb:httpVerb];

}	

+ (StackMobRequest*)requestForMethod:(NSString*)method withArguments:(NSDictionary*)arguments  withHttpVerb:(SMHttpVerb) httpVerb
{
	StackMobRequest* request = [StackMobRequest request];
	request.method = method;
	request.httpMethod = [self stringFromHttpVerb:httpVerb];
	if (arguments != nil) {
		[request setArguments:arguments];
	}
	return request;
}

+ (NSString*)stringFromHttpVerb:(SMHttpVerb)httpVerb {
	switch (httpVerb) {
		case POST:
			return @"POST";	
		case PUT:
			return @"PUT";
		case DELETE:
			return @"DELETE";	
		default:
			return @"GET";
	}
}

- (NSURL*)getURL
{
	if (self.method == nil)
		return nil;
	NSMutableString *stringURL = [session urlForMethod:self.method];
	if ([[self httpMethod] isEqualToString: @"GET"] &&
		[mArguments count] > 0) {
		[stringURL appendString: @"?"];
		[stringURL appendString: [mArguments queryString]];
	}
	StackMobLog(@"%@", stringURL);
	return [NSURL URLWithString: stringURL];
}

- (NSInteger)getStatusCode
{
	return [mHttpResponse statusCode];
}


- (id)init	
{
	self = [super init];
	if (self == nil)
		return nil;
	self.delegate = nil;
	self.method = nil;
	self.result = nil;
	mArguments = [[NSMutableDictionary alloc] init];
	mConnectionData = [[NSMutableData alloc] init];
	mResult = nil;
	session = [StackMobSession session];
	return self;
}

- (void)dealloc
{
	if (kLogVersbose == YES)
		StackMobLog(@"StackMobRequest: dealloc");
	[self cancel];
	[mConnectionData release];
	[mConnection release];
	[mDelegate release];
	[mMethod release];
	[mResult release];
	[mHttpMethod release];
	[mHttpResponse release];
	[super dealloc];
	if (kLogVersbose == YES)
		StackMobLog(@"StackMobRequest: dealloc finished");
}

#pragma mark -

- (void)setArguments:(NSDictionary*)arguments
{
	[mArguments setDictionary:arguments];
}

- (void)setValue:(NSString*)value forArgument:(NSString*)argument
{
	[mArguments setValue:value forKey:argument];
}

- (void)setInteger:(NSUInteger)value forArgument:(NSString*)argument
{
	[mArguments setValue:[NSString stringWithFormat:@"%u", value] forKey:argument];
}

- (void)setBool:(BOOL)value forArgument:(NSString*)argument
{
	[mArguments setValue:(value ? @"true" : @"false") forKey:argument];
}


- (void)sendRequest
{
	_requestFinished = NO;

	if (kLogVersbose == YES) {
		StackMobLog(@"Sending Request: %@", self.method);
		StackMobLog(@"Request url: %@", self.url);
		StackMobLog(@"Request HTTP Method: %@", self.httpMethod);
	}
				
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:session.apiKey
														secret:session.apiSecret];
		
		//TODO: This should be its own call?
//		StackMobClientData *data = [StackMobClientData sharedClientData];
//		[self setValue:[data clientDataString]  forArgument:@"cd"];
				
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:self.url
																   consumer:consumer
																	  token:nil
																	  realm:nil
														  signatureProvider:nil]; // use the default method, HMAC-SHA1
	[request setHTTPMethod:[self httpMethod]];
		
	[request addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	[request addValue:@"deflate" forHTTPHeaderField:@"Accept-Encoding"];
	[request prepare];
	if (![[self httpMethod] isEqualToString: @"GET"]) {
		[request setHTTPBody:[[mArguments yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding]];	
		NSString *contentType = [NSString stringWithFormat:@"application/json"];
		[request addValue:contentType forHTTPHeaderField: @"Content-Type"]; 
	}
		
	if (kLogVersbose) {
		StackMobLog(@"StackMobRequest: sending asynchronous oauth request: %@", request);
	}
	[mConnectionData setLength:0];		
	self.result = nil;
	self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] retain]; // Why retaining this when already retained by synthesized method?
}

- (void)cancel
{
	[self.connection cancel];
	self.connection = nil;
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
	mHttpResponse = [(NSHTTPURLResponse*)response copy];
}
	
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
	if (data == nil) {
		StackMobLog(@"StackMobRequest: Recieved data but it was nil");
		return;
	}

	[mConnectionData appendData:data];
	
	if (kLogVersbose == YES)
		StackMobLog(@"StackMobRequest: Got data of length %u", [mConnectionData length]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	_requestFinished = YES;
	// inform the user
	NSLog(@"Connection failed! Error - %@ %@",
		[error localizedDescription],
		[[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	self.result = [NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription], @"statusDetails", nil];  
	// If a delegate has been set, attempt to tell
	// it all about this request's status.
	if (self.delegate != nil)
	{
		// If a selector has been set for this request, 
		// attempt to notify the delegate using it.
		if ([self.delegate respondsToSelector:@selector(requestCompleted:)] == YES)
			[[self delegate] requestCompleted:self];
	}
}


- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
	_requestFinished = YES;
	if (kLogRequestSteps == YES)
		StackMobLog(@"Received Request: %@", self.method);
	NSString*     textResult;
	NSDictionary* result;
	
	if ([mConnectionData length] == 0)
	{
		result = [NSDictionary dictionary];
	}
	else
	{
		textResult = [[[NSString alloc] initWithData:mConnectionData encoding:NSUTF8StringEncoding] autorelease];
		StackMobLog(@"Text result was %@", textResult);
		
		[mConnectionData setLength:0];		
		result = [textResult yajl_JSON];
	}
	
	if (kLogRequestSteps == YES)
		NSLog(@"Request Processed: %@", self.method);


	self.result = result;
	
	// If a delegate has been set, attempt to tell
	// it all about this request's status.
	if (mDelegate != nil)
	{
		if ([mDelegate respondsToSelector:@selector(requestCompleted:)] == YES) {
      if (kLogVersbose == YES) {
        StackMobLog(@"Calling delegate");
      }
			[mDelegate requestCompleted:self];
    } else {
      if (kLogVersbose == YES) {
        StackMobLog(@"Delegate does not respond to selector\ndelegate: %@", mDelegate);
      }
    }
	
	} else {
    if (kLogVersbose == YES) {
      StackMobLog(@"No delegate");
    }
  }
}

- (id) sendSynchronousRequestProvidingError:(NSError**)error {
	if (kLogVersbose == YES) {
		StackMobLog(@"Sending Request: %@", self.method);
		StackMobLog(@"Request url: %@", self.url);
		StackMobLog(@"Request HTTP Method: %@", self.httpMethod);
	}
	
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:session.apiKey
													secret:session.apiSecret];
	
	//TODO: This should be its own call?
	//		StackMobClientData *data = [StackMobClientData sharedClientData];
	//		[self setValue:[data clientDataString]  forArgument:@"cd"];
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:self.url
																   consumer:consumer
																	  token:nil   // we don't need a token
																	  realm:nil   // should we set a realm?
														  signatureProvider:nil]; // use the default method, HMAC-SHA1
	
	[request setHTTPMethod:[self httpMethod]];
	
	[request addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	[request addValue:@"deflate" forHTTPHeaderField:@"Accept-Encoding"];
	[request prepare];
	if (![[self httpMethod] isEqualToString: @"GET"]) {
		[request setHTTPBody:[[mArguments yajl_JSONString] dataUsingEncoding:NSUTF8StringEncoding]];	
		NSString *contentType = [NSString stringWithFormat:@"application/json"];
		[request addValue:contentType forHTTPHeaderField: @"Content-Type"]; 
	}
	
	[mConnectionData setLength:0];
	NSURLResponse *response = nil;

	if (kLogVersbose) {
		StackMobLog(@"StackMobRequest: sending synchronous oauth request: %@", request);
	}
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
	if (kLogVersbose) {
    if (*error!=nil) {
      StackMobLog(@"StackMobRequest: ERROR: %@", [*error localizedDescription]);
    }
	}

	[mConnectionData appendData:data];
  mHttpResponse = [(NSHTTPURLResponse*)response copy];

	NSDictionary* result;
	
	if ([mConnectionData length] == 0)
	{
		result = [NSDictionary dictionary];
	}
	else
	{
    NSString* textResult = [[[NSString alloc] initWithData:mConnectionData encoding:NSUTF8StringEncoding] autorelease];
		StackMobLog(@"Text result was %@", textResult);
		
		[mConnectionData setLength:0];		
		result = [textResult yajl_JSON];
	}
	return result;
}

- (NSString*) description {
  return [NSString stringWithFormat:@"%@: %@", [super description], self.url];
}
	
	
@end
