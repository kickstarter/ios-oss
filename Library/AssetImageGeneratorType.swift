import class Foundation.NSValue
import AVFoundation

public protocol AssetImageGeneratorType {

  init(asset: AVAsset)

  func generateCGImagesAsynchronouslyForTimes(
    requestedTimes: [NSValue],
    completionHandler handler: AVAssetImageGeneratorCompletionHandler)
}

extension AVAssetImageGenerator: AssetImageGeneratorType {
}
