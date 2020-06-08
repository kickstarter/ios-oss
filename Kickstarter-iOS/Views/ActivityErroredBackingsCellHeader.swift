import Library
import Prelude
import UIKit

final class ActivityErroredBackingsCellHeader: UIView {
  // MARK: - Properties

  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let subtitleLabel: UILabel = { UILabel(frame: .zero) }()
  private let titleLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Life cycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.bindStyles()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: - Configuration

  private func configureViews() {
    _ = ([self.titleLabel, self.subtitleLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.subtitleLabel
      |> subtitleLabelStyle

    _ = self.titleLabel
      |> titleLabelStyle
  }
}

// MARK: - Styles

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> \.spacing .~ Styles.grid(1)
}

private let subtitleLabelStyle: LabelStyle = { label in
  label
    |> \.text %~ { _ in Strings.We_cant_process_your_pledge_for() }
    |> \.font .~ UIFont.ksr_footnote()
    |> \.textColor .~ .ksr_soft_black
    |> \.numberOfLines .~ 0
}

private let titleLabelStyle: LabelStyle = { label in
  label
    |> \.text %~ { _ in Strings.Payment_failure() }
    |> \.font .~ UIFont.ksr_title2().bolded
    |> \.textColor .~ .ksr_soft_black
    |> \.numberOfLines .~ 0
}
