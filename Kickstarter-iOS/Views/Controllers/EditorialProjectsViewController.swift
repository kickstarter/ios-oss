import KsApi
import Library
import Prelude
import UIKit

public final class EditorialProjectsViewController: UIViewController {
  // MARK: - Properties

  private lazy var closeButton: UIButton = {
    UIButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var discoveryPageViewController: DiscoveryPageViewController = {
    DiscoveryPageViewController.configuredWith(sort: .magic)
      |> \.preferredBackgroundColor .~ .clear
  }()

  private lazy var headerView: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let viewModel: EditorialProjectsViewModelType = EditorialProjectsViewModel()

  // MARK: - Lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
    self.setupConstraints()

    self.closeButton.addTarget(
      self,
      action: #selector(EditorialProjectsViewController.closeButtonTapped),
      for: .touchUpInside
    )

    // Will be moved to be a testable output of VC that presents this one
    self.viewModel.inputs.configure(with: .goRewardless)

    self.viewModel.inputs.viewDidLoad()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    let currentTableViewInsets = self.discoveryPageViewController.tableView.contentInset

    self.discoveryPageViewController.tableView.contentInset = currentTableViewInsets
      |> UIEdgeInsets.lens.top .~ (self.headerView.frame.height - self.view.safeAreaInsets.top)

    self.discoveryPageViewController.tableView.scrollIndicatorInsets =
      self.discoveryPageViewController.tableView.contentInset
  }

  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - Styles

  public override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> \.backgroundColor .~ UIColor.white

    _ = self.headerView
      |> \.backgroundColor .~ UIColor.hex(0x00007D)

    _ = self.closeButton
      |> UIButton.lens.title(for: .normal) .~ nil
      |> UIButton.lens.image(for: .normal) .~ image(named: "icon--cross", tintColor: .white)
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.accessibility_projects_buttons_close() }
      |> UIButton.lens.accessibilityHint %~ { _ in
        Strings.dashboard_switcher_accessibility_label_closes_list_of_projects()
      }
  }

  // MARK: - View model

  public override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.configureDiscoveryPageViewControllerWithParams
      .observeForUI()
      .observeValues { [weak self] params in
        self?.discoveryPageViewController.change(filter: params)
      }

    self.viewModel.outputs.dismiss
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dismiss(animated: true)
      }
  }

  // MARK: - Layout

  private func configureSubviews() {
    _ = (self.headerView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.discoveryPageViewController.view, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.closeButton, self.view)
      |> ksr_addSubviewToParent()

    self.addChild(self.discoveryPageViewController)
    self.discoveryPageViewController.didMove(toParent: self)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.headerView.widthAnchor.constraint(equalTo: self.discoveryPageViewController.tableView.widthAnchor),
      self.closeButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
      self.closeButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height),
      self.closeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.width)
    ])

    // remove once header has content
    self.headerView.heightAnchor.constraint(equalToConstant: 300).isActive = true
  }

  // MARK: - Actions

  @objc private func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }
}
