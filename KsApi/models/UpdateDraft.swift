import Argo
import Curry
import Runes

public struct UpdateDraft {
  public private(set) var update: Update
  public private(set) var images: [Image]
  public private(set) var video: Video?

  public enum Attachment {
    case image(Image)
    case video(Video)
  }

  public struct Image {
    public private(set) var id: Int
    public private(set) var thumb: String
    public private(set) var full: String
  }

  public struct Video {
    public private(set) var id: Int
    public private(set) var status: Status
    public private(set) var frame: String

    public enum Status: String {
      case processing
      case failed
      case successful
    }
  }
}

extension UpdateDraft: Equatable {}
public func == (lhs: UpdateDraft, rhs: UpdateDraft) -> Bool {
  return lhs.update.id == rhs.update.id
}

extension UpdateDraft.Attachment {
  public var id: Int {
    switch self {
    case let .image(image):
      return image.id
    case let .video(video):
      return video.id
    }
  }

  public var thumbUrl: String {
    switch self {
    case let .image(image):
      return image.full
    case let .video(video):
      return video.frame
    }
  }
}

extension UpdateDraft.Attachment: Equatable {}
public func == (lhs: UpdateDraft.Attachment, rhs: UpdateDraft.Attachment) -> Bool {
  return lhs.id == rhs.id
}

extension UpdateDraft: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<UpdateDraft> {
    return curry(UpdateDraft.init)
      <^> Update.decode(json)
      <*> json <|| "images"
      <*> json <|? "video"
  }
}

extension UpdateDraft.Image: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<UpdateDraft.Image> {
    return curry(UpdateDraft.Image.init)
      <^> json <| "id"
      <*> json <| "thumb"
      <*> json <| "full"
  }
}

extension UpdateDraft.Video: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<UpdateDraft.Video> {
    return curry(UpdateDraft.Video.init)
      <^> json <| "id"
      <*> json <| "status"
      <*> json <| "frame"
  }
}

extension UpdateDraft.Video.Status: Argo.Decodable {
}
