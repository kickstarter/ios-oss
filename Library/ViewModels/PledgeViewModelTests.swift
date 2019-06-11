import Foundation
import Prelude
import ReactiveExtensions
import ReactiveSwift
import Result
import XCTest

@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers

final class PledgeViewModelTests: TestCase {
  private let vm: PledgeViewModelType = PledgeViewModel()

  private let project = TestObserver<Project, Never>()
  private let reward = TestObserver<Reward, Never>()
  private let isLoggedIn = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.reloadWithData.map { $0.0 }.observe(self.project.observer)
    self.vm.outputs.reloadWithData.map { $0.1 }.observe(self.reward.observer)
    self.vm.outputs.reloadWithData.map { $0.2 }.observe(self.isLoggedIn.observer)
  }

  func testReloadWithData_loggedOut() {
    withEnvironment(currentUser: nil) {
      let project = Project.template
      let reward = Reward.template

      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.project.assertValues([project])
      self.reward.assertValues([reward])
      self.isLoggedIn.assertValues([false])
    }
  }

  func testReloadWithData_loggedIn() {
    let project = Project.template
    let reward = Reward.template
    let user = User.template

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.project.assertValues([project])
      self.reward.assertValues([reward])
      self.isLoggedIn.assertValues([true])
    }
  }
}
