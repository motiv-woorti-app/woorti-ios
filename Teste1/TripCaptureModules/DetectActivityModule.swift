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

class DetectActivityModule {
    
    //MARK:properties
    static public var viewControllerSnapped: ViewController? //used to notify inferface of changes
    static private var actMan: CMMotionActivityManager?
    static private var lastDateSearched = Date()
    static public let ActivityTimeInterval = 10*60 //seconds
    
    public static var MockActivities = false // true for testing purposes only
    
    public static var numOccurences = 70
    public static var numOccurencesMax = 10000
    
    public static var actNumOccurences = 0
    public static var numOccurrencesSurveys = 2000
    
    
    //MARK:functions
    //used to start the activity detection service
    static func startAD() {
        if !MockActivities {
            if actMan == nil {
                DetectActivityModule.startContinuousAD()
                
            }
        }
    }
    
    //Start activity detection with real time detection
    private static func startContinuousAD(){
        //Activity request
        if !MockActivities {
            if CMMotionActivityManager.isActivityAvailable(){
                actMan = CMMotionActivityManager()
                let backgroungOQ: OperationQueue = OperationQueue()
                backgroungOQ.qualityOfService = .background
                let motionHandler: CMMotionActivityHandler = myHandler(activity:)
                actMan!.startActivityUpdates(to: backgroungOQ, withHandler: motionHandler)
            }
        }
    }
    
    //Start activity detection on a timer and retrieve all activities from ActivityTimeInterval seconds ago variable
    private static func startADonTimer(){
        //Activity requests on timer
        if !MockActivities {
            if CMMotionActivityManager.isActivityAvailable(){
                if (DetectActivityModule.actMan==nil) {
                    DetectActivityModule.actMan = CMMotionActivityManager()
                }
                
                //Query handler operation queue
                let backgroungOQ: OperationQueue = OperationQueue()
                backgroungOQ.qualityOfService = .utility
                
                let now=Date()
                
                let dateComponents: DateComponents = {
                    var dateComponents = DateComponents()
                    dateComponents.setValue(-1, for: .hour)
                    return dateComponents
                }()
                
                guard let startDate = NSCalendar.current.date(byAdding: dateComponents, to: now) else { return }
                
                DetectActivityModule.actMan!.queryActivityStarting(from: startDate, to: now, to: backgroungOQ){ activities, error in
                    DetectActivityModule.handleMultipleActivities(activities: activities, error: error)
                }
                
                DetectActivityModule.lastDateSearched=now
                
                Timer.scheduledTimer(timeInterval: TimeInterval(DetectActivityModule.ActivityTimeInterval), target: DetectActivityModule(), selector: #selector(ActivityTimer), userInfo: nil, repeats: true)
            }
        }
    }
    
    //used to stop activity detection
    static func stopAD(){
        actMan?.stopActivityUpdates()
        actMan=nil
    }
    
    
    @objc func ActivityTimer(){
        if (DetectActivityModule.actMan==nil) {
            DetectActivityModule.actMan = CMMotionActivityManager()
        }
        
        let backgroungOQ: OperationQueue = OperationQueue()
        backgroungOQ.qualityOfService = .utility
        
        let now=Date()
        
        DetectActivityModule.actMan!.queryActivityStarting(from: DetectActivityModule.lastDateSearched, to: now, to: backgroungOQ){ activities, error in
            DetectActivityModule.handleMultipleActivities(activities: activities, error: error)
        }
        
        DetectActivityModule.lastDateSearched=now
    }
    
    static private func handleMultipleActivities(activities:[CMMotionActivity]?, error:Error?) ->Void{
        if (activities != nil) {
            for activity in activities! {
                myHandler(activity: activity)
            }
        }
    }
    
    //handler for the detected ativity
    static private func myHandler(activity:CMMotionActivity?) -> Void {
        actNumOccurences += 1
        actNumOccurences %= numOccurencesMax
        
        if actNumOccurences % numOccurrencesSurveys == 0 {
            print("NotifyingDatedSurveys")
            
            //get the list of survey if changed
            
            MotivRequestManager.getInstance().UpdateMySurveys()
            
            NotificationEngine.getInstance().notifyDatedSurveys()
            MotivUser.getInstance()?.trySendNextNotificationFromElsewhere()
            NotificationEngine.getInstance().notifyOnceTripSurveys() // Temp func to fire all once surveys if should already have fired
 
 
            
        }
        
        if actNumOccurences % numOccurences == 0 {
            print("Activating GPS due to periodic num occurences")
            PowerManagementModule.TurnGpsOn()
        }
        
        
        print("actNumOccurences: \(actNumOccurences)")
        
        if(activity==nil){
            return
        } else if validateActivity(activity: activity!) {
            //send new activity to userInfo
            
            UserInfo.newActivity(activity: activity!)
            PowerManagementModule.processnewActivity(activity: activity!)
//            print("Got Activity: " + printActivity(activity: activity!))
        }
    }
    
    static private func validateActivity(activity: CMMotionActivity) -> Bool {
        return activity.stationary || activity.walking || activity.running || activity.automotive || activity.cycling || activity.unknown
    }
    
    static private func printActivity(activity: CMMotionActivity) -> String {
        var responseText = ""
        if activity.walking {
            responseText.append("walking ")
        }
        if activity.stationary {
            responseText.append("stationary ")
        }
        if activity.automotive {
            responseText.append("automotive ")
        }
        if activity.cycling {
            responseText.append("cycling ")
        }
        if activity.running {
            responseText.append("running ")
        }
        if activity.unknown {
            responseText.append("unknown ")
        }
        return responseText
    }
    
    //MockHandler
    static public func mockActivity(activity: String){
        if DetectActivityModule.MockActivities {
            let mockActivity = MockActivity(modeOfTransport: activity, Confidence: 2)
            
            

            UserInfo.newMockActivity(activity: mockActivity)
        }
    }
    
//    //MARK: Accelerometer Funcions
//    static func startAccelerometerDetection() {
//        if !MockActivities {
//            if motMan == nil {
//                startAD()
//            }
//            if let manager = motMan {
//                manager.update
//            }
//        }
//    }
}

class MockActivity {
    var modeOfTransport: String = ""
    var confidenceLevel: Int = 0
    var StartDate = Date()
    
    public init(modeOfTransport: String, Confidence: Int) {
        self.confidenceLevel=Confidence
        self.modeOfTransport=modeOfTransport
    }
}
