import Foundation

extension Dictionary {
  static func renamed(key fromKey: Key, to toKey: Key) -> ((Dictionary) -> Dictionary) {
    return { dict in
      var result = dict
      result[toKey] = result[fromKey]
      result[fromKey] = nil
      return result
    }
  }
}

extension Array where Element: Hashable {
  public func distincts(_ eq: (Element, Element) -> Bool) -> Array {
    var result = Array()
    forEach { x in
      if !result.contains(where: { eq(x, $0) }) {
        result.append(x)
      }
    }
    return result
  }
}
