import Prelude

public struct ImageViewElement: HTMLViewElement {
  public let src: String
  public let href: String?
  public let caption: String?
  public var data: Data?
}

extension ImageViewElement {
  public enum lens {
    public static let data = Lens<ImageViewElement, Data?>(
      view: { $0.data },
      set: { ImageViewElement(
        src: $1.src,
        href: $1.href,
        caption: $1.caption,
        data: $0
      )
      }
    )
  }
}
