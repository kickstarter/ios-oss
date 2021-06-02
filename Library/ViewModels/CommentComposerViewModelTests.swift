@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class CommentComposerViewModelTests: TestCase {
  private let vm: CommentComposerViewModelType = CommentComposerViewModel()

  private let avatarURL = TestObserver<URL?, Never>()
  private let bodyText = TestObserver<String?, Never>()
  private let clearInputTextView = TestObserver<(), Never>()
  private let inputAreaHidden = TestObserver<Bool, Never>()
  private let inputTextViewResignFirstResponder = TestObserver<(), Never>()
  private let notifyDelegateDidSubmitText = TestObserver<String, Never>()
  private let placeholderHidden = TestObserver<Bool, Never>()
  private let postButtonHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.bodyText.observe(self.bodyText.observer)
    self.vm.outputs.avatarURL.observe(self.avatarURL.observer)
    self.vm.outputs.inputAreaHidden.observe(self.inputAreaHidden.observer)
    self.vm.outputs.notifyDelegateDidSubmitText.observe(self.notifyDelegateDidSubmitText.observer)
    self.vm.outputs.postButtonHidden.observe(self.postButtonHidden.observer)
    self.vm.outputs.placeholderHidden.observe(self.placeholderHidden.observer)
    self.vm.outputs.inputTextViewResignFirstResponder.observe(self.inputTextViewResignFirstResponder.observer)
    self.vm.outputs.clearInputTextView.observe(self.clearInputTextView.observer)
  }

  func testPostingCommentFlow() {
    self.vm.inputs.configure(with: (nil, true))

    self.postButtonHidden.assertValues([true])
    self.placeholderHidden.assertValues([false])
    self.inputAreaHidden.assertValues([false])

    self.bodyText.assertValues([])

    self.vm.inputs.bodyTextDidChange("Nice Project.")

    self.postButtonHidden.assertValues([true, false])
    self.placeholderHidden.assertValues([false, true])
    self.bodyText.assertValues(["Nice Project."])

    self.vm.inputs.bodyTextDidChange("Nice Project. Cheers!")
    self.postButtonHidden.assertValues([true, false, false])
    self.placeholderHidden.assertValues([false, true, true])
    self.bodyText.assertValues(["Nice Project.", "Nice Project. Cheers!"])

    self.vm.inputs.postButtonPressed()
    self.postButtonHidden.assertValues([true, false, false])
    self.placeholderHidden.assertValues([false, true, true])
    self.bodyText.assertValues(["Nice Project.", "Nice Project. Cheers!"])
    self.notifyDelegateDidSubmitText.assertValues(["Nice Project. Cheers!"])

    self.vm.inputs.resetInput()
    self.bodyText.assertValues(["Nice Project.", "Nice Project. Cheers!", nil])
    self.postButtonHidden.assertValues([true, false, false, true])
    self.placeholderHidden.assertValues([false, true, true, false])
    self.inputTextViewResignFirstResponder.assertDidEmitValue()
    self.clearInputTextView.assertValueCount(1)
  }

  func testAvatarURL() {
    self.vm.inputs.configure(with: (nil, true))
    self.avatarURL.assertValues([nil])

    self.vm.inputs.configure(with: (URL(string: "https://avatar.png"), true))
    self.avatarURL.assertValues([nil, URL(string: "https://avatar.png")])
  }

  func testInputAreaVisibility() {
    self.vm.inputs.configure(with: (nil, true))
    self.inputAreaHidden.assertValues([false])

    self.vm.inputs.configure(with: (nil, false))
    self.inputAreaHidden.assertValues([false, true])
  }

  func testEmptyInput() {
    self.vm.inputs.configure(with: (nil, true))
    self.postButtonHidden.assertValues([true])
    self.placeholderHidden.assertValues([false])

    self.vm.inputs.bodyTextDidChange("Enough Add Ons")
    self.postButtonHidden.assertValues([true, false])
    self.placeholderHidden.assertValues([false, true])
  }

  func testPostCommentAction() {
    self.vm.inputs.configure(with: (nil, true))
    self.notifyDelegateDidSubmitText.assertValues([])

    self.vm.inputs.bodyTextDidChange("Can't wait for this")
    self.notifyDelegateDidSubmitText.assertValues([])

    self.vm.inputs.postButtonPressed()
    self.notifyDelegateDidSubmitText.assertValues(["Can't wait for this"])
  }

  func testTextViewShouldChangeTextInRange_LengthExceeded() {
    let current = String(Array(repeating: "1", count: CommentComposerConstant.characterLimit))

    let range = (current as NSString).range(of: current)
    let replacement = current + "1"

    XCTAssertFalse(
      self.vm.inputs.textViewShouldChange(text: current, in: range, replacementText: replacement)
    )
  }

  func testTextViewShouldChangeTextInRange_LengthUnchanged() {
    let current = String(Array(repeating: "1", count: CommentComposerConstant.characterLimit))

    let range = (current as NSString).range(of: current)
    let replacement = current

    XCTAssertTrue(self.vm.inputs.textViewShouldChange(text: current, in: range, replacementText: replacement))
  }

  func testTextViewShouldChangeTextInRange_LengthShorter() {
    let current = String(Array(repeating: "1", count: CommentComposerConstant.characterLimit))
    let range = (current as NSString).range(of: current)
    let replacement = String(current.dropLast())

    XCTAssertTrue(self.vm.inputs.textViewShouldChange(text: current, in: range, replacementText: replacement))
  }
}
