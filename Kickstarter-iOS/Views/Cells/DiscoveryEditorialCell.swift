import Foundation
import KsApi
import Library
import Prelude
import UIKit

protocol DiscoveryEditorialCellDelegate: AnyObject {
  func discoveryEditorialCellTapped(
    _ cell: DiscoveryEditorialCell,
    tagId: DiscoveryParams.TagID
  )
}

final class DiscoveryEditorialCell: UITableViewCell, ValueCell {
  weak var delegate: DiscoveryEditorialCellDelegate?

  // MARK: - Properties

  private let editorialImageView = {
    UIImageView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let editorialTitleLabel = UILabel(frame: .zero)
  private let editorialSubtitleLabel = UILabel(frame: .zero)
  private let leftColumnStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let viewModel: DiscoveryEditorialViewModelType = DiscoveryEditorialViewModel()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyDelegateViewTapped
      .observeForUI()
      .observeValues { [weak self] tagId in
        guard let self = self else { return }

        self.delegate?.discoveryEditorialCellTapped(self, tagId: tagId)
      }

    self.viewModel.outputs.imageName
      .observeForUI()
      .observeValues { [weak self] imageName in
        guard let self = self else { return }

        _ = self.editorialImageView
          |> \.image %~ { _ in
            Library.image(
              named: imageName,
              inBundle: Bundle.framework,
              compatibleWithTraitCollection: nil
            )
          }
      }

    self.editorialTitleLabel.rac.text = self.viewModel.outputs.titleText
    self.editorialSubtitleLabel.rac.text = self.viewModel.outputs.subtitleText
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> DiscoveryEditorialCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(2), left: Styles.grid(30), bottom: 0, right: Styles.grid(30))
          : .init(top: Styles.grid(2), left: Styles.grid(2), bottom: 0, right: Styles.grid(2))
      }
      |> \.isAccessibilityElement .~ true
      |> \.accessibilityTraits .~ [UIAccessibilityTraits.button]
      |> \.accessibilityLabel %~ { _ in Strings.Introducing_Lights_On() }
      |> \.accessibilityHint %~ { _ in Strings.Support_creative_spaces_and_businesses_affected_by() }

    _ = self
      |> \.backgroundColor .~ discoveryPageBackgroundColor()

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.leftColumnStackView
      |> \.axis .~ .vertical
      |> \.spacing .~ Styles.grid(2)

    _ = self.editorialImageView
      |> roundedStyle(cornerRadius: Styles.grid(2))
      |> UIImageView.lens.contentMode .~ .scaleAspectFill

    _ = self.editorialTitleLabel
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 0
      |> \.textColor .~ .white
      |> \.textAlignment .~ .left
      |> \.font .~ UIFont.ksr_title3().bolded

    _ = self.editorialSubtitleLabel
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 0
      |> \.textColor .~ .white
      |> \.textAlignment .~ .left
      |> \.font .~ UIFont.ksr_callout().bolded
  }

  func configureWith(value: DiscoveryEditorialCellValue) {
    self.viewModel.inputs.configureWith(value)

    self.layoutIfNeeded()
  }

  // MARK: - Configuration

  private func configureViews() {
    _ = (self.editorialImageView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.leftColumnStackView, UIView()], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.editorialTitleLabel, self.editorialSubtitleLabel], self.leftColumnStackView)
      |> ksr_addArrangedSubviewsToStackView()

    let tapGestureRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(DiscoveryEditorialCell.editorialCellTapped)
    )

    self.addGestureRecognizer(tapGestureRecognizer)
  }

  // MARK: - Accessors

  @objc private func editorialCellTapped() {
    self.viewModel.inputs.editorialCellTapped()
  }
}

// MARK: - Styles

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.distribution .~ .fillEqually
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ .init(all: Styles.grid(2))
}
