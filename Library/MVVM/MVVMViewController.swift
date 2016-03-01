import UIKit

/// A UIViewController base class that gives a single point of observing
/// signals, usually exposed by the view model.
///
/// Subclasses should override `bindViewModel`, and do all observations
/// in that method.
public class MVVMViewController : UIViewController {
  private var needsToBind = true

  public override func viewDidLoad() {
    super.viewDidLoad()

    if needsToBind {
      // guarantee that `bindViewModel` is called after `viewDidLoad`
      dispatch_async(dispatch_get_main_queue()) {
        self.bindViewModel()
      }
      needsToBind = false
    }
  }

  /// All signal observations should happen in here. This method is called
  /// immediately after `viewDidLoad`.
  public func bindViewModel() {
  }
}
