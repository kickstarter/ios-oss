import Foundation
import GraphAPI
@testable import LibraryTestHelpers
@testable import ServerDrivenUI
import XCTest

final class RichTextGQLConversionTests: TestCase {
  /* AsRichText item -> .text element with styles, link, no children */
  func testAsRichTextItemAsRichText() throws {
    let gql = RichTextComponentFragment.Item.AsRichText(
      children: nil,
      text: "foo",
      link: "https://kickstarter.com/",
      styles: ["STRONG"]
    )
    let el = gql.asRichTextElement
    guard case let .text(t, level) = el else { XCTFail("expected .text"); return }
    XCTAssertEqual(t.text, "foo")
    XCTAssertEqual(t.link, URL(string: "https://kickstarter.com/"))
    XCTAssertEqual(t.styles, [.strong])
    XCTAssertTrue(t.children.isEmpty)
    XCTAssertNil(level)
  }

  /* Child.AsRichText -> .text element, no children */
  func testAsRichTextChildAsRichText() throws {
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichText(text: "bar", link: nil, styles: [])
    let el = gql.asRichTextElement
    guard case .text(let t, nil) = el else { XCTFail("expected .text"); return }
    XCTAssertEqual(t.text, "bar")
    XCTAssertTrue(t.children.isEmpty)
  }

