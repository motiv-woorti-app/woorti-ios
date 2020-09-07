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
import CoreMotion
import CoreLocation
import CoreData
import os.log
import Firebase

/**
 Static class with the application context.
 Accessible by everywhere on the app.
 - State Properties:
    - fulltrips: The complete list of Trips stored in this device(fetched from Core data when initializing)
    - context: NSManaged Context where persistent objects are stored
    - activities: The complete list of UserActivities stored in this device(fetched from Core data when initializing)
    - userAcceleration: The complete list of accelerations stored in this device(accelerations only retrieved when on a trip)(fetched from Core data when initializing)
    - mockActivities: The complete list of mocked Activities on this device
 
 - Sincronization:
    - actSem: semaphore with value 1 used to sincronize accesses to the activities list
    - accSem: semaphore with value 1 used to sincronize accesses to the acceleration list
    - ContextSemaphore: semaphore with value 1 used to sincronize accesses to Core data context object, used when creatin core data objects.
 
 - Session Properties(Per session):
    - user: Logged in user (TODO, incomplete may change)
    - email: user email(already in user variable)(FIXME)
    - authenticationToken: authentication token received from firebase when logging in
 */
class UserInfo { //: NSManagedObject
    
    //MARK: properties
    private static var fulltrips = [FullTrip]() // list of fulltrips
    public static var context: NSManagedObjectContext?
    public static var parentContext: NSManagedObjectContext?
    private static let startupSemaphore = DispatchSemaphore(value: 0)
    private static var activities = [UserActivity]()
    private static let actSem = DispatchSemaphore(value: 1)
    private static var userAcceleration = [UserAcceleration]()
    private static let accSem = DispatchSemaphore(value: 1)
    public static var mockActivities = [MockActivity]()
    public static var appDelegate :AppDelegate?
    public static let ContextSemaphore = DispatchSemaphore(value: 1)
    private static var Surveys = [Survey]()
    private static var answeredSurveys = [AnsweredSurvey]()
    private static let SurveysAnsweringSem = DispatchSemaphore(value: 1)
    private static var answerSurveysSending = [AnsweredSurvey]()
    public static var campaigns = [MockCampaign]()
    
    public static var partToGiveFeedback: FullTripPart? = nil
    
    public static var debugLog = ""
    
    //MARK: Session Properties
    static var authenticationToken: String? = nil
    static var mRequestMan: MotivRequestManager?
    static var email: String? = nil
    private static var user: MotivUser?
    static var pnToken: String?
    
    private static var hasStartedTripDetection = false
    
    //MARK: functions
    //User functions
    /**
     set user after login
     - parameters:
        - user: the user that just logged in
     */
    public static func setUser(user: MotivUser){
        self.user=user
    }
    
    /**
     get the user that is logged in
     - returns: the user that is logged in, nil if no one is logged in
     */
    public static func getUser() -> MotivUser? {
        return self.user
    }
    
    //MARK: activity management functions(thread safe)
    /**
     get a copy of the activities list(thread safe)
     - returns: the copy of the current activities list
     */
    public static func getActivityList() -> [UserActivity] {
        actSem.wait()
        var acts = [UserActivity]()
        acts.append(contentsOf: activities)
        actSem.signal()
        return acts
    }
    
    /**
     adds an activity to the activities list(thread safe)
     - parameters:
        - act: the new activity
     */
    public static func addActivity(act: UserActivity){
        actSem.wait()
        activities.append(act)
        actSem.signal()
    }
    
    
    /**
     Used to clean the activities list after a while to spare disk space
     (commented for tests, production will be uncommented)(thread safe)
     */
    public static func resetActivityList(){
        actSem.wait()
        if activities.count > 1 {
            activities = [activities.last!]
        }
        actSem.signal()
    }
    
    
    /**
     add new activity mode to the full trip(thread safe)
     - parameters:
        - act: the new activity
     */
    public static func newActivity(activity: CMMotionActivity){
        addActivity(act: UserActivity.getUserActivity(userActivity: activity, context: UserInfo.context!)!)
    }
    
    /**
     add new activity mode to the full trip(thread safe)
     - parameters:
        - act: the new mock activity
     */
    public static func newMockActivity(activity: MockActivity){
        mockActivities.append(activity)
    }
    
