import Foundation

struct AttributionTracking {
  public enum AttributionEvent: String {
    case projectPageViewed = "Project Page Viewed"
  }

  static func eventParametersString(refInfo: RefInfo?) -> String? {
    let sessionRefTag = refInfo?.refTag?.stringTag
    let contextPageUrl = refInfo?.deeplinkUrl
    var props = [String: String]()
    if let sessionRefTag {
      props["session_ref_tag"] = sessionRefTag
    }
    props["context_page_url"] = contextPageUrl ?? ""

    let propsData = try? JSONSerialization.data(withJSONObject: props)
    return String(data: propsData!, encoding: .utf8)
  }
}
