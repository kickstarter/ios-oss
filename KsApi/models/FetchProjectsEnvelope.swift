//
//  FetchProjectsEnvelope.swift
//  KsApi
//
//  Created by Amy Dyer on 10/3/23.
//  Copyright © 2023 Kickstarter. All rights reserved.
//

import Foundation

public struct FetchProjectsEnvelope: Decodable {
  public var projects: [Project]
  public var cursor: String?
  public var hasPreviousPage: Bool
  public var totalCount: Int
}
