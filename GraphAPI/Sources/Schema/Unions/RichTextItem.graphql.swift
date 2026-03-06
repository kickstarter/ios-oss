// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Unions {
  /// Rich text items: Text, Header, List, Photo, Audio, Video or Oembed.
  static let RichTextItem = Union(
    name: "RichTextItem",
    possibleTypes: [
      Objects.RichText.self,
      Objects.RichTextHeader.self,
      Objects.RichTextListItem.self,
      Objects.RichTextListOpen.self,
      Objects.RichTextListClose.self,
      Objects.RichTextPhoto.self,
      Objects.RichTextAudio.self,
      Objects.RichTextVideo.self,
      Objects.RichTextOembed.self
    ]
  )
}