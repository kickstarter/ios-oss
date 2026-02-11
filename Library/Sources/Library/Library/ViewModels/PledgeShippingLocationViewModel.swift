import Foundation
import GraphAPI
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public struct PledgeShippingLocationViewData {
  let project: Project
  let selectedLocationId: Int?
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
  var notifyDelegateOfSelectedShippingLocation: Signal<Location, Never> { get }
  var shimmerLoadingViewIsHidden: Signal<Bool, Never> { get }
  var shippingLocationButtonTitle: Signal<String, Never> { get }
  var shippingRulesError: Signal<String, Never> { get }
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

    let project = configData
      .map { $0.project }
    let selectedLocationId = configData
      .map { $0.selectedLocationId }

    let shippingShouldBeginLoading = project
      .mapConst(true)

    let locationsQuery = project
      .switchMap { project in
        shippableLocations(forProject: project.id).materialize()
      }

    let loadedLocations = locationsQuery.values()
    let erroredLocations = locationsQuery.errors()

    let shippingRulesLoadingCompleted = Signal.merge(
      loadedLocations.ignoreValues(),
      erroredLocations.ignoreValues()
    ).mapConst(false)

    let isLoading = Signal.merge(
      shippingShouldBeginLoading,
      shippingRulesLoadingCompleted
    )

    self.adaptableStackViewIsHidden = isLoading
    self.shimmerLoadingViewIsHidden = isLoading.negate()

    let initialShippingLocation = Signal.combineLatest(
      project,
      loadedLocations,
      selectedLocationId
    )
    .map(determineShippingLocation)

    self.shippingRulesError = erroredLocations
      .mapConst(Strings.We_were_unable_to_load_the_shipping_destinations())

    self.notifyDelegateOfSelectedShippingLocation = Signal.merge(
      initialShippingLocation.skipNil(),
      self.shippingLocationUpdatedSignal
    )

    self.presentShippingLocations = Signal.combineLatest(
      loadedLocations,
      self.notifyDelegateOfSelectedShippingLocation
    )
    .takeWhen(self.shippingLocationButtonTappedSignal)

    self.shippingLocationButtonTitle = self.notifyDelegateOfSelectedShippingLocation
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
  public let notifyDelegateOfSelectedShippingLocation: Signal<Location, Never>
  public let shimmerLoadingViewIsHidden: Signal<Bool, Never>
  public let shippingLocationButtonTitle: Signal<String, Never>
  public let shippingRulesError: Signal<String, Never>

  public var inputs: PledgeShippingLocationViewModelInputs { return self }
  public var outputs: PledgeShippingLocationViewModelOutputs { return self }
}

// MARK: - Functions

private func shippingValue(of project: Project, with shippingRuleCost: Double) -> NSAttributedString? {
  let defaultAttributes = checkoutCurrencyDefaultAttributes()
  let superscriptAttributes = checkoutCurrencySuperscriptAttributes()
  guard
    let attributedCurrency = Format.attributedCurrency(
      shippingRuleCost,
      currencyCode: project.statsCurrency,
      omitCurrencyCode: project.stats.omitUSCurrencyCode,
      defaultAttributes: defaultAttributes,
      superscriptAttributes: superscriptAttributes
    ) else { return nil }

  let combinedAttributes = defaultAttributes.merging(superscriptAttributes) { _, new in new }

  return Format.attributedPlusSign(combinedAttributes) + attributedCurrency
}

private func determineShippingLocation(
  with project: Project,
  locations: [Location],
  selectedLocationId: Int?
) -> Location? {
  if
    let locationId = selectedLocationId ?? project.personalization.backing?.locationId,
    let selectedShippingLocation = locations.first(where: { $0.id == locationId }) {
    return selectedShippingLocation
  }

  return defaultShippingLocation(fromLocations: locations)
}

private func shippableLocations(forProject pid: Int) -> SignalProducer<[Location], ErrorEnvelope> {
  let query = GraphAPI.ShippableLocationsForProjectQuery(id: pid)
  let producer = AppEnvironment.current.apiService.fetch(query: query)
    .map { data in
      let locations = Location.locations(from: data)
      return locations
    }
    .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)

  return producer
}
