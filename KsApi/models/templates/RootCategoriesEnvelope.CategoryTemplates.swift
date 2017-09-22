import Prelude

extension KsApi.RootCategoriesEnvelope.Category {
  internal static let template = RootCategoriesEnvelope.Category(
    id: "Q2F0ZWdvcnktMQ==",
    name: "Art",
    parentId: nil,
    subcategories: RootCategoriesEnvelope.Category.SubcategoryConnection(totalCount: 0,
                                                                         nodes: []),
    totalProjectCount: 0
  )

  internal static let art = template
    |> RootCategoriesEnvelope.Category.lens.id .~ "Q2F0ZWdvcnktMQ=="
    <> RootCategoriesEnvelope.Category.lens.name .~ "Art"

  internal static let filmAndVideo = template
    |> RootCategoriesEnvelope.Category.lens.id .~ "Q2F0ZWdvcnktMTE="
    <> RootCategoriesEnvelope.Category.lens.name .~ "Film & Video"

  internal static let games = template
    |> RootCategoriesEnvelope.Category.lens.id .~ "Q2F0ZWdvcnktMTI="
    <> RootCategoriesEnvelope.Category.lens.name .~ "Games"

  internal static let illustration = template
    |> RootCategoriesEnvelope.Category.lens.id .~ "Q2F0ZWdvcnktMjI="
    <> RootCategoriesEnvelope.Category.lens.name .~ "Illustration"
    <> RootCategoriesEnvelope.Category.lens.parentId .~ RootCategoriesEnvelope.Category.art.id

  internal static let documentary = template
    |> RootCategoriesEnvelope.Category.lens.id .~ "Q2F0ZWdvcnktMzA="
    <> RootCategoriesEnvelope.Category.lens.name .~ "Documentary"
    <> RootCategoriesEnvelope.Category.lens.parentId .~ RootCategoriesEnvelope.Category.filmAndVideo.id

  internal static let tabletopGames = template
    |> RootCategoriesEnvelope.Category.lens.id .~ "Q2F0ZWdvcnktMzQ="
    <> RootCategoriesEnvelope.Category.lens.name .~ "Tabletop Games"
    <> RootCategoriesEnvelope.Category.lens.parentId .~ RootCategoriesEnvelope.Category.games.id
}

