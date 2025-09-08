import KDS
import KsApi
import Prelude
import UserNotifications

/**
 Returns the full currency symbol for a currencyCode. Special logic is added around prefixing currency symbols
 with country/currency codes based on a variety of factors.

 - parameter currencyCode: The currency code.
 - parameter omitCurrencyCode: Safe to omit the US currencyCode
 - parameter env: Current Environment.

 - returns: The currency symbol that can be used for currency display.
 */
public func currencySymbol(
  forCurrencyCode currencyCode: String,
  omitCurrencyCode: Bool = true,
  env: Environment = AppEnvironment.current
) -> String {
  let country = projectCountry(forCurrency: currencyCode, env: env) ?? .us

  guard env.launchedCountries.currencyNeedsCode(country.currencySymbol) else {
    // Currencies that dont have ambigious currencies can just use their symbol.
    return country.currencySymbol
  }

  if country == .us && env.countryCode == Project.Country.us.countryCode && omitCurrencyCode {
    // US people looking at US projects just get the currency symbol
    return country.currencySymbol
  } else if country == .sg {
    // Singapore projects get a special currency prefix
    return "\(String.nbsp)S\(country.currencySymbol)\(String.nbsp)"
  } else if country.currencySymbol == "kr" || country.currencySymbol == "Fr" {
    // Kroner projects use the currency code prefix
    return "\(String.nbsp)\(country.currencyCode)\(String.nbsp)"
  } else {
    // Everything else uses the country code prefix.
    return "\(String.nbsp)\(country.countryCode)\(country.currencySymbol)\(String.nbsp)"
  }
}

/**
 Returns the full country for a currency code.

 - parameter code: The currency code.
 - parameter env: Current Environment.

 - returns: The first matching country for currency symbol
 */
public func projectCountry(
  forCurrency code: String?,
  env: Environment = AppEnvironment.current
) -> Project.Country? {
  guard let currencyCode = code,
        let country = env.launchedCountries.countries.filter({ $0.currencyCode == currencyCode }).first else {
    return nil
  }
  // return a hardcoded Country if it matches the country code
  return country
}

/*
 A helper that assists in rounding a Double to a given number of decimal places
 */
public func rounded(_ value: Double, places: Int16) -> Decimal {
  let roundingBehavior = NSDecimalNumberHandler(
    roundingMode: .bankers,
    scale: places,
    raiseOnExactness: true,
    raiseOnOverflow: true,
    raiseOnUnderflow: true,
    raiseOnDivideByZero: true
  )

  return NSDecimalNumber(value: value).rounding(accordingToBehavior: roundingBehavior) as Decimal
}

/*
 A helper that assists in rounding a Float to a given number of decimal places
 */
public func rounded(_ value: Float, places: Int16) -> Decimal {
  let roundingBehavior = NSDecimalNumberHandler(
    roundingMode: .bankers,
    scale: places,
    raiseOnExactness: true,
    raiseOnOverflow: true,
    raiseOnUnderflow: true,
    raiseOnDivideByZero: true
  )

  return NSDecimalNumber(value: value).rounding(accordingToBehavior: roundingBehavior) as Decimal
}
