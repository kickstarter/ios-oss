import Prelude
import Prelude_UIKit
import UIKit

public let tabBarDeselectedColor = UIColor.ksr_dark_grey_400
public let tabBarSelectedColor = UIColor.ksr_green_800
public let tabBarTintColor = UIColor.white
public let tabBarAvatarSize = CGSize(width: 25, height: 25)

private let paddingY: CGFloat = 6.0

private let baseTabBarItemStyle = UITabBarItem.lens.title .~ nil

public func activityTabBarItemStyle(isMember: Bool) -> (UITabBarItem) -> UITabBarItem {

  return baseTabBarItemStyle
    <> UITabBarItem.lens.title %~ { _ in Strings.tabbar_activity() }
    <> UITabBarItem.lens.image .~ image(named: "tabbar-icon-activity")
    <> UITabBarItem.lens.selectedImage .~ image(named: "tabbar-icon-activity-selected")
    <> UITabBarItem.lens.accessibilityLabel %~ { _ in Strings.tabbar_activity() }
    <> UITabBarItem.lens.tag .~ 1
}

public let dashboardTabBarItemStyle = baseTabBarItemStyle
  <> UITabBarItem.lens.title %~ { _ in Strings.tabbar_dashboard() }
  <> UITabBarItem.lens.image .~ image(named: "tabbar-icon-dashboard")
  <> UITabBarItem.lens.selectedImage .~ image(named: "tabbar-icon-dashboard-selected")
  <> UITabBarItem.lens.accessibilityLabel %~ { _ in Strings.tabbar_dashboard() }
  <> UITabBarItem.lens.tag .~ 3

public func homeTabBarItemStyle(isMember: Bool) -> (UITabBarItem) -> UITabBarItem {

  return baseTabBarItemStyle
    <> UITabBarItem.lens.title %~ { _ in Strings.Explore() }
    <> UITabBarItem.lens.image .~ image(named: "tabbar-icon-home")
    <> UITabBarItem.lens.selectedImage .~ image(named: "tabbar-icon-home-selected")
    <> UITabBarItem.lens.accessibilityLabel %~ { _ in Strings.Explore() }
    <> UITabBarItem.lens.tag .~ 0
}

public func profileTabBarItemStyle(isLoggedIn: Bool, isMember: Bool) -> (UITabBarItem) -> UITabBarItem {

  let imageName = isLoggedIn ? "tabbar-icon-profile-logged-in" : "tabbar-icon-profile-logged-out"
  let accLabel = isLoggedIn ? Strings.tabbar_profile() : Strings.tabbar_login()

  return baseTabBarItemStyle
    <> UITabBarItem.lens.title %~ { _ in Strings.tabbar_profile() }
    <> UITabBarItem.lens.image .~ image(named: imageName)
    <> UITabBarItem.lens.selectedImage .~ image(named: "tabbar-icon-profile-selected")
    <> UITabBarItem.lens.accessibilityLabel .~ accLabel
    <> UITabBarItem.lens.tag .~ 4
}

public let searchTabBarItemStyle = baseTabBarItemStyle
  <> UITabBarItem.lens.title %~ { _ in Strings.tabbar_search() }
  <> UITabBarItem.lens.image .~ image(named: "tabbar-icon-search")
  <> UITabBarItem.lens.selectedImage .~ image(named: "tabbar-icon-search-selected")
  <> UITabBarItem.lens.accessibilityLabel %~ { _ in Strings.tabbar_search() }
  <> UITabBarItem.lens.tag .~ 2
