/*
 * Firebase iOS Client Library
 *
 * Copyright © 2013 Firebase - All Rights Reserved
 * https://www.firebase.com
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binaryform must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY FIREBASE AS IS AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL FIREBASE BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
#import "FIRMutableData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Used for runTransactionBlock:. An FIRTransactionResult instance is a container for the results of the transaction.
 */
@interface FIRTransactionResult : NSObject

/**
 * Used for runTransactionBlock:. Indicates that the new value should be saved at this location
 *
 * @param value A FIRMutableData instance containing the new value to be set
 * @return An FIRTransactionResult instance that can be used as a return value from the block given to runTransactionBlock:
 */
+ (FIRTransactionResult *)successWithValue:(FIRMutableData *)value;


/**
 * Used for runTransactionBlock:. Indicates that the current transaction should no longer proceed.
 *
 * @return An FIRTransactionResult instance that can be used as a return value from the block given to runTransactionBlock:
 */
+ (FIRTransactionResult *) abort;

@end

NS_ASSUME_NONNULL_END
