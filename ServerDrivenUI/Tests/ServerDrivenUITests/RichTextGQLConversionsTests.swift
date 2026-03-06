import Foundation
import GraphAPI
@testable import ServerDrivenUI
import Testing

@Test func asRichTextItemAsRichText() async throws {
  let gql = RichTextComponentFragment.Item.AsRichText(
    children: nil,
    text: "foo",
    link: "https://kck.st",
    styles: ["bold"]
  )
  let el = gql.asRichTextElement
  guard case let .text(t, level) = el else { Issue.record("expected .text"); return }
  #expect(t.text == "foo")
  #expect(t.link == URL(string: "https://kck.st"))
  #expect(t.styles == ["bold"])
  #expect(t.children.isEmpty)
  #expect(level == nil)
}

@Test func asRichTextChildAsRichText() async throws {
  let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichText(text: "bar", link: nil, styles: [])
  let el = gql.asRichTextElement
  guard case .text(let t, nil) = el else { Issue.record("expected .text"); return }
  #expect(t.text == "bar")
  #expect(t.children.isEmpty)
}

@Test func asRichTextHeaderChildAsRichText() async throws {
  let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichText(
    text: "h",
    link: nil,
    styles: ["italic"]
  )
  let el = gql.asRichTextElement
  guard case .text(let t, nil) = el else { Issue.record("expected .text"); return }
  #expect(t.text == "h")
  #expect(t.styles == ["italic"])
}

@Test func asRichTextListItemChildAsRichText() async throws {
  let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichText(
    text: "li",
    link: nil,
    styles: nil
  )
  let el = gql.asRichTextElement
  guard case .text(let t, nil) = el else { Issue.record("expected .text"); return }
  #expect(t.text == "li")
}

