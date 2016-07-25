import Foundation
import KsApi

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

  // Number formatter for fractions.
  private static let percentageFractionFormatter: NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .PercentStyle
    formatter.roundingMode = .RoundDown
    formatter.maximumFractionDigits = 0
    return formatter
  }()

  // Number formatter for currency.
  private static let currencyFormatter: NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .CurrencyStyle
    formatter.roundingMode = .RoundDown
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
   Formats a Double percentage into a string.

   - parameter percentage: A Double where .10 corresponds to 10%.
   - parameter env:        An (optional) environment.

   - returns: A formatted string.
   */
  public static func percentage(percentage: Double, env: Environment = AppEnvironment.current) -> String {
    Format.percentageFractionFormatter.locale = env.locale

    return Format.percentageFractionFormatter.stringFromNumber(percentage)
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

  /**
   Format a duration into a string.

   - parameter seconds: Seconds represention of the date as measured from UTC.
   - parameter thresholdInDays: (optional) Threshold.
   - parameter env: An (optional) environment.

   - returns: A formatted string.
   */
  public static func duration(secondsInUTC seconds: NSTimeInterval,
                                           thresholdInDays: Int = defaultThresholdInDays,
                                           env: Environment = AppEnvironment.current) -> String? {

    let components = env.calendar.components([.Day, .Hour, .Minute, .Second],
                                             fromDate: NSDate(),
                                             toDate: NSDate(timeIntervalSince1970: seconds),
                                             options: [])
    guard components.day < thresholdInDays else { return nil }
    if components.day > 0 {
      return Strings.dates_time_days(time_count: components.day)
    } else if components.hour > 0 {
      return Strings.dates_time_hours(time_count: components.hour)
    } else if components.minute >= 0 && components.second >= 0 {
      return Strings.dates_time_minutes(time_count: components.minute)
    }
    return nil
  }

  /**
   Format a date into a relative string.

   - parameter secondsInUTC: Seconds represention of the date as measured from UTC.
   - parameter abbreviate: (optional) Whether or not to use the abbreviated style.
   - parameter threshold: (optional) Threshold.
   - parameter env: An (optional) environment.

   - returns: A formatted string.
   */
  public static func relative(
    secondsInUTC seconds: NSTimeInterval,
                 abbreviate: Bool = false,
                 threshold thresholdInDays: Int = defaultThresholdInDays,
                 env: Environment = AppEnvironment.current) -> String {

    let components = env.calendar.components([.Day, .Hour, .Minute, .Second],
                                             fromDate: NSDate(timeIntervalSince1970: seconds),
                                             toDate: NSDate(),
                                             options: [])

    if abs(components.day) > thresholdInDays {
      return Format.date(secondsInUTC: seconds, dateStyle: .MediumStyle, timeStyle: .NoStyle)
    } else if components.day > 1 {
      let format = abbreviate ? Strings.dates_time_days_ago_abbreviated : Strings.dates_time_days_ago
      return format(time_count: components.day)
    } else if components.day == 1 {
      return Strings.dates_yesterday()
    } else if components.hour > 0 {
      let format = abbreviate ? Strings.dates_time_hours_ago_abbreviated : Strings.dates_time_hours_ago
      return format(time_count: components.hour)
    } else if components.minute > 0 {
      let format = abbreviate ? Strings.dates_time_minutes_ago_abbreviated : Strings.dates_time_minutes_ago
      return format(time_count: components.minute)
    } else if components.second > 0 {
      return Strings.dates_just_now()
    } else if components.day < 0 {
      let format = abbreviate ? Strings.dates_time_in_days_abbreviated : Strings.dates_time_in_days
      return format(time_count: -components.day)
    } else if components.hour < 0 {
      let format = abbreviate ? Strings.dates_time_in_hours_abbreviated : Strings.dates_time_in_hours
      return format(time_count: -components.hour)
    } else if components.minute < 0 {
      let format = abbreviate ? Strings.dates_time_in_minutes_abbreviated : Strings.dates_time_in_minutes
      return format(time_count: -components.minute)
    } else {
      return Strings.dates_right_now()
    }
  }
}

private let defaultThresholdInDays = 30 // days
