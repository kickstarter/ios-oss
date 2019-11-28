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

  internal lazy var discoveryPageViewController: DiscoveryPageViewController = {
    DiscoveryPageViewController.configuredWith(sort: .magic)
      |> \.preferredBackgroundColor .~ .clear
      |> \.delegate .~ self
  }()

  private lazy var editorialImageView = {
    UIImageView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var editorialTitleLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var headerView: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var headerTopLayoutGuide: UILayoutGuide = { UILayoutGuide() }()
  private var headerTopLayoutGuideHeightConstraint: NSLayoutConstraint?

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

    self.viewModel.inputs.viewDidLoad()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.updateTableViewContentInset()
  }

  public override func viewSafeAreaInsetsDidChange() {
    super.viewSafeAreaInsetsDidChange()

    self.updateTableViewContentInset()
  }

  private func updateTableViewContentInset() {
    let currentTableViewInsets = self.discoveryPageViewController.tableView.contentInset

    self.discoveryPageViewController.tableView.contentInset = currentTableViewInsets
      |> UIEdgeInsets.lens.top .~ (self.headerView.frame.height - self.view.safeAreaInsets.top)

    self.discoveryPageViewController.tableView.scrollIndicatorInsets =
      self.discoveryPageViewController.tableView.contentInset

    self.headerTopLayoutGuideHeightConstraint?.constant = self.view.safeAreaInsets.top
  }

  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return self.viewModel.outputs.preferredStatusBarStyle()
  }

  // MARK: - Styles

  public override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> \.backgroundColor .~ UIColor.white

    _ = self.headerView
      |> UIView.lens.layoutMargins %~~ { _, view in
        view.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(2), left: Styles.grid(30), bottom: 0, right: Styles.grid(30))
          : .init(top: Styles.grid(2), left: Styles.grid(7), bottom: 0, right: Styles.grid(6))
      }

    _ = self.headerView
      |> headerViewStyle

    _ = self.editorialImageView
      |> UIImageView.lens.contentMode .~ .scaleAspectFill

    _ = self.editorialTitleLabel
      |> editorialLabelStyle
      |> \.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? UIFont.ksr_title3(size: 30).bolded
          : UIFont.ksr_title3().bolded
      }

    _ = self.closeButton
      |> UIButton.lens.image(for: .normal) .~ image(named: "icon--cross")
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

    self.viewModel.outputs.imageName
      .observeForUI()
      .observeValues { [weak self] imageName in
        guard let self = self else { return }

        _ = self.editorialImageView
          |> \.image %~ { _ in
            Library.image(
              named: imageName,
              inBundle: Bundle.framework,
              compatibleWithTraitCollection: nil
            )
          }
      }

    self.viewModel.outputs.setNeedsStatusBarAppearanceUpdate
      .observeForUI()
      .observeValues { [weak self] in
        self?.setNeedsStatusBarAppearanceUpdate()
      }

    self.viewModel.outputs.applyViewTransformsWithYOffset
      .observeForControllerAction()
      .observeValues { [weak self] y in
        self?.applyViewTransforms(withYOffset: y)
      }

    self.editorialTitleLabel.rac.text = self.viewModel.outputs.titleLabelText
    self.closeButton.rac.tintColor = self.viewModel.outputs.closeButtonImageTintColor
  }

  // MARK: - Layout

  private func configureSubviews() {
    _ = (self.headerView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.headerTopLayoutGuide, self.headerView)
      |> ksr_addLayoutGuideToView()

    _ = (self.editorialTitleLabel, self.headerView)
      |> ksr_addSubviewToParent()

    _ = (self.editorialImageView, self.headerView)
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
    let headerTopLayoutGuideHeightConstraint = self.headerTopLayoutGuide.heightAnchor
      .constraint(equalToConstant: 0)
    self.headerTopLayoutGuideHeightConstraint = headerTopLayoutGuideHeightConstraint

    NSLayoutConstraint.activate([
      // headerView
      self.headerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.headerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.headerView.widthAnchor.constraint(equalTo: self.discoveryPageViewController.tableView.widthAnchor),
      // headerTopLayoutGuide
      self.headerTopLayoutGuide.leftAnchor.constraint(equalTo: self.headerView.leftAnchor),
      self.headerTopLayoutGuide.rightAnchor.constraint(equalTo: self.headerView.rightAnchor),
      self.headerTopLayoutGuide.topAnchor.constraint(equalTo: self.headerView.topAnchor),
      headerTopLayoutGuideHeightConstraint,
      // editorialTitleLabel
      self.editorialTitleLabel.leftAnchor.constraint(equalTo: self.headerView.layoutMarginsGuide.leftAnchor),
      self.editorialTitleLabel.topAnchor
        .constraint(equalTo: self.headerTopLayoutGuide.bottomAnchor, constant: Styles.gridHalf(3)),
      self.editorialTitleLabel.rightAnchor
        .constraint(equalTo: self.headerView.layoutMarginsGuide.rightAnchor),
      // closeButton
      self.closeButton.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.closeButton.topAnchor.constraint(
        equalTo: self.view.safeAreaLayoutGuide.topAnchor
      ),
      self.closeButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height),
      self.closeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.width),
      // editorialImageView
      self.editorialImageView.leftAnchor.constraint(equalTo: self.headerView.leftAnchor),
      self.editorialImageView.rightAnchor.constraint(equalTo: self.headerView.rightAnchor),
      self.editorialImageView.bottomAnchor.constraint(equalTo: self.headerView.bottomAnchor),
      self.editorialImageView.topAnchor.constraint(
        equalTo: self.editorialTitleLabel.bottomAnchor,
        constant: Styles.grid(6)
      )
    ])
  }

  // MARK: - Accessors

  func configure(with tagId: DiscoveryParams.TagID) {
    self.viewModel.inputs.configure(with: tagId)
  }

  // MARK: - Actions

  @objc private func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }

  private func applyViewTransforms(withYOffset y: CGFloat) {
    let normalizedY = abs(y) - self.headerView.frame.height

    let imageViewScale = max(1, 1 + (normalizedY * 0.0025))
    let labelScale = min(1.25, 1 + (normalizedY * 0.00015))
    let labelAlpha = 1 - (-normalizedY * 0.005)

    self.editorialImageView.transform = CGAffineTransform(scaleX: imageViewScale, y: imageViewScale)
    self.editorialTitleLabel.transform = CGAffineTransform(scaleX: labelScale, y: labelScale)
    self.editorialTitleLabel.alpha = labelAlpha
  }
}

// MARK: - DiscoveryPageViewControllerDelegate

extension EditorialProjectsViewController: DiscoveryPageViewControllerDelegate {
  func discoverPageViewController(
    _: DiscoveryPageViewController,
    contentOffsetDidChangeTo offset: CGPoint
  ) {
    self.viewModel.inputs.discoveryPageViewControllerContentOffsetChanged(to: offset)
  }
}

// MARK: - Styles

private let headerViewStyle: ViewStyle = { view in
  view
    |> \.clipsToBounds .~ true
    |> \.backgroundColor .~ .ksr_trust_700
}

private let editorialLabelStyle: LabelStyle = { label in
  label
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .white
    |> \.textAlignment .~ .center
}
