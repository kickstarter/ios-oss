//
//  TrackingHelpers.swift
//  Library-iOS
//
//  Created by Afees Lawal on 25/02/2021.
//  Copyright © 2021 Kickstarter. All rights reserved.
//

import Foundation

final class TrackingHelpers {
  static func pledgeContext(for viewContext: PledgeViewContext) -> KSRAnalytics.TypeContext.PledgeContext {
     switch viewContext {
     case .pledge:
      return .newPledge
     case .update, .changePaymentMethod:
      return .manageReward
     case .updateReward:
      return .changeReward
     case .fixPaymentMethod:
      return .fixErroredPledge
     }
   }
 }
