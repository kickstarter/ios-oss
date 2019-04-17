import UIKit

public func ksr_addSubviewToParent() -> ((UIView, UIView) -> (UIView, UIView)) {
  return { (subview, parent) in
    parent.addSubview(subview)
    return (subview, parent)
  }
}

public func ksr_constrainViewToEdgesInParent(priority: UILayoutPriority = .required)
  -> ((UIView, UIView) -> (UIView, UIView)) {
  return { (subview, parent) in
    subview.translatesAutoresizingMaskIntoConstraints = false

    let constraints = [
      subview.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
      subview.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
      subview.topAnchor.constraint(equalTo: parent.topAnchor),
      subview.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
    ]

    constraints.forEach { $0.priority = priority }

    NSLayoutConstraint.activate(constraints)

    return (subview, parent)
  }
}

public func ksr_constrainViewToMarginsInParent() -> ((UIView, UIView) -> (UIView, UIView)) {
  return { (subview, parent) in
    subview.translatesAutoresizingMaskIntoConstraints = false

    let constraints = [
      subview.leadingAnchor.constraint(equalTo: parent.layoutMarginsGuide.leadingAnchor),
      subview.trailingAnchor.constraint(equalTo: parent.layoutMarginsGuide.trailingAnchor),
      subview.topAnchor.constraint(equalTo: parent.layoutMarginsGuide.topAnchor),
      subview.bottomAnchor.constraint(equalTo: parent.layoutMarginsGuide.bottomAnchor)
    ]

    NSLayoutConstraint.activate(constraints)

    return (subview, parent)
  }
}
