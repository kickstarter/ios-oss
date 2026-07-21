import AVKit
@testable import ServerDrivenUI
import ServerDrivenUITestHelpers
import SwiftUI
import ViewInspector
import XCTest

@MainActor
final class AudioVideoBlockTests: XCTestCase {
  // MARK: - Placeholder (no player)

  func testAudioBlockWithoutURL_beforeOnAppear_rendersUnavailablePlaceholder() throws {
    let audio = makeAudio(altText: "Audio alt", caption: "Audio caption", url: nil)
    let view = audioVideoBlock(content: .audio(audio), colorScheme: .light)

    XCTAssertNoThrow(
      try view.inspect().find(viewWithAccessibilityLabel: "Media unavailable"),
      "Expected unavailable placeholder before onAppear when audio URL is nil."
    )
    XCTAssertNoThrow(
      try view.inspect().find(ViewType.Image.self),
      "Expected video.slash system image in unavailable placeholder."
    )
  }

  func testAudioBlockWithEmptyURL_beforeOnAppear_rendersUnavailablePlaceholder() throws {
    let audio = makeAudio(altText: "Audio alt", caption: nil, url: "")
    let view = audioVideoBlock(content: .audio(audio), colorScheme: .light)

    XCTAssertNoThrow(
      try view.inspect().find(viewWithAccessibilityLabel: "Media unavailable"),
      "Expected unavailable placeholder before onAppear when audio URL is empty."
    )
  }

  func testVideoBlockWithoutURL_beforeOnAppear_rendersUnavailablePlaceholder() throws {
    let video = makeVideo(altText: "Video alt", caption: "Video caption", url: nil)
    let view = audioVideoBlock(content: .video(video), colorScheme: .light)

    XCTAssertNoThrow(
      try view.inspect().find(viewWithAccessibilityLabel: "Media unavailable"),
      "Expected unavailable placeholder before onAppear when video URL is nil."
    )
  }

  func testAudioBlockWithoutURL_afterOnAppear_stillRendersUnavailablePlaceholder() throws {
    let audio = makeAudio(altText: "Audio alt", caption: nil, url: nil)

    try inspectAfterAppear(content: .audio(audio), colorScheme: .light) { block in
      XCTAssertNoThrow(
        try block.find(viewWithAccessibilityLabel: "Media unavailable"),
        "Expected unavailable placeholder after onAppear when audio URL is nil."
      )
      XCTAssertThrowsError(
        try findVideoPlayer(on: block),
        "Expected no VideoPlayer when audio URL is nil."
      )
    }
  }

  func testVideoBlockWithEmptyURL_afterOnAppear_stillRendersUnavailablePlaceholder() throws {
    let video = makeVideo(altText: "Video alt", caption: nil, url: "")

    try inspectAfterAppear(content: .video(video), colorScheme: .light) { block in
      XCTAssertNoThrow(
        try block.find(viewWithAccessibilityLabel: "Media unavailable"),
        "Expected unavailable placeholder after onAppear when video URL is empty."
      )
    }
  }

  func testUnavailablePlaceholder_usesSixteenByNineAspectFit() throws {
    let audio = makeAudio(altText: nil, caption: nil, url: nil)
    let view = audioVideoBlock(content: .audio(audio), colorScheme: .light)

    let placeholder = try view.inspect().find(viewWithAccessibilityLabel: "Media unavailable")
    let aspectRatio = try placeholder.aspectRatio()

    XCTAssertEqual(
      aspectRatio.aspectRatio,
      16.0 / 9.0 as CGFloat,
      "Expected unavailable placeholder to use 16:9 aspect ratio."
    )
    XCTAssertEqual(
      aspectRatio.contentMode,
      .fit,
      "Expected unavailable placeholder content mode to be .fit."
    )
  }

  // MARK: - Player (valid URL, after onAppear)

