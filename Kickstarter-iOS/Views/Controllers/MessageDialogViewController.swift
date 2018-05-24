import KsApi
import Library
import Prelude
import ReactiveExtensions
import UIKit

internal protocol MessageDialogViewControllerDelegate: class {
  func messageDialogWantsDismissal(_ dialog: MessageDialogViewController)
  func messageDialog(_ dialog: MessageDialogViewController, postedMessage: Message)
}

internal final class MessageDialogViewController: UIViewController {
  fileprivate let viewModel: MessageDialogViewModelType = MessageDialogViewModel()
  internal weak var delegate: MessageDialogViewControllerDelegate?

  @IBOutlet private weak var bodyTextView: UITextView!
  @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet private weak var cancelButton: UIBarButtonItem!
  @IBOutlet private weak var loadingView: UIView!
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var postButton: UIBarButtonItem!
  @IBOutlet private weak var titleLabel: UILabel!

  internal static func configuredWith(messageSubject: MessageSubject,
                                      context: Koala.MessageDialogContext) -> MessageDialogViewController {

    let vc = Storyboard.Messages.instantiate(MessageDialogViewController.self)
    vc.viewModel.inputs.configureWith(messageSubject: messageSubject, context: context)
    vc.modalPresentationStyle = .formSheet
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindViewModel() {
    self.nameLabel.rac.text = self.viewModel.outputs.recipientName
    self.postButton.rac.enabled = self.viewModel.outputs.postButtonEnabled
    self.loadingView.rac.hidden = self.viewModel.outputs.loadingViewIsHidden
    self.bodyTextView.rac.isFirstResponder = self.viewModel.outputs.keyboardIsVisible

    self.bottomConstraint.rac.constant = Keyboard.change
      .map { [weak self] in (self?.view.frame.height ?? 0.0) - $0.frame.minY }

    self.viewModel.outputs.notifyPresenterDialogWantsDismissal
      .observeValues { [weak self] in
        guard let _self = self else { return }
        _self.delegate?.messageDialogWantsDismissal(_self)
    }

    self.viewModel.outputs.notifyPresenterCommentWasPostedSuccesfully
      .observeValues { [weak self] message in
        guard let _self = self else { return }
        _self.postNotification()
        _self.delegate?.messageDialog(_self, postedMessage: message)
    }

    self.viewModel.outputs.showAlertMessage
      .observeForControllerAction()
      .observeValues { [weak self] in self?.presentError($0) }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.cancelButton
      |> UIBarButtonItem.lens.title %~ { _ in Strings.general_navigation_buttons_cancel() }

    _ = self.nameLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_900
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 13.0)

    _ = self.postButton
      |> UIBarButtonItem.lens.title %~ { _ in Strings.social_buttons_send() }

    _ = self.titleLabel
      |> UILabel.lens.textColor .~ .ksr_navy_600
      |> UILabel.lens.font .~ UIFont.ksr_subhead(size: 14.0)
  }

  @IBAction fileprivate func cancelButtonPressed () {
    self.viewModel.inputs.cancelButtonPressed()
  }

  @IBAction fileprivate func postButtonPressed() {
    self.viewModel.inputs.postButtonPressed()
  }

  fileprivate func presentError(_ message: String) {
    self.present(UIAlertController.genericError(message),
                               animated: true,
                               completion: nil)
  }

  private func postNotification() {
    NotificationCenter.default.post(name: Notification.Name.ksr_showNotificationsDialog,
                                    object: nil,
                                    userInfo: [UserInfoKeys.context: PushNotificationDialog.Context.message])
  }
}

extension MessageDialogViewController: UITextViewDelegate {

  internal func textViewDidChange(_ textView: UITextView) {
    self.viewModel.inputs.bodyTextChanged(textView.text)
  }
}
