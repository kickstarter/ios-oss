import Prelude

private struct ID {
  fileprivate static let art = "Q2F0ZWdvcnktMQ=="
  fileprivate static let documentary = "Q2F0ZWdvcnktMzA="
  fileprivate static let film = "Q2F0ZWdvcnktMTE="
  fileprivate static let games = "Q2F0ZWdvcnktMTI="
  fileprivate static let illustration = "Q2F0ZWdvcnktMjI="
  fileprivate static let tabletop = "Q2F0ZWdvcnktMzQ="
}

private struct Name {
  fileprivate static let art = "Art"
  fileprivate static let documentary = "Documentary"
  fileprivate static let film = "Film & Video"
  fileprivate static let games = "Games"
  fileprivate static let illustration = "Illustration"
  fileprivate static let tabletop = "Tabletop Games"
}

extension KsApi.Category {
  internal static let template = Category(id: ID.art, name: Name.art)

  internal static let art = Category.template
    |> \.subcategories
    .~ Category.SubcategoryConnection(totalCount: 1, nodes: [.illustration])

  internal static let filmAndVideo = Category.template
    |> \.id .~ ID.film
    |> \.name .~ Name.film
    |> \.subcategories
    .~ Category.SubcategoryConnection(totalCount: 1, nodes: [.documentary])

  internal static let games = Category.template
    |> \.id .~ ID.games
    |> \.name .~ Name.games
    |> \.subcategories
    .~ Category.SubcategoryConnection(totalCount: 1, nodes: [.tabletopGames])

  internal static let illustration = Category.template
    |> \.id .~ ID.illustration
    |> \.name .~ Name.illustration
    |> \.parentId .~ ID.art
    |> Category.lens.parent .~ ParentCategory(id: ID.art, name: Name.art)

  internal static let documentary = Category.template
    |> \.id .~ ID.documentary
    |> \.name .~ Name.documentary
    |> \.parentId .~ ID.film
    |> Category.lens.parent .~ ParentCategory(id: ID.film, name: Name.film)

  internal static let tabletopGames = Category.template
    |> \.id .~ ID.tabletop
    |> \.name .~ Name.tabletop
    |> \.parentId .~ ID.games
    |> Category.lens.parent .~ ParentCategory(id: ID.games, name: Name.games)
}
