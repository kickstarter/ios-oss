import XCTest
import UIKit

final class RootTabBar: BaseTest {

  private lazy var tabBar: XCUIElement = findAll(XCUIElement.ElementType.tabBar).firstMatch

  func tapActivity() -> RootTabBar {
    let activityButton = self.tabBar.buttons.matching(identifier: "tabBar_activity").element
    wait(for: activityButton, timeout: 5)
    activityButton.tap()
    return self
  }

  func tapSearch() -> RootTabBar {
    let activityButton = self.tabBar.buttons.matching(identifier: "tabBar_search").element
    wait(for: activityButton, timeout: 5)
    activityButton.tap()
    return self
  }

  func tapProfile() -> RootTabBar {
    let activityButton = self.tabBar.buttons.matching(identifier: "tabBar_profile").element
    wait(for: activityButton, timeout: 5)
    activityButton.tap()
    return self
  }

  func tapExplore() -> RootTabBar {
    let activityButton = self.tabBar.buttons.matching(identifier: "tabBar_home").element
    wait(for: activityButton, timeout: 5)
    activityButton.tap()
    return self
  }
}
