import Foundation
import KsApi

private enum KSRAnalyticsIdentityTraitValue: Equatable {
  case string(String)
  case bool(Bool)

  var value: Any {
    switch self {
    case let .string(value): return value
    case let .bool(value): return value
    }
  }
}

public struct KSRAnalyticsIdentityData: Equatable {
  public let userId: Int
  private let name: String
  private let notifications: User.Notifications

  init(_ user: User) {
    self.userId = user.id
    self.name = user.name
    self.notifications = user.notifications
  }

  public static func == (lhs: KSRAnalyticsIdentityData, rhs: KSRAnalyticsIdentityData) -> Bool {
    guard lhs.userId == rhs.userId else { return false }

    let uniqueTraits = lhs.uniqueTraits(comparedTo: rhs)

    return uniqueTraits.isEmpty
  }

  func uniqueTraits(comparedTo otherData: KSRAnalyticsIdentityData?) -> [String: Any] {
    var newTraits: [String: Any] = [:]
    let otherTraits = otherData?.traits ?? [:]

    for key in self.traits.keys where self.traits[key] != otherTraits[key] {
      newTraits[key] = self.traits[key]?.value
    }

    return newTraits
  }

  var allTraits: [String: Any] {
    return self.traits.mapValues { $0.value }
  }

  fileprivate var traits: [String: KSRAnalyticsIdentityTraitValue] {
    let notifications = self.notifications.encode()
      .mapValues { ($0 as? Bool).flatMap(KSRAnalyticsIdentityTraitValue.bool) }
      .compactMapValues { $0 }

    return [
      "name": .string(self.name)
    ]
    .withAllValuesFrom(notifications)
  }
}

extension KSRAnalyticsIdentityData: Codable {
  private enum CodingKeys: String, CodingKey {
    case userId
    case name
    case notifications
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.userId, forKey: .userId)
    try container.encode(self.name, forKey: .name)

    let data = try JSONSerialization.data(withJSONObject: self.notifications.encode(), options: [])
    try container.encode(data, forKey: .notifications)
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    self.userId = try values.decode(Int.self, forKey: .userId)
    self.name = try values.decode(String.self, forKey: .name)

    let data = try values.decode(Data.self, forKey: .notifications)
    self.notifications = try JSONDecoder().decode(User.Notifications.self, from: data)
  }
}
