import Library
import UIKit

private enum Layout {
  enum IconSize {
    static let height: CGFloat = 18.0
    static let width: CGFloat = 18.0
  }

  static let interimSpacing = Styles.grid(1)
}

public struct PillsViewData: Equatable {
  public let interimLineSpacing: CGFloat
  public let interimPillSpacing: CGFloat
  public let margins: UIEdgeInsets
  public let pills: [PillData]
}

public struct PillData: Equatable {
  public let backgroundColor: UIColor
  public let font: UIFont
  public let margins: UIEdgeInsets
  public let text: String
  public let textColor: UIColor
  public let imageName: String?
}

private class PillView: UIView {
  private var data: PillData
  private var label = UILabel(frame: .zero)
  private var imageView: UIImageView?

  public init(with data: PillData) {
    self.data = data

    super.init(frame: .zero)

    self.layer.cornerRadius = Styles.grid(1)
    self.layer.masksToBounds = true

    self.label.numberOfLines = 0
    self.label.text = data.text
    self.label.textAlignment = data.imageName == nil ? .center : .left
    self.label.font = data.font
    self.label.textColor = data.textColor
    self.backgroundColor = data.backgroundColor

    self.addSubview(self.label)

    if let imageName = data.imageName {
      let imageView = UIImageView(image: Library.image(named: imageName, tintColor: data.textColor))
      self.imageView = imageView

      self.addSubview(imageView)
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    if let imageView = self.imageView {
      let imageViewY = (self.bounds.height / 2) - (Layout.IconSize.height / 2)

      imageView.frame = CGRect(
        origin: CGPoint(x: self.data.margins.left, y: imageViewY),
        size: CGSize(width: Layout.IconSize.width, height: Layout.IconSize.height)
      )

      let labelWidth = self.bounds.width - (imageView.frame.width + Layout.interimSpacing)

      self.label.frame = CGRect(
        origin: CGPoint(x: imageView.frame.maxX + Layout.interimSpacing, y: self.bounds.minY),
        size: CGSize(width: labelWidth, height: self.bounds.height)
      )
    } else {
      self.label.frame = self.bounds
    }
  }

  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    guard let text = self.label.text else { return .zero }

    /**
     FIXME: Note, this is currently sufficient but needs some more work to support very long text
     in order to wrap correctly. We should add an `NSParagraphStyle` with word-wrapping options.
     */
    let textSize = (text as NSString).boundingRect(
      with: size,
      options: [.usesLineFragmentOrigin, .usesFontLeading],
      attributes: [.font: self.data.font],
      context: nil
    )

    let leftAndRightMargins = self.data.margins.left + self.data.margins.right
    let topAndBottomMargins = self.data.margins.top + self.data.margins.bottom

    let imageWidth = (self.imageView?.frame.size.width ?? 0)
    let imageWithToAccommodate = imageWidth > 0 ? (imageWidth + Layout.interimSpacing) : 0

    return CGSize(
      width: textSize.width + leftAndRightMargins + imageWithToAccommodate,
      height: textSize.height + topAndBottomMargins
    )
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

public final class PillsView: UIView {
  private var heightCache = NSCache<UIView, NSValue>()
  private var data: PillsViewData?
  private var pillViews: [UIView] = []
  private var preferredSize: CGSize = .zero

  public func configure(with data: PillsViewData) {
    guard data != self.data else { return }

    self.heightCache.removeAllObjects()
    self.pillViews.forEach { $0.removeFromSuperview() }

    self.data = data
    self.pillViews = data.pills.map(PillView.init(with:))

    self.pillViews.forEach(self.addSubview(_:))
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    guard let data = self.data, !self.pillViews.isEmpty else { return }

    let leftAndRightMargins = data.margins.left + data.margins.right

    let constrainedSize = CGSize(
      width: self.bounds.size.width - leftAndRightMargins,
      height: UIView.noIntrinsicMetric
    )

    var x = data.margins.left
    var y = data.margins.top

    var pillsIterator = self.pillViews.makeIterator()

    var prevViewSize: CGSize?

    while let pillView = pillsIterator.next() {
      let size: CGSize

      if let cachedSize = self.heightCache.object(forKey: pillView) {
        size = cachedSize.cgSizeValue
      } else {
        size = pillView.sizeThatFits(constrainedSize)
        self.heightCache.setObject(NSValue(cgSize: size), forKey: pillView)
      }

      let nextMaxX = x + size.width
      let canFitOnLine = nextMaxX <= constrainedSize.width

      if !canFitOnLine {
        x = data.margins.left
        y += size.height + data.interimLineSpacing
      }

      pillView.frame = CGRect(
        origin: CGPoint(x: x, y: y),
        size: size
      )

      x += size.width + data.interimPillSpacing

      prevViewSize = size
    }

    self.preferredSize = CGSize(
      width: self.bounds.size.width,
      height: y + (prevViewSize?.height ?? 0) + data.margins.bottom
    )
  }

  public override var intrinsicContentSize: CGSize {
    self.layoutIfNeeded()

    return self.preferredSize
  }
}
