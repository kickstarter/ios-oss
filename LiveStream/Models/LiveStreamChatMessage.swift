// swiftlint:disable type_name
import Argo
import Curry
import Prelude
import Runes

public struct LiveStreamChatMessage {
  public fileprivate(set) var id: String
  public fileprivate(set) var message: String
  public fileprivate(set) var name: String
  public fileprivate(set) var profilePictureUrl: String
  public fileprivate(set) var date: TimeInterval
  public fileprivate(set) var userId: Int

  static internal func decode(_ snapshot: FirebaseDataSnapshotType) ->
    Decoded<LiveStreamChatMessage> {
    guard let value = snapshot.value as? [String:Any] else {
      return .failure(DecodeError.custom("Unable to parse message"))
    }

    let message: [String:Any] = ["id": snapshot.key]

    return self.decode(JSON(message.withAllValuesFrom(value)))
  }
}

extension LiveStreamChatMessage: Decodable {
  static public func decode(_ json: JSON) -> Decoded<LiveStreamChatMessage> {
    let create = curry(LiveStreamChatMessage.init)

    let tmp1 = create
      <^> json <| "id"
      <*> json <| "message"
      <*> json <| "name"

    let tmp2 = tmp1
      <*> json <| "profilePic"
      <*> json <| "timestamp"
      <*> ((json <| "userId") >>- toInt)

    return tmp2
  }
}

private func toInt(string: String) -> Decoded<Int> {
  // Currently chat user ID's are prefixed with "id_" and are strings, doing this until that changes
  // They should just be Int's
  let dropPrefix = string.replacingOccurrences(of: "id_", with: "")

  guard let userId = Int(dropPrefix) else {
    return .failure(DecodeError.custom("Unable to parse user ID"))
  }

  return .success(userId)
}

extension LiveStreamChatMessage {
  public enum lens {
    public static let id = Lens<LiveStreamChatMessage, String>(
      view: { $0.id },
      set: { var new = $1; new.id = $0; return new }
    )
    public static let message = Lens<LiveStreamChatMessage, String>(
      view: { $0.message },
      set: { var new = $1; new.message = $0; return new }
    )
    public static let name = Lens<LiveStreamChatMessage, String>(
      view: { $0.name },
      set: { var new = $1; new.name = $0; return new }
    )
    public static let profilePictureUrl = Lens<LiveStreamChatMessage, String>(
      view: { $0.profilePictureUrl },
      set: { var new = $1; new.profilePictureUrl = $0; return new }
    )
    public static let date = Lens<LiveStreamChatMessage, TimeInterval>(
      view: { $0.date },
      set: { var new = $1; new.date = $0; return new }
    )
    public static let userId = Lens<LiveStreamChatMessage, Int>(
      view: { $0.userId },
      set: { var new = $1; new.userId = $0; return new }
    )
  }
}
