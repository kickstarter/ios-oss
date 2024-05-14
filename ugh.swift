import Foundation
import Kingfisher
import KingfisherWebP
import UIKit

extension GIFAnimatedImageView {
  internal func ugh() {
    KingfisherManager.shared.defaultOptions += [
      .processor(WebPProcessor.default),
      .cacheSerializer(WebPSerializer.default)
    ]

    // let source = URL(string: "https://i.kickstarter.com/assets/044/904/189/5369afcd06ac1dbf29fb2f4db08c8222_original.gif?fit=scale-down&origin=ugc&q=92&width=680&sig=DgTpXqs2gx7rIrOwqF1MMpNkn%2BLzONEvhtl9qIHvSwo%3D")!

    // let source = URL(string: "https://i.kickstarter.com/assets/044/711/260/509108686bba3bdffc486b8d7a3bfd50_original.webp?fit=scale-down&origin=ugc&q=92&width=680&sig=iMrNo22vpFaBR9I%2Fi%2BdjnBRr%2Fqn3nNbQ%2FcB5HCkxNws%3D")!

    if let bundleURL = Bundle.main.url(forResource: "ugh", withExtension: "webp"),
       let data = try? Data(contentsOf: bundleURL) {
      let provider = RawImageDataProvider(data: data, cacheKey: "ugh")

      self.kf.setImage(with: provider)
    }

    // TODO: try to set from a download
    /*
     self.kf.setImage(with: source, options: [.preloadAllAnimationData]) { (result: Result<RetrieveImageResult, KingfisherError>) -> Void in
       switch result {
       case let .success(image):
         let data = image.data()
         if let source = CGImageSourceCreateWithData(data! as CFData, nil) {
           let count = CGImageSourceGetCount(source)
           print("I got \(count) frames") //WHY IS THIS 1???? IT SHOUDL BE MANY????
         }
         break
       case .failure:
         break
       }
           }
      */
  }
}
