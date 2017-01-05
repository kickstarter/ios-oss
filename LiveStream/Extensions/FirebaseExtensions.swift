import FirebaseAnalytics
import FirebaseDatabase

public struct FirebaseRefConfig {
  // FIXME: alphabetize
  let ref: String
  let orderBy: String

  public init(ref: String, orderBy: String) {
    self.ref = ref
    self.orderBy = orderBy
  }
}

internal protocol FirebaseAppType {}
extension FIRApp: FirebaseAppType {}

// FIXME: rename to FirebaseDatabaseReferenceType
internal protocol FirebaseDatabaseRefType {}
extension FIRDatabaseReference: FirebaseDatabaseRefType {}
