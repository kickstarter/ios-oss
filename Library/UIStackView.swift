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

public func ksr_setBackgroundColor(_ color: UIColor) -> ((UIStackView) -> (UIStackView)) {
  return { stackView in
    let backgroundView = UIView(frame: stackView.bounds)
    backgroundView.backgroundColor = color
    backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    stackView.insertSubview(backgroundView, at: 0)

    return stackView
  }
}
