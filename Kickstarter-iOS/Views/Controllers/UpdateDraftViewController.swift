import Foundation
import UIKit
import Library
import Prelude
import Prelude_UIKit
import KsApi
import SafariServices

internal protocol UpdateDraftViewControllerDelegate: class {
  func updateDraftViewControllerWantsDismissal(updateDraftViewController: UpdateDraftViewController)
}

internal final class UpdateDraftViewController: UIViewController {
  private let viewModel: UpdateDraftViewModelType = UpdateDraftViewModel()
  internal weak var delegate: UpdateDraftViewControllerDelegate?

  @IBOutlet private weak var bodyTextView: UITextView!
  @IBOutlet private weak var isBackersOnlyButton: UIButton!
  @IBOutlet private weak var attachmentsStackView: UIStackView!
  @IBOutlet private weak var addAttachmentButton: UIButton!
  @IBOutlet private weak var previewButton: UIBarButtonItem!
  @IBOutlet private weak var titleTextField: UITextField!
  @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!

  @IBOutlet private weak var topSeparatorView: UIView!
  @IBOutlet private weak var bottomSeparatorView: UIView!

  internal override func bindStyles() {
    super.bindStyles()

    self |> baseControllerStyle()
    self.titleTextField |> updateTitleTextFieldStyle
    self.isBackersOnlyButton |> updateBackersOnlyButtonStyle
    self.attachmentsStackView |> updateAttachmentsStackViewStyle
    self.addAttachmentButton |> updateAddAttachmentButtonStyle
    self.bodyTextView |> updateBodyTextViewStyle
    self.topSeparatorView |> separatorStyle
    self.bottomSeparatorView |> separatorStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.previewButton.rac.enabled = self.viewModel.outputs.isPreviewButtonEnabled
    self.titleTextField.rac.text = self.viewModel.outputs.title
    self.bodyTextView.rac.text = self.viewModel.outputs.body
    self.isBackersOnlyButton.rac.selected = self.viewModel.outputs.isBackersOnly

    self.viewModel.outputs.attachments
      .observeForUI()
      .observeNext { [weak self] attachments in
        guard let attachmentsStackView = self?.attachmentsStackView else { return }
        attachmentsStackView |>
          UIStackView.lens.arrangedSubviews .~ attachments
            .map { attachment in
              let imageView = UIImageView()
              if let url = NSURL(string: attachment.thumbUrl) {
                imageView.af_setImageWithURL(url)
              }
              return imageView
        }
    }

    self.viewModel.outputs.notifyPresenterViewControllerWantsDismissal
      .observeNext { [weak self] in
        guard let _self = self else { return }
        _self.delegate?.updateDraftViewControllerWantsDismissal(_self)
    }

    self.viewModel.outputs.showSaveFailure
      .observeForUI()
      .observeNext { /*[weak self] in*/
        print("Save failed!")
    }

    self.viewModel.outputs.showPreview
      .observeForUI()
      .observeNext { [weak self] url in
        self?.navigationController?
          .pushViewController(SFSafariViewController(URL: url), animated: true)
    }

    self.viewModel.outputs.bodyTextViewBecomeFirstResponder
      .observeForUI()
      .observeNext { [weak self] _ in
        self?.bodyTextView.becomeFirstResponder()
    }

    Keyboard.change.observeForUI()
      .observeNext { [weak self] in self?.animateBottomConstraint($0) }

    self.viewModel.outputs.resignFirstResponder
      .observeForUI()
      .observeNext { [weak self] in
        self?.view.endEditing(true)
    }
  }

  internal func configureWith(project project: Project) {
    self.viewModel.inputs.configureWith(project: project)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)

    self.viewModel.inputs.viewWillDisappear()
  }

  @IBAction private func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }

  @IBAction private func previewButtonTapped() {
    self.viewModel.inputs.previewButtonTapped()
  }

  @IBAction private func isBackersOnlyButtonTapped() {
    self.viewModel.inputs.isBackersOnlyOn(!self.isBackersOnlyButton.selected)
  }

  @IBAction private func addAttachmentButtonTapped() {
    self.viewModel.inputs.addAttachmentButtonTapped()
  }

  @IBAction private func titleTextFieldDidChange() {
    self.viewModel.inputs.titleTextChanged(self.titleTextField.text ?? "")
  }

  @IBAction private func titleTextFieldDoneEditing() {
    self.viewModel.inputs.titleTextFieldDoneEditing()
  }

  private func animateBottomConstraint(change: Keyboard.Change) {
    UIView.animateWithDuration(change.duration, delay: 0.0, options: change.options, animations: {
      self.bottomConstraint.constant = self.view.frame.height - change.frame.minY
      }, completion: nil)
  }
}

extension UpdateDraftViewController: UITextViewDelegate {

  internal func textViewDidChange(textView: UITextView) {
    self.viewModel.inputs.bodyTextChanged(textView.text)
  }
}
