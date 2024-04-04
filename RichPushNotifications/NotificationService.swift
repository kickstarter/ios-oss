import UIKit
import UserNotifications

let AppboyAPNSDictionaryKey = "ab"
let AppboyAPNSDictionaryAttachmentKey = "att"
let AppboyAPNSDictionaryAttachmentURLKey = "url"
let AppboyAPNSDictionaryAttachmentTypeKey = "type"

private func printDebug(_ items: Any...) {
  #if DEBUG
    print(items)
  #endif
}

class NotificationService: UNNotificationServiceExtension {
  var bestAttemptContent: UNMutableNotificationContent?
  var contentHandler: ((UNNotificationContent) -> Void)?
  var originalContent: UNMutableNotificationContent?
  var abortOnAttachmentFailure: Bool = false

  override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler handler: @escaping (UNNotificationContent) -> Void
  ) {
    self.contentHandler = handler
    self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
    self.originalContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

    printDebug("[APPBOY] Push with mutable content received.")

    guard let appboyPayload = request.content.userInfo[AppboyAPNSDictionaryKey] as? [AnyHashable: Any]
    else { return self.displayOriginalContent("Push is not from Appboy.") }

    guard let attachmentPayload = appboyPayload[AppboyAPNSDictionaryAttachmentKey] as? [AnyHashable: Any]
    else { return self.displayOriginalContent("Push has no attachment.") }

    guard let attachmentURLString = attachmentPayload[AppboyAPNSDictionaryAttachmentURLKey] as? String
    else { return self.displayOriginalContent("Push has no attachment.") }

    guard let attachmentURL = URL(string: attachmentURLString)
    else { return self.displayOriginalContent("Cannot parse \(attachmentURLString) to URL.") }

    printDebug("[APPBOY] Attachment URL string is \(attachmentURLString)")

    guard let attachmentType = attachmentPayload[AppboyAPNSDictionaryAttachmentTypeKey] as? String
    else { return self.displayOriginalContent("Push attachment has no type.") }

    printDebug("[APPBOY] Attachment type is \(attachmentType)")
    let fileSuffix: String = ".\(attachmentType)"

    // Download, store, and attach the content to the notification
    let session = URLSession(configuration: URLSessionConfiguration.default)

    session.downloadTask(
      with: attachmentURL,
      completionHandler: { temporaryFileLocation, _, error in

        guard let temporaryFileLocation = temporaryFileLocation, error == nil else {
          return self
            .displayOriginalContent(
              "Error fetching attachment, displaying content unaltered: \(String(describing: error?.localizedDescription))"
            )
        }

        printDebug(
          "[Appboy] Data fetched from server, processing with temporary file url \(temporaryFileLocation.absoluteString)"
        )

        let typedAttachmentURL = URL(fileURLWithPath: "\(temporaryFileLocation.path)\(fileSuffix)")

        do {
          try FileManager.default.moveItem(at: temporaryFileLocation, to: typedAttachmentURL)
        } catch {
          return self.displayOriginalContent("Failed to move file path.")
        }

        guard let attachment = try? UNNotificationAttachment(
          identifier: "",
          url: typedAttachmentURL,
          options: nil
        ) else { return self.displayOriginalContent("Attachment returned error.") }

        guard let bestAttemptContent = self.bestAttemptContent
        else { return self.displayOriginalContent("bestAttemptContent is nil") }

        bestAttemptContent.attachments = [attachment]
        handler(bestAttemptContent)
      }
    ).resume()
  }

  func displayOriginalContent(_ extraLogging: String) {
    printDebug("[APPBOY] \(extraLogging)")
    printDebug("[APPBOY] Displaying original content.")

    guard let contentHandler = contentHandler, let originalContent = originalContent else { return }

    contentHandler(originalContent)
  }

  override func serviceExtensionTimeWillExpire() {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.displayOriginalContent("Service extension called, displaying original content.")
  }
}
