@testable import KsApi
@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CommentDialogViewModelTests: TestCase {
  internal let vm: CommentDialogViewModelType = CommentDialogViewModel()

  internal let bodyTextViewText = TestObserver<String, Never>()
  internal var postButtonEnabled = TestObserver<Bool, Never>()
  internal var loadingViewIsHidden = TestObserver<Bool, Never>()
  internal var presentError = TestObserver<String, Never>()
  internal let notifyPresenterCommentWasPostedSuccesfully = TestObserver<Comment, Never>()
  internal let notifyPresenterDialogWantsDismissal = TestObserver<(), Never>()
  internal let showKeyboard = TestObserver<Bool, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.bodyTextViewText.observe(self.bodyTextViewText.observer)
    self.vm.outputs.postButtonEnabled.observe(self.postButtonEnabled.observer)
    self.vm.outputs.notifyPresenterDialogWantsDismissal
      .observe(self.notifyPresenterDialogWantsDismissal.observer)
    self.vm.outputs.loadingViewIsHidden.observe(self.loadingViewIsHidden.observer)
    self.vm.outputs.notifyPresenterCommentWasPostedSuccesfully
      .observe(self.notifyPresenterCommentWasPostedSuccesfully.observer)
    self.vm.errors.presentError.observe(self.presentError.observer)
    self.vm.outputs.showKeyboard.observe(self.showKeyboard.observer)
  }

  func testBodyTextViewText_WithoutRecipient() {
    self.vm.inputs
      .configureWith(project: .template, update: nil, recipientName: nil, context: .projectComments)
    self.vm.inputs.viewWillAppear()

    self.bodyTextViewText.assertValueCount(0)
  }

  func testBodyTextViewText_WithRecipient() {
    let author = ActivityCommentAuthor.template
    self.vm.inputs.configureWith(
      project: .template,
      update: nil,
      recipientName: author.name,
      context: .projectComments
    )
    self.vm.inputs.viewWillAppear()

    self.bodyTextViewText.assertValues(["@\(author.name): "])
  }

  internal func testPostingFlow_Project() {
    withEnvironment(apiService: MockService(postCommentResult: .success(.template)), currentUser: .template) {
      self.vm.inputs
        .configureWith(project: .template, update: nil, recipientName: nil, context: .projectComments)
      self.vm.inputs.viewWillAppear()

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

      self.postButtonEnabled.assertValues(
        [false, true, false, true],
        "Button re-enabled after typing comment body."
      )

      self.vm.inputs.postButtonPressed()

      self.scheduler.advance(by: .seconds(1))

      self.loadingViewIsHidden.assertValues(
        [true, false, true],
        "Comment is posting and then done after pressing button."
      )
      self.notifyPresenterCommentWasPostedSuccesfully
        .assertValueCount(
          2,
          "Comment posts successfully. Two comments are posted, one optimistically and another when network returns response."
        )
      self.notifyPresenterDialogWantsDismissal
        .assertValueCount(
          2,
          "Dialog is dismissed after posting of comment. Two dismissals because of two comments being posted, not ideal."
        )

      XCTAssertEqual(
        [],
        self.segmentTrackingClient.events, "Koala event is tracked."
      )
      XCTAssertEqual(
        [],
        self.segmentTrackingClient.properties(forKey: "type", as: String.self)
      )
    }
  }

  internal func testPostingFlow_Update() {
    withEnvironment(apiService: MockService(postCommentResult: .success(.template)), currentUser: .template) {
      self.vm.inputs.configureWith(
        project: .template, update: .template, recipientName: nil,
        context: .updateComments
      )
      self.vm.inputs.viewWillAppear()

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

      self.postButtonEnabled.assertValues(
        [false, true, false, true],
        "Button re-enabled after typing comment body."
      )

      self.vm.inputs.postButtonPressed()

      self.scheduler.advance(by: .seconds(1))

      self.loadingViewIsHidden.assertValues(
        [true, false, true],
        "Comment is posting and then done after pressing button."
      )
      self.notifyPresenterCommentWasPostedSuccesfully
        .assertValueCount(
          2,
          "Comment posts successfully. Two comments are posted, one optimistically and another when network returns response."
        )
      self.notifyPresenterDialogWantsDismissal
        .assertValueCount(
          2,
          "Dialog is dismissed after posting of comment. Two dismissals because of two comments being posted, not ideal."
        )

      XCTAssertEqual(
        [],
        self.segmentTrackingClient.events, "Koala event is tracked."
      )
      XCTAssertEqual(
        [],
        self.segmentTrackingClient.properties(forKey: "type", as: String.self)
      )
    }
  }

  internal func testPostingErrorFlow() {
    withEnvironment(
      apiService: MockService(postCommentResult: .failure(.couldNotParseJSON)),
      currentUser: .template
    ) {
      self.vm.inputs
        .configureWith(project: .template, update: nil, recipientName: nil, context: .projectComments)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.commentBodyChanged("hello")

      self.vm.inputs.postButtonPressed()

      self.scheduler.advance(by: .seconds(1))

      self.presentError.assertValues(["Something went wrong, please try again."], "Error message is emitted.")
      self.loadingViewIsHidden.assertValues(
        [true, false, true],
        "Comment is posting and then done after pressing button."
      )

      self.notifyPresenterCommentWasPostedSuccesfully
        .assertValueCount(
          1,
          "Comment does not post successfuly. However, because comments are posted optimistically, we still count this as successful post. See //FIXME in view model for more info."
        )
      self.notifyPresenterDialogWantsDismissal
        .assertValueCount(
          1,
          "Comment dialog does not dismiss automatically. However, because comments are posted optimistically, we still dismiss the dialog. See //FIXME in view model for more info."
        )
    }
  }

  internal func testPostingErrorFlow_WithMissingErrorMessage() {
    withEnvironment(
      apiService: MockService(postCommentResult: .failure(.couldNotParseJSON)),
      currentUser: .template
    ) {
      self.vm.inputs
        .configureWith(project: .template, update: nil, recipientName: nil, context: .projectComments)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.commentBodyChanged("hello")

      self.vm.inputs.postButtonPressed()

      self.scheduler.advance(by: .seconds(1))

      self.presentError
        .assertValueCount(
          1,
          "Error message is emitted. Not displayed to user. See //FIXME in view model for more info."
        )

      XCTAssertEqual([], self.segmentTrackingClient.events)
    }
  }

  internal func testCancellingFlow() {
    self.vm.inputs
      .configureWith(project: .template, update: nil, recipientName: nil, context: .projectComments)
    self.vm.inputs.viewWillAppear()

    self.vm.inputs.cancelButtonPressed()
    self.notifyPresenterDialogWantsDismissal.assertValueCount(1)

    XCTAssertEqual([], self.segmentTrackingClient.events)
  }

  func testShowKeyboard() {
    self.vm.inputs
      .configureWith(project: .template, update: nil, recipientName: nil, context: .projectComments)
    self.vm.inputs.viewWillAppear()

    self.showKeyboard.assertValues([true])

    self.vm.inputs.viewWillDisappear()

    self.showKeyboard.assertValues([true, false])
  }
}
