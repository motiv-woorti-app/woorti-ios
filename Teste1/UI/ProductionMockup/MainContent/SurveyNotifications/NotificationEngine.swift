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
import UserNotifications

/*
 * Handle and emit notifications
 */
class NotificationEngine {
    
    private var startTripSurveys = [Survey]()
    private var endTripSurveys = [Survey]()
    private var onceTripSurveys = [Survey]()
    private var repeatableTripSurveys = [Survey]()
    
    private static let NE = NotificationEngine()
    public static let NotificationTypeString = "type"
    public static let NotificationGlobalIdString = "survey"
    
    public static func getInstance() -> NotificationEngine {
        return NotificationEngine.NE
    }
    
    func dateTrigger() -> UNNotificationTrigger {
        // Configure the recurring date.
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        
        dateComponents.weekday = 3  // Tuesday
        dateComponents.hour = 14    // 14:00 hours
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: true)
        return trigger
    }
    
    func nowTrigger() -> UNNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    }
    
    func testContent() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Weekly Staff Meeting"
        content.body = "Every Tuesday at 2pm"
        return content
    }
    
    func SurveyContent(count: Int) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "You have \(count) new surveys to answer"
        content.body = "You also have \(TriggeredSurvey.getTriggeredSurveysFromSurveys().count) pending surveys \nclick to go view all pending surveys"
        
        content.userInfo[NotificationEngine.NotificationTypeString] = notificationtype.fillSurvey.rawValue
        return content
    }
    
    func DebugContent(title: String, body: String) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        content.userInfo[NotificationEngine.NotificationTypeString] = notificationtype.debug.rawValue
        return content
    }
    
    func EngagementContent(title: String, body: String) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        content.userInfo[NotificationEngine.NotificationTypeString] = notificationtype.engagement.rawValue
        return content
    }
    
    func sendNotification (content: UNNotificationContent, trigger: UNNotificationTrigger) {
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
            }
        }
    }
    
    func testSendFirstNotification() {
        self.sendNotification(content: testContent(), trigger: nowTrigger())
    }
    
    enum notificationtype: String {
        case fillSurvey
        case debug
        case engagement
    }
    
    func registerSurveys(surveys: [Survey]){
        for survey in surveys {
            registerSurvey(survey: survey)
        }
    }
    
    func registerSurvey(survey :Survey){
        if let te = survey.trigger as? TriggerEvent {
            if te.trigger == TriggerEvent.TriggerEvents.startTrip {
                self.startTripSurveys.append(survey)
            } else if te.trigger == TriggerEvent.TriggerEvents.endTrip {
                self.endTripSurveys.append(survey)
            }
        } else if let to = survey.trigger as? TriggerOnce {
            self.onceTripSurveys.append(survey)
        } else if let tr = survey.trigger as? TriggerRepeatable {
            self.repeatableTripSurveys.append(survey)
        }
    }
    
    func notificationDebugging(){
        self.sendNotification(content: self.SurveyContent(count: self.startTripSurveys.count), trigger: self.nowTrigger())
    }
    
    func notifyStartTripSurveys() {
        DispatchQueue.global(qos: .background).async {
            for survey in self.startTripSurveys {
                if survey.isSurveyValid() {
                    survey.triggerSurvey(date: Date())
                }
                
            }
            if self.startTripSurveys.count > 0 {
                self.sendNotification(content: self.SurveyContent(count: self.startTripSurveys.count), trigger: self.nowTrigger())
            }
        }
    }
    
    func notifyEndTripSurveys() {
        DispatchQueue.global(qos: .background).async {
            for survey in self.endTripSurveys {
                if survey.isSurveyValid() {
                    survey.triggerSurvey(date: Date())
                }
            }
            if self.endTripSurveys.count > 0 {
                self.sendNotification(content: self.SurveyContent(count: self.endTripSurveys.count), trigger: self.nowTrigger())
            }
        }
    }
    
    func notifyOnceTripSurveys() {
        DispatchQueue.global(qos: .background).async {
            var count = 0
    
            for survey in self.onceTripSurveys {
                if survey.isSurveyValid() {
                    if let to = survey.trigger as? TriggerOnce,
                        let tDate = to.timestamp,
                        !to.wasTriggered(),
                        tDate < Date() {
                        
                        survey.triggerSurvey(date: Date())
                        count += 1
                        to.triggered = true
                    }
                }
                
            }

            if count > 0 {
                self.sendNotification(content: self.SurveyContent(count: count), trigger: self.nowTrigger())
            }
        }
    }
    
    func notifyRepeatableSurveys() {
        DispatchQueue.global(qos: .background).async {
            var count = 0
            for survey in self.repeatableTripSurveys {
                if survey.isSurveyValid() {
                    if let to = survey.trigger as? TriggerRepeatable {
                        
                        var tDate = to.startday!
                        if (to.triggered ?? [Date]()).count > 1 {
                            tDate = Calendar.current.date(byAdding: .day, value: Int(to.timeInBetween), to: to.triggered!.last!)!
                        }
                        
                        if tDate < Date() {
                            survey.triggerSurvey(date: Date())
                            var triggered = (to.triggered ?? [Date]())
                            triggered.append(tDate)
                            to.triggered = triggered
                            count += 1
                        }
                    }
                }
            }
            if count > 0 {
                self.sendNotification(content: self.SurveyContent(count: count), trigger: self.nowTrigger())
            }
        }
    }
    
    func notifyDatedSurveys() {
        notifyOnceTripSurveys()
        notifyRepeatableSurveys()
    }
    
    func debugNotification(title: String, body: String, notify: Bool = true) {
        DispatchQueue.global(qos: .background).async {
            if notify {
                UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
                    //get debug
                    let matching = notifications.first(where: { notify in
                        let existingUserInfo = notify.request.content.userInfo
                        let id = existingUserInfo[NotificationEngine.NotificationTypeString] as? String
                        return id == NotificationEngine.notificationtype.debug.rawValue
                    })
                    
                    //remove notification
                    if let matchExists = matching {
                        UNUserNotificationCenter.current().removeDeliveredNotifications(
                            withIdentifiers: [matchExists.request.identifier]
                        )
                    }
                }
                self.sendNotification(content: self.DebugContent(title: title, body: body), trigger: self.nowTrigger())
                
            }
            UserInfo.writeToLog("title: \(title) at: \(Date()) \nbody: \(body)\n")
        }
    }
    
    func engagementNotification(title: String, body: String) {
        DispatchQueue.global(qos: .background).async {
            UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
                //get debug
                let matching = notifications.first(where: { notify in
                    //                            if let type = userinfo[NotificationEngine.NotificationTypeString] as? String {
                    let existingUserInfo = notify.request.content.userInfo
                    let id = existingUserInfo[NotificationEngine.NotificationTypeString] as? String
                    return id == NotificationEngine.notificationtype.engagement.rawValue
                })
                
                //remove notification
                if let matchExists = matching {
                    UNUserNotificationCenter.current().removeDeliveredNotifications(
                        withIdentifiers: [matchExists.request.identifier]
                    )
                }
            }
            self.sendNotification(content: self.EngagementContent(title: title, body: body), trigger: self.nowTrigger())
        }
    }
}
