//
//  STPAPIResponseDecodable.h
//  Stripe
//
//  Created by Jack Flintermann on 10/14/15.
//  Copyright © 2015 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Objects conforming to STPAPIResponseDecodable can be automatically converted 
 from a JSON dictionary that was returned from the Stripe API.
 */
@protocol STPAPIResponseDecodable <NSObject>

/**
 Parses an response from the Stripe API (in JSON format; represented as 
 an `NSDictionary`) into an instance of the class.

 @param response The JSON dictionary that represents an object of this type

 @return The object represented by the JSON dictionary, or nil if the object 
 could not be decoded (i.e. if one of its `requiredFields` is nil).
 */
+ (nullable instancetype)decodedObjectFromAPIResponse:(nullable NSDictionary *)response;

/**
 The raw JSON response used to create the object. This can be useful for accessing
 fields that haven't yet been made into native properties in the SDK.
 */
@property (nonatomic, readonly, nonnull, copy) NSDictionary *allResponseFields;

@end
