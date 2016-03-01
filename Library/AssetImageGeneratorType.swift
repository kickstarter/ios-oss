import AVFoundation

internal protocol AssetImageGeneratorType {

  init(asset: AVAsset)

  func generateCGImagesAsynchronouslyForTimes(requestedTimes: [NSValue], completionHandler handler: AVAssetImageGeneratorCompletionHandler)
}

extension AVAssetImageGenerator : AssetImageGeneratorType {
}
