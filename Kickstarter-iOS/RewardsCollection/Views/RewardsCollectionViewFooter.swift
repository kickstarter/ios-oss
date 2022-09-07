import Foundation
import Library
import Prelude
import UIKit

final class RewardsCollectionViewFooter: UIView {
  private lazy var countLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var separatorView: UIView = { UIView(frame: .zero)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.setupConstraints()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> checkoutBackgroundStyle

    _ = self.countLabel
      |> countLabelStyle

    _ = self.separatorView
      |> separatorStyleDark
  }

  // MARK: - Functions

  private func configureSubviews() {
    _ = self
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

    _ = (self.separatorView, self)
      |> ksr_addSubviewToParent()

    _ = (self.countLabel, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent(priority: .defaultHigh)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.separatorView.leftAnchor.constraint(equalTo: self.leftAnchor),
      self.separatorView.rightAnchor.constraint(equalTo: self.rightAnchor),
      self.separatorView.topAnchor.constraint(equalTo: self.topAnchor),
      self.separatorView.heightAnchor.constraint(equalToConstant: 1)
    ])
  }

  // MARK: - Accessors

  public func configure(with rewardsCount: Int) {
    _ = self.countLabel
      |> \.text %~ { _ in Strings.Rewards_count_rewards(rewards_count: rewardsCount) }
  }
}

private let countLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_footnote()
    |> \.textColor .~ UIColor.ksr_support_400
    |> \.textAlignment .~ .center
    |> \.backgroundColor .~ UIColor.ksr_support_100
}
