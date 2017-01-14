import UIKit
import KsApi
import Prelude
import ReactiveSwift
import Result
import ReactiveExtensions
import Library

internal protocol CommentDialogDelegate: class {
  func commentDialogWantsDismissal(_ dialog: CommentDialogViewController)
  func commentDialog(_ dialog: CommentDialogViewController, postedComment: Comment)
}

internal final class CommentDialogViewController: UIViewController {
  fileprivate let viewModel: CommentDialogViewModelType = CommentDialogViewModel()
  internal weak var delegate: CommentDialogDelegate?

  @IBOutlet fileprivate weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var cancelButton: UIBarButtonItem!
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var subtitleLabel: UILabel!
  @IBOutlet fileprivate weak var bodyTextView: UITextView!
  @IBOutlet fileprivate weak var postButton: UIBarButtonItem!
  @IBOutlet fileprivate weak var loadingView: UIView!

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  internal override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.viewModel.inputs.viewWillDisappear()
  }

  internal static func configuredWith(project: Project, update: Update?, recipient: User?,
                                      context: Koala.CommentDialogContext) -> CommentDialogViewController {
    let vc: CommentDialogViewController = Storyboard.Comments.instantiate()
    vc.viewModel.inputs.configureWith(project: project, update: update, recipient: recipient,
                                      context: context)
    return vc
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.postButton
      |> UIBarButtonItem.lens.title %~ { _ in Strings.social_buttons_post() }

    _ = self.titleLabel
      |> UILabel.lens.text %~ { _ in Strings.Public_comment() }

    _ = self.cancelButton
      |> UIBarButtonItem.lens.title %~ { _ in
        Strings.dashboard_post_update_compose_attachment_buttons_cancel()
    }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.bodyTextView.rac.text = self.viewModel.outputs.bodyTextViewText
    self.postButton.rac.enabled = self.viewModel.outputs.postButtonEnabled
    self.subtitleLabel.rac.text = self.viewModel.outputs.subtitle
    self.loadingView.rac.hidden = self.viewModel.outputs.loadingViewIsHidden

    self.viewModel.outputs.showKeyboard
      .observeForControllerAction()
      .observeValues { [weak textView = self.bodyTextView] show in
        _ = show ? textView?.becomeFirstResponder() : textView?.resignFirstResponder()
    }

    self.viewModel.outputs.notifyPresenterDialogWantsDismissal
      .observeForControllerAction()
      .observeValues { [weak self] in self?.notifyPresenterOfDismissal() }

    self.viewModel.outputs.notifyPresenterCommentWasPostedSuccesfully
      .observeForControllerAction()
      .observeValues { [weak self] in self?.commentPostedSuccessfully($0) }

    self.viewModel.errors.presentError
      .observeForControllerAction()
      .observeValues { [weak self] in self?.presentError($0) }

    Keyboard.change.observeForUI()
      .observeValues { [weak self] in self?.animateTextViewConstraint($0) }
  }

  @IBAction internal func cancelButtonPressed() {
    self.viewModel.inputs.cancelButtonPressed()
  }

  @IBAction internal func postButtonPressed() {
    self.viewModel.inputs.postButtonPressed()
  }

  fileprivate func notifyPresenterOfDismissal() {
    self.delegate?.commentDialogWantsDismissal(self)
  }

  fileprivate func commentPostedSuccessfully(_ comment: Comment) {
    self.delegate?.commentDialog(self, postedComment: comment)
  }

  fileprivate func animateTextViewConstraint(_ change: Keyboard.Change) {
    UIView.animate(withDuration: change.duration, delay: 0.0, options: change.options, animations: {
      self.bottomConstraint.constant = self.view.frame.height - change.frame.minY
      }, completion: nil)
  }

  fileprivate func presentError(_ message: String) {
    self.present(UIAlertController.genericError(message),
                               animated: true,
                               completion: nil)
  }
}

extension CommentDialogViewController: UITextViewDelegate {

  internal func textViewDidChange(_ textView: UITextView) {
    self.viewModel.inputs.commentBodyChanged(textView.text)
  }
}
