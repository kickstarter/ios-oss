@testable import LibraryTestHelpers
@testable import ServerDrivenUI
import ServerDrivenUITestHelpers
import SwiftUI
import ViewInspector
import WebKit
import XCTest

@MainActor
final class OEmbedBlockTests: TestCase {
  // MARK: - Valid iframe URL

  func testOEmbedBlockWithValidIframeURL_hasAccessibilityLabel() throws {
    let oembed = makeOembed(
      title: "YouTube Video",
      iframeUrl: "https://www.youtube.com/embed/dQw4w9WgXcQ"
    )

    let view = oembedBlock(oembed: oembed, colorScheme: .light)

    XCTAssertNoThrow(
      try view.inspect().find(viewWithAccessibilityLabel: "YouTube Video"),
      "Expected OEmbedBlock to expose accessibility label from title when iframe URL is valid."
    )
  }

  func testOEmbedBlockWithValidIframeURL_exposesOembed() throws {
    let oembed = makeOembed(
      title: "YouTube Video",
      iframeUrl: "https://www.youtube.com/embed/dQw4w9WgXcQ"
    )

    let view = oembedBlock(oembed: oembed, colorScheme: .light)
    let block = try view.inspect().find(OEmbedBlock.self).actualView()

    XCTAssertEqual(
      block.oembed.title,
      "YouTube Video",
      "OEmbedBlock.oembed.title should equal the provided title."
    )
    XCTAssertEqual(
      block.oembed.iframeUrl,
      "https://www.youtube.com/embed/dQw4w9WgXcQ",
      "OEmbedBlock.oembed.iframeUrl should equal the provided iframe URL."
    )
  }

  // MARK: - Missing iframe URL

  func testOEmbedBlockWithNilIframeURL_rendersNothing() throws {
    let oembed = makeOembed(title: "Missing Embed", iframeUrl: nil)

    let block = OEmbedBlock(oembed: oembed)

    XCTAssertNil(
      block.iframeURL,
      "Expected iframeURL to be nil when iframe URL string is nil."
    )
  }

  func testOEmbedBlockWithEmptyIframeURL_rendersNothing() throws {
    let oembed = makeOembed(title: "Missing Embed", iframeUrl: "")

    let block = OEmbedBlock(oembed: oembed)

    XCTAssertNil(
      block.iframeURL,
      "Expected iframeURL to be nil when iframe URL string is empty."
    )
  }

  // MARK: - Playsinline query parameter

  func testOEmbedBlockIframeURL_appendsPlaysinlineParameter() throws {
    let oembed = makeOembed(
      title: "Video",
      iframeUrl: "https://www.youtube.com/embed/abc123"
    )

    let block = OEmbedBlock(oembed: oembed)
    let iframeURL = block.iframeURL

    XCTAssertNotNil(iframeURL, "Expected a valid iframe URL.")
    let components = URLComponents(url: iframeURL!, resolvingAgainstBaseURL: false)
    let playsinline = components?.queryItems?.first(where: { $0.name == "playsinline" })

    XCTAssertNotNil(playsinline, "Expected playsinline query parameter to be appended.")
    XCTAssertEqual(
      playsinline?.value,
      "1",
      "Expected playsinline value to be '1'."
    )
  }

  func testOEmbedBlockIframeURL_preservesExistingQueryParameters() throws {
    let oembed = makeOembed(
      title: "Video",
      iframeUrl: "https://www.youtube.com/embed/abc123?feature=oembed"
    )

    let block = OEmbedBlock(oembed: oembed)
    let iframeURL = block.iframeURL

    XCTAssertNotNil(iframeURL, "Expected a valid iframe URL.")
    let components = URLComponents(url: iframeURL!, resolvingAgainstBaseURL: false)
    let queryItems = components?.queryItems ?? []

    let feature = queryItems.first(where: { $0.name == "feature" })
    XCTAssertEqual(
      feature?.value,
      "oembed",
      "Expected existing query parameter 'feature' to be preserved."
    )

    let playsinline = queryItems.first(where: { $0.name == "playsinline" })
    XCTAssertEqual(
      playsinline?.value,
      "1",
      "Expected playsinline to be appended alongside existing parameters."
    )
  }

