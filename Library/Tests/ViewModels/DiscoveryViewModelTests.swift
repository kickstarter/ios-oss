import XCTest
import UIKit
@testable import ReactiveExtensions_TestHelpers
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import Library
import Prelude
import ReactiveCocoa
import Result

final class DiscoveryViewModelTests: TestCase {
  let vm: DiscoveryViewModelType = DiscoveryViewModel()

  let hasAddedProjects = TestObserver<Bool, NoError>()
  let hasRemovedProjects = TestObserver<Bool, NoError>()
  let projectsAreLoading = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.projects
      .map { $0.count }
      .combinePrevious(0)
      .map { prev, next in next > prev }
      .observe(self.hasAddedProjects.observer)
    self.vm.outputs.projects
      .map { $0.count }
      .combinePrevious(0)
      .map { prev, next in next < prev }
      .observe(self.hasRemovedProjects.observer)
    self.vm.outputs.projectsAreLoading.observe(self.projectsAreLoading.observer)
  }

  func testPaginating() {
    withEnvironment(apiDelayInterval: 0.0) {

      self.vm.inputs.viewDidLoad()

      self.hasAddedProjects.assertDidNotEmitValue("No projects load at first.")
      self.hasRemovedProjects.assertDidNotEmitValue("No projects load at first.")

      // Advance scheduler so that API returns results
      self.scheduler.advance()

      self.hasAddedProjects.assertValues([true], "Projects are added.")
      self.hasRemovedProjects.assertValues([false], "Projects are not removed.")
      self.projectsAreLoading.assertValues([true, false], "Loading indicator toggles on/off.")

      // Scroll down a bit and advance scheduler
      self.vm.inputs.willDisplayRow(2, outOf: 10)
      self.scheduler.advance()

      self.hasAddedProjects.assertValues([true], "No projects are added.")
      self.hasRemovedProjects.assertValues([false], "No projects are removed.")

      // Scroll down to the bottom of the view and advanced scheduler
      self.vm.inputs.willDisplayRow(9, outOf: 10)
      self.scheduler.advance()

      self.hasAddedProjects.assertValues([true, true], "More projects are added from pagination.")
      self.hasRemovedProjects.assertValues([false, false], "No projects are removed.")
      self.projectsAreLoading.assertValues([true, false, true, false], "Loading indicator toggles on/off.")

      // Make scroll area increase in size, advanced scheduler
      self.vm.inputs.willDisplayRow(9, outOf: 20)
      self.scheduler.advance()

      self.hasAddedProjects.assertValues([true, true], "No projects are added.")
      self.hasRemovedProjects.assertValues([false, false], "No projects are removed.")

      // Change the filter params used
      self.vm.inputs.filterParamsChanged(
        DiscoveryParams.defaults |> DiscoveryParams.lens.category .~ Category.art
      )

      self.hasAddedProjects.assertValues([true, true, false], "No projects are added.")
      self.hasRemovedProjects.assertValues([false, false, true], "Projects are removed right away.")

      // Advance scheduler so that the API request is made
      self.scheduler.advance()

      self.hasAddedProjects.assertValues([true, true, false, true], "Projects are added.")
      self.hasRemovedProjects.assertValues([false, false, true, false], "Projects are not removed.")
      self.projectsAreLoading.assertValues([true, false, true, false, true, false],
                                           "Loading indicator toggles on/off.")

      // Change the sort used and advanced the scheduler so that the API request is made
      self.vm.inputs.sortChanged(.Popular)
      self.scheduler.advance()

      self.hasAddedProjects.assertValues([true, true, false, true, false, true],
                                         "Projects are added.")
      self.hasRemovedProjects.assertValues([false, false, true, false, true, false],
                                            "Projects are not removed.")
      self.projectsAreLoading.assertValues([true, false, true, false, true, false, true, false],
                                           "Loading indicator toggles on/off.")

      // Scroll to the end of the list and advance the scheduler.
      self.vm.inputs.willDisplayRow(18, outOf: 20)
      self.vm.inputs.willDisplayRow(19, outOf: 20)
      self.vm.inputs.willDisplayRow(20, outOf: 20)
      self.scheduler.advance()

      self.hasAddedProjects.assertValues([true, true, false, true, false, true, true],
                                         "Projects are added.")
      self.hasRemovedProjects.assertValues([false, false, true, false, true, false, false],
                                           "Projects are not removed.")
      self.projectsAreLoading.assertValues([true, false, true, false, true, false, true, false, true, false],
                                           "Loading indicator toggles on/off.")
    }
  }
}
