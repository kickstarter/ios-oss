import Foundation
import KsApi
import Library
import Prelude
import SafariServices
import UIKit
import WebKit

internal final class ProjectDescriptionViewController: WebViewController {
  private let loadingIndicator = UIActivityIndicatorView()
  private lazy var pledgeCTAContainerView: PledgeCTAContainerView = {
    PledgeCTAContainerView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.delegate .~ self
  }()

  private let viewModel: ProjectDescriptionViewModelType = ProjectDescriptionViewModel()

  internal static func configuredWith(value: (Project, RefTag?)) -> ProjectDescriptionViewController {
    let vc = ProjectDescriptionViewController()
    vc.viewModel.inputs.configureWith(value: value)
    return vc
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configurePledgeCTAContainerView()

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

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.bottomAnchorConstraint?.constant = -(!self.pledgeCTAContainerView.isHidden ?
      self.pledgeCTAContainerView.frame.size.height : 0)
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      <> WebViewController.lens.title %~ { _ in Strings.project_menu_buttons_campaign() }
      <> (WebViewController.lens.webView.scrollView .. UIScrollView.lens.delaysContentTouches) .~ false
      <> (WebViewController.lens.webView.scrollView .. UIScrollView.lens.canCancelContentTouches) .~ true

    _ = self.loadingIndicator
      |> baseActivityIndicatorStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.loadingIndicator.rac.animating = self.viewModel.outputs.isLoading
    self.pledgeCTAContainerView.rac.hidden = self.viewModel.outputs.pledgeCTAContainerViewIsHidden

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

    self.viewModel.outputs.configurePledgeCTAContainerView
      .observeForUI()
      .observeValues { [weak self] value in
        self?.pledgeCTAContainerView.configureWith(value: value)
      }

    self.viewModel.outputs.goToRewards
      .observeForControllerAction()
      .observeValues { value in
        let vc = RewardsCollectionViewController.controller(with: value.0, refTag: value.1)

        self.present(vc, animated: true)
      }
  }

  // MARK: - Subviews

  private func configurePledgeCTAContainerView() {
    _ = (self.pledgeCTAContainerView, self.view)
      |> ksr_addSubviewToParent()

    let pledgeCTAContainerViewConstraints = [
      self.pledgeCTAContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.pledgeCTAContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.pledgeCTAContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ]

    NSLayoutConstraint.activate(pledgeCTAContainerViewConstraints)
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

  fileprivate func goToMessageDialog(subject: MessageSubject, context: Koala.MessageDialogContext) {
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

// MARK: - PledgeCTAContainerViewDelegate

extension ProjectDescriptionViewController: PledgeCTAContainerViewDelegate {
  func pledgeCTAButtonTapped(with state: PledgeStateCTAType) {
    self.viewModel.inputs.pledgeCTAButtonTapped(with: state)
  }
}
