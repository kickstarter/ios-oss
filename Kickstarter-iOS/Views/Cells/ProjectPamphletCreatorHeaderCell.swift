import KsApi
import Library
import Prelude
import UIKit

private enum Layout {
  enum Button {
    static let height: CGFloat = 48
  }
}

protocol ProjectPamphletCreatorHeaderCellDelegate: class {
  func projectPamphletCreatorHeaderCellDidTapButton(
    _ cell: ProjectPamphletCreatorHeaderCell,
    project: Project
  )
}

final class ProjectPamphletCreatorHeaderCell: UITableViewCell, ValueCell {
  // MARK: Properties

  private let launchDateLabel: UILabel = { UILabel(frame: .zero) }()
  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let viewProgressButton: UIButton = { UIButton(frame: .zero) }()
  private let viewModel: ProjectPamphletCreatorHeaderCellViewModelType =
    ProjectPamphletCreatorHeaderCellViewModel()

  internal weak var delegate: ProjectPamphletCreatorHeaderCellDelegate?

  // MARK: Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.configureViews()
    self.setupConstraints()
    self.bindViewModel()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Configuration

  internal func configureWith(value project: Project) {
    self.viewModel.inputs.configure(with: project)
  }

  private func configureViews() {
    _ = ([self.launchDateLabel, self.viewProgressButton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    self.viewProgressButton.addTarget(
      self, action: #selector(self.viewProgressButtonTapped), for: .touchUpInside
    )
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.viewProgressButton.heightAnchor.constraint(equalToConstant: Layout.Button.height)
    ])
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()
    self.launchDateLabel.rac.attributedText = self.viewModel.outputs.launchDateLabelAttributedText
    self.viewProgressButton.rac.title = self.viewModel.outputs.buttonTitle

    self.viewModel.outputs.notifyDelegateViewProgressButtonTapped
      .observeForUI()
      .observeValues { [weak self] in
        guard let self = self else { return }

        self.delegate?.projectPamphletCreatorHeaderCellDidTapButton(self, project: $0)
    }
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> viewStyle

    _ = self.launchDateLabel
      |> projectCreationInfoLabelStyle

    _ = self.rootStackView
      |> checkoutAdaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )
      |> rootStackViewStyle

    _ = self.viewProgressButton
      |> viewProgressButtonStyle
      self.viewProgressButton.setTitle("View progress", for: .normal)
  }

  // MARK: - Actions

  @objc private func viewProgressButtonTapped() {
    self.viewModel.inputs.viewProgressButtonTapped()
  }
}

// MARK: Styles

private let projectCreationInfoLabelStyle: LabelStyle = { label in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.numberOfLines .~ 0
    |> \.text %~ { _ in "You launched this project on January 2, 2018" }
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(3), leftRight: 0)
}

private let viewStyle: ViewStyle = { view in
  view
    |> \.layer.borderWidth .~ 2.0
    |> \.backgroundColor .~ UIColor.ksr_grey_100
    |> \.layer.borderColor .~ UIColor.ksr_grey_500.cgColor
}

private let viewProgressButtonStyle: ButtonStyle = { button in
  button
    |> greyButtonStyle
}
