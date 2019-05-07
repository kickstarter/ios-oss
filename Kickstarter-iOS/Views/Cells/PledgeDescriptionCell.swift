import Library
import Prelude
import UIKit

private enum Layout {
  enum ImageView {
    static let width: CGFloat = 90
    static let height: CGFloat = 120
  }

  enum SpacerView {
    static let height: CGFloat = 10
  }
}

final class PledgeDescriptionCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var containerImageView: UIView = {
    return UIView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false }()
  private lazy var pledgeImageView: UIImageView = {
    return UIImageView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false }()
  private lazy var descriptionStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var estimatedDeliveryLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var dateLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var descriptionLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var learnMoreLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var spacerView: UIView = {
    return UIView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.containerImageView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.pledgeImageView, self.containerImageView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.configureStackView()

    NSLayoutConstraint.activate([
      self.containerImageView.widthAnchor.constraint(equalToConstant: Layout.ImageView.width),
      self.containerImageView.heightAnchor.constraint(equalToConstant: Layout.ImageView.height),
      self.pledgeImageView.centerXAnchor.constraint(equalTo: self.containerImageView.centerXAnchor)
    ])
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> checkoutBackgroundStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.pledgeImageView
      |> \.backgroundColor .~ UIColor.orange

    _ = self.descriptionStackView
      |> descriptionStackViewStyle

    _ = self.estimatedDeliveryLabel
      |> checkoutBackgroundStyle
    _ = self.estimatedDeliveryLabel
      |> estimatedDeliveryLabelStyle

    _ = self.dateLabel
      |> checkoutBackgroundStyle
    _ = self.dateLabel
      |> dateLabelStyle

    _ = self.descriptionLabel
      |> checkoutBackgroundStyle
    _ = self.descriptionLabel
      |> descriptionLabelStyle

    _ = self.learnMoreLabel
      |> checkoutBackgroundStyle
    _ = self.learnMoreLabel
      |> learnMoreLabelStyle
  }

  // MARK: - Configuration

  func configureWith(value: String) {
    _ = self.dateLabel
      |> \.text .~ value
  }

  private func configureStackView() {
    NSLayoutConstraint.activate([
      self.spacerView.heightAnchor.constraint(equalToConstant: Layout.SpacerView.height)
    ])

   _ = ([self.spacerView,
      self.estimatedDeliveryLabel,
      self.dateLabel,
      self.descriptionLabel,
      self.learnMoreLabel], self.descriptionStackView)
    |> ksr_addArrangedSubviewsToStackView()

    if #available(iOS 11.0, *) {
      self.descriptionStackView.setCustomSpacing(10.0, after: self.dateLabel)
    } else {
      let view: UIView = {
        return UIView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false
      }()
      view.heightAnchor.constraint(equalToConstant: Layout.SpacerView.height).isActive = true
      self.descriptionStackView.insertArrangedSubview(view, at: 3)
    }

    _ = ([self.descriptionStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }
}

private let rootStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.alignment .~ UIStackView.Alignment.top
    |> \.axis .~ NSLayoutConstraint.Axis.horizontal
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(5), leftRight: Styles.grid(4))
    |> \.spacing .~ Styles.grid(3)
}

private let descriptionStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.distribution .~ UIStackView.Distribution.fill
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
    |> \.numberOfLines .~ 0
}

private let descriptionLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.text  %~ { _ in Strings.Kickstarter_is_not_a_store_Its_a_way_to_bring_creative_projects_to_life() }
    |> \.textColor .~ UIColor.ksr_text_dark_grey_500
    |> \.font .~ UIFont.ksr_caption1()
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.numberOfLines .~ 0
}

private let learnMoreLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.text  %~ { _ in "\(Strings.Learn_more_about_accountability())." }
    |> \.textColor .~ UIColor.ksr_green_500
    |> \.font .~ UIFont.ksr_caption1()
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.numberOfLines .~ 0
}
