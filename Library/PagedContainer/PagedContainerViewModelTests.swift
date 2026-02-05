import Combine
@testable import Library
import XCTest

final class PagedContainerViewModelTests: XCTestCase {
  struct FakeTabBarPage: TabBarPage {
    var name: String
    var badge: TabBarBadge

    let id = UUID().uuidString
  }

  var subscriptions = Set<AnyCancellable>()

  private func makeViewModel(tabs: [(String, Int?)] = [("Project alerts", 5), ("Activity feed", nil)])
    -> PagedContainerViewModel<FakeTabBarPage> {
    let viewModel = PagedContainerViewModel<FakeTabBarPage>()
    viewModel.configure(with: tabs.map { name, badgeCount in
      let badge: TabBarBadge = badgeCount.map { .count($0) } ?? .none
      return (FakeTabBarPage(name: name, badge: badge), UIViewController())
    })
    return viewModel
  }

  func testEnsureTabSelectedWhenViewAppears() throws {
    let viewModel = self.makeViewModel()
    var foundPage: FakeTabBarPage? = nil
    let expectation = self.expectation(description: "Waiting for a page to be selected")
    viewModel.$displayPage
      .compactMap { $0 }
      .first()
      .sink { page, _ in
        foundPage = page
        expectation.fulfill()
      }
      .store(in: &self.subscriptions)

    XCTAssertNil(foundPage)

    viewModel.viewWillAppear()
    self.wait(for: [expectation], timeout: 0.1)
    let page = try XCTUnwrap(foundPage)
    XCTAssertEqual(page.name, "Project alerts")
    XCTAssertEqual(page.badge.count, 5)
  }

  func testTabSelection() throws {
    let viewModel = self.makeViewModel(tabs: [])
    let firstPage = FakeTabBarPage(name: "First", badge: .count(1))
    let secondPage = FakeTabBarPage(name: "Second", badge: .none)
    viewModel.configure(with: [
      (firstPage, UIViewController()),
      (secondPage, UIViewController())
    ])
    viewModel.viewWillAppear()

    var existingPage: FakeTabBarPage? = nil
    var selectedPage: FakeTabBarPage? = nil

    let existingExpectation = self.expectation(description: "Existing tab")
    let selectedExpectation = self.expectation(description: "Selected tab")

    // the currently selected tab should be first page
    viewModel.$displayPage
      .compactMap { $0 }
      .first()
      .sink { page, _ in
        existingPage = page
        existingExpectation.fulfill()
      }
      .store(in: &self.subscriptions)

    self.wait(for: [existingExpectation], timeout: 0.1)
    let existing = try XCTUnwrap(existingPage)
    XCTAssertEqual(existing.name, firstPage.name)
    XCTAssertEqual(existing.badge.count, firstPage.badge.count)

    viewModel.$displayPage
      .compactMap { $0 }
      .dropFirst()
      .first()
      .sink { page, _ in
        selectedPage = page
        selectedExpectation.fulfill()
      }
      .store(in: &self.subscriptions)

    XCTAssertNil(selectedPage)
    viewModel.didSelect(page: secondPage)
    self.wait(for: [selectedExpectation], timeout: 0.1)
    let selected = try XCTUnwrap(selectedPage)
    XCTAssertEqual(selected.name, secondPage.name)
    XCTAssertEqual(selected.badge.count, secondPage.badge.count)
  }
}
