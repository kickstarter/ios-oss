import Library
import Prelude
import ReactiveSwift
import UIKit

protocol PillCellDelegate: AnyObject {
  func pillCell(_ cell: PillCell,
                didTapAtIndex index: IndexPath,
                action: ((Bool) -> ())
  )
}

final class PillCell: UICollectionViewCell, ValueCell {
  weak var delegate: PillCellDelegate?

  // MARK: - Properties

  private(set) lazy var label = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private var tapGestureRecognizer: UITapGestureRecognizer?

  private let viewModel: PillCellViewModelType = PillCellViewModel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(PillCell.pillCellTapped))

    self.addGestureRecognizer(tapGestureRecognizer!)

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

    _ = self.label
      |> labelStyle
//
//    _ = self.contentView
//      |> \.layoutMargins .~ .init(topBottom: Styles.grid(1) + Styles.gridHalf(1), leftRight: Styles.grid(2))
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

    self.viewModel.outputs.tapGestureRecognizerIsEnabled
    .observeForUI()
      .observeValues { [weak self] isEnabled in
        _ = self?.tapGestureRecognizer
          ?|> \.isEnabled .~ isEnabled
    }

    self.viewModel.outputs.notifyDelegatePillCellTapped
      .observeForUI()
      .observeValues { [weak self] indexPath in
        guard let self = self else { return }

        self.delegate?.pillCell(self,
                                didTapAtIndex: indexPath,
                                action: { shouldSelect in
          self.viewModel.inputs.setIsSelected(selected: shouldSelect)
        })
    }
  }

  // MARK: - Configuration

  func configureWith(value: (String, PillCellStyle, IndexPath?)) {
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

  @objc func pillCellTapped() {
    self.viewModel.inputs.pillCellTapped()
  }
}

// MARK: - Styles

private let labelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_footnote().bolded
    |> \.numberOfLines .~ 0
}
