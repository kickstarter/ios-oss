@testable import Library
@testable import LibraryTestHelpers
import SnapshotTesting
import SwiftUI
import XCTest

final class PagedTabBarTests: TestCase {
  struct FakeTabBarPage: TabBarPage {
    let id = UUID()

    var name: String
    var badge: TabBarBadge
  }

  let size = CGSize(width: 375, height: 46)

  func testTabSelection() {
    let viewModel = PagedContainerViewModel<FakeTabBarPage>()
    let firstPage = FakeTabBarPage(name: "First", badge: .count(1))
    let secondPage = FakeTabBarPage(name: "Second", badge: .none)
    viewModel.configure(with: [
      (firstPage, UIViewController()),
      (secondPage, UIViewController())
    ])
    viewModel.didSelect(page: firstPage)

    let tabs = PagedTabBar(viewModel: viewModel)
      .frame(width: self.size.width, height: self.size.height)

    assertSnapshot(
      forSwiftUIView: tabs,
      withType: defaultLightScreenshotType,
      size: self.size,
      testName: "testTabSelection_firstTab"
    )

    viewModel.didSelect(page: secondPage)

    assertSnapshot(
      forSwiftUIView: tabs,
      withType: defaultDarkScreenshotType,
      size: self.size,
      testName: "testTabSelection_secondTab"
    )
  }

  func testSecondTabBadge() {
    let viewModel = PagedContainerViewModel<FakeTabBarPage>()
    let firstPage = FakeTabBarPage(name: "First", badge: .none)
    let secondPage = FakeTabBarPage(name: "Second", badge: .count(2))
    viewModel.configure(with: [
      (firstPage, UIViewController()),
      (secondPage, UIViewController())
    ])
    viewModel.didSelect(page: firstPage)

    let tabs = PagedTabBar(viewModel: viewModel)
      .frame(width: self.size.width, height: self.size.height)

    assertSnapshot(forSwiftUIView: tabs, withType: defaultLightScreenshotType, size: self.size)
  }

  func testThreeTabs() {
    let viewModel = PagedContainerViewModel<FakeTabBarPage>()
    let firstPage = FakeTabBarPage(name: "First", badge: .none)
    let secondPage = FakeTabBarPage(name: "Second", badge: .none)
    let thirdPage = FakeTabBarPage(name: "Third", badge: .none)
    viewModel.configure(with: [
      (firstPage, UIViewController()),
      (secondPage, UIViewController()),
      (thirdPage, UIViewController())
    ])
    viewModel.didSelect(page: firstPage)

    let tabs = PagedTabBar(viewModel: viewModel)
      .frame(width: self.size.width, height: self.size.height)

    assertSnapshot(forSwiftUIView: tabs, withType: defaultDarkScreenshotType, size: self.size)
  }

  func testLongName() {
    let viewModel = PagedContainerViewModel<FakeTabBarPage>()
    let firstPage = FakeTabBarPage(name: "really really really really long name", badge: .count(1))
    let secondPage = FakeTabBarPage(name: "Second", badge: .none)
    viewModel.configure(with: [
      (firstPage, UIViewController()),
      (secondPage, UIViewController())
    ])
    viewModel.didSelect(page: firstPage)

    let tabs = PagedTabBar(viewModel: viewModel)
      .frame(width: self.size.width, height: self.size.height)

    assertSnapshot(forSwiftUIView: tabs, withType: defaultLightScreenshotType, size: self.size)
  }

  func testLongGermanNames() {
    let viewModel = PagedContainerViewModel<FakeTabBarPage>()
    let firstPage = FakeTabBarPage(name: "Freundschaftsbezeigungen", badge: .count(1))
    let secondPage = FakeTabBarPage(name: "Streichholzschächtelchen", badge: .none)
    viewModel.configure(with: [
      (firstPage, UIViewController()),
      (secondPage, UIViewController())
    ])
    viewModel.didSelect(page: firstPage)

    let tabs = PagedTabBar(viewModel: viewModel)
      .frame(width: self.size.width, height: self.size.height)

    assertSnapshot(forSwiftUIView: tabs, withType: defaultDarkScreenshotType, size: self.size)
  }

  func testLongBadge() {
    let viewModel = PagedContainerViewModel<FakeTabBarPage>()
    let firstPage = FakeTabBarPage(name: "First", badge: .count(Int.max))
    let secondPage = FakeTabBarPage(name: "Second", badge: .none)
    viewModel.configure(with: [
      (firstPage, UIViewController()),
      (secondPage, UIViewController())
    ])
    viewModel.didSelect(page: firstPage)

    let tabs = PagedTabBar(viewModel: viewModel)
      .frame(width: self.size.width, height: self.size.height)

    assertSnapshot(forSwiftUIView: tabs, withType: defaultLightScreenshotType, size: self.size)
  }

  func testNoBadges() {
    let viewModel = PagedContainerViewModel<FakeTabBarPage>()
    let firstPage = FakeTabBarPage(name: "First", badge: .none)
    let secondPage = FakeTabBarPage(name: "Second", badge: .none)
    viewModel.configure(with: [
      (firstPage, UIViewController()),
      (secondPage, UIViewController())
    ])
    viewModel.didSelect(page: firstPage)

    let tabs = PagedTabBar(viewModel: viewModel)
      .frame(width: self.size.width, height: self.size.height)

    assertSnapshot(forSwiftUIView: tabs, withType: defaultDarkScreenshotType, size: self.size)
  }

  func testNoBadgesLongNames() {
    let viewModel = PagedContainerViewModel<FakeTabBarPage>()
    let firstPage = FakeTabBarPage(name: "First really really really really long name", badge: .none)
    let secondPage = FakeTabBarPage(name: "Second really really really really long name", badge: .none)
    viewModel.configure(with: [
      (firstPage, UIViewController()),
      (secondPage, UIViewController())
    ])
    viewModel.didSelect(page: firstPage)

    let tabs = PagedTabBar(viewModel: viewModel)
      .frame(width: self.size.width, height: self.size.height)

    assertSnapshot(forSwiftUIView: tabs, withType: defaultLightScreenshotType, size: self.size)
  }

  func testBadgeAndDot() {
    let viewModel = PagedContainerViewModel<FakeTabBarPage>()
    let firstPage = FakeTabBarPage(name: "First", badge: .dot)
    let secondPage = FakeTabBarPage(name: "Second", badge: .count(3))
    viewModel.configure(with: [
      (firstPage, UIViewController()),
      (secondPage, UIViewController())
    ])
    viewModel.didSelect(page: firstPage)

    let tabs = PagedTabBar(viewModel: viewModel)
      .frame(width: self.size.width, height: self.size.height)

    assertSnapshot(forSwiftUIView: tabs, withType: defaultDarkScreenshotType, size: self.size)
  }
}
