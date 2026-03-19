import Foundation
import GraphAPI
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public struct PledgeShippingLocationViewData {
  /// Project ID
  let pid: Int
  /// Initial selected location
  let selectedLocationId: Int?
  /// Whether or not the project has any rewards that require shipping.
  let hasShippableRewards: Bool

  public init(withProject project: Project) {
    self.pid = project.id
    self.selectedLocationId = project.personalization.backing?.locationId

    guard project.rewards.count > 0 else {
      assert(
        false,
        "Project has no rewards attached, so we don't know whether or not to show the shipping location."
      )

      self.hasShippableRewards = true
      return
    }

    // TODO: Clean up when a Project field for this is added (MBL-3150)
    self.hasShippableRewards = project.rewards
      .contains(where: { $0.shipping.enabled })
  }
}

public protocol PledgeShippingLocationViewModelInputs {
  func configureWith(data: PledgeShippingLocationViewData)
  func shippingLocationButtonTapped()
  func shippingLocationCancelButtonTapped()
  func shippingLocationUpdated(to rule: Location)
  func viewDidLoad()
}

public protocol PledgeShippingLocationViewModelOutputs {
  var adaptableStackViewIsHidden: Signal<Bool, Never> { get }
  var dismissShippingLocations: Signal<Void, Never> { get }
  var presentShippingLocations: Signal<([Location], Location), Never> { get }
  var notifyDelegateOfSelectedShippingLocation: Signal<Location?, Never> { get }
  var shimmerLoadingViewIsHidden: Signal<Bool, Never> { get }
  var shippingLocationButtonTitle: Signal<String, Never> { get }
  var shippingRulesError: Signal<String, Never> { get }
  var shippingLocationViewHidden: Signal<Bool, Never> { get }
}

public protocol PledgeShippingLocationViewModelType {
  var inputs: PledgeShippingLocationViewModelInputs { get }
  var outputs: PledgeShippingLocationViewModelOutputs { get }
}

public final class PledgeShippingLocationViewModel: PledgeShippingLocationViewModelType,
  PledgeShippingLocationViewModelInputs,
  PledgeShippingLocationViewModelOutputs {
  public init() {
    let configData = Signal.combineLatest(
      self.configDataProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let selectedLocationId = configData
      .map { $0.selectedLocationId }

    // Hide the selector if the project has no shippable rewards.
    self.shippingLocationViewHidden = configData.map { data in
      !data.hasShippableRewards
    }

    let isLoading = MutableProperty(false)

    // TODO: It would make this page a bit faster if we fetched shippableLocationsExpanded earlier.
    // This could be fetched as part of the Project Page fetch, or part of ProjectFragment.
    let locationsQuery = configData
      .on(value: { _ in
        isLoading.value = true
      })
      .switchMap { data in
        shippableLocations(data: data).materialize()
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .on(completed: {
            isLoading.value = false
          })
      }

    let loadedLocations = locationsQuery.values()
    let erroredLocations = locationsQuery.errors()

    self.adaptableStackViewIsHidden = isLoading.signal
    self.shimmerLoadingViewIsHidden = isLoading.signal.negate()

    let initialShippingLocation = Signal.combineLatest(
      loadedLocations,
      selectedLocationId
    )
    .map(determineShippingLocation)

    self.shippingRulesError = erroredLocations
      .mapConst(Strings.We_were_unable_to_load_the_shipping_destinations())

    let selectedShippingLocation = Signal.merge(
      initialShippingLocation,
      self.shippingLocationUpdatedSignal.wrapInOptional()
    )

    self.notifyDelegateOfSelectedShippingLocation = selectedShippingLocation

    self.presentShippingLocations = Signal.combineLatest(
      loadedLocations,
      selectedShippingLocation.skipNil()
    )
    .takeWhen(self.shippingLocationButtonTappedSignal)

    self.shippingLocationButtonTitle = selectedShippingLocation
      .skipNil()
      .map { $0.localizedName }

    self.dismissShippingLocations = Signal.merge(
      self.shippingLocationCancelButtonTappedProperty.signal,
      self.shippingLocationUpdatedSignal.signal
        .ignoreValues()
        .ksr_debounce(.milliseconds(300), on: AppEnvironment.current.scheduler)
    )
  }

  private let configDataProperty = MutableProperty<PledgeShippingLocationViewData?>(nil)
  public func configureWith(data: PledgeShippingLocationViewData) {
    self.configDataProperty.value = data
  }

  private let (shippingLocationButtonTappedSignal, shippingLocationButtonTappedObserver)
    = Signal<Void, Never>.pipe()
  public func shippingLocationButtonTapped() {
    self.shippingLocationButtonTappedObserver.send(value: ())
  }

  private let shippingLocationCancelButtonTappedProperty = MutableProperty(())
  public func shippingLocationCancelButtonTapped() {
    self.shippingLocationCancelButtonTappedProperty.value = ()
  }

  private let (shippingLocationUpdatedSignal, shippingLocationUpdatedObserver) = Signal<Location, Never>
    .pipe()
  public func shippingLocationUpdated(to location: Location) {
    self.shippingLocationUpdatedObserver.send(value: location)
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let adaptableStackViewIsHidden: Signal<Bool, Never>
  public let dismissShippingLocations: Signal<Void, Never>
  public let presentShippingLocations: Signal<([Location], Location), Never>
  public let notifyDelegateOfSelectedShippingLocation: Signal<Location?, Never>
  public let shimmerLoadingViewIsHidden: Signal<Bool, Never>
  public let shippingLocationButtonTitle: Signal<String, Never>
  public let shippingRulesError: Signal<String, Never>
  public let shippingLocationViewHidden: Signal<Bool, Never>

  public var inputs: PledgeShippingLocationViewModelInputs { return self }
  public var outputs: PledgeShippingLocationViewModelOutputs { return self }
}

// MARK: - Functions

private func determineShippingLocation(
  locations: [Location],
  selectedLocationId: Int?
) -> Location? {
  if let locationId = selectedLocationId,
     let selectedShippingLocation = locations.first(where: { $0.id == locationId }) {
    return selectedShippingLocation
  }

  return defaultShippingLocation(fromLocations: locations)
}

private func shippableLocations(data: PledgeShippingLocationViewData)
  -> SignalProducer<[Location], ErrorEnvelope> {
  if !data.hasShippableRewards {
    return SignalProducer(value: [])
  }

  let query = GraphAPI.ShippableLocationsForProjectQuery(id: data.pid)
  let producer = AppEnvironment.current.apiService.fetch(query: query)
    .map { data in
      let locations = Location.locations(from: data)
      return locations
    }
  return producer
}
