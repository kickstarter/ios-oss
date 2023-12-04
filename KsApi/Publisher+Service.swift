import Combine
import Foundation

extension Publisher {
  /// A convenience method for mapping the results of your fetch to another data type. Any unknown errors are returned in the error as `ErrorEnvelope.couldNotParseJSON`.
  func mapFetchResults<NewOutputType>(_ convertData: @escaping ((Output) -> NewOutputType?))
    -> AnyPublisher<NewOutputType, ErrorEnvelope> {
    return self.tryMap { (data: Output) -> NewOutputType in
      guard let envelope = convertData(data) else {
        throw ErrorEnvelope.couldNotParseJSON
      }

      return envelope
    }
    .mapError { rawError in

      if let error = rawError as? ErrorEnvelope {
        return error
      }

      return ErrorEnvelope.couldNotParseJSON
    }
    .eraseToAnyPublisher()
  }
}
