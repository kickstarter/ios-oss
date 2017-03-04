import KsApi
import Library
import Prelude
import SafariServices

internal final class ProjectUpdatesViewController: WebViewController {
  fileprivate let viewModel: ProjectUpdatesViewModelType = ProjectUpdatesViewModel()
  
  private let navBorder = UIView()

  internal static func configuredWith(project: Project) -> ProjectUpdatesViewController {
    let vc = ProjectUpdatesViewController()
    vc.viewModel.inputs.configureWith(project: project)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    if let navBar = self.navigationController?.navigationBar {
      _ = self.navBorder |> baseNavigationBorderStyle(navBar: navBar)
      navBar.addSubview(navBorder)
    }

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.navigationItem.title = Strings.project_menu_buttons_updates()

    _ = self.navigationController?.navigationBar ?|> baseNavigationBarStyle
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if let navBar = self.navigationController?.navigationBar {
      self.navBorder.frame = CGRect(x: 0.0,
                                    y: navBar.frame.size.height,
                                    width: navBar.frame.size.width,
                                    height: self.navBorder.frame.size.height)
    }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.goToSafariBrowser
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goToSafariBrowser(url: $0) }

    self.viewModel.outputs.goToUpdate
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goToUpdate(forProject: $0, update: $1) }

    self.viewModel.outputs.goToUpdateComments
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goToComments(forUpdate: $0) }

    self.viewModel.outputs.webViewLoadRequest
      .observeForControllerAction()
      .observeValues { [weak self] in _ = self?.webView.load($0) }
  }

  fileprivate func goToComments(forUpdate update: Update) {
    let vc = CommentsViewController.configuredWith(update: update)
    if self.traitCollection.userInterfaceIdiom == .pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
      self.present(nav, animated: true, completion: nil)
    } else {
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  fileprivate func goToSafariBrowser(url: URL) {
    let controller = SFSafariViewController(url: url)
    controller.modalPresentationStyle = .overFullScreen
    self.present(controller, animated: true, completion: nil)
  }

  fileprivate func goToUpdate(forProject project: Project, update: Update) {
    let vc = UpdateViewController.configuredWith(project: project, update: update, context: .updates)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  internal func webView(_ webView: WKWebView,
                        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
                        decisionHandler: (WKNavigationActionPolicy) -> Void) {
    decisionHandler(
      self.viewModel.inputs.decidePolicy(forNavigationAction: .init(navigationAction: navigationAction))
    )
  }
}
