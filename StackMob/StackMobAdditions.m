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

#import "StackMobAdditions.h"

@implementation NSDictionary (StackMobAdditions)

- (NSString*)queryString
{
	NSMutableArray* encodedPieces = [NSMutableArray array];
	
	for(NSString* argumentKey in self)
	{
		NSString* argumentValue = [self objectForKey:argumentKey];
		if(!argumentValue)
			continue;
		
		argumentValue = [(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)argumentValue, NULL, CFSTR("?=&+"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)) autorelease];
		[encodedPieces addObject:[NSString stringWithFormat:@"%@=%@", argumentKey, argumentValue]];
	}
	
	return [encodedPieces componentsJoinedByString:@"&"];
}

@end
