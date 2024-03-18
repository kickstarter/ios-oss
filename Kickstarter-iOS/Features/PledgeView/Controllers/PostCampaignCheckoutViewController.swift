import KsApi
import Library
import Prelude
import UIKit

private enum PostCampaignCheckoutLayout {
  enum Style {
    static let cornerRadius: CGFloat = Styles.grid(2)
  }
}

final class PostCampaignCheckoutViewController: UIViewController {
  // MARK: - Properties

  private lazy var titleLabel = UILabel(frame: .zero)

  private lazy var paymentMethodsViewController = {
    PledgePaymentMethodsViewController.instantiate()
    // TODO: Add self as delegate and add support for delegate methods.
  }()

  private lazy var pledgeCTAContainerView: PledgeViewCTAContainerView = {
    PledgeViewCTAContainerView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
    // TODO: Add self as delegate and add support for delegate methods.
  }()

  private lazy var rootScrollView: UIScrollView = {
    UIScrollView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let viewModel: PostCampaignCheckoutViewModelType = PostCampaignCheckoutViewModel()

  // MARK: - Lifecycle

  func configure(with data: PledgeViewData) {
    self.viewModel.inputs.configure(with: data)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem
      .backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)

    _ = self
      |> \.extendedLayoutIncludesOpaqueBars .~ true

    self.title = Strings.Back_this_project()

    self.configureChildViewControllers()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Configuration

  private func configureChildViewControllers() {
    _ = (self.rootScrollView, self.view)
      |> ksr_addSubviewToParent()

    self.view.addSubview(self.rootScrollView)
    self.view.addSubview(self.pledgeCTAContainerView)

    _ = (self.rootStackView, self.rootScrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.rootStackView.addArrangedSubview(self.titleLabel)
    // TODO: Add payment methods VC to stack view.
    self.rootStackView.addArrangedSubview(self.paymentMethodsViewController.view)
    self.addChild(self.paymentMethodsViewController)
    self.paymentMethodsViewController.didMove(toParent: self)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.rootScrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.rootScrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.rootScrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.rootScrollView.bottomAnchor.constraint(equalTo: self.pledgeCTAContainerView.topAnchor),
      self.pledgeCTAContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.pledgeCTAContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.pledgeCTAContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      self.rootStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle

    // TODO: Update string to localized string
    self.titleLabel.text = "Checkout"
    self.titleLabel.font = UIFont.ksr_title2().bolded
    self.titleLabel.numberOfLines = 0

    self.rootScrollView.showsVerticalScrollIndicator = false
    self.rootScrollView.alwaysBounceVertical = true

    self.rootStackView.axis = NSLayoutConstraint.Axis.vertical
    self.rootStackView.spacing = Styles.grid(4)
    self.rootStackView.isLayoutMarginsRelativeArrangement = true
    self.rootStackView.layoutMargins = UIEdgeInsets(
      topBottom: ConfirmDetailsLayout.Margin.topBottom,
      leftRight: ConfirmDetailsLayout.Margin.leftRight
    )

    _ = self.paymentMethodsViewController.view
      |> roundedStyle(cornerRadius: PostCampaignCheckoutLayout.Style.cornerRadius)
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.configurePledgeViewCTAContainerView
      .observeForUI()
      .observeValues { [weak self] value in
        self?.pledgeCTAContainerView.configureWith(value: value)
      }

    self.viewModel.outputs.configurePaymentMethodsViewControllerWithValue
      .observeForUI()
      .observeValues { [weak self] value in
        self?.paymentMethodsViewController.configure(with: value)
      }
  }
}
