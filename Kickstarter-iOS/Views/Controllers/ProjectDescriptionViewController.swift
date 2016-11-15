import KsApi
import Library
import Prelude
import SafariServices
import UIKit

internal final class ProjectDescriptionViewController: WebViewController {
  private let viewModel: ProjectDescriptionViewModelType = ProjectDescriptionViewModel()

  internal static func configuredWith(project project: Project) -> ProjectDescriptionViewController {
    let vc = ProjectDescriptionViewController()
    vc.viewModel.inputs.configureWith(project: project)
    return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  override func bindStyles() {
    super.bindStyles()

    self
      |> baseControllerStyle()
      |> WebViewController.lens.title %~ { _ in Strings.project_menu_buttons_campaign() }
      |> (WebViewController.lens.webView.scrollView • UIScrollView.lens.delaysContentTouches) .~ false
      |> (WebViewController.lens.webView.scrollView • UIScrollView.lens.canCancelContentTouches) .~ true
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.goToMessageDialog
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goToMessageDialog(subject: $0, context: $1) }

    self.viewModel.outputs.goBackToProject
      .observeForControllerAction()
      .observeNext { [weak self] _ in
        self?.navigationController?.popViewControllerAnimated(true)
    }

    self.viewModel.outputs.goToSafariBrowser
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.goToSafariBrowser(url: $0)
    }

    self.viewModel.outputs.loadWebViewRequest
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.webView.loadRequest($0)
    }
  }

  internal func webView(webView: WKWebView,
                        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
                        decisionHandler: (WKNavigationActionPolicy) -> Void) {

    self.viewModel.inputs.decidePolicyFor(navigationAction: .init(navigationAction: navigationAction))
    decisionHandler(self.viewModel.outputs.decidedPolicyForNavigationAction)
  }

  private func goToMessageDialog(subject subject: MessageSubject, context: Koala.MessageDialogContext) {
    let vc = MessageDialogViewController.configuredWith(messageSubject: subject, context: context)
    vc.delegate = self
    self.presentViewController(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }

  private func goToSafariBrowser(url url: NSURL) {
    let controller = SFSafariViewController(URL: url)
    controller.modalPresentationStyle = .OverFullScreen
    self.presentViewController(controller, animated: true, completion: nil)
  }
}

extension ProjectDescriptionViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(dialog: MessageDialogViewController) {
    dialog.dismissViewControllerAnimated(true, completion: nil)
  }

  internal func messageDialog(dialog: MessageDialogViewController, postedMessage message: Message) {
  }
}
