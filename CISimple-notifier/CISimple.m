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

NSString * const kBuildUpdatedEventName = @"build-state-changed";

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
                  parameters:@{}
                  completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
                      NSLog(@"Retrieved response");
                      
                      if (nil == error && urlResponse.statusCode == 200) {
                          NSLog(@"No error : retrieved channel name");
                          if ([self.delegate respondsToSelector:@selector(cisimpleClientFetchedChannel:channel:)]) {
                              NSLog(@"Delegate respond to cisimpleClientFetchedChannel:channel: : sending message");
                              [self.delegate cisimpleClientFetchedChannel: self channel: response[@"name"]];
                          }
                          
                          completion(response, nil);
                          return;
                      }
                    
                      NSLog(@"Got an error or the response code wasn't 200");
                      if ([self.delegate respondsToSelector:@selector(cisimpleClient:didReceiveError:)]) {
                          NSLog(@"Delegate responds to selector cisimpleClient:didReceiveError:");
                          if (urlResponse.statusCode != 200) {
                              NSLog(@"Response code was not 200 : throwing HTTP Error");
                              NSHTTPError *httpError = [NSHTTPError errorWithDomain: @"HTTP error"
                                                              code: urlResponse.statusCode
                                                          userInfo: nil];
                              [self.delegate cisimpleClient:self didReceiveError: httpError];
                          } else {
                              NSLog(@"Throwing other error");
                              [self.delegate cisimpleClient:self didReceiveError: error];
                          }
                      }
                  }];
}


- (void)retrieveAuthentificationForParameters:(NSDictionary *)parameters completionBlock:(CISCompletionHandler)completion;
{
    NSAssert(completion != nil, @"Completion block must not be nil");

    NSString *authUrl = @"/user/channel/auth";
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
    [client setValue:@"application/vnd.cisimple.v1" forHTTPHeaderField: @"Accept"];
    NSString *authHeaderValue = [@"Bearer " stringByAppendingString:_token];
    [client setValue:authHeaderValue forHTTPHeaderField: @"Authorization"];

    return client;
}



@end
