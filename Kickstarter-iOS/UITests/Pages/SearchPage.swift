import XCTest
import UIKit

final class SearchPage: BaseTest {

  private lazy var searchTextField: XCUIElement = {
    let textField = findAll(XCUIElement.ElementType.textField)
      .matching(identifier: AccessibilityIdentifier.Search.textField.rawValue)
      .element
    wait(for: textField, timeout: 15)
    return textField
  }()

  private lazy var tableView: XCUIElement = {
    let tableView = findAll(XCUIElement.ElementType.table)
      .matching(identifier: AccessibilityIdentifier.Search.tableView.rawValue)
      .element
    wait(for: tableView, timeout: 15)
    return tableView
  }()

  private lazy var cancelButton: XCUIElement = {
    let cancelButton = findAll(XCUIElement.ElementType.button)
      .matching(identifier: AccessibilityIdentifier.Search.cancelButton.rawValue)
      .element
    wait(for: cancelButton, timeout: 15)
    return cancelButton
  }()

  func search(for text: String) -> SearchPage {
    self.searchTextField.tap()
    self.searchTextField.typeText(text)
    return self
  }

  func scrollTableView() -> SearchPage {
    let lastCell = self.tableView.cells.element(boundBy: 5)
    wait(for: lastCell, timeout: 15)
    self.tableView.scrollTo(element: lastCell)
    return self
  }

  func tapCancelButton() -> RootTabBarPage {
    self.cancelButton.tap()
    return RootTabBarPage()
  }
}

extension XCUIElement {
  func scrollTo(element: XCUIElement) {
    while !element.visible() {
      swipeUp()
    }
  }

  func visible() -> Bool {
    guard self.exists && !self.frame.isEmpty else { return false }
    return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
  }
}
