import AlamofireImage
import KsApi
import Library
import Prelude
import Prelude_UIKit
import SafariServices
import UIKit

internal protocol UpdateDraftViewControllerDelegate: class {
  func updateDraftViewControllerWantsDismissal(updateDraftViewController: UpdateDraftViewController)
}

internal final class UpdateDraftViewController: UIViewController {
  private let viewModel: UpdateDraftViewModelType = UpdateDraftViewModel()
  internal weak var delegate: UpdateDraftViewControllerDelegate?

  @IBOutlet private weak var addAttachmentButton: UIButton!
  @IBOutlet private weak var addAttachmentExpandedButton: UIButton!
  @IBOutlet private weak var attachmentsSeparatorView: UIView!
  @IBOutlet private weak var attachmentsScrollView: UIScrollView!
  @IBOutlet private weak var attachmentsStackView: UIStackView!
  @IBOutlet private weak var bodyPlaceholderTextView: UITextView!
  @IBOutlet private weak var bodyTextView: UITextView!
  @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet private weak var closeBarButtonItem: UIBarButtonItem!
  @IBOutlet private weak var isBackersOnlyButton: UIButton!
  @IBOutlet private weak var previewBarButtonItem: UIBarButtonItem!
  @IBOutlet private weak var titleTextField: UITextField!

  @IBOutlet private var separatorViews: [UIView]!

  internal static func configuredWith(project project: Project) -> UpdateDraftViewController {
    let vc = Storyboard.UpdateDraft.instantiate(UpdateDraftViewController)
    vc.viewModel.inputs.configureWith(project: project)
    return vc
  }

