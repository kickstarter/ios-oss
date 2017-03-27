import KsApi
import Library
import LiveStream
import Prelude
import ReactiveSwift
import UIKit

internal protocol LiveStreamChatInputViewDelegate: class {
  func liveStreamChatInputView(_ chatInputView: LiveStreamChatInputView, didSendMessage message: String)
  func liveStreamChatInputViewRequestedLogin(chatInputView: LiveStreamChatInputView)
}

internal final class LiveStreamChatInputView: UIView {

  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private weak var sendButton: UIButton!
  @IBOutlet private weak var separatorView: UIView!
  @IBOutlet private weak var textField: UITextField!

  private weak var delegate: LiveStreamChatInputViewDelegate?

  fileprivate let viewModel: LiveStreamChatInputViewModelType = LiveStreamChatInputViewModel()

  internal class func fromNib() -> LiveStreamChatInputView {
    return UINib(nibName: Nib.LiveStreamChatInputView.rawValue, bundle: .framework)
      .instantiate(withOwner: nil, options: nil)
      //swiftlint:disable:next force_cast
      .first as! LiveStreamChatInputView
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    self.sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    self.textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)

    self.viewModel.inputs.didAwakeFromNib()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> UIView.lens.backgroundColor .~ .ksr_navy_700

    _ = self.separatorView
      |> UIView.lens.backgroundColor .~ UIColor.white.withAlphaComponent(0.2)

    _ = self.rootStackView
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(leftRight: Styles.grid(2))
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.textField
      |> UITextField.lens.backgroundColor .~ .ksr_navy_700
      |> UITextField.lens.tintColor .~ .white
      |> UITextField.lens.textColor .~ .white
      |> UITextField.lens.font .~ .ksr_body(size: 14)
      |> UITextField.lens.borderStyle .~ .none
      |> UITextField.lens.returnKeyType .~ .done

    _ = self.sendButton
      |> UIButton.lens.tintColor .~ .white
      |> UIButton.lens.title(forState: .normal) .~ localizedString(key: "Send", defaultValue: "Send")
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.sendButton.rac.enabled = self.viewModel.outputs.sendButtonEnabled

    self.viewModel.outputs.notifyDelegateMessageSent
      .observeForUI()
      .observeValues { [weak self] text in
        self.doIfSome { $0.delegate?.liveStreamChatInputView($0, didSendMessage: text) }
    }

    self.viewModel.outputs.clearTextFieldAndResignFirstResponder
      .observeForUI()
      .observeValues { [weak self] in
        self?.textField.text = nil
        self?.textField.resignFirstResponder()
    }

    self.viewModel.outputs.notifyDelegateRequestLogin
      .observeForControllerAction()
      .observeValues { [weak self] in
        self.doIfSome { $0.delegate?.liveStreamChatInputViewRequestedLogin(chatInputView: $0) }
    }

    self.textField.rac.attributedPlaceholder = self.viewModel.outputs.placeholderText
  }

  // MARK: Actions

  @objc private func sendButtonTapped() {
    self.viewModel.inputs.sendButtonTapped()
  }

  @objc private func textFieldChanged(_ textField: UITextField) {
    textField.text.doIfSome { self.viewModel.inputs.textDidChange(toText: $0) }
  }
}

extension LiveStreamChatInputView: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    return self.viewModel.inputs.textFieldShouldBeginEditing()
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()

    return true
  }
}
