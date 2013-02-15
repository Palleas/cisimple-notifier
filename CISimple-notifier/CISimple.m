//
//  PCCiSimple.m
//  CISimple-notifier
//
//  Created by Romain Pouclet on 10/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "CISimple.h"
#import "SVHTTPRequest.h"
#import "NSHTTPError.h"

NSString * const kBuildUpdatedEventName = @"build-progress-updated";

@implementation CISimple

@synthesize key = _key;

- (id)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        _key = key;
    }
    
    return self;
}

- (void)retrieveChannelInfo:(CISCompletionHandler)completion;
{
    NSAssert(completion != nil, @"Completion block must not be nil");
    
    [[self sharedClient] GET: @"/user/channel"
                  parameters:@{@"access_token" : self.key}
                  completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
                      NSLog(@"Retrieved response");

                      if (urlResponse.statusCode != 200) {
                          NSLog(@"Code wasn't 200 :( ");
                          // @todo fix domain ?
                          error = [NSHTTPError errorWithDomain: @"HTTP error"
                                                      code: urlResponse.statusCode
                                                  userInfo: nil];
                          completion(nil, error);
                      } else if (nil == error) {
                          completion(response[@"name"], nil);
                      } else {
                          completion(nil, error);
                      }
                  }];
}


- (void)retrieveAuthentificationForParameters:(NSDictionary *)parameters completionBlock:(CISCompletionHandler)completion;
{
    NSAssert(completion != nil, @"Completion block must not be nil");

    NSString *authUrl = [@"/user/channel/auth?access_token=" stringByAppendingString: self.key];
    [[self sharedClient] POST: authUrl parameters: parameters completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (nil == error) {
            completion(response, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (SVHTTPClient *)sharedClient
{
    SVHTTPClient *client = [SVHTTPClient sharedClientWithIdentifier: @"cisimple"];
    client.basePath = @"https://www.cisimple.com";
    
    return client;
}



@end
