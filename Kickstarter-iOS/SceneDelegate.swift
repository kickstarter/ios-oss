import Foundation
import KDS
import Kickstarter_Framework
import UIKit

/// Owns the scene's window now that the app has adopted the UIKit scene lifecycle. For now this only
/// wires up enough to satisfy `UIWindowSceneDelegate` and keep the app's launch behavior unchanged.
/// `SceneDelegateViewModel`'s inputs and outputs get connected to real UI actions as the pieces
/// currently handled by `AppDelegate` (URL opens, continued user activities, shortcut items, and the
/// app's foreground / background / active lifecycle) move over in follow-up work.
internal final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  private let viewModel: SceneDelegateViewModelType = SceneDelegateViewModel()

  func scene(
    _ scene: UIScene,
    willConnectTo _: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard scene is UIWindowScene else { return }

    self.window?.tintColor = LegacyColors.ksr_create_700.uiColor()
  }
}
