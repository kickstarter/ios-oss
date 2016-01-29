import UIKit

/// A UICollectionViewController base class that interfaces nicely with
/// cells of the type MVVMCollectionViewCell.
///
/// Subclasses will be most interested in overriding `bindViewModel`. This
/// is where one should observe signals exposed in the view model.
public class MVVMCollectionViewController : UICollectionViewController {
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
