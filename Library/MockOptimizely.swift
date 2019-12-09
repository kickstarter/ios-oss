import Foundation

class MockOptimizely: KSOptimizelyClientType {
  static func variant(for experiment: OptimizelyExperiment.Name) -> String {
    if experiment == OptimizelyExperiment.Name.pledgeCTACopy {
      return "experimental"
    } else {
      return "control"
    }
  }
}
