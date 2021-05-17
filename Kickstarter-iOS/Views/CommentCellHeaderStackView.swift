import KsApi
import Library
import Prelude
import UIKit

internal final class CommentCellHeaderStackView: UIStackView {
  private lazy var userImageView = { UIImageView(frame: .zero)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var userNameLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var userNameTagLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var postTimeLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var usernameLabelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var usernameTimeLabelsStackView: UIStackView = { UIStackView(frame: .zero) }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    _ = self
      |> \.axis .~ .horizontal
      |> \.spacing .~ Styles.grid(2)

    _ = self.usernameTimeLabelsStackView
      |> \.axis .~ .vertical
      |> \.spacing .~ Styles.grid(1)

    _ = self.usernameLabelsStackView
      |> \.axis .~ .horizontal
      |> \.spacing .~ Styles.grid(1)

    _ = self.userNameLabel
      |> \.numberOfLines .~ 1
      |> \.textColor .~ .ksr_support_700
      |> \.textAlignment .~ .left
      |> \.font .~ UIFont.ksr_callout().weighted(.semibold)
      |> \.adjustsFontForContentSizeCategory .~ true

    _ = self.userNameTagLabel
      |> \.numberOfLines .~ 1
      |> \.textColor .~ .ksr_create_500
      |> \.textAlignment .~ .left
      |> \.font .~ UIFont.ksr_callout().bolded
      |> \.adjustsFontForContentSizeCategory .~ true

    _ = self.postTimeLabel
      |> \.numberOfLines .~ 1
      |> \.textColor .~ .ksr_support_400
      |> \.textAlignment .~ .left
      |> \.font .~ UIFont.ksr_footnote()
      |> \.adjustsFontForContentSizeCategory .~ true

    self.addArrangedSubview(self.userImageView)
    self.addArrangedSubview(self.usernameTimeLabelsStackView)

    _ = ([self.usernameLabelsStackView, self.postTimeLabel], self.usernameTimeLabelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.userNameLabel, self.userNameTagLabel, UIView()], self.usernameLabelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    NSLayoutConstraint.activate([
      self.userImageView.widthAnchor.constraint(equalToConstant: Styles.grid(7)),
      self.userImageView.heightAnchor.constraint(equalToConstant: Styles.grid(7))
    ])
  }

  required init(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configureWith(comment: DemoComment) {
    self.userNameLabel.text = comment.username == nil ? (comment.firstName + " " + comment.lastName) : comment
      .username
    self.postTimeLabel.text = comment.postTime
    self.userImageView
      .ksr_setRoundedImageWith(URL(string: comment.imageURL)!)
    self.userNameTagLabel.text = comment.type == .backer ? nil : comment.type.rawValue.capitalized
  }
}
