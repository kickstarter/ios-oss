import XCTest
import Result
import ReactiveCocoa
@testable import KsApi
@testable import Library
@testable import KsApi
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class CommentDialogViewModelTests: TestCase {
  internal let vm: CommentDialogViewModelType = CommentDialogViewModel()

  internal var postButtonEnabled = TestObserver<Bool, NoError>()
  internal var loadingViewIsHidden = TestObserver<Bool, NoError>()
  internal var presentError = TestObserver<String, NoError>()
  internal let notifyPresenterCommentWasPostedSuccesfully = TestObserver<Comment, NoError>()
  internal let notifyPresenterDialogWantsDismissal = TestObserver<(), NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.postButtonEnabled.observe(self.postButtonEnabled.observer)
    self.vm.outputs.notifyPresenterDialogWantsDismissal
      .observe(self.notifyPresenterDialogWantsDismissal.observer)
    self.vm.outputs.loadingViewIsHidden.observe(self.loadingViewIsHidden.observer)
    self.vm.outputs.notifyPresenterCommentWasPostedSuccesfully
      .observe(self.notifyPresenterCommentWasPostedSuccesfully.observer)
    self.vm.errors.presentError.observe(self.presentError.observer)
  }

  internal func testPostingFlow_Project() {
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.project(Project.template, update: nil)

    self.postButtonEnabled.assertValues([false], "Button is not enabled initially.")
    self.loadingViewIsHidden.assertValues([true], "Loading view starts hidden")

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

    self.loadingViewIsHidden.assertValues([true, false, true],
                                          "Comment is posting and then done after pressing button.")
    self.notifyPresenterCommentWasPostedSuccesfully.assertValueCount(1, "Comment posts successfully.")
    self.notifyPresenterDialogWantsDismissal
      .assertValueCount(1, "Dialog is dismissed after posting of comment.")

    XCTAssertEqual(["Project Comment Create"], self.trackingClient.events, "Koala event is tracked.")
  }

  internal func testPostingFlow_Update() {
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.project(Project.template, update: Update.template)

    self.postButtonEnabled.assertValues([false], "Button is not enabled initially.")
    self.loadingViewIsHidden.assertValues([true], "Loading view starts hidden")

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

    self.loadingViewIsHidden.assertValues([true, false, true],
                                          "Comment is posting and then done after pressing button.")
    self.notifyPresenterCommentWasPostedSuccesfully.assertValueCount(1, "Comment posts successfully.")
    self.notifyPresenterDialogWantsDismissal
      .assertValueCount(1, "Dialog is dismissed after posting of comment.")

    XCTAssertEqual(["Update Comment Create"], self.trackingClient.events, "Koala event is tracked.")
  }

  internal func testPostingErrorFlow() {
    let error = ErrorEnvelope(
      errorMessages: ["ijc"],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(postCommentError: error)) {
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.project(Project.template, update: nil)
      self.vm.inputs.commentBodyChanged("hello")

      self.vm.inputs.postButtonPressed()

      self.presentError.assertValues(["ijc"], "Error message is emitted.")
      self.loadingViewIsHidden.assertValues([true, false, true],
                                            "Comment is posting and then done after pressing button.")
      self.notifyPresenterCommentWasPostedSuccesfully
        .assertValueCount(0, "Comment does not post successfuly.")
      self.notifyPresenterDialogWantsDismissal
        .assertValueCount(0, "Comment dialog does not dismiss automatically.")

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
      self.vm.inputs.project(Project.template, update: nil)
      self.vm.inputs.commentBodyChanged("hello")

      self.vm.inputs.postButtonPressed()

      self.presentError.assertValueCount(1, "Error message is emitted.")

      XCTAssertEqual([], trackingClient.events, "Koala event is not tracked.")
    }
  }

  internal func testCancellingFlow() {
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.project(Project.template, update: nil)

    self.vm.inputs.cancelButtonPressed()
    self.notifyPresenterDialogWantsDismissal.assertValueCount(1)
  }
}