  func testAudioBlockWithValidURL_afterOnAppear_rendersVideoPlayerWithExpectedURL() throws {
    let mediaURL = testMediaURL()
    let audio = makeAudio(
      altText: "Test audio",
      caption: nil,
      url: mediaURL.absoluteString
    )

    try self.inspectAfterAppear(content: .audio(audio), colorScheme: .light) { block in
      let playerView = try findVideoPlayer(on: block)
      let avPlayer = try XCTUnwrap(
        playerView.player(),
        "Expected hosted AudioVideoBlock to configure an AVPlayer."
      )
      let urlAsset = try XCTUnwrap(
        avPlayer.currentItem?.asset as? AVURLAsset,
        "Expected AVPlayer item to use an AVURLAsset."
      )
      XCTAssertEqual(
        urlAsset.url,
        mediaURL,
        "Expected AVPlayer URL to match the audio media URL."
      )
      XCTAssertThrowsError(
        try block.find(viewWithAccessibilityLabel: "Media unavailable"),
        "Expected player view, not unavailable placeholder, after onAppear with valid URL."
      )
    }
  }

  func testAudioBlockWithValidURL_afterOnAppear_hasAccessibilityLabelFromAltText() throws {
    let audio = makeAudio(
      altText: "Test audio",
      caption: "Caption ignored for a11y",
      url: testMediaURL().absoluteString
    )

    try self.inspectAfterAppear(content: .audio(audio), colorScheme: .light) { block in
      XCTAssertEqual(
        try accessibilityLabelString(on: block),
        "Test audio",
        "Expected player accessibility label from altText after onAppear."
      )
    }
  }

  func testVideoBlockWithValidURL_afterOnAppear_hasAccessibilityLabelFromAltText() throws {
    let video = makeVideo(
      altText: "Test video",
      caption: "Caption ignored for a11y",
      url: testMediaURL().absoluteString
    )

    try self.inspectAfterAppear(content: .video(video), colorScheme: .light) { block in
      XCTAssertEqual(
        try accessibilityLabelString(on: block),
        "Test video",
        "Expected player accessibility label from altText after onAppear."
      )
    }
  }

  func testAudioBlockWithValidURL_afterOnAppear_exposesContent() throws {
    let audio = makeAudio(
      altText: "Test audio",
      caption: "Test caption",
      url: testMediaURL().absoluteString
    )

    try self.inspectAfterAppear(content: .audio(audio), colorScheme: .light) { block in
      let exposed = try block.actualView()

      guard case let .audio(content) = exposed.content else {
        XCTFail("Expected AudioVideoBlock content to be .audio.")
        return
      }
      XCTAssertEqual(content.altText, "Test audio")
      XCTAssertEqual(content.caption, "Test caption")
      XCTAssertEqual(content.url, audio.url)
    }
  }

  func testVideoBlockWithValidURL_afterOnAppear_exposesContent() throws {
    let video = makeVideo(
      altText: "Test video",
      caption: "Test caption",
      url: testMediaURL().absoluteString
    )

    try self.inspectAfterAppear(content: .video(video), colorScheme: .light) { block in
      let exposed = try block.actualView()

      guard case let .video(content) = exposed.content else {
        XCTFail("Expected AudioVideoBlock content to be .video.")
        return
      }
      XCTAssertEqual(content.altText, "Test video")
      XCTAssertEqual(content.caption, "Test caption")
      XCTAssertEqual(content.url, video.url)
    }
  }

  func testAudioBlockWithValidURL_afterOnAppear_usesSixteenByNineAspectFit() throws {
    let audio = makeAudio(
      altText: "Test audio",
      caption: nil,
      url: testMediaURL().absoluteString
    )

    try self.inspectAfterAppear(content: .audio(audio), colorScheme: .light) { block in
      let player = try findVideoPlayer(on: block)
      let aspectRatio = try player.aspectRatio()

      XCTAssertEqual(
        aspectRatio.aspectRatio,
        16.0 / 9.0 as CGFloat,
        "Expected player to use 16:9 aspect ratio."
      )
      XCTAssertEqual(
        aspectRatio.contentMode,
        .fit,
        "Expected player content mode to be .fit."
      )
    }
  }

