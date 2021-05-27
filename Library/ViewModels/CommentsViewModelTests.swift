@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CommentsViewModelTests: TestCase {
  private let vm: CommentsViewModelType = CommentsViewModel()

  private let configureCommentComposerViewURL = TestObserver<URL?, Never>()
  private let configureCommentComposerViewIsBacking = TestObserver<Bool, Never>()
  private let isCommentComposerHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureCommentComposerViewWithData.map(first)
      .observe(self.configureCommentComposerViewURL.observer)
    self.vm.outputs.configureCommentComposerViewWithData.map(second)
      .observe(self.configureCommentComposerViewIsBacking.observer)
    self.vm.outputs.isCommentComposerHidden.observe(self.isCommentComposerHidden.observer)
  }

  func testOutput_ConfigureCommentComposerViewWithData_IsLoggedOut() {
    self.configureCommentComposerViewURL.assertDidNotEmitValue()
    self.configureCommentComposerViewIsBacking.assertDidNotEmitValue()

    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()

      self.configureCommentComposerViewURL
        .assertValues([nil], "nil is emitted because the user is not logged in.")
      self.configureCommentComposerViewIsBacking
        .assertValues([false], "false is emitted because the project is not backed.")
    }
  }

  func testOutput_ConfigureCommentComposerViewWithData_IsLoggedIn_IsBacking_False() {
    let user = User.template |> \.id .~ 12_345

    self.configureCommentComposerViewURL.assertDidNotEmitValue()
    self.configureCommentComposerViewIsBacking.assertDidNotEmitValue()

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()

      self.configureCommentComposerViewURL
        .assertValues(
          [URL(string: "http://www.kickstarter.com/medium.jpg")],
          "An URL is emitted because the user is logged in."
        )
      self.configureCommentComposerViewIsBacking
        .assertValues([false], "false is emitted because the project is not backed.")
    }
  }

  func testOutput_ConfigureCommentComposerViewWithData_IsLoggedIn_IsBacking_True() {
    let project = Project.template
      |> \.personalization.isBacking .~ true

    let user = User.template |> \.id .~ 12_345

    self.configureCommentComposerViewURL.assertDidNotEmitValue()
    self.configureCommentComposerViewIsBacking.assertDidNotEmitValue()

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(project: project)
      self.vm.inputs.viewDidLoad()

      self.configureCommentComposerViewURL
        .assertValues(
          [URL(string: "http://www.kickstarter.com/medium.jpg")],
          "An URL is emitted because the user is logged in."
        )
      self.configureCommentComposerViewIsBacking
        .assertValues([true], "true is emitted because the project is backed.")
    }
  }

  func testOutput_IsCommentComposerHidden_False() {
    let user = User.template |> \.id .~ 12_345

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()

      self.isCommentComposerHidden.assertValue(false)
    }
  }

  func testOutput_IsCommentComposerHidden_True() {
    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: .template)
      self.vm.inputs.viewDidLoad()

      self.isCommentComposerHidden.assertValue(true)
    }
  }
}
