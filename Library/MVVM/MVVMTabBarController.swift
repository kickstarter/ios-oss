import func Foundation.dispatch_async
import func Foundation.dispatch_get_main_queue
import class UIKit.UITabBarController

/// A UIViewController base class that gives a single point of observing
/// signals, usually exposed by the view model.
///
/// Subclasses should override `bindViewModel`, and do all observations
/// in that method.
public class MVVMTabBarController: UITabBarController {

  public override func viewDidLoad() {
    super.viewDidLoad()
    self.bindViewModel()
  }

  /// All signal observations should happen in here. This method is called
  /// immediately after `viewDidLoad`.
  public func bindViewModel() {
  }
}
