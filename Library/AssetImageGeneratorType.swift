import class Foundation.NSValue
import AVFoundation

public protocol AssetImageGeneratorType {

  init(asset: AVAsset)

  func generateCGImagesAsynchronously(
    forTimes requestedTimes: [NSValue],
    completionHandler handler: @escaping AVFoundation.AVAssetImageGeneratorCompletionHandler
  )
}

extension AVAssetImageGenerator: AssetImageGeneratorType {
}
