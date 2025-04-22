@testable import Kickstarter_Framework
import Library
import SnapshotTesting
import SwiftUI
import XCTest

final class SearchFiltersHeaderViewTests: TestCase {
  func testHeaderView() {
    orthogonalCombos(
      [Device.phone5_5inch, Device.pad],
      [
        ContentSizeCategory.medium,
        ContentSizeCategory.accessibilityExtraExtraExtraLarge
      ]
    ).forEach {
      device, contentSize in
      let size = device.deviceSize(in: .portrait)

      let pills = [
        SearchFilterPill(
          isHighlighted: true,
          filterType: .all,
          buttonType: .image("shortcut-icon-k"),
          count: 42
        ),
        SearchFilterPill(
          isHighlighted: false,
          filterType: .category,
          buttonType: .dropdown("My favorite things")
        ),
        SearchFilterPill(
          isHighlighted: false,
          filterType: .sort,
          buttonType: .image("icon-sort")
        ),
        SearchFilterPill(
          isHighlighted: true,
          filterType: .projectState,
          buttonType: .dropdown("Cool projects"),
          count: 6
        )
      ]

      let view = SearchFiltersHeaderView(didTapPill: { _ in }, pills: pills)
        .environment(\.sizeCategory, contentSize)
        .frame(width: size.width, height: 100)

      assertSnapshot(
        matching: view,
        as: .image,
        named: "lang_en_\(device)_\(contentSize)"
      )
    }
  }
}
