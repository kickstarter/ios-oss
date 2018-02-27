import AlamofireImage
import ReactiveExtensions
import ReactiveSwift
import Result
import UIKit

extension UIImageView {

  public func ksr_setImageWithURL(_ url: URL) {

    self.af_setImage(withURL: url,
                     placeholderImage: nil,
                     filter: nil,
                     progress: nil,
                     progressQueue: DispatchQueue.main,
                     imageTransition: .crossDissolve(0.3),
                     runImageTransitionIfCached: false,
                     completion: nil)
  }
}

private enum Associations {
  fileprivate static var imageUrl = 0
}

extension Rac where Object: UIImageView {
  public var imageUrl: Signal<URL?, NoError> {
    nonmutating set {
      let prop: MutableProperty<URL?> = lazyMutableProperty(
        object,
        key: &Associations.imageUrl,
        setter: { [weak object] url in
          object?.af_cancelImageRequest()
          object?.image = nil
          guard let url = url else { return }
          object?.ksr_setImageWithURL(url)
        },
        getter: { nil })

      prop <~ newValue.observeForUI()
    }

    get {
      return .empty
    }
  }
}
