import FirebaseAnalytics
import FirebaseDatabase

public struct FirebaseRefConfig: Equatable {
  let orderBy: String
  let ref: String

  public init(ref: String, orderBy: String) {
    self.orderBy = orderBy
    self.ref = ref
  }
}

public func == (lhs: FirebaseRefConfig, rhs: FirebaseRefConfig) -> Bool {
  return lhs.ref == rhs.ref &&
    lhs.orderBy == rhs.orderBy
}

internal protocol FirebaseAppType {}
extension FIRApp: FirebaseAppType {}

internal protocol FirebaseDatabaseReferenceType {}
extension FIRDatabaseReference: FirebaseDatabaseReferenceType {}
