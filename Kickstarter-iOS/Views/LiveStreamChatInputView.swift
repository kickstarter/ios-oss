import KsApi
import Library
import LiveStream
import Prelude
import ReactiveSwift
import UIKit

//FIXME: remove this once other PR is merged that includes it
public enum Nib: String {
  case LiveStreamChatInputView
}

internal protocol LiveStreamChatInputViewDelegate: class {
  func liveStreamChatInputViewDidTapMoreButton(chatInputView: LiveStreamChatInputView)
  func liveStreamChatInputViewDidSend(chatInputView: LiveStreamChatInputView, message: String)
  func liveStreamChatInputViewRequestedLogin(chatInputView: LiveStreamChatInputView)
}

internal final class LiveStreamChatInputView: UIView {

  @IBOutlet private weak var moreButton: UIButton!
  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private weak var sendButton: UIButton!
  @IBOutlet private weak var separatorView: UIView!
  @IBOutlet private weak var textField: UITextField!

  private weak var delegate: LiveStreamChatInputViewDelegate?

  let viewModel: LiveStreamChatInputViewModelType = LiveStreamChatInputViewModel()

  internal class func fromNib() -> LiveStreamChatInputView? {
    return UINib(nibName: Nib.LiveStreamChatInputView.rawValue, bundle: .framework)
      .instantiate(withOwner: nil, options: nil)
      .first as? LiveStreamChatInputView
  }

  internal func configureWith(delegate: LiveStreamChatInputViewDelegate) {
    self.delegate = delegate
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> UIView.lens.backgroundColor .~ UIColor.hex(0x353535)

    _ = self.separatorView
      |> UIView.lens.backgroundColor .~ UIColor.white.withAlphaComponent(0.2)

    _ = self.rootStackView
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(leftRight: Styles.grid(2))
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.textField
      |> UITextField.lens.backgroundColor .~ UIColor.hex(0x353535)
      |> UITextField.lens.tintColor .~ .white
      |> UITextField.lens.textColor .~ .white
      |> UITextField.lens.font .~ .ksr_body(size: 14)
      |> UITextField.lens.borderStyle .~ .none
      |> UITextField.lens.returnKeyType .~ .done

    self.textField.attributedPlaceholder = NSAttributedString(
      string: localizedString(key: "Say_something_kind", defaultValue: "Say something kind..."),
      attributes: [
        NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8),
        NSFontAttributeName: UIFont.ksr_body(size: 14)
      ]
    )

    _ = self.sendButton
      |> UIButton.lens.tintColor .~ .white
      |> UIButton.lens.title(forState: .normal) .~ localizedString(key: "Send", defaultValue: "Send")

    _ = self.moreButton
      |> UIButton.lens.tintColor .~ .white
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.moreButton.addTarget(self, action: #selector(LiveStreamChatInputView.more), for: .touchUpInside)
    self.sendButton.addTarget(self, action: #selector(LiveStreamChatInputView.send), for: .touchUpInside)

    self.moreButton.rac.hidden = self.viewModel.outputs.moreButtonHidden
    self.sendButton.rac.hidden = self.viewModel.outputs.sendButtonHidden

    self.viewModel.outputs.notifyDelegateMoreButtonTapped.observeValues { [weak self] in
      self.flatMap { $0.delegate?.liveStreamChatInputViewDidTapMoreButton(chatInputView: $0) }
    }

    self.viewModel.outputs.notifyDelegateMessageSent
      .observeForUI()
      .on(value: { [weak self] _ in
        self?.textField.text = nil
        self?.textField.resignFirstResponder()
      })
      .observeValues { [weak self] text in
        self.flatMap { $0.delegate?.liveStreamChatInputViewDidSend(chatInputView: $0, message: text) }
    }

    self.viewModel.outputs.notifyDelegateRequestLogin
      .observeForControllerAction()
      .observeValues { [weak self] in
        self.flatMap { $0.delegate?.liveStreamChatInputViewRequestedLogin(chatInputView: $0) }
    }
  }

  internal override func layoutSubviews() {
    super.layoutSubviews()

    self.viewModel.inputs.layoutSubviews()
  }

  // MARK: Actions

  @objc private func more() {
    self.viewModel.inputs.moreButtonTapped()
  }

  @objc private func send() {
    self.viewModel.inputs.sendButtonTapped()
  }
}

extension LiveStreamChatInputView: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    self.viewModel.inputs.textFieldDidBeginEditing()
    return AppEnvironment.current.currentUser != nil
  }

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    let text = textField.text.coalesceWith("") as NSString
    let newText = text.replacingCharacters(in: range, with: string)

    self.viewModel.inputs.textDidChange(toText: newText)

    return true
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()

    return true
  }
}
