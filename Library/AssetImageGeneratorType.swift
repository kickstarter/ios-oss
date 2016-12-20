import class Foundation.NSValue
import AVFoundation

public protocol AssetImageGeneratorType {

  init(asset: AVAsset)

//  func generateCGImagesAsynchronouslyForTimes(
//    _ requestedTimes: [NSValue],
//    completionHandler handler: AVAssetImageGeneratorCompletionHandler)

  func generateCGImagesAsynchronously(
    forTimes requestedTimes: [NSValue],
    completionHandler handler: @escaping AVFoundation.AVAssetImageGeneratorCompletionHandler
  )
}

extension AVAssetImageGenerator: AssetImageGeneratorType {
}
