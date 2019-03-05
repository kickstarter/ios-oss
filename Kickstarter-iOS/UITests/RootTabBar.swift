import XCTest
import UIKit

final class RootTabBar: BaseTest {

  override init() {
    super.init()
  }

  private lazy var tabBar: XCUIElement = self.app.tabBars["root_tabBar"]

  func tapActivity() -> RootTabBar {
    let activityButton = self.tabBar.children(matching: XCUIElement.ElementType.button)
      .allElementsBoundByAccessibilityElement
      .filter {
        $0.identifier == "tabBar_activity"
      }.first
    activityButton?.tap()
    return self
  }

  func tapSearch() -> RootTabBar {
    let activityButton = self.tabBar.children(matching: XCUIElement.ElementType.button)
      .allElementsBoundByAccessibilityElement
      .filter {
        $0.identifier == "tabBar_search"
      }.first
    activityButton?.tap()
    return self
  }

  func tapProfile() -> RootTabBar {
    let activityButton = self.tabBar.children(matching: XCUIElement.ElementType.button)
      .allElementsBoundByAccessibilityElement
      .filter {
        $0.identifier == "tabBar_profile"
      }.first
    activityButton?.tap()
    return self
  }

  func tapExplore() -> RootTabBar {
    let activityButton = self.tabBar.children(matching: XCUIElement.ElementType.button)
      .allElementsBoundByAccessibilityElement
      .filter {
        $0.identifier == "tabBar_home"
      }.first
    activityButton?.tap()
    return self
  }
}
