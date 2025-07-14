// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Parameters for sharing app data and device information with the Conversions API
public struct AppDataInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    advertiserTrackingEnabled: Bool,
    applicationTrackingEnabled: Bool,
    extinfo: [String]
  ) {
    __data = InputDict([
      "advertiserTrackingEnabled": advertiserTrackingEnabled,
      "applicationTrackingEnabled": applicationTrackingEnabled,
      "extinfo": extinfo
    ])
  }

  /// Use this field to specify ATT permission on an iOS 14.5+ device.
  public var advertiserTrackingEnabled: Bool {
    get { __data["advertiserTrackingEnabled"] }
    set { __data["advertiserTrackingEnabled"] = newValue }
  }

  /// A person can choose to enable ad tracking on an app level. Your SDK should allow an app developer to put an opt-out setting into their app. Use this field to specify the person's choice.
  public var applicationTrackingEnabled: Bool {
    get { __data["applicationTrackingEnabled"] }
    set { __data["applicationTrackingEnabled"] = newValue }
  }

  /// Extended device information, such as screen width and height. Required only for native.
  public var extinfo: [String] {
    get { __data["extinfo"] }
    set { __data["extinfo"] = newValue }
  }
}
