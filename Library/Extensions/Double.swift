import Foundation

extension Double {
  public func addingCurrency(_ otherDouble: Double) -> Double {
    let amountDecimal = Decimal(self)
    let otherDecimal = Decimal(otherDouble)

    let sum = NSDecimalNumber(decimal: amountDecimal + otherDecimal)

    return sum.doubleValue
  }

  public func multiplyingCurrency(_ otherDouble: Double) -> Double {
    let amountDecimal = Decimal(self)
    let otherDecimal = Decimal(otherDouble)

    let multiplied = NSDecimalNumber(decimal: amountDecimal * otherDecimal)

    return multiplied.doubleValue
  }
}
