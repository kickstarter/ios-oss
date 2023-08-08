import Foundation
import PerimeterX_SDK

extension PerimeterXClient {
  static var mock: PerimeterXClient = PerimeterXClient(
    dateType: ApiMockDate.self
  )
}
