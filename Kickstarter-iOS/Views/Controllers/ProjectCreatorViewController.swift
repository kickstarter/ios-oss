import KsApi
import Library
import Prelude
import SafariServices

internal final class ProjectCreatorViewController: WebViewController {
  fileprivate let viewModel: ProjectCreatorViewModelType = ProjectCreatorViewModel()

  internal static func configuredWith(project: Project) -> ProjectCreatorViewController {
    let vc = ProjectCreatorViewController()
    vc.viewModel.inputs.configureWith(project: project)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()

    self.navigationItem.title = Strings.project_subpages_menu_buttons_creator()

    if self.traitCollection.userInterfaceIdiom == .pad {
      self.navigationItem.leftBarButtonItem = .close(self, selector: #selector(closeButtonTapped))
    }
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.goToLoginTout
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToLoginTout($0)
    }

    self.viewModel.outputs.loadWebViewRequest
      .observeForControllerAction()
      .observeValues { [weak self] in _ = self?.webView.load($0) }

    self.viewModel.outputs.goBackToProject
      .observeForControllerAction()
      .observeValues { [weak self] in
        if self?.traitCollection.userInterfaceIdiom == .pad {
          self?.dismiss(animated: true, completion: nil)
        } else {
          self?.navigationController?.popViewController(animated: true)
        }
    }

    self.viewModel.outputs.goToMessageDialog
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goToMessageDialog(subject: $0, context: $1) }

    self.viewModel.outputs.goToSafariBrowser
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToSafariBrowser(url: $0)
    }
  }

  internal func webView(_ webView: WKWebView,
                        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
                        decisionHandler: (WKNavigationActionPolicy) -> Void) {
    decisionHandler(
      self.viewModel.inputs.decidePolicy(
        forNavigationAction: WKNavigationActionData(navigationAction: navigationAction)
      )
    )
  }

  fileprivate func goToLoginTout(_ loginIntent: LoginIntent) {
    let vc = LoginToutViewController.configuredWith(loginIntent: loginIntent)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
  }

  fileprivate func goToMessageDialog(subject: MessageSubject, context: Koala.MessageDialogContext) {
    let vc = MessageDialogViewController.configuredWith(messageSubject: subject, context: context)
    vc.delegate = self
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet
    self.present(nav, animated: true, completion: nil)
  }

  fileprivate func goToSafariBrowser(url: URL) {
    let controller = SFSafariViewController(url: url)
    controller.modalPresentationStyle = .overFullScreen
    self.present(controller, animated: true, completion: nil)
  }

  @objc fileprivate func closeButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }
}

extension ProjectCreatorViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(_ dialog: MessageDialogViewController) {
    dialog.dismiss(animated: true, completion: nil)
  }

  internal func messageDialog(_ dialog: MessageDialogViewController, postedMessage message: Message) {
  }
}
