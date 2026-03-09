import Foundation
import GraphAPI
@testable import KsApi
@testable import KsApiTestHelpers
@testable import Library
@testable import LibraryTestHelpers
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class PledgeShippingLocationViewModelTests: TestCase {
  private let vm: PledgeShippingLocationViewModelType = PledgeShippingLocationViewModel()

  private let adaptableStackViewIsHidden = TestObserver<Bool, Never>()
  private let dismissShippingLocations = TestObserver<Void, Never>()
  private let presentShippingLocationsAllLocations = TestObserver<[Location], Never>()
  private let presentShippingLocationsSelectedLocation = TestObserver<Location, Never>()
  private let notifyDelegateOfSelectedShippingLocation = TestObserver<Location?, Never>()
  private let notifyDelegateOfRewardFilterLocation = TestObserver<String, Never>()
  private let shimmerLoadingViewIsHidden = TestObserver<Bool, Never>()
  private let shippingLocationButtonTitle = TestObserver<String, Never>()
  private let shippingRulesError = TestObserver<String, Never>()
  private let shippingLocationViewHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.adaptableStackViewIsHidden.observe(self.adaptableStackViewIsHidden.observer)
    self.vm.outputs.dismissShippingLocations.observe(self.dismissShippingLocations.observer)
    self.vm.outputs.shimmerLoadingViewIsHidden.observe(self.shimmerLoadingViewIsHidden.observer)
    self.vm.outputs.presentShippingLocations.map { $0.0 }
      .observe(self.presentShippingLocationsAllLocations.observer)
    self.vm.outputs.presentShippingLocations.map { $0.1 }
      .observe(self.presentShippingLocationsSelectedLocation.observer)
    self.vm.outputs.notifyDelegateOfSelectedShippingLocation
      .observe(self.notifyDelegateOfSelectedShippingLocation.observer)
    self.vm.outputs.notifyDelegateOfRewardFilterLocation
      .observe(self.notifyDelegateOfRewardFilterLocation.observer)
    self.vm.outputs.shippingLocationButtonTitle.observe(self.shippingLocationButtonTitle.observer)
    self.vm.outputs.shippingRulesError.observe(self.shippingRulesError.observer)
    self.vm.outputs.shippingLocationViewHidden.observe(self.shippingLocationViewHidden.observer)
  }

  func testDefaultShippingRule_ProjectCountryEqualsProjectCurrencyCountry_US() {
    let mockService = MockService(fetchGraphQLResponses: [
      (ShippableLocationsForProjectQuery.self, threeShippableCountries)
    ])

    let reward = Reward.shipsToUSAReward

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    withEnvironment(apiService: mockService, countryCode: "US") {
      self.vm.inputs.configureWith(data: PledgeShippingLocationViewData(withProject: project))
      self.vm.inputs.viewDidLoad()

      self.adaptableStackViewIsHidden.assertValues([true])
      self.shimmerLoadingViewIsHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingLocation.assertDidNotEmitValue()
      self.notifyDelegateOfRewardFilterLocation.assertValues(["US"])
      self.shippingLocationButtonTitle.assertValues([])

      self.scheduler.advance()

      self.adaptableStackViewIsHidden.assertValues([true, false])
      self.shimmerLoadingViewIsHidden.assertValues([false, true])
      self.shippingLocationViewHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingLocation.assertValues(
        [Location.usa],
        "Because the user has an environment with a US country code, their default location should be the USA."
      )
      self.notifyDelegateOfRewardFilterLocation.assertValues(["US"])
      self.shippingLocationButtonTitle.assertValues(["United States"])
      self.shippingRulesError.assertDidNotEmitValue()
    }
  }

  func testDefaultShippingRule_US_ProjectCountry_NonUSProjectCurrencyCountry_US_UserLocation() {
    let mockService = MockService(fetchGraphQLResponses: [
      (ShippableLocationsForProjectQuery.self, threeShippableCountries)
    ])

    let reward = Reward.shipsToUSAReward

    let projectRewards = [reward]

    let project = Project.template
      |> Project.lens.stats.projectCurrency .~ Project.Country.mx.currencyCode
      |> Project.lens.country .~ Project.Country.us
      |> Project.lens.rewardData.rewards .~ projectRewards

    withEnvironment(apiService: mockService, countryCode: "US") {
      self.vm.inputs.configureWith(data: PledgeShippingLocationViewData(withProject: project))

      self.vm.inputs.viewDidLoad()

      self.adaptableStackViewIsHidden.assertValues([true])
      self.shimmerLoadingViewIsHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingLocation.assertDidNotEmitValue()
      self.notifyDelegateOfRewardFilterLocation.assertValues(["US"])
      self.shippingLocationButtonTitle.assertValues([])

      self.scheduler.advance()

      self.adaptableStackViewIsHidden.assertValues([true, false])
      self.shimmerLoadingViewIsHidden.assertValues([false, true])
      self.shippingLocationViewHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingLocation.assertValues(
        [Location.usa],
        "Because the user has an environment with a US country code, their default location should be the USA."
      )
      self.notifyDelegateOfRewardFilterLocation.assertValues(["US"])
      self.shippingLocationButtonTitle.assertValues(["United States"])
      self.shippingRulesError.assertDidNotEmitValue()
    }
  }

  func testDefaultShippingRule_ProjectCountryEqualsProjectCurrencyCountry_US_DefaultsToPreselected() {
    let mockService = MockService(fetchGraphQLResponses: [
      (ShippableLocationsForProjectQuery.self, threeShippableCountries)
    ])

    let reward = Reward.shipsToAustraliaReward

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        Backing.template
          |> Backing.lens.locationId .~ Location.australia.id
      )

    withEnvironment(apiService: mockService, countryCode: "US") {
      self.vm.inputs.configureWith(data: PledgeShippingLocationViewData(withProject: project))
      self.vm.inputs.viewDidLoad()

      self.adaptableStackViewIsHidden.assertValues([true])
      self.shimmerLoadingViewIsHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingLocation.assertDidNotEmitValue()
      self.notifyDelegateOfRewardFilterLocation.assertValues(["AU"])
      self.shippingLocationButtonTitle.assertValues([])

      self.scheduler.advance()

      self.adaptableStackViewIsHidden.assertValues([true, false])
      self.shimmerLoadingViewIsHidden.assertValues([false, true])
      self.shippingLocationViewHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingLocation.assertValues(
        [Location.australia],
        "Because the project has a backing in Australia, the selected shipping location should be Australia."
      )
      self.notifyDelegateOfRewardFilterLocation.assertValues(["AU"])
      self.shippingLocationButtonTitle.assertValues(["Australia"])
      self.shippingRulesError.assertDidNotEmitValue()
    }
  }

  func testDefaultShippingRule_ProjectHasNoShippableRewards_DefaultsToNil() {
    let mockService = MockService(fetchGraphQLResponses: [
      (ShippableLocationsForProjectQuery.self, noShippableCountries)
    ])

    let reward = Reward.digitalReward

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    withEnvironment(apiService: mockService, countryCode: "US") {
      self.vm.inputs.configureWith(data: PledgeShippingLocationViewData(withProject: project))
      self.vm.inputs.viewDidLoad()

      self.adaptableStackViewIsHidden.assertValues([true])
      self.shimmerLoadingViewIsHidden.assertValues([false])
      self.shippingLocationViewHidden.assertValues(
        [true],
        "Shipping location view should be hidden if project has no shippable rewards"
      )
      self.notifyDelegateOfSelectedShippingLocation.assertDidNotEmitValue()
      self.notifyDelegateOfRewardFilterLocation.assertValues(["US"])
      self.shippingLocationButtonTitle.assertValues([])

      self.scheduler.advance()

      self.adaptableStackViewIsHidden.assertValues([true, false])
      self.shimmerLoadingViewIsHidden.assertValues([false, true])
      self.shippingLocationViewHidden.assertValues(
        [true],
        "Shipping location view should be hidden if project has no shippable rewards"
      )
      self.notifyDelegateOfSelectedShippingLocation.assertValues(
        [nil],
        "Because the project has no shippable rewards, the default shipping location should be nil."
      )
      self.notifyDelegateOfRewardFilterLocation.assertValues(["US"])
      self.shippingLocationButtonTitle.assertDidNotEmitValue()
      self.shippingRulesError.assertDidNotEmitValue()
    }
  }

  func testShippingRulesSelection() {
    let mockService = MockService(fetchGraphQLResponses: [
      (ShippableLocationsForProjectQuery.self, threeShippableCountries)
    ])
    let reward = Reward.shipsToUSAReward

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    withEnvironment(apiService: mockService, countryCode: "US") {
      self.vm.inputs.configureWith(data: PledgeShippingLocationViewData(withProject: project))
      self.vm.inputs.viewDidLoad()

      self.notifyDelegateOfSelectedShippingLocation.assertDidNotEmitValue()
      self.notifyDelegateOfRewardFilterLocation.assertValues(["US"])

      self.scheduler.advance()

      self.notifyDelegateOfSelectedShippingLocation.assertValues([Location.usa])
      self.notifyDelegateOfRewardFilterLocation.assertValues(["US"])

      self.vm.inputs.shippingLocationButtonTapped()

      self.dismissShippingLocations.assertDidNotEmitValue()
      self.presentShippingLocationsAllLocations.assertValues([[
        Location.australia,
        Location.canada,
        Location.usa
      ]])
      self.presentShippingLocationsSelectedLocation.assertValues([Location.usa])

      self.vm.inputs.shippingLocationUpdated(to: Location.australia)

      self.scheduler.advance(by: .milliseconds(300))

      self.dismissShippingLocations.assertValueCount(1)
      self.notifyDelegateOfSelectedShippingLocation.assertValues([
        Location.usa,
        Location.australia
      ])
      self.notifyDelegateOfRewardFilterLocation.assertValues(["US", "AU"])
    }
  }

  func testShippingRulesCancelation() {
    let mockService = MockService(fetchGraphQLResponses: [
      (ShippableLocationsForProjectQuery.self, threeShippableCountries)
    ])

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    withEnvironment(apiService: mockService, countryCode: "US") {
      self.vm.inputs.configureWith(data: PledgeShippingLocationViewData(withProject: project))
      self.vm.inputs.viewDidLoad()

      let defaultShippingLocation = Location.usa

      self.notifyDelegateOfSelectedShippingLocation.assertDidNotEmitValue()

      self.scheduler.advance()

      self.notifyDelegateOfSelectedShippingLocation.assertValues([defaultShippingLocation])

      self.vm.inputs.shippingLocationButtonTapped()

      self.presentShippingLocationsAllLocations.assertValues([shippingLocations])
      self.presentShippingLocationsSelectedLocation.assertValues([defaultShippingLocation])

      self.dismissShippingLocations.assertDidNotEmitValue()
      self.vm.inputs.shippingLocationCancelButtonTapped()
      self.dismissShippingLocations.assertValueCount(1)
    }
  }

  func testShippingRulesError_ProjectCountryEqualsProjectCurrencyCountry_US() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    let project = Project.template
      |> Project.lens.rewardData.rewards .~ [reward]

    // Leaving the mock unimplemented gives us an ErrorEnvelope, which is what we want to test
    withEnvironment {
      self.vm.inputs.configureWith(data: PledgeShippingLocationViewData(withProject: project))
      self.vm.inputs.viewDidLoad()

      self.shippingRulesError.assertValues([])

      self.scheduler.advance()

      self.adaptableStackViewIsHidden.assertValues([true, false])
      self.shimmerLoadingViewIsHidden.assertValues([false, true])
      self.notifyDelegateOfSelectedShippingLocation.assertDidNotEmitValue()
      self.shippingLocationButtonTitle.assertValues([])
      self.shippingRulesError.assertValues([Strings.We_were_unable_to_load_the_shipping_destinations()])
    }
  }

  func testShippingLocationFromBackingIsDefault_ProjectCountryEqualsProjectCurrencyCountry_US() {
    let mockService = MockService(fetchGraphQLResponses: [
      (ShippableLocationsForProjectQuery.self, threeShippableCountries)
    ])

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    let projectRewards = [reward]

    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ Reward.postcards
          |> Backing.lens.rewardId .~ Reward.postcards.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
          |> Backing.lens.locationId .~ Location.canada.id
          |> Backing.lens.locationName .~ Location.canada.name
      )
      |> Project.lens.rewardData.rewards .~ projectRewards

    withEnvironment(apiService: mockService, countryCode: "US") {
      self.vm.inputs.configureWith(data: PledgeShippingLocationViewData(withProject: project))
      self.vm.inputs.viewDidLoad()

      self.adaptableStackViewIsHidden.assertValues([true])
      self.shimmerLoadingViewIsHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingLocation.assertDidNotEmitValue()
      self.shippingLocationButtonTitle.assertValues([])

      self.scheduler.advance()

      self.adaptableStackViewIsHidden.assertValues([true, false])
      self.shimmerLoadingViewIsHidden.assertValues([false, true])
      self.notifyDelegateOfSelectedShippingLocation.assertValues(
        [Location.canada],
        "Because the backing was made with the location Canada, the selected shipping location should default to Canada."
      )
      self.shippingLocationButtonTitle.assertValues(["Canada"])
      self.shippingRulesError.assertDidNotEmitValue()

      self.scheduler.advance(by: .seconds(1))
    }
  }

  func testShippingLocationFromBackingIsDefault_ProjectCountryEqualsProjectCurrencyCountry_US_NewRewardDoesNotHaveSelectedRule(
  ) {
    let shippingDataWithoutCanada = GraphAPI.ShippableLocationsForProjectQuery.Data(
      project: GraphAPI.ShippableLocationsForProjectQuery.Data.Project(
        shippableCountriesExpanded: [
          GraphLocation(
            country: "US",
            countryName: "United States",
            displayableName: "United States",
            id: encodeToBase64("Location-5"),
            name: "United States"
          ),
          GraphLocation(
            country: "AU",
            countryName: "Australia",
            displayableName: "Australia",
            id: encodeToBase64("Location-8"),
            name: "Australia"
          )
        ]
      )
    )

    let mockService = MockService(fetchGraphQLResponses: [
      (ShippableLocationsForProjectQuery.self, shippingDataWithoutCanada)
    ])

    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true

    let projectRewards = [reward]

    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ Reward.postcards
          |> Backing.lens.rewardId .~ Reward.postcards.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700.0
          |> Backing.lens.locationId .~ Location.canada.id
          |> Backing.lens.locationName .~ Location.canada.name
      )
      |> Project.lens.rewardData.rewards .~ projectRewards

    withEnvironment(apiService: mockService, countryCode: "US") {
      self.vm.inputs.configureWith(data: PledgeShippingLocationViewData(withProject: project))
      self.vm.inputs.viewDidLoad()

      self.adaptableStackViewIsHidden.assertValues([true])
      self.shimmerLoadingViewIsHidden.assertValues([false])
      self.notifyDelegateOfSelectedShippingLocation.assertDidNotEmitValue()
      self.shippingLocationButtonTitle.assertValues([])

      self.scheduler.advance()

      self.adaptableStackViewIsHidden.assertValues([true, false])
      self.shimmerLoadingViewIsHidden.assertValues([false, true])
      self.notifyDelegateOfSelectedShippingLocation.assertValues(
        [Location.usa],
        "Because Canada is no longer a valid shipping destination, even though the backing was sent to Canada, the shipping location should default to the user's default location."
      )
      self.shippingLocationButtonTitle.assertValues(["United States"])
      self.shippingRulesError.assertDidNotEmitValue()
    }
  }
}

private let shippingLocations: [Location] = Location.locations(from: threeShippableCountries)

private typealias GraphLocation = GraphAPI.ShippableLocationsForProjectQuery.Data.Project
  .ShippableCountriesExpanded

private let threeShippableCountries = GraphAPI.ShippableLocationsForProjectQuery.Data(
  project: GraphAPI.ShippableLocationsForProjectQuery.Data.Project(
    shippableCountriesExpanded: [
      GraphLocation(
        country: "AU",
        countryName: "Australia",
        displayableName: "Australia",
        id: encodeToBase64("Location-8"),
        name: "Australia"
      ),
      GraphLocation(
        country: "CA",
        countryName: "Canada",
        displayableName: "Canada",
        id: encodeToBase64("Location-6"),
        name: "Canada"
      ),
      GraphLocation(
        country: "US",
        countryName: "United States",
        displayableName: "United States",
        id: encodeToBase64("Location-5"),
        name: "United States"
      )
    ]
  )
)

private let noShippableCountries = GraphAPI.ShippableLocationsForProjectQuery.Data(
  project: GraphAPI.ShippableLocationsForProjectQuery.Data.Project(
    shippableCountriesExpanded: []
  )
)
