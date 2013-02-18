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

@synthesize token = _token;
@synthesize delegate = _delegate;

- (id)initWithToken:(NSString *)token delegate:(id<CISCisimpleDelegate>)delegate
{
    NSAssert(token != nil, @"API token cannot be null");
    
    self = [super init];
    if (self) {
        _token = token;
        _delegate = delegate;
    }
    
    return self;
}

- (void)retrieveChannelInfo:(CISCompletionHandler)completion;
{
    NSAssert(completion != nil, @"Completion block must not be nil");
    
    NSLog(@"Retrieving channel informations");
    if ([self.delegate respondsToSelector:@selector(cisimpleClientStartedFetchingChannel:)]) {
        NSLog(@"Delegate respond to cisimpleClientStartedFetchingChannel : sending message");
        [self.delegate cisimpleClientStartedFetchingChannel: self];
    }
    
    [[self sharedClient] GET: @"/user/channel"
                  parameters:@{@"access_token" : self.token}
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
                          NSLog(@"No error : retrieved channel name");
                          if ([self.delegate respondsToSelector:@selector(cisimpleClientFetchedChannel:channel:)]) {
                              NSLog(@"Delegate respond to cisimpleClientFetchedChannel:channel: : sending message");
                              [self.delegate cisimpleClientFetchedChannel: self channel: response[@"name"]];
                          }
                          
                          completion(response[@"name"], nil);
                      } else {
                          completion(nil, error);
                      }
                  }];
}


- (void)retrieveAuthentificationForParameters:(NSDictionary *)parameters completionBlock:(CISCompletionHandler)completion;
{
    NSAssert(completion != nil, @"Completion block must not be nil");

    NSString *authUrl = [@"/user/channel/auth?access_token=" stringByAppendingString: self.token];
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
