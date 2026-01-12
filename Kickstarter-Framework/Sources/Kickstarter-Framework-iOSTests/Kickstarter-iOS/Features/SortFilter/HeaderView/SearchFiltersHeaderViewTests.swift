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
      var size = device.deviceSize(in: .portrait)

      let icon1 = Library.image(named: "shortcut-icon-k")!.withRenderingMode(.alwaysTemplate)
      let icon2 = Library.image(named: "icon-sort")!.withRenderingMode(.alwaysTemplate)
      let icon3 = Library.image(named: "icon-pwl")!

      let pills = [
        SearchFilterPill(
          isHighlighted: true,
          filterType: .allFilters,
          buttonType: .image(icon1),
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
          buttonType: .image(icon2)
        ),
        SearchFilterPill(
          isHighlighted: true,
          filterType: .projectState,
          buttonType: .dropdown("Cool projects"),
          count: 6
        ),
        SearchFilterPill(
          isHighlighted: false,
          filterType: .projectsWeLove,
          buttonType: .toggleWithImage("Things I love", icon3)
        ),
        SearchFilterPill(
          isHighlighted: true,
          filterType: .recommended,
          buttonType: .toggle("A toggle")
        )
      ]

      let view = SearchFiltersHeaderView(didTapPill: { _ in }, pills: pills)
        .environment(\.sizeCategory, contentSize)
        // Lots of pills, double the width so we can get more of them.
        .frame(width: size.width * 2, height: 100)

      assertSnapshot(
        matching: view,
        as: .image,
        named: "lang_en_\(device)_\(contentSize)"
      )
    }
  }
}
