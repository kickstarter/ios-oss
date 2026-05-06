import AVFoundation
import AVKit
import KDS
import SwiftUI

struct AudioVideoBlock: View {
  enum Content: Sendable {
    case audio(RichTextElement.Audio)
    case video(RichTextElement.Video)
  }

  var content: Content
  @Environment(\.richTextStyle) var style: any RichTextStyle
  @State private var player: AVPlayer?

  private var mediaURL: URL? {
    let raw: String?
    switch self.content {
    case let .audio(a): raw = a.url
    case let .video(v): raw = v.url
    }
    return raw.flatMap { URL(string: $0) }
  }

  private var caption: String? {
    switch self.content {
    case let .audio(a): return a.caption
    case let .video(v): return v.caption
    }
  }

  private var altText: String? {
    switch self.content {
    case let .audio(a): return a.altText
    case let .video(v): return v.altText
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: self.style.blockSpacing / 2) {
      self.playerView
      if let caption = self.caption {
        Text(caption)
          .font(self.style.bodyFont)
          .foregroundStyle(self.style.bodyColor.swiftUIColor())
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .onAppear {
      guard let url = self.mediaURL else { return }
      try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
      self.player = AVPlayer(url: url)
    }
    .onDisappear {
      self.player?.pause()
      self.player = nil
    }
  }

  @ViewBuilder
  private var playerView: some View {
    if let player = self.player {
      VideoPlayer(player: player)
        .aspectRatio(16.0 / 9.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: self.style.mediaCornerRadius))
        .accessibilityLabel(self.altText ?? self.caption ?? "")
        .accessibilityAddTraits(.startsMediaSession)
    } else {
      self.unavailablePlaceholder
    }
  }

  private var unavailablePlaceholder: some View {
    RoundedRectangle(cornerRadius: self.style.mediaCornerRadius)
      .fill(self.style.backgroundColor.swiftUIColor())
      .aspectRatio(16.0 / 9.0, contentMode: .fit)
      .overlay {
        Image(systemName: "video.slash")
          .font(.title)
          .foregroundStyle(self.style.bodyColor.swiftUIColor())
      }
      .accessibilityLabel("Media unavailable")
  }
}
