//
//  Config+Helpers.swift
//  Kickstarter-iOS
//
//  Created by Isabel Barrera on 5/7/18.
//  Copyright © 2018 Kickstarter. All rights reserved.
//

import Foundation
import KsApi

extension Experiment.Name {
  public func isEnabled(in environment: Environment) -> Bool {
    guard let experiments = AppEnvironment.current.config?.abExperiments else { return false }
    
    if let variant = experiments[self.rawValue] {
      return Experiment.Variant(rawValue: variant) == .experimental
    }
    
    return false
  }
}
