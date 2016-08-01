import ReactiveCocoa
import Result
import SystemConfiguration

public enum Reachability {
  case wifi
  #if os(iOS)
  case wwan
  #endif
  case none

  public static var current: Reachability {
    return reachabilityProperty.value
  }

  public static let signalProducer = reachabilityProperty.producer
}

private let reachabilityProperty: MutableProperty<Reachability> = {
  guard
    let networkReachability = networkReachability(),
    reachabilityFlags = reachabilityFlags(forNetworkReachability: networkReachability)
    else { return MutableProperty(.none) }

  guard SCNetworkReachabilitySetCallback(networkReachability, callback, nil)
    && SCNetworkReachabilitySetDispatchQueue(networkReachability, queue)
    else { return MutableProperty(.none) }

  return MutableProperty(reachability(forFlags: reachabilityFlags))
}()

private let queue = dispatch_queue_create("com.kickstarter.reachability", DISPATCH_QUEUE_SERIAL)

private func networkReachability() -> SCNetworkReachability? {
  var zeroAddress = sockaddr_in()
  zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
  zeroAddress.sin_family = sa_family_t(AF_INET)

  guard let ref =
    withUnsafePointer(&zeroAddress, {
      SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
    }) else { return nil }

  return ref
}

private func reachabilityFlags(forNetworkReachability networkReachability: SCNetworkReachability)
  -> SCNetworkReachabilityFlags? {

    var reachabilityFlags = SCNetworkReachabilityFlags()

    guard withUnsafeMutablePointer(&reachabilityFlags, {
      SCNetworkReachabilityGetFlags(networkReachability, UnsafeMutablePointer($0))
    }) else { return nil }

    return reachabilityFlags
}

private func reachability(forFlags flags: SCNetworkReachabilityFlags) -> Reachability {
  #if os(iOS)
  if flags.contains(.IsWWAN) {
    return .wwan
  }
  #endif
  if flags.contains(.Reachable) {
    return .wifi
  }

  return .none
}

private func callback(networkReachability: SCNetworkReachability, flags: SCNetworkReachabilityFlags,
                      info: UnsafeMutablePointer<Void>) {

  reachabilityProperty.value = reachability(forFlags: flags)
}
