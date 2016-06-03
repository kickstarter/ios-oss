#import <Foundation/Foundation.h>

@class BITCrashManager;
@class BITHockeyAttachment;

/**
 The `BITCrashManagerDelegate` formal protocol defines methods further configuring
 the behaviour of `BITCrashManager`.
 */

@protocol BITCrashManagerDelegate <NSObject>

@optional


///-----------------------------------------------------------------------------
/// @name Additional meta data
///-----------------------------------------------------------------------------

/** Return any log string based data the crash report being processed should contain

 @param crashManager The `BITCrashManager` instance invoking this delegate
 @see attachmentForCrashManager:
 @see userNameForHockeyManager:(BITHockeyManager *)hockeyManager componentManager:(BITHockeyBaseManager *)componentManager
 @see userEmailForHockeyManager:(BITHockeyManager *)hockeyManager componentManager:(BITHockeyBaseManager *)componentManager
 */
-(NSString *)applicationLogForCrashManager:(BITCrashManager *)crashManager;


/** Return a BITHockeyAttachment object providing an NSData object the crash report
 being processed should contain
 
 Please limit your attachments to reasonable files to avoid high traffic costs for your users.
 
 Example implementation:
 
     - (BITHockeyAttachment *)attachmentForCrashManager:(BITCrashManager *)crashManager {
       NSData *data = [NSData dataWithContentsOfURL:@"mydatafile"];
 
       BITHockeyAttachment *attachment = [[BITHockeyAttachment alloc] initWithFilename:@"myfile.data"
                                                                  hockeyAttachmentData:data
                                                                           contentType:@"'application/octet-stream"];
       return attachment;
     }
 
 @param crashManager The `BITCrashManager` instance invoking this delegate
 @see BITHockeyAttachment
 @see applicationLogForCrashManager:
 @see userNameForHockeyManager:(BITHockeyManager *)hockeyManager componentManager:(BITHockeyBaseManager *)componentManager
 @see userEmailForHockeyManager:(BITHockeyManager *)hockeyManager componentManager:(BITHockeyBaseManager *)componentManager
 */
-(BITHockeyAttachment *)attachmentForCrashManager:(BITCrashManager *)crashManager;



///-----------------------------------------------------------------------------
/// @name Alert
///-----------------------------------------------------------------------------

/** Invoked before the user is asked to send a crash report, so you can do additional actions.
 E.g. to make sure not to ask the user for an app rating :)
 
 @param crashManager The `BITCrashManager` instance invoking this delegate
 */
-(void)crashManagerWillShowSubmitCrashReportAlert:(BITCrashManager *)crashManager;


/** Invoked after the user did choose _NOT_ to send a crash in the alert
 
 @param crashManager The `BITCrashManager` instance invoking this delegate
 */
-(void)crashManagerWillCancelSendingCrashReport:(BITCrashManager *)crashManager;


/** Invoked after the user did choose to send crashes always in the alert
 
 @param crashManager The `BITCrashManager` instance invoking this delegate
 */
-(void)crashManagerWillSendCrashReportsAlways:(BITCrashManager *)crashManager;


///-----------------------------------------------------------------------------
/// @name Networking
///-----------------------------------------------------------------------------

/** Invoked right before sending crash reports will start
 
 @param crashManager The `BITCrashManager` instance invoking this delegate
 */
- (void)crashManagerWillSendCrashReport:(BITCrashManager *)crashManager;

/** Invoked after sending crash reports failed
 
 @param crashManager The `BITCrashManager` instance invoking this delegate
 @param error The error returned from the NSURLConnection/NSURLSession call or `kBITCrashErrorDomain`
 with reason of type `BITCrashErrorReason`.
 */
- (void)crashManager:(BITCrashManager *)crashManager didFailWithError:(NSError *)error;

/** Invoked after sending crash reports succeeded
 
 @param crashManager The `BITCrashManager` instance invoking this delegate
 */
- (void)crashManagerDidFinishSendingCrashReport:(BITCrashManager *)crashManager;

///-----------------------------------------------------------------------------
/// @name Experimental
///-----------------------------------------------------------------------------

/** Define if a report should be considered as a crash report
 
 Due to the risk, that these reports may be false positives, this delegates allows the
 developer to influence which reports detected by the heuristic should actually be reported.
 
 The developer can use the following property to get more information about the crash scenario:
 - `[BITCrashManager didReceiveMemoryWarningInLastSession]`: Did the app receive a low memory warning
 
 This allows only reports to be considered where at least one low memory warning notification was
 received by the app to reduce to possibility of having false positives.
 
 @param crashManager The `BITCrashManager` instance invoking this delegate
 @return `YES` if the heuristic based detected report should be reported, otherwise `NO`
 @see `[BITCrashManager didReceiveMemoryWarningInLastSession]`
 */
-(BOOL)considerAppNotTerminatedCleanlyReportForCrashManager:(BITCrashManager *)crashManager;

@end
