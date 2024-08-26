@testable import Library
import SnapshotTesting
import SwiftUI
import XCTest

final class PagedTabBarTests: TestCase {
  struct FakeTabBarPage: TabBarPage {
    let id = UUID()

    var name: String
    var badgeCount: Int?
  }

  let size = CGSize(width: 375, height: 46)

  func testTabSelection() {
    let viewModel = PagedContainerViewModel<FakeTabBarPage>()
    let firstPage = FakeTabBarPage(name: "First", badgeCount: 1)
    let secondPage = FakeTabBarPage(name: "Second", badgeCount: nil)
    viewModel.configure(with: [
      (firstPage, UIViewController()),
      (secondPage, UIViewController())
    ])
    viewModel.didSelect(page: firstPage)

    let tabs = PagedTabBar(viewModel: viewModel)
      .frame(width: size.width, height: size.height)

    assertSnapshot(matching: tabs, as: .image, named: "firstTab")

    viewModel.didSelect(page: secondPage)

    assertSnapshot(matching: tabs, as: .image, named: "secondTab")
  }

  func testLongName() {
    let viewModel = PagedContainerViewModel<FakeTabBarPage>()
    let firstPage = FakeTabBarPage(name: "really really really really long name", badgeCount: 1)
    let secondPage = FakeTabBarPage(name: "Second", badgeCount: nil)
    viewModel.configure(with: [
      (firstPage, UIViewController()),
      (secondPage, UIViewController())
    ])
    viewModel.didSelect(page: firstPage)

    let tabs = PagedTabBar(viewModel: viewModel)
      .frame(width: size.width, height: size.height)

    assertSnapshot(matching: tabs, as: .image, named: "long name")
  }

  func testLongBadge() {
    let viewModel = PagedContainerViewModel<FakeTabBarPage>()
    let firstPage = FakeTabBarPage(name: "First", badgeCount: Int.max)
    let secondPage = FakeTabBarPage(name: "Second", badgeCount: nil)
    viewModel.configure(with: [
      (firstPage, UIViewController()),
      (secondPage, UIViewController())
    ])
    viewModel.didSelect(page: firstPage)

    let tabs = PagedTabBar(viewModel: viewModel)
      .frame(width: size.width, height: size.height)

    assertSnapshot(matching: tabs, as: .image, named: "long badge")
  }

  func testNoBadges() {
    let viewModel = PagedContainerViewModel<FakeTabBarPage>()
    let firstPage = FakeTabBarPage(name: "First", badgeCount: nil)
    let secondPage = FakeTabBarPage(name: "Second", badgeCount: nil)
    viewModel.configure(with: [
      (firstPage, UIViewController()),
      (secondPage, UIViewController())
    ])
    viewModel.didSelect(page: firstPage)

    let tabs = PagedTabBar(viewModel: viewModel)
      .frame(width: size.width, height: size.height)

    assertSnapshot(matching: tabs, as: .image, named: "no badges")
  }

  func testNoBadgesLongNames() {
    let viewModel = PagedContainerViewModel<FakeTabBarPage>()
    let firstPage = FakeTabBarPage(name: "First really really really really long name", badgeCount: nil)
    let secondPage = FakeTabBarPage(name: "Second really really really really long name", badgeCount: nil)
    viewModel.configure(with: [
      (firstPage, UIViewController()),
      (secondPage, UIViewController())
    ])
    viewModel.didSelect(page: firstPage)

    let tabs = PagedTabBar(viewModel: viewModel)
      .frame(width: size.width, height: size.height)

    assertSnapshot(matching: tabs, as: .image, named: "no badges")
  }
}
