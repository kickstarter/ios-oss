import ReactiveSwift
import SystemConfiguration

public enum Reachability {
  case wifi
  case wwan
  case none

  public static var current: Reachability {
    return reachabilityProperty.value
  }

  public static let signalProducer = reachabilityProperty.producer
}

private let reachabilityProperty: MutableProperty<Reachability> = {
  guard
    let networkReachability = networkReachability(),
    let reachabilityFlags = reachabilityFlags(forNetworkReachability: networkReachability)
  else { return MutableProperty(.none) }

  guard SCNetworkReachabilitySetCallback(networkReachability, callback, nil),
    SCNetworkReachabilitySetDispatchQueue(networkReachability, queue)
  else { return MutableProperty(.none) }

  return MutableProperty(reachability(forFlags: reachabilityFlags))
}()

private let queue = DispatchQueue(label: "com.kickstarter.reachability", attributes: [])

private func networkReachability() -> SCNetworkReachability? {
  var zeroAddress = sockaddr_in()
  zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
  zeroAddress.sin_family = sa_family_t(AF_INET)

  return withUnsafePointer(to: &zeroAddress) { ptr in
    ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
      SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
    }
  }
}

private func reachabilityFlags(forNetworkReachability networkReachability: SCNetworkReachability)
  -> SCNetworkReachabilityFlags? {
  var reachabilityFlags = SCNetworkReachabilityFlags()

  guard withUnsafeMutablePointer(to: &reachabilityFlags, {
    SCNetworkReachabilityGetFlags(networkReachability, UnsafeMutablePointer($0))
  }) else { return nil }

  return reachabilityFlags
}

private func reachability(forFlags flags: SCNetworkReachabilityFlags) -> Reachability {
  if flags.contains(.isWWAN) {
    return .wwan
  }

  if flags.contains(.reachable) {
    return .wifi
  }

  return .none
}

private func callback(
  networkReachability _: SCNetworkReachability,
  flags: SCNetworkReachabilityFlags,
  info _: UnsafeMutableRawPointer?
) {
  reachabilityProperty.value = reachability(forFlags: flags)
}
