import Library
import UIKit

private enum Constants {
  static let rootStackViewSpacing = 14.0
  static let rootStackViewCustomSpacing = Styles.grid(1)
  static let rootStackViewLayoutMargins = UIEdgeInsets(all: 16.0)
  static let titleStackViewSpacing: CGFloat = 8.0
  static let activityStyleCornerRadius: CGFloat = 8.0
  static let backingStyleCornerRadius: CGFloat = 8.0
}

public enum RewardTrackingDetailsViewStyle {
  case activity
  case backingDetails
}

protocol RewardTrackingDetailsViewDelegate: AnyObject {
  func didTapTrackingButton(with trackingURL: URL)
}

final class RewardTrackingDetailsView: UIView {
  // MARK: Properties

  public weak var delegate: RewardTrackingDetailsViewDelegate?
  private let viewModel: RewardTrackingDetailsViewModelType = RewardTrackingDetailsViewModel()
  private var style: RewardTrackingDetailsViewStyle

  private let rootStackView: UIStackView = UIStackView(frame: .zero)
  private let trackingTitleStackView: UIStackView = UIStackView(frame: .zero)
  private let trackingIconImageView: UIImageView = UIImageView(frame: .zero)
  private let trackingStatusLabel: UILabel = UILabel(frame: .zero)
  private let trackingNumberLabel: UILabel = UILabel(frame: .zero)
  private let trackingButton: KSRButton = KSRButton(style: .filled)

  // MARK: Lifecycle

  init(frame: CGRect = .zero, style: RewardTrackingDetailsViewStyle) {
    self.style = style
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

    applyRootStackViewStyle(self.rootStackView, style: self.style)
    applyTrackingIconImageViewStyle(self.trackingIconImageView)
    applyTrackingTitleStackViewStyle(self.trackingTitleStackView)
    applyTrackingStatusLabelStyle(self.trackingStatusLabel)
    applyTrackingNumberLabelStyle(self.trackingNumberLabel)
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.trackingStatusLabel.rac.text = self.viewModel.outputs.rewardTrackingStatus
    self.trackingNumberLabel.rac.text = self.viewModel.outputs.rewardTrackingNumber
    self.trackingButton.rac.hidden = self.viewModel.outputs.trackingButtonHidden

    self.viewModel.outputs.trackShipping
      .observeForUI()
      .observeValues { [weak self] trackingURL in
        guard let url = trackingURL else { return }

        self?.delegate?.didTapTrackingButton(with: url)
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

    self.trackingButton.setTitle(Strings.Track_shipment(), for: .normal)
    self.trackingButton.addTarget(self, action: #selector(self.onTrackingButtonTapped), for: .touchUpInside)
  }

  private func setupConstraints() {
    self.rootStackView.constrainViewToEdges(in: self)

    self.rootStackView.setCustomSpacing(
      Constants.rootStackViewCustomSpacing,
      after: self.trackingTitleStackView
    )
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
private func applyRootStackViewStyle(_ stackView: UIStackView, style: RewardTrackingDetailsViewStyle) {
  stackView.axis = .vertical
  stackView.spacing = Constants.rootStackViewSpacing
  stackView.layoutMargins = Constants.rootStackViewLayoutMargins
  stackView.isLayoutMarginsRelativeArrangement = true
  stackView.backgroundColor = style.backgroundColor
  stackView.rounded(with: style.cornerRadius)
}

private func applyTrackingTitleStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .horizontal
  stackView.spacing = Constants.titleStackViewSpacing
}

private func applyTrackingIconImageViewStyle(_ imageView: UIImageView) {
  imageView.image = Library.image(named: "icon-shipped")
  imageView.tintColor = Colors.Icon.primary.uiColor()
  imageView.contentMode = .scaleAspectFit
  imageView.setContentHuggingPriority(.required, for: .horizontal)
}

private func applyTrackingStatusLabelStyle(_ label: UILabel) {
  label.textColor = Colors.Text.primary.uiColor()
  label.font = .ksr_headingMD()
  label.adjustsFontForContentSizeCategory = true
}

private func applyTrackingNumberLabelStyle(_ label: UILabel) {
  label.textColor = LegacyColors.ksr_support_400
    .uiColor() // Do we want to implement a new Design System color?
  label.font = .ksr_bodyMD()
  label.adjustsFontForContentSizeCategory = true
}

extension RewardTrackingDetailsViewStyle {
  fileprivate var backgroundColor: UIColor {
    switch self {
    case .activity: return Colors.Background.Surface.primary.uiColor()
    case .backingDetails: return LegacyColors.ksr_support_200.uiColor()
    }
  }

  fileprivate var cornerRadius: CGFloat {
    switch self {
    case .activity: return Constants.activityStyleCornerRadius
    case .backingDetails: return Constants.backingStyleCornerRadius
    }
  }
}
