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
      |> \.delegate .~ self
  }()

  private lazy var editorialLabelStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var editorialImageView = {
    UIImageView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var editorialSubtitleLabel: UILabel = {
    UILabel(frame: .zero)
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

    _ = self.discoveryPageViewController.view
      |> \.backgroundColor .~ .clear

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

    _ = self.editorialLabelStackView
      |> \.axis .~ .vertical
      |> \.spacing .~ Styles.grid(2)
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.distribution .~ .fill
      |> UIStackView.lens.layoutMargins .~ .init(
        top: Styles.grid(15), left: Styles.grid(6), bottom: Styles.grid(7), right: Styles.grid(6)
      )

    _ = self.editorialTitleLabel
      |> editorialLabelStyle
      |> \.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? UIFont.ksr_title2(size: 30).bolded
          : UIFont.ksr_title2().bolded
      }

    _ = self.editorialSubtitleLabel
      |> editorialLabelStyle
      |> \.text %~ { _ in Strings.Help_local_businesses_keep_the_lights() }
      |> \.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? UIFont.ksr_headline(size: 20)
          : UIFont.ksr_headline().bolded
      }

    _ = self.closeButton
      |> closeButtonStyle
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

    self.editorialTitleLabel.rac.text = self.viewModel.outputs.titleLabelText
    self.closeButton.rac.tintColor = self.viewModel.outputs.closeButtonImageTintColor
  }

  // MARK: - Layout

  private func configureSubviews() {
    _ = (self.headerView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.discoveryPageViewController.view, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.headerTopLayoutGuide, self.headerView)
      |> ksr_addLayoutGuideToView()

    _ = (self.editorialImageView, self.headerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.editorialLabelStackView, self.headerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.editorialTitleLabel, self.editorialSubtitleLabel], self.editorialLabelStackView)
      |> ksr_addArrangedSubviewsToStackView()

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
      // closeButton
      self.closeButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: Styles.grid(1)),
      self.closeButton.topAnchor.constraint(
        equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: Styles.grid(3)
      ),
      self.closeButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height),
      self.closeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.width)
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

private let closeButtonStyle: ButtonStyle = { button in
  button
    |> UIButton.lens.image(for: .normal) .~ image(named: "icon--close-circle")
    |> UIButton.lens.accessibilityLabel %~ { _ in Strings.accessibility_projects_buttons_close() }
    |> UIButton.lens.accessibilityHint %~ { _ in
      Strings.dashboard_switcher_accessibility_label_closes_list_of_projects()
    }
}

private let headerViewStyle: ViewStyle = { view in
  view
    |> \.clipsToBounds .~ true
}

private let editorialLabelStyle: LabelStyle = { label in
  label
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .white
    |> \.textAlignment .~ .center
}
