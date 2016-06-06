import class Foundation.NSDate
import class Foundation.NSDateFormatter
import enum Foundation.NSDateFormatterStyle
import class Foundation.NSNumberFormatter
import struct Foundation.NSTimeInterval
import struct KsApi.Project

public enum Format {
  // Number formatter for whole numbers.
  private static let wholeNumberFormatter: NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .DecimalStyle
    return formatter
  }()

  // Number formatter for whole numbers.
  private static let percentageFormatter: NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .PercentStyle
    formatter.roundingMode = .RoundDown
    return formatter
  }()

  // Number formatter for currency.
  private static let currencyFormatter: NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .CurrencyStyle
    formatter.roundingMode = .RoundUp
    formatter.maximumFractionDigits = 0
    formatter.generatesDecimalNumbers = false
    return formatter
  }()

  private static let dateFormatter = NSDateFormatter()

  /**
   Formats an int into a string.

   - parameter x:   An integer.
   - parameter env: An (optional) environment.

   - returns: A formatted string.
   */
  public static func wholeNumber(x: Int, env: Environment = AppEnvironment.current) -> String {
    Format.wholeNumberFormatter.locale = env.locale
    return Format.wholeNumberFormatter.stringFromNumber(x) ?? String(x)
  }

  /**
   Formats an int percentage into a string.

   - parameter percentage: An int where 100 corresponds to 100%.
   - parameter env:        An (optional) environment.

   - returns: A formatted string.
   */
  public static func percentage(percentage: Int, env: Environment = AppEnvironment.current) -> String {
    Format.percentageFormatter.locale = env.locale

    return Format.percentageFormatter.stringFromNumber(Float(percentage) / 100.0)
      ?? String(percentage) + "%"
  }

  /**
   Formats an int with currency symbol into a string.

   - parameter amount: The amount to format.
   - parameter country: The country that currency is in.
   - parameter env: (optional) An environment to use for locality.

   - returns: A formatted string.
  */
  public static func currency(amount: Int,
                              country: Project.Country,
                              env: Environment = AppEnvironment.current) -> String {

    Format.currencyFormatter.locale = env.locale
    Format.currencyFormatter.currencySymbol = country.currencySymbol

    let string = Format.currencyFormatter.stringFromNumber(amount) ?? country.currencySymbol + String(amount)

    // Sometimes we need to append a country code in order to disambiguate a currency
    if env.launchedCountries.currencyNeedsCode(country.currencySymbol) {
      // USD for US backers does not need to be disambiguated.
      if env.countryCode != "US" || country.countryCode != "US" {
        // NB: The space " " here is a non-breaking space
        return string + " " + country.currencyCode
      }
    }

    return string
  }

  /**
   Format a date into a string.

   - parameter secondsInUTC: Seconds represention of the date as measured from UTC.
   - parameter dateStyle: (optional) The style to format the date.
   - parameter timeStyle: (optional) The style to format the time.
   - parameter env: (optional) An environment to use for locality and time zones.

   - returns: A formatted string.
  */
  public static func date(secondsInUTC seconds: NSTimeInterval,
                                       dateStyle: NSDateFormatterStyle = .MediumStyle,
                                       timeStyle: NSDateFormatterStyle = .MediumStyle,
                                       env: Environment = AppEnvironment.current) -> String {

    Format.dateFormatter.timeZone = env.timeZone
    Format.dateFormatter.locale = env.locale
    Format.dateFormatter.dateStyle = dateStyle
    Format.dateFormatter.timeStyle = timeStyle

    return Format.dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: seconds))
  }
}