    //MARK: location management functions
    /**
     Start a new Trip on startLocation
     - parameters:
        - startLocation: the location where this new Trip start
     */
    public static func newFullTrip(startLocation: CLLocation, fromUI: Bool = false){
        let ft = FullTrip.getFullTrip(startLocation: startLocation, context: context!)!
        ft.manualTripStart = fromUI
        fulltrips.append(ft)
        fulltrips.last?.manualTripStart = fromUI
        NotificationEngine.getInstance().notifyStartTripSurveys()
        MotivUser.getInstance()?.trySendNextNotificationOnStartTrip()
    }
    
    /**
     End a new Trip on startLocation
     - parameters:
        - endFullTrip: the location where this Trip ends
     */
    public static func endFullTrip(endLocation: CLLocation, fromUI: Bool = false) -> Bool {
        if let fulltrip = fulltrips.last {
            let bg = FiniteBackgroundTask()
            bg.registerBackgroundTask(withName: "EndTrip")
            if !fulltrip.close(endLocation: endLocation) {
                UserInfo.removeFulltripIfEmpty(ft: fulltrip)
                bg.endBackgroundTask()
                if fromUI {
                    fulltrip.manualTripEnd = true
                }
                UserInfo.appDelegate?.saveContext()
                return false
            }
            UserInfo.removeFulltripIfEmpty(ft: fulltrip)
            bg.endBackgroundTask()
            
            UserInfo.appDelegate?.saveContext()
            NotificationEngine.getInstance().notifyEndTripSurveys()
            MotivUser.getInstance()?.trySendNextNotificationOnEndTrip()
            return true
        }
        return false
    }
    
    /**
     Get a list with all Trips
     - returns: a list of all Trip
     */
    public static func getFullTrips() -> [FullTrip] {
        let returnedValue = fulltrips
        return returnedValue
    }
    
    /**
     ends a Leg in endLocation
     - parameters:
        - endLocation: the last location on the Trip
     */
    public static func endTrip(endLocation: CLLocation, fromUI: Bool = false){
        let bg = FiniteBackgroundTask()
        bg.registerBackgroundTask(withName: "EndLeg")
        fulltrips.last?.manualTripEnd = fromUI
        fulltrips.last?.endLeg(endLocation: endLocation, context: UserInfo.context!)
        bg.endBackgroundTask()
    }
    
    /**
     starts a Leg in startLocation
     - parameters:
        - startLocation: the first location on the Trip
     */
    public static func newTrip(startLocation: CLLocation){
        fulltrips.last?.newLeg(startLocation: startLocation, context: UserInfo.context!)
    }
    
    /**
     add new location to the Trip(last part of the trip)
     - parameters:
        - location: the new Location
     */
    public static func newLocation(location: CLLocation){
        fulltrips.last?.newLocation(location: location, context: UserInfo.context!)
    }
    
    /**
     return if the user is in Trip
     - return: True if the last Trip is not closed
     */
    public static func inFullTrip() -> Bool {
        if(fulltrips.count>0){
            return !(fulltrips.last?.closed)!
        }
        return false
    }
    
    //MARK: PrintFunctions
    //printInfo
    static public func printInfo() -> String {
        var responseText: String = ""
        for fullTrip in fulltrips {
            responseText.append(fullTrip.printInfo())
        }
        return responseText
    }
    
