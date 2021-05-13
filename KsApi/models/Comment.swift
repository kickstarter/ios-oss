import Foundation

public struct Comment: Decodable, Equatable {
  public var author: Author
  public var body: String
  public var id: String
  public var uid: Int
  public var replyCount: Int

  public struct Author: Decodable, Equatable {
    public var id: String
    public var isCreator: Bool
    public var name: String
  }
}
