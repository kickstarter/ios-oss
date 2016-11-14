import KsApi
import Library
import Prelude
import UIKit

internal final class UpdateViewController: WebViewController {
  private let viewModel: UpdateViewModelType = UpdateViewModel()
  private let shareViewModel: ShareViewModelType = ShareViewModel()

  private let closeButton = UIBarButtonItem()

  @IBOutlet private weak var shareButton: UIBarButtonItem!

  internal static func configuredWith(project project: Project, update: Update) -> UpdateViewController {
    let vc = Storyboard.Update.instantiate(UpdateViewController)
    vc.viewModel.inputs.configureWith(project: project, update: update)
    vc.shareViewModel.inputs.configureWith(shareContext: .update(project, update))
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    self.navigationController?.setNavigationBarHidden(false, animated: animated)

    guard
      self.presentingViewController != nil,
      let navigationController = self.navigationController
      where navigationController.viewControllers == [self]
      else { return }

    self.navigationItem.leftBarButtonItem = self.closeButton
  }

  internal override func bindStyles() {
    self |> baseControllerStyle()

    self.closeButton |> closeBarButtonItemStyle
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(dismiss))

    self.shareButton
      |> UIBarButtonItem.lens.accessibilityLabel %~ { _ in
        localizedString(key: "Share_update", defaultValue: "Share update")
    }
  }

  internal override func bindViewModel() {
    self.navigationItem.rac.title = self.viewModel.outputs.title

    self.viewModel.outputs.webViewLoadRequest
      .observeForControllerAction()
      .observeNext { [weak self] in self?.webView.loadRequest($0) }

    self.viewModel.outputs.goToComments
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goToComments(forUpdate: $0) }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goTo(project: $0, refTag: $1) }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeNext { [weak self] in self?.showShareSheet($0) }
  }

  internal func webView(webView: WKWebView,
                        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
                        decisionHandler: (WKNavigationActionPolicy) -> Void) {

    decisionHandler(self.viewModel.inputs.decidePolicyFor(navigationAction: navigationAction))
  }

  private func goToComments(forUpdate update: Update) {
    let vc = CommentsViewController.configuredWith(update: update)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goTo(project project: Project, refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project, refTag: refTag)
    self.presentViewController(vc, animated: true, completion: nil)
  }

  private func showShareSheet(activityController: UIActivityViewController) {

    activityController.completionWithItemsHandler = { [weak self] in
      self?.shareViewModel.inputs.shareActivityCompletion(activityType: $0,
                                                          completed: $1,
                                                          returnedItems: $2,
                                                          activityError: $3)
    }

    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      activityController.modalPresentationStyle = .Popover
      let popover = activityController.popoverPresentationController
      popover?.permittedArrowDirections = .Any
      popover?.barButtonItem = self.navigationItem.rightBarButtonItem
    }

    self.presentViewController(activityController, animated: true, completion: nil)
  }

  @IBAction private func shareButtonTapped() {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  @objc private func dismiss() {
    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
}
