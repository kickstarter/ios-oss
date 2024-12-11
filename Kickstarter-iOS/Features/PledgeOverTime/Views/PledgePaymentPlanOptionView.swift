import Library
import UIKit

protocol PledgePaymentPlanOptionViewDelegate: AnyObject {
  func pledgePaymentPlanOptionView(
    _ optionView: PledgePaymentPlanOptionView,
    didSelectPlanType paymentPlanType: PledgePaymentPlansType
  )
  func pledgePaymentPlansViewController(
    _ optionView: PledgePaymentPlanOptionView,
    didTapTermsOfUseWith helpType: HelpType
  )
}

final class PledgePaymentPlanOptionView: UIView {
  // MARK: - Properties

  private lazy var contentView: UIView = UIView(frame: .zero)
  private lazy var optionDescriptorStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var titleLabel = { UILabel(frame: .zero) }()
  private lazy var subtitleLabel = { UILabel(frame: .zero) }()
  private lazy var selectionIndicatorImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var termsOfUseButton: UIButton = { UIButton(frame: .zero) }()
  private lazy var paymentIncrementsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var ineligibleBadgeLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var ineligibleBadgeView: UIView = { UIView(frame: .zero) }()

  private let viewModel: PledgePaymentPlansOptionViewModelType = PledgePaymentPlansOptionViewModel()

  public weak var delegate: PledgePaymentPlanOptionViewDelegate?

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.bindViewModel()
    self.configureSubviews()
    self.setupConstraints()
    self.configureTapGestureAndActions()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  private func configureSubviews() {
    self.addSubview(self.contentView)

    self.contentView.addSubview(self.selectionIndicatorImageView)
    self.contentView.addSubview(self.optionDescriptorStackView)

    self.optionDescriptorStackView.addArrangedSubviews(
      self.titleLabel,
      self.subtitleLabel,
      self.ineligibleBadgeView,
      self.termsOfUseButton,
      self.paymentIncrementsStackView
    )

    // TODO: add strings translations [MBL-1860](https://kickstarter.atlassian.net/browse/MBL-1860)
    self.termsOfUseButton.setAttributedTitle(
      NSAttributedString(
        string: "See our Terms of Use",
        attributes: [NSAttributedString.Key.font: UIFont.ksr_caption1()]
      ),
      for: .normal
    )

    self.ineligibleBadgeLabel.text = "Available for pledges over $150"
  }

