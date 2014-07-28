//
//  ShipIO.m
//  ShipIO-notifier
//
//  Created by Romain Pouclet on 10/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "ShipIO.h"
#import "SVHTTPRequest.h"
#import "NSHTTPError.h"

NSString * const kBuildUpdatedEventName = @"build-state-changed";

@implementation ShipIO

@synthesize token = _token;
@synthesize delegate = _delegate;

- (id)initWithToken:(NSString *)token delegate:(id<CISShipioDelegate>)delegate
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
    if ([self.delegate respondsToSelector:@selector(shipioClientStartedFetchingChannel:)]) {
        NSLog(@"Delegate respond to shipioClientStartedFetchingChannel : sending message");
        [self.delegate shipioClientStartedFetchingChannel: self];
    }

    [[self sharedClient] GET: @"/user/channel"
                  parameters:@{}
                  completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
                      NSLog(@"Retrieved response");
                      
                      if (nil == error && urlResponse.statusCode == 200) {
                          NSLog(@"No error : retrieved channel name");
                          if ([self.delegate respondsToSelector:@selector(shipioClientFetchedChannel:channel:)]) {
                              NSLog(@"Delegate respond to shipioClientFetchedChannel:channel: : sending message");
                              [self.delegate shipioClientFetchedChannel: self channel: response[@"name"]];
                          }
                          
                          completion(response, nil);
                          return;
                      }
                    
                      NSLog(@"Got an error or the response code wasn't 200");
                      if ([self.delegate respondsToSelector:@selector(shipioClient:didReceiveError:)]) {
                          NSLog(@"Delegate responds to selector shipioClient:didReceiveError:");
                          if (urlResponse.statusCode != 200) {
                              NSLog(@"Response code was not 200 : throwing HTTP Error");
                              NSHTTPError *httpError = [NSHTTPError errorWithDomain: @"HTTP error"
                                                              code: urlResponse.statusCode
                                                          userInfo: nil];
                              [self.delegate shipioClient:self didReceiveError: httpError];
                          } else {
                              NSLog(@"Throwing other error");
                              [self.delegate shipioClient:self didReceiveError: error];
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
    SVHTTPClient *client = [SVHTTPClient sharedClientWithIdentifier: @"shipio"];
    client.basePath = @"https://ship.io";
    [client setValue:@"application/vnd.shipio.v1" forHTTPHeaderField: @"Accept"];
    NSString *authHeaderValue = [@"Bearer " stringByAppendingString:_token];
    [client setValue:authHeaderValue forHTTPHeaderField: @"Authorization"];

    return client;
}



@end
