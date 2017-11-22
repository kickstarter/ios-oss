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

extension KsApi.RootCategoriesEnvelope.Category {
  internal static let template = RootCategoriesEnvelope.Category(id: ID.art, name: Name.art)

  internal static let art = RootCategoriesEnvelope.Category.template
    |> \.subcategories
    .~ RootCategoriesEnvelope.Category.SubcategoryConnection(totalCount: 1, nodes: [.illustration])

  internal static let filmAndVideo = RootCategoriesEnvelope.Category.template
    |> \.id .~ ID.film
    |> \.name .~ Name.film
    |> \.subcategories
    .~ RootCategoriesEnvelope.Category.SubcategoryConnection(totalCount: 1, nodes: [.documentary])

  internal static let games = RootCategoriesEnvelope.Category.template
    |> \.id .~ ID.games
    |> \.name .~ Name.games
    |> \.subcategories
    .~ RootCategoriesEnvelope.Category.SubcategoryConnection(totalCount: 1, nodes: [.tabletopGames])

  internal static let illustration = RootCategoriesEnvelope.Category.template
    |> \.id .~ ID.illustration
    |> \.name .~ Name.illustration
    |> \.parentId .~ ID.art
    |> RootCategoriesEnvelope.Category.lens.parent .~ ParentCategory(id: ID.art, name: Name.art)

  internal static let documentary = RootCategoriesEnvelope.Category.template
    |> \.id .~ ID.documentary
    |> \.name .~ Name.documentary
    |> \.parentId .~ ID.film
    |> RootCategoriesEnvelope.Category.lens.parent .~ ParentCategory(id: ID.film, name: Name.film)

  internal static let tabletopGames = RootCategoriesEnvelope.Category.template
    |> \.id .~ ID.tabletop
    |> \.name .~ Name.tabletop
    |> \.parentId .~ ID.games
    |> RootCategoriesEnvelope.Category.lens.parent .~ ParentCategory(id: ID.games, name: Name.games)
}
