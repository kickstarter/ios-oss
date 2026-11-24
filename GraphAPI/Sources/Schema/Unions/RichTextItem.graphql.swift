// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Unions {
  /// Rich text items: Text, Header, List, Photo, Audio, Video or Oembed.
  static let RichTextItem = Union(
    name: "RichTextItem",
    possibleTypes: [
      Objects.RichText.self,
      Objects.RichTextAudio.self,
      Objects.RichTextHeader.self,
      Objects.RichTextListClose.self,
      Objects.RichTextListItem.self,
      Objects.RichTextListOpen.self,
      Objects.RichTextOembed.self,
      Objects.RichTextPhoto.self,
      Objects.RichTextVideo.self
    ]
  )
}