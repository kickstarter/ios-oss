@testable import Kickstarter_Framework
import Library
import SnapshotTesting
import SwiftUI
import XCTest

final class PPOEmptyStateViewTests: TestCase {
  func testEmptyStateView() {
    orthogonalCombos(Language.allLanguages, Device.allCases, Orientation.allCases).forEach {
      language, device, orientation in
      withEnvironment(
        language: language
      ) {
        let size = device.deviceSize(in: orientation)
        let view = PPOEmptyStateView().frame(width: size.width, height: size.height)
        assertSnapshot(
          matching: view,
          as: .image,
          named: "lang_\(language.rawValue)_\(device)_\(orientation)"
        )
      }
    }
  }
}
