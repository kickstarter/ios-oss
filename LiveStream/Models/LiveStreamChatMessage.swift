// swiftlint:disable type_name
import Argo
import Curry
import Prelude
import Runes

internal extension Collection where Iterator.Element == LiveStreamChatMessage {
  static func decode(_ snapshots: [FirebaseDataSnapshotType]) -> [LiveStreamChatMessage] {
    return snapshots.flatMap { snapshot in
      LiveStreamChatMessage.decode(snapshot).value
    }
  }
}

public struct LiveStreamChatMessage {
  public fileprivate(set) var id: String
  public fileprivate(set) var message: String
  public fileprivate(set) var name: String
  public fileprivate(set) var profilePictureUrl: String
  public fileprivate(set) var date: TimeInterval
  public fileprivate(set) var userId: Int

  static internal func decode(_ snapshot: FirebaseDataSnapshotType) ->
    Decoded<LiveStreamChatMessage> {
      return (snapshot.value as? [String:Any])
        .map { self.decode(JSON($0.withAllValuesFrom(["id": snapshot.key]))) }
        .coalesceWith(.failure(.custom("Unable to parse Firebase snapshot.")))
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
      <*> ((json <| "userId") >>- convertId)

    return tmp2
  }
}

// Currently chat user ID's are prefixed with "id_" and are strings, doing this until that changes
private func convertId(fromJson json: JSON) -> Decoded<Int> {
  switch json {
  case .string(let string):
    if string.hasPrefix("id_") {
      return Int(string.replacingOccurrences(of: "id_", with: ""))
        .map(Decoded.success)
        .coalesceWith(.failure(.custom("Couldn't decoded \"\(string)\" into Int.")))
    }

    return Int(string)
      .map(Decoded.success)
      .coalesceWith(.failure(.custom("Couldn't decoded \"\(string)\" into Int.")))
  case .number(let number):
    return .success(number.intValue)
  default:
    return .failure(.custom("Couldn't decoded Int."))
  }
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
