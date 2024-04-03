import Library
import Prelude
import UIKit

final class ViewRepliesView: UIView {
  // MARK: - Properties

  private lazy var iconImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var textLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.bindStyles()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Views

  private func configureSubviews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.textLabel, UIView(), self.iconImageView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.rootStackView
      |> viewRepliesStackViewStyle

    _ = self.textLabel
      |> \.text %~ { _ in Strings.View_replies() }
      |> \.textColor .~ UIColor.ksr_support_400
      |> \.font .~ UIFont.ksr_callout(size: 14)

    _ = self.iconImageView
      |> UIImageView.lens.image .~ Library.image(named: "right-diagonal")

    // Add accessibility label to self instead of to the textLabel, so the cell can be treated as
    // one accessibility element.
    self.accessibilityLabel = Strings.View_replies()
  }
}
