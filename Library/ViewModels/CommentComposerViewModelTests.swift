@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class CommentComposerViewModelTests: TestCase {
  private let viewModel: CommentComposerViewModelType = CommentComposerViewModel()

  private let bodyText = TestObserver<String, Never>()
  private let avatarURL = TestObserver<URL?, Never>()
  private let inputAreaHidden = TestObserver<Bool, Never>()
  private let notifyDelegateDidSubmitText = TestObserver<String, Never>()
  private let postButtonHidden = TestObserver<Bool, Never>()
  private let placeholderHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.viewModel.outputs.bodyText.observe(self.bodyText.observer)
    self.viewModel.outputs.avatarURL.observe(self.avatarURL.observer)
    self.viewModel.outputs.inputAreaHidden.observe(self.inputAreaHidden.observer)
    self.viewModel.outputs.notifyDelegateDidSubmitText.observe(self.notifyDelegateDidSubmitText.observer)
    self.viewModel.outputs.postButtonHidden.observe(self.postButtonHidden.observer)
    self.viewModel.outputs.placeholderHidden.observe(self.placeholderHidden.observer)
  }

  func testPostingCommentFlow() {
    self.viewModel.inputs.configure(with: (nil, true))

    self.postButtonHidden.assertValues([true])
    self.placeholderHidden.assertValues([false])
    self.inputAreaHidden.assertValues([false])

    self.bodyText.assertValues([])

    self.viewModel.inputs.bodyTextDidChange("Nice Project.")

    self.postButtonHidden.assertValues([true, false])
    self.placeholderHidden.assertValues([false, true])
    self.bodyText.assertValues(["Nice Project."])

    self.viewModel.inputs.bodyTextDidChange("Nice Project. Cheers!")
    self.postButtonHidden.assertValues([true, false, false])
    self.placeholderHidden.assertValues([false, true, true])
    self.bodyText.assertValues(["Nice Project.", "Nice Project. Cheers!"])

    self.viewModel.inputs.postButtonPressed()
    self.postButtonHidden.assertValues([true, false, false])
    self.placeholderHidden.assertValues([false, true, true])
    self.bodyText.assertValues(["Nice Project.", "Nice Project. Cheers!"])
    self.notifyDelegateDidSubmitText.assertValues(["Nice Project. Cheers!"])

    self.viewModel.inputs.bodyTextDidChange("")
    self.bodyText.assertValues(["Nice Project.", "Nice Project. Cheers!", ""])
  }

  func testAvatarURL() {
    self.viewModel.inputs.configure(with: (nil, true))
    self.avatarURL.assertValues([nil])

    self.viewModel.inputs.configure(with: (URL(string: "https://avatar.png"), true))
    self.avatarURL.assertValues([nil, URL(string: "https://avatar.png")])
  }

  func testInputAreaVisibility() {
    self.viewModel.inputs.configure(with: (nil, true))
    self.inputAreaHidden.assertValues([false])

    self.viewModel.inputs.configure(with: (nil, false))
    self.inputAreaHidden.assertValues([false, true])
  }

  func testEmptyInput() {
    self.viewModel.inputs.configure(with: (nil, true))
    self.postButtonHidden.assertValues([true])
    self.placeholderHidden.assertValues([false])

    self.viewModel.inputs.bodyTextDidChange("Enough Add Ons")
    self.postButtonHidden.assertValues([true, false])
    self.placeholderHidden.assertValues([false, true])
  }

  func testPostCommentAction() {
    self.viewModel.inputs.configure(with: (nil, true))
    self.notifyDelegateDidSubmitText.assertValues([])

    self.viewModel.inputs.bodyTextDidChange("Can't wait for this")
    self.notifyDelegateDidSubmitText.assertValues([])

    self.viewModel.inputs.postButtonPressed()
    self.notifyDelegateDidSubmitText.assertValues(["Can't wait for this"])
  }
}
