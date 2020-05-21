import Argo
import Curry
import Prelude
import Runes

public struct DiscoveryParams {
  public var backed: Bool?
  public var category: Category?
  public var collaborated: Bool?
  public var created: Bool?
  public var hasVideo: Bool?
  public var includePOTD: Bool?
  public var page: Int?
  public var perPage: Int?
  public var query: String?
  public var recommended: Bool?
  public var seed: Int?
  public var similarTo: Project?
  public var social: Bool?
  public var sort: Sort?
  public var staffPicks: Bool?
  public var starred: Bool?
  public var state: State?
  public var tagId: TagID?

  public enum State: String, Argo.Decodable {
    case all
    case live
    case successful
  }

  public enum Sort: String, Argo.Decodable {
    case endingSoon = "end_date"
    case magic
    case newest
    case popular = "popularity"
    case distance
  }

  public enum TagID: String, Argo.Decodable {
    case lightsOn = "557"
  }

  public static let defaults = DiscoveryParams(
    backed: nil, category: nil, collaborated: nil,
    created: nil, hasVideo: nil, includePOTD: nil,
    page: nil, perPage: nil, query: nil, recommended: nil,
    seed: nil, similarTo: nil, social: nil, sort: nil,
    staffPicks: nil, starred: nil, state: nil, tagId: nil
  )

  public static let recommendedDefaults = DiscoveryParams.defaults
    |> DiscoveryParams.lens.includePOTD .~ true
    |> DiscoveryParams.lens.backed .~ false
    |> DiscoveryParams.lens.recommended .~ true

  public var queryParams: [String: String] {
    var params: [String: String] = [:]
    params["backed"] = self.backed == true ? "1" : self.backed == false ? "-1" : nil
    params["category_id"] = self.category?.intID?.description
    params["collaborated"] = self.collaborated?.description
    params["created"] = self.created?.description
    params["has_video"] = self.hasVideo?.description
    params["page"] = self.page?.description
    params["per_page"] = self.perPage?.description
    params["recommended"] = self.recommended?.description
    params["seed"] = self.seed?.description
    params["similar_to"] = self.similarTo?.id.description
    params["social"] = self.social == true ? "1" : self.social == false ? "-1" : nil
    params["sort"] = self.sort?.rawValue
    params["staff_picks"] = self.staffPicks?.description
    params["starred"] = self.starred == true ? "1" : self.starred == false ? "-1" : nil
    params["state"] = self.state?.rawValue
    params["term"] = self.query
    params["tag_id"] = self.tagId?.rawValue

    return params
  }
}

extension DiscoveryParams: Equatable {}
public func == (a: DiscoveryParams, b: DiscoveryParams) -> Bool {
  return a.queryParams == b.queryParams
}

extension DiscoveryParams: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.description)
  }
}

extension DiscoveryParams: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    return self.queryParams.description
  }

  public var debugDescription: String {
    return self.queryParams.debugDescription
  }
}

extension DiscoveryParams: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<DiscoveryParams> {
    let tmp1 = curry(DiscoveryParams.init)
      <^> ((json <|? "backed" >>- stringIntToBool) as Decoded<Bool?>)
      <*> ((json <|? "category" >>- decodeToGraphCategory) as Decoded<Category>)
      <*> ((json <|? "collaborated" >>- stringToBool) as Decoded<Bool?>)
      <*> ((json <|? "created" >>- stringToBool) as Decoded<Bool?>)
    let tmp2 = tmp1
      <*> ((json <|? "has_video" >>- stringToBool) as Decoded<Bool?>)
      <*> ((json <|? "include_potd" >>- stringToBool) as Decoded<Bool?>)
      <*> ((json <|? "page" >>- stringToInt) as Decoded<Int?>)
      <*> ((json <|? "per_page" >>- stringToInt) as Decoded<Int?>)
    let tmp3 = tmp2
      <*> json <|? "term"
      <*> ((json <|? "recommended" >>- stringToBool) as Decoded<Bool?>)
      <*> ((json <|? "seed" >>- stringToInt) as Decoded<Int?>)
      <*> json <|? "similar_to"
    return tmp3
      <*> ((json <|? "social" >>- stringIntToBool) as Decoded<Bool?>)
      <*> json <|? "sort"
      <*> ((json <|? "staff_picks" >>- stringToBool) as Decoded<Bool?>)
      <*> ((json <|? "starred" >>- stringIntToBool) as Decoded<Bool?>)
      <*> json <|? "state"
      <*> json <|? "tag_id"
  }
}

private func stringToBool(_ string: String?) -> Decoded<Bool?> {
  guard let string = string else { return .success(nil) }
  switch string {
  // taken from server's `value_to_boolean` function
  case "true", "1", "t", "T", "TRUE", "on", "ON":
    return .success(true)
  case "false", "0", "f", "F", "FALSE", "off", "OFF":
    return .success(false)
  default:
    return .failure(.custom("Could not parse string into bool."))
  }
}

private func stringToInt(_ string: String?) -> Decoded<Int?> {
  guard let string = string else { return .success(nil) }
  return Int(string).map(Decoded<Int?>.success) ?? .failure(.custom("Could not parse string into int."))
}

private func stringIntToBool(_ string: String?) -> Decoded<Bool?> {
  guard let string = string else { return .success(nil) }
  return Int(string)
    .filter { $0 <= 1 && $0 >= -1 }
    .map { .success($0 == 0 ? nil : $0 == 1) }
    .coalesceWith(.failure(.custom("Could not parse string into bool.")))
}

private func decodeToGraphCategory(_ json: JSON?) -> Decoded<Category> {
  guard let jsonObj = json else {
    return .success(Category(id: "-1", name: "Unknown Category"))
  }
  switch jsonObj {
  case let .object(dic):
    let category = Category(
      id: categoryInfo(dic)?.0 ?? "",
      name: categoryInfo(dic)?.1 ?? ""
    )
    return .success(category)
  default:
    return .failure(DecodeError.custom("JSON should be object type"))
  }
}

private func categoryInfo(_ json: [String: JSON]) -> (String, String)? {
  guard let name = json["name"], let id = json["id"] else {
    return nil
  }
  switch (id, name) {
  case let (.number(id), .string(name)):
    return ("\(id)", name)
  default:
    return nil
  }
}
