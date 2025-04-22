import SwiftUI

/// Lays out subviews in a wrapping layout, similar to a list of `<span>` tags on
/// a webpage. Each row will fill its width until it needs to wrap to the next line.
public struct FlowLayout: Layout {
  private var horizontalSpacing: CGFloat
  private var verticalSpacing: CGFloat
  private var alignment: HorizontalAlignment

  public init(
    spacing: CGFloat = 0,
    alignment: HorizontalAlignment = .leading
  ) {
    self.horizontalSpacing = spacing
    self.verticalSpacing = spacing
    self.alignment = alignment
  }

  public init(
    horizontalSpacing: CGFloat = 0,
    verticalSpacing: CGFloat = 0,
    alignment: HorizontalAlignment = .leading
  ) {
    self.horizontalSpacing = horizontalSpacing
    self.verticalSpacing = verticalSpacing
    self.alignment = alignment
  }

  public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
    let containerWidth = proposal.width ?? .infinity

    var rowWidths: [CGFloat] = [0]
    var rowHeights: [CGFloat] = [0]
    var currentRowIndex = 0

    // Calculate positions and determine size
    for subview in subviews {
      let size = subview.sizeThatFits(.unspecified)

      // If this view doesn't fit on the current row, move to the next row
      if rowWidths[currentRowIndex] + size.width > containerWidth && rowWidths[currentRowIndex] > 0 {
        currentRowIndex += 1
        rowWidths.append(0)
        rowHeights.append(0)
      }

      // Add the view to the current row
      rowWidths[currentRowIndex] += size.width + (rowWidths[currentRowIndex] > 0 ? self.horizontalSpacing : 0)
      rowHeights[currentRowIndex] = max(rowHeights[currentRowIndex], size.height)
    }

    // Calculate total height
    let totalLineSpacing = (rowHeights.count > 1 ? self.verticalSpacing * CGFloat(rowHeights.count - 1) : 0)
    let totalHeight = rowHeights.reduce(0, +) + totalLineSpacing

    // Return the size
    return CGSize(
      width: proposal.width ?? rowWidths.max() ?? 0,
      height: totalHeight
    )
  }

  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache _: inout ()
  ) {
    let containerWidth = bounds.width

    var rowWidths: [CGFloat] = []
    var rowHeights: [CGFloat] = []
    var rowViewCount: [Int] = []
    var viewSizes: [CGSize] = []

    // First pass: determine rows and collect sizes
    var currentRowWidth: CGFloat = 0
    var currentRowHeight: CGFloat = 0
    var currentRowViewCount = 0

    for subview in subviews {
      let size = subview.sizeThatFits(.unspecified)
      viewSizes.append(size)

      // Check if this view needs to go on a new row
      if currentRowWidth + size.width > containerWidth && currentRowWidth > 0 {
        // Save the current row info
        rowWidths.append(currentRowWidth)
        rowHeights.append(currentRowHeight)
        rowViewCount.append(currentRowViewCount)

        // Reset for the new row
        currentRowWidth = size.width
        currentRowHeight = size.height
        currentRowViewCount = 1
      } else {
        // Add to the current row
        currentRowWidth += size.width + (currentRowWidth > 0 ? self.horizontalSpacing : 0)
        currentRowHeight = max(currentRowHeight, size.height)
        currentRowViewCount += 1
      }
    }

    // Add the last row if it has any views
    if currentRowViewCount > 0 {
      rowWidths.append(currentRowWidth)
      rowHeights.append(currentRowHeight)
      rowViewCount.append(currentRowViewCount)
    }

    // Second pass: place the views
    var viewIndex = 0
    var yOffset = bounds.minY

    for rowIndex in 0..<rowWidths.count {
      let rowHeight = rowHeights[rowIndex]
      var xOffset = bounds.minX

      // Adjust xOffset based on alignment
      if self.alignment == .center {
        xOffset += (containerWidth - rowWidths[rowIndex]) / 2
      } else if self.alignment == .trailing {
        xOffset += containerWidth - rowWidths[rowIndex]
      }

      // Place views in this row
      for _ in 0..<rowViewCount[rowIndex] {
        let viewSize = viewSizes[viewIndex]
        let viewYOffset = yOffset + (rowHeight - viewSize.height) / 2

        subviews[viewIndex].place(
          at: CGPoint(x: xOffset, y: viewYOffset),
          anchor: .topLeading,
          proposal: ProposedViewSize(width: viewSize.width, height: viewSize.height)
        )

        xOffset += viewSize.width + self.horizontalSpacing
        viewIndex += 1
      }

      yOffset += rowHeight + self.verticalSpacing
    }
  }
}
