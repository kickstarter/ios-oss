//
//  STPCoreTableViewController.h
//  Stripe
//
//  Created by Brian Dorfman on 1/6/17.
//  Copyright © 2017 Stripe, Inc. All rights reserved.
//

#import "STPCoreScrollViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 This is the base class for all Stripe scroll view controllers. It is intended
 for use only by Stripe classes, you should not subclass it yourself in your app.
 
 It inherits from STPCoreScrollViewController and changes the type of the
 created scroll view to UITableView, as well as other shared table view logic.
 */
@interface STPCoreTableViewController : STPCoreScrollViewController

@end

NS_ASSUME_NONNULL_END
