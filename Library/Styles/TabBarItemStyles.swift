import UIKit

public let tabBarDeselectedColor = UIColor.ksr_support_400
public let tabBarSelectedColor = UIColor.ksr_create_700
public let tabBarTintColor = UIColor.ksr_white
public let tabBarAvatarSize = CGSize(width: 25, height: 25)

public typealias TabBarItemStyle = (UITabBarItem) -> UITabBarItem

private let paddingY: CGFloat = 6.0

public let activityTabBarItemStyle: TabBarItemStyle = { button in
  button.title = Strings.tabbar_activity()
  button.image = image(named: "tabbar-icon-activity")
  button.image = image(named: "tabbar-icon-activity-selected")
  button.accessibilityLabel = Strings.tabbar_activity()
  return button
}

public let dashboardTabBarItemStyle: TabBarItemStyle = { button in
  button.title = Strings.tabbar_dashboard()
  button.image = image(named: "tabbar-icon-dashboard")
  button.selectedImage = image(named: "tabbar-icon-dashboard-selected")
  button.accessibilityLabel = Strings.tabbar_dashboard()
  return button
}

public let homeTabBarItemStyle: TabBarItemStyle = { button in
  button.title = Strings.Explore()
  button.image = image(named: "tabbar-icon-home")
  button.selectedImage = image(named: "tabbar-icon-home-selected")
  button.accessibilityLabel = Strings.Explore()
  return button
}

public func profileTabBarItemStyle(isLoggedIn: Bool) -> TabBarItemStyle {
  let imageName = isLoggedIn ? "tabbar-icon-profile-logged-in" : "tabbar-icon-profile-logged-out"
  let accLabel = isLoggedIn ? Strings.tabbar_profile() : Strings.tabbar_login()

  return { button in
    button.title = Strings.tabbar_profile()
    button.image = image(named: imageName)
    button.image = image(named: "tabbar-icon-profile-selected")
    button.accessibilityLabel = accLabel

    return button
  }
}

public let searchTabBarItemStyle: TabBarItemStyle = { button in
  button.title = Strings.tabbar_search()
  button.image = image(named: "tabbar-icon-search")
  button.selectedImage = image(named: "tabbar-icon-search-selected")
  button.accessibilityLabel = Strings.tabbar_search()
  return button
}

public let backingsTabBarItemStyle: TabBarItemStyle = { button in
  button.title = Strings.tabbar_backings()
  button.image = image(named: "tabbar-icon-backings")
  button.selectedImage = image(named: "tabbar-icon-backings-selected")
  button.accessibilityLabel = Strings.tabbar_backings()
  return button
}
