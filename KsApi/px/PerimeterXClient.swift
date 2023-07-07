import Foundation
import PerimeterX_SDK

public class PerimeterXClient: NSObject, PerimeterXClientType {
  let dateType: ApiDateProtocol.Type
 // private var policy = PXPolicy()
  /**
   Custom `HTTPCookie` adding Perimeter X protection to native webviews.
   */
  public lazy var cookie: HTTPCookie? = {
    HTTPCookie(properties: [
      // Change this AppEnvironment's current apiURL
      .domain: "https://api.kickstarter.com", // Change according to the domain the webview will use
      .path: "/",
      .name: "_pxmvid",
      .value: PerimeterX.vid() as Any,
      .expires: self.dateType.init(timeIntervalSinceNow: 3_600).date
    ])
  }()

//  public lazy var vid: String? = {
//    PerimeterX.vid()
//  }()
//
  public func getPXHeaders() -> [String: String] {
    //let headers = PerimeterX.headersForURLRequest() ?? [:]
    //print("PX Headers - \(headers)")
    
    return [:]
  }
  
  public init(
    dateType: ApiDateProtocol.Type = Date.self
  ) {
    self.dateType = dateType

    super.init()
  }

  public func start(policyDomains: Set<String>) {
    let policy = PXPolicy()
    //policy.doctorCheckEnabled = true
    //policy.urlRequestInterceptionType = .none
    policy.set(domains: policyDomains, forAppId: Secrets.PerimeterX.appId)
    //PXPolicy.requestsInterceptedAutomaticallyEnabled = false

    try? PerimeterX.start(appId: Secrets.PerimeterX.appId, delegate: nil, policy: policy)
    
   // let setPolicy = {

      //policy.requestsInterceptedAutomaticallyEnabled = false
//      PerimeterX.setPolicy(policy: policy) {
//        print("❎ Perimeter X policy setup complete.")
//      }
    // }
//    let policy = PXPolicy()
//    //policy.doctorCheckEnabled = true
//    //policy.urlRequestInterceptionType = .none
//    policy.set(domains: policyDomains, forAppId: Secrets.PerimeterX.appId)
//    //PXPolicy.requestsInterceptedAutomaticallyEnabled = false
//
//    do {
//      try PerimeterX.start(appId: Secrets.PerimeterX.appId, delegate: self, policy: policy)
//    } catch {
//        print("failed to start \(error)")
//    }
//    { status, error in
//      switch error {
//      case let .some(errorValue):
//        print("❎ Perimeter X start error \(errorValue)")
//      default:
//        print("❎ Has Perimeter X started? \(status)")
//
////        if status {
////          setPolicy()
////        }
//      }
//    }
  }
  
  public func handleResponse(data: Data, response: URLResponse) -> Bool {
    PerimeterX.handleResponse(response: response, data: data) { result in
      switch result {
      case .cancelled:
        print("cancelled")
      case .solved:
        print("solved")
      @unknown default:
        fatalError()
      }
    }
  }
}
