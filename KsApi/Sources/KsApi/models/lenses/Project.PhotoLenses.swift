import Prelude

extension Project.Photo {
  public enum lens {
    public static let full = Lens<Project.Photo, String>(
      view: { $0.full },
      set: { .init(full: $0, med: $1.med, size1024x768: $1.size1024x768, small: $1.small) }
    )

    public static let med = Lens<Project.Photo, String>(
      view: { $0.full },
      set: { .init(full: $1.full, med: $0, size1024x768: $1.size1024x768, small: $1.small) }
    )

    public static let size1024x768 = Lens<Project.Photo, String?>(
      view: { $0.size1024x768 },
      set: { .init(full: $1.full, med: $1.med, size1024x768: $0, small: $1.small) }
    )

    public static let small = Lens<Project.Photo, String>(
      view: { $0.small },
      set: { .init(full: $1.full, med: $1.med, size1024x768: $1.size1024x768, small: $0) }
    )
  }
}
