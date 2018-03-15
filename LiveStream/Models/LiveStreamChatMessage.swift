import Argo
import Curry
import Prelude
import Runes

internal protocol FirebaseDataSnapshotType {
  var key: String { get }
  var value: Any? { get }
}

// Returns an empty array if any snapshot decodings fail
internal extension Collection where Iterator.Element == LiveStreamChatMessage {
  static func decode(_ snapshots: [FirebaseDataSnapshotType]) -> Decoded<[LiveStreamChatMessage]> {
    return .success(snapshots.flatMap { snapshot in
      LiveStreamChatMessage.decode(snapshot).value
    })
  }
}

public struct LiveStreamChatMessage {
  public fileprivate(set) var date: TimeInterval
  public fileprivate(set) var id: String
  public fileprivate(set) var isCreator: Bool?
  public fileprivate(set) var message: String
  public fileprivate(set) var name: String
  public fileprivate(set) var profilePictureUrl: String
  public fileprivate(set) var userId: String

  static internal func decode(_ snapshot: FirebaseDataSnapshotType) -> Decoded<LiveStreamChatMessage> {
      return (snapshot.value as? [String: Any])
        .map {
          self.decode(JSON($0.withAllValuesFrom(["id": snapshot.key])))
        }
        .coalesceWith(.failure(.custom("Unable to parse Firebase snapshot.")))
  }
}

extension LiveStreamChatMessage: Argo.Decodable {
  static public func decode(_ json: JSON) -> Decoded<LiveStreamChatMessage> {

    let tmp1 = curry(LiveStreamChatMessage.init)
      <^> json <| "timestamp"
      <*> json <| "id"
      <*> json <|? "creator"
      <*> json <| "message"

    let tmp2 = tmp1
      <*> json <| "name"
      <*> json <| "profilePic"
      <*> json <| "userId"

    return tmp2
  }
}

extension LiveStreamChatMessage: Equatable {
  static public func == (lhs: LiveStreamChatMessage, rhs: LiveStreamChatMessage) -> Bool {
    return lhs.id == rhs.id
  }
}

extension LiveStreamChatMessage {
  public enum lens {
    public static let id = Lens<LiveStreamChatMessage, String>(
      view: { $0.id },
      set: { var new = $1; new.id = $0; return new }
    )
    public static let isCreator = Lens<LiveStreamChatMessage, Bool?>(
      view: { $0.isCreator },
      set: { var new = $1; new.isCreator = $0; return new }
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
    public static let userId = Lens<LiveStreamChatMessage, String>(
      view: { $0.userId },
      set: { var new = $1; new.userId = $0; return new }
    )
  }
}
