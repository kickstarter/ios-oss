import Argo
import Curry
import Runes
import Prelude

public struct DiscoveryParams {

  public private(set) var backed: Bool?
  public private(set) var category: RootCategoriesEnvelope.Category?
  public private(set) var collaborated: Bool?
  public private(set) var created: Bool?
  public private(set) var hasLiveStreams: Bool?
  public private(set) var hasVideo: Bool?
  public private(set) var includePOTD: Bool?
  public private(set) var page: Int?
  public private(set) var perPage: Int?
  public private(set) var query: String?
  public private(set) var recommended: Bool?
  public private(set) var seed: Int?
  public private(set) var similarTo: Project?
  public private(set) var social: Bool?
  public private(set) var sort: Sort?
  public private(set) var staffPicks: Bool?
  public private(set) var starred: Bool?
  public private(set) var state: State?

  public enum State: String, Argo.Decodable {
    case all
    case live
    case successful
  }

  public enum Sort: String, Argo.Decodable {
    case endingSoon = "end_date"
    case magic
    case mostFunded = "most_funded"
    case newest
    case popular = "popularity"
  }

  public static let defaults = DiscoveryParams(backed: nil, category: nil, collaborated: nil, created: nil,
                                               hasLiveStreams: nil, hasVideo: nil, includePOTD: nil,
                                               page: nil, perPage: nil, query: nil, recommended: nil,
                                               seed: nil, similarTo: nil, social: nil, sort: nil,
                                               staffPicks: nil, starred: nil, state: nil)

  public var queryParams: [String: String] {
    var params: [String: String] = [:]
    params["backed"] = self.backed == true ? "1" : self.backed == false ? "-1" : nil
    params["category_id"] = self.category?.intID?.description
    params["collaborated"] = self.collaborated?.description
    params["created"] = self.created?.description
    params["has_live_streams"] = self.hasLiveStreams?.description
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

    // Include the POTD only when searching when sorting by magic / not specifying sort
    if params["sort"] == nil || params["sort"] == DiscoveryParams.Sort.magic.rawValue {
      params["include_potd"] = self.includePOTD?.description
    }

    return params
  }
}

extension DiscoveryParams: Equatable {}
public func == (a: DiscoveryParams, b: DiscoveryParams) -> Bool {
  return a.queryParams == b.queryParams
}

extension DiscoveryParams: Hashable {
  public var hashValue: Int {
    return self.description.hash
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
    let create = curry(DiscoveryParams.init)

    let tmp1 = create
      <^> ((json <|? "backed" >>- stringIntToBool) as Decoded<Bool?>)
      <*> ((json <|? "category" >>- decodeToGraphCategory) as Decoded<RootCategoriesEnvelope.Category>)
      <*> ((json <|? "collaborated" >>- stringToBool) as Decoded<Bool?>)
      <*> ((json <|? "created" >>- stringToBool) as Decoded<Bool?>)
    let tmp2 = tmp1
      <*> json <|? "has_live_streams"
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
  }
}

private func stringToBool(_ string: String?) -> Decoded<Bool?> {
  guard let string = string else { return .success(nil) }
  switch string {
  // taken from server's `value_to_boolean` function
  case "true", "1", "t", "T", "true", "TRUE", "on", "ON":
    return .success(true)
  case "false", "0", "f", "F", "false", "FALSE", "off", "OFF":
    return .success(false)
  default:
    return .failure(.custom("Could not parse string into bool."))
  }
}

private func stringToInt(_ string: String?) -> Decoded<Int?> {
  guard let string = string else { return .success(nil) }
  return Int(string).map(Decoded.success) ?? .failure(.custom("Could not parse string into int."))
}

private func stringIntToBool(_ string: String?) -> Decoded<Bool?> {
  guard let string = string else { return .success(nil) }
  return Int(string)
    .filter { $0 <= 1 && $0 >= -1 }
    .map { .success($0 == 0 ? nil : $0 == 1) }
    .coalesceWith(.failure(.custom("Could not parse string into bool.")))
}

private func decodeToGraphCategory(_ json: JSON?) -> Decoded<RootCategoriesEnvelope.Category> {

  guard let jsonObj = json else {
    return .success(RootCategoriesEnvelope.Category(id: "-1", name: "Unknown Category"))
  }
  switch jsonObj {
  case .object(let dic):
    let category = RootCategoriesEnvelope.Category(id: categoryInfo(dic)?.0 ?? "",
                                                   name: categoryInfo(dic)?.1 ?? "")
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
  case (.number(let id), .string(let name)):
    return ("\(id)", name)
  default:
    return nil
  }
}