  /* Header.Child.AsRichText -> .text element with emphasis style */
  func testAsRichTextHeaderChildAsRichText() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichText(
      text: "h",
      link: nil,
      styles: ["EMPHASIS"]
    )
    let el = gql.asRichTextElement
    guard case .text(let t, nil) = el else { XCTFail("expected .text"); return }
    XCTAssertEqual(t.text, "h")
    XCTAssertEqual(t.styles, [.emphasis])
  }

  /* ListItem.Child.AsRichText -> .text element */
  func testAsRichTextListItemChildAsRichText() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichText(
      text: "li",
      link: nil,
      styles: nil
    )
    let el = gql.asRichTextElement
    guard case .text(let t, nil) = el else { XCTFail("expected .text"); return }
    XCTAssertEqual(t.text, "li")
  }

  /* AsRichTextHeader item -> .text element */
  func testAsRichTextHeader() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextHeader(
      children: nil,
      text: "header",
      link: nil,
      styles: []
    )
    let el = gql.asRichTextElement
    guard case .text(let t, nil) = el else { XCTFail("expected .text"); return }
    XCTAssertEqual(t.text, "header")
  }

  /* Header.Child.AsRichTextHeader -> .text element */
  func testAsRichTextHeaderChildAsRichTextHeader() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextHeader(
      text: "h2",
      link: nil,
      styles: []
    )
    let el = gql.asRichTextElement
    guard case .text(let t, nil) = el else { XCTFail("expected .text"); return }
    XCTAssertEqual(t.text, "h2")
  }

  /* Child.AsRichTextHeader -> .text element */
  func testAsRichTextChildAsRichTextHeader() throws {
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextHeader(
      text: "x",
      link: nil,
      styles: nil
    )
    let el = gql.asRichTextElement
    guard case .text(let t, nil) = el else { XCTFail("expected .text"); return }
    XCTAssertEqual(t.text, "x")
  }

  /* ListItem.Child.AsRichTextHeader -> .text element */
  func testAsRichTextListItemChildAsRichTextHeader() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextHeader(
      text: "y",
      link: nil,
      styles: nil
    )
    let el = gql.asRichTextElement
    guard case .text(let t, nil) = el else { XCTFail("expected .text"); return }
    XCTAssertEqual(t.text, "y")
  }

  /* AsRichTextListItem item -> .listItem element with no children */
  func testAsRichTextListItem() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListItem(
      children: nil,
      text: "bullet",
      link: nil,
      styles: []
    )
    let el = gql.asRichTextElement
    guard case let .listItem(t) = el else { XCTFail("expected .listItem"); return }
    XCTAssertEqual(t.text, "bullet")
    XCTAssertTrue(t.children.isEmpty)
  }

  /* ListItem.Child.AsRichTextListItem -> .listItem element */
  func testAsRichTextListItemChildAsRichTextListItem() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextListItem(
      text: "nested",
      link: nil,
      styles: []
    )
    let el = gql.asRichTextElement
    guard case let .listItem(t) = el else { XCTFail("expected .listItem"); return }
    XCTAssertEqual(t.text, "nested")
  }

  /* Child.AsRichTextListItem -> .listItem element */
  func testAsRichTextChildAsRichTextListItem() throws {
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextListItem(
      text: "a",
      link: nil,
      styles: nil
    )
    let el = gql.asRichTextElement
    guard case let .listItem(t) = el else { XCTFail("expected .listItem"); return }
    XCTAssertEqual(t.text, "a")
  }

  /* Header.Child.AsRichTextListItem -> .listItem element */
  func testAsRichTextHeaderChildAsRichTextListItem() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextListItem(
      text: "b",
      link: nil,
      styles: nil
    )
    let el = gql.asRichTextElement
    guard case let .listItem(t) = el else { XCTFail("expected .listItem"); return }
    XCTAssertEqual(t.text, "b")
  }

  /* AsRichTextListOpen item -> .listItemOpen element */
  func testAsRichTextListOpenItem() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListOpen(_present: true)
    let el = gql.asRichTextElement
    guard case .listItemOpen = el else { XCTFail("expected .listItemOpen"); return }
  }

  /* Child.AsRichTextListOpen -> .listItemOpen element */
  func testAsRichTextListOpenChild() throws {
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextListOpen(_present: true)
    let el = gql.asRichTextElement
    guard case .listItemOpen = el else { XCTFail("expected .listItemOpen"); return }
  }

  /* Header.Child.AsRichTextListOpen -> .listItemOpen element */
  func testAsRichTextListOpenHeaderChild() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextListOpen(_present: true)
    let el = gql.asRichTextElement
    guard case .listItemOpen = el else { XCTFail("expected .listItemOpen"); return }
  }

  /* ListItem.Child.AsRichTextListOpen -> .listItemOpen element */
  func testAsRichTextListOpenListItemChild() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextListOpen(_present: true)
    let el = gql.asRichTextElement
    guard case .listItemOpen = el else { XCTFail("expected .listItemOpen"); return }
  }

  /* AsRichTextListClose item -> .listItemClose element */
  func testAsRichTextListCloseItem() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListClose(_present: true)
    let el = gql.asRichTextElement
    guard case .listItemClose = el else { XCTFail("expected .listItemClose"); return }
  }

  /* Child.AsRichTextListClose -> .listItemClose element */
  func testAsRichTextListCloseChild() throws {
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextListClose(_present: true)
    let el = gql.asRichTextElement
    guard case .listItemClose = el else { XCTFail("expected .listItemClose"); return }
  }

  /* Header.Child.AsRichTextListClose -> .listItemClose element */
  func testAsRichTextListCloseHeaderChild() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextListClose(_present: true)
    let el = gql.asRichTextElement
    guard case .listItemClose = el else { XCTFail("expected .listItemClose"); return }
  }

  /* ListItem.Child.AsRichTextListClose -> .listItemClose element */
  func testAsRichTextListCloseListItemChild() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextListClose(_present: true)
    let el = gql.asRichTextElement
    guard case .listItemClose = el else { XCTFail("expected .listItemClose"); return }
  }

  /* AsRichTextAudio item -> .audio element with alt, caption, url */
  func testAsRichTextAudioItem() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextAudio(
      altText: "alt",
      asset: nil,
      caption: "cap",
      url: "https://audio"
    )
    let el = gql.asRichTextElement
    guard case let .audio(a) = el else { XCTFail("expected .audio"); return }
    XCTAssertEqual(a.altText, "alt")
    XCTAssertNil(a.assetID)
    XCTAssertEqual(a.caption, "cap")
    XCTAssertEqual(a.url, "https://audio")
  }

  /* Child.AsRichTextAudio -> .audio element */
  func testAsRichTextAudioChild() throws {
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextAudio(
      altText: "a",
      asset: nil,
      caption: "c",
      url: "u"
    )
    let el = gql.asRichTextElement
    guard case let .audio(a) = el else { XCTFail("expected .audio"); return }
    XCTAssertEqual(a.altText, "a")
    XCTAssertEqual(a.url, "u")
  }

  /* AsRichTextAudio with Asset -> .audio element with assetID */
  func testAsRichTextAudioWithAsset() throws {
    let asset = RichTextItemFragment.AsRichTextAudio.Asset(id: "asset-1")
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextAudio(
      altText: "",
      asset: asset,
      caption: "",
      url: ""
    )
    let el = gql.asRichTextElement
    guard case let .audio(a) = el else { XCTFail("expected .audio"); return }
    XCTAssertEqual(a.assetID, "asset-1")
  }

  /* AsRichTextPhoto item -> .photo element with alt, caption, url */
  func testAsRichTextPhotoItem() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextPhoto(
      altText: "photo",
      asset: nil,
      caption: "cap",
      url: "https://img"
    )
    let el = gql.asRichTextElement
    guard case let .photo(p) = el else { XCTFail("expected .photo"); return }
    XCTAssertEqual(p.altText, "photo")
    XCTAssertNil(p.assetID)
    XCTAssertEqual(p.url, "https://img")
  }

  /* Child.AsRichTextPhoto -> .photo element */
  func testAsRichTextPhotoChild() throws {
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextPhoto(
      altText: "p",
      asset: nil,
      caption: "c",
      url: "u"
    )
    let el = gql.asRichTextElement
    guard case let .photo(p) = el else { XCTFail("expected .photo"); return }
    XCTAssertEqual(p.altText, "p")
  }

  /* AsRichTextVideo item -> .video element with alt, caption, url */
  func testAsRichTextVideoItem() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextVideo(
      altText: "v",
      asset: nil,
      caption: "cap",
      url: "https://vid"
    )
    let el = gql.asRichTextElement
    guard case let .video(v) = el else { XCTFail("expected .video"); return }
    XCTAssertEqual(v.altText, "v")
    XCTAssertEqual(v.url, "https://vid")
    XCTAssertNil(v.posterURL)
    XCTAssertTrue(v.formats.isEmpty)
  }

  /* AsRichTextVideo item with asset -> .video element with assetID and posterURL */
  func testAsRichTextVideoItemWithAsset() throws {
    let asset = RichTextItemFragment.AsRichTextVideo.Asset(
      id: "vid-asset-1",
      poster: "https://example.com/poster.jpg",
      formats: nil
    )
    let gql = RichTextComponentFragment.Item.AsRichTextVideo(
      altText: "v",
      asset: asset,
      caption: "cap",
      url: "https://vid"
    )
    let el = gql.asRichTextElement
    guard case let .video(v) = el else { XCTFail("expected .video"); return }
    XCTAssertEqual(v.assetID, "vid-asset-1")
    XCTAssertEqual(v.posterURL, "https://example.com/poster.jpg")
    XCTAssertTrue(v.formats.isEmpty)
  }

  /* AsRichTextVideo item with formats -> .video element with all format fields */
  func testAsRichTextVideoItemWithFormats() throws {
    let hi = RichTextItemFragment.AsRichTextVideo.Asset.Format(
      encoding: #"video/mp4; codecs="avc1.64001E, mp4a.40.2""#,
      height: "1080",
      width: "1920",
      profile: "high",
      url: "https://vid/high.mp4"
    )
    let lo = RichTextItemFragment.AsRichTextVideo.Asset.Format(
      encoding: #"video/mp4; codecs="avc1.42E01E, mp4a.40.2""#,
      height: "720",
      width: "1280",
      profile: "baseline",
      url: "https://vid/baseline.mp4"
    )
    let asset = RichTextItemFragment.AsRichTextVideo.Asset(
      id: "vid-asset-2",
      poster: nil,
      formats: [hi, lo]
    )
    let gql = RichTextComponentFragment.Item.AsRichTextVideo(
      altText: "",
      asset: asset,
      caption: "",
      url: "https://vid"
    )
    let el = gql.asRichTextElement
    guard case let .video(v) = el else { XCTFail("expected .video"); return }
    XCTAssertNil(v.posterURL)
    XCTAssertEqual(v.formats.count, 2)
    guard let first = v.formats.first else { return XCTFail("missing first format") }
    XCTAssertEqual(first.encoding, #"video/mp4; codecs="avc1.64001E, mp4a.40.2""#)
    XCTAssertEqual(first.width, "1920")
    XCTAssertEqual(first.height, "1080")
    XCTAssertEqual(first.profile, "high")
    XCTAssertEqual(first.url, "https://vid/high.mp4")
    guard let second = v.formats.last else { return XCTFail("missing second format") }
    XCTAssertEqual(second.profile, "baseline")
    XCTAssertEqual(second.url, "https://vid/baseline.mp4")
  }

  /* AsRichTextVideo item with nil format entries -> nil entries skipped */
  func testAsRichTextVideoItemNilFormatEntriesSkipped() throws {
    let format = RichTextItemFragment.AsRichTextVideo.Asset.Format(
      encoding: "video/mp4",
      height: "720",
      width: "1280",
      profile: "main",
      url: "https://vid/main.mp4"
    )
    let asset = RichTextItemFragment.AsRichTextVideo.Asset(
      id: "vid-asset-3",
      poster: nil,
      formats: [format, nil]
    )
    let gql = RichTextComponentFragment.Item.AsRichTextVideo(
      altText: "",
      asset: asset,
      caption: "",
      url: ""
    )
    let el = gql.asRichTextElement
    guard case let .video(v) = el else { XCTFail("expected .video"); return }
    XCTAssertEqual(v.formats.count, 1)
  }

  /* Child.AsRichTextVideo -> .video element */
  func testAsRichTextVideoChild() throws {
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextVideo(
      altText: "x",
      asset: nil,
      caption: "",
      url: ""
    )
    let el = gql.asRichTextElement
    guard case let .video(v) = el else { XCTFail("expected .video"); return }
    XCTAssertEqual(v.altText, "x")
    XCTAssertNil(v.posterURL)
    XCTAssertTrue(v.formats.isEmpty)
  }

  /* Child.AsRichTextVideo with asset -> .video element with posterURL and formats */
  func testAsRichTextVideoChildWithAsset() throws {
    let format = RichTextItemFragment.AsRichTextVideo.Asset.Format(
      encoding: "video/mp4",
      height: "1080",
      width: "1920",
      profile: "high",
      url: "https://vid/high.mp4"
    )
    let asset = RichTextItemFragment.AsRichTextVideo.Asset(
      id: "child-asset",
      poster: "https://example.com/child-poster.jpg",
      formats: [format]
    )
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextVideo(
      altText: "",
      asset: asset,
      caption: "",
      url: ""
    )
    let el = gql.asRichTextElement
    guard case let .video(v) = el else { XCTFail("expected .video"); return }
    XCTAssertEqual(v.assetID, "child-asset")
    XCTAssertEqual(v.posterURL, "https://example.com/child-poster.jpg")
    XCTAssertEqual(v.formats.count, 1)
    XCTAssertEqual(v.formats.first?.profile, "high")
  }

  /* AsRichTextOembed item -> .oembed element with dimensions, urls, and thumbnail */
  func testAsRichTextOembedItem() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextOembed(
      width: 200,
      height: 100,
      version: "1.0",
      title: "Title",
      type: "video",
      iframeUrl: "https://iframe",
      originalUrl: "https://orig",
      thumbnailHeight: 50,
      thumbnailUrl: "https://thumb",
      thumbnailWidth: 60
    )
    let el = gql.asRichTextElement
    guard case let .oembed(o) = el else { XCTFail("expected .oembed"); return }
    XCTAssertEqual(o.width, 200)
    XCTAssertEqual(o.height, 100)
    XCTAssertEqual(o.title, "Title")
    XCTAssertEqual(o.type, "video")
    XCTAssertEqual(o.version, "1.0")
    XCTAssertEqual(o.iframeUrl, "https://iframe")
    XCTAssertEqual(o.originalUrl, "https://orig")
    XCTAssertEqual(o.thumbnailUrl, "https://thumb")
    XCTAssertEqual(o.thumbnailWidth, 60)
    XCTAssertEqual(o.thumbnailHeight, 50)
  }

  /* Child.AsRichTextOembed -> .oembed element */
  func testAsRichTextOembedChild() throws {
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextOembed(
      width: 4,
      height: 1,
      version: "1.0",
      title: "T",
      type: "rich",
      iframeUrl: "i",
      originalUrl: "o",
      thumbnailHeight: 2,
      thumbnailUrl: "t",
      thumbnailWidth: 3
    )
    let el = gql.asRichTextElement
    guard case let .oembed(o) = el else { XCTFail("expected .oembed"); return }
    XCTAssertEqual(o.width, 4)
    XCTAssertEqual(o.height, 1)
    XCTAssertEqual(o.title, "T")
    XCTAssertEqual(o.type, "rich")
  }

  /* Header.Child.AsRichTextAudio -> .audio element */
  func testAsRichTextHeaderChildAsRichTextAudio() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextAudio(
      altText: "h",
      asset: nil,
      caption: "",
      url: ""
    )
    let el = gql.asRichTextElement
    guard case let .audio(a) = el else { XCTFail("expected .audio"); return }
    XCTAssertEqual(a.altText, "h")
  }

  /* ListItem.Child.AsRichTextAudio -> .audio element */
  func testAsRichTextListItemChildAsRichTextAudio() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextAudio(
      altText: "li",
      asset: nil,
      caption: "",
      url: ""
    )
    let el = gql.asRichTextElement
    guard case let .audio(a) = el else { XCTFail("expected .audio"); return }
    XCTAssertEqual(a.altText, "li")
  }

  /* Header.Child.AsRichTextPhoto -> .photo element */
  func testAsRichTextHeaderChildAsRichTextPhoto() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextPhoto(
      altText: "hp",
      asset: nil,
      caption: "",
      url: ""
    )
    let el = gql.asRichTextElement
    guard case let .photo(p) = el else { XCTFail("expected .photo"); return }
    XCTAssertEqual(p.altText, "hp")
  }

  /* ListItem.Child.AsRichTextPhoto -> .photo element */
  func testAsRichTextListItemChildAsRichTextPhoto() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextPhoto(
      altText: "lip",
      asset: nil,
      caption: "",
      url: ""
    )
    let el = gql.asRichTextElement
    guard case let .photo(p) = el else { XCTFail("expected .photo"); return }
    XCTAssertEqual(p.altText, "lip")
  }

  /* Header.Child.AsRichTextVideo -> .video element with posterURL and formats */
  func testAsRichTextHeaderChildAsRichTextVideo() throws {
    let asset = RichTextItemFragment.AsRichTextVideo.Asset(
      id: "h-asset",
      poster: "https://example.com/header-poster.jpg",
      formats: nil
    )
    let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextVideo(
      altText: "hv",
      asset: asset,
      caption: "",
      url: ""
    )
    let el = gql.asRichTextElement
    guard case let .video(v) = el else { XCTFail("expected .video"); return }
    XCTAssertEqual(v.altText, "hv")
    XCTAssertEqual(v.assetID, "h-asset")
    XCTAssertEqual(v.posterURL, "https://example.com/header-poster.jpg")
    XCTAssertTrue(v.formats.isEmpty)
  }

  /* ListItem.Child.AsRichTextVideo -> .video element with posterURL and formats */
  func testAsRichTextListItemChildAsRichTextVideo() throws {
    let asset = RichTextItemFragment.AsRichTextVideo.Asset(
      id: "li-asset",
      poster: "https://example.com/li-poster.jpg",
      formats: nil
    )
    let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextVideo(
      altText: "liv",
      asset: asset,
      caption: "",
      url: ""
    )
    let el = gql.asRichTextElement
    guard case let .video(v) = el else { XCTFail("expected .video"); return }
    XCTAssertEqual(v.altText, "liv")
    XCTAssertEqual(v.assetID, "li-asset")
    XCTAssertEqual(v.posterURL, "https://example.com/li-poster.jpg")
    XCTAssertTrue(v.formats.isEmpty)
  }

  /* Header.Child.AsRichTextOembed -> .oembed element */
  func testAsRichTextHeaderChildAsRichTextOembed() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextOembed(
      width: 10,
      height: 10,
      version: "1.0",
      title: "H",
      type: "link",
      iframeUrl: "",
      originalUrl: "",
      thumbnailHeight: 10,
      thumbnailUrl: "",
      thumbnailWidth: 10
    )
    let el = gql.asRichTextElement
    guard case let .oembed(o) = el else { XCTFail("expected .oembed"); return }
    XCTAssertEqual(o.title, "H")
  }

  /* ListItem.Child.AsRichTextOembed -> .oembed element */
  func testAsRichTextListItemChildAsRichTextOembed() throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextOembed(
      width: 5,
      height: 5,
      version: "1.0",
      title: "L",
      type: "photo",
      iframeUrl: "",
      originalUrl: "",
      thumbnailHeight: 5,
      thumbnailUrl: "",
      thumbnailWidth: 5
    )
    let el = gql.asRichTextElement
    guard case let .oembed(o) = el else { XCTFail("expected .oembed"); return }
    XCTAssertEqual(o.title, "L")
    XCTAssertEqual(o.width, 5)
  }
}
