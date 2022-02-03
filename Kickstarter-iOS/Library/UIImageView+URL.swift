import AlamofireImage
import Kingfisher
import ReactiveExtensions
import ReactiveSwift
import UIKit

extension UIImageView {
  public func ksr_setImageWithURL(
    _ url: URL,
    placeholderImage: UIImage? = nil
  ) {
    self.af.setImage(
      withURL: url,
      placeholderImage: placeholderImage,
      filter: nil,
      progress: nil,
      progressQueue: DispatchQueue.main,
      imageTransition: .crossDissolve(0.3),
      runImageTransitionIfCached: false,
      completion: nil
    )
  }

  public func ksr_setRoundedImageWith(_ url: URL) {
    self.af.setImage(
      withURL: url,
      placeholderImage: nil,
      filter: CircleFilter(),
      progress: nil,
      progressQueue: DispatchQueue.main,
      imageTransition: .crossDissolve(0.3),
      runImageTransitionIfCached: false,
      completion: nil
    )
  }

  public func ksr_cacheImageWith(_ url: URL) {
    let optionsInfo: KingfisherOptionsInfo = [.scaleFactor(UIScreen.main.scale)]

    _ = KingfisherManager.shared.retrieveImage(
      with: url,
      options: optionsInfo,
      completionHandler: nil
    )
  }

  public func ksr_setImageWith(_ url: URL) {
    let optionsInfo: KingfisherOptionsInfo = [.scaleFactor(UIScreen.main.scale)]

    _ = KingfisherManager.shared.retrieveImage(
      with: url,
      options: optionsInfo,
      completionHandler: { [weak self] result in
        switch result {
        case let .success(imageResult):
          self?.image = imageResult.image
        case .failure:
          self?.image = nil
        }
      }
    )
  }
}

private enum Associations {
  fileprivate static var ksr_imageUrl = 0
}

extension Rac where Object: UIImageView {
  public var ksr_imageUrl: Signal<URL?, Never> {
    nonmutating set {
      let prop: MutableProperty<URL?> = lazyMutableProperty(
        object,
        key: &Associations.ksr_imageUrl,
        setter: { [weak object] url in
          object?.af.cancelImageRequest()
          object?.image = nil
          guard let url = url else { return }
          object?.ksr_setImageWithURL(url)
        },
        getter: { nil }
      )

      prop <~ newValue.observeForUI()
    }

    get {
      .empty
    }
  }
}
