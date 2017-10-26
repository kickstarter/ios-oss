import Prelude

fileprivate struct ID {
  static let art = "Q2F0ZWdvcnktMQ=="
  static let documentary = "Q2F0ZWdvcnktMzA="
  static let film = "Q2F0ZWdvcnktMTE="
  static let games = "Q2F0ZWdvcnktMTI="
  static let illustration = "Q2F0ZWdvcnktMjI="
  static let tabletop = "Q2F0ZWdvcnktMzQ="
}

fileprivate struct Name {
  static let art = "Art"
  static let documentary = "Documentary"
  static let film = "Film & Video"
  static let games = "Games"
  static let illustration = "Illustration"
  static let tabletop = "Tabletop Games"
} 

extension KsApi.RootCategoriesEnvelope.Category {
  internal static let template = RootCategoriesEnvelope.Category(
    id: ID.art,
    name: Name.art
  )

  internal static let art: RootCategoriesEnvelope.Category = template
    |> RootCategoriesEnvelope.Category.lens.subcategories
    .~ RootCategoriesEnvelope.Category.SubcategoryConnection(totalCount: 1, nodes: [.illustration])

  internal static let filmAndVideo: RootCategoriesEnvelope.Category = template
    |> RootCategoriesEnvelope.Category.lens.id .~ ID.film
    <> RootCategoriesEnvelope.Category.lens.name .~ Name.film
    <> RootCategoriesEnvelope.Category.lens.subcategories
    .~ RootCategoriesEnvelope.Category.SubcategoryConnection(totalCount: 1, nodes: [.documentary])

  internal static let games: RootCategoriesEnvelope.Category = template
    |> RootCategoriesEnvelope.Category.lens.id .~ ID.games
    <> RootCategoriesEnvelope.Category.lens.name .~ Name.games
    <> RootCategoriesEnvelope.Category.lens.subcategories
    .~ RootCategoriesEnvelope.Category.SubcategoryConnection(totalCount: 1, nodes: [.tabletopGames])

  internal static let illustration: RootCategoriesEnvelope.Category = template
    |> RootCategoriesEnvelope.Category.lens.id .~ ID.illustration
    <> RootCategoriesEnvelope.Category.lens.name .~ Name.illustration
    <> RootCategoriesEnvelope.Category.lens.parentId .~ ID.art
    <> RootCategoriesEnvelope.Category.lens.parent .~ ParentCategory(id: ID.art,
                                                                     name: Name.art)

  internal static let documentary: RootCategoriesEnvelope.Category = template
    |> RootCategoriesEnvelope.Category.lens.id .~ ID.documentary
    <> RootCategoriesEnvelope.Category.lens.name .~ Name.documentary
    <> RootCategoriesEnvelope.Category.lens.parentId .~ ID.film
    <> RootCategoriesEnvelope.Category.lens.parent .~ ParentCategory(id: ID.film,
                                                                     name: Name.film)

  internal static let tabletopGames: RootCategoriesEnvelope.Category = template
    |> RootCategoriesEnvelope.Category.lens.id .~ ID.tabletop
    <> RootCategoriesEnvelope.Category.lens.name .~ Name.tabletop
    <> RootCategoriesEnvelope.Category.lens.parentId .~ ID.games
    <> RootCategoriesEnvelope.Category.lens.parent .~ ParentCategory(id: ID.games,
                                                                     name: Name.games)
}
