import KsApi
import Library
import Prelude
import UIKit

protocol ProjectPamphletCreatorHeaderCellDelegate: class {
  func projectPamphletCreatorHeaderCellDidTapButton(_ cell: ProjectPamphletCreatorHeaderCell)
}

final class ProjectPamphletCreatorHeaderCell: UITableViewCell, ValueCell {
  // MARK: Properties

  private let projectCreationInfoLabel: UILabel = { UILabel(frame: .zero) }()
  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let viewProgressButton: UIButton = { UIButton(frame: .zero) }()

  weak var delegate: ProjectPamphletCreatorHeaderCellDelegate?

  // MARK: Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.configureViews()
    self.setupConstraints()
    self.bindStyles()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Configuration

  internal func configureWith(value project: Project) {
    print(project)
  }

  private func configureViews() {
    _ = ([self.projectCreationInfoLabel, self.viewProgressButton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.viewProgressButton.heightAnchor.constraint(equalToConstant: 50)
    ])
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.projectCreationInfoLabel
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
}

// MARK: Styles

private let projectCreationInfoLabelStyle: LabelStyle = { label in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.numberOfLines .~ 0
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
}

private let viewProgressButtonStyle: ButtonStyle = { button in
  button
    |> greyButtonStyle
}
