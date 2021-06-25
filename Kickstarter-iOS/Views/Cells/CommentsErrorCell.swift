import Library
import Prelude
import UIKit

final class CommentsErrorCell: UITableViewCell, ValueCell {
  private let iconImageView = UIImageView()
  private let messageLabel = UILabel()
  private let rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.bindStyles()
    self.configureViews()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self |> baseTableViewCellStyle()

    _ = self.rootStackView
      |> \.axis .~ .vertical
      |> \.distribution .~ .fillProportionally
      |> \.alignment .~ .center
      |> \.spacing .~ Styles.grid(2)

    _ = self.messageLabel
      |> messageLabelStyle

    _ = self.iconImageView
      |> UIImageView.lens.image .~ Library.image(named: "icon--alert")
      |> \.tintColor .~ .ksr_black
  }

  // MARK: - Configuration

  func configureWith(value _: Void) {
    self.messageLabel.text = Strings.Something_went_wrong_pull_to_refresh()
  }

  private func configureViews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()

    _ = ([self.iconImageView, self.messageLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    NSLayoutConstraint.activate([
      self.iconImageView.heightAnchor.constraint(equalToConstant: Styles.grid(4)),
      self.iconImageView.widthAnchor.constraint(equalToConstant: Styles.grid(4)),
      self.rootStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      self.rootStackView.heightAnchor.constraint(equalToConstant: Styles.grid(9)),
      self.rootStackView.leadingAnchor.constraint(
        equalTo: self.safeAreaLayoutGuide.leadingAnchor,
        constant: Styles.grid(1)
      ),
      self.rootStackView.trailingAnchor.constraint(
        equalTo: self.safeAreaLayoutGuide.trailingAnchor,
        constant: -Styles.grid(1)
      )
    ])
  }
}

// MARK: - Styles

private let messageLabelStyle: LabelStyle = { label in
  label
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.font .~ UIFont.ksr_subhead()
    |> \.textAlignment .~ .center
    |> \.textColor .~ UIColor.ksr_support_700
}