  private func setupConstraints() {
    self.contentView.translatesAutoresizingMaskIntoConstraints = false
    self.selectionIndicatorImageView.translatesAutoresizingMaskIntoConstraints = false
    self.optionDescriptorStackView.translatesAutoresizingMaskIntoConstraints = false

    self.titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    self.titleLabel.setContentHuggingPriority(.required, for: .vertical)

    self.subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    self.subtitleLabel.setContentHuggingPriority(.required, for: .vertical)

    NSLayoutConstraint.activate([
      self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Styles.grid(2)),
      self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Styles.grid(2)),
      self.contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: Styles.grid(2)),
      self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Styles.grid(2))
    ])

    NSLayoutConstraint.activate([
      self.optionDescriptorStackView.leadingAnchor.constraint(
        equalTo: self.selectionIndicatorImageView.trailingAnchor,
        constant: Styles.grid(2)
      ),
      self.optionDescriptorStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
      self.optionDescriptorStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
      self.optionDescriptorStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
    ])

    NSLayoutConstraint.activate([
      self.selectionIndicatorImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
      self.selectionIndicatorImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
      self.selectionIndicatorImageView.widthAnchor.constraint(equalToConstant: Styles.grid(4)),
      self.selectionIndicatorImageView.heightAnchor.constraint(
        equalTo: self.titleLabel.heightAnchor,
        multiplier: 1.0
      )
    ])

    self.ineligibleBadgeView.addSubview(self.ineligibleBadgeLabel)
    self.ineligibleBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
    self.ineligibleBadgeLabel.setContentHuggingPriority(.required, for: .horizontal)
    self.ineligibleBadgeView.setContentHuggingPriority(.required, for: .horizontal)

    NSLayoutConstraint.activate([
      self.ineligibleBadgeLabel.topAnchor.constraint(
        equalTo: self.ineligibleBadgeView.topAnchor,
        constant: 6
      ),
      self.ineligibleBadgeLabel.leadingAnchor.constraint(
        equalTo: self.ineligibleBadgeView.leadingAnchor,
        constant: 8
      ),
      self.ineligibleBadgeLabel.bottomAnchor.constraint(
        equalTo: self.ineligibleBadgeView.bottomAnchor,
        constant: -6
      ),
      self.ineligibleBadgeLabel.trailingAnchor.constraint(
        equalTo: self.ineligibleBadgeView.trailingAnchor,
        constant: -8
      )
    ])
  }

  private func configureTapGestureAndActions() {
    self.addGestureRecognizer(UITapGestureRecognizer(
      target: self,
      action: #selector(self.onOptionTapped)
    ))

    self.termsOfUseButton.addTarget(
      self,
      action: #selector(self.onTermsOfUseButtonTapped),
      for: .touchUpInside
    )
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    applyOptionDescriptorStackViewStyle(self.optionDescriptorStackView)
    self.optionDescriptorStackView.setCustomSpacing(0, after: self.subtitleLabel)

    applyTitleLabelStyle(self.titleLabel)
    applySubtitleLabelStyle(self.subtitleLabel)
    applySelectionIndicatorImageViewStyle(self.selectionIndicatorImageView)
    applyTermsOfUseStyle(self.termsOfUseButton)
    applyPaymentIncrementsStackViewStyle(self.paymentIncrementsStackView)
    applyIneligibleBadgeViewStyle(self.ineligibleBadgeView)
    applyIneligibleBadgeLabelStyle(self.ineligibleBadgeLabel)
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.selectionIndicatorImageName
      .observeForUI()
      .observeValues { [weak self] imageName in
        self?.selectionIndicatorImageView.image = Library.image(named: imageName)
      }

    self.titleLabel.rac.text = self.viewModel.outputs.titleText

    self.subtitleLabel.rac.text = self.viewModel.outputs.subtitleText
    self.subtitleLabel.isHidden = true
    self.subtitleLabel.rac.hidden = self.viewModel.outputs.subtitleLabelHidden

    self.viewModel.outputs.notifyDelegatePaymentPlanOptionSelected
      .observeForUI()
      .observeValues { [weak self] paymentPlan in
        guard let self = self else { return }

        self.delegate?.pledgePaymentPlanOptionView(self, didSelectPlanType: paymentPlan)
      }

    self.viewModel.outputs.notifyDelegateTermsOfUseTapped
      .observeForUI()
      .observeValues { [weak self] helpType in
        guard let self = self else { return }

        self.delegate?.pledgePaymentPlansViewController(self, didTapTermsOfUseWith: helpType)
      }

    self.ineligibleBadgeView.rac.hidden = self.viewModel.outputs.ineligibleBadgeHidden
    self.ineligibleBadgeLabel.rac.text = self.viewModel.outputs.ineligibleBadgeText

    self.termsOfUseButton.rac.hidden = self.viewModel.outputs.termsOfUseButtonHidden
    self.paymentIncrementsStackView.rac.hidden = self.viewModel.outputs.paymentIncrementsHidden

    self.viewModel.outputs.optionViewEnable
      .observeForUI()
      .observeValues { [weak self] isOptionViewEnable in
        self?.isUserInteractionEnabled = isOptionViewEnable
        applyTextColorByState(self!.titleLabel, isEnabled: isOptionViewEnable)
      }

    self.viewModel.outputs.paymentIncrements
      .observeForUI()
      .observeValues { [weak self] increments in
        guard let self = self else { return }

        self.setupIncrementsStackView(with: increments)
      }
  }

  func configureWith(value: PledgePaymentPlanOptionData) {
    self.viewModel.inputs.configureWith(data: value)
  }

  func refreshSelectedOption(_ selectedType: PledgePaymentPlansType) {
    self.viewModel.inputs.refreshSelectedType(selectedType)
  }

  // MARK: - Actions

  @objc private func onOptionTapped() {
    self.viewModel.inputs.optionTapped()
  }

  @objc private func onTermsOfUseButtonTapped() {
    self.viewModel.inputs.termsOfUseTapped()
  }

  // MARK: - Functions

  private func setupIncrementsStackView(with increments: [PledgePaymentIncrementFormatted]) {
    var dateLabels: [UILabel] = []
    increments.forEach { increment in
      let incrementStackView = UIStackView()
      applyIncrementStackViewStyle(incrementStackView)

      let titleLabel = UILabel()
      applyIncrementTitleLabelStyle(titleLabel)
      titleLabel.text = increment.title

      let detailsStackView = UIStackView()
      applyIncrementDetailsStackViewStyle(detailsStackView)

      let dateLabel = UILabel()
      applyIncrementDateLabelStyle(dateLabel)
      dateLabel.text = increment.scheduledCollection
      dateLabels.append(dateLabel)

      let amountLabel = UILabel()
      applyIncrementDateLabelStyle(amountLabel)
      amountLabel.text = increment.amount
      amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

      detailsStackView.addArrangedSubviews(dateLabel, amountLabel)
      incrementStackView.addArrangedSubviews(titleLabel, detailsStackView)

      self.paymentIncrementsStackView.addArrangedSubview(incrementStackView)
    }

    if let firstDateLabel = dateLabels.first {
      dateLabels.forEach { label in
        label.widthAnchor.constraint(equalTo: firstDateLabel.widthAnchor).isActive = true
      }
    }
  }
}

