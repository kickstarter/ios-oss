import KDS
import SwiftUI
import UIKit

private enum Constants {
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

enum FloatingTabBarTab: Int {
  case discovery = 0
  case search = 1
  case profile = 2
}

struct FloatingTabBarView: View {
  let selectedTab: FloatingTabBarTab
  let onSelect: (FloatingTabBarTab) -> Void
  let profileDefaultImage: UIImage?
  let profileSelectedImage: UIImage?

  @Namespace private var animation

  var body: some View {
    HStack(spacing: Constants.spacing) {
      self.pillItem(.discovery, iconImageName: Constants.discoveryIcon)
      self.pillItem(.search, iconImageName: Constants.searchIcon)

      // profile uses default / selected avatar images
      self.pillItem(
        .profile,
        iconImageName: Constants.profileIcon,
        profileImageDefault: self.profileDefaultImage,
        profileImageSelected: self.profileSelectedImage
      )
    }
    .padding(.horizontal, Constants.horizontalPadding)
    .padding(.vertical, Constants.verticalPadding)
    .background(
      RoundedRectangle(cornerRadius: Constants.pillCornerRadius, style: .continuous)
        .fill(Constants.pillBackgroundColor)
        .shadow(
          color: Color.black.opacity(Constants.pillShadowOpacity),
          radius: Constants.pillShadowRadius,
          y: Constants.pillShadowOffsetY
        )
    )
    .padding(.bottom, Constants.bottomPadding)
    .padding(.top, Constants.topPadding)
    .animation(
      .spring(
        response: Constants.animationResponse,
        dampingFraction: Constants.animationDamping
      ),
      value: self.selectedTab
    )
  }

  @ViewBuilder
  private func pillItem(
    _ tab: FloatingTabBarTab,
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
            cornerRadius: Constants.indicatorCornerRadius,
            style: .continuous
          )
          .fill(Constants.indicatorColor)
          .matchedGeometryEffect(
            id: Constants.animationID,
            in: self.animation
          )
          .frame(
            width: Constants.iconFrameSize,
            height: Constants.iconFrameSize
          )
        }

        if let profileImage = (isSelected ? profileImageSelected : profileImageDefault) {
          Image(uiImage: profileImage)
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .frame(
              width: Constants.profileImageIconFrameSize,
              height: Constants.profileImageIconFrameSize
            )
        } else {
          Image(iconImageName)
            .renderingMode(.template)
            .foregroundColor(
              isSelected
                ? Constants.selectedIconColor
                : Constants.unselectedIconColor
            )
            .frame(
              width: Constants.iconFrameSize,
              height: Constants.iconFrameSize
            )
        }
      }
      .frame(
        width: Constants.iconFrameSize,
        height: Constants.iconFrameSize
      )
    }
    .buttonStyle(.plain)
  }
}
