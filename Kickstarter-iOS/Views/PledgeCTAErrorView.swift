import Prelude
import UIKit

protocol PledgeCTAErrorViewDelegate: class {
  func didTapRetry()
}

final class PledgeCTAErrorView: UIView {

  public var delegate: PledgeCTAErrorViewDelegate?

  private let errorLabel: UILabel = UILabel(frame: .zero)
  private let messageStackView: UIStackView = UIStackView(frame: .zero)
  private let retryButton: UIButton = UIButton(type: .system)
  private let retryImageView: UIImageView = {
    UIImageView(image: image(named: "icon--circle-forward"))
  }()
  private let rootStackView: UIStackView = UIStackView(frame: .zero)
  private let viewContainer: UIView = { UIView(frame: .zero) }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.setupConstraints()
  }

  // MARK - Bind Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.errorLabel
      |> errorLabelStyle

    _ = self.messageStackView
      |> messageStackViewStyle

    _ = self.viewContainer
      |> viewContainerStyle
  }

  private func configureViews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.retryImageView, self.errorLabel], self.messageStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.messageStackView, self.viewContainer)
      |> ksr_addSubviewToParent()

    _ = (self.retryButton, self.viewContainer)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.viewContainer], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.retryButton.addTarget(self,
                               action: #selector(PledgeCTAErrorView.didTapRetry),
                               for: .touchUpInside)
  }

  @objc func didTapRetry() {
    print("didTapRetry")
    self.delegate?.didTapRetry()
  }

  private func setupConstraints() {
    let messageStackViewConstraints = [
      self.messageStackView.centerXAnchor.constraint(equalTo: self.rootStackView.centerXAnchor),
      self.messageStackView.centerYAnchor.constraint(equalTo: self.rootStackView.centerYAnchor)
    ]

    NSLayoutConstraint.activate(messageStackViewConstraints)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: Styles

private let errorLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_callout().bolded
    |> \.textColor .~ .ksr_soft_black
}

private let messageStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
}

private let viewContainerStyle : ViewStyle = { view in
  view
    |> \.backgroundColor .~ .white
}
