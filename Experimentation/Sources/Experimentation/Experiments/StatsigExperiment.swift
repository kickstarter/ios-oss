/// Statsig uses string-based keys for layers, experiment names, and values.
/// This protocol lets use declare our own strongly-typed Statsig experiments.
/// Here's an example of an experiment implementing `StatsigExperiment`:
/// ```swift
/// struct ExampleExperiment: StatsigExperimentProtocol {
///  typealias Parameters = ExampleExperiment.Parameters
///  enum Parameters: String {
///   case parameter_one
///   case parameter_two
///   case parameter_three
///  }
///  var name: StatsigExperimentName {
///   return .example_experiment
///  }
/// }
/// ```
/// The experiment can then be used like:
/// ```swift
/// let experiment = ExampleExperiment()
/// experiment.boolValue(forKey: .parameter_two)
/// ```

public protocol StatsigExperimentProtocol<Parameters> {
  /// Every experiment should be associated with some experimental parameters.
  /// Those parameters should be defined as an `enum`, like `enum FooParameters: String, CaseIterable`
  associatedtype Parameters: Hashable, CaseIterable, RawRepresentable where Parameters.RawValue == String

  /// The name of the experiment (in Statsig)
  var name: StatsigExperimentName { get }
}

/// The names of our Statsig experiments.
/// Maps directly to the experiment name in the Statsig console.
public enum StatsigExperimentName: String, CaseIterable {
  case ios_test_experiment
  case fullscreen_checkout_experience_experiment
}
