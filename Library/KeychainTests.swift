@testable import Library
import XCTest

final class KeychainTests: XCTestCase {
  let password = "hello1234"
  let account = "world@world.com"

  override func tearDown() {
    try! Keychain.deleteAllPasswords()
  }

  func testDeleteAllPasswords_hasThreePasswords_removesAllPasswords() {
    try! Keychain.storePassword("one", forAccount: "one")
    try! Keychain.storePassword("two", forAccount: "two")
    try! Keychain.storePassword("three", forAccount: "three")

    XCTAssertTrue(Keychain.hasPassword(forAccount: "one"))
    XCTAssertTrue(Keychain.hasPassword(forAccount: "two"))
    XCTAssertTrue(Keychain.hasPassword(forAccount: "three"))

    try! Keychain.deleteAllPasswords()

    XCTAssertFalse(Keychain.hasPassword(forAccount: "one"))
    XCTAssertFalse(Keychain.hasPassword(forAccount: "two"))
    XCTAssertFalse(Keychain.hasPassword(forAccount: "three"))
  }

  func testDeleteAllPasswords_hasNoPasswords_doesNotThrow() {
    XCTAssertFalse(Keychain.hasPassword(forAccount: self.account))
    XCTAssertNoThrow(try Keychain.deleteAllPasswords())
  }

  func testStorePassword_alreadyHasPassword_overwritesPassword() {
    XCTAssertFalse(Keychain.hasPassword(forAccount: self.account))

    try! Keychain.storePassword(self.password, forAccount: self.account)

    guard let fetchedPassword1 = try! Keychain.fetchPassword(forAccount: account) else {
      XCTFail()
      return
    }

    XCTAssertEqual(self.password, fetchedPassword1)

    let newPassword = "new password"
    try! Keychain.storePassword(newPassword, forAccount: self.account)

    guard let fetchedPassword2 = try! Keychain.fetchPassword(forAccount: account) else {
      XCTFail()
      return
    }

    XCTAssertEqual(newPassword, fetchedPassword2)
  }

  func testStorePassword_alreadyHasMultiplePasswords_overwritesPasswordForCorrectAccount() {
    try! Keychain.storePassword("one", forAccount: "one")
    try! Keychain.storePassword("two", forAccount: "two")

    guard let fetchedPassword1 = try! Keychain.fetchPassword(forAccount: "one") else {
      XCTFail()
      return
    }

    XCTAssertEqual("one", fetchedPassword1)

    let newPassword = "new password"
    try! Keychain.storePassword(newPassword, forAccount: "one")

    guard let fetchedPassword2 = try! Keychain.fetchPassword(forAccount: "one") else {
      XCTFail()
      return
    }

    XCTAssertEqual(newPassword, fetchedPassword2)

    guard let unchangedPassword = try! Keychain.fetchPassword(forAccount: "two") else {
      XCTFail()
      return
    }

    XCTAssertEqual(unchangedPassword, "two")
  }

  func testStorePassword_hasNoPassword_savesNewPassword() {
    XCTAssertFalse(Keychain.hasPassword(forAccount: self.account))

    try! Keychain.storePassword(self.password, forAccount: self.account)

    guard let fetchedPassword1 = try! Keychain.fetchPassword(forAccount: account) else {
      XCTFail()
      return
    }

    XCTAssertEqual(self.password, fetchedPassword1)
  }

  func testFetchPassword_hasStoredPassword_returnsPassword() {
    try! Keychain.storePassword(self.password, forAccount: self.account)

    guard let fetchedPassword = try! Keychain.fetchPassword(forAccount: account) else {
      XCTFail()
      return
    }

    XCTAssertEqual(fetchedPassword, self.password)
  }

  func testFetchPassword_hasNoPassword_returnsNil() {
    XCTAssertFalse(Keychain.hasPassword(forAccount: self.account))
    let fetchedPassword = try! Keychain.fetchPassword(forAccount: self.account)
    XCTAssertNil(fetchedPassword)
  }

  func testHasPassword_hasNoPassword_returnsFalse() {
    XCTAssertFalse(Keychain.hasPassword(forAccount: self.account))
  }

  func testHasPassword_hasPassword_returnsTrue() {
    try! Keychain.storePassword(self.password, forAccount: self.account)
    XCTAssertTrue(Keychain.hasPassword(forAccount: self.account))
  }

  func testDeletePassword_hasStoredPassword_removesPassword() {
    try! Keychain.storePassword(self.password, forAccount: self.account)
    XCTAssertTrue(Keychain.hasPassword(forAccount: self.account))

    try! Keychain.deletePassword(forAccount: self.account)

    XCTAssertFalse(Keychain.hasPassword(forAccount: self.account))
  }

  func testDeletePassword_hasNoStoredPassword_doesNotThrow() {
    XCTAssertFalse(Keychain.hasPassword(forAccount: self.account))
    XCTAssertNoThrow(try Keychain.deletePassword(forAccount: self.account))
  }

  func testDeletePassword_hasMultipleStoredPasswords_removesOnlyCorrectPassword() {
    try! Keychain.storePassword("one", forAccount: "one")
    try! Keychain.storePassword("two", forAccount: "two")

    XCTAssertTrue(Keychain.hasPassword(forAccount: "one"))
    XCTAssertTrue(Keychain.hasPassword(forAccount: "two"))

    try! Keychain.deletePassword(forAccount: "one")

    XCTAssertFalse(Keychain.hasPassword(forAccount: "one"))
    XCTAssertTrue(Keychain.hasPassword(forAccount: "two"))
  }
}
