import KsApi
import Library
import Prelude
import ReactiveExtensions
import UIKit

internal protocol MessageDialogViewControllerDelegate: AnyObject {
  func messageDialogWantsDismissal(_ dialog: MessageDialogViewController)
  func messageDialog(_ dialog: MessageDialogViewController, postedMessage: Message)
}

internal final class MessageDialogViewController: UIViewController {
  fileprivate let viewModel: MessageDialogViewModelType = MessageDialogViewModel()
  internal weak var delegate: MessageDialogViewControllerDelegate?

  @IBOutlet private var bodyTextView: UITextView!
  @IBOutlet private var bottomConstraint: NSLayoutConstraint!
  @IBOutlet private var cancelButton: UIBarButtonItem!
  @IBOutlet private var loadingView: UIView!
  @IBOutlet private var nameLabel: UILabel!
  @IBOutlet private var postButton: UIBarButtonItem!

  internal static func configuredWith(
    messageSubject: MessageSubject,
    context: KSRAnalytics.MessageDialogContext
  ) -> MessageDialogViewController {
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
      |> UILabel.lens.textColor .~ .ksr_support_700
      |> UILabel.lens.font .~ UIFont.ksr_body().bolded

    _ = self.postButton
      |> UIBarButtonItem.lens.title %~ { _ in Strings.social_buttons_send() }
  }

  @IBAction fileprivate func cancelButtonPressed() {
    self.viewModel.inputs.cancelButtonPressed()
  }

  @IBAction fileprivate func postButtonPressed() {
    self.viewModel.inputs.postButtonPressed()
  }

  fileprivate func presentError(_ message: String) {
    self.present(
      UIAlertController.genericError(message),
      animated: true,
      completion: nil
    )
  }

  private func postNotification() {
    NotificationCenter.default.post(
      name: Notification.Name.ksr_showNotificationsDialog,
      object: nil,
      userInfo: [UserInfoKeys.context: PushNotificationDialog.Context.message]
    )
  }
}

extension MessageDialogViewController: UITextViewDelegate {
  internal func textViewDidChange(_ textView: UITextView) {
    self.viewModel.inputs.bodyTextChanged(textView.text)
  }
}
