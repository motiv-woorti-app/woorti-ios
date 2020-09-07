// (C) 2017-2020 - The Woorti app is a research (non-commercial) application that was
// developed in the context of the European research project MoTiV (motivproject.eu). The
// code was developed by partner INESC-ID with contributions in graphics design by partner
// TIS. The Woorti app development was one of the outcomes of a Work Package of the MoTiV
// project.
 
// The Woorti app was originally intended as a tool to support data collection regarding
// mobility patterns from city and country-wide campaigns and provide the data and user
// management to campaign managers.
 
// The Woorti app development followed an agile approach taking into account ongoing
// feedback of partners and testing users while continuing under development. This has
// been carried out as an iterative process deploying new app versions. Along the 
// timeline, various previously unforeseen requirements were identified, some requirements
// Were revised, there were requests for modifications, extensions, or new aspects in
// functionality or interaction as found useful or interesting to campaign managers and
// other project partners. Most stemmed naturally from the very usage and ongoing testing
// of the Woorti app. Hence, code and data structures were successively revised in a
// way not only to accommodate this but, also importantly, to maintain compatibility with
// the functionality, data and data structures of previous versions of the app, as new
// version roll-out was never done from scratch.

// The code developed for the Woorti app is made available as open source, namely to
// contribute to further research in the area of the MoTiV project, and the app also makes
// use of open source components as detailed in the Woorti app license. 
 
// This project has received funding from the European Union’s Horizon 2020 research and
// innovation programme under grant agreement No. 770145.
 
// This file is part of the Woorti app referred to as SOFTWARE.

import Foundation
import Firebase
import UserNotifications

//Own notifications
class PushNotificationsDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    func handleNotification(userinfo: [AnyHashable : Any], foreground: Bool) {
        if let type = userinfo[NotificationEngine.NotificationTypeString] as? String {
            switch type {
            case NotificationEngine.notificationtype.fillSurvey.rawValue:
                DispatchQueue.global(qos: .userInteractive).async {
                    UiAlerts.getInstance().showNewSurveysToAnswerAlert(foreground: foreground)
                }
            case NotificationEngine.notificationtype.debug.rawValue:
               
                break
//                DispatchQueue.global(qos: .userInteractive).async {
//                    UiAlerts.getInstance().showNewSurveysToAnswerAlert(foreground: foreground)
//                }
            default:
                print("no such type")
            }
        }
    }
    
    
    //delivered in foreground
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
        
        // Print full message.
        print(userInfo)
        handleNotification(userinfo: userInfo, foreground: true)
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    
    
    //delivered notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
        
        // Print full message.
        print(userInfo)
        handleNotification(userinfo: userInfo, foreground: false)
        
        //Currently disabled
        if response.notification.request.content.categoryIdentifier == "MEETING_INVITATION" {
            //            //            // Retrieve the meeting details.
            //            //            let meetingID = userInfo["MEETING_ID"] as! String
            //            //            let userID = userInfo["USER_ID"] as! String
            //            //
            //            //            switch response.actionIdentifier {
            //            //            case "ACCEPT_ACTION":
            //            //                sharedMeetingManager.acceptMeeting(user: userID,
            //            //                                                   meetingID: meetingID)
            //            //                break
            //            //
            //            //            case "DECLINE_ACTION":
            //            //                sharedMeetingManager.declineMeeting(user: userID,
            //            //                                                    meetingID: meetingID)
            //            //                break
            //            //
            //            //            case UNNotificationDefaultActionIdentifier,
            //            //                 UNNotificationDismissActionIdentifier:
            //            //                // Queue meeting-related notifications for later
            //            //                //  if the user does not act.
            //            //                sharedMeetingManager.queueMeetingForDelivery(user: userID,
            //            //                                                             meetingID: meetingID)
            //            //                break
            //            //
            //            //            default:
            //            //                break
            //            //            }
                    }
            //        else {
            //            // Handle other notification types...
            //        }
        
        completionHandler()
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler:
//        @escaping () -> Void) {
//        // Get the meeting ID from the original notification.
//        let userInfo = response.notification.request.content.userInfo
//
//        if response.notification.request.content.categoryIdentifier ==
//            "MEETING_INVITATION" {
//            //            // Retrieve the meeting details.
//            //            let meetingID = userInfo["MEETING_ID"] as! String
//            //            let userID = userInfo["USER_ID"] as! String
//            //
//            //            switch response.actionIdentifier {
//            //            case "ACCEPT_ACTION":
//            //                sharedMeetingManager.acceptMeeting(user: userID,
//            //                                                   meetingID: meetingID)
//            //                break
//            //
//            //            case "DECLINE_ACTION":
//            //                sharedMeetingManager.declineMeeting(user: userID,
//            //                                                    meetingID: meetingID)
//            //                break
//            //
//            //            case UNNotificationDefaultActionIdentifier,
//            //                 UNNotificationDismissActionIdentifier:
//            //                // Queue meeting-related notifications for later
//            //                //  if the user does not act.
//            //                sharedMeetingManager.queueMeetingForDelivery(user: userID,
//            //                                                             meetingID: meetingID)
//            //                break
//            //
//            //            default:
//            //                break
//            //            }
//        }
//        else {
//            // Handle other notification types...
//        }
//
//        // Always call the completion handler when done.
//        completionHandler()
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler:
//        @escaping (UNNotificationPresentationOptions) -> Void) {
//            if notification.request.content.categoryIdentifier ==
//                "MEETING_INVITATION" {
//                //            // Retrieve the meeting details.
//                //            let meetingID = notification.request.content.
//                //            userInfo["MEETING_ID"] as! String
//                //            let userID = notification.request.content.
//                //            userInfo["USER_ID"] as! String
//                //
//                //            // Add the meeting to the queue.
//                //            sharedMeetingManager.queueMeetingForDelivery(user: userID,
//                //                                                         meetingID: meetingID)
//                //
//                //            // Play a sound to let the user know about the invitation.
//                //            completionHandler(.sound)
//                return
//            }
//            else {
//                // Handle other notification types...
//            }
//
//            // Don't alert the user for other types.
//            completionHandler(UNNotificationPresentationOptions(rawValue: 0))
//    }
    
}
