import AlamofireImage
import KsApi
import Library
import Prelude
import Prelude_UIKit
import SafariServices
import UIKit

internal protocol UpdateDraftViewControllerDelegate: class {
  func updateDraftViewControllerWantsDismissal(_ updateDraftViewController: UpdateDraftViewController)
}

internal final class UpdateDraftViewController: UIViewController {
  fileprivate let viewModel: UpdateDraftViewModelType = UpdateDraftViewModel()
  internal weak var delegate: UpdateDraftViewControllerDelegate?

  @IBOutlet fileprivate weak var addAttachmentButton: UIButton!
  @IBOutlet fileprivate weak var addAttachmentExpandedButton: UIButton!
  @IBOutlet fileprivate weak var attachmentsSeparatorView: UIView!
  @IBOutlet fileprivate weak var attachmentsScrollView: UIScrollView!
  @IBOutlet fileprivate weak var attachmentsStackView: UIStackView!
  @IBOutlet fileprivate weak var bodyPlaceholderTextView: UITextView!
  @IBOutlet fileprivate weak var bodyTextView: UITextView!
  @IBOutlet fileprivate weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var closeBarButtonItem: UIBarButtonItem!
  @IBOutlet fileprivate weak var isBackersOnlyButton: UIButton!
  @IBOutlet fileprivate weak var previewBarButtonItem: UIBarButtonItem!
  @IBOutlet fileprivate weak var titleTextField: UITextField!

  @IBOutlet fileprivate var separatorViews: [UIView]!

  internal static func configuredWith(project: Project) -> UpdateDraftViewController {
    let vc = Storyboard.UpdateDraft.instantiate(UpdateDraftViewController.self)
    vc.viewModel.inputs.configureWith(project: project)
    return vc
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self |> baseControllerStyle()

    _ = self.navigationController?.navigationBar ?|> baseNavigationBarStyle
    _ = self.navigationItem.backBarButtonItem = UIBarButtonItem.back(nil, selector: nil)

    _ = self.closeBarButtonItem |> updateDraftCloseBarButtonItemStyle
    _ = self.previewBarButtonItem |> updateDraftPreviewBarButtonItemStyle

    _ = self.addAttachmentExpandedButton |> updateAddAttachmentExpandedButtonStyle
    _ = self.attachmentsScrollView |> updateAttachmentsScrollViewStyle
    _ = self.attachmentsStackView |> updateAttachmentsStackViewStyle
    _ = self.addAttachmentButton |> updateAddAttachmentButtonStyle
    _ = self.bodyPlaceholderTextView |> updateBodyPlaceholderTextViewStyle
    _ = self.bodyTextView |> updateBodyTextViewStyle
    _ = self.isBackersOnlyButton |> updateBackersOnlyButtonStyle
    _ = self.titleTextField |> updateTitleTextFieldStyle

    _ = self.separatorViews ||> separatorStyle
  }

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.addAttachmentExpandedButton.rac.hidden =
      self.viewModel.outputs.isAttachmentsSectionHidden.map(negate)
    self.attachmentsSeparatorView.rac.hidden = self.viewModel.outputs.isAttachmentsSectionHidden
    self.attachmentsStackView.rac.hidden = self.viewModel.outputs.isAttachmentsSectionHidden
    self.bodyPlaceholderTextView.rac.hidden = self.viewModel.outputs.isBodyPlaceholderHidden
    self.bodyTextView.rac.text = self.viewModel.outputs.body
    self.bodyTextView.rac.becomeFirstResponder = self.viewModel.outputs.bodyTextViewBecomeFirstResponder
    self.isBackersOnlyButton.rac.selected = self.viewModel.outputs.isBackersOnly
    self.navigationItem.rac.title = self.viewModel.outputs.navigationItemTitle
    self.previewBarButtonItem.rac.enabled = self.viewModel.outputs.isPreviewButtonEnabled
    self.titleTextField.rac.text = self.viewModel.outputs.title
    self.titleTextField.rac.becomeFirstResponder = self.viewModel.outputs.titleTextFieldBecomeFirstResponder
    self.view.rac.endEditing = self.viewModel.outputs.resignFirstResponder

    self.viewModel.outputs.attachments
      .observeForControllerAction()
      .observeValues { [weak self] attachments in
        guard let attachmentsStackView = self?.attachmentsStackView else { return }
        _ = attachmentsStackView |>
          UIStackView.lens.arrangedSubviews .~ attachments.flatMap { self?.imageView(forAttachment: $0) }
    }

