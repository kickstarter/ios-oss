import SwiftUI

final class FloatingTabBarHostingController: UIHostingController<FloatingTabBarView> {
  private var selected: FloatingTabBarTab
  private let onSelect: (FloatingTabBarTab) -> Void
  private var profileDefaultImage: UIImage?
  private var profileSelectedImage: UIImage?

  init(
    selected: FloatingTabBarTab,
    onSelect: @escaping (FloatingTabBarTab) -> Void,
    profileDefaultImage: UIImage? = nil,
    profileSelectedImage: UIImage? = nil
  ) {
    self.selected = selected
    self.onSelect = onSelect
    self.profileDefaultImage = profileDefaultImage
    self.profileSelectedImage = profileSelectedImage

    let rootView = FloatingTabBarView(
      selectedTab: selected,
      onSelect: onSelect,
      profileDefaultImage: profileDefaultImage,
      profileSelectedImage: profileSelectedImage
    )

    super.init(rootView: rootView)
    self.view.backgroundColor = .clear
  }

  @available(*, unavailable)
  @objc required dynamic init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func update(
    selected: FloatingTabBarTab,
    profileDefaultImage: UIImage? = nil,
    profileSelectedImage: UIImage? = nil
  ) {
    self.selected = selected
    self.profileDefaultImage = profileDefaultImage
    self.profileSelectedImage = profileSelectedImage

    self.rootView = FloatingTabBarView(
      selectedTab: self.selected,
      onSelect: self.onSelect,
      profileDefaultImage: self.profileDefaultImage,
      profileSelectedImage: self.profileSelectedImage
    )
  }
}
