import Library
import Prelude
import UIKit

final class PledgeDescriptionCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var containerImageView: UIView = { UIView.init() }()
  private lazy var pledgeImage: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var descriptionStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var dateStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var estimatedDeliveryLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var dateLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var detailsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var descriptionLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var learnMoreLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var spacingView: UIView = { UIView(frame: .zero) }()

  func configureWith(value: String) {
    self.estimatedDeliveryLabel.text = value
  }

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.contentView.addSubview(self.rootStackView)
    NSLayoutConstraint.activate(
      [
        self.rootStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
        self.rootStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
        self.rootStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
        self.rootStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
      ]
    )
    self.containerImageView.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
    self.rootStackView.addArrangedSubview(self.containerImageView)

    self.pledgeImage.widthAnchor.constraint(equalToConstant: 90.0).isActive = true
    self.pledgeImage.heightAnchor.constraint(equalToConstant: 130.0).isActive = true
    self.containerImageView.addSubview(self.pledgeImage)
    self.pledgeImage.centerXAnchor.constraint(equalTo: self.containerImageView.centerXAnchor).isActive = true

    self.rootStackView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    self.descriptionStackView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    self.rootStackView.addArrangedSubview(self.descriptionStackView)
    self.detailsStackView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    self.dateStackView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

    self.spacingView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true

    self.dateStackView.addArrangedSubview(self.estimatedDeliveryLabel)
    self.dateStackView.addArrangedSubview(self.dateLabel)
    self.detailsStackView.addArrangedSubview(self.descriptionLabel)
    self.detailsStackView.addArrangedSubview(self.learnMoreLabel)
    self.descriptionStackView.addArrangedSubview(self.spacingView)
    self.descriptionStackView.addArrangedSubview(self.dateStackView)
    self.descriptionStackView.addArrangedSubview(self.detailsStackView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.selectionStyle .~ .none

    _ = self.contentView
      |> \.backgroundColor .~ UIColor(white: 240.0/255.0, alpha: 1.0)

    _ = self.rootStackView
      |> \.alignment .~ .top
      |> \.axis .~ .horizontal
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.layoutMargins .~ .init(topBottom: Styles.grid(6), leftRight: Styles.grid(2))
      |> \.spacing .~ Styles.grid(2)

    _ = self.containerImageView
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.backgroundColor .~ UIColor.blue

    _ = self.spacingView
      |> \.translatesAutoresizingMaskIntoConstraints .~ false

    _ = self.pledgeImage
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.backgroundColor .~ UIColor.orange

    _ = self.descriptionStackView
      |> \.axis .~ .vertical
      |> \.distribution .~ .fill
      |> \.spacing .~ Styles.grid(2)

    _ = self.dateStackView
      |> \.axis .~ .vertical
      |> \.distribution .~ .fill

    _ = self.detailsStackView
      |> \.axis .~ .vertical
      |> \.distribution .~ .fill

    _ = self.estimatedDeliveryLabel
      |> \.text  %~ { _ in Strings.Estimated_delivery_of() }
      |> \.textColor .~ .ksr_text_dark_grey_500
      |> \.font .~ .ksr_headline()
      |> \.adjustsFontForContentSizeCategory .~ true
      |> \.numberOfLines .~ 0

    _ = self.dateLabel
      |> \.text  %~ { _ in "August 2019" }
      |> \.textColor .~ .ksr_soft_black
      |> \.font .~ .ksr_headline()
      |> \.adjustsFontForContentSizeCategory .~ true

    _ = self.descriptionLabel
      |> \.text  %~ { _ in "Kickstarter is not a store. It's a way to bring creative projects to life." }
      |> \.textColor .~ .ksr_text_dark_grey_500
      |> \.font .~ .ksr_subhead(size: 10)
      |> \.adjustsFontForContentSizeCategory .~ true
      |> \.numberOfLines .~ 0

    _ = self.learnMoreLabel
      |> \.text  %~ { _ in Strings.Learn_more_about_accountability() }
      |> \.textColor .~ .ksr_green_500
      |> \.font .~ .ksr_subhead(size: 10)
      |> \.adjustsFontForContentSizeCategory .~ true
      |> \.numberOfLines .~ 0
  }
}
