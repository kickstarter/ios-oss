import KsApi
import Library
import SafariServices

internal final class ProjectUpdatesViewController: WebViewController {
  private let viewModel: ProjectUpdatesViewModelType = ProjectUpdatesViewModel()

  internal static func configuredWith(project project: Project) -> ProjectUpdatesViewController {
    let vc = ProjectUpdatesViewController()
    vc.viewModel.inputs.configureWith(project: project)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.navigationItem.title = Strings.project_menu_buttons_updates()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.goToSafariBrowser
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goToSafariBrowser(url: $0) }

    self.viewModel.outputs.goToUpdate
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goToUpdate(forProject: $0, update: $1) }

    self.viewModel.outputs.goToUpdateComments
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goToComments(forUpdate: $0) }

    self.viewModel.outputs.webViewLoadRequest
      .observeForControllerAction()
      .observeNext { [weak self] in self?.webView.loadRequest($0) }
  }

  private func goToComments(forUpdate update: Update) {
    let vc = CommentsViewController.configuredWith(update: update)
    if self.traitCollection.userInterfaceIdiom == .Pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = UIModalPresentationStyle.FormSheet
      self.presentViewController(nav, animated: true, completion: nil)
    } else {
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  private func goToSafariBrowser(url url: NSURL) {
    let controller = SFSafariViewController(URL: url)
    controller.modalPresentationStyle = .OverFullScreen
    self.presentViewController(controller, animated: true, completion: nil)
  }

  private func goToUpdate(forProject project: Project, update: Update) {
    let vc = UpdateViewController.configuredWith(project: project, update: update)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  internal func webView(webView: WKWebView,
                        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
                                                        decisionHandler: (WKNavigationActionPolicy) -> Void) {
    decisionHandler(
      self.viewModel.inputs.decidePolicy(forNavigationAction: .init(navigationAction: navigationAction))
    )
  }
}
