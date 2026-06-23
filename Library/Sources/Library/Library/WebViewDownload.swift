import Foundation
import ReactiveSwift
import WebKit

/// Wraps a `WKDownload` handed to us by a `WKWebView`, owning the download's
/// lifecycle and surfacing its state as reactive events.
///
/// The wrapper makes itself the download's delegate and writes the downloaded
/// file to a unique subdirectory of the system temporary directory, so that
/// concurrent downloads (or downloads that share a suggested filename) never
/// collide on disk.
///
/// `WKDownload` only holds its delegate weakly, so whoever creates a
/// `WebViewDownload` must retain it until it has emitted a terminal event on
/// either `completed` or `failed`.
public final class WebViewDownload: NSObject {
  /// Emits the download's completion fraction (`0...1`) as it progresses.
  public let progress: Signal<Double, Never>

  /// Emits the on-disk location of the downloaded file once it finishes.
  public let completed: Signal<URL, Never>

  /// Emits if the download fails at any point.
  public let failed: Signal<Error, Never>

  private let progressObserver: Signal<Double, Never>.Observer
  private let completedObserver: Signal<URL, Never>.Observer
  private let failedObserver: Signal<Error, Never>.Observer

  private let download: WKDownload
  private var destinationURL: URL?
  private var progressObservation: NSKeyValueObservation?

  public init(download: WKDownload) {
    self.download = download

    (self.progress, self.progressObserver) = Signal<Double, Never>.pipe()
    (self.completed, self.completedObserver) = Signal<URL, Never>.pipe()
    (self.failed, self.failedObserver) = Signal<Error, Never>.pipe()

    super.init()

    self.download.delegate = self

    self.progressObservation = download.progress
      .observe(\.fractionCompleted, options: [.initial, .new]) { [weak self] progress, _ in
        self?.progressObserver.send(value: progress.fractionCompleted)
      }
  }

  deinit {
    self.progressObservation?.invalidate()

    // Tear down any observers that are still alive if the download was never
    // allowed to terminate (e.g. the wrapper was released early).
    self.progressObserver.sendCompleted()
    self.completedObserver.sendCompleted()
    self.failedObserver.sendCompleted()
  }
}

extension WebViewDownload: WKDownloadDelegate {
  public func download(
    _: WKDownload,
    decideDestinationUsing _: URLResponse,
    suggestedFilename: String,
    completionHandler: @escaping (URL?) -> Void
  ) {
    // Place the file in a fresh, randomly named subdirectory so that the
    // server's suggested filename is preserved without risking collisions.
    let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
      .appendingPathComponent(UUID().uuidString, isDirectory: true)

    do {
      try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    } catch {
      self.failedObserver.send(value: error)
      completionHandler(nil)
      return
    }

    let filename = suggestedFilename.isEmpty ? "File" : suggestedFilename
    let destination = directory.appendingPathComponent(filename)
    self.destinationURL = destination

    completionHandler(destination)
  }

  public func download(_: WKDownload, didFailWithError error: Error, resumeData _: Data?) {
    self.failedObserver.send(value: error)
  }

  public func downloadDidFinish(_: WKDownload) {
    guard let destinationURL = self.destinationURL else { return }

    self.completedObserver.send(value: destinationURL)
  }
}