  func testOEmbedBlockIframeURL_doesNotDuplicatePlaysinline() throws {
    let oembed = makeOembed(
      title: "Video",
      iframeUrl: "https://www.youtube.com/embed/abc123?playsinline=1"
    )

    let block = OEmbedBlock(oembed: oembed)
    let iframeURL = block.iframeURL

    XCTAssertNotNil(iframeURL, "Expected a valid iframe URL.")
    let components = URLComponents(url: iframeURL!, resolvingAgainstBaseURL: false)
    let playsinlineItems = components?.queryItems?.filter { $0.name == "playsinline" } ?? []

    XCTAssertEqual(
      playsinlineItems.count,
      1,
      "Expected exactly one playsinline parameter, not a duplicate."
    )
  }

  // MARK: - WebView configuration

  func testOEmbedWebView_configuresInlineMediaPlayback() throws {
    let expectation = expectation(description: "WebView created")
    var capturedWebView: WKWebView?

    let oembed = makeOembed(
      title: "Config Test",
      iframeUrl: "https://example.com/embed"
    )
    var block = OEmbedBlock(oembed: oembed)
    block.onWebViewCreated = { webView in
      capturedWebView = webView
      expectation.fulfill()
    }

    let view = block
      .environment(\.richTextStyle, richTextStyle(.light))
      .frame(width: 300, height: 200)

    ViewHosting.host(view: view)
    defer { ViewHosting.expel() }
    wait(for: [expectation], timeout: 1.0)

    let webView = try XCTUnwrap(capturedWebView, "Expected the onWebViewCreated callback to fire.")

    XCTAssertTrue(
      webView.configuration.allowsInlineMediaPlayback,
      "Expected allowsInlineMediaPlayback to be true."
    )
    XCTAssertTrue(
      webView.configuration.suppressesIncrementalRendering,
      "Expected suppressesIncrementalRendering to be true to prevent partial content flicker."
    )
  }

  func testOEmbedWebView_setsKickstarterApplicationName() throws {
    let expectation = expectation(description: "WebView created")
    var capturedWebView: WKWebView?

    let oembed = makeOembed(
      title: "UA Test",
      iframeUrl: "https://example.com/embed"
    )
    var block = OEmbedBlock(oembed: oembed)
    block.onWebViewCreated = { webView in
      capturedWebView = webView
      expectation.fulfill()
    }

    let view = block
      .environment(\.richTextStyle, richTextStyle(.light))
      .frame(width: 300, height: 200)

    ViewHosting.host(view: view)
    defer { ViewHosting.expel() }
    wait(for: [expectation], timeout: 1.0)

    let webView = try XCTUnwrap(capturedWebView, "Expected the onWebViewCreated callback to fire.")
    let appName = webView.configuration.applicationNameForUserAgent

    XCTAssertEqual(
      appName,
      "Kickstarter-iOS",
      "Expected applicationNameForUserAgent to identify the app."
    )
  }

  func testOEmbedWebView_disablesScrolling() throws {
    let expectation = expectation(description: "WebView created")
    var capturedWebView: WKWebView?

    let oembed = makeOembed(
      title: "Scroll Test",
      iframeUrl: "https://example.com/embed"
    )
    var block = OEmbedBlock(oembed: oembed)
    block.onWebViewCreated = { webView in
      capturedWebView = webView
      expectation.fulfill()
    }

    let view = block
      .environment(\.richTextStyle, richTextStyle(.light))
      .frame(width: 300, height: 200)

    ViewHosting.host(view: view)
    defer { ViewHosting.expel() }
    wait(for: [expectation], timeout: 1.0)

    let webView = try XCTUnwrap(capturedWebView, "Expected the onWebViewCreated callback to fire.")

    XCTAssertFalse(
      webView.scrollView.isScrollEnabled,
      "Expected scroll to be disabled so the embed sizes to its container."
    )
  }

  func testOEmbedWebView_hasUIDelegateForLinkHandling() throws {
    let expectation = expectation(description: "WebView created")
    var capturedWebView: WKWebView?

    let oembed = makeOembed(
      title: "Delegate Test",
      iframeUrl: "https://example.com/embed"
    )
    var block = OEmbedBlock(oembed: oembed)
    block.onWebViewCreated = { webView in
      capturedWebView = webView
      expectation.fulfill()
    }

    let view = block
      .environment(\.richTextStyle, richTextStyle(.light))
      .frame(width: 300, height: 200)

    ViewHosting.host(view: view)
    defer { ViewHosting.expel() }
    wait(for: [expectation], timeout: 1.0)

    let webView = try XCTUnwrap(capturedWebView, "Expected the onWebViewCreated callback to fire.")

    XCTAssertNotNil(
      webView.uiDelegate,
      "Expected a WKUIDelegate to handle links that target new windows."
    )
  }

  // MARK: - Aspect ratio

