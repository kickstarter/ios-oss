import Foundation
import KsApi
import Library
import Prelude
import UIKit

protocol PersonalizationCellDelegate: AnyObject {
  func personalizationCellTapped(
    _ cell: PersonalizationCell
  )

  func personalizationCellDidTapDismiss(_ cell: PersonalizationCell)
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
  private let dismissButton = {
    UIButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let rootStackView = { UIStackView(frame: .zero) }()

  private let viewModel: PersonalizationCellViewModelType = PersonalizationCellViewModel()

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
      .observeValues { [weak self] _ in
        guard let self = self else { return }

        self.delegate?.personalizationCellTapped(self)
      }

    self.viewModel.outputs.notifyDelegateDismissButtonTapped
      .observeForUI()
      .observeValues { [weak self] in
        guard let self = self else { return }

        self.delegate?.personalizationCellDidTapDismiss(self)
      }
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> \.backgroundColor .~ discoveryPageBackgroundColor()
      |> \.accessibilityElements .~ [self.containerView, self.dismissButton]
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
      |> imageLeftStyle

    _ = self.imageViewRight
      |> imageRightStyle

    _ = self.dismissButton
      |> dismissButtonStyle

    _ = self.titleLabel
      |> baseLabelStyle
      |> titleLabelStyle

    _ = self.subtitleLabel
      |> baseLabelStyle
      |> subtitleLabelStyle
  }

  func configureWith(value _: ()) {}

  // MARK: - Configuration

  private func configureViews() {
    _ = (self.containerView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (self.imageViewLeft, self.containerView)
      |> ksr_addSubviewToParent()

    _ = (self.imageViewRight, self.containerView)
      |> ksr_addSubviewToParent()

    _ = (self.rootStackView, self.containerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.titleLabel, self.subtitleLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.dismissButton, self.containerView)
      |> ksr_addSubviewToParent()

    let tapGestureRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(PersonalizationCell.cellTapped)
    )

    self.containerView.addGestureRecognizer(tapGestureRecognizer)

    self.dismissButton
      .addTarget(self, action: #selector(PersonalizationCell.dismissButtonTapped), for: .touchUpInside)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.imageViewLeft.leftAnchor.constraint(equalTo: self.containerView.leftAnchor),
      self.imageViewLeft.topAnchor.constraint(equalTo: self.containerView.topAnchor),
      self.imageViewLeft.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
      self.imageViewRight.rightAnchor.constraint(equalTo: self.containerView.rightAnchor),
      self.imageViewRight.topAnchor.constraint(equalTo: self.containerView.topAnchor),
      self.dismissButton.topAnchor.constraint(equalTo: self.containerView.topAnchor),
      self.dismissButton.rightAnchor.constraint(equalTo: self.containerView.rightAnchor),
      self.dismissButton.widthAnchor.constraint(equalToConstant: Styles.minTouchSize.width),
      self.dismissButton.heightAnchor.constraint(equalToConstant: Styles.minTouchSize.height)
    ])
  }

  // MARK: - Accessors

  @objc private func cellTapped() {
    self.viewModel.inputs.cellTapped()
  }

  @objc private func dismissButtonTapped() {
    self.viewModel.inputs.dismissButtonTapped()
  }
}

// MARK: - Styles

private let containerViewStyle: ViewStyle = { view in
  view
    |> roundedStyle(cornerRadius: Styles.grid(2))
    |> \.backgroundColor .~ .ksr_trust_700
    |> \.isAccessibilityElement .~ true
    |> \.accessibilityTraits .~ [UIAccessibilityTraits.button]
    |> \.accessibilityLabel %~ { _ in Strings.Well_help_you_find_a_project_to_back() }
    |> \.accessibilityHint %~ { _ in Strings.See_our_suggestions() }
}

private let baseLabelStyle: LabelStyle = { label in
  label
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .white
    |> \.textAlignment .~ .center
}

private let imageLeftStyle: ImageViewStyle = { imageView in
  imageView
    |> \.image .~ image(named: "shape-green-wave")
    |> UIImageView.lens.contentMode .~ .scaleAspectFill
}

private let imageRightStyle: ImageViewStyle = { imageView in
  imageView
    |> \.image .~ image(named: "shape-purple-circle")
    |> UIImageView.lens.contentMode .~ .scaleAspectFill
}

private let titleLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_title3().bolded
    |> \.text %~ { _ in Strings.Well_help_you_find_a_project_to_back() }
}

private let subtitleLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_body()
    |> \.text %~ { _ in Strings.See_our_suggestions() }
}

private let dismissButtonStyle: ButtonStyle = { button in
  button
    |> \.tintColor .~ UIColor.white
    |> UIButton.lens.image(for: .normal) .~ image(named: "icon--cross")
    |> UIButton.lens.accessibilityLabel %~ { _ in Strings.Dismiss() }
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.spacing .~ Styles.grid(2)
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ .init(
      top: Styles.grid(6),
      left: Styles.grid(4),
      bottom: Styles.grid(3),
      right: Styles.grid(4)
    )
}
