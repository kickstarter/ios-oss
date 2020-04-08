import Foundation
import Library
import Prelude
import UIKit

final class ProcessingView: UIView {
  lazy var activityIndicator = { UIActivityIndicatorView(frame: .zero)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var processingLabel = { UILabel(frame: .zero) }()
  private lazy var stackView = { UIStackView(frame: .zero)
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
      |> \.backgroundColor .~ UIColor.ksr_soft_black.withAlphaComponent(0.8)

    _ = self.activityIndicator
      |> activityIndicatorStyle

    _ = self.processingLabel
      |> processingLabelStyle

    _ = self.stackView
      |> stackViewStyle
  }

  private func configureSubviews() {
    _ = (self.stackView, self)
      |> ksr_addSubviewToParent()

    _ = ([self.activityIndicator, self.processingLabel], self.stackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    let margins = self.layoutMarginsGuide

    NSLayoutConstraint.activate([
      self.stackView.leftAnchor.constraint(equalTo: margins.leftAnchor),
      self.stackView.rightAnchor.constraint(equalTo: margins.rightAnchor),
      self.stackView.centerYAnchor.constraint(equalTo: margins.centerYAnchor)
    ])
  }
}

private let activityIndicatorStyle: ActivityIndicatorStyle = { activityIndicator in
  activityIndicator
    |> \.style .~ .white
}

private let processingLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_callout()
    |> \.textColor .~ UIColor.white
    |> \.textAlignment .~ .center
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.text %~ { _ in localizedString(key: "processing", defaultValue: "Processing...") }
}

private let stackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> \.alignment .~ .center
    |> \.distribution .~ .fill
    |> \.spacing .~ Styles.grid(3)
}
