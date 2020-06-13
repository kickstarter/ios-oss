import KsApi
import Library
import Prelude
import UIKit

final class PledgePaymentMethodCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var cardImageAndLabelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var cardImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var checkmarkImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var expirationDateLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var labelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var lastFourLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var leftColumnStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var rightColumnStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var selectionView: UIView = { UIView(frame: .zero) |> \.backgroundColor .~ .ksr_grey_200 }()
  private lazy var unavailableCardTypeLabel: UILabel = { UILabel(frame: .zero) }()

  private let viewModel: PledgePaymentMethodCellViewModelType = PledgePaymentMethodCellViewModel()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureSubviews()
    self.setupConstraints()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  private func configureSubviews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()

    _ = ([self.leftColumnStackView, self.rightColumnStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.checkmarkImageView, UIView()], self.leftColumnStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.lastFourLabel, self.expirationDateLabel], self.labelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    let cardImageAndLabels = [self.cardImageView, self.labelsStackView, UIView()]

    _ = (cardImageAndLabels, self.cardImageAndLabelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.cardImageAndLabelsStackView, self.unavailableCardTypeLabel], self.rightColumnStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_constrainViewToEdgesInParent()

    NSLayoutConstraint.activate([
      self.cardImageView.widthAnchor.constraint(equalToConstant: Styles.grid(10)),
      self.checkmarkImageView.widthAnchor.constraint(equalToConstant: Styles.grid(4)),
      self.checkmarkImageView.heightAnchor.constraint(equalTo: self.cardImageView.heightAnchor)
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.selectedBackgroundView .~ self.selectionView

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.leftColumnStackView
      |> columnStackViewStyle
      |> \.spacing .~ 0

    _ = self.rightColumnStackView
      |> columnStackViewStyle

    _ = self.labelsStackView
      |> labelsStackViewStyle

    _ = self.cardImageAndLabelsStackView
      |> adaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )
      |> cardImageAndLabelsStackViewStyle

    _ = self.unavailableCardTypeLabel
      |> unavailableCardTypeLabelStyle

    _ = self.cardImageView
      |> cardImageViewStyle

    _ = self.checkmarkImageView
      |> checkmarkImageViewStyle

    _ = self.lastFourLabel
      |> lastFourLabelStyle

    _ = self.expirationDateLabel
      |> expirationDateLabelStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.lastFourLabel.rac.accessibilityLabel = self.viewModel.outputs.cardNumberAccessibilityLabel
    self.lastFourLabel.rac.textColor = self.viewModel.outputs.lastFourLabelTextColor
    self.expirationDateLabel.rac.text = self.viewModel.outputs.expirationDateText
    self.lastFourLabel.rac.text = self.viewModel.outputs.cardNumberTextShortStyle
    self.unavailableCardTypeLabel.rac.hidden = self.viewModel.outputs.unavailableCardLabelHidden
    self.unavailableCardTypeLabel.rac.text = self.viewModel.outputs.unavailableCardText

    self.viewModel.outputs.cardImageAlpha
      .observeForUI()
      .observeValues { [weak self] opacity in
        self?.cardImageView.alpha = opacity
      }

    self.viewModel.outputs.checkmarkImageHidden
      .observeForUI()
      .observeValues { [weak self] hidden in
        self?.checkmarkImageView.alpha = hidden ? 0 : 1
      }

    self.viewModel.outputs.cardImageName
      .observeForUI()
      .observeValues { [weak self] imageName in
        _ = self?.cardImageView
          ?|> \.image .~ Library.image(named: imageName)
      }

    self.viewModel.outputs.checkmarkImageName
      .observeForUI()
      .observeValues { [weak self] imageName in
        _ = self?.checkmarkImageView
          ?|> \.image .~ Library.image(named: imageName)
      }

    self.viewModel.outputs.selectionStyle
      .observeForUI()
      .observeValues { [weak self] style in
        self?.selectionStyle = style
      }
  }

  func configureWith(value: PledgePaymentMethodCellData) {
    self.viewModel.inputs.configureWith(value: value)
  }

  // MARK: - Accessors

  func setSelectedCard(_ card: GraphUserCreditCard.CreditCard) {
    self.viewModel.inputs.setSelectedCard(card)
  }
}

// MARK: - Styles

private let cardImageAndLabelsStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.spacing .~ Styles.grid(2)
}

private let checkmarkImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.contentMode .~ .center
}

private let columnStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.spacing .~ Styles.grid(2)
}

private let expirationDateLabelStyle: LabelStyle = { label in
  label
    |> checkoutTitleLabelStyle
    |> \.font .~ UIFont.ksr_caption2()
    |> \.textColor .~ .ksr_dark_grey_500
}

private let labelsStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.spacing .~ Styles.grid(1)
}

private let lastFourLabelStyle: LabelStyle = { label in
  label
    |> checkoutTitleLabelStyle
    |> \.font .~ UIFont.ksr_subhead().bolded
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
    |> \.layoutMargins .~ .init(all: Styles.grid(2))
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.spacing .~ Styles.grid(2)
}

private let unavailableCardTypeLabelStyle: LabelStyle = { label in
  label
    |> \.numberOfLines .~ 0
    |> \.font .~ UIFont.ksr_caption1()
    |> \.textColor .~ UIColor.ksr_red_400
}
