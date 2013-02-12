//
//  PCCiSimple.m
//  CISimple-notifier
//
//  Created by Romain Pouclet on 10/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "PCCiSimple.h"
#import "SVHTTPRequest.h"

@implementation PCCiSimple

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
                      
                      if (nil == error) {
                          completion(response[@"name"], nil);
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
