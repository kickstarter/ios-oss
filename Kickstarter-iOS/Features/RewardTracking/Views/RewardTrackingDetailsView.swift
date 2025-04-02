import Library
import UIKit

private enum Constants {
  static let rootStackViewSpacing = Styles.grid(2)
  static let rootStackViewLayoutMargins = UIEdgeInsets(all: 16.0)
  static let titleStackViewSpacing: CGFloat = 8.0
}

protocol RewardTrackingDetailsViewDelegate: AnyObject {
  func didTrackingButtonTap(with trackingURL: URL)
}

final class RewardTrackingDetailsView: UIView {
  // MARK: Properties

  public weak var delegate: RewardTrackingDetailsViewDelegate?
  private let viewModel: RewardTrackingDetailsViewModelType = RewardTrackingDetailsViewModel()

  private let rootStackView: UIStackView = UIStackView(frame: .zero)
  private let trackingTitleStackView: UIStackView = UIStackView(frame: .zero)
  private let trackingIconImageView: UIImageView = UIImageView(frame: .zero)
  private let trackingStatusLabel: UILabel = UILabel(frame: .zero)
  private let trackingNumberLabel: UILabel = UILabel(frame: .zero)
  private let trackingButton: KSRButton = KSRButton(style: .filled)

  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.setupConstraints()
    self.bindViewModel()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  public override func bindStyles() {
    super.bindStyles()

    applyRootStackViewStyle(self.rootStackView)
    applyTrackingIconImageViewStyle(self.trackingIconImageView)
    applyTrackingTitleStackViewStyle(self.trackingTitleStackView)
    applyTrackingStatusLabelStyle(self.trackingStatusLabel)
    applyTrackingNumberLabelStyle(self.trackingNumberLabel)
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.trackingStatusLabel.rac.text = self.viewModel.outputs.rewardTrackingStatus
    self.trackingNumberLabel.rac.text = self.viewModel.outputs.rewardTrackingNumber
    self.rootStackView.rac.backgroundColor = self.viewModel.outputs.backgroundColor

    self.viewModel.outputs.trackShipping
      .observeForUI()
      .observeValues { [weak self] trackingURL in
        self?.delegate?.didTrackingButtonTap(with: trackingURL)
      }

    self.viewModel.outputs.cornerRadius
      .observeForUI()
      .observeValues { [weak self] cornerRadius in
        self?.rootStackView.rounded(with: cornerRadius)
      }
  }

  private func configureViews() {
    self.addSubview(self.rootStackView)

    self.trackingTitleStackView.addArrangedSubviews(
      self.trackingIconImageView,
      self.trackingStatusLabel
    )

    self.rootStackView.addArrangedSubviews(
      self.trackingTitleStackView,
      self.trackingNumberLabel,
      self.trackingButton
    )

    // TODO: Replace with localized string once translations are available. [MBL-2271](https://kickstarter.atlassian.net/browse/MBL-2271)
    self.trackingButton.setTitle("Track shipment", for: .normal)
    self.trackingButton.addTarget(self, action: #selector(self.onTrackingButtonTapped), for: .touchUpInside)
  }

  private func setupConstraints() {
    self.rootStackView.constrainViewToEdges(in: self)
  }

  public func configure(with data: RewardTrackingDetailsViewData) {
    self.viewModel.inputs.configure(with: data)
  }

  // MARK: - Actions

  @objc private func onTrackingButtonTapped() {
    self.viewModel.inputs.trackingButtonTapped()
  }
}

// Styles helper
private func applyRootStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .vertical
  stackView.spacing = Constants.rootStackViewSpacing
  stackView.layoutMargins = Constants.rootStackViewLayoutMargins
  stackView.isLayoutMarginsRelativeArrangement = true
}

private func applyTrackingTitleStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .horizontal
  stackView.spacing = Constants.titleStackViewSpacing
}

private func applyTrackingIconImageViewStyle(_ imageView: UIImageView) {
  imageView.image = image(named: "icon-shipped")
  imageView.tintColor = Colors.Icon.primary.adaptive()
  imageView.contentMode = .scaleAspectFit
  imageView.setContentHuggingPriority(.required, for: .horizontal)
}

private func applyTrackingStatusLabelStyle(_ label: UILabel) {
  label.textColor = Colors.Text.primary.adaptive()
  label.font = .ksr_headingMD()
  label.adjustsFontForContentSizeCategory = true
}

private func applyTrackingNumberLabelStyle(_ label: UILabel) {
  label.textColor = .ksr_support_400 // Do we want to implement a new Design System color?
  label.font = .ksr_bodyMD()
  label.adjustsFontForContentSizeCategory = true
}
