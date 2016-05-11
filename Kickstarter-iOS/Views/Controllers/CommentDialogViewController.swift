import UIKit
import Models
import ReactiveCocoa
import Result
import ReactiveExtensions
import Library

internal protocol CommentDialogDelegate: class {
  func commentDialogWantsDismissal(dialog: CommentDialogViewController)
  func commentDialog(dialog: CommentDialogViewController, postedComment: Comment)
}

internal final class CommentDialogViewController: UIViewController {
  private let viewModel: CommentDialogViewModelType = CommentDialogViewModel()
  internal weak var delegate: CommentDialogDelegate?

  @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var subtitleLabel: UILabel!
  @IBOutlet private weak var bodyTextView: UITextView!
  @IBOutlet private weak var postButton: UIBarButtonItem!
  @IBOutlet private weak var loadingView: UIView!

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  internal override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    self.viewModel.inputs.viewWillDisappear()
  }

  internal func configureWith(project project: Project, update: Update?) {
    self.viewModel.inputs.project(project, update: update)
  }

  override func bindViewModel() {

    self.viewModel.outputs.postButtonEnabled
      .observeForUI()
      .observeNext { [weak self] in self?.postButton.enabled = $0 }

    self.subtitleLabel.rac.text = self.viewModel.outputs.subtitle

    self.viewModel.outputs.showKeyboard
      .observeForUI()
      .observeNext { [weak textView = self.bodyTextView] show in
        show ? textView?.becomeFirstResponder() : textView?.resignFirstResponder()
    }

    self.viewModel.outputs.notifyPresenterDialogWantsDismissal
      .observeForUI()
      .observeNext { [weak self] in self?.notifyPresenterOfDismissal() }

    self.viewModel.outputs.notifyPresenterCommentWasPostedSuccesfully
      .observeForUI()
      .observeNext { [weak self] in self?.commentPostedSuccessfully($0) }

    self.viewModel.errors.presentError
      .observeForUI()
      .observeNext { [weak self] in self?.presentError($0) }

    self.loadingView.rac.hidden = self.viewModel.outputs.loadingViewIsHidden

    Keyboard.change.observeForUI()
      .observeNext { [weak self] in self?.animateTextViewConstraint($0) }
  }

  @IBAction internal func cancelButtonPressed() {
    self.viewModel.inputs.cancelButtonPressed()
  }

  @IBAction internal func postButtonPressed() {
    self.viewModel.inputs.postButtonPressed()
  }

  private func notifyPresenterOfDismissal() {
    self.delegate?.commentDialogWantsDismissal(self)
  }

  private func commentPostedSuccessfully(comment: Comment) {
    self.delegate?.commentDialog(self, postedComment: comment)
  }

  private func animateTextViewConstraint(change: Keyboard.Change) {
    UIView.animateWithDuration(change.duration, delay: 0.0, options: change.options, animations: {
      self.bottomConstraint.constant = self.view.frame.height - change.frame.minY
      }, completion: nil)
  }

  private func presentError(message: String) {
    self.presentViewController(UIAlertController.genericError(message),
                               animated: true,
                               completion: nil)
  }
}

extension CommentDialogViewController: UITextViewDelegate {

  internal func textViewDidChange(textView: UITextView) {
    self.viewModel.inputs.commentBodyChanged(textView.text)
  }
}
