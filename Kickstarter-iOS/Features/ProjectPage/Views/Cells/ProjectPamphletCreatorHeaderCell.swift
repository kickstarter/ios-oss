import KsApi
import Library
import Prelude
import UIKit

final class ProjectPamphletCreatorHeaderCell: UITableViewCell, ValueCell {
  // MARK: Properties

  private let launchDateLabel: UILabel = { UILabel(frame: .zero) }()
  private let viewModel: ProjectPamphletCreatorHeaderCellViewModelType =
    ProjectPamphletCreatorHeaderCellViewModel()

  // MARK: Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.configureViews()
    self.bindViewModel()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Configuration

  internal func configureWith(value project: Project) {
    self.viewModel.inputs.configure(with: project)
  }

  private func configureViews() {
    _ = (self.launchDateLabel, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()
    self.launchDateLabel.rac.attributedText = self.viewModel.outputs.launchDateLabelAttributedText
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.contentView
      |> contentViewStyle

    _ = self.launchDateLabel
      |> projectCreationInfoLabelStyle
  }
}

// MARK: Styles

private let contentViewStyle: ViewStyle = { view in
  view
    |> \.layer.borderWidth .~ 2.0
    |> \.backgroundColor .~ UIColor.ksr_support_100
    |> \.layer.borderColor .~ UIColor.ksr_support_300.cgColor
    |> \.layoutMargins %~~ { _, _ in
      .init(topBottom: Styles.grid(3), leftRight: 0)
    }
}

private let projectCreationInfoLabelStyle: LabelStyle = { label in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.numberOfLines .~ 0
}
