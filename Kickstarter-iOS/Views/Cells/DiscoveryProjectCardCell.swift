import Foundation
import Library
import UIKit
import Prelude

final class DiscoveryProjectCardCell: UITableViewCell, ValueCell {
  private lazy var backersLabel = { UILabel(frame: .zero) }()
  private lazy var backersCountLabel = { UILabel(frame: .zero) }()
  private lazy var backersCountIconImageView = { UIImageView(frame: .zero) }()
  private lazy var backersCountStackView = { UIImageView(frame: .zero) }()
  private lazy var cardContainerView = { UIView(frame: .zero) }()
  private lazy var projectDetailsStackView = { UIStackView(frame: .zero) }()
  private lazy var percentFundedLabel = { UILabel(frame: .zero) }()
  private lazy var projectImageView = { UIImageView(frame: .zero) }()
  private lazy var projectInfoStackView = { UIStackView(frame: .zero) }()
  private lazy var projectNameLabel = { UILabel(frame: .zero) }()
  private lazy var projectBlurbLabel = { UILabel(frame: .zero) }()
  private lazy var tagsCollectionView = { UICollectionView(frame: .zero) }()

  private let viewModel: DiscoveryPostcardViewModelType = DiscoveryPostcardViewModel()

  func configureWith(value: DiscoveryProjectCellRowValue) {
    //
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.contentView
      |> \.layoutMargins .~ .init(top: Styles.grid(2),
                                  left: Styles.grid(2),
                                  bottom: 0,
                                  right: Styles.grid(2))
      |> \.backgroundColor .~ .ksr_grey_200

    _ = self.projectImageView
      |> projectImageViewStyle

    _ = self.projectNameLabel
      |> projectNameLabelStyle

    _ = self.projectBlurbLabel
      |> projectBlurbLabelStyle

    _ = self.percentFundedLabel
      |> percentFundedLabelStyle

    _ = self.backersCountLabel
      |> backersCountLabelStyle

    _ = self.backersLabel
      |> backersLabelStyle

    _ = self.backersCountIconImageView
      |> backersCountIconImageViewStyle

    _ = self.projectInfoStackView
      |> projectInfoStackViewStyle
      |> checkoutAdaptableStackViewStyle(
         self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
       ) // TODO: rename this to a generic stack view style
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.projectImageView.af.cancelImageRequest()
        self?.projectImageView.image = nil
      })
      .skipNil()
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

    _ = ([self.projectNameLabel,
          self.projectBlurbLabel,
          self.projectInfoStackView,
          self.tagsCollectionView], self.projectDetailsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.percentFundedLabel, self.backersCountStackView], self.projectInfoStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    let aspectRatio = CGFloat(9/16)

    NSLayoutConstraint.activate([
      self.projectImageView.topAnchor.constraint(equalTo: self.cardContainerView.topAnchor),
      self.projectImageView.leftAnchor.constraint(equalTo: self.cardContainerView.leftAnchor),
      self.projectImageView.rightAnchor.constraint(equalTo: self.cardContainerView.rightAnchor),
      self.projectDetailsStackView.topAnchor.constraint(equalTo: self.projectImageView.bottomAnchor),
      self.projectDetailsStackView.leftAnchor.constraint(equalTo: self.cardContainerView.leftAnchor),
      self.projectDetailsStackView.rightAnchor.constraint(equalTo: self.cardContainerView.rightAnchor),
      self.projectDetailsStackView.bottomAnchor.constraint(equalTo: self.cardContainerView.bottomAnchor),
      self.projectImageView.heightAnchor.constraint(equalTo: self.projectImageView.widthAnchor,
                                                    multiplier: aspectRatio)
    ])
  }
}

private let cardContainerViewStyle: ViewStyle = { view in
  view
    |> roundedStyle(cornerRadius: Styles.grid(2))
    |> \.backgroundColor .~ .white
}

private let projectImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.contentMode .~ .scaleAspectFill
    |> ignoresInvertColorsImageViewStyle
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
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
    |> \.tintColor .~ .ksr_grey_400
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
    |> \.axis .~ .horizontal
    |> \.alignment .~ .leading
    |> \.distribution .~ .fill
    |> \.spacing .~ Styles.grid(1)
}

private let projectDetailsStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> \.spacing .~ Styles.grid(2)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
    |> \.layoutMargins .~ .init(all: Styles.grid(2))
    |> \.isLayoutMarginsRelativeArrangement .~ true
}
