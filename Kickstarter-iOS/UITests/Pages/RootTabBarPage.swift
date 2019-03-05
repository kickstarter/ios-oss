import XCTest
import UIKit

final class RootTabBarPage: BaseTest {

  private lazy var tabBar: XCUIElement = findAll(XCUIElement.ElementType.tabBar).firstMatch

  func tapActivity() -> RootTabBarPage {
    let activityButton = self.tabBar
      .buttons
      .matching(identifier: AccessibilityIdentifier.RootTabBar.activity.rawValue)
      .element
    wait(for: activityButton)
    activityButton.tap()
    return self
  }

  func tapSearch() -> SearchPage {
    let searchButton = self.tabBar
      .buttons
      .matching(identifier: AccessibilityIdentifier.RootTabBar.search.rawValue)
      .element
    wait(for: searchButton)
    searchButton.tap()
    return SearchPage()
  }

  func tapProfile() -> RootTabBarPage {
    let profileButton = self.tabBar
      .buttons
      .matching(identifier: AccessibilityIdentifier.RootTabBar.profile.rawValue)
      .element
    wait(for: profileButton)
    profileButton.tap()
    return self
  }

  func tapExplore() -> RootTabBarPage {
    let exploreButton = self.tabBar
      .buttons
      .matching(identifier: AccessibilityIdentifier.RootTabBar.explore.rawValue)
      .element
    wait(for: exploreButton)
    exploreButton.tap()
    return self
  }
}
