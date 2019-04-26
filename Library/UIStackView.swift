import UIKit.UIStackView

public func ksr_addArrangedSubviewsToStackView() -> (([UIView], UIStackView) -> UIStackView) {
  return { (subviews, stackView) in
    subviews.forEach { subview in
      stackView.addArrangedSubview(subview)
    }

    return stackView
  }
}
