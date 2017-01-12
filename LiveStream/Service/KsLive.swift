import FirebaseAnalytics
import FirebaseDatabase
import FirebaseAuth

public class KsLiveApp {

  private static func start() {
    let options: FIROptions = FIROptions(googleAppID: Secrets.Firebase.Huzza.Production.googleAppID,
                                   bundleID: Secrets.Firebase.Huzza.Production.bundleID,
                                   gcmSenderID: Secrets.Firebase.Huzza.Production.gcmSenderID,
                                   apiKey: Secrets.Firebase.Huzza.Production.apiKey,
                                   clientID: Secrets.Firebase.Huzza.Production.clientID,
                                   trackingID: "",
                                   androidClientID: "",
                                   databaseURL: Secrets.Firebase.Huzza.Production.databaseURL,
                                   storageBucket: Secrets.Firebase.Huzza.Production.storageBucket,
                                   deepLinkURLScheme: "")

    FIRApp.configure(withName: Secrets.Firebase.Huzza.Production.appName, options: options)
  }

  public static func firebaseApp() -> FIRApp? {
    guard let app = FIRApp(named: Secrets.Firebase.Huzza.Production.appName) else {
      self.start()
      return FIRApp(named: Secrets.Firebase.Huzza.Production.appName)
    }

    return app
  }

  public static func firebaseAuth() -> FIRAuth? {
    guard let app = self.firebaseApp() else { return nil }
    return FIRAuth(app: app)
  }

  public static func apiUrl() -> String {
    return Secrets.LiveStreams.endpoint
  }
}