  func testAudioBlockWithValidURL_afterOnDisappear_returnsToUnavailablePlaceholder() throws {
    let audio = makeAudio(
      altText: "Test audio",
      caption: nil,
      url: testMediaURL().absoluteString
    )

    var block = AudioVideoBlock(content: .audio(audio))
    let exp = block.on(\.onAppear) { appeared in
      XCTAssertNoThrow(try findVideoPlayer(on: appeared))
      try appeared.vStack().callOnDisappear()
      XCTAssertNoThrow(
        try appeared.find(viewWithAccessibilityLabel: "Media unavailable"),
        "Expected unavailable placeholder after onDisappear clears the player."
      )
      XCTAssertThrowsError(try findVideoPlayer(on: appeared))
    }

    let view = block
      .environment(\.richTextStyle, richTextStyle(.light))
      .frame(width: 300, height: 200)

    ViewHosting.host(view: view)
    defer { ViewHosting.expel() }
    wait(for: [exp], timeout: 0.5)
  }

  // MARK: - Accessibility label fallback

  func testAudioBlockWithNilAltText_afterOnAppear_usesCaptionForAccessibilityLabel() throws {
    let audio = makeAudio(
      altText: nil,
      caption: "Caption as label",
      url: testMediaURL().absoluteString
    )

    try self.inspectAfterAppear(content: .audio(audio), colorScheme: .light) { block in
      XCTAssertEqual(
        try accessibilityLabelString(on: block),
        "Caption as label",
        "Expected player accessibility label to fall back to caption when altText is nil."
      )
    }
  }

  func testVideoBlockWithNilAltTextAndNilCaption_afterOnAppear_hasEmptyAccessibilityLabel() throws {
    let video = makeVideo(
      altText: nil,
      caption: nil,
      url: testMediaURL().absoluteString
    )

    try self.inspectAfterAppear(content: .video(video), colorScheme: .light) { block in
      XCTAssertEqual(
        try accessibilityLabelString(on: block),
        "",
        "Expected empty accessibility label when altText and caption are nil."
      )
    }
  }

  // MARK: - Caption text

  func testAudioBlockWithCaption_rendersCaptionText() throws {
    let audio = makeAudio(
      altText: "Test audio",
      caption: "Test caption",
      url: testMediaURL().absoluteString
    )

    try self.inspectAfterAppear(content: .audio(audio), colorScheme: .light) { block in
      let captionText = try block.find(text: "Test caption")
      XCTAssertEqual(
        try captionText.string(),
        "Test caption",
        "Expected caption Text below the player."
      )
    }
  }

  func testVideoBlockWithoutCaption_doesNotRenderCaptionText() throws {
    let video = makeVideo(
      altText: "Test video",
      caption: nil,
      url: testMediaURL().absoluteString
    )

    try self.inspectAfterAppear(content: .video(video), colorScheme: .light) { block in
      let texts = block.findAll(ViewType.Text.self)
      XCTAssertTrue(
        texts.isEmpty,
        "Expected no Text views when caption is nil."
      )
    }
  }

  func testAudioBlockWithEmptyCaption_rendersEmptyCaptionText() throws {
    let audio = makeAudio(
      altText: "Test audio",
      caption: "",
      url: testMediaURL().absoluteString
    )

    try self.inspectAfterAppear(content: .audio(audio), colorScheme: .light) { block in
      let captionText = try block.find(text: "")
      XCTAssertEqual(
        try captionText.string(),
        "",
        "Expected empty caption Text when caption is an empty string."
      )
    }
  }

  // MARK: - Color schemes

  func testAudioBlockWithValidURL_lightAndDarkStyles() throws {
    let audio = makeAudio(
      altText: "Styled audio",
      caption: "Styled caption",
      url: testMediaURL().absoluteString
    )

    for colorScheme in [ColorScheme.light, ColorScheme.dark] {
      try self.inspectAfterAppear(content: .audio(audio), colorScheme: colorScheme) { block in
        let exposed = try block.actualView()

        guard case let .audio(content) = exposed.content else {
          XCTFail("Expected .audio content for color scheme \(colorScheme).")
          return
        }
        XCTAssertEqual(
          content.altText,
          "Styled audio",
          "Audio altText should be preserved for color scheme \(colorScheme)."
        )
        XCTAssertEqual(
          try accessibilityLabelString(on: block),
          "Styled audio",
          "Expected player accessibility label for color scheme \(colorScheme)."
        )
        XCTAssertNoThrow(
          try block.find(text: "Styled caption"),
          "Expected caption text for color scheme \(colorScheme)."
        )
      }
    }
  }

