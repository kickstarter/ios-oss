import UIKit.UIStackView

public func ksr_addArrangedSubviewsToStackView() -> (([UIView], UIStackView) -> UIStackView) {
  return { subviews, stackView in
    subviews.forEach(stackView.addArrangedSubview)

    return stackView
  }
}

public func ksr_setCustomSpacing(_ spacing: CGFloat) -> ((UIView, UIStackView) -> UIStackView) {
  return { view, stackView in
    stackView.setCustomSpacing(spacing, after: view)

    return stackView
  }
}
