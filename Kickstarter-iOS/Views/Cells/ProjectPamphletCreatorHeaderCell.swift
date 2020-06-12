import KsApi
import Library
import Prelude
import UIKit

private enum Layout {
  enum Button {
    static let height: CGFloat = 48
    static let width: CGFloat = 152
  }
}

protocol ProjectPamphletCreatorHeaderCellDelegate: AnyObject {
  func projectPamphletCreatorHeaderCellDidTapViewProgress(
    _ cell: ProjectPamphletCreatorHeaderCell,
    with project: Project
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

  required init?(coder _: NSCoder) {
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
      self.viewProgressButton.heightAnchor.constraint(equalToConstant: Layout.Button.height),
      self.viewProgressButton.widthAnchor.constraint(equalToConstant: Layout.Button.width)
    ])
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()
    self.launchDateLabel.rac.attributedText = self.viewModel.outputs.launchDateLabelAttributedText
    self.viewProgressButton.rac.title = self.viewModel.outputs.buttonTitle

    self.viewModel.outputs.notifyDelegateViewProgressButtonTapped
      .observeForUI()
      .observeValues { [weak self] project in
        guard let self = self else { return }

        self.delegate?.projectPamphletCreatorHeaderCellDidTapViewProgress(self, with: project)
      }
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.contentView
      |> contentViewStyle

    _ = self.launchDateLabel
      |> projectCreationInfoLabelStyle

    _ = self.rootStackView
      |> adaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )
      |> rootStackViewStyle

    _ = self.viewProgressButton
      |> viewProgressButtonStyle
  }

  // MARK: - Actions

  @objc private func viewProgressButtonTapped() {
    self.viewModel.inputs.viewProgressButtonTapped()
  }
}

// MARK: Styles

private let contentViewStyle: ViewStyle = { view in
  view
    |> \.layer.borderWidth .~ 2.0
    |> \.backgroundColor .~ UIColor.ksr_grey_100
    |> \.layer.borderColor .~ UIColor.ksr_grey_500.cgColor
    |> \.layoutMargins %~~ { _, _ in
      .init(topBottom: Styles.grid(3), leftRight: 0)
    }
}

private let projectCreationInfoLabelStyle: LabelStyle = { label in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.numberOfLines .~ 0
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.spacing .~ Styles.grid(1)
}

private let viewProgressButtonStyle: ButtonStyle = { button in
  button
    |> greyButtonStyle
}
