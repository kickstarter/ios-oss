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

  public static func ksr_cacheImageWith(_ url: URL,
                                        serializer: CacheSerializer = DefaultCacheSerializer(),
                                        completionHandler: @escaping ((Data)?) -> Void) {
    let prefetcher = ImagePrefetcher(
      resources: [url],
      options: [.scaleFactor(UIScreen.main.scale)]
    ) { cachedImages, failedImages, downloadedImages in
      var urlData: (Data)?

      guard failedImages.isEmpty,
        let image = (cachedImages + downloadedImages).first else {
        completionHandler(urlData)

        return
      }

      ImageCache.default.retrieveImage(
        forKey: image.cacheKey,
        options: [.scaleFactor(UIScreen.main.scale)]
      ) { result in

        switch result {
        case let .success(imageResult):
          if let imageResultImage = imageResult.image,
            let imageResultData = serializer.data(with: imageResultImage, original: nil) {
            urlData = imageResultData
          }

          completionHandler(urlData)
        case .failure:
          completionHandler(urlData)
        }
      }
    }

    prefetcher.start()
  }

  public static func ksr_stopFetchingImages() {
    ImageDownloader.default.cancelAll()
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
