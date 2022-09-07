@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class PledgePaymentMethodsDataSourceTests: XCTestCase {
  private let dataSource = PledgePaymentMethodsDataSource()
  private let tableView = UITableView()

  func testLoad_NonPaymentSheetCardValues() {
    let cellData = [
      (
        card: UserCreditCards.amex,
        isEnabled: true,
        isSelected: true,
        projectCountry: "Country 1",
        isErroredPaymentMethod: false
      ),
      (
        card: UserCreditCards.visa,
        isEnabled: false,
        isSelected: false,
        projectCountry: "Country 2",
        isErroredPaymentMethod: false
      )
    ]

    self.dataSource.load(cellData, paymentSheetCards: [])

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(
      2,
      self.dataSource.numberOfItems(in: PaymentMethodsTableViewSection.paymentMethods.rawValue)
    )
    XCTAssertEqual(
      1,
      self.dataSource.numberOfItems(in: PaymentMethodsTableViewSection.addNewCard.rawValue)
    )
  }

  func testLoad_PaymentSheetCardValues() {
    let paymentSheetData = [
      (
        image: UIImage(),
        redactedCardNumber: "test1",
        setupIntent: "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ",
        isSelected: true,
        isEnabled: true
      ),
      (
        image: UIImage(),
        redactedCardNumber: "test2",
        setupIntent: "seti_2LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLP",
        isSelected: false,
        isEnabled: true
      )
    ]

    self.dataSource.load([], paymentSheetCards: paymentSheetData)

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(
      2,
      self.dataSource.numberOfItems(in: PaymentMethodsTableViewSection.paymentMethods.rawValue)
    )
    XCTAssertEqual(
      1,
      self.dataSource.numberOfItems(in: PaymentMethodsTableViewSection.addNewCard.rawValue)
    )
  }

  func testLoad_PaymentSheetCardAndNonPaymentSheetCardValues() {
    let cellData = [
      (
        card: UserCreditCards.amex,
        isEnabled: true,
        isSelected: true,
        projectCountry: "Country 1",
        isErroredPaymentMethod: false
      ),
      (
        card: UserCreditCards.visa,
        isEnabled: false,
        isSelected: false,
        projectCountry: "Country 2",
        isErroredPaymentMethod: false
      )
    ]

    let paymentSheetData = [
      (
        image: UIImage(),
        redactedCardNumber: "test1",
        setupIntent: "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ",
        isSelected: true,
        isEnabled: true
      ),
      (
        image: UIImage(),
        redactedCardNumber: "test2",
        setupIntent: "seti_2LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLP",
        isSelected: false,
        isEnabled: true
      )
    ]

    self.dataSource.load(cellData, paymentSheetCards: paymentSheetData)

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(
      4,
      self.dataSource.numberOfItems(in: PaymentMethodsTableViewSection.paymentMethods.rawValue)
    )
    XCTAssertEqual(
      1,
      self.dataSource.numberOfItems(in: PaymentMethodsTableViewSection.addNewCard.rawValue)
    )
  }

  func testLoadingState() {
    self.dataSource.load([], paymentSheetCards: [], isLoading: true)

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView), "Sections padded")
    XCTAssertEqual(
      1,
      self.dataSource.numberOfItems(in: PaymentMethodsTableViewSection.loading.rawValue)
    )
    XCTAssertEqual(
      0,
      self.dataSource.numberOfItems(in: PaymentMethodsTableViewSection.paymentMethods.rawValue)
    )
    XCTAssertEqual(
      0,
      self.dataSource.numberOfItems(in: PaymentMethodsTableViewSection.addNewCard.rawValue)
    )
  }

  func testLoadingState_AddNewCardButton() {
    self.dataSource.load([], paymentSheetCards: [], isLoading: true)
    self.dataSource.updateAddNewPaymentCardLoad(state: true)

    let addNewCardIndexPath = IndexPath(row: 0, section: 1)

    XCTAssertTrue(self.dataSource.isLoadingStateCell(indexPath: addNewCardIndexPath))

    self.dataSource.updateAddNewPaymentCardLoad(state: false)

    XCTAssertFalse(self.dataSource.isLoadingStateCell(indexPath: addNewCardIndexPath))
  }
}
