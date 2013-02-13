//
//  CISKeychainManager.m
//  CISimple-notifier
//
//  Created by Romain Pouclet on 12/02/13.
//  Copyright (c) 2013 Perfectly Cooked. All rights reserved.
//

#import "CISKeychainManager.h"

const char *cService_name = "cisimple";
const char *cAccount_name = "default account";

@implementation CISKeychainManager

- (void)storeApiKey:(NSString *)key
{
    size_t service_length = strlen(cService_name);
    size_t account_length = strlen(cAccount_name);
    const char* cApiKey = [key cStringUsingEncoding: NSUTF8StringEncoding];
    SecKeychainItemRef itemRef;
    
    // Store string in keychain
    OSStatus status = SecKeychainAddGenericPassword(NULL,
                                                    (UInt32)service_length,
                                                    cService_name,
                                                    (UInt32)account_length,
                                                    cAccount_name,
                                                    (UInt32)strlen(cApiKey),
                                                    cApiKey,
                                                    &itemRef);
    
    NSString *errorMessage = (__bridge NSString *)SecCopyErrorMessageString(status, NULL);
    NSLog(@"Keychain error message = %@ (%d)", errorMessage, status);
    
    if (errSecDuplicateItem == status) {
        NSLog(@"Object already exist => replacing");
        
        OSStatus status = SecKeychainItemModifyAttributesAndData([self retrieveApiKey: nil], NULL, (UInt32)strlen(cApiKey), cApiKey);
    }
}

- (SecKeychainItemRef)retrieveApiKey:(CISKeychainCompletionHandler)completion
{
    void *passwordData = nil;
    UInt32 passwordLength = 0;
    SecKeychainItemRef ref;

    OSStatus status = SecKeychainFindGenericPassword(NULL,
                                                     (UInt32)strlen(cService_name),
                                                     cService_name,
                                                     (UInt32)strlen(cAccount_name),
                                                     cAccount_name, &passwordLength,
                                                     &passwordData,
                                                     &ref);
    if (errSecSuccess == status && nil != completion) {
        NSString *apiKey = [[NSString alloc] initWithBytes: passwordData
                                                    length: passwordLength
                                                  encoding: NSUTF8StringEncoding];
        completion(apiKey, nil);
    } else if(errSecItemNotFound == status) {
        completion(nil, nil);
    } else {
        NSString *errorMessage = (__bridge NSString *)SecCopyErrorMessageString(status, NULL);
        completion(nil, [NSError errorWithDomain: errorMessage
                                            code: status
                                        userInfo: nil]);
    }
    
    return ref;
}

@end
