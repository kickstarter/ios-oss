import Foundation
import KsApi
import Library
import Prelude
import SafariServices
import UIKit
import WebKit

internal final class ProjectDescriptionViewController: WebViewController {
  private let loadingIndicator = UIActivityIndicatorView()
  private let viewModel: ProjectDescriptionViewModelType = ProjectDescriptionViewModel()

  internal static func configuredWith(data: ProjectPamphletMainCellData) -> ProjectDescriptionViewController {
    let vc = ProjectDescriptionViewController()
    vc.viewModel.inputs.configureWith(value: data)
    return vc
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(self.loadingIndicator)
    NSLayoutConstraint.activate(
      [
        self.loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        self.loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
      ]
    )

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> self.projectDescriptionViewControllerStyle

    _ = self.loadingIndicator
      |> baseActivityIndicatorStyle
  }

  private let projectDescriptionViewControllerStyle: (WebViewController) -> WebViewController = { vc in
    vc
      |> baseControllerStyle()
      |> WebViewController.lens.title %~ { _ in Strings.project_menu_buttons_campaign() }
      |> (WebViewController.lens.webView.scrollView .. UIScrollView.lens.delaysContentTouches) .~ false
      |> (WebViewController.lens.webView.scrollView .. UIScrollView.lens.canCancelContentTouches) .~ true
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.loadingIndicator.rac.animating = self.viewModel.outputs.isLoading

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
        self?.goTo(url: $0)
      }

    self.viewModel.outputs.loadWebViewRequest
      .observeForControllerAction()
      .observeValues { [weak self] in
        _ = self?.webView.load($0)
      }

    self.viewModel.outputs.showErrorAlert
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.present(
          UIAlertController.genericError($0.localizedDescription),
          animated: true,
          completion: nil
        )
      }
  }

  // MARK: - WKNavigationDelegate

  internal func webView(
    _: WKWebView,
    decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
  ) {
    self.viewModel.inputs.decidePolicyFor(navigationAction: .init(navigationAction: navigationAction))
    decisionHandler(self.viewModel.outputs.decidedPolicyForNavigationAction)
  }

  internal func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
    self.viewModel.inputs.webViewDidStartProvisionalNavigation()
  }

  internal func webView(_: WKWebView, didFinish _: WKNavigation!) {
    self.viewModel.inputs.webViewDidFinishNavigation()
  }

  internal func webView(
    _: WKWebView,
    didFailProvisionalNavigation _: WKNavigation!,
    withError error: Error
  ) {
    self.viewModel.inputs.webViewDidFailProvisionalNavigation(withError: error)
  }

  // MARK: - Navigation

  fileprivate func goToMessageDialog(subject: MessageSubject, context: KSRAnalytics.MessageDialogContext) {
    let vc = MessageDialogViewController.configuredWith(messageSubject: subject, context: context)
    vc.delegate = self
    self.present(
      UINavigationController(rootViewController: vc),
      animated: true,
      completion: nil
    )
  }
}

// MARK: - MessageDialogViewControllerDelegate

extension ProjectDescriptionViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(_ dialog: MessageDialogViewController) {
    dialog.dismiss(animated: true, completion: nil)
  }

  internal func messageDialog(_: MessageDialogViewController, postedMessage _: Message) {}
}
