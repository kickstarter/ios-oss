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

  private let disabledDescriptionLabelIsHiddenObserver = TestObserver<Bool, NoError>()
  private let isDisabledObserver = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.disabledDescriptionLabelIsHidden
      .observe(disabledDescriptionLabelIsHiddenObserver.observer)
    self.vm.outputs.isDisabled.observe(isDisabledObserver.observer)
  }

  func testCell_userFollowingEnabled() {
    let user = User.template |> User.lens.social .~ true

    self.vm.configure(with: user)

    self.disabledDescriptionLabelIsHiddenObserver.assertValue(true)
    self.isDisabledObserver.assertValue(false)
  }

  func testCell_userFollowingDisabled() {
    let user = User.template |> User.lens.social .~ false

    self.vm.configure(with: user)

    self.disabledDescriptionLabelIsHiddenObserver.assertValue(false)
    self.isDisabledObserver.assertValue(true)
  }

}
