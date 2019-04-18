import KsApi
import Library
import Prelude
import UIKit

final class PledgeDescriptionCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var containerImageView: UIView = { UIView.init() }()
  private lazy var pledgeImage: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var descriptionStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var estimatedDeliveryLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var dateLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var descriptionLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var learnMoreLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var spacerView: UIView = { UIView(frame: .zero) }()

  func configureWith(value: String) {
    _ = self.dateLabel
      |> \.text .~ value
  }

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.containerImageView.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
    self.rootStackView.addArrangedSubview(self.containerImageView)

    self.pledgeImage.widthAnchor.constraint(equalToConstant: 90.0).isActive = true
    self.pledgeImage.heightAnchor.constraint(equalToConstant: 130.0).isActive = true
    self.containerImageView.addSubview(self.pledgeImage)
    self.pledgeImage.centerXAnchor.constraint(equalTo: self.containerImageView.centerXAnchor).isActive = true

    self.spacerView.heightAnchor.constraint(equalToConstant: 10.0).isActive = true
    self.descriptionStackView.addArrangedSubview(self.spacerView)

    self.descriptionStackView.addArrangedSubview(self.estimatedDeliveryLabel)
    self.descriptionStackView.addArrangedSubview(self.dateLabel)
    self.descriptionStackView.addArrangedSubview(self.descriptionLabel)
    self.descriptionStackView.addArrangedSubview(self.learnMoreLabel)

    if #available(iOS 11.0, *) {
      self.descriptionStackView.setCustomSpacing(10.0, after: self.dateLabel)
    } else {
      print("nada") // FIX THIS
    }

    self.rootStackView.addArrangedSubview(self.descriptionStackView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.backgroundColor .~ UIColor.hex(0xf0f0f0)

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.containerImageView
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.backgroundColor .~ UIColor.blue

    _ = self.spacerView
      |> \.translatesAutoresizingMaskIntoConstraints .~ false

    _ = self.pledgeImage
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.backgroundColor .~ UIColor.orange

    _ = self.descriptionStackView
      |> descriptionStackViewStyle

    _ = self.estimatedDeliveryLabel
      |> estimatedDeliveryLabelStyle

    _ = self.dateLabel
      |> dateLabelStyle

    _ = self.descriptionLabel
      |> descriptionLabelStyle

    _ = self.learnMoreLabel
      |> learnMoreLabelStyle
  }
}

private let rootStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.alignment .~ .top
    |> \.axis .~ .horizontal
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(5), leftRight: Styles.grid(2))
    |> \.spacing .~ Styles.grid(2)
}

private let descriptionStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.axis .~ .vertical
    |> \.distribution .~ .fill
}

private let estimatedDeliveryLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.text %~ { _ in Strings.Estimated_delivery_of() }
    |> \.textColor .~ UIColor.ksr_text_dark_grey_500
    |> \.font .~ UIFont.ksr_headline()
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.numberOfLines .~ 0
}

private let dateLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.textColor .~ UIColor.ksr_soft_black
    |> \.font .~ UIFont.ksr_headline()
    |> \.adjustsFontForContentSizeCategory .~ true
}

private let descriptionLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.text  %~ { _ in "Kickstarter is not a store. It's a way to bring creative projects to life." }
    |> \.textColor .~ UIColor.ksr_text_dark_grey_500
    |> \.font .~ UIFont.ksr_subhead(size: 12)
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.numberOfLines .~ 0
}

private let learnMoreLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.text  %~ { _ in Strings.Learn_more_about_accountability() }
    |> \.textColor .~ UIColor.ksr_green_500
    |> \.font .~ UIFont.ksr_subhead(size: 12)
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.numberOfLines .~ 0
}