    //MARK: core data main functions
    /**
     fetch all information from Core Data
     - parameters:
        - context: NSManagedObjectContext of the previously saved data
     */
    public static func startUp(context: NSManagedObjectContext){
        UserInfo.parentContext = context
        //
        let bg = FiniteBackgroundTask()
        bg.registerBackgroundTask(withName: "UserInfoStartUp")
        
        UserInfo.context = {
            let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            managedObjectContext.parent = context
            managedObjectContext.automaticallyMergesChangesFromParent = true
            managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            managedObjectContext.shouldDeleteInaccessibleFaults = true
            return managedObjectContext
        }()
        
        UserInfo.ContextSemaphore.wait()
        UserInfo.context?.performAndWait {
            let ftRequest = NSFetchRequest<NSFetchRequestResult>(entityName: FullTrip.entityName)
            ftRequest.returnsObjectsAsFaults = false
            let uaRequest = NSFetchRequest<NSFetchRequestResult>(entityName: UserActivity.entityName)
            uaRequest.returnsObjectsAsFaults = false
            let accsRequest = NSFetchRequest<NSFetchRequestResult>(entityName: UserAcceleration.entityName)
            accsRequest.returnsObjectsAsFaults = false
            let SurveysRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Survey.MyEntityName)
            SurveysRequest.returnsObjectsAsFaults = false
            let AnsweredSurveysRequest = NSFetchRequest<NSFetchRequestResult>(entityName: AnsweredSurvey.MyEntityName)
            AnsweredSurveysRequest.returnsObjectsAsFaults = false
            
            do {
                UserInfo.fulltrips = try UserInfo.context?.fetch(ftRequest) as! [FullTrip]
            } catch {
                Crashlytics.sharedInstance().recordError(error)
            }
            
            do {
                UserInfo.activities = try UserInfo.context?.fetch(uaRequest) as! [UserActivity]
            } catch {
                Crashlytics.sharedInstance().recordError(error)
            }
            
            do {
                UserInfo.userAcceleration = try UserInfo.context?.fetch(accsRequest) as! [UserAcceleration]
            } catch {
                Crashlytics.sharedInstance().recordError(error)
            }
            
            do {
                UserInfo.Surveys = try UserInfo.context?.fetch(SurveysRequest) as! [Survey]
                NotificationEngine.getInstance().registerSurveys(surveys: UserInfo.Surveys)
            } catch {
                Crashlytics.sharedInstance().recordError(error)
            }
            
            do {
                UserInfo.answeredSurveys = try UserInfo.context?.fetch(AnsweredSurveysRequest) as! [AnsweredSurvey]
            } catch {
                Crashlytics.sharedInstance().recordError(error)
            }
            
            UserInfo.startupSemaphore.signal()
            
        }
        UserInfo.ContextSemaphore.signal()
        bg.endBackgroundTask()
        
    }
    
    /*
    * Set Real Mots for every trip
    */
    public static func setRealMots() {
        for ft in getFullTrips() {
            ft.setRealMots()
        }
    }
    
    /*
    * get user context
    */
    static func getMainContext() -> NSManagedObjectContext {
        UserInfo.startupSemaphore.wait()
        UserInfo.startupSemaphore.signal()
        return UserInfo.context!
    }
    
    /*
    * Fetch trips from CoreData
    */
    static func fetchUserTrips(){
        if let user = Auth.auth().currentUser {
            ContextSemaphore.wait()
            let ftRequest = NSFetchRequest<NSFetchRequestResult>(entityName: FullTrip.entityName)
            ftRequest.predicate = NSPredicate(format: "uid == %@", user.uid)
            do {
                fulltrips = try UserInfo.context?.fetch(ftRequest) as! [FullTrip]
            } catch {
                Crashlytics.sharedInstance().recordError(error)
            }
            ContextSemaphore.signal()
        }
    }
    
    //MARK: testing functions
    /**
     Fucntion used to close all open Trips when re-starting the app
     */
    public static func closeOpenedTrips(){
        if let ctx = UserInfo.context {
            for ft in fulltrips {
                var needsSaving = false
                if !ft.closed {
                    ctx.performAndWait {
                        needsSaving = true
                        ft.CloseFt()
                        ft.cleanTrip()
                        UserInfo.removeFulltripIfEmpty(ft: ft)
                    }
                }
                if(needsSaving) {
                    UserInfo.appDelegate?.saveContext()
                }
            }
            
        }
        
    }
    
    /*
    * Send to server - trips confirmed by the user but not sent to server
    */
    static func sendConfirmedTripsNotSentToServer(){
        DispatchQueue.global(qos: .background).async {
            if !MotivRequestManager.getInstance().tripBeingSentToServer {
                for trip in fulltrips {
                    UserInfo.context?.perform({
                        if trip.closed && trip.confirmed && !trip.sentToServer {
                            MotivRequestManager.getInstance().sendTrip(trip: trip)
                        }
                    })
                }
            }
        }
    }
    
    //MARK: Auxiliar functions
    /**
     convert seconds to a human readable format
     - returns: tuple with (hours,minutes,seconds) in INT format
     */
    public static func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    /**
     convert seconds to a human readable string format
     - returns: the formatted string to show
     */
    public static func printHoursMinutesSeconds(seconds: Int) -> String {
        var returnString = ""
        let (hour,minute,second) = UserInfo.secondsToHoursMinutesSeconds(seconds: seconds)
        if hour > 0 {
            returnString += "\(hour)H"
        }
        if minute > 0 {
            returnString += "\(minute)m"
        }
        if second > 0 {
            returnString += "\(second)s"
        }
        
        return returnString
    }
    
    /**
     removes a Trip that has no Legs/Waiting Events.
     Used on postProcessing to cleanup.
     */
    static func removeFulltripIfEmpty(ft: FullTrip){
        //Changed from trip part to trip (no sense in having a trip wich is a waiting event)
        if ft.getTripOrderedList().count < 1 {
            ft.delete()
        }
        ft.deleteEmptyLegs()
    }
    
    //MARK:acceleration Functions
    /**
     adds a new acceleration value to the acceleration list(thread safe)
     - parameters:
        - ua: new acceleration to add
     */
    static func addAcceleration(_ ua: UserAcceleration){
        accSem.wait()
        userAcceleration.append(ua)
        accSem.signal()
    }
    
    /**
     get a copy of the acceleration list
     - returns: copy of the list of all accelerations sorted by most recent first
     */
    static func getAccelerations() -> [UserAcceleration] {
        
        var tempAcc = [UserAcceleration]()
        accSem.wait()
        tempAcc.append(contentsOf: userAcceleration)
        accSem.signal()
        var rval = [UserAcceleration]()
            rval = tempAcc.sorted(by: { (ua1, ua2) -> Bool in
                return ua1.timestamp < ua2.timestamp
            })
        return rval
    }
    
    /*
    * Get Unsorted Accelerations
    */
    static func getAccelerationsWithoutSort() -> [UserAcceleration] {
        
        var tempAcc = [UserAcceleration]()
        accSem.wait()
        tempAcc.append(contentsOf: userAcceleration)
        accSem.signal()
        var rval = [UserAcceleration]()
        return rval
    }
    
    /*
    * Send confirmed trips to server
    */
    static func DumpToServerConfirmedTrips() {
        for trip in fulltrips {
            if trip.confirmed && !trip.sentToServer {
                trip.confirmTrip()
            }
        }
    }
    
    /*
    * Remove trip from CoreData
    */
    static func removeTrip(trip: FullTrip){
        if let index = fulltrips.index(of: trip) {
            fulltrips.remove(at: index)
        }
    }
    
    //MARK: surveyFunctions
    static func getSurveys() -> [Survey] {
        return UserInfo.Surveys
    }
    
    /*
    * If a repeated survey is received from the server, replace it. 
    */
    static func replaceRepeatedSurvey(newSurvey: Survey) -> Bool{
        
        for survey in getSurveys() {
            if survey.surveyID == newSurvey.surveyID {
                survey.globalSurveyTimestamp = newSurvey.globalSurveyTimestamp
                if(!survey.deletedSurvey) {
                    survey.deletedSurvey = newSurvey.deletedSurvey
                }
                return true
            }
        }
        return false
    }
    
    
    //Add surveys. If a repeated survey is received, ignore it and replace new global survey timestamp
    static func addSurveys(surveys: [Survey]) {

        var surveysToAdd = [Survey]()
        for survey in surveys {
            if replaceRepeatedSurvey(newSurvey: survey) {
                print("Replaced duplicated survey with ID=" + String(survey.surveyID))
            }
            else {
                print("Addind new survey with ID=" + String(survey.surveyID))
                surveysToAdd.append(survey)
            }
        }
    
        if surveysToAdd.count > 0 {
            UserInfo.Surveys.append(contentsOf: surveysToAdd)
            NotificationEngine.getInstance().registerSurveys(surveys: surveysToAdd)
        }
        
        self.appDelegate?.saveContext()
    }
    
    /*
    * Remove survey used for Reporting
    */
    static func removeReportingSurvey() {
        UserInfo.Surveys = UserInfo.Surveys.filter({ (survey) -> Bool in
            if let trigger = survey.trigger as? TriggerEvent,
                trigger.trigger == TriggerEvent.TriggerEvents.reporting {
                return false
            }
            return true
        })
        self.appDelegate?.saveContext()
    }
    

    static func setAnsweredSurveys(answeredSurveys: [AnsweredSurvey]){
        SurveysAnsweringSem.wait()
        self.answeredSurveys = answeredSurveys
        SurveysAnsweringSem.signal()
    }
    
    /*
    * Get surveys that need to be sent to server
    */
    static func getAnsweredSurveysToSend() -> [AnsweredSurvey]{
        SurveysAnsweringSem.wait()
        self.answerSurveysSending.append(contentsOf: self.answeredSurveys)
        self.answeredSurveys = [AnsweredSurvey]()
        SurveysAnsweringSem.signal()
        return self.answerSurveysSending
    }
    
    // get surveys by function,
    // get only the normal or rerporting surveys
    // each different answered surveys is sent to a different endpoint
    static func getSurveyByfunction(reporting: Bool) -> [AnsweredSurvey] {
        var answeredSurvey = [AnsweredSurvey]()
        
        for survey in Surveys {
            if let etrigger = survey.trigger as? TriggerEvent,
                etrigger.trigger == TriggerEvent.TriggerEvents.reporting {
                answeredSurvey.append(contentsOf: self.answeredSurveys.filter({ (answer) -> Bool in
                    if answer.surveyID == survey.surveyID && answer.version == survey.version {
                        return reporting
                    } else {
                        return !reporting
                    }
                }))
            }
        }
        
        return answeredSurvey
    }
    
    // get reports to send
    // get the reporting answers that are pending to send.
    // flags the answers that are pending to be sent.
    static func getReportToSend() -> [AnsweredSurvey] {
        SurveysAnsweringSem.wait()
        let reportingSurvey = getSurveyByfunction(reporting: true)
        self.answerSurveysSending.append(contentsOf: reportingSurvey)
        self.answeredSurveys = getSurveyByfunction(reporting: false)
        SurveysAnsweringSem.signal()
        return self.answerSurveysSending
    }
    
    // Remove an answer (after it was successfully sent to the server)
    static func removeSubmissions() {
        SurveysAnsweringSem.wait()
        guard let ctx = UserInfo.context else {
            print("no context")
            SurveysAnsweringSem.signal()
            return
        }
        for answeredSurvey in self.answerSurveysSending {
                for answer in answeredSurvey.answers?.allObjects as? [Answer] ?? [Answer]() {
                    ctx.delete(answer)
                }
            ctx.delete(answeredSurvey)
        }
        answerSurveysSending = [AnsweredSurvey]()
        self.appDelegate?.saveContext()
        SurveysAnsweringSem.signal()
    }
    
    /*
    * After a survey is filled, the strutures that flag a new survey to fill are updated.
    */
    static func removeTriggeredDatesFromSurveys(ansS: AnsweredSurvey, triggerDate: Date){
        self.Surveys.forEach { (survey) in
            if (survey.surveyID == ansS.surveyID && survey.version == ansS.version  ) {
                let dates = survey.getTriggeredDates().filter({ (date) -> Bool in
                    return date != triggerDate
                })
                survey.triggeredDates = dates
            }
        }
    }
    
    /*
    * Check if there are new answered surveys
    */
    static func hasAnswersToSend() -> Bool {
        return self.answeredSurveys.count > 0 || self.answerSurveysSending.count > 0
    }
    
    /*
    * Add questions answered to answered surveys
    */
    static func answerQuestions(surveyID: Double, version: Double, trigger: Trigger, triggerDate: Date, uid: String, answers: [Answer], reportingID: String = "", reportingOS: String = "") {
        SurveysAnsweringSem.wait()
        if let answeredSurvey = getSurveyAnswered(surveyID: surveyID, version: version, triggerDate: triggerDate, uid: uid) {
            
            answeredSurvey.reportingID = reportingID
            answeredSurvey.reportingOS = reportingOS
            if answeredSurvey.answers == nil {
                answeredSurvey.answers = NSSet()
            }
            answeredSurvey.answers = (answeredSurvey.answers ?? NSSet()).addingObjects(from: answers) as? NSSet ?? NSSet()
            removeTriggeredDatesFromSurveys(ansS: answeredSurvey, triggerDate: triggerDate)
        }
        SurveysAnsweringSem.signal()
    }
    
    
    /*
    * Create an answered survey without the answers
    */ 
    private static func getSurveyAnswered(surveyID: Double, version: Double, triggerDate: Date, uid: String) -> AnsweredSurvey? {
        let survey = self.answeredSurveys.filter { (answeredSurvey) -> Bool in
            return answeredSurvey.surveyID == surveyID && answeredSurvey.version == version
        }
        if survey.count > 0 {
            return survey.first!
        } else if let ctx = UserInfo.context,
            let user = MotivUser.getInstance() {
            var userLang = Languages.getLanguages().first!.woortiID
            if let lang = Languages.getLanguageForSMCode(smartphoneID: user.language ?? "") {
                userLang = lang.woortiID
            }
            
            let survey = AnsweredSurvey(surveyID: surveyID, version: version, uid: uid, triggerDate: triggerDate.timeIntervalSince1970*1000, answerDate: Date().timeIntervalSince1970*1000, lang: userLang, context: ctx)
            self.answeredSurveys.append(survey)
            return survey
        }
        return nil
    }
    
    /*
    * Initialize trip detection
    */
    static func startUpTripDetectionOnStart() {
        if hasStartedTripDetection {
            return
        }
        appDelegate?.startUpTripDetectionOnStart()
        hasStartedTripDetection = true
    }
    
    /*
    * get trips by startDate
    */
    static func getDateFromDateTime(date: Date, dayDistance: Int = 0) -> Date{
        let calendar = NSCalendar.current
        var c = DateComponents()
        
        c.year = calendar.component( .year, from: date)
        c.month = calendar.component( .month, from: date)
        c.day = calendar.component( .day, from: date) + dayDistance
        c.hour = 1
        c.minute = 0
        c.second = 0
        
        return (NSCalendar.current.date(from: c))!
    }
    
    static func getDateForTrips(ft: FullTrip) -> Date {
        return getDateFromDateTime(date: ft.startDate!)
    }
    
    /*
    * Build daily travel report. Returns (ditance, duration).
    */
    static func processDayTravelReport() -> (Double,Double) {
        let today = getDateFromDateTime(date: Date())
        let yesterday = getDateFromDateTime(date: today, dayDistance: -7)
        
        let todaytrips = getTripsByDay(date: today)
        let yesterdaytrips = getTripsByDay(date: yesterday)
        
        let todayTimeAndDistance = getTimeAndDistanceForTrips(fts: todaytrips)
        let yesterdayTimeAndDistance = getTimeAndDistanceForTrips(fts: yesterdaytrips)
        
        return (todayTimeAndDistance.0 - yesterdayTimeAndDistance.0, todayTimeAndDistance.1 - yesterdayTimeAndDistance.1)
    }
    
    /*
    * Build weekly travel report. Returns (ditance, duration).
    */
    static func processLast7DaysTravelReport() -> (Double,Double) {
        let today = getDateFromDateTime(date: Date())
        let yesterday = getDateFromDateTime(date: today, dayDistance: -7)
        
        let yesterdaytrips = getTripsLast7Days(date: yesterday)
        
        let yesterdayTimeAndDistance = getTimeAndDistanceForTrips(fts: yesterdaytrips)
        
        return (yesterdayTimeAndDistance.0, yesterdayTimeAndDistance.1)
    }
    
    /*
    * Calculate the sum of distance and time for the fiven trip array
    * Returns (Distance, Duration)
    */
    static func getTimeAndDistanceForTrips(fts: [FullTrip]) -> (Double,Double) {
        var info = (Double(0),Double(0))
        fts.forEach { (ft) in
            let dist = ft.distance
            let dur = ft.duration
            
            print("=== Full trip duration=" + String(dur) + ", dist=" + String(dist))
            if let validation = ft.validationDate {
                info.0 += Double(dist)
                info.1 += Double(dur)
            }

        }
        return info
    }
    
    /*
    * Return Trip array associated with a given date
    */
    static func getTripsByDay(date: Date) -> [FullTrip] {
        return getFullTrips().filter({ (ft) -> Bool in
            return (ft.closed && getDateForTrips(ft: ft) == getDateFromDateTime(date: date))
        })
    }
    
    /*
    * Return Trip array associated with the last 7 days
    */
    static func getTripsLast7Days(date: Date) -> [FullTrip] {
        return getFullTrips().filter({ (ft) -> Bool in
            return (ft.closed && getDateForTrips(ft: ft) >= getDateFromDateTime(date: date))
        })
    }
    
    
    //FUNCTIONS TO WRITE/READ FROM File

    static func writeToFile(file: String, text: String) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                let data = text.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    if let fileHandle = try? FileHandle(forUpdating: fileURL) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                    }
                } else {
                    print("write to file doesnt exist")
                    do {
                        try text.write(to: fileURL, atomically: false, encoding: .utf8)
                    } catch {
                        print("write to file: \(error)")
                    }
                }
            }
            catch {
                if (error as! NSError).code == 260 {
                    do {
                        try text.write(to: fileURL, atomically: false, encoding: .utf8)
                    } catch {
                        print("write to file: \(error)")
                    }
                } else {
                    print("write to file: \(error)")
                }
            }
        }
    }
    
    static func readFromFile(file: String) -> String {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                return try String(contentsOf: fileURL, encoding: .utf8)
            }
            catch {
                print("read from file: \(error)")
            }
        }
        return ""
    }
    
    static func deleteFile(file: String) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("error deleteFile: \(error)")
            }
        }
    }
    
    //log Functions
    static let logSem = DispatchSemaphore(value: 1)
    static let writeLogSem = DispatchSemaphore(value: 1)
    static let logFile = "Log"
    static let logFilePrev = "PrevLog"
    static var logString = ""
    static var pendingLogString = ""
    static var lastWrite = Date()
    
    public static func writeToLog(_ text: String, force: Bool = false) {
    }
    
    public static func readFromAllLogFiles() -> String {
        writeToLog("", force: true)
        logSem.wait()
        var string = readFromFile(file: logFilePrev)
        string.append(readFromFile(file: logFile))
        logSem.signal()
        print("reading from files: \(string.count) chars")
        return string
    }
    
    public static func readFromLog() -> String{
        if logString.count > 0 {
            return logString
        }
        logSem.wait()
        if logString.count == 0 {
            let result = readFromFile(file: logFile)
            logString = result
            print("reading from file: \(logString.count) chars")
        }
        logSem.signal()
        return logString
    }
    
    public static func deleteLogNoLock(){
        deleteFile(file: logFilePrev)
        deleteFile(file: logFile)
        logString = ""
    }
    
    public static func deleteLog(){
        logSem.wait()
        deleteFile(file: logFilePrev)
        deleteFile(file: logFile)
        writeLogSem.wait()
        logString = ""
        writeLogSem.signal()
        logSem.signal()
        print("deleting log")
    }
    
    
    /*
    * Delete trip array from coredata
    */
    static func DeleteTrips(fts: [FullTrip]) {
        fulltrips = fulltrips.filter { (ft) -> Bool in
            return !fts.contains(ft)
        }
        for ft in fts {
            if let obj = UserInfo.context?.registeredObject(for: ft.objectID) {
                UserInfo.context?.delete(ft)
            }
        }
    }
    
    /*
    * Merge trip array
    */
    static func mergeTrips(fts: [FullTrip]) {
        var ftsToMerge = fts
        let first = ftsToMerge.removeFirst()
        
        for ft in ftsToMerge {
            let firstLocation = first.getLastLocation()
            let lastLocation = ft.getFirstLocation()
            
            if firstLocation!.timestamp.addingTimeInterval(5*60) > lastLocation!.timestamp {
                if let We = ft.getTripPartsortedList().first as? WaitingEvent {
                    We.newLocation(location: UserLocation.getUserLocation(userLocation: firstLocation!, context: UserInfo.context!)!)
                } else {
                    let We = WaitingEvent(startDate: firstLocation!.timestamp, context: UserInfo.context!)
                    We.newLocation(location: UserLocation.getUserLocation(userLocation: firstLocation!, context: UserInfo.context!)!)
                    We.newLocation(location: UserLocation.getUserLocation(userLocation: lastLocation!, context: UserInfo.context!)!)
                    first.addToTrips(We)
                }
            }
            
            first.addToTrips(ft.trips)
            
        }
        DeleteTrips(fts: ftsToMerge)
        
        first.closed = false
        first.CloseFt()
    }
    
    /*
    * Split some trip.
    * parameters:
    * ft: trip to be splitted.
    * part: last leg of ft
    */
    static func splitTrip(ft: FullTrip, part: FullTripPart) {
        if let ind = ft.getTripPartsortedList().index(of: part) {
            let trips = ft.getTripPartsortedList()
            ft.trips.removeAllObjects()
            var newFullTrip: FullTrip?
            for index in 0...(trips.count-1){
                
                let partToSplit = trips[index]
                if index > ind {
                    if newFullTrip == nil {
                        newFullTrip = FullTrip(startLocation: partToSplit.getLocationsortedList().first!.location!, context: UserInfo.context!)
                    }
                    newFullTrip?.addToTrips(partToSplit)
                    
                } else {
                    ft.addToTrips(partToSplit)
                }
            }
            newFullTrip?.closed = false
            newFullTrip?.CloseFt()
            ft.closed = false
            ft.CloseFt()
            
            if let nft = newFullTrip {
                fulltrips.append(nft)
            }
        }
    }
}
