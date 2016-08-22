import KsApi
import Library
import Prelude
import UIKit

internal final class UpdatePreviewViewController: WebViewController {
  private let viewModel: UpdatePreviewViewModelType = UpdatePreviewViewModel()

  @IBOutlet weak var publishBarButtonItem: UIBarButtonItem!

  internal static func configuredWith(draft draft: UpdateDraft) -> UpdatePreviewViewController {
    let vc = Storyboard.UpdateDraft.instantiate(UpdatePreviewViewController)
    vc.viewModel.inputs.configureWith(draft: draft)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.publishBarButtonItem
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(publishButtonTapped))

    self.viewModel.inputs.viewDidLoad()
  }

  func publishButtonTapped() {
    self.viewModel.inputs.publishButtonTapped()
  }

  internal override func bindStyles() {
    self |> baseControllerStyle()
    self.publishBarButtonItem |> updatePreviewBarButtonItemStyle
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.webViewLoadRequest
      .observeForControllerAction()
      .observeNext { [weak self] in self?.webView.loadRequest($0) }

    self.viewModel.outputs.goToUpdate
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goTo(update: $1, forProject: $0) }

    self.viewModel.outputs.showPublishConfirmation
      .observeForControllerAction()
      .observeNext { [weak self] in self?.showPublishConfirmation(message: $0) }

    self.viewModel.outputs.showPublishFailure
      .observeForControllerAction()
      .observeNext { [weak self] in self?.showPublishFailure() }
  }

  internal func webView(webView: WKWebView,
                        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
                                                        decisionHandler: (WKNavigationActionPolicy) -> Void) {

    decisionHandler(self.viewModel.inputs.decidePolicyFor(navigationAction: navigationAction))
  }

  private func goTo(update update: Update, forProject project: Project) {
    let vc = UpdateViewController.configuredWith(project: project, update: update)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func showPublishConfirmation(message message: String) {
    let alert = UIAlertController(
      title: Strings.dashboard_post_update_preview_confirmation_alert_title(),
      message: message,
      preferredStyle: .Alert
    )
    alert.addAction(
      UIAlertAction(
        title: Strings.dashboard_post_update_preview_confirmation_alert_confirm_button(),
        style: .Default) { _ in
          self.viewModel.inputs.publishConfirmationButtonTapped()
      }
    )
    alert.addAction(
      .init(
        title: Strings.dashboard_post_update_preview_confirmation_alert_cancel_button(),
        style: .Cancel,
        handler: nil
      )
    )
    self.presentViewController(alert, animated: true, completion: nil)
  }

  private func showPublishFailure() {
    let alert = UIAlertController
      .genericError(Strings.dashboard_post_update_preview_confirmation_alert_error_something_wrong())
    self.presentViewController(alert, animated: true, completion: nil)
  }
}
