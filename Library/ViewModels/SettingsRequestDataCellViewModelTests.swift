import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class SettingsRequestDataCellViewModelTests: TestCase {
  internal let vm = SettingsRequestDataCellViewModel()
  internal let dataExpirationAndChevronHidden = TestObserver<Bool, NoError>()
  internal let goToSafari = TestObserver<String, NoError>()
  internal let requestDataButtonEnabled = TestObserver<Bool, NoError>()
  internal let requestedDataExpirationDate = TestObserver<String, NoError>()
  internal let requestDataLoadingIndicator = TestObserver<Bool, NoError>()
  internal let requestDataText = TestObserver<String, NoError>()
  internal let requestDataTextHidden = TestObserver<Bool, NoError>()
  internal let showPreparingDataText = TestObserver<Bool, NoError>()
  internal let showRequestDataPrompt = TestObserver<(), NoError>()
  internal let unableToRequestDataError = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.goToSafari.observe(self.goToSafari.observer)
    self.vm.outputs.requestDataButtonEnabled.observe(self.requestDataButtonEnabled.observer)
    self.vm.outputs.requestedDataExpirationDate.observe(self.requestedDataExpirationDate.observer)
    self.vm.outputs.requestDataLoadingIndicator.observe(self.requestDataLoadingIndicator.observer)
    self.vm.outputs.requestDataText.observe(self.requestDataText.observer)
    self.vm.outputs.requestDataTextHidden.observe(self.requestDataTextHidden.observer)
    self.vm.outputs.dataExpirationAndChevronHidden.observe(self.dataExpirationAndChevronHidden.observer)
    self.vm.outputs.showPreparingDataText.observe(self.showPreparingDataText.observer)
    self.vm.outputs.showRequestDataPrompt.observe(self.showRequestDataPrompt.observer)
    self.vm.outputs.unableToRequestDataError.observe(self.unableToRequestDataError.observer)
  }

  func testOpenDataUrlInSafari() {
    let user = User.template

    withEnvironment(apiService: MockService(fetchExportStateResponse: .template)) {
      self.vm.inputs.configureWith(user: user)
      self.scheduler.advance()
      self.vm.inputs.exportDataTapped()
      self.goToSafari.assertValues(["http://kickstarter.com/mydata"])
    }
  }

  func testRequestDataButtonIsEnabled() {
    let user = User.template
    let export = .template
      |> ExportDataEnvelope.lens.state .~ .expired
      |> ExportDataEnvelope.lens.expiresAt .~ nil
      |> ExportDataEnvelope.lens.dataUrl .~ nil

    withEnvironment(apiService: MockService(fetchExportStateResponse: export)) {
      self.vm.inputs.configureWith(user: user)
      self.requestDataButtonEnabled.assertValues([true])
      self.vm.inputs.startRequestDataTapped()
      self.requestDataButtonEnabled.assertValues([true, false])
    }
  }

  func testDataExpirationDate() {
    let user = User.template

    withEnvironment(apiService: MockService(fetchExportStateResponse: .template)) {
      self.vm.inputs.configureWith(user: user)
      self.scheduler.advance()
      self.requestedDataExpirationDate.assertValues(["Expires Jun 19, 2018 at 1:12 PM"])
    }
  }

  func testRequestDataText_IsHidden() {
    let user = User.template
    let export = .template
      |> ExportDataEnvelope.lens.state .~ .expired
      |> ExportDataEnvelope.lens.expiresAt .~ nil
      |> ExportDataEnvelope.lens.dataUrl .~ nil

    withEnvironment(apiService: MockService(fetchExportStateResponse: export)) {
      self.vm.inputs.configureWith(user: user)

      self.scheduler.advance()

      self.requestDataText.assertValues([Strings.Request_my_Personal_Data()])

      self.vm.inputs.exportDataTapped()

      self.scheduler.advance()

      withEnvironment(apiService: MockService(fetchExportStateResponse: .template)) {

        self.vm.inputs.configureWith(user: user)

        self.scheduler.advance()

        self.requestDataText.assertValues([Strings.Request_my_Personal_Data(),
                                           Strings.Download_your_personal_data()])
      }
    }
  }

  func testDataExpirationAndChevronHidden() {
    let user = User.template

    withEnvironment(apiService: MockService(fetchExportStateResponse: .template)) {
      self.vm.inputs.configureWith(user: user)
      self.scheduler.advance()
      self.requestDataText.assertValues([Strings.Download_your_personal_data()])
      self.dataExpirationAndChevronHidden.assertValues([false])
    }
  }

  func testShowRequestDataPrompt() {
    let user = User.template
    let export = .template
      |> ExportDataEnvelope.lens.state .~ .expired
      |> ExportDataEnvelope.lens.expiresAt .~ nil
      |> ExportDataEnvelope.lens.dataUrl .~ nil

    withEnvironment(apiService: MockService(fetchExportStateResponse: export)) {
      self.vm.inputs.configureWith(user: user)
      self.scheduler.advance()
      self.vm.inputs.exportDataTapped()
      self.showRequestDataPrompt.assertValueCount(1)
    }
  }

  func testPreparingData() {
    let user = User.template
    let export = .template
      |> ExportDataEnvelope.lens.state .~ .expired
      |> ExportDataEnvelope.lens.expiresAt .~ nil
      |> ExportDataEnvelope.lens.dataUrl .~ nil

    withEnvironment(apiService: MockService(fetchExportStateResponse: export)) {
      self.vm.inputs.configureWith(user: user)

      self.requestDataLoadingIndicator.assertValues([false])
      self.requestDataTextHidden.assertValues([false])
      self.showPreparingDataText.assertValues([true])

      self.vm.inputs.startRequestDataTapped()

      self.requestDataLoadingIndicator.assertValues([false, true])
      self.requestDataTextHidden.assertValues([false, true])
      self.showPreparingDataText.assertValues([true, false])
    }
  }

  func testUnableToRequestDataError() {
    let user = User.template
    let error = ErrorEnvelope(
      errorMessages: ["unable to request data"],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    withEnvironment(apiService: MockService(exportDataError: error)) {
      self.vm.inputs.configureWith(user: user)
      self.vm.inputs.startRequestDataTapped()
      self.scheduler.advance()
      self.unableToRequestDataError.assertValueCount(1)
    }
  }
}
