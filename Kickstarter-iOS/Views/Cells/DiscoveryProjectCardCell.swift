import Foundation
import Library
import Prelude
import UIKit

final class DiscoveryProjectCardCell: UITableViewCell, ValueCell {
  private lazy var backersLabel = { UILabel(frame: .zero) }()
  private lazy var backersCountLabel = { UILabel(frame: .zero) }()
  private lazy var backersCountIconImageView = { UIImageView(frame: .zero) }()
  private lazy var backersCountStackView = { UIStackView(frame: .zero) }()
  private lazy var cardContainerView = { UIView(frame: .zero) }()
  private lazy var goalMetIconImageView = { UIImageView(frame: .zero) }()
  private lazy var goalPercentFundedStackView = { UIStackView(frame: .zero) }()
  private lazy var projectDetailsStackView = { UIStackView(frame: .zero) }()
  private lazy var percentFundedLabel = { UILabel(frame: .zero) }()
  private lazy var projectImageView = { UIImageView(frame: .zero) }()
  // Stack view container for "percent funded" and "backer count" info
  private lazy var projectInfoStackView = { UIStackView(frame: .zero) }()
  private lazy var projectNameLabel = { UILabel(frame: .zero) }()
  private lazy var projectBlurbLabel = { UILabel(frame: .zero) }()
//  private lazy var tagsCollectionView = { UICollectionView(frame: .zero) }()

  private let viewModel: DiscoveryProjectCardViewModelType = DiscoveryProjectCardViewModel()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureSubviews()
    self.setupConstraints()

    self.bindStyles()
    self.bindViewModel()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureWith(value: DiscoveryProjectCellRowValue) {
    self.viewModel.inputs.configure(with: value)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.contentView
      |> contentViewStyle

    _ = self.cardContainerView
      |> cardContainerViewStyle

    _ = self.projectImageView
      |> projectImageViewStyle

    _ = self.projectDetailsStackView
      |> projectDetailsStackViewStyle

    _ = self.projectNameLabel
      |> projectNameLabelStyle

    _ = self.projectBlurbLabel
      |> projectBlurbLabelStyle

    _ = self.percentFundedLabel
      |> percentFundedLabelStyle

    _ = self.backersCountLabel
      |> backersCountLabelStyle

    _ = self.backersCountStackView
      |> infoStackViewStyle

    _ = self.goalPercentFundedStackView
      |> infoStackViewStyle
      |> UIView.lens.contentHuggingPriority(for: .horizontal) .~ .required

    _ = self.goalMetIconImageView
      |> goalMetIconImageViewStyle

    _ = self.backersLabel
      |> backersLabelStyle

    _ = self.backersCountIconImageView
      |> backersCountIconImageViewStyle

    _ = self.projectInfoStackView
      |> checkoutAdaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      ) // TODO: rename this to a generic stack view style
      |> projectInfoStackViewStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.projectNameLabel.rac.text = self.viewModel.outputs.projectNameLabelText
    self.projectBlurbLabel.rac.text = self.viewModel.outputs.projectBlurbLabelText
    self.percentFundedLabel.rac.text = self.viewModel.outputs.percentFundedLabelText
    self.backersLabel.rac.text = self.viewModel.outputs.backerLabelText
    self.goalMetIconImageView.rac.hidden = self.viewModel.outputs.goalMetIconHidden

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.projectImageView.af.cancelImageRequest()
        self?.projectImageView.image = nil
      })
      .observeValues { [weak self] url in
        self?.projectImageView.ksr_setImageWithURL(url)
      }
  }

  private func configureSubviews() {
    _ = (self.cardContainerView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (self.projectImageView, self.cardContainerView)
      |> ksr_addSubviewToParent()

    _ = (self.projectDetailsStackView, self.cardContainerView)
      |> ksr_addSubviewToParent()

    _ = ([
      self.projectNameLabel,
      self.projectBlurbLabel,
      self.projectInfoStackView
//      self.tagsCollectionView
    ], self.projectDetailsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.goalMetIconImageView, self.percentFundedLabel], self.goalPercentFundedStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.backersCountIconImageView, self.backersLabel], self.backersCountStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.goalPercentFundedStackView, self.backersCountStackView], self.projectInfoStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    _ = [self.projectImageView, self.projectDetailsStackView]
      ||> \.translatesAutoresizingMaskIntoConstraints .~ false

    let aspectRatio = CGFloat(9.0 / 16.0)

    NSLayoutConstraint.activate([
      self.projectImageView.topAnchor.constraint(equalTo: self.cardContainerView.topAnchor),
      self.projectImageView.leftAnchor.constraint(equalTo: self.cardContainerView.leftAnchor),
      self.projectImageView.rightAnchor.constraint(equalTo: self.cardContainerView.rightAnchor),
      self.projectImageView.widthAnchor.constraint(equalTo: self.cardContainerView.widthAnchor),
      self.projectImageView.heightAnchor.constraint(
        equalTo: self.projectImageView.widthAnchor,
        multiplier: aspectRatio
      ),
      self.projectDetailsStackView.topAnchor.constraint(equalTo: self.projectImageView.bottomAnchor),
      self.projectDetailsStackView.leftAnchor.constraint(equalTo: self.cardContainerView.leftAnchor),
      self.projectDetailsStackView.rightAnchor.constraint(equalTo: self.cardContainerView.rightAnchor),
      self.projectDetailsStackView.bottomAnchor.constraint(equalTo: self.cardContainerView.bottomAnchor)
    ])
  }
}

