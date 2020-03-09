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
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.label
      |> labelStyle
  }

  // MARK: - View Model

  override func bindViewModel() {
    super.bindViewModel()

    self.contentView.rac.backgroundColor = self.viewModel.outputs.backgroundColor
    self.label.rac.text = self.viewModel.outputs.text
    self.label.rac.textColor = self.viewModel.outputs.textColor

    self.viewModel.outputs.layoutMargins
      .observeForUI()
      .observeValues { [weak self] layoutMargins in
        _ = self?.contentView
          ?|> \.layoutMargins .~ layoutMargins
    }

    self.viewModel.outputs.cornerRadius
      .observeForUI()
      .observeValues { [weak self] cornerRadius in
        _ = self?.contentView.layer
          ?|> \.cornerRadius .~ cornerRadius
    }
  }

  // MARK: - Configuration

  func configureWith(value: (String, PillCellStyle)) {
    self.viewModel.inputs.configure(with: value)
  }

  // MARK: - Functions

  private func configureSubviews() {
    _ = (self.label, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  // MARK: - Accessors

  public func setIsSelected(_ isSelected: Bool) {
    self.viewModel.inputs.setIsSelected(selected: isSelected)
  }
}

// MARK: - Styles

private let labelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_footnote().bolded
    |> \.numberOfLines .~ 0
}
