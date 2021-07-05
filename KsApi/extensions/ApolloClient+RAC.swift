import Apollo
import Foundation
import ReactiveSwift

extension ApolloClient {
  /**
   Performs a GraphQL fetch request with a given query.

   - parameter query: The `Query` to fetch.

   - returns: A `SignalProducer` generic over `Query.Data` and `ErrorEnvelope`.
   */
  public func fetch<Query: GraphQLQuery>(query: Query) -> SignalProducer<Query.Data, ErrorEnvelope> {
    SignalProducer { observer, _ in
      self.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely) { result in
        switch result {
        case let .success(response):
          guard let data = response.data else {
            return observer.send(error: .couldNotParseJSON)
          }
          observer.send(value: data)
          observer.sendCompleted()
        case let .failure(error):
          observer.send(error: .couldNotDecodeJSON(error))
        }
      }
    }
  }

  /**
   Performs a GraphQL mutation request with a given mutation.

   - parameter mutation: The `Mutation` to perform.

   - returns: A `SignalProducer` generic over `Mutation.Data` and `ErrorEnvelope`.
   */
  public func perform<Mutation: GraphQLMutation>(
    mutation: Mutation
  ) -> SignalProducer<Mutation.Data, ErrorEnvelope> {
    SignalProducer { observer, _ in
      self.perform(mutation: mutation) { result in
        switch result {
        case let .success(response):
          guard let data = response.data else {
            return observer.send(error: .couldNotParseJSON)
          }
          observer.send(value: data)
          observer.sendCompleted()
        case let .failure(error):
          observer.send(error: .couldNotDecodeJSON(error))
        }
      }
    }
  }
}
