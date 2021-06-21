import Foundation

extension GraphCommentsEnvelope {
  static let template = GraphCommentsEnvelope(
    comments: [.template, .template, .template],
    cursor: "WzMwNDkwNDY0XQ==",
    hasNextPage: true,
    slug: "jadelabo-j1-beautiful-powerful-and-smart-idex-3d-printer",
    totalCount: 100
  )

  static let projectUpdateTemplate = GraphCommentsEnvelope(
    comments: [.template, .template, .template],
    cursor: "WzMwNDkwNDY0XQ==",
    hasNextPage: true,
    slug: nil,
    totalCount: 100,
    updateID: "GDgOaVFgU4ODDGdfS="
  )
}