@Test func asRichTextHeader() async throws {
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

@Test func asRichTextHeaderChildAsRichTextHeader() async throws {
  let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextHeader(
    text: "h2",
    link: nil,
    styles: []
  )
  let el = gql.asRichTextElement
  guard case .text(let t, nil) = el else { Issue.record("expected .text"); return }
  #expect(t.text == "h2")
}

@Test func asRichTextChildAsRichTextHeader() async throws {
  let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextHeader(
    text: "x",
    link: nil,
    styles: nil
  )
  let el = gql.asRichTextElement
  guard case .text(let t, nil) = el else { Issue.record("expected .text"); return }
  #expect(t.text == "x")
}

@Test func asRichTextListItemChildAsRichTextHeader() async throws {
  let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextHeader(
    text: "y",
    link: nil,
    styles: nil
  )
  let el = gql.asRichTextElement
  guard case .text(let t, nil) = el else { Issue.record("expected .text"); return }
  #expect(t.text == "y")
}

@Test func asRichTextListItem() async throws {
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

@Test func asRichTextListItemChildAsRichTextListItem() async throws {
  let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextListItem(
    text: "nested",
    link: nil,
    styles: []
  )
  let el = gql.asRichTextElement
  guard case let .listItem(t) = el else { Issue.record("expected .listItem"); return }
  #expect(t.text == "nested")
}

@Test func asRichTextChildAsRichTextListItem() async throws {
  let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextListItem(
    text: "a",
    link: nil,
    styles: nil
  )
  let el = gql.asRichTextElement
  guard case let .listItem(t) = el else { Issue.record("expected .listItem"); return }
  #expect(t.text == "a")
}

@Test func asRichTextHeaderChildAsRichTextListItem() async throws {
  let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextListItem(
    text: "b",
    link: nil,
    styles: nil
  )
  let el = gql.asRichTextElement
  guard case let .listItem(t) = el else { Issue.record("expected .listItem"); return }
  #expect(t.text == "b")
}

@Test func asRichTextListOpenItem() async throws {
  let gql = RichTextComponentFragment.Item.AsRichTextListOpen(_present: true)
  let el = gql.asRichTextElement
  guard case .listItemOpen = el else { Issue.record("expected .listItemOpen"); return }
}

@Test func asRichTextListOpenChild() async throws {
  let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextListOpen(_present: true)
  let el = gql.asRichTextElement
  guard case .listItemOpen = el else { Issue.record("expected .listItemOpen"); return }
}

@Test func asRichTextListOpenHeaderChild() async throws {
  let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextListOpen(_present: true)
  let el = gql.asRichTextElement
  guard case .listItemOpen = el else { Issue.record("expected .listItemOpen"); return }
}

@Test func asRichTextListOpenListItemChild() async throws {
  let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextListOpen(_present: true)
  let el = gql.asRichTextElement
  guard case .listItemOpen = el else { Issue.record("expected .listItemOpen"); return }
}

@Test func asRichTextListCloseItem() async throws {
  let gql = RichTextComponentFragment.Item.AsRichTextListClose(_present: true)
  let el = gql.asRichTextElement
  guard case .listItemClose = el else { Issue.record("expected .listItemClose"); return }
}

@Test func asRichTextListCloseChild() async throws {
  let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextListClose(_present: true)
  let el = gql.asRichTextElement
  guard case .listItemClose = el else { Issue.record("expected .listItemClose"); return }
}

@Test func asRichTextListCloseHeaderChild() async throws {
  let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextListClose(_present: true)
  let el = gql.asRichTextElement
  guard case .listItemClose = el else { Issue.record("expected .listItemClose"); return }
}

@Test func asRichTextListCloseListItemChild() async throws {
  let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextListClose(_present: true)
  let el = gql.asRichTextElement
  guard case .listItemClose = el else { Issue.record("expected .listItemClose"); return }
}

@Test func asRichTextAudioItem() async throws {
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

@Test func asRichTextAudioChild() async throws {
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

@Test func asRichTextAudioWithAsset() async throws {
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

@Test func asRichTextPhotoItem() async throws {
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

@Test func asRichTextPhotoChild() async throws {
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

@Test func asRichTextVideoItem() async throws {
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

@Test func asRichTextVideoChild() async throws {
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

@Test func asRichTextOembedItem() async throws {
  let gql = RichTextComponentFragment.Item.AsRichTextOembed(
    authorName: "",
    authorUrl: "",
    height: 100,
    html: "",
    iframeUrl: "https://iframe",
    originalUrl: "https://orig",
    photoUrl: "",
    providerName: "",
    providerUrl: "",
    thumbnailHeight: 50,
    thumbnailUrl: "https://thumb",
    thumbnailWidth: 60,
    title: "Title",
    type: "video",
    version: "1.0",
    width: 200
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

@Test func asRichTextOembedChild() async throws {
  let gql = RichTextComponentFragment.Item.AsRichText.Child.AsRichTextOembed(
    authorName: "a",
    authorUrl: "u",
    height: 1,
    html: "h",
    iframeUrl: "i",
    originalUrl: "o",
    photoUrl: "p",
    providerName: "pn",
    providerUrl: "pu",
    thumbnailHeight: 2,
    thumbnailUrl: "t",
    thumbnailWidth: 3,
    title: "T",
    type: "rich",
    version: "1.0",
    width: 4
  )
  let el = gql.asRichTextElement
  guard case let .oembed(o) = el else { Issue.record("expected .oembed"); return }
  #expect(o.width == 4)
  #expect(o.height == 1)
  #expect(o.title == "T")
  #expect(o.type == "rich")
}

@Test func asRichTextHeaderChildAsRichTextAudio() async throws {
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

@Test func asRichTextListItemChildAsRichTextAudio() async throws {
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

@Test func asRichTextHeaderChildAsRichTextPhoto() async throws {
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

@Test func asRichTextListItemChildAsRichTextPhoto() async throws {
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

@Test func asRichTextHeaderChildAsRichTextVideo() async throws {
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

@Test func asRichTextListItemChildAsRichTextVideo() async throws {
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

@Test func asRichTextHeaderChildAsRichTextOembed() async throws {
  let gql = RichTextComponentFragment.Item.AsRichTextHeader.Child.AsRichTextOembed(
    authorName: "", authorUrl: "", height: 10, html: "", iframeUrl: "", originalUrl: "", photoUrl: "",
    providerName: "", providerUrl: "", thumbnailHeight: 10, thumbnailUrl: "", thumbnailWidth: 10,
    title: "H", type: "link", version: "1.0", width: 10
  )
  let el = gql.asRichTextElement
  guard case let .oembed(o) = el else { Issue.record("expected .oembed"); return }
  #expect(o.title == "H")
}

@Test func asRichTextListItemChildAsRichTextOembed() async throws {
  let gql = RichTextComponentFragment.Item.AsRichTextListItem.Child.AsRichTextOembed(
    authorName: "", authorUrl: "", height: 5, html: "", iframeUrl: "", originalUrl: "", photoUrl: "",
    providerName: "", providerUrl: "", thumbnailHeight: 5, thumbnailUrl: "", thumbnailWidth: 5,
    title: "L", type: "photo", version: "1.0", width: 5
  )
  let el = gql.asRichTextElement
  guard case let .oembed(o) = el else { Issue.record("expected .oembed"); return }
  #expect(o.title == "L")
  #expect(o.width == 5)
}
