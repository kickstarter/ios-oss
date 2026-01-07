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

  /// A convenience method for gracefully catching API failures.
  /// If you handle your API failure in receiveCompletion:, that will actually cancel the entire pipeline, which means the failed request can't be retried.
  /// This is a wrapper around the .catch operator, which just makes it a bit easier to read.
  ///
  /// An example:
  /// ```
  /// self.somethingHappened
  ///    .flatMap() { _ in
  ///        self.doAnAPIRequest
  ///            .handleFailureAndAllowRetry() { e in
  ///               showTheError(e)
  ///            }
  ///    }

  public func handleFailureAndAllowRetry(_ onFailure: @escaping (Self.Failure) -> Void)
    -> AnyPublisher<Self.Output, Never> {
    return self.catch { e in
      onFailure(e)
      return Empty<Self.Output, Never>()
    }
    .eraseToAnyPublisher()
  }
}
