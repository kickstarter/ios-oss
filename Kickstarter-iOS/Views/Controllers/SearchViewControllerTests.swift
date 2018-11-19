import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

internal final class SearchViewContollerTests: TestCase {

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView_defaultState() {
    let project = (1...10).map {
      .cosmicSurgery
        |> Project.lens.id .~ $0
        |> Project.lens.photo.full .~ ""
        |> Project.lens.photo.med .~ ""
        |> Project.lens.stats.goal .~ ($0 * 20)
        |> Project.lens.stats.pledged .~ ($0 * $0 * 4)
    }

    let discoveryResponse = .template
      |> DiscoveryEnvelope.lens.projects .~ project

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad])
      .forEach { language, device in
        withEnvironment(
          apiService: MockService(fetchDiscoveryResponse: discoveryResponse), language: language) {

          let controller = Storyboard.Search.instantiate(SearchViewController.self)
          controller.viewWillAppear(true)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          self.scheduler.run()

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_EmptyState() {
    let discoveryResponse = .template
      |> DiscoveryEnvelope.lens.projects .~ []

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad])
      .forEach { language, device in
        withEnvironment(
        apiService: MockService(fetchDiscoveryResponse: discoveryResponse), language: language) {

          let controller = Storyboard.Search.instantiate(SearchViewController.self)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          controller.viewModel.inputs.searchTextChanged("abcdefgh")

          self.scheduler.run()

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_SearchState() {
    let project = (1...10).map {
      .cosmicSurgery
        |> Project.lens.id .~ $0
        |> Project.lens.photo.full .~ ""
        |> Project.lens.photo.med .~ ""
        |> Project.lens.stats.goal .~ ($0 * 20)
        |> Project.lens.stats.pledged .~ ($0 * $0 * 4)
    }

    let discoveryResponse = .template
      |> DiscoveryEnvelope.lens.projects .~ project

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad])
      .forEach { language, device in
        withEnvironment(
        apiService: MockService(fetchDiscoveryResponse: discoveryResponse), language: language) {

          let controller = Storyboard.Search.instantiate(SearchViewController.self)
          controller.viewWillAppear(true)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          controller.viewModel.inputs.searchTextChanged("abcdefgh")

          self.scheduler.run()

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testScrollToTop() {
    let controller = ActivitiesViewController.instantiate()

    XCTAssertNotNil(controller.view as? UIScrollView)
  }
}
