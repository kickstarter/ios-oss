import XCTest
import Result
import ReactiveCocoa
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
import Prelude

internal final class CommentsEmptyStateCellViewModelTest: TestCase {
  internal let vm: CommentsEmptyStateCellViewModelType = CommentsEmptyStateCellViewModel()
  internal let goToCommentDialog = TestObserver<Void, NoError>()
  internal let goToLoginTout = TestObserver<Void, NoError>()
  internal let leaveACommentButtonHidden = TestObserver<Bool, NoError>()
  internal let loginButtonHidden = TestObserver<Bool, NoError>()
  internal let subtitleText = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.goToCommentDialog.observe(self.goToCommentDialog.observer)
    self.vm.outputs.goToLoginTout.observe(self.goToLoginTout.observer)
    self.vm.outputs.leaveACommentButtonHidden.observe(self.leaveACommentButtonHidden.observer)
    self.vm.outputs.loginButtonHidden.observe(self.loginButtonHidden.observer)
    self.vm.outputs.subtitleText.observe(self.subtitleText.observer)
  }

  internal func testGoToCommentDialog() {
    let project = .template
      |> Project.lens.personalization.isBacking .~ true

    self.vm.inputs.configureWith(project: project, update: nil)
    self.goToCommentDialog.assertDidNotEmitValue()
    self.leaveACommentButtonHidden.assertValues([false])
    self.loginButtonHidden.assertValues([true])

    self.vm.inputs.leaveACommentTapped()
    self.goToCommentDialog.assertValueCount(1)
  }

  internal func testGoToLoginTout() {
    let project = .template
      |> Project.lens.personalization.isBacking .~ nil

    self.vm.inputs.configureWith(project: project, update: nil)
    self.goToLoginTout.assertDidNotEmitValue()
    self.leaveACommentButtonHidden.assertValues([true])
    self.loginButtonHidden.assertValues([false])

    self.vm.inputs.loginTapped()
    self.goToLoginTout.assertValueCount(1)
  }

  internal func testLoggedInNonBacking() {
    let project = .template
      |> Project.lens.personalization.isBacking .~ false

    self.vm.inputs.configureWith(project: project, update: nil)
    self.leaveACommentButtonHidden.assertValues([true])
    self.loginButtonHidden.assertValues([true])
    self.subtitleText.assertValues([Strings.project_comments_empty_state_non_backer_message()])
  }

  internal func testLoggedInBackingProject() {
    let project = .template
      |> Project.lens.personalization.isBacking .~ true

    self.vm.inputs.configureWith(project: project, update: nil)
    self.leaveACommentButtonHidden.assertValues([false])
    self.loginButtonHidden.assertValues([true])
    self.subtitleText.assertValues([Strings.project_comments_empty_state_backer_message()])
  }

  internal func testLoggedInBackingUpdate() {
    let project = .template
      |> Project.lens.personalization.isBacking .~ true

    self.vm.inputs.configureWith(project: project, update: Update.template)
    self.leaveACommentButtonHidden.assertValues([false])
    self.loginButtonHidden.assertValues([true])
    self.subtitleText.assertValues([Strings.update_comments_empty_state_backer_message()])
  }

  internal func testLoggedOut() {
    let project = .template
      |> Project.lens.personalization.isBacking .~ nil

    self.vm.inputs.configureWith(project: project, update: nil)
    self.leaveACommentButtonHidden.assertValues([true])
    self.loginButtonHidden.assertValues([false])
    self.subtitleText.assertValues([Strings.project_comments_empty_state_logged_out_message_log_in()])
  }
}
