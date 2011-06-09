# Getting Started
1. Clone the repository from GitHub
`git clone git://github.com/stackmob/StackMob_iOS.git`
2. Open the StackMobiOS project in XCode
3.  Build the target "Build Framework" (Note: if not building for iOS 4.2, first edit the xcodebuild -sdk params at the top of script/build)
4.  Copy $\{StackMobiOSHome\}/build/Framework/StackMob.framework to your project as a framework
5. Add the following to Other Linker Flags in the build configuration of your project: -ObjC -all_load
6.  Add the following Frameworks to your project:

    - CFNetwork.framework
    - CoreLocation.framework
    - SystemConfirmation.framework
    - YAJLiOS.framework - This is provided as part of our GitHub project. You will find it in the external folder

7. We suggest you create a SessionFactory to handle creating the StackMob Session needed to connect to our servers. The session object should be retained for the life of the application. So creating it on applicationDidFinishLaunching and releasing it on applicationWillTerminate or applicationDidEnterBackground is a good pattern.  Something like the following will work:

                    @implementation SMSessionFactory
                    StackMobSession *session_;
                    NSString * const kAPIKey = @"PUT_YOUR_KEY_HERE";
                    NSString * const kAPISecret = @"PUT_YOUR_SECRET_HERE";
                    NSString * const kSubDomain = @"PUT_YOUR_SUB_DOMAIN_HERE";
                    NSString * const kAppName = @"PUT_YOUR_APP_NAME_HERE";
                    NSString * const kDomain = @"stackmob.com";
                    NSNumber * const kAPIVersionNumber = [NSNumber numberWithInt:0]; // 0=sandbox

                    + (StackMobSession*)session {
                        if (session_ == nil) {
                            session_ = [[StackMobSession sessionForApplication:kAPIKey
                                                                       secret:kAPISecret
                                                                      appName:kAppName
                                                                    subDomain:kSubDomain
                                                                        domain:kDomain
                                                               apiVersionNumber:kAPIVersionNumber] retain];
                        }
                        return session_;
                    }
                    @end
8. You can now make requests to your servers on StackMob using the following pattern

	            StackMobRequest *request = [StackMobRequest requestForMethod: "THE_NAME_OF_THE_METHOD_BEING_CALLED"
                                                               withArguments: "DICT_OF_PARAMS"
                                                                withHttpVerb: "THE_TYPE_OF_REQUEST_GET_POST_ETC"];
                       request.delegate = self;
                       [request sendRequest];

             - (void)requestCompleted:(StackMobRequest*)request {
                       NSString *prettyPrint = [[request result] yajl_JSONStringWithOptions:YAJLGenOptionsBeautify
                            indentString:@"  "];
                       jsonLabel.text = prettyPrint;
             }

9. You can register an Apple Push Notification service device token like this

              - (void) application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
                // Apple sends the token in this format: <3004dd85 409f1f62 469a82b8 7baf74c9 8101475e 8bcda8a7 4a098853 b9fc858e>
                // we need to strip out the angle brackets and spaces
                NSString* tokenString = [NSString stringWithFormat:@"%@", deviceToken];
                NSRange tokenRange;
                tokenRange.location = 1;
                tokenRange.length = [tokenString length]-2;
                NSString* noBracketsString = [tokenString substringWithRange:tokenRange];
                NSString* stackMobTokenString = [noBracketsString stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSDictionary* arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                                           stackMobTokenString , @"token",
                                           stackMobAppUserId, @"userId",
                                           nil];
                StackMobRequest* request = [StackMobRequest pushRequestWithArguments:arguments withHttpVerb:POST];
                [request sendRequest];
              }
