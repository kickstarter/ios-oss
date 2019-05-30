import Prelude
import ReactiveSwift
import XCTest
@testable import Library
@testable import KsApi
import ReactiveExtensions_TestHelpers

import Foundation

internal final class FindFriendsCellViewModelTests: TestCase {
  private let vm = FindFriendsCellViewModel()

  private let isDisabled = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.isDisabled.observe(isDisabled.observer)
  }

  func testCell_userFollowingEnabled() {
    let user = User.template |> \.social .~ true

    self.vm.configure(with: user)

    self.isDisabled.assertValue(false)
  }

  func testCell_userFollowingDisabled() {
    let user = User.template |> \.social .~ false

    self.vm.configure(with: user)

    self.isDisabled.assertValue(true)
  }
}
