import Foundation
import Library
import Prelude
import UIKit

private enum Layout {
  enum CardImageView {
    static let minWidth: CGFloat = 40.0
  }
}

final class PledgePaymentMethodLoadingCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var cardImagePlaceholder: UIView = { UIView(frame: .zero) }()
  private lazy var contentStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var subtitlePlaceholder: UIView = { UIView(frame: .zero) }()
  private lazy var subtitleStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var titlePlaceholder: UIView = { UIView(frame: .zero) }()
  private lazy var titleStackView: UIStackView = { UIStackView(frame: .zero) }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
    self.setupConstraints()

    self.startLoading()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.layoutPlaceholderViews()

    self.layoutGradientLayers()
  }

  private func layoutPlaceholderViews() {
    self.cardImagePlaceholder.layoutIfNeeded()
    self.subtitlePlaceholder.layoutIfNeeded()
    self.titlePlaceholder.layoutIfNeeded()

    _ = self.cardImagePlaceholder
      |> roundedStyle(cornerRadius: Styles.grid(1))

    _ = self.subtitlePlaceholder
      |> roundedStyle(cornerRadius: self.subtitlePlaceholder.bounds.height / 2)

    _ = self.titlePlaceholder
      |> roundedStyle(cornerRadius: self.titlePlaceholder.bounds.height / 2)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.rootStackView
      |> \.spacing .~ Styles.grid(2)
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.insetsLayoutMarginsFromSafeArea .~ false
      |> \.layoutMargins .~ .init(all: Styles.grid(2))

    _ = self.contentStackView
      |> \.axis .~ .vertical
      |> \.distribution .~ .fillEqually
      |> \.spacing .~ Styles.gridHalf(3)
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.insetsLayoutMarginsFromSafeArea .~ false
      |> \.layoutMargins .~ .init(topBottom: Styles.grid(1))

    _ = self.subtitleStackView
      |> \.insetsLayoutMarginsFromSafeArea .~ false

    _ = self.titleStackView
      |> \.insetsLayoutMarginsFromSafeArea .~ false
  }

  func configureWith(value _: Void) {}

  // MARK: - Subviews

  private func configureViews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.titlePlaceholder, UIView()], self.titleStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.subtitlePlaceholder, UIView()], self.subtitleStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.titleStackView, self.subtitleStackView], self.contentStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.cardImagePlaceholder, self.contentStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    let cardImageWidthConstraint = self.cardImagePlaceholder.widthAnchor
      .constraint(equalToConstant: Layout.CardImageView.minWidth)
      |> \.priority .~ .defaultHigh

    NSLayoutConstraint.activate([
      cardImageWidthConstraint,
      self.cardImagePlaceholder.heightAnchor.constraint(equalTo: self.cardImagePlaceholder.widthAnchor),
      self.titlePlaceholder.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
      self.subtitlePlaceholder.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4)
    ])
  }
}

// MARK: - ShimmerLoading

extension PledgePaymentMethodLoadingCell: ShimmerLoading {
  func shimmerViews() -> [UIView] {
    return [self.cardImagePlaceholder, self.titlePlaceholder, self.subtitlePlaceholder]
  }
}
