import class UIKit.UICollectionViewController
import struct Library.Environment
import struct Library.AppEnvironment

final internal class DiscoveryViewController: UICollectionViewController {

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    AppEnvironment.current.koala.trackDiscovery()
  }
}
