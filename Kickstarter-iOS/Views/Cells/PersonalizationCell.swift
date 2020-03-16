import Foundation
import KsApi
import Library
import Prelude
import UIKit

protocol PersonalizationCellDelegate: AnyObject {
  func personalizationCellTapped(
    _ cell: PersonalizationCell
  )

  func personalizationCellDidTapRemove(_ cell: PersonalizationCell)
}

final class PersonalizationCell: UITableViewCell, ValueCell {
  weak var delegate: PersonalizationCellDelegate?

  // MARK: - Properties

  private let containerView = UIView(frame: .zero)
  private let imageViewLeft = {
    UIImageView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()
  private let imageViewRight = {
    UIImageView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let subtitleLabel = UILabel(frame: .zero)
  private let titleLabel = UILabel(frame: .zero)
  private let removeButton = {
    UIButton(type: .custom)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let rootStackView = { UIStackView(frame: .zero) }()

  private let viewModel: DiscoveryEditorialViewModelType = DiscoveryEditorialViewModel()

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

        self.delegate?.personalizationCellTapped(self)
      }
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> PersonalizationCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(2), left: Styles.grid(30), bottom: 0, right: Styles.grid(30))
          : .init(top: Styles.grid(2), left: Styles.grid(2), bottom: 0, right: Styles.grid(2))
      }

    _ = self.containerView
      |> containerViewStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.imageViewLeft
      |> UIImageView.lens.contentMode .~ .scaleAspectFill

    _ = self.imageViewRight
      |> UIImageView.lens.contentMode .~ .scaleAspectFill

    _ = self.removeButton
      |> removeButtonStyle

    _ = self.titleLabel
      |> baseLabelStyle
      |> titleLabelStyle

    _ = self.subtitleLabel
      |> baseLabelStyle
      |> subtitleLabelStyle
  }

  func configureWith(value: ()) {
//    self.viewModel.inputs.configureWith(value)
  }

  // MARK: - Configuration

  private func configureViews() {
    _ = (self.containerView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (self.rootStackView, self.containerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.imageViewLeft, self.containerView)
      |> ksr_addSubviewToParent()

    _ = (self.imageViewRight, self.containerView)
      |> ksr_addSubviewToParent()

    _ = ([self.titleLabel, self.subtitleLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.removeButton, self.containerView)
      |> ksr_addSubviewToParent()

    let tapGestureRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(PersonalizationCell.cellTapped)
    )

    self.containerView.addGestureRecognizer(tapGestureRecognizer)

    self.removeButton
      .addTarget(self, action: #selector(PersonalizationCell.removeButtonTapped), for: .touchUpInside)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.imageViewLeft.leftAnchor.constraint(equalTo: self.containerView.leftAnchor),
      self.imageViewLeft.topAnchor.constraint(equalTo: self.containerView.topAnchor),
      self.imageViewLeft.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
      self.imageViewRight.rightAnchor.constraint(equalTo: self.containerView.rightAnchor),
      self.imageViewRight.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
      self.imageViewRight.topAnchor.constraint(equalTo: self.containerView.topAnchor),
      self.removeButton.topAnchor.constraint(equalTo: self.containerView.topAnchor),
      self.removeButton.rightAnchor.constraint(equalTo: self.containerView.rightAnchor),
      self.removeButton.widthAnchor.constraint(equalToConstant: Styles.minTouchSize.width),
      self.removeButton.heightAnchor.constraint(equalToConstant: Styles.minTouchSize.height)
    ])
  }

  // MARK: - Accessors

  @objc private func cellTapped() {
//    self.viewModel.inputs.editorialCellTapped()
  }

  @objc private func removeButtonTapped() {
//    self.viewModel.inputs.editorialCellTapped()
  }
}

// MARK: - Styles

private let containerViewStyle: ViewStyle = { view in
  view
    |> roundedStyle(cornerRadius: Styles.grid(2))
    |> \.backgroundColor .~ .ksr_trust_700
    |> \.isAccessibilityElement .~ true
    |> \.accessibilityTraits .~ [UIAccessibilityTraits.button]
    |> \.accessibilityLabel %~ { _ in "We've helped you find your next project to back." }
    |> \.accessibilityHint %~ { _ in "See what we've found" }
}

private let baseLabelStyle: LabelStyle = { label in
  label
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .white
    |> \.textAlignment .~ .center
}

private let titleLabelStyle: LabelStyle = { label in
  label
  |> \.font .~ UIFont.ksr_headline().bolded
    |> \.text %~ { _ in "We've helped you find your next project to back" }
}

private let subtitleLabelStyle: LabelStyle = { label in
  label
  |> \.font .~ UIFont.ksr_subhead()
  |> \.text %~ { _ in "See what we've found >" }
}

private let removeButtonStyle: ButtonStyle = { button in
  button
    |> \.tintColor .~ UIColor.white
    |> UIButton.lens.image(for: .normal) .~ image(named: "icon--cross")
    |> UIButton.lens.accessibilityLabel %~ { _ in "Hide personalization card" }
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.spacing .~ Styles.grid(2)
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ .init(top: Styles.grid(5),
                                left: Styles.grid(4),
                                bottom: Styles.grid(3),
                                right: Styles.grid(4))
}

