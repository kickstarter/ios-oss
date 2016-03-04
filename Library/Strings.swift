/// Make this file computer generated from Localizable.strings

public enum Strings {

  /**
   "Project of the day"
  */
  public static func project_of_the_day() -> String {
    return localizedString(key: "project_of_the_day", defaultValue: "Project of the day")
  }

  /**
   by <b>%{creator_name}</b>
   
   - parameters:
     - creator_name:
  */
  public static func by_creator(creator_name creator_name: String) -> String {

    return localizedString(key: "by_creator", defaultValue: "by <b>%{creator_name}</b>", substitutions: ["creator_name": creator_name])
  }
}
