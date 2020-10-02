import UIKit

public func ksr_addSubviewToParent() -> ((UIView, UIView) -> (UIView, UIView)) {
  return { subview, parent in
    parent.addSubview(subview)
    return (subview, parent)
  }
}

public func ksr_insertSubview(_ subview: UIView, belowSubview otherSubview: UIView)
  -> ((UIView) -> (UIView)) {
  return { view in
    view.insertSubview(subview, belowSubview: otherSubview)

    return view
  }
}

public func ksr_insertSubviewInParent(at index: Int) -> ((UIView, UIView) -> (UIView, UIView)) {
  return { subview, parent in
    parent.insertSubview(subview, at: index)
    return (subview, parent)
  }
}

public func ksr_constrainViewToCenterInParent() -> ((UIView, UIView) -> (UIView, UIView)) {
  return { subview, parent in
    subview.translatesAutoresizingMaskIntoConstraints = false

    let constraints = [
      subview.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
      subview.centerYAnchor.constraint(equalTo: parent.centerYAnchor)
    ]

    NSLayoutConstraint.activate(constraints)

    return (subview, parent)
  }
}

public func ksr_constrainViewToTrailingMarginInParent() -> ((UIView, UIView) -> (UIView, UIView)) {
  return { subview, parent in
    subview.translatesAutoresizingMaskIntoConstraints = false

    let constraints = [
      subview.trailingAnchor.constraint(equalTo: parent.layoutMarginsGuide.trailingAnchor),
      subview.centerYAnchor.constraint(equalTo: parent.centerYAnchor),
    ]

    NSLayoutConstraint.activate(constraints)

    return (subview, parent)
  }
}

public func ksr_addLayoutGuideToView() -> ((UILayoutGuide, UIView) -> (UILayoutGuide, UIView)) {
  return { layoutGuide, view in
    view.addLayoutGuide(layoutGuide)
    return (layoutGuide, view)
  }
}

public func ksr_constrainViewToEdgesInParent(priority: UILayoutPriority = .required)
  -> ((UIView, UIView) -> (UIView, UIView)) {
  return { subview, parent in
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

public func ksr_constrainViewToMarginsInParent(priority: UILayoutPriority = .required)
  -> ((UIView, UIView) -> (UIView, UIView)) {
  return { subview, parent in
    subview.translatesAutoresizingMaskIntoConstraints = false

    let constraints = [
      subview.leadingAnchor.constraint(equalTo: parent.layoutMarginsGuide.leadingAnchor),
      subview.trailingAnchor.constraint(equalTo: parent.layoutMarginsGuide.trailingAnchor),
      subview.topAnchor.constraint(equalTo: parent.layoutMarginsGuide.topAnchor),
      subview.bottomAnchor.constraint(equalTo: parent.layoutMarginsGuide.bottomAnchor)
    ]

    constraints.forEach { $0.priority = priority }

    NSLayoutConstraint.activate(constraints)

    return (subview, parent)
  }
}

public func ksr_setContentCompressionResistancePriority(
  _ priority: UILayoutPriority,
  for axis: NSLayoutConstraint.Axis
) -> (UIView) -> (UIView) {
  return { view in
    view.setContentCompressionResistancePriority(priority, for: axis)

    return (view)
  }
}
