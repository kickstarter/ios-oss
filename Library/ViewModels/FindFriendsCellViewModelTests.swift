import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import Library
@testable import KsApi
@testable import Kickstarter_Framework
@testable import ReactiveExtensions_TestHelpers

import Foundation

internal final class FindFriendsCellViewModelTests: TestCase {
  private let vm = FindFriendsCellViewModel()

  private let isDisabled = TestObserver<Bool, NoError>()

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
