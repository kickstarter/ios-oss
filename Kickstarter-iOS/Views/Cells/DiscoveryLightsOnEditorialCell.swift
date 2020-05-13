import Foundation
import KsApi
import Library
import Prelude
import UIKit

protocol DiscoveryLightsOnEditorialCellDelegate: AnyObject {
  func discoveryLightsOnEditorialCellTapped(
    _ cell: DiscoveryLightsOnEditorialCell,
    tagId: DiscoveryParams.TagID
  )
}

final class DiscoveryLightsOnEditorialCell: UITableViewCell, ValueCell {
  weak var delegate: DiscoveryLightsOnEditorialCellDelegate?

  // MARK: - Properties

  private let containerView = UIView(frame: .zero)
  private let editorialImageView = {
    UIImageView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let editorialTitleLabel = UILabel(frame: .zero)
  private let editorialSubtitleLabel = UILabel(frame: .zero)
  private let rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let viewModel: DiscoveryLightsOnEditorialViewModelType = DiscoveryLightsOnEditorialViewModel()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
    self.setupConstraints()
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

        self.delegate?.discoveryLightsOnEditorialCellTapped(self, tagId: tagId)
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
      |> DiscoveryLightsOnEditorialCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(2), left: Styles.grid(30), bottom: 0, right: Styles.grid(30))
          : .init(top: Styles.grid(2), left: Styles.grid(2), bottom: 0, right: Styles.grid(2))
      }
      |> \.isAccessibilityElement .~ true
      |> \.accessibilityTraits .~ [UIAccessibilityTraits.button]
      |> \.accessibilityLabel %~ { _ in Strings.Introducing_Lights_On() }
      |> \.accessibilityHint %~ { _ in Strings.Support_creative_spaces_and_businesses_affected_by() }

    _ = self.rootStackView
      |> rootStackViewStyle

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

  func configureWith(value: DiscoveryLightsOnEditorialCellValue) {
    self.viewModel.inputs.configureWith(value)
  }

  // MARK: - Configuration

  private func configureViews() {
    _ = (self.editorialImageView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (self.containerView, self.editorialImageView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (self.rootStackView, self.containerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.editorialTitleLabel, self.editorialSubtitleLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    let tapGestureRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(DiscoveryLightsOnEditorialCell.lightsOnCellTapped)
    )

    self.addGestureRecognizer(tapGestureRecognizer)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.containerView.widthAnchor
        .constraint(equalTo: self.editorialImageView.widthAnchor, multiplier: 0.52)
    ])
  }

  // MARK: - Accessors

    @objc private func lightsOnCellTapped() {
      self.viewModel.inputs.lightsOnCellTapped()
    }
}

// MARK: - Styles

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.spacing .~ Styles.grid(2)
    |> \.isLayoutMarginsRelativeArrangement .~ true
}
