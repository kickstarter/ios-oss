@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class SettingsRequestDataCellViewModelTests: TestCase {
  internal let vm = SettingsRequestDataCellViewModel()
  internal let dataExpirationAndChevronHidden = TestObserver<Bool, Never>()
  internal let goToSafari = TestObserver<String, Never>()
  internal let requestDataButtonEnabled = TestObserver<Bool, Never>()
  internal let requestedDataExpirationDate = TestObserver<String, Never>()
  internal let requestDataLoadingIndicator = TestObserver<Bool, Never>()
  internal let requestDataText = TestObserver<String, Never>()
  internal let requestDataTextHidden = TestObserver<Bool, Never>()
  internal let showPreparingDataAndCheckBackLaterText = TestObserver<Bool, Never>()
  internal let showRequestDataPrompt = TestObserver<String, Never>()
  internal let unableToRequestDataError = TestObserver<String, Never>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.goToSafari.observe(self.goToSafari.observer)
    self.vm.outputs.requestDataButtonEnabled.observe(self.requestDataButtonEnabled.observer)
    self.vm.outputs.requestedDataExpirationDate.observe(self.requestedDataExpirationDate.observer)
    self.vm.outputs.requestDataLoadingIndicator.observe(self.requestDataLoadingIndicator.observer)
    self.vm.outputs.requestDataText.observe(self.requestDataText.observer)
    self.vm.outputs.requestDataTextHidden.observe(self.requestDataTextHidden.observer)
    self.vm.outputs.dataExpirationAndChevronHidden.observe(self.dataExpirationAndChevronHidden.observer)
    self.vm.outputs.showPreparingDataAndCheckBackLaterText
      .observe(self.showPreparingDataAndCheckBackLaterText.observer)
    self.vm.outputs.showRequestDataPrompt.observe(self.showRequestDataPrompt.observer)
    self.vm.outputs.unableToRequestDataError.observe(self.unableToRequestDataError.observer)
  }

  func testOpenDataUrlInSafari() {
    let user = User.template

    withEnvironment(apiService: MockService(fetchExportStateResponse: .template)) {
      self.vm.inputs.awakeFromNib()
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
      self.vm.inputs.awakeFromNib()
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
      self.vm.inputs.awakeFromNib()
      self.requestDataText.assertValues(
        [Strings.Request_my_personal_data()],
        "Should emit on awakeFromNib to set initial value"
      )

      self.vm.inputs.configureWith(user: user)

      self.scheduler.advance()

      self.requestDataText.assertValues([
        Strings.Request_my_personal_data(),
        Strings.Request_my_personal_data()
      ])

      self.vm.inputs.exportDataTapped()

      self.scheduler.advance()

      withEnvironment(apiService: MockService(fetchExportStateResponse: .template)) {
        self.vm.inputs.configureWith(user: user)

        self.scheduler.advance()

        self.requestDataText.assertValues([
          Strings.Request_my_personal_data(),
          Strings.Request_my_personal_data(),
          Strings.Download_your_personal_data()
        ])
      }
    }
  }

  func testDataExpirationAndChevronHidden() {
    let user = User.template

    withEnvironment(apiService: MockService(fetchExportStateResponse: .template)) {
      self.vm.inputs.awakeFromNib()
      self.requestDataText.assertValues(
        [Strings.Request_my_personal_data()],
        "Should emit on awakeFromNib to set initial value"
      )
      self.dataExpirationAndChevronHidden.assertValues([true])
      self.vm.inputs.configureWith(user: user)
      self.scheduler.advance()
      self.requestDataText.assertValues([
        Strings.Request_my_personal_data(),
        Strings.Download_your_personal_data()
      ])
      self.dataExpirationAndChevronHidden.assertValues([true, false])
    }
  }

  func testShowRequestDataPrompt() {
    let user = User.template
    let userEnvelope = UserEnvelope(me: GraphUser.template)
    let export = .template
      |> ExportDataEnvelope.lens.state .~ .expired
      |> ExportDataEnvelope.lens.expiresAt .~ nil
      |> ExportDataEnvelope.lens.dataUrl .~ nil

    withEnvironment(apiService: MockService(
      fetchExportStateResponse: export,
      fetchGraphUserResult: .success(userEnvelope)
    )) {
      self.vm.inputs.awakeFromNib()
      self.vm.inputs.configureWith(user: user)
      self.scheduler.advance()
      self.vm.inputs.exportDataTapped()
      self.showRequestDataPrompt.assertValues([
        Strings.Youll_receive_an_email_at_email_when_your_download_is_ready(email: "nativesquad@ksr.com")
      ])
    }
  }

  func testPreparingDataAndCheckBackLaterText() {
    let user = User.template
    let export = .template
      |> ExportDataEnvelope.lens.state .~ .expired
      |> ExportDataEnvelope.lens.expiresAt .~ nil
      |> ExportDataEnvelope.lens.dataUrl .~ nil

    withEnvironment(apiService: MockService(fetchExportStateResponse: export)) {
      self.vm.inputs.configureWith(user: user)

      self.requestDataLoadingIndicator.assertValues([false])
      self.requestDataTextHidden.assertValues([false])
      self.showPreparingDataAndCheckBackLaterText.assertValues([true])

      self.vm.inputs.startRequestDataTapped()

      self.requestDataLoadingIndicator.assertValues([false, true])
      self.requestDataTextHidden.assertValues([false, true])
      self.showPreparingDataAndCheckBackLaterText.assertValues([true, false])
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