  internal override func bindStyles() {
    super.bindStyles()

    self |> baseControllerStyle()

    self.navigationController?.navigationBar ?|> baseNavigationBarStyle
    self.navigationItem.backBarButtonItem ?|> updateDraftBackBarButtonItemStyle

    self.closeBarButtonItem |> updateDraftCloseBarButtonItemStyle
    self.previewBarButtonItem |> updateDraftPreviewBarButtonItemStyle

    self.addAttachmentExpandedButton |> updateAddAttachmentExpandedButtonStyle
    self.attachmentsScrollView |> updateAttachmentsScrollViewStyle
    self.attachmentsStackView |> updateAttachmentsStackViewStyle
    self.addAttachmentButton |> updateAddAttachmentButtonStyle
    self.bodyPlaceholderTextView |> updateBodyPlaceholderTextViewStyle
    self.bodyTextView |> updateBodyTextViewStyle
    self.isBackersOnlyButton |> updateBackersOnlyButtonStyle
    self.titleTextField |> updateTitleTextFieldStyle

    self.separatorViews ||> separatorStyle
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
      .observeNext { [weak self] attachments in
        guard let attachmentsStackView = self?.attachmentsStackView else { return }
        attachmentsStackView |>
          UIStackView.lens.arrangedSubviews .~ attachments
            .flatMap { self?.imageView(forAttachment: $0) }
    }

    self.viewModel.outputs.notifyPresenterViewControllerWantsDismissal
      .observeForControllerAction()
      .observeNext { [weak self] in
        guard let _self = self else { return }
        _self.delegate?.updateDraftViewControllerWantsDismissal(_self)
    }

    self.viewModel.outputs.showAttachmentActions
      .observeForControllerAction()
      .observeNext { [weak self] actions in self?.showAttachmentActions(actions) }

    self.viewModel.outputs.showImagePicker
      .observeForControllerAction()
      .observeNext { [weak self] action in self?.showImagePicker(forAction: action) }

    self.viewModel.outputs.attachmentAdded
      .observeForControllerAction()
      .observeNext { [weak self] attachment in
        guard let _self = self else { return }
        let imageView = _self.imageView(forAttachment: attachment)
        _self.attachmentsStackView.addArrangedSubview(imageView)

        after(0.1) {
          let scrollView = _self.attachmentsScrollView
          let offset = scrollView.contentSize.width - scrollView.bounds.size.width
          scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        }
    }

    self.viewModel.outputs.showRemoveAttachmentConfirmation
      .observeForControllerAction()
      .observeNext { [weak self] attachment in self?.showRemoveAttachmentAlert(attachment) }

    self.viewModel.outputs.attachmentRemoved
      .observeForControllerAction()
      .observeNext { [weak self] attachment in
        guard let _self = self else { return }
        UIView.animateWithDuration(0.2) {
          _self.attachmentsStackView.viewWithTag(attachment.id)?.removeFromSuperview()
        }

        after(0.1) {
          let scrollView = _self.attachmentsScrollView
          let offset = scrollView.contentSize.width - scrollView.bounds.size.width
          guard offset >= scrollView.contentOffset.x else { return }
          scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        }
    }

    self.viewModel.outputs.goToPreview
      .observeForControllerAction()
      .observeNext { [weak self] draft in
        let vc = UpdatePreviewViewController.configuredWith(draft: draft)
        self?.navigationController?.pushViewController(vc, animated: true)
    }

    self.viewModel.outputs.showAddAttachmentFailure
      .observeForControllerAction()
      .observeNext { [weak self] in
        let alert = UIAlertController
          .genericError(Strings.dashboard_post_update_compose_error_could_not_save_update())
        self?.presentViewController(alert, animated: true, completion: nil)
    }

    self.viewModel.outputs.showRemoveAttachmentFailure
      .observeForControllerAction()
      .observeNext { // [weak self] in
//        let alert = UIAlertController
//          .genericError(Strings.dashboard_post_update_compose_error_could_not_save_update())
//        self?.presentViewController(alert, animated: true, completion: nil)
    }

    self.viewModel.outputs.showSaveFailure
      .observeForControllerAction()
      .observeNext { // [weak self] in
//        let alert = UIAlertController
//          .genericError(Strings.dashboard_post_update_compose_error_could_not_save_update())
//        self?.presentViewController(alert, animated: true, completion: nil)
    }

    Keyboard.change.observeForUI()
      .observeNext { [weak self] in self?.animateBottomConstraint($0) }
  }
  // swiftlint:enable function_body_length

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.addAttachmentButton.addTarget(self, action: #selector(addAttachmentButtonTapped),
                                       forControlEvents: .TouchUpInside)
    self.addAttachmentExpandedButton.addTarget(self, action: #selector(addAttachmentButtonTapped),
                                               forControlEvents: .TouchUpInside)
    self.bodyTextView.delegate = self
    self.isBackersOnlyButton.addTarget(self, action: #selector(isBackersOnlyButtonTapped),
                                       forControlEvents: .TouchUpInside)
    self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange),
                                  forControlEvents: .EditingChanged)
    self.titleTextField.addTarget(self, action: #selector(titleTextFieldDoneEditing),
                                  forControlEvents: .EditingDidEndOnExit)

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

  @objc private func isBackersOnlyButtonTapped() {
    self.viewModel.inputs.isBackersOnlyOn(!self.isBackersOnlyButton.selected)
  }

  @objc private func addAttachmentButtonTapped() {
    self.viewModel.inputs.addAttachmentButtonTapped(availableSources: [.camera, .cameraRoll]
      .filter { UIImagePickerController.isSourceTypeAvailable($0.sourceType) })
  }

  @objc private func titleTextFieldDidChange() {
    self.viewModel.inputs.titleTextChanged(to: self.titleTextField.text ?? "")
  }

  @objc private func titleTextFieldDoneEditing() {
    self.viewModel.inputs.titleTextFieldDoneEditing()
  }

  private func showAttachmentActions(actions: [AttachmentSource]) {
    let attachmentSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

    for action in actions {
      attachmentSheet.addAction(.init(title: action.title, style: .Default, handler: { [weak self] _ in
        self?.viewModel.inputs.addAttachmentSheetButtonTapped(action)
        }))
    }
    attachmentSheet.addAction(.init(title: Strings.dashboard_post_update_compose_attachment_buttons_cancel(),
      style: .Cancel,
      handler: nil))

    // iPad provision
    attachmentSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

    self.presentViewController(attachmentSheet, animated: true, completion: nil)
  }

  private func showImagePicker(forAction action: AttachmentSource) {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.sourceType = action.sourceType
    self.presentViewController(picker, animated: true, completion: nil)
  }

  private func animateBottomConstraint(change: Keyboard.Change) {
    UIView.animateWithDuration(change.duration, delay: 0.0, options: change.options, animations: {
      self.bottomConstraint.constant = self.view.frame.height - change.frame.minY
      }, completion: nil)
  }

  private func imageView(forAttachment attachment: UpdateDraft.Attachment) -> UIImageView {
    let imageView = UIImageView() |> updateAttachmentsThumbStyle
      |> UIImageView.lens.tag .~ attachment.id
    imageView.widthAnchor.constraintEqualToAnchor(imageView.heightAnchor).active = true
    if let url = NSURL(string: attachment.thumbUrl) {
      imageView.af_setImageWithURL(url)
    }

    let tap = UITapGestureRecognizer(target: self, action: #selector(attachmentTapped))
    tap.cancelsTouchesInView = false
    imageView.addGestureRecognizer(tap)

    return imageView
  }

  @objc private func attachmentTapped(tap: UITapGestureRecognizer) {
    guard let id = tap.view?.tag else { return }
    self.viewModel.inputs.attachmentTapped(id: id)
  }

  private func showRemoveAttachmentAlert(attachment: UpdateDraft.Attachment) {
    let alert = UIAlertController(
      title: Strings.dashboard_post_update_compose_attachment_alerts_image_remove_image(),
      message: Strings
        .dashboard_post_update_compose_attachment_alerts_image_are_you_sure_you_want_to_remove_image(),
      preferredStyle: .Alert
    )
    alert.addAction(
      UIAlertAction(
        title: Strings.dashboard_post_update_compose_attachment_alerts_image_buttons_remove(),
        style: .Destructive
      ) { [weak self] _ in
        self?.viewModel.inputs.remove(attachment: attachment)
      }
    )
    alert.addAction(
      UIAlertAction(
        title: Strings.dashboard_post_update_compose_attachment_alerts_image_buttons_cancel(),
        style: .Cancel
      ) { [weak self] _ in
        self?.viewModel.inputs.removeAttachmentConfirmationCanceled()
      }
    )
    self.presentViewController(alert, animated: true, completion: nil)
  }
}

extension UpdateDraftViewController: UITextViewDelegate {
  internal func textViewDidChange(textView: UITextView) {
    self.viewModel.inputs.bodyTextChanged(to: textView.text)
  }
}

extension UpdateDraftViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  @objc internal func imagePickerController(picker: UIImagePickerController,
                                            didFinishPickingMediaWithInfo info: [String:AnyObject]) {
    guard
      let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
      imageData = UIImageJPEGRepresentation(image, 0.9),
      caches = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first,
      file = NSURL(string: caches)?.URLByAppendingPathComponent("\(image.hash).jpg")
      else { fatalError() }

    imageData.writeToFile(file.absoluteString, atomically: true)

    self.viewModel.inputs.imagePicked(url: file,
                                      fromSource: AttachmentSource(sourceType: picker.sourceType))
    picker.dismissViewControllerAnimated(true, completion: nil)
  }

  @objc internal func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.viewModel.inputs.imagePickerCanceled()
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
}

private func after(seconds: NSTimeInterval,
                   queue: dispatch_queue_t = dispatch_get_main_queue(),
                   body: () -> ()) {

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC))), queue, body)
}