// MARK: - Styles

private let contentViewStyle: ViewStyle = { view in
  view
  |> \.layoutMargins .~ .init(
    top: Styles.grid(2),
    left: Styles.grid(2),
    bottom: 0,
    right: Styles.grid(2)
  )
  |> \.backgroundColor .~ .ksr_grey_200
}

private let cardContainerViewStyle: ViewStyle = { view in
  view
    |> roundedStyle(cornerRadius: Styles.grid(2))
    |> \.backgroundColor .~ .white
}

private let goalMetIconImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.image .~ image(named: "")
    |> \.tintColor .~ .ksr_green_500
}

private let projectImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.clipsToBounds .~ true
    |> \.backgroundColor .~ .ksr_grey_400
    |> \.contentMode .~ .scaleAspectFit
    |> ignoresInvertColorsImageViewStyle
}

private let projectNameLabelStyle: LabelStyle = { label in
  label
    |> \.numberOfLines .~ 2
    |> \.lineBreakMode .~ .byTruncatingTail
    |> \.font .~ UIFont.ksr_headline().bolded
    |> \.textColor .~ .ksr_soft_black
}

private let projectBlurbLabelStyle: LabelStyle = { label in
  label
    |> \.numberOfLines .~ 2
    |> \.lineBreakMode .~ .byTruncatingTail
    |> \.font .~ UIFont.ksr_subhead()
    |> \.textColor .~ .ksr_text_dark_grey_500
}

private let infoStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
    |> \.spacing .~ Styles.grid(1)
    |> \.alignment .~ .center
    |> \.distribution .~ .equalSpacing
}

private let percentFundedLabelStyle: LabelStyle = { label in
  label
    |> \.numberOfLines .~ 1
    |> \.lineBreakMode .~ .byTruncatingTail
    |> \.font .~ UIFont.ksr_subhead().bolded
    |> \.textColor .~ .ksr_green_500
}

private let backersCountIconImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.image .~ image(named: "icon--humans")
    |> \.tintColor .~ .ksr_grey_500
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
}

private let backersCountLabelStyle: LabelStyle = { label in
  label
    |> \.numberOfLines .~ 1
    |> \.lineBreakMode .~ .byTruncatingTail
    |> \.font .~ UIFont.ksr_subhead().bolded
    |> \.textColor .~ .ksr_soft_black
}

private let backersLabelStyle: LabelStyle = { label in
  label
    |> \.numberOfLines .~ 1
    |> \.lineBreakMode .~ .byTruncatingTail
    |> \.font .~ UIFont.ksr_footnote().bolded
    |> \.textColor .~ .ksr_soft_black
}

private let projectInfoStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.spacing .~ Styles.grid(2)
}

private let projectDetailsStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> \.spacing .~ Styles.grid(2)
    |> \.alignment .~ .leading
    |> \.layoutMargins .~ .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))
    |> \.isLayoutMarginsRelativeArrangement .~ true
}