    self.viewModel.outputs.notifyPresenterViewControllerWantsDismissal
      .observeForControllerAction()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        _self.delegate?.updateDraftViewControllerWantsDismissal(_self)
    }

    self.viewModel.outputs.showAttachmentActions
      .observeForControllerAction()
      .observeValues { [weak self] actions in self?.showAttachmentActions(actions) }

    self.viewModel.outputs.showImagePicker
      .observeForControllerAction()
      .observeValues { [weak self] action in self?.showImagePicker(forAction: action) }

    self.viewModel.outputs.attachmentAdded
      .observeForControllerAction()
      .observeValues { [weak self] attachment in
        guard let _self = self else { return }
        let imageView = _self.imageView(forAttachment: attachment)
        _self.attachmentsStackView.addArrangedSubview(imageView)

        after(0.1) {
          let scrollView = _self.attachmentsScrollView
          let offset = (scrollView?.contentSize.width)! - (scrollView?.bounds.size.width)!
          guard offset >= (scrollView?.contentOffset.x)! else { return }
          scrollView?.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        }
    }

    self.viewModel.outputs.showRemoveAttachmentConfirmation
      .observeForControllerAction()
      .observeValues { [weak self] attachment in self?.showRemoveAttachmentAlert(attachment) }

    self.viewModel.outputs.attachmentRemoved
      .observeForControllerAction()
      .observeValues { [weak self] attachment in
        guard let _self = self else { return }
        UIView.animate(withDuration: 0.2) {
          _self.attachmentsStackView.viewWithTag(attachment.id)?.removeFromSuperview()
        }
    }

    self.viewModel.outputs.goToPreview
      .observeForControllerAction()
      .observeValues { [weak self] draft in
        let vc = UpdatePreviewViewController.configuredWith(draft: draft)
        self?.navigationController?.pushViewController(vc, animated: true)
    }

    self.viewModel.outputs.showAddAttachmentFailure
      .observeForControllerAction()
      .observeValues { [weak self] in
        let alert = UIAlertController
          .genericError(Strings.Couldnt_add_attachment())
        self?.present(alert, animated: true, completion: nil)
    }

    self.viewModel.outputs.showRemoveAttachmentFailure
      .observeForControllerAction()
      .observeValues { [weak self] in
        let alert = UIAlertController
          .genericError(Strings.Couldnt_remove_attachment())
        self?.present(alert, animated: true, completion: nil)
    }

    self.viewModel.outputs.showSaveFailure
      .observeForControllerAction()
      .observeValues { [weak self] in
        let alert = UIAlertController
          .genericError(Strings.dashboard_post_update_compose_error_could_not_save_update())
        self?.present(alert, animated: true, completion: nil)
    }

    Keyboard.change.observeForUI()
      .observeValues { [weak self] in self?.animateBottomConstraint($0) }
  }
  // swiftlint:enable function_body_length

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.addAttachmentButton.addTarget(self, action: #selector(addAttachmentButtonTapped),
                                       for: .touchUpInside)
    self.addAttachmentExpandedButton.addTarget(self, action: #selector(addAttachmentButtonTapped),
                                               for: .touchUpInside)
    self.bodyTextView.delegate = self
    self.isBackersOnlyButton.addTarget(self, action: #selector(isBackersOnlyButtonTapped),
                                       for: .touchUpInside)
    self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange),
                                  for: .editingChanged)
    self.titleTextField.addTarget(self, action: #selector(titleTextFieldDoneEditing),
                                  for: .editingDidEndOnExit)

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    self.viewModel.inputs.viewWillDisappear()
  }

  @IBAction fileprivate func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }

  @IBAction fileprivate func previewButtonTapped() {
    self.viewModel.inputs.previewButtonTapped()
  }

  @objc fileprivate func isBackersOnlyButtonTapped() {
    self.viewModel.inputs.isBackersOnlyOn(!self.isBackersOnlyButton.isSelected)
  }

  @objc fileprivate func addAttachmentButtonTapped() {
    self.viewModel.inputs.addAttachmentButtonTapped(availableSources: [.camera, .cameraRoll]
      .filter { UIImagePickerController.isSourceTypeAvailable($0.sourceType) })
  }

  @objc fileprivate func titleTextFieldDidChange() {
    self.viewModel.inputs.titleTextChanged(to: self.titleTextField.text ?? "")
  }

  @objc fileprivate func titleTextFieldDoneEditing() {
    self.viewModel.inputs.titleTextFieldDoneEditing()
  }

  fileprivate func showAttachmentActions(_ actions: [AttachmentSource]) {
    let attachmentSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    for action in actions {
      attachmentSheet.addAction(.init(title: action.title, style: .default, handler: { [weak self] _ in
        self?.viewModel.inputs.addAttachmentSheetButtonTapped(action)
        }))
    }
    attachmentSheet.addAction(.init(title: Strings.dashboard_post_update_compose_attachment_buttons_cancel(),
      style: .cancel,
      handler: nil))

    // iPad provision
    attachmentSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

    self.present(attachmentSheet, animated: true, completion: nil)
  }

  fileprivate func showImagePicker(forAction action: AttachmentSource) {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.sourceType = action.sourceType
    self.present(picker, animated: true, completion: nil)
  }

  fileprivate func animateBottomConstraint(_ change: Keyboard.Change) {
    UIView.animate(withDuration: change.duration, delay: 0.0, options: change.options, animations: {
      self.bottomConstraint.constant = self.view.frame.maxY - change.frame.minY
      }, completion: nil)
  }

  fileprivate func imageView(forAttachment attachment: UpdateDraft.Attachment) -> UIImageView {
    let imageView = UIImageView() |> updateAttachmentsThumbStyle
      |> UIImageView.lens.tag .~ attachment.id

    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
    if let url = URL(string: attachment.thumbUrl) {
      imageView.ksr_setImageWithURL(url)
    }

    let tap = UITapGestureRecognizer(target: self, action: #selector(attachmentTapped))
    tap.cancelsTouchesInView = false
    imageView.addGestureRecognizer(tap)

    return imageView
  }

  @objc fileprivate func attachmentTapped(_ tap: UITapGestureRecognizer) {
    guard let id = tap.view?.tag else { return }
    self.viewModel.inputs.attachmentTapped(id: id)
  }

  fileprivate func showRemoveAttachmentAlert(_ attachment: UpdateDraft.Attachment) {
    let alert = UIAlertController(
      title: Strings.dashboard_post_update_compose_attachment_alerts_image_remove_image(),
      message: Strings
        .dashboard_post_update_compose_attachment_alerts_image_are_you_sure_you_want_to_remove_image(),
      preferredStyle: .alert
    )
    alert.addAction(
      UIAlertAction(
        title: Strings.dashboard_post_update_compose_attachment_alerts_image_buttons_remove(),
        style: .destructive
      ) { [weak self] _ in
        self?.viewModel.inputs.remove(attachment: attachment)
      }
    )
    alert.addAction(
      UIAlertAction(
        title: Strings.dashboard_post_update_compose_attachment_alerts_image_buttons_cancel(),
        style: .cancel
      ) { [weak self] _ in
        self?.viewModel.inputs.removeAttachmentConfirmationCanceled()
      }
    )
    self.present(alert, animated: true, completion: nil)
  }
}

extension UpdateDraftViewController: UITextViewDelegate {
  internal func textViewDidChange(_ textView: UITextView) {
    self.viewModel.inputs.bodyTextChanged(to: textView.text)
  }
}

extension UpdateDraftViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  @objc internal func imagePickerController(_ picker: UIImagePickerController,
                                            didFinishPickingMediaWithInfo info: [String:Any]) {
    guard
      let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
      let imageData = UIImageJPEGRepresentation(image, 0.9),
      let caches = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first,
      let file = URL(string: caches)?.appendingPathComponent("\(image.hash).jpg"),
      let absoluteString = file.absoluteString
      else { fatalError() }

    imageData.writeToFile(absoluteString, atomically: true)

    self.viewModel.inputs.imagePicked(url: file,
                                      fromSource: AttachmentSource(sourceType: picker.sourceType))
    picker.dismiss(animated: true, completion: nil)
  }

  @objc internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    self.viewModel.inputs.imagePickerCanceled()
    picker.dismiss(animated: true, completion: nil)
  }
}

private func after(_ seconds: TimeInterval,
                   queue: DispatchQueue = DispatchQueue.main,
                   body: @escaping () -> ()) {

  queue.asyncAfter(deadline: DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: body)
}
