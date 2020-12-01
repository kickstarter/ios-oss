import Library
import Prelude
import ReactiveSwift
import UIKit

final class PillCell: UICollectionViewCell, ValueCell {
  // MARK: - Properties

  private(set) lazy var label = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let viewModel: PillCellViewModelType = PillCellViewModel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.bindStyles()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.contentView
      |> contentViewStyle

    _ = self.label
      |> labelStyle
  }

  // MARK: - View Model

  override func bindViewModel() {
    super.bindViewModel()

    self.label.rac.text = self.viewModel.outputs.text
  }

  // MARK: - Configuration

  func configureWith(value: String) {
    self.viewModel.inputs.configure(with: value)
  }

  // MARK: - Functions

  private func configureSubviews() {
    _ = (self.label, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }
}

// MARK: - Styles

private let contentViewStyle: ViewStyle = { view in
  view
    |> checkoutRoundedCornersStyle
    |> \.layoutMargins .~ UIEdgeInsets(topBottom: Styles.gridHalf(2), leftRight: Styles.gridHalf(3))
    |> \.backgroundColor .~ UIColor.ksr_create_700.withAlphaComponent(0.06)
}

private let labelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_footnote().bolded
    |> \.numberOfLines .~ 0
    |> \.textColor .~ UIColor.ksr_create_700
}
