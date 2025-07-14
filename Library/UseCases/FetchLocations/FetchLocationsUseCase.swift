import GraphAPI
import KsApi
import ReactiveSwift

public protocol FetchLocationsUseCaseType {
  var inputs: FetchLocationsUseCaseInputs { get }
  var dataOutputs: FetchLocationsUseCaseDataOutputs { get }
}

public protocol FetchLocationsUseCaseInputs {
  /// Call this when the user types a location query string in the location filter
  func searchedForLocations(_ query: String)
}

public protocol FetchLocationsUseCaseDataOutputs {
  /// Emits the list of default locations. Emits empty array on initial signal.
  var defaultLocations: Signal<[Location], Never> { get }

  /// Emits locations related to the query inputted with `searchedForLocations`. Emits empty array on initial signal.
  var suggestedLocations: Signal<[Location], Never> { get }
}

/// A use case for fetching locations for the purpose of filtering projects.
public final class FetchLocationsUseCase: FetchLocationsUseCaseType, FetchLocationsUseCaseInputs,
  FetchLocationsUseCaseDataOutputs {
  public init(initialSignal: Signal<Void, Never>) {
    let emptyArrayOnInitialSignal: Signal<[KsApi.Location], Never>
      = initialSignal.mapConst([])

    let defaultLocationsQuery = initialSignal
      .switchMap {
        let defaultLocations = GraphAPI.DefaultLocationsQuery(first: 5)
        return AppEnvironment.current.apiService.fetch(query: defaultLocations).materialize()
      }
      .values()
      .map { data in
        KsApi.Location.locations(from: data)
      }

    self.defaultLocations = Signal.merge(emptyArrayOnInitialSignal, defaultLocationsQuery)

    let locationQuery = self.locationQuerySignal.filter { !$0.isEmpty }
    let emptyLocationQuery: Signal<[Location], Never> = self.locationQuerySignal.filter { $0.isEmpty }
      .mapConst([])

    let suggestedLocationsQuery = locationQuery
      .switchMap { queryText in
        let query = GraphAPI.LocationsByTermQuery(term: GraphQLNullable.some(queryText), first: 10)
        return AppEnvironment.current.apiService.fetch(query: query).materialize()
      }
      .values()
      .map { data in
        KsApi.Location.locations(from: data)
      }

    self.suggestedLocations = Signal.merge(
      emptyArrayOnInitialSignal,
      suggestedLocationsQuery,
      emptyLocationQuery
    )
  }

  private let (locationQuerySignal, locationQueryObserver) = Signal<String, Never>.pipe()
  public func searchedForLocations(_ query: String) {
    self.locationQueryObserver.send(value: query)
  }

  public let defaultLocations: Signal<[Location], Never>
  public let suggestedLocations: Signal<[Location], Never>

  public var inputs: FetchLocationsUseCaseInputs { return self }
  public var dataOutputs: FetchLocationsUseCaseDataOutputs { return self }
}
