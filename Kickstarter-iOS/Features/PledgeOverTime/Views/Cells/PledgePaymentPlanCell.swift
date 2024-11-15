import Library
import UIKit

final class PledgePaymentPlanCell: UITableViewCell, ValueCell {
  // MARK: properties

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()

  private lazy var leftColumnStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var rigthColumnStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var titleLabel = { UILabel(frame: .zero) }()
  private lazy var subtitleLabel = { UILabel(frame: .zero) }()
  private lazy var checkmarkImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var selectionView: UIView = { UIView(frame: .zero) }()

  private let viewModel: PledgePaymentPlansCellViewModelType = PledgePaymentPlansCellViewModel()

  // MARK: Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureSubviews()
    self.setupConstraints()
    self.bindViewModel()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  private func configureSubviews() {
    
    self.contentView.addSubview(self.rootStackView)
    
    addArrangedSubviews([self.checkmarkImageView, UIView()], to: self.leftColumnStackView)
    
    addArrangedSubviews([self.titleLabel, UIView()], to: self.rigthColumnStackView)
    
    addArrangedSubviews([self.leftColumnStackView, self.rigthColumnStackView], to: self.rootStackView)
    
    self.titleLabel.text = "Pledge Over Time" // TODO: add strings translations [MBL-1860](https://kickstarter.atlassian.net/browse/MBL-1860)
    
    self.subtitleLabel.text = "You will be charged for your pledge over four payments, at no extra cost." // TODO: add strings translations [MBL-1860](https://kickstarter.atlassian.net/browse/MBL-1860)
  }

  private func setupConstraints() {
    self.rootStackView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      self.rootStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
      self.rootStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
      self.rootStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
      self.rootStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
    ])
    
    self.titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    self.titleLabel.setContentHuggingPriority(.required, for: .vertical)

    self.subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    self.subtitleLabel.setContentHuggingPriority(.required, for: .vertical)

    NSLayoutConstraint.activate([
      self.checkmarkImageView.widthAnchor.constraint(equalToConstant: Styles.grid(4)),
      self.checkmarkImageView.heightAnchor.constraint(equalTo: self.checkmarkImageView.widthAnchor)
    ])

    NSLayoutConstraint.activate([
      self.checkmarkImageView.widthAnchor.constraint(equalToConstant: Styles.grid(4)),
      self.checkmarkImageView.heightAnchor.constraint(equalTo: self.checkmarkImageView.widthAnchor)
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()
    
    self.selectionView.backgroundColor = .ksr_support_100

    self.selectedBackgroundView = self.selectionView

    applyRootStackViewStyle(self.rootStackView)
    
    applyColumnStackViewStyle(self.leftColumnStackView)
    self.leftColumnStackView.spacing = 0
    
    applyColumnStackViewStyle(self.rigthColumnStackView)

    applyTitleLabelStyle(self.titleLabel)
    
    applySubtitleLabelStyle(self.subtitleLabel)

    applyCheckmarkImageViewStyle(self.checkmarkImageView)
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.checkmarkImageName
      .observeForUI()
      .observeValues { [weak self] imageName in
        self?.checkmarkImageView.image = Library.image(named: imageName)
      }
    
    self.viewModel.outputs.titleText.observeForUI().observeValues { [weak self] titleText in
      self?.titleLabel.text = titleText ?? ""
    }
    
    self.viewModel.outputs.subtitleText.observeForUI().observeValues { [weak self] subtitleText in
      self?.configureSubtitleLabel(text: subtitleText)
    }
  }

  func configureWith(value: PledgePaymentPlanCellData) {
    self.viewModel.inputs.configureWith(data: value)
  }
  
  func configureSubtitleLabel(text: String?) {
    guard let text = text, !text.isEmpty else {
      self.rigthColumnStackView.removeArrangedSubview(self.subtitleLabel)
      self.subtitleLabel.removeFromSuperview()
      return
    }
    
    self.subtitleLabel.text = text
    if !self.rigthColumnStackView.arrangedSubviews.contains(self.subtitleLabel) {
      self.rigthColumnStackView.insertArrangedSubview(self.subtitleLabel, at: 1)
    }
  }
}

// MARK: - Styles helper

private func applyRootStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .horizontal
  stackView.layoutMargins = .init(all: Styles.grid(2))
  stackView.isLayoutMarginsRelativeArrangement = true
  stackView.insetsLayoutMarginsFromSafeArea = false
  stackView.spacing = Styles.grid(2)
}

private func applyColumnStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .vertical
  stackView.spacing = Styles.grid(1)
}

private func applyTitleLabelStyle(_ label: UILabel) {
  label.accessibilityTraits  = UIAccessibilityTraits.header
  label.adjustsFontForContentSizeCategory  = true
  label.numberOfLines  = 0
  label.font = UIFont.ksr_subhead().bolded
}

private func applySubtitleLabelStyle(_ label: UILabel) {
  label.accessibilityTraits  = UIAccessibilityTraits.header
  label.adjustsFontForContentSizeCategory  = true
  label.numberOfLines  = 0
  label.font = UIFont.ksr_caption1()
  label.textColor = .ksr_support_400
}

private func applyCheckmarkImageViewStyle(_ imageView: UIImageView) {
  imageView.contentMode = .top
}

// MARK: - Helper functions

private func addArrangedSubviews(_ subviews: [UIView], to stackView: UIStackView) {
  subviews.forEach(stackView.addArrangedSubview)
}
