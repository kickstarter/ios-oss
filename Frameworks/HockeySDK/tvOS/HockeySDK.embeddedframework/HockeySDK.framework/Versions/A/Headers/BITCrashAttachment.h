#import "BITHockeyAttachment.h"

/**
 Deprecated: Provides support to add binary attachments to crash reports
 
 This class is not needed any longer and exists for compatibility purposes with
 HockeySDK-iOS 3.5.5.
 
 It is a subclass of `BITHockeyAttachment` which only provides an initializer
 that is compatible with the one of HockeySDK-iOS 3.5.5.
 
 This is used by `[BITCrashManagerDelegate attachmentForCrashManager:]`
 
 @see BITHockeyAttachment
 */
@interface BITCrashAttachment : BITHockeyAttachment

/**
 Create an BITCrashAttachment instance with a given filename and NSData object
 
 @param filename            The filename the attachment should get
 @param crashAttachmentData The attachment data as NSData
 @param contentType         The content type of your data as MIME type
 
 @return An instance of BITCrashAttachment
 */
- (instancetype)initWithFilename:(NSString *)filename
             crashAttachmentData:(NSData *)crashAttachmentData
                     contentType:(NSString *)contentType;

@end
