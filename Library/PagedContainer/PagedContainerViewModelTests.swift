import Combine
@testable import Library
import XCTest

/*
 public protocol PagedContainerViewModelInputs {
   func viewWillAppear()
   func configure(with children: [(Page, UIViewController)])
   func didSelect(page: Page)
 }

 public protocol PagedContainerViewModelOutputs {
   var displayPage: AnyPublisher<(Page, UIViewController), Never> { get }
   var pages: AnyPublisher<[(Page, UIViewController)], Never> { get }
 }
 */
final class PagedContainerViewModelTests: XCTestCase {
  struct FakeTabBarPage: TabBarPage {
    var name: String
    var badgeCount: Int?

    let id = UUID().uuidString
  }

  var subscriptions = Set<AnyCancellable>()

  private func makeViewModel(tabs: [(String, Int?)] = [("Project alerts", 5), ("Activity feed", nil)]) -> PagedContainerViewModel<FakeTabBarPage> {
    let viewModel = PagedContainerViewModel<FakeTabBarPage>()
    viewModel.configure(with: tabs.map({ name, badgeCount in
      (FakeTabBarPage(name: name, badgeCount: badgeCount), UIViewController())
    }))
    return viewModel
  }

  func testEnsureTabSelectedWhenViewAppears() throws {
    let viewModel = makeViewModel()
    var foundPage: FakeTabBarPage? = nil
    let expectation = self.expectation(description: "Waiting for a page to be selected")
    viewModel.displayPage
      .first()
      .sink { (page, _) in
        foundPage = page
        expectation.fulfill()
      }
      .store(in: &subscriptions)

    XCTAssertNil(foundPage)

    viewModel.viewWillAppear()
    self.wait(for: [expectation], timeout: 0.1)
    let page = try XCTUnwrap(foundPage)
    XCTAssertEqual(page.name, "Project alerts")
    XCTAssertEqual(page.badgeCount, 5)
  }

  func testTabSelection() throws {
    let viewModel = makeViewModel(tabs: [])
    let firstPage = FakeTabBarPage(name: "First", badgeCount: 1)
    let secondPage = FakeTabBarPage(name: "Second", badgeCount: nil)
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
    viewModel.displayPage
      .first()
      .sink { (page, _) in
        existingPage = page
        existingExpectation.fulfill()
      }
      .store(in: &subscriptions)

    self.wait(for: [existingExpectation], timeout: 0.1)
    let existing = try XCTUnwrap(existingPage)
    XCTAssertEqual(existing.name, firstPage.name)
    XCTAssertEqual(existing.badgeCount, firstPage.badgeCount)

    viewModel.displayPage
      .dropFirst()
      .first()
      .sink { page, _ in
        selectedPage = page
        selectedExpectation.fulfill()
      }
      .store(in: &subscriptions)

    XCTAssertNil(selectedPage)
    viewModel.didSelect(page: secondPage)
    self.wait(for: [selectedExpectation], timeout: 0.1)
    let selected = try XCTUnwrap(selectedPage)
    XCTAssertEqual(selected.name, secondPage.name)
    XCTAssertEqual(selected.badgeCount, secondPage.badgeCount)
  }
}
