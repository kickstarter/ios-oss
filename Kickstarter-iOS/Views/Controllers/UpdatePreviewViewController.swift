import KsApi
import Library
import Prelude
import UIKit

internal final class UpdatePreviewViewController: WebViewController {
  fileprivate let viewModel: UpdatePreviewViewModelType = UpdatePreviewViewModel()

  @IBOutlet fileprivate weak var publishBarButtonItem: UIBarButtonItem!

  internal static func configuredWith(draft: UpdateDraft) -> UpdatePreviewViewController {
    let vc = Storyboard.UpdateDraft.instantiate(UpdatePreviewViewController.self)
    vc.viewModel.inputs.configureWith(draft: draft)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    _ = self.publishBarButtonItem
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(publishButtonTapped))

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    _ = self |> baseControllerStyle()
    _ = self.publishBarButtonItem |> updatePreviewBarButtonItemStyle

    self.navigationItem.title = nil
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.webViewLoadRequest
      .observeForControllerAction()
      .observeValues { [weak self] in _ = self?.webView.load($0) }

    self.viewModel.outputs.showPublishConfirmation
      .observeForControllerAction()
      .observeValues { [weak self] in self?.showPublishConfirmation(message: $0) }

    self.viewModel.outputs.showPublishFailure
      .observeForControllerAction()
      .observeValues { [weak self] in self?.showPublishFailure() }

    self.viewModel.outputs.goToUpdate
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goTo(update: $1, forProject: $0) }
  }

  internal func webView(_ webView: WKWebView,
                        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
                        decisionHandler: (WKNavigationActionPolicy) -> Void) {

    decisionHandler(
      self.viewModel.inputs.decidePolicyFor(navigationAction: .init(navigationAction: navigationAction))
    )
  }

  @objc fileprivate func publishButtonTapped() {
    self.viewModel.inputs.publishButtonTapped()
  }

  fileprivate func showPublishConfirmation(message: String) {
    let alert = UIAlertController(
      title: Strings.dashboard_post_update_preview_confirmation_alert_title(),
      message: message,
      preferredStyle: .alert
    )
    alert.addAction(
      UIAlertAction(
        title: Strings.dashboard_post_update_preview_confirmation_alert_confirm_button(),
        style: .default) { _ in
          self.viewModel.inputs.publishConfirmationButtonTapped()
      }
    )
    alert.addAction(
      UIAlertAction(
        title: Strings.dashboard_post_update_preview_confirmation_alert_cancel_button(),
        style: .cancel) { _ in
          self.viewModel.inputs.publishCancelButtonTapped()
      }
    )
    self.present(alert, animated: true, completion: nil)
  }

  fileprivate func showPublishFailure() {
    let alert = UIAlertController
      .genericError(Strings.dashboard_post_update_preview_confirmation_alert_error_something_wrong())
    self.present(alert, animated: true, completion: nil)
  }

  fileprivate func goTo(update: Update, forProject project: Project) {
    let vc = UpdateViewController.configuredWith(project: project, update: update, context: .draftPreview)
    self.navigationController?.setViewControllers([vc], animated: true)
  }
}
