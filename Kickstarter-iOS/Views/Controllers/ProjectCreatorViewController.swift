import KsApi
import Library
import Prelude
import SafariServices

internal final class ProjectCreatorViewController: WebViewController {
  private let viewModel: ProjectCreatorViewModelType = ProjectCreatorViewModel()

  internal static func configuredWith(project project: Project) -> ProjectCreatorViewController {
    let vc = ProjectCreatorViewController()
    vc.viewModel.inputs.configureWith(project: project)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()

    self.navigationItem.title = Strings.project_subpages_menu_buttons_creator()

    if self.traitCollection.userInterfaceIdiom == .Pad {
      self.navigationItem.leftBarButtonItem = .close(self, selector: #selector(closeButtonTapped))
    }
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseControllerStyle()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadWebViewRequest
      .observeForControllerAction()
      .observeNext { [weak self] in self?.webView.loadRequest($0) }

    self.viewModel.outputs.goToMessageDialog
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goToMessageDialog(subject: $0, context: $1) }

    self.viewModel.outputs.goToSafariBrowser
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.goToSafariBrowser(url: $0)
    }
  }

  internal func webView(webView: WKWebView,
                        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
                                                        decisionHandler: (WKNavigationActionPolicy) -> Void) {
    decisionHandler(self.viewModel.inputs.decidePolicy(forNavigationAction: navigationAction))
  }

  private func goToMessageDialog(subject subject: MessageSubject, context: Koala.MessageDialogContext) {
    let vc = MessageDialogViewController.configuredWith(messageSubject: subject, context: context)
    vc.delegate = self
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .FormSheet
    self.presentViewController(nav, animated: true, completion: nil)
  }

  private func goToSafariBrowser(url url: NSURL) {
    let controller = SFSafariViewController(URL: url)
    controller.modalPresentationStyle = .OverFullScreen
    self.presentViewController(controller, animated: true, completion: nil)
  }

  @objc private func closeButtonTapped() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}

extension ProjectCreatorViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(dialog: MessageDialogViewController) {
    dialog.dismissViewControllerAnimated(true, completion: nil)
  }

  internal func messageDialog(dialog: MessageDialogViewController, postedMessage message: Message) {
  }
}
