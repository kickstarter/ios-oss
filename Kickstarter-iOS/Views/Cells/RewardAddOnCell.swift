import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

final class RewardAddOnCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var containerView: UIView = { UIView(frame: .zero) }()
  internal lazy var rewardAddOnCardView: RewardAddOnCardView = { RewardAddOnCardView(frame: .zero) }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.selectionStyle = .none

    self.configureViews()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  private func configureViews() {
    _ = (self.containerView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (self.rewardAddOnCardView, self.containerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent(priority: UILayoutPriority(rawValue: 999))
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.separatorInset = .init(leftRight: self.frame.width / 2)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.contentView
      |> contentViewStyle

    _ = self.containerView
      |> containerViewStyle
  }

  internal func configureWith(value: RewardAddOnCardViewData) {
    self.rewardAddOnCardView.configure(with: value)

    self.contentView.layoutIfNeeded()
  }
}

// MARK: - Styles

private let containerViewStyle: ViewStyle = { (view: UIView) in
  view
    |> checkoutWhiteBackgroundStyle
    |> roundedStyle(cornerRadius: Styles.grid(3))
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
}

private let contentViewStyle: ViewStyle = { (view: UIView) in
  view
    |> checkoutBackgroundStyle
    |> \.layoutMargins .~ .init(leftRight: Styles.grid(4))
}
