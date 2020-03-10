import Argo
import Foundation

extension Argo.JSON {
  func toPrimitive() -> Any? {
    switch self {
    case let .array(json):
      return json.map { $0.toPrimitive() }
    case let .bool(bool):
      return bool
    case .null:
      return nil
    case let .number(number):
      return number
    case let .object(dict):
      return dict.mapValues { $0.toPrimitive() }
    case let .string(string):
      return string
    }
  }
}
