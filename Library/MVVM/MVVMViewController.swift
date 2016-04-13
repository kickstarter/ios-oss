import func Foundation.dispatch_async
import func Foundation.dispatch_get_main_queue
import class UIKit.UIViewController

/// A UIViewController base class that gives a single point of observing
/// signals, usually exposed by the view model.
///
/// Subclasses should override `bindViewModel`, and do all observations
/// in that method.
public class MVVMViewController: UIViewController {

  public override func viewDidLoad() {
    super.viewDidLoad()
    self.bindViewModel()
  }

  /// All signal observations should happen in here.
  public func bindViewModel() {
  }
}
