@testable import Kickstarter_Framework
import SnapshotTesting
import SwiftUI
import XCTest

final class ButtonStylesSwiftUITests: TestCase {
  func testGreenButton() {
    let view = Button("See all projects") { /* no action */ }
      .buttonStyle(GreenButtonStyle())
      .frame(width: 320, height: 200)
    assertSnapshot(matching: view, as: .image, named: "enabled")

    let disabled = view.disabled(true)
    assertSnapshot(matching: disabled, as: .image, named: "disabled")
  }

  func testRedButton() {
    let view =
      Button(
        "Warning! Something bad happened and for some reason we need very many words to explain that to the user"
      ) {
      /* no action */ }
      .buttonStyle(RedButtonStyle())
      .frame(width: 320, height: 200)
    assertSnapshot(matching: view, as: .image, named: "enabled")

    let disabled = view.disabled(true)
    assertSnapshot(matching: disabled, as: .image, named: "disabled")
  }

  func testBlackButton() {
    let view = Button("OK") { /* no action */ }
      .buttonStyle(BlackButtonStyle())
      .frame(width: 320, height: 200)
    assertSnapshot(matching: view, as: .image, named: "enabled")

    let disabled = view.disabled(true)
    assertSnapshot(matching: disabled, as: .image, named: "disabled")
  }
}
