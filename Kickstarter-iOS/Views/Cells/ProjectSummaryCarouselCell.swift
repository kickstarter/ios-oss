import Foundation
import KsApi
import Library
import Prelude
import UIKit

extension ProjectSummaryCarouselCell {
  public enum Layout {
    public static func maxInnerWidth(withMaxOuterWidth width: CGFloat) -> CGFloat {
      return width - (Margin.width * 2)
    }

    public static func maxOuterWidth(
      traitCollection: UITraitCollection
    ) -> CGFloat {
      let percentage: CGFloat
      if traitCollection.isRegularRegular {
        percentage = 35
      } else if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
        percentage = 85
      } else {
        percentage = 65
      }

      return CGFloat(Int(UIScreen.main.bounds.width * percentage / 100))
    }

    public enum Margin {
      public static let width: CGFloat = Styles.grid(3)
    }

    public enum Spacing {
      public static let width: CGFloat = Styles.gridHalf(5)
    }
  }

  public enum Style {
    public enum Body {
      public static let font = { UIFont.ksr_body() }
    }

    public enum Title {
      public static let font = { UIFont.ksr_title3().bolded }
    }
  }
}

final class ProjectSummaryCarouselCell: UICollectionViewCell {
  // MARK: - Properties

  private lazy var bodyLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var gradientBackgroundView: GradientView = { GradientView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  private let viewModel: ProjectSummaryCarouselCellViewModelType = ProjectSummaryCarouselCellViewModel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.setupConstraints()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.titleLabel.rac.text = self.viewModel.outputs.title
    self.bodyLabel.rac.text = self.viewModel.outputs.body
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.backgroundColor .~ .white

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.titleLabel
      |> titleLabelStyle

    _ = self.bodyLabel
      |> bodyLabelStyle

    _ = self.gradientBackgroundView
      |> gradientBackgroundViewStyle
  }

  // MARK: - Configuration

  private func configureViews() {
    _ = (self.gradientBackgroundView, self.contentView)
      |> ksr_addSubviewToParent()

    _ = (self.rootStackView, self.gradientBackgroundView)
      |> ksr_addSubviewToParent()

    _ = ([self.titleLabel, self.bodyLabel, UIView()], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.bodyLabel, self.rootStackView)
      |> ksr_setCustomSpacing(0)
  }

  private func setupConstraints() {
    _ = (self.gradientBackgroundView, self.contentView)
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rootStackView, self.gradientBackgroundView)
      |> ksr_constrainViewToEdgesInParent()
  }
}

extension ProjectSummaryCarouselCell: ValueCell {
  // MARK: - Accessors

  func configureWith(value: ProjectSummaryEnvelope.ProjectSummaryItem) {
    self.viewModel.inputs.configure(with: value)
  }
}

// MARK: - Styles

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.spacing .~ ProjectSummaryCarouselCell.Layout.Spacing.width
    |> \.layoutMargins .~ .init(all: ProjectSummaryCarouselCell.Layout.Margin.width)
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

private let bodyLabelStyle: LabelStyle = { label in
  label
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .ksr_trust_700
    |> \.font .~ ProjectSummaryCarouselCell.Style.Body.font()
}

private let titleLabelStyle: LabelStyle = { label in
  label
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .ksr_trust_700
    |> \.font .~ ProjectSummaryCarouselCell.Style.Title.font()
}

private let gradientBackgroundViewStyle: ((GradientView) -> GradientView) = { view in
  _ = view
    |> roundedStyle(cornerRadius: Styles.grid(3))
    |> \.layer.borderColor .~ UIColor.white.cgColor
    |> \.layer.borderWidth .~ 2
    |> \.startPoint .~ CGPoint.zero
    |> \.endPoint .~ CGPoint(x: 0, y: 1)

  let gradient: [(UIColor?, Float)] = [
    (UIColor.hex(0xDBE7FF), 0.0),
    (UIColor.hex(0xE6FAF1), 1)
  ]

  view.setGradient(gradient)

  return view
}
