import Library
import KsApi
import ReactiveExtensions
import UIKit

internal protocol MessageDialogViewControllerDelegate: class {
  func messageDialogWantsDismissal(dialog: MessageDialogViewController)
  func messageDialog(dialog: MessageDialogViewController, postedMessage: Message)
}

internal final class MessageDialogViewController: UIViewController {
  private let viewModel: MessageDialogViewModelType = MessageDialogViewModel()
  internal weak var delegate: MessageDialogViewControllerDelegate?

  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var postButton: UIBarButtonItem!
  @IBOutlet private weak var bodyTextView: UITextView!
  @IBOutlet private weak var loadingView: UIView!
  @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!

  internal static func configuredWith(messageSubject messageSubject: MessageSubject,
                                      context: Koala.MessageDialogContext) -> MessageDialogViewController {

    let vc = Storyboard.Messages.instantiate(MessageDialogViewController)
    vc.viewModel.inputs.configureWith(messageSubject: messageSubject, context: context)
    vc.modalPresentationStyle = .FormSheet
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
      .observeNext { [weak self] in
        guard let _self = self else { return }
        _self.delegate?.messageDialogWantsDismissal(_self)
    }

    self.viewModel.outputs.notifyPresenterCommentWasPostedSuccesfully
      .observeNext { [weak self] message in
        guard let _self = self else { return }
        _self.delegate?.messageDialog(_self, postedMessage: message)
    }

    self.viewModel.outputs.showAlertMessage
      .observeForControllerAction()
      .observeNext { [weak self] in self?.presentError($0) }
  }

  @IBAction private func cancelButtonPressed () {
    self.viewModel.inputs.cancelButtonPressed()
  }

  @IBAction private func postButtonPressed() {
    self.viewModel.inputs.postButtonPressed()
  }

  private func presentError(message: String) {
    self.presentViewController(UIAlertController.genericError(message),
                               animated: true,
                               completion: nil)
  }
}

extension MessageDialogViewController: UITextViewDelegate {

  internal func textViewDidChange(textView: UITextView) {
    self.viewModel.inputs.bodyTextChanged(textView.text)
  }
}
