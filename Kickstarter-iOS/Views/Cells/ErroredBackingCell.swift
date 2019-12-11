import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

private enum Layout {
  enum Button {
    static let height: CGFloat = 48
    static let width: CGFloat = 98
  }
}

final class ErroredBackingCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let manageButton: UIButton = { UIButton(type: .custom) }()
  private let projectNameLabel: UILabel = { UILabel(frame: .zero) }()
  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let viewModel: ErroredBackingCellViewModelType = ErroredBackingCellViewModel()

  // MARK: - Life cycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
    self.configureConstraints()
    self.bindViewModel()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: - Configuration

  func configureWith(value: GraphBacking) {
    self.viewModel.inputs.configure(with: value)
  }

  private func configureViews() {
    _ = ([self.projectNameLabel, self.manageButton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  private func configureConstraints() {
    NSLayoutConstraint.activate([
      self.manageButton.widthAnchor.constraint(equalToConstant: Layout.Button.width),
      self.manageButton.heightAnchor.constraint(equalToConstant: Layout.Button.height)
    ])
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.contentView
      |> contentViewStyle

    _ = self.manageButton
      |> manageButtonStyle

    _ = self.manageButton.titleLabel
      ?|> manageButtonTitleLabelStyle

    _ = self.projectNameLabel
      |> projectNameLabelStyle

    _ = self.rootStackView
      |> rootStackViewStyle
  }
}

// MARK: - Styles

private let contentViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .ksr_grey_300
}

private let manageButtonStyle: ButtonStyle = { button in
  button
    |> redButtonStyle
    |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Manage() }
}

private let manageButtonTitleLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.lineBreakMode .~ .byTruncatingTail
}

private let projectNameLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_footnote()
    |> \.numberOfLines .~ 0
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.spacing .~ Styles.gridHalf(1)
}
