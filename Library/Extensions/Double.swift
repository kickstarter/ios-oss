import Foundation

extension Double {
  func addingCurrency(_ otherDouble: Double) -> Double {
    let amountDecimal = Decimal(self)
    let otherDecimal = Decimal(otherDouble)

    let sum = NSDecimalNumber(decimal: amountDecimal + otherDecimal)

    return sum.doubleValue
  }
}
