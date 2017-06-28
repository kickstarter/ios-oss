import Prelude

extension UpdateDraft {
  public enum lens {
    public static let update = Lens<UpdateDraft, Update>(
      view: { $0.update },
      set: { UpdateDraft(update: $0, images: $1.images, video: $1.video) }
    )

    public static let images = Lens<UpdateDraft, [UpdateDraft.Image]>(
      view: { $0.images },
      set: { UpdateDraft(update: $1.update, images: $0, video: $1.video) }
    )

    public static let video = Lens<UpdateDraft, UpdateDraft.Video?>(
      view: { $0.video },
      set: { UpdateDraft(update: $1.update, images: $1.images, video: $0) }
    )
  }
}

extension UpdateDraft.Image {
  public enum lens {
    public static let id = Lens<UpdateDraft.Image, Int>(
      view: { $0.id },
      set: { UpdateDraft.Image(id: $0, thumb: $1.thumb, full: $1.full) }
    )

    public static let thumb = Lens<UpdateDraft.Image, String>(
      view: { $0.thumb },
      set: { UpdateDraft.Image(id: $1.id, thumb: $0, full: $1.full) }
    )

    public static let full = Lens<UpdateDraft.Image, String>(
      view: { $0.thumb },
      set: { UpdateDraft.Image(id: $1.id, thumb: $1.thumb, full: $0) }
    )
  }
}

extension UpdateDraft.Video {
  public enum lens {
    public static let id = Lens<UpdateDraft.Video, Int>(
      view: { $0.id },
      set: { UpdateDraft.Video(id: $0, status: $1.status, frame: $1.frame) }
    )

    public static let status = Lens<UpdateDraft.Video, Status>(
      view: { $0.status },
      set: { UpdateDraft.Video(id: $1.id, status: $0, frame: $1.frame) }
    )

    public static let frame = Lens<UpdateDraft.Video, String>(
      view: { $0.frame },
      set: { UpdateDraft.Video(id: $1.id, status: $1.status, frame: $0) }
    )
  }
}

extension Lens where Whole == UpdateDraft, Part == Update {
  public var id: Lens<UpdateDraft, Int> {
    return UpdateDraft.lens.update..Update.lens.id
  }

  public var projectId: Lens<UpdateDraft, Int> {
    return UpdateDraft.lens.update..Update.lens.projectId
  }

  public var title: Lens<UpdateDraft, String> {
    return UpdateDraft.lens.update..Update.lens.title
  }

  public var body: Lens<UpdateDraft, String?> {
    return UpdateDraft.lens.update..Update.lens.body
  }

  public var isPublic: Lens<UpdateDraft, Bool> {
    return UpdateDraft.lens.update..Update.lens.isPublic
  }

  public var sequence: Lens<UpdateDraft, Int> {
    return UpdateDraft.lens.update..Update.lens.sequence
  }
}
