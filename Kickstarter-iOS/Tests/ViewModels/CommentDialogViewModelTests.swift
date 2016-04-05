import XCTest
import Result
import ReactiveCocoa
@testable import Kickstarter_iOS
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import Library
@testable import Models
@testable import Models_TestHelpers
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class CommentDialogViewModelTests: TestCase {
  internal let vm: CommentDialogViewModelType = CommentDialogViewModel()

  internal var postButtonEnabled = TestObserver<Bool, NoError>()
  internal var notifyPresenterOfDismissal = TestObserver<(), NoError>()
  internal var commentIsPosting = TestObserver<Bool, NoError>()
  internal var commentPostedSuccessfully = TestObserver<(), NoError>()
  internal var presentError = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.postButtonEnabled.observe(self.postButtonEnabled.observer)
    self.vm.outputs.notifyPresenterOfDismissal.observe(self.notifyPresenterOfDismissal.observer)
    self.vm.outputs.commentIsPosting.observe(self.commentIsPosting.observer)
    self.vm.outputs.commentPostedSuccessfully.observe(self.commentPostedSuccessfully.observer)
    self.vm.errors.presentError.observe(self.presentError.observer)
  }

  internal func testPostingFlow() {
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.project(ProjectFactory.live())

    self.postButtonEnabled.assertValues([false], "Button is not enabled initially.")
    self.commentIsPosting.assertValueCount(0)
    self.commentPostedSuccessfully.assertValueCount(0)
    self.notifyPresenterOfDismissal.assertValueCount(0)

    self.vm.inputs.commentBodyChanged("h")
    self.postButtonEnabled.assertValues([false, true], "Button enabled after typing comment body.")

    self.vm.inputs.commentBodyChanged("")
    self.postButtonEnabled.assertValues([false, true, false], "Button disabled after clearing body.")

    self.vm.inputs.commentBodyChanged("h")
    self.vm.inputs.commentBodyChanged("he")
    self.vm.inputs.commentBodyChanged("hel")
    self.vm.inputs.commentBodyChanged("hell")
    self.vm.inputs.commentBodyChanged("hello")

    self.postButtonEnabled.assertValues([false, true, false, true],
                                        "Button re-enabled after typing comment body.")

    self.vm.inputs.postButtonPressed()

    self.commentIsPosting.assertValues([true, false],
                                       "Comment is posting and then done after pressing button.")
    self.commentPostedSuccessfully.assertValueCount(1, "Comment posts successfully.")
    self.notifyPresenterOfDismissal.assertValueCount(1, "Dialog is dismissed after posting of comment.")

    XCTAssertEqual(["Project Comment Create"], trackingClient.events, "Koala event is tracked.")
  }

  internal func testPostingErrorFlow() {
    let error = ErrorEnvelope(
      errorMessages: ["IJC"],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(postCommentError: error)) {
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.project(ProjectFactory.live())
      self.vm.inputs.commentBodyChanged("hello")

      self.vm.inputs.postButtonPressed()

      self.presentError.assertValues(["IJC"], "Error message is emitted.")
      self.commentIsPosting.assertValues([true, false],
                                         "Comment is posting and then done after pressing button.")
      self.commentPostedSuccessfully.assertValueCount(0, "Comment does not post successfuly.")
      self.notifyPresenterOfDismissal.assertValueCount(0, "Comment dialog does not dismiss automatically.")

      XCTAssertEqual([], trackingClient.events, "Koala event is not tracked.")
    }
  }

  internal func testPostingErrorFlow_WithMissingErrorMessage() {
    let error = ErrorEnvelope(
      errorMessages: [],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(postCommentError: error)) {
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.project(ProjectFactory.live())
      self.vm.inputs.commentBodyChanged("hello")

      self.vm.inputs.postButtonPressed()

      self.presentError.assertValueCount(1, "Error message is emitted.")

      XCTAssertEqual([], trackingClient.events, "Koala event is not tracked.")
    }
  }

  internal func testCancellingFlow() {
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.project(ProjectFactory.live())

    self.vm.inputs.cancelButtonPressed()
    self.notifyPresenterOfDismissal.assertValueCount(1)
  }
}