  func testOEmbedBlockWithValidDimensions_usesProvidedAspectRatio() throws {
    let oembed = makeOembed(
      width: 640,
      height: 480,
      title: "4:3 Video",
      iframeUrl: "https://example.com/embed"
    )

    let view = oembedBlock(oembed: oembed, colorScheme: .light)
    let element = try view.inspect().find(viewWithAccessibilityLabel: "4:3 Video")
    let aspectRatio = try element.aspectRatio()

    XCTAssertEqual(
      aspectRatio.aspectRatio,
      640.0 / 480.0 as CGFloat,
      "Expected aspect ratio to match width/height from oembed data."
    )
    XCTAssertEqual(
      aspectRatio.contentMode,
      .fit,
      "Expected content mode to be .fit."
    )
  }

  func testOEmbedBlockWithZeroDimensions_fallsBackToSixteenByNine() throws {
    let oembed = makeOembed(
      width: 0,
      height: 0,
      title: "Fallback Ratio",
      iframeUrl: "https://example.com/embed"
    )

    let view = oembedBlock(oembed: oembed, colorScheme: .light)
    let element = try view.inspect().find(viewWithAccessibilityLabel: "Fallback Ratio")
    let aspectRatio = try element.aspectRatio()

    XCTAssertEqual(
      aspectRatio.aspectRatio,
      16.0 / 9.0 as CGFloat,
      "Expected 16:9 fallback aspect ratio when dimensions are zero."
    )
  }

  // MARK: - Empty title

  func testOEmbedBlockWithEmptyTitle_hasEmptyAccessibilityLabel() throws {
    let oembed = makeOembed(
      title: "",
      iframeUrl: "https://example.com/embed"
    )

    let view = oembedBlock(oembed: oembed, colorScheme: .light)

    XCTAssertNoThrow(
      try view.inspect().find(viewWithAccessibilityLabel: ""),
      "Expected empty accessibility label when title is empty."
    )
  }

  // MARK: - Color schemes

  func testOEmbedBlockWithValidIframeURL_lightAndDarkStyles() throws {
    let oembed = makeOembed(
      title: "Styled Embed",
      iframeUrl: "https://example.com/embed"
    )

    for colorScheme in [ColorScheme.light, ColorScheme.dark] {
      let view = oembedBlock(oembed: oembed, colorScheme: colorScheme)
      let block = try view.inspect().find(OEmbedBlock.self).actualView()

      XCTAssertEqual(
        block.oembed.title,
        "Styled Embed",
        "OEmbedBlock.oembed.title should be preserved for color scheme \(colorScheme)."
      )
      XCTAssertNoThrow(
        try view.inspect().find(viewWithAccessibilityLabel: "Styled Embed"),
        "Expected accessibility label for color scheme \(colorScheme)."
      )
    }
  }

  // MARK: - Container sizing

  func testOEmbedBlockWithValidIframeURL_respectsContainerFrame() throws {
    let oembed = makeOembed(
      title: "Framed Embed",
      iframeUrl: "https://example.com/embed"
    )
    let containerWidth: CGFloat = 400
    let containerHeight: CGFloat = 300

    let view = oembedBlock(
      oembed: oembed,
      colorScheme: .light,
      width: containerWidth,
      height: containerHeight
    )
    let frame = try view.inspect().fixedFrame()

    XCTAssertEqual(
      frame.width,
      containerWidth,
      "Expected OEmbedBlock width to respect container width."
    )
    XCTAssertEqual(
      frame.height,
      containerHeight,
      "Expected OEmbedBlock height to respect container height."
    )
  }
}

// MARK: - Helpers

private func makeOembed(
  width: Int = 640,
  height: Int = 360,
  title: String,
  type: String = "video",
  iframeUrl: String?,
  originalUrl: String? = "https://example.com/original"
) -> RichTextElement.OEmbed {
  RichTextElement.OEmbed(
    width: width,
    height: height,
    version: "1.0",
    title: title,
    type: type,
    iframeUrl: iframeUrl,
    originalUrl: originalUrl,
    thumbnailUrl: nil,
    thumbnailWidth: nil,
    thumbnailHeight: nil
  )
}

@MainActor
@ViewBuilder
private func oembedBlock(
  oembed: RichTextElement.OEmbed,
  colorScheme: ColorScheme,
  width: CGFloat? = 300,
  height: CGFloat? = 200
) -> some View {
  let block = OEmbedBlock(oembed: oembed)
    .environment(\.richTextStyle, richTextStyle(colorScheme))

  if let width, let height {
    block.frame(width: width, height: height)
  } else {
    block
  }
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
