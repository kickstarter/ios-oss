import Foundation
import XCTest
import ReactiveCocoa
import Result
import KsApi
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers
import Prelude

internal final class ProfileHeaderViewModelTests: TestCase {
  let vm = ProfileHeaderViewModel()
  let avatarURL = TestObserver<NSURL?, NoError>()
  let backedProjectsCountLabel = TestObserver<String, NoError>()
  let createdProjectsCountLabel = TestObserver<String, NoError>()
  let createdProjectsCountLabelHidden = TestObserver<Bool, NoError>()
  let createdProjectsLabelHidden = TestObserver<Bool, NoError>()
  let dividerViewHidden = TestObserver<Bool, NoError>()
  let userName = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.avatarURL.observe(avatarURL.observer)
    self.vm.outputs.backedProjectsCountLabel.observe(backedProjectsCountLabel.observer)
    self.vm.outputs.createdProjectsCountLabel.observe(createdProjectsCountLabel.observer)
    self.vm.outputs.createdProjectsCountLabelHidden.observe(createdProjectsCountLabelHidden.observer)
    self.vm.outputs.createdProjectsLabelHidden.observe(createdProjectsLabelHidden.observer)
    self.vm.outputs.dividerViewHidden.observe(dividerViewHidden.observer)
    self.vm.outputs.userName.observe(userName.observer)
  }

  func testUserDataEmits() {
    let user = User.template

    self.vm.inputs.user(user)

    self.avatarURL.assertValues([NSURL(string: user.avatar.large ?? user.avatar.medium)],
                                "User avatar emitted.")
    self.userName.assertValues([user.name], "User name emitted.")
  }

  func testUserWithCreatedProjects() {
    let user = User.template |> User.lens.stats.createdProjectsCount .~ 1

    withEnvironment(apiService: MockService(fetchUserSelfResponse: user)) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: user))

      self.vm.inputs.user(user)

      self.backedProjectsCountLabel.assertValues([String(user.stats.backedProjectsCount ?? 0)],
                                                 "Backed projects count emitted.")
      self.createdProjectsCountLabel.assertValues([String(user.stats.createdProjectsCount ?? 0)],
                                                  "Created projects count emitted.")

      self.createdProjectsCountLabelHidden.assertValues([false], "Created labels are not hidden.")
      self.createdProjectsLabelHidden.assertValues([false])
      self.dividerViewHidden.assertValues([false])
    }
  }

  func testUserWithNoCreatedProjects() {
    let user = User.template |> User.lens.stats.backedProjectsCount .~ 1

    self.vm.inputs.user(user)

    self.backedProjectsCountLabel.assertValues([String(user.stats.backedProjectsCount ?? 0)],
                                               "Backed projects count emits.")
    self.createdProjectsCountLabelHidden.assertValues([true])

    self.createdProjectsLabelHidden.assertValues([true], "Created labels are hidden.")
    self.createdProjectsCountLabel.assertValues(["0"])
    self.dividerViewHidden.assertValues([true])
  }
}
