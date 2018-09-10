//
//  STPLegalEntityParams.h
//  Stripe
//
//  Created by Daniel Jackson on 12/20/17.
//  Copyright © 2017 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STPFormEncodable.h"

@class STPAddress, STPVerificationParams;

NS_ASSUME_NONNULL_BEGIN

/**
 Stripe API parameters to define a Person. Things like their name, address, etc.

 All of the fields are optional.
 */
@interface STPPersonParams: NSObject<STPFormEncodable>

/**
 The first name of this person.
 */
@property (nonatomic, copy, nullable) NSString *firstName;

/**
 The last name of this person.
 */
@property (nonatomic, copy, nullable) NSString *lastName;

/**
 The maiden name of this person.
 */
@property (nonatomic, copy, nullable) NSString *maidenName;

/**
 The address parameter. For `STPPersonParams`, this is the address of the person.
 For the `STPLegalEntityParams` subclass, see also `personalAddress`.
 */
@property (nonatomic, strong, nullable) STPAddress *address;

/**
 The date of birth (dob) of this person.

 Must include `day`, `month`, and `year`, and only those fields are used.
 */
@property (nonatomic, copy, nullable) NSDateComponents *dateOfBirth;

/**
 Verification document for this person.
 */
@property (nonatomic, strong, nullable) STPVerificationParams *verification;

@end


/**
 Stripe API parameters to define a Legal Entity. This extends `STPPersonParams`
 and adds some more fields.

 Legal entities can be either an individual or a company.
 */
@interface STPLegalEntityParams : STPPersonParams

/**
 Additional owners of the legal entity.
 */
@property (nonatomic, copy, nullable) NSArray<STPPersonParams *> *additionalOwners;

/**
 The business name
 */
@property (nonatomic, copy, nullable) NSString *businessName;

/**
 The business Tax Id
 */
@property (nonatomic, copy, nullable) NSString *businessTaxId;

/**
 The business VAT Id
 */
@property (nonatomic, copy, nullable) NSString *businessVATId;

/**
 The gender of the individual, as a string.

 Currently either `male` or `female` are supported values.
 */
@property (nonatomic, copy, nullable) NSString *genderString;

/**
 The personal address field.
 */
@property (nonatomic, strong, nullable) STPAddress *personalAddress;

/**
 The Personal Id number
 */
@property (nonatomic, copy, nullable) NSString *personalIdNumber;

/**
 The phone number of the entity.
 */
@property (nonatomic, copy, nullable) NSString *phoneNumber;

/**
 The last four digits of the SSN of the individual.
 */
@property (nonatomic, copy, nullable) NSString *ssnLast4;

/**
 The Tax Id Registrar
 */
@property (nonatomic, copy, nullable) NSString *taxIdRegistrar;

/**
 The type of this legal entity, as a string.

 Currently `individual` or `company` are supported values.
 */
@property (nonatomic, copy, nullable) NSString *entityTypeString;

@end


/**
 Parameters for supported types of verification.
 */
@interface STPVerificationParams: NSObject<STPFormEncodable>

/**
 The file id for the uploaded verification document.
 */
@property (nonatomic, copy, nullable) NSString *document;

@end

NS_ASSUME_NONNULL_END
