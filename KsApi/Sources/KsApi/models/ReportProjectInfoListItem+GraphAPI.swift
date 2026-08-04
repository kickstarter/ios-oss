import GraphAPI

extension ReportProjectInfoListItem {
  /// Builds a display tree from the flat list returned by `FlaggingOptionsQuery`.
  public static func items(from data: GraphAPI.FlaggingOptionsQuery.Data) -> [ReportProjectInfoListItem] {
    let nodes = data.flaggingOptions
    let allIDs = Set(nodes.map { $0.id })

    // Recursively builds an item and all its children
    func makeItem(from node: GraphAPI.FlaggingOptionsQuery.Data.FlaggingOption) -> ReportProjectInfoListItem {
      let children = nodes
        .filter { $0.parentId == node.id }
        .map { makeItem(from: $0) }

      return ReportProjectInfoListItem(
        id: node.id,
        title: node.title,
        subtitle: node.subtitle ?? "",
        flaggingKind: node.kind?.value,
        placeholder: node.placeholder,
        subItems: children.isEmpty ? nil : children
      )
    }

    // Root nodes are those whose parent isn't in the list (e.g. parentId "project" is not a node itself)
    return nodes
      .filter { node in
        guard let parentId = node.parentId else { return true }

        return !allIDs.contains(parentId)
      }
      .map { makeItem(from: $0) }
  }
}
