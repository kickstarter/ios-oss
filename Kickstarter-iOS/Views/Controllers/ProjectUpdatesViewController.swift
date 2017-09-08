import KsApi
import Library
import Prelude
import SafariServices

internal final class ProjectUpdatesViewController: WebViewController {
  fileprivate let viewModel: ProjectUpdatesViewModelType = ProjectUpdatesViewModel()
  fileprivate let activityIndicator = UIActivityIndicatorView()
  internal static func configuredWith(project: Project) -> ProjectUpdatesViewController {
    let vc = ProjectUpdatesViewController()
    vc.viewModel.inputs.configureWith(project: project)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(self.activityIndicator)
    NSLayoutConstraint.activate([
      self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
    ])
    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self |> baseControllerStyle()
    _ = self.activityIndicator |> baseActivityIndicatorStyle

    self.navigationItem.title = Strings.project_menu_buttons_updates()
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

    self.activityIndicator.rac.hidden = self.viewModel.outputs.isActivityIndicatorHidden
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

  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    self.viewModel.inputs.webViewDidStartProvisionalNavigation()
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    self.viewModel.inputs.webViewDidFinishNavigation()
  }
}
