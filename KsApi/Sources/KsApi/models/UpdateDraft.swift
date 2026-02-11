

public struct UpdateDraft {
  public let update: Update
  public let images: [Image]
  public let video: Video?

  public enum Attachment {
    case image(Image)
    case video(Video)
  }

  public struct Image {
    public let id: Int
    public let thumb: String
    public let full: String
  }

  public struct Video {
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

extension UpdateDraft: Decodable {
  enum CodingKeys: String, CodingKey {
    case images
    case video
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.update = try Update(from: decoder)
    self.images = try values.decode([Image].self, forKey: .images)
    self.video = try values.decodeIfPresent(Video.self, forKey: .video)
  }
}

extension UpdateDraft.Image: Decodable {}
extension UpdateDraft.Video: Decodable {}
extension UpdateDraft.Video.Status: Decodable {}
