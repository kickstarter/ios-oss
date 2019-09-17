import KsApi
import Library
import Prelude
import UIKit

final class ManageViewPledgeViewController: UIViewController {
  // MARK: - Properties

  private lazy var closeButton: UIBarButtonItem = {
    UIBarButtonItem(
      image: UIImage(named: "icon--cross"),
      style: .plain,
      target: self,
      action: #selector(ManageViewPledgeViewController.closeButtonTapped)
    )
  }()

  private lazy var editButton: UIBarButtonItem = {
    UIBarButtonItem(
      image: UIImage(named: "icon--more-menu"),
      style: .plain,
      target: self,
      action: #selector(ManageViewPledgeViewController.editButtonTapped)
    )
  }()

  private lazy var pledgeSummaryView: ManagePledgeSummaryView = { ManagePledgeSummaryView(frame: .zero) }()

  private lazy var navigationBarShadowImage: UIImage? = {
    UIImage(in: CGRect(x: 0, y: 0, width: 1, height: 0.5), with: .ksr_dark_grey_400)
  }()

  private lazy var rootScrollView: UIScrollView = { UIScrollView(frame: .zero) }()

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let viewModel = ManageViewPledgeViewModel()

  static func instantiate(with project: Project, reward: Reward) -> ManageViewPledgeViewController {
    let manageViewPledgeVC = ManageViewPledgeViewController.instantiate()
    manageViewPledgeVC.viewModel.inputs.configureWith(project, reward: reward)

    return manageViewPledgeVC
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.extendedLayoutIncludesOpaqueBars .~ true

    _ = self.navigationController?.navigationBar
      ?|> \.shadowImage .~ UIImage()
      ?|> \.isTranslucent .~ false
      ?|> \.barTintColor .~ .ksr_grey_400

    _ = self.navigationItem
      ?|> \.leftBarButtonItem .~ self.closeButton
      ?|> \.rightBarButtonItem .~ self.editButton

    self.configureViews()
    self.setupConstraints()
    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> viewStyle

    _ = self.closeButton
      |> \.accessibilityLabel %~ { _ in Strings.Dismiss() }
      |> \.width .~ Styles.minTouchSize.width

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.title
      .observeForUI()
      .observeValues { [weak self] title in
        guard let self = self else { return }
        _ = self
          |> \.title .~ title
      }

    self.viewModel.outputs.configurePaymentMethodView
      .observeForUI()
      .observeValues { _ in }

    self.viewModel.outputs.configurePledgeSummaryView
      .observeForUI()
      .observeValues { [weak self] project in
        self?.pledgeSummaryView.configureWith(project)
      }

    self.viewModel.outputs.configureRewardSummaryView
      .observeForUI()
      .observeValues { _ in }
  }

  // MARK: - Configuration

  private func configureWith(project: Project, reward: Reward) {
    self.viewModel.inputs.configureWith(project, reward: reward)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.rootStackView.widthAnchor.constraint(equalTo: self.rootScrollView.widthAnchor)
    ])
  }

  // MARK: Functions

  private func configureViews() {
    _ = (self.rootScrollView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rootStackView, self.rootScrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.pledgeSummaryView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  // MARK: Actions

  @objc private func editButtonTapped() {
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    actionSheet.addAction(
      UIAlertAction(title: Strings.Contact_creator(), style: .default)
    )
    actionSheet.addAction(
      UIAlertAction(title: Strings.Cancel(), style: .cancel)
    )
    self.present(actionSheet, animated: true)
  }

  @objc private func closeButtonTapped() {
    self.dismiss(animated: true)
  }
}

// MARK: Styles

public let viewStyle: ViewStyle = { (view: UIView) in
  view
    |> \.backgroundColor .~ UIColor.ksr_grey_400
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.layoutMargins .~ .init(
      top: Styles.grid(3),
      left: Styles.grid(4),
      bottom: Styles.grid(3),
      right: Styles.grid(4)
    )
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.distribution .~ UIStackView.Distribution.fill
    |> \.alignment .~ UIStackView.Alignment.fill
    |> \.spacing .~ Styles.grid(4)
}
