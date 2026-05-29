import ApolloAPI
import ReactiveSwift

public protocol ApolloClientType {
  func fetch<Query: GraphQLQuery>(query: Query, cache: Bool) -> SignalProducer<Query.Data, ErrorEnvelope>
  func perform<Mutation: GraphQLMutation>(mutation: Mutation) -> SignalProducer<Mutation.Data, ErrorEnvelope>
}
