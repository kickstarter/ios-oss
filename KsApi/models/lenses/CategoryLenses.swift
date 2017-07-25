import Prelude

extension Category {
  public enum lens {
    public static let id = Lens<Category, Int>(
      view: { $0.id },
      set: { Category(color: $1.color, id: $0, name: $1.name, parent: $1.parent, parentId: $1.parentId,
        position: $1.position, projectsCount: $1.projectsCount, slug: $1.slug) }
    )

    public static let name = Lens<Category, String>(
      view: { $0.name },
      set: { Category(color: $1.color, id: $1.id, name: $0, parent: $1.parent, parentId: $1.parentId,
        position: $1.position, projectsCount: $1.projectsCount, slug: $1.slug) }
    )

    public static let parent = Lens<Category, Category?>(
      view: { $0.parent },
      set: { Category(color: $1.color, id: $1.id, name: $1.name, parent: $0, parentId: $1.parentId,
        position: $1.position, projectsCount: $1.projectsCount, slug: $1.slug) }
    )

    public static let parentId = Lens<Category, Int?>(
      view: { $0.parentId },
      set: { Category(color: $1.color, id: $1.id, name: $1.name, parent: $1.parent, parentId: $0,
        position: $1.position, projectsCount: $1.projectsCount, slug: $1.slug) }
    )

    public static let position = Lens<Category, Int>(
      view: { $0.position },
      set: { Category(color: $1.color, id: $1.id, name: $1.name, parent: $1.parent,
        parentId: $1.parentId, position: $0, projectsCount: $1.projectsCount, slug: $1.slug) }
    )

    public static let projectsCount = Lens<Category, Int?>(
      view: { $0.projectsCount },
      set: { Category(color: $1.color, id: $1.id, name: $1.name, parent: $1.parent,
        parentId: $1.parentId, position: $1.position, projectsCount: $0, slug: $1.slug) }
    )

    public static let slug = Lens<Category, String>(
      view: { $0.slug },
      set: { Category(color: $1.color, id: $1.id, name: $1.name, parent: $1.parent,
        parentId: $1.parentId, position: $1.position, projectsCount: $1.projectsCount, slug: $0) }
    )
  }
}
