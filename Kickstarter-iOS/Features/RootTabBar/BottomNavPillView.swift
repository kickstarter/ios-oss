import KDS
import SwiftUI
import UIKit

enum BottomNavPillConstants {
  // Icons
  static let discoveryIcon = "pill-tabbar-icon-home"
  static let searchIcon = "pill-tabbar-icon-search"
  static let profileIcon = "pill-tabbar-icon-profile"

  // Icon Styles
  static let iconFrameSize: CGFloat = 40
  static let profileImageIconFrameSize: CGFloat = 30
  static let selectedIconColor: Color = Colors.Nav.iconColorSelected.swiftUIColor()
  static let unselectedIconColor: Color = Colors.Nav.iconColorUnselected.swiftUIColor()

  // Layout
  static let spacing: CGFloat = 10
  static let horizontalPadding: CGFloat = 8
  static let verticalPadding: CGFloat = 8
  static let bottomPadding: CGFloat = 12
  static let topPadding: CGFloat = 8

  // Background Pill
  static let pillCornerRadius: CGFloat = 16
  static let pillShadowOpacity: Double = 0.15
  static let pillShadowRadius: CGFloat = 28
  static let pillShadowOffsetY: CGFloat = 8
  static let pillBackgroundColor: Color = Colors.Nav.background.swiftUIColor()

  // Selected Tab Indicator
  static let indicatorCornerRadius: CGFloat = 8
  static let indicatorColor: Color = Colors.Nav.iconHighlight.swiftUIColor()

  // Animation
  static let animationResponse: CGFloat = 0.01
  static let animationDamping: CGFloat = 0.5
  static let animationID = "selectedTabIndicator"
}

enum RootTab: Int {
  case discovery = 0
  case search = 1
  case profile = 2
}

// MARK: - Pill View

struct BottomNavPillView: View {
  let selectedTab: RootTab
  let onSelect: (RootTab) -> Void
  let profileDefaultImage: UIImage?
  let profileSelectedImage: UIImage?

  @Namespace private var animation

  var body: some View {
    HStack(spacing: BottomNavPillConstants.spacing) {
      self.pillItem(.discovery, iconImageName: BottomNavPillConstants.discoveryIcon)
      self.pillItem(.search, iconImageName: BottomNavPillConstants.searchIcon)

      // profile uses default / selected avatar images
      self.pillItem(
        .profile,
        iconImageName: BottomNavPillConstants.profileIcon,
        profileImageDefault: self.profileDefaultImage,
        profileImageSelected: self.profileSelectedImage
      )
    }
    .padding(.horizontal, BottomNavPillConstants.horizontalPadding)
    .padding(.vertical, BottomNavPillConstants.verticalPadding)
    .background(
      RoundedRectangle(cornerRadius: BottomNavPillConstants.pillCornerRadius, style: .continuous)
        .fill(BottomNavPillConstants.pillBackgroundColor)
        .shadow(
          color: Color.black.opacity(BottomNavPillConstants.pillShadowOpacity),
          radius: BottomNavPillConstants.pillShadowRadius,
          y: BottomNavPillConstants.pillShadowOffsetY
        )
    )
    .padding(.bottom, BottomNavPillConstants.bottomPadding)
    .padding(.top, BottomNavPillConstants.topPadding)
    .animation(
      .spring(
        response: BottomNavPillConstants.animationResponse,
        dampingFraction: BottomNavPillConstants.animationDamping
      ),
      value: self.selectedTab
    )
  }

  @ViewBuilder
  private func pillItem(
    _ tab: RootTab,
    iconImageName: String,
    profileImageDefault: UIImage? = nil,
    profileImageSelected: UIImage? = nil
  ) -> some View {
    let isSelected = self.selectedTab == tab

    Button {
      self.onSelect(tab)
    } label: {
      ZStack {
        if isSelected {
          RoundedRectangle(
            cornerRadius: BottomNavPillConstants.indicatorCornerRadius,
            style: .continuous
          )
          .fill(BottomNavPillConstants.indicatorColor)
          .matchedGeometryEffect(
            id: BottomNavPillConstants.animationID,
            in: self.animation
          )
          .frame(
            width: BottomNavPillConstants.iconFrameSize,
            height: BottomNavPillConstants.iconFrameSize
          )
        }

        if let profileImage = (isSelected ? profileImageSelected : profileImageDefault) {
          Image(uiImage: profileImage)
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .frame(
              width: BottomNavPillConstants.profileImageIconFrameSize,
              height: BottomNavPillConstants.profileImageIconFrameSize
            )
        } else {
          Image(iconImageName)
            .renderingMode(.template)
            .foregroundColor(
              isSelected
                ? BottomNavPillConstants.selectedIconColor
                : BottomNavPillConstants.unselectedIconColor
            )
            .frame(
              width: BottomNavPillConstants.iconFrameSize,
              height: BottomNavPillConstants.iconFrameSize
            )
        }
      }
      .frame(
        width: BottomNavPillConstants.iconFrameSize,
        height: BottomNavPillConstants.iconFrameSize
      )
    }
    .buttonStyle(.plain)
  }
}

// MARK: - Hosting Controller

final class BottomNavPillHostingController: UIHostingController<BottomNavPillView> {
  private var selected: RootTab
  private let onSelect: (RootTab) -> Void
  private var profileDefaultImage: UIImage?
  private var profileSelectedImage: UIImage?

  init(
    selected: RootTab,
    onSelect: @escaping (RootTab) -> Void,
    profileDefaultImage: UIImage? = nil,
    profileSelectedImage: UIImage? = nil
  ) {
    self.selected = selected
    self.onSelect = onSelect
    self.profileDefaultImage = profileDefaultImage
    self.profileSelectedImage = profileSelectedImage

    let rootView = BottomNavPillView(
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
    selected: RootTab,
    profileDefaultImage: UIImage? = nil,
    profileSelectedImage: UIImage? = nil
  ) {
    self.selected = selected
    self.profileDefaultImage = profileDefaultImage
    self.profileSelectedImage = profileSelectedImage

    self.rootView = BottomNavPillView(
      selectedTab: self.selected,
      onSelect: self.onSelect,
      profileDefaultImage: self.profileDefaultImage,
      profileSelectedImage: self.profileSelectedImage
    )
  }
}
