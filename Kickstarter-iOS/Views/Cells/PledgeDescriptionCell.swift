import KsApi
import Library
import Prelude
import Prelude_UIKit
import ReactiveSwift
import UIKit

internal protocol PledgeDescriptionCellDelegate: class {
  func pledgeDescriptionCellDidPresentTrustAndSafety(_ cell: PledgeDescriptionCell)
}

internal final class PledgeDescriptionCell: UITableViewCell, ValueCell {
  fileprivate let viewModel = PledgeDescriptionCellViewModel()
  internal weak var delegate: PledgeDescriptionCellDelegate?

  // MARK: - Properties

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var containerImageView: UIView = { UIView(frame: .zero) }()
  private lazy var pledgeImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var descriptionStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var estimatedDeliveryLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var dateLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var descriptionLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var learnMoreLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var spacerView: UIView = { UIView(frame: .zero) }()

  internal func configureWith(value: String) {
    self.viewModel.inputs.configureWith(estimatedDeliveryDate: value)
  }

  // MARK: - Lifecycle

  internal override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.rootStackView.addArrangedSubview(self.containerImageView)

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(learnMoreTapped))
    self.learnMoreLabel.addGestureRecognizer(tapRecognizer)

    _ = (self.pledgeImageView, self.containerImageView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.arrangeStackView()
    self.bindViewModel()

    NSLayoutConstraint.activate ([
      self.containerImageView.widthAnchor.constraint(equalToConstant: 100.0),
      self.pledgeImageView.widthAnchor.constraint(equalToConstant: 90.0),
      self.pledgeImageView.heightAnchor.constraint(equalToConstant: 130.0),
      self.pledgeImageView.centerXAnchor.constraint(equalTo: self.containerImageView.centerXAnchor)
    ])
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  internal override func bindStyles() {
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

    _ = self.pledgeImageView
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

  internal override func bindViewModel() {
    super.bindViewModel()

    self.dateLabel.rac.text = self.viewModel.outputs.estimatedDeliveryText

    self.viewModel.outputs.presentTrustAndSafety
      .observeForUI()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        self?.delegate?.pledgeDescriptionCellDidPresentTrustAndSafety(_self)
    }
  }

  internal func arrangeStackView() {
    self.spacerView.heightAnchor.constraint(equalToConstant: 10.0).isActive = true

    [
      self.spacerView,
      self.estimatedDeliveryLabel,
      self.dateLabel,
      self.descriptionLabel,
      self.learnMoreLabel
    ].forEach(self.descriptionStackView.addArrangedSubview)

    if #available(iOS 11.0, *) {
      self.descriptionStackView.setCustomSpacing(10.0, after: self.dateLabel)
    } else {
      let view = UIView(frame: .zero)
      view.translatesAutoresizingMaskIntoConstraints = true
      view.heightAnchor.constraint(equalToConstant: 10.0).isActive = true
      self.descriptionStackView.insertArrangedSubview(view, at: 3)
    }

    self.rootStackView.addArrangedSubview(self.descriptionStackView)
  }

  @objc func learnMoreTapped(sender: UITapGestureRecognizer) {
    self.viewModel.inputs.tapped()
  }
}

private let rootStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.alignment .~ UIStackView.Alignment.top
    |> \.axis .~ NSLayoutConstraint.Axis.horizontal
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(5), leftRight: Styles.grid(2))
    |> \.spacing .~ Styles.grid(2)
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
    |> \.isUserInteractionEnabled .~ true
}
