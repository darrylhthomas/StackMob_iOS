# Getting Started
1. Clone the repository from GitHub
`git clone git://github.com/stackmob/StackMob_iOS.git`
2. Open the StackMobiOS project in XCode
3.  Build the target "Build Framework"
4.  Copy $\{StackMobiOSHome\}/build/Framework/StackMob.framework to your project as a framework
5. Add the following to Other Linker Flags in the build configuration of your project: -ObjC -all_load
6.  Add the following Frameworks to your project:
- CFNetwork.framework
- CoreLocation.framework
- SystemConfirmation.framework
- YAJLiOS.framework - This is provided as part of our GitHub project. You will find it in the external folder

7. We suggest you create a SessionFactory to handle creating the StackMob Session needed to connect to our servers. The session object should be retained for the life of the application. So creating it on applicationDidFinishLaunching and releasing it on applicationWillTerminate or applicationDidEnterBackground is a good pattern.  Something like the following will work:

                    `@implementation SMSessionFactory
                    StackMobSession *session_;
                    NSString * const kAPIKey = @"PUT_YOUR_KEY_HERE";
                    NSString * const kAPISecret = @"PUT_YOUR_SECRET_HERE";
                    NSString * const kSubDomain = @"PUT_YOUR_SUB_DOMAIN_HERE";
                    NSString * const kAppName = @"PUT_YOUR_APP_NAME_HERE";
                    NSString * const kDomain = @"stackmob.com";

                    + (StackMobSession*)session {
                        if (session_ == nil) {
                            session_ = [[StackMobSession sessionForApplication:kAPIKey
                                                                       secret:kAPISecret
                                                                      appName:kAppName
                                                                    subDomain:kSubDomain
                                                                        domain:kDomain] retain];
                        }
                        return session_;
                    }
                    @end`
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