  func testVideoBlockWithValidURL_lightAndDarkStyles() throws {
    let video = makeVideo(
      altText: "Styled video",
      caption: "Styled caption",
      url: testMediaURL().absoluteString
    )

    for colorScheme in [ColorScheme.light, ColorScheme.dark] {
      try self.inspectAfterAppear(content: .video(video), colorScheme: colorScheme) { block in
        XCTAssertEqual(
          try accessibilityLabelString(on: block),
          "Styled video",
          "Expected player accessibility label for color scheme \(colorScheme)."
        )
      }
    }
  }

  /// Hosts an `AudioVideoBlock`, waits for its `onAppear`, then runs inspection code.
  /// This helper bridges the asynchronous nature of SwiftUI lifecycle events to a synchronous
  /// test flow using ViewInspector. It hosts the view, waits for `onAppear` via an expectation,
  /// runs the provided inspection closure, and propagates any thrown errors back to the test.
  private func inspectAfterAppear<R>(
    content: AudioVideoBlock.Content,
    colorScheme: ColorScheme,
    _ body: @escaping (InspectableView<ViewType.View<AudioVideoBlock>>) throws -> R
  ) throws -> R {
    var block = AudioVideoBlock(content: content)
    var output: R?
    var failure: Error?

    // Convert the view's onAppear into a test expectation using ViewInspector's `on` helper.
    // When the view appears, run the inspection closure and capture either its output or error.
    let exp = block.on(\.onAppear) { appeared in
      do {
        output = try body(appeared)
      } catch {
        failure = error
      }
    }

    let view = block
      .environment(\.richTextStyle, richTextStyle(colorScheme))
      .frame(width: 300, height: 200)

    // Host the view so that SwiftUI lifecycle events (like onAppear) are triggered.
    ViewHosting.host(view: view)
    defer { ViewHosting.expel() } // Ensure the hosted view is torn down after the test.

    // Block the test until onAppear fires or the timeout elapses.
    wait(for: [exp], timeout: 0.5)

    if let failure {
      throw failure
    }
    return try XCTUnwrap(output, "Expected onAppear inspection to run.")
  }
}

// MARK: - Helpers

private func makeAudio(altText: String?, caption: String?, url: String?) -> RichTextElement.Audio {
  RichTextElement.Audio(
    altText: altText,
    assetID: "audio-asset",
    caption: caption,
    url: url
  )
}

private func makeVideo(altText: String?, caption: String?, url: String?) -> RichTextElement.Video {
  RichTextElement.Video(
    altText: altText,
    assetID: "video-asset",
    caption: caption,
    url: url,
    posterURL: nil,
    formats: []
  )
}

private func testMediaURL() -> URL {
  guard let mediaURL = Bundle.module.url(forResource: "600x400", withExtension: "png") else {
    XCTFail("Expected bundled test resource '600x400.png' to exist in test resources.")
    fatalError("no test media URL")
  }
  return mediaURL
}

@MainActor
@ViewBuilder
private func audioVideoBlock(
  content: AudioVideoBlock.Content,
  colorScheme: ColorScheme
) -> some View {
  AudioVideoBlock(content: content)
    .environment(\.richTextStyle, richTextStyle(colorScheme))
    .frame(width: 300, height: 200)
}

private func richTextStyle(_ colorScheme: ColorScheme) -> any RichTextStyle {
  switch colorScheme {
  case .light:
    return LightRichTextStyle()
  case .dark:
    return DarkRichTextStyle()
  @unknown default:
    assertionFailure()
    return AutomaticRichTextStyle()
  }
}

private func findVideoPlayer(
  on block: InspectableView<ViewType.View<AudioVideoBlock>>
) throws -> InspectableView<ViewType.VideoPlayer> {
  try block.vStack().videoPlayer(0)
}

private func accessibilityLabelString(
  on block: InspectableView<ViewType.View<AudioVideoBlock>>
) throws -> String {
  try findVideoPlayer(on: block).accessibilityLabel().string()
}
