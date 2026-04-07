import Foundation
import GraphAPI
@testable import ServerDrivenUI
import Testing

@Suite("RichText GraphQL parsing")
struct RichTextGQLConversionTests {
  @Test("AsRichText item -> .text element with styles, link, no children")
  func asRichTextItemAsRichText() async throws {
    let gql = RichTextComponentFragment.Item.AsRichText(
      children: nil,
      text: "foo",
      link: "https://kickstarter.com/",
      styles: ["STRONG"]
    )
    let el = gql.asRichTextElement
    guard case let .text(t, level) = el else { Issue.record("expected .text"); return }
    #expect(t.text == "foo")
    #expect(t.link == URL(string: "https://kickstarter.com/"))
    #expect(t.styles == [.strong])
    #expect(t.children.isEmpty)
    #expect(level == nil)
  }

  @Test("Child.AsRichText -> .text element, no children")
  func asRichTextChildAsRichText() async throws {
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichText(text: "bar", link: nil, styles: [])
    let el = gql.asRichTextElement
    guard case .text(let t, nil) = el else { Issue.record("expected .text"); return }
    #expect(t.text == "bar")
    #expect(t.children.isEmpty)
  }

  @Test("Header.Child.AsRichText -> .text element with emphasis style")
  func asRichTextHeaderChildAsRichText() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichText(
      text: "h",
      link: nil,
      styles: ["EMPHASIS"]
    )
    let el = gql.asRichTextElement
    guard case .text(let t, nil) = el else { Issue.record("expected .text"); return }
    #expect(t.text == "h")
    #expect(t.styles == [.emphasis])
  }

  @Test("ListItem.Child.AsRichText -> .text element")
  func asRichTextListItemChildAsRichText() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichText(
      text: "li",
      link: nil,
      styles: nil
    )
    let el = gql.asRichTextElement
    guard case .text(let t, nil) = el else { Issue.record("expected .text"); return }
    #expect(t.text == "li")
  }

  @Test("AsRichTextHeader item -> .text element")
  func asRichTextHeader() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextHeader(
      children: nil,
      text: "header",
      link: nil,
      styles: []
    )
    let el = gql.asRichTextElement
    guard case .text(let t, nil) = el else { Issue.record("expected .text"); return }
    #expect(t.text == "header")
  }

  @Test("Header.Child.AsRichTextHeader -> .text element")
  func asRichTextHeaderChildAsRichTextHeader() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextHeader(
      text: "h2",
      link: nil,
      styles: []
    )
    let el = gql.asRichTextElement
    guard case .text(let t, nil) = el else { Issue.record("expected .text"); return }
    #expect(t.text == "h2")
  }

  @Test("Child.AsRichTextHeader -> .text element")
  func asRichTextChildAsRichTextHeader() async throws {
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextHeader(
      text: "x",
      link: nil,
      styles: nil
    )
    let el = gql.asRichTextElement
    guard case .text(let t, nil) = el else { Issue.record("expected .text"); return }
    #expect(t.text == "x")
  }

  @Test("ListItem.Child.AsRichTextHeader -> .text element")
  func asRichTextListItemChildAsRichTextHeader() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextHeader(
      text: "y",
      link: nil,
      styles: nil
    )
    let el = gql.asRichTextElement
    guard case .text(let t, nil) = el else { Issue.record("expected .text"); return }
    #expect(t.text == "y")
  }

  @Test("AsRichTextListItem item -> .listItem element with no children")
  func asRichTextListItem() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListItem(
      children: nil,
      text: "bullet",
      link: nil,
      styles: []
    )
    let el = gql.asRichTextElement
    guard case let .listItem(t) = el else { Issue.record("expected .listItem"); return }
    #expect(t.text == "bullet")
    #expect(t.children.isEmpty)
  }

  @Test(
    "ListItem.Child.AsRichTextListItem -> .listItem element"
  )
  func asRichTextListItemChildAsRichTextListItem() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextListItem(
      text: "nested",
      link: nil,
      styles: []
    )
    let el = gql.asRichTextElement
    guard case let .listItem(t) = el else { Issue.record("expected .listItem"); return }
    #expect(t.text == "nested")
  }

  @Test("Child.AsRichTextListItem -> .listItem element")
  func asRichTextChildAsRichTextListItem() async throws {
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextListItem(
      text: "a",
      link: nil,
      styles: nil
    )
    let el = gql.asRichTextElement
    guard case let .listItem(t) = el else { Issue.record("expected .listItem"); return }
    #expect(t.text == "a")
  }

  @Test("Header.Child.AsRichTextListItem -> .listItem element")
  func asRichTextHeaderChildAsRichTextListItem() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextListItem(
      text: "b",
      link: nil,
      styles: nil
    )
    let el = gql.asRichTextElement
    guard case let .listItem(t) = el else { Issue.record("expected .listItem"); return }
    #expect(t.text == "b")
  }

  @Test("AsRichTextListOpen item -> .listItemOpen element")
  func asRichTextListOpenItem() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListOpen(_present: true)
    let el = gql.asRichTextElement
    guard case .listItemOpen = el else { Issue.record("expected .listItemOpen"); return }
  }

  @Test("Child.AsRichTextListOpen -> .listItemOpen element")
  func asRichTextListOpenChild() async throws {
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextListOpen(_present: true)
    let el = gql.asRichTextElement
    guard case .listItemOpen = el else { Issue.record("expected .listItemOpen"); return }
  }

  @Test("Header.Child.AsRichTextListOpen -> .listItemOpen element")
  func asRichTextListOpenHeaderChild() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextListOpen(_present: true)
    let el = gql.asRichTextElement
    guard case .listItemOpen = el else { Issue.record("expected .listItemOpen"); return }
  }

  @Test("ListItem.Child.AsRichTextListOpen -> .listItemOpen element")
  func asRichTextListOpenListItemChild() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextListOpen(_present: true)
    let el = gql.asRichTextElement
    guard case .listItemOpen = el else { Issue.record("expected .listItemOpen"); return }
  }

  @Test("AsRichTextListClose item -> .listItemClose element")
  func asRichTextListCloseItem() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListClose(_present: true)
    let el = gql.asRichTextElement
    guard case .listItemClose = el else { Issue.record("expected .listItemClose"); return }
  }

  @Test("Child.AsRichTextListClose -> .listItemClose element")
  func asRichTextListCloseChild() async throws {
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextListClose(_present: true)
    let el = gql.asRichTextElement
    guard case .listItemClose = el else { Issue.record("expected .listItemClose"); return }
  }

  @Test("Header.Child.AsRichTextListClose -> .listItemClose element")
  func asRichTextListCloseHeaderChild() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextListClose(_present: true)
    let el = gql.asRichTextElement
    guard case .listItemClose = el else { Issue.record("expected .listItemClose"); return }
  }

  @Test("ListItem.Child.AsRichTextListClose -> .listItemClose element")
  func asRichTextListCloseListItemChild() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextListClose(_present: true)
    let el = gql.asRichTextElement
    guard case .listItemClose = el else { Issue.record("expected .listItemClose"); return }
  }

  @Test("AsRichTextAudio item -> .audio element with alt, caption, url")
  func asRichTextAudioItem() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextAudio(
      altText: "alt",
      asset: nil,
      caption: "cap",
      url: "https://audio"
    )
    let el = gql.asRichTextElement
    guard case let .audio(a) = el else { Issue.record("expected .audio"); return }
    #expect(a.altText == "alt")
    #expect(a.assetID == nil)
    #expect(a.caption == "cap")
    #expect(a.url == "https://audio")
  }

  @Test("Child.AsRichTextAudio -> .audio element")
  func asRichTextAudioChild() async throws {
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextAudio(
      altText: "a",
      asset: nil,
      caption: "c",
      url: "u"
    )
    let el = gql.asRichTextElement
    guard case let .audio(a) = el else { Issue.record("expected .audio"); return }
    #expect(a.altText == "a")
    #expect(a.url == "u")
  }

  @Test("AsRichTextAudio with Asset -> .audio element with assetID")
  func asRichTextAudioWithAsset() async throws {
    let asset = RichTextItemFragment.AsRichTextAudio.Asset(id: "asset-1")
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextAudio(
      altText: "",
      asset: asset,
      caption: "",
      url: ""
    )
    let el = gql.asRichTextElement
    guard case let .audio(a) = el else { Issue.record("expected .audio"); return }
    #expect(a.assetID == "asset-1")
  }

  @Test("AsRichTextPhoto item -> .photo element with alt, caption, url")
  func asRichTextPhotoItem() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextPhoto(
      altText: "photo",
      asset: nil,
      caption: "cap",
      url: "https://img"
    )
    let el = gql.asRichTextElement
    guard case let .photo(p) = el else { Issue.record("expected .photo"); return }
    #expect(p.altText == "photo")
    #expect(p.assetID == nil)
    #expect(p.url == "https://img")
  }

  @Test("Child.AsRichTextPhoto -> .photo element")
  func asRichTextPhotoChild() async throws {
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextPhoto(
      altText: "p",
      asset: nil,
      caption: "c",
      url: "u"
    )
    let el = gql.asRichTextElement
    guard case let .photo(p) = el else { Issue.record("expected .photo"); return }
    #expect(p.altText == "p")
  }

  @Test("AsRichTextVideo item -> .video element with alt, caption, url")
  func asRichTextVideoItem() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextVideo(
      altText: "v",
      asset: nil,
      caption: "cap",
      url: "https://vid"
    )
    let el = gql.asRichTextElement
    guard case let .video(v) = el else { Issue.record("expected .video"); return }
    #expect(v.altText == "v")
    #expect(v.url == "https://vid")
  }

  @Test("Child.AsRichTextVideo -> .video element")
  func asRichTextVideoChild() async throws {
    let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextVideo(
      altText: "x",
      asset: nil,
      caption: "",
      url: ""
    )
    let el = gql.asRichTextElement
    guard case let .video(v) = el else { Issue.record("expected .video"); return }
    #expect(v.altText == "x")
  }

  @Test(
    "AsRichTextOembed item -> .oembed element with dimensions, urls, and thumbnail"
  )
  func asRichTextOembedItem() async throws {
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
    guard case let .oembed(o) = el else { Issue.record("expected .oembed"); return }
    #expect(o.width == 200)
    #expect(o.height == 100)
    #expect(o.title == "Title")
    #expect(o.type == "video")
    #expect(o.version == "1.0")
    #expect(o.iframeUrl == "https://iframe")
    #expect(o.originalUrl == "https://orig")
    #expect(o.thumbnailUrl == "https://thumb")
    #expect(o.thumbnailWidth == 60)
    #expect(o.thumbnailHeight == 50)
  }

  @Test("Child.AsRichTextOembed -> .oembed element")
  func asRichTextOembedChild() async throws {
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
    guard case let .oembed(o) = el else { Issue.record("expected .oembed"); return }
    #expect(o.width == 4)
    #expect(o.height == 1)
    #expect(o.title == "T")
    #expect(o.type == "rich")
  }

  @Test("Header.Child.AsRichTextAudio -> .audio element")
  func asRichTextHeaderChildAsRichTextAudio() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextAudio(
      altText: "h",
      asset: nil,
      caption: "",
      url: ""
    )
    let el = gql.asRichTextElement
    guard case let .audio(a) = el else { Issue.record("expected .audio"); return }
    #expect(a.altText == "h")
  }

  @Test("ListItem.Child.AsRichTextAudio -> .audio element")
  func asRichTextListItemChildAsRichTextAudio() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextAudio(
      altText: "li",
      asset: nil,
      caption: "",
      url: ""
    )
    let el = gql.asRichTextElement
    guard case let .audio(a) = el else { Issue.record("expected .audio"); return }
    #expect(a.altText == "li")
  }

  @Test("Header.Child.AsRichTextPhoto -> .photo element")
  func asRichTextHeaderChildAsRichTextPhoto() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextPhoto(
      altText: "hp",
      asset: nil,
      caption: "",
      url: ""
    )
    let el = gql.asRichTextElement
    guard case let .photo(p) = el else { Issue.record("expected .photo"); return }
    #expect(p.altText == "hp")
  }

  @Test("ListItem.Child.AsRichTextPhoto -> .photo element")
  func asRichTextListItemChildAsRichTextPhoto() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextPhoto(
      altText: "lip",
      asset: nil,
      caption: "",
      url: ""
    )
    let el = gql.asRichTextElement
    guard case let .photo(p) = el else { Issue.record("expected .photo"); return }
    #expect(p.altText == "lip")
  }

  @Test("Header.Child.AsRichTextVideo -> .video element")
  func asRichTextHeaderChildAsRichTextVideo() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextVideo(
      altText: "hv",
      asset: nil,
      caption: "",
      url: ""
    )
    let el = gql.asRichTextElement
    guard case let .video(v) = el else { Issue.record("expected .video"); return }
    #expect(v.altText == "hv")
  }

  @Test("ListItem.Child.AsRichTextVideo -> .video element")
  func asRichTextListItemChildAsRichTextVideo() async throws {
    let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextVideo(
      altText: "liv",
      asset: nil,
      caption: "",
      url: ""
    )
    let el = gql.asRichTextElement
    guard case let .video(v) = el else { Issue.record("expected .video"); return }
    #expect(v.altText == "liv")
  }

  @Test("Header.Child.AsRichTextOembed -> .oembed element")
  func asRichTextHeaderChildAsRichTextOembed() async throws {
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
    guard case let .oembed(o) = el else { Issue.record("expected .oembed"); return }
    #expect(o.title == "H")
  }

  @Test("ListItem.Child.AsRichTextOembed -> .oembed element")
  func asRichTextListItemChildAsRichTextOembed() async throws {
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
    guard case let .oembed(o) = el else { Issue.record("expected .oembed"); return }
    #expect(o.title == "L")
    #expect(o.width == 5)
  }
}
