import Argo
import Curry
import Runes

public struct UpdateDraft: Equatable {
  public let update: Update
  public let images: [Image]
  public let video: Video?

  public enum Attachment: Equatable {
    case image(Image)
    case video(Video)
  }

  public struct Image: Equatable {
    public let id: Int
    public let thumb: String
    public let full: String
  }

  public struct Video: Equatable {
    public let id: Int
    public let status: Status
    public let frame: String

    public enum Status: String {
      case processing
      case failed
      case successful
    }
  }
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

extension UpdateDraft.Video.Status: Argo.Decodable {}
