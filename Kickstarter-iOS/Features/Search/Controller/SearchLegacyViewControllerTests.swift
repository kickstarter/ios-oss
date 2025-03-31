@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import SnapshotTesting
import XCTest

internal final class SearchLegacyViewContollerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
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

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad])
      .forEach { language, device in
        withEnvironment(
          apiService: MockService(fetchDiscoveryResponse: discoveryResponse), language: language
        ) {
          let controller = Storyboard.SearchLegacy.instantiate(SearchLegacyViewController.self)
          controller.viewWillAppear(true)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          self.scheduler.run()

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.98),
            named: "lang_\(language)_device_\(device)"
          )
        }
      }
  }

  func testView_EmptyState() {
    let discoveryResponse = .template
      |> DiscoveryEnvelope.lens.projects .~ []

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad])
      .forEach { language, device in
        withEnvironment(
          apiService: MockService(fetchDiscoveryResponse: discoveryResponse), language: language
        ) {
          let controller = Storyboard.SearchLegacy.instantiate(SearchLegacyViewController.self)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          controller.viewModel.inputs.searchTextChanged("abcdefgh")

          self.scheduler.run()

          assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
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

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad])
      .forEach { language, device in
        withEnvironment(
          apiService: MockService(fetchDiscoveryResponse: discoveryResponse), language: language
        ) {
          let controller = Storyboard.SearchLegacy.instantiate(SearchLegacyViewController.self)
          controller.viewWillAppear(true)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          controller.viewModel.inputs.searchTextChanged("abcdefgh")

          self.scheduler.run()

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.98),
            named: "lang_\(language)_device_\(device)"
          )
        }
      }
  }

  func testView_PrelaunchProject_InSearch_Success() {
    let project = (1...10).map {
      .cosmicSurgery
        |> Project.lens.id .~ $0
        |> Project.lens.photo.full .~ ""
        |> Project.lens.photo.med .~ ""
        |> Project.lens.displayPrelaunch .~ true
        |> Project.lens.prelaunchActivated .~ true
    }

    let discoveryResponse = .template
      |> DiscoveryEnvelope.lens.projects .~ project

    orthogonalCombos(Language.allLanguages, [Device.phone5_8inch, Device.pad])
      .forEach { language, device in
        withEnvironment(
          apiService: MockService(fetchDiscoveryResponse: discoveryResponse), language: language
        ) {
          let controller = Storyboard.SearchLegacy.instantiate(SearchLegacyViewController.self)
          controller.viewWillAppear(true)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          controller.viewModel.inputs.searchTextChanged("abcdefgh")

          self.scheduler.run()

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.98),
            named: "lang_\(language)_device_\(device)"
          )
        }
      }
  }

  func testScrollToTop() {
    let controller = ActivitiesViewController.instantiate()

    XCTAssertNotNil(controller.view as? UIScrollView)
  }
}
