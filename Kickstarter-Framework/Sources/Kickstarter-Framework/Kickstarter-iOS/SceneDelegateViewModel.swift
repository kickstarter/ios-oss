public protocol SceneDelegateViewModelInputs {}

public protocol SceneDelegateViewModelOutputs {}

public protocol SceneDelegateViewModelType {
  var inputs: SceneDelegateViewModelInputs { get }
  var outputs: SceneDelegateViewModelOutputs { get }
}

/// Handles everything that arrives through a `UIWindowScene`'s delegate: URL opens, continued user
/// activities (universal links / Handoff), shortcut-item invocations, and the scene's foreground /
/// background / active lifecycle. This is the SceneDelegate's counterpart to `AppDelegateViewModel`,
/// which instead handles push-notification and Braze deep links.
///
/// Empty for now — inputs and outputs get added as each piece of that responsibility moves over from
/// `AppDelegate` in follow-up work.
public final class SceneDelegateViewModel: SceneDelegateViewModelType, SceneDelegateViewModelInputs,
  SceneDelegateViewModelOutputs {
  public init() {}

  public var inputs: SceneDelegateViewModelInputs { return self }
  public var outputs: SceneDelegateViewModelOutputs { return self }
}
