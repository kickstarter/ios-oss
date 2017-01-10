import Foundation
import UIKit

/**
 Returns a UIView consisting of many rectangles of colors with their labels printed on them.

 - parameter colors:       An array of colors to put in the UIView.
 - parameter size:         The size of the UIView
 - parameter columnsCount: Number of columns to use in the palette.
 */
public func colorPalette(colors: [(color: UIColor, name: String)],
  size: CGSize = CGSize(width: 800.0, height: 400.0),
  columnsCount: Int = 6)
  -> UIView {

  let palette = UIView(frame: CGRect(origin: .zero, size: size))
  palette.backgroundColor = .clear

  let rowsCount = Int(ceil(Float(colors.count) / Float(columnsCount)))
  let columnWidth = palette.frame.width / CGFloat(columnsCount)
  let rowHeight = palette.frame.height / CGFloat(rowsCount)

  let tiles = colors.enumerated().map { idx, data -> UIView in
    let row = Int(idx / columnsCount)
    let column = idx % columnsCount

    let view = UIView(frame: CGRect(
      x: CGFloat(column) * columnWidth,
      y: CGFloat(row) * rowHeight,
      width: columnWidth,
      height: rowHeight
      )
    )
    view.backgroundColor = data.color

    let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 20.0))
    label.text = data.name
    label.textColor = data.color._white < 0.5 ? .white : .black
    view.addSubview(label)

    return view
  }

  tiles.forEach(palette.addSubview)

  return palette
}
