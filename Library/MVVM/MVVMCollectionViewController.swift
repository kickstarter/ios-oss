import func Foundation.dispatch_async
import func Foundation.dispatch_get_main_queue
import class UIKit.UICollectionViewController

/// A UICollectionViewController base class that interfaces nicely with
/// cells of the type MVVMCollectionViewCell.
///
/// Subclasses will be most interested in overriding `bindViewModel`. This
/// is where one should observe signals exposed in the view model.
public class MVVMCollectionViewController: UICollectionViewController {
  private var needsToBind = true

  public override func viewDidLoad() {
    super.viewDidLoad()
    self.bindViewModel()
  }

  /// All signal observations should happen in here.
  public func bindViewModel() {
  }
}
