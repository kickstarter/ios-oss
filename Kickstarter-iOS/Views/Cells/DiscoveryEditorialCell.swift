import Foundation
import Library
import Prelude
import UIKit
import KsApi

protocol DiscoveryEditorialCellDelegate: AnyObject {
  func discoveryEditorialCellDidTapGoRewardlessButton(_ cell: DiscoveryEditorialCell)
}

final class DiscoveryEditorialCell: UITableViewCell, ValueCell {
  weak var delegate: DiscoveryEditorialCellDelegate?

  private let containerView = UIView(frame: .zero)
  private let editorialTitleLabel = UILabel(frame: .zero)
  private let editorialSubtitleLabel = UILabel(frame: .zero)
  private let rootStackView = UIStackView(frame: .zero)

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.containerView
      |> \.backgroundColor .~ .ksr_violet_500
      |> roundedStyle(cornerRadius: Styles.grid(2))

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.editorialTitleLabel
      |> editorialLabelStyle
      |> \.font .~ UIFont.ksr_title2()
      |> \.text .~ "Going rewardless is rewarding"

    _ = self.editorialSubtitleLabel
      |> editorialLabelStyle
      |> \.font .~ UIFont.ksr_subhead()
      |> \.text .~ "Find projects that speak to you"
  }
  // TBD whether DiscoveryParams is what we need to pass here
  func configureWith(value: ()) {
    // TODO
  }

  // MARK: - Configuration

  private func configureViews() {
    _ = (self.containerView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (self.rootStackView, self.containerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.editorialTitleLabel, self.editorialSubtitleLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

//    let tapGestureRecognizer = UITapGestureRecognizer(target: self,
//                                                      action: #selector(DiscoveryEditorialCell.goRewardlessButtonTapped))

  }

  // MARK: - Accessors

  @objc private func goRewardlessButtonTapped() {
    self.delegate?.discoveryEditorialCellDidTapGoRewardlessButton(self)
  }
}

// MARK: - Styles

private let editorialLabelStyle: LabelStyle = { label in
  label
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .white
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.spacing .~ Styles.grid(3)
    |> \.alignment .~ .leading
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
}
