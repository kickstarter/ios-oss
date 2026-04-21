@testable import Library
@testable import LibraryTestHelpers
import XCTest

final class StatsigExperimentHelperTests: TestCase {
  func testExperimentValue_IsOverriddenByMockExperimentValues() {
    let experiment = iOSTestExperiment()
    let mockStatsigClient = MockStatsigClient()

    withEnvironment(statsigClient: mockStatsigClient) {
      XCTAssertEqual(experiment.boolValue(forKey: .experiment_parameter_one), nil)
      XCTAssertEqual(experiment.boolValue(forKey: .experiment_parameter_two), nil)
    }

    let mockExperiment = MockExperiment<iOSTestExperiment>(
      [
        .experiment_parameter_one: false,
        .experiment_parameter_two: true
      ]
    )

    mockStatsigClient.overrideExperiment(experiment, withMock: mockExperiment)

    withEnvironment(statsigClient: mockStatsigClient) {
      XCTAssertEqual(experiment.boolValue(forKey: .experiment_parameter_one), false)
      XCTAssertEqual(experiment.boolValue(forKey: .experiment_parameter_two), true)
    }
  }
}
