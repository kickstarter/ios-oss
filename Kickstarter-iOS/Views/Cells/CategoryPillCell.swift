import Library
import Prelude
import ReactiveSwift
import UIKit

protocol CategoryPillCellDelegate: AnyObject {
  func categoryPillCell(_ cell: CategoryPillCell,
                didTapAtIndex index: IndexPath,
                action: ((Bool) -> ())
  )
}

final class CategoryPillCell: UICollectionViewCell, ValueCell {
  lazy var button: UIButton = { UIButton(type: .custom) }()
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

    _ = self.contentView
      |> contentViewStyle
  }

  // MARK: - View Model

  override func bindViewModel() {
    super.bindViewModel()

    self.button.rac.title = self.viewModel.outputs.text
    self.button.rac.selected = self.viewModel.outputs.isSelected

    self.viewModel.outputs.notifyDelegatePillCellTapped
      .observeForUI()
      .observeValues { [weak self] indexPath in
        guard let self = self else { return }

        self.delegate?.categoryPillCell(self,
                                didTapAtIndex: indexPath,
                                action: { shouldSelect in
          self.viewModel.inputs.setIsSelected(selected: shouldSelect)
        })
    }
  }

  // MARK: - Configuration

  func configureWith(value: (String, IndexPath?)) {
    self.viewModel.inputs.configure(with: value)
  }

  // MARK: - Functions

  private func configureSubviews() {
    _ = (self.button, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent(priority: .defaultHigh)

    NSLayoutConstraint.activate([
      self.button.heightAnchor.constraint(equalToConstant: Styles.minTouchSize.height)
    ])
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
    |> baseButtonStyle
    |> roundedStyle(cornerRadius: Styles.minTouchSize.height / 2)
    |> UIButton.lens.titleColor(for: .normal) .~ UIColor.ksr_soft_black
    |> UIButton.lens.titleColor(for: .selected) .~ UIColor.ksr_cobalt_500
    |> UIButton.lens.backgroundColor(for: .normal) .~ UIColor.ksr_grey_400.withAlphaComponent(0.8)
    |> UIButton.lens.backgroundColor(for: .selected) .~ UIColor.ksr_cobalt_500.withAlphaComponent(0.1)
}

private let contentViewStyle: ViewStyle = { view in
  view
}
