import Prelude

extension Project.Video {
  public enum lens {
    public static let id = Lens<Project.Video, Int>(
      view: { $0.id },
      set: { .init(id: $0, high: $1.high) }
    )

    public static let high = Lens<Project.Video, String>(
      view: { $0.high },
      set: { .init(id: $1.id, high: $0) }
    )
  }
}
