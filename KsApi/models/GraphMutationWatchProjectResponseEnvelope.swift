import Foundation

public struct GraphMutationWatchProjectResponseEnvelope: Decodable {
  public private(set) var watchProject: WatchProject

  public struct WatchProject: Decodable {
    public private(set) var project: Project

    public struct Project: Decodable {
      public private(set) var id: String
      public private(set) var isWatched: Bool
    }
  }
}

public struct CreatePaymentMethodEnvelope: Decodable {
  public private(set) var createPaymentSource: CreatePaymentSource

  public struct CreatePaymentSource: Decodable {
    public private(set) var errorMessage: String
    public private(set) var isSuccessful: Bool
  }
}

extension CreatePaymentMethodEnvelope {
  private enum CodingKeys: String, CodingKey {
    case
    createPaymentSource,
    errorMessage,
    isSuccessful
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.createPaymentSource = try values.decode(CreatePaymentSource.self, forKey: .createPaymentSource)
  }
}
