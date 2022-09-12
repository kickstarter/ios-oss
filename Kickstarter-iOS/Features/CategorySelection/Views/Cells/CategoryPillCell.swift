import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

protocol CategoryPillCellDelegate: AnyObject {
  func categoryPillCell(
    _ cell: CategoryPillCell,
    didTapAtIndex index: IndexPath,
    withCategory category: KsApi.Category
  )
}

final class CategoryPillCell: UICollectionViewCell, ValueCell {
  private lazy var button: UIButton = { UIButton(type: .custom) }()
  var buttonWidthConstraint: NSLayoutConstraint?

  weak var delegate: CategoryPillCellDelegate?

  // MARK: - Properties

  private let viewModel: CategoryPillCellViewModelType = CategoryPillCellViewModel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.button.addTarget(self, action: #selector(CategoryPillCell.pillCellTapped), for: .touchUpInside)

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

    _ = self.button
      |> buttonStyle
  }

  // MARK: - View Model

  override func bindViewModel() {
    super.bindViewModel()

    self.button.rac.title = self.viewModel.outputs.buttonTitle
    self.button.rac.selected = self.viewModel.outputs.isSelected

    self.viewModel.outputs.notifyDelegatePillCellTapped
      .observeForUI()
      .observeValues { [weak self] indexPath, category in
        guard let self = self else { return }

        self.delegate?.categoryPillCell(self, didTapAtIndex: indexPath, withCategory: category)
      }
  }

  // MARK: - Configuration

  func configureWith(value: CategoryPillCellValue) {
    self.viewModel.inputs.configure(with: value)
  }

  // MARK: - Functions

  private func configureSubviews() {
    _ = (self.button, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent(priority: .defaultHigh)

    self.buttonWidthConstraint = self.button.widthAnchor.constraint(lessThanOrEqualToConstant: 0)

    NSLayoutConstraint.activate([
      self.buttonWidthConstraint,
      self.button.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
    ].compact())
  }

  // MARK: - Accessors

  public func setIsSelected(_ isSelected: Bool) {
    self.viewModel.inputs.setIsSelected(selected: isSelected)
  }

  @objc func pillCellTapped() {
    self.viewModel.inputs.pillCellTapped()
  }
}

// MARK: - Styles

private let buttonStyle: ButtonStyle = { button in
  button
    |> greyButtonStyle
    |> roundedStyle(cornerRadius: Styles.minTouchSize.height / 2)
    |> UIButton.lens.titleLabel.lineBreakMode .~ .byTruncatingTail
    |> UIButton.lens.titleColor(for: .selected) .~ UIColor.ksr_white
    |> UIButton.lens.backgroundColor(for: .selected) .~ UIColor.ksr_create_700
}
