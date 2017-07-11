import Argo
import Curry
import Runes

extension Project.Video: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Project.Video> {
    return curry(Project.Video.init)
      <^> json <| "id"
      <*> json <| "high"
  }
}
