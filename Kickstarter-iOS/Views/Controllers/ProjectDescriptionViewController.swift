import KsApi
import Library
import Prelude
import SafariServices
import UIKit

internal final class ProjectDescriptionViewController: WebViewController {
  fileprivate let viewModel: ProjectDescriptionViewModelType = ProjectDescriptionViewModel()

  internal static func configuredWith(project: Project) -> ProjectDescriptionViewController {
    let vc = ProjectDescriptionViewController()
    vc.viewModel.inputs.configureWith(project: project)
    return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> WebViewController.lens.title %~ { _ in Strings.project_menu_buttons_campaign() }
      |> (WebViewController.lens.webView.scrollView • UIScrollView.lens.delaysContentTouches) .~ false
      |> (WebViewController.lens.webView.scrollView • UIScrollView.lens.canCancelContentTouches) .~ true

    _ = self.navigationController?.navigationBar
      ?|> baseNavigationBarStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.goToMessageDialog
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goToMessageDialog(subject: $0, context: $1) }

    self.viewModel.outputs.goBackToProject
      .observeForControllerAction()
      .observeValues { [weak self] _ in
        _ = self?.navigationController?.popViewController(animated: true)
    }

    self.viewModel.outputs.goToSafariBrowser
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToSafariBrowser(url: $0)
    }

    self.viewModel.outputs.loadWebViewRequest
      .observeForControllerAction()
      .observeValues { [weak self] in
        _ = self?.webView.load($0)
    }
  }

  internal func webView(_ webView: WKWebView,
                        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
                        decisionHandler: (WKNavigationActionPolicy) -> Void) {

    self.viewModel.inputs.decidePolicyFor(navigationAction: .init(navigationAction: navigationAction))
    decisionHandler(self.viewModel.outputs.decidedPolicyForNavigationAction)
  }

  fileprivate func goToMessageDialog(subject: MessageSubject, context: Koala.MessageDialogContext) {
    let vc = MessageDialogViewController.configuredWith(messageSubject: subject, context: context)
    vc.delegate = self
    self.present(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }

  fileprivate func goToSafariBrowser(url: URL) {
    let controller = SFSafariViewController(url: url)
    controller.modalPresentationStyle = .overFullScreen
    self.present(controller, animated: true, completion: nil)
  }
}

extension ProjectDescriptionViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(_ dialog: MessageDialogViewController) {
    dialog.dismiss(animated: true, completion: nil)
  }

  internal func messageDialog(_ dialog: MessageDialogViewController, postedMessage message: Message) {
  }
}