// MARK: - Styles helper

private func applyOptionDescriptorStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .vertical
  stackView.spacing = Styles.grid(1)
  stackView.alignment = .leading
}

private func applyPaymentIncrementsStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .vertical
  stackView.spacing = Styles.grid(2)
  stackView.alignment = .leading
}

private func applyTitleLabelStyle(_ label: UILabel) {
  label.accessibilityTraits = UIAccessibilityTraits.header
  label.adjustsFontForContentSizeCategory = true
  label.numberOfLines = 0
  label.font = UIFont.ksr_subhead().bolded
}

private func applySubtitleLabelStyle(_ label: UILabel) {
  label.accessibilityTraits = UIAccessibilityTraits.header
  label.adjustsFontForContentSizeCategory = true
  label.numberOfLines = 0
  label.font = UIFont.ksr_caption1()
  label.textColor = .ksr_support_400
}

private func applySelectionIndicatorImageViewStyle(_ imageView: UIImageView) {
  imageView.contentMode = .center
}

private func applyTermsOfUseStyle(_ button: UIButton) {
  button.configuration = {
    var config = UIButton.Configuration.borderless()
    config.contentInsets = NSDirectionalEdgeInsets(top: 1.0, leading: 0, bottom: 1.0, trailing: 0)
    config.baseForegroundColor = .ksr_create_700
    return config
  }()

  button.contentHorizontalAlignment = .leading
  button.setContentHuggingPriority(.required, for: .horizontal)
}

private func applyIncrementStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .vertical
  stackView.spacing = Styles.gridHalf(1)
}

private func applyIncrementDetailsStackViewStyle(_ stackview: UIStackView) {
  stackview.axis = .horizontal
  stackview.spacing = Styles.grid(6)
  stackview.distribution = .fill
}

private func applyIncrementTitleLabelStyle(_ label: UILabel) {
  label.font = UIFont.ksr_footnote().bolded
  label.textColor = .ksr_black
  label.textAlignment = .left
  label.adjustsFontForContentSizeCategory = true
  label.setContentCompressionResistancePriority(.required, for: .vertical)
}

private func applyIncrementDateLabelStyle(_ label: UILabel) {
  label.font = UIFont.ksr_footnote()
  label.textColor = .ksr_support_400
  label.textAlignment = .left
  label.adjustsFontForContentSizeCategory = true
}

private func applyIneligibleBadgeViewStyle(_ view: UIView) {
  view.backgroundColor = .ksr_support_100
  view.rounded(with: Styles.grid(1))
}

private func applyIneligibleBadgeLabelStyle(_ label: UILabel) {
  label.font = UIFont.ksr_caption1().bolded
  label.textColor = .ksr_support_500
  label.textAlignment = .center
  label.numberOfLines = 0
  label.adjustsFontForContentSizeCategory = true
}

private func applyTextColorByState(_ label: UILabel, isEnabled: Bool) {
  var textColor = UIColor.ksr_black

  if !isEnabled {
    textColor = .ksr_support_300
  }

  label.textColor = textColor
}
