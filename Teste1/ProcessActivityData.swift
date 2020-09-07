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
import Crashlytics

class ProcessActivityData {
    
    private static var batchTime = TimeInterval(2*60) //(in seconds) should be 60s
    
    //MARK: Entry function
    //receives a full trip and parses the activities on each trip
    static func processFullTrip(fullTrip: FullTrip) {
        for part in fullTrip.getTripPartsortedList() {
            
            if !part.closed {
                processTrip(fullTrip: fullTrip, part: part)
            }
        }
    }
    
    //receives full trip and the part to be processed and processes the activities for the trip
    //it also adds and removes the mentioned trips as eneded
    static func processTrip(fullTrip: FullTrip, part: FullTripPart){
        guard let trip = part as? Trip else {
            return
        }
        
        let newTrips = ProcessActivityData.MLProcessTrip(trip: trip)
        fullTrip.removeFromTrips(trip)
        if newTrips.count == 0 {
            return
        }
        quickFix(trips: newTrips)
        
        
        for newTrip in newTrips {
            fullTrip.trips = NSMutableSet(set:fullTrip.trips.adding(newTrip))
        }
    }
    
    static func quickFix(trips: [Trip]) {
        for t in trips {
            if t.modeOfTransport == ActivityClassfier.WALKING && t.avSpeed.multiplied(by: 1000).divided(by: 3600) > Float(7) {
               t.modeOfTransport = ActivityClassfier.CYCLING
            }
        }
    }
    
    //MARK: List functions (used to get list of activities/locations for a certain time)
    static func getActivitiesList(sDate: Date, eDate: Date) -> [UserActivity] {
        var prevActivity: UserActivity?
        var tripActivityList = [UserActivity]()
        UserInfo.context?.performAndWait({
            for act in UserInfo.getActivityList() {
                if (prevActivity == nil){
                    prevActivity = act
                    continue
                }
                
                let startDate = prevActivity!.activity!.startDate
                guard let endDate = act.activity?.startDate else {
                    UserActivity.deleteActivity(ua: act)
                    continue
                }
                
                if ((startDate<=eDate && startDate>=sDate) || (endDate<=eDate && endDate>=sDate) || (startDate<=sDate && endDate>=eDate)){
                    tripActivityList.append(prevActivity!)
                }
                
                prevActivity = act
            }
            if let act = prevActivity?.activity {
                if act.startDate < eDate {
                    tripActivityList.append(prevActivity!)
                }
            }
        })
        return tripActivityList
    }
    
    static func getMockActivitiesList(sDate: Date, eDate: Date) -> [MockActivity] {
        var prevActivity: MockActivity?
        var tripActivityList = [MockActivity]()
        if UserInfo.mockActivities.count==0 {
            return tripActivityList
        }
        
        for act in UserInfo.mockActivities {
            if (prevActivity == nil){
                prevActivity = act
                continue
            }
            
            let startDate = prevActivity!.StartDate
            let endDate = act.StartDate
            
            if ((startDate<=eDate && startDate>=sDate) || (endDate<=eDate && endDate>=sDate) || (startDate<=sDate && endDate>=eDate)){
                tripActivityList.append(prevActivity!)
            }
            
            prevActivity = act
        }
        
        if (prevActivity?.StartDate)! < eDate {
            tripActivityList.append(prevActivity!)
        }
        
        return tripActivityList
    }
    
    static func getLocationsList(sDate: Date, eDate: Date, locations: [UserLocation]) -> [UserLocation] {
        var prevLocation: UserLocation?
        var tripLocationList = [UserLocation]()
        for loc in locations {
            if (prevLocation == nil){
                prevLocation = loc
                continue
            }
            
            let startDate = prevLocation!.location!.timestamp
            let endDate = (loc.location?.timestamp)!
            
            if ((startDate<=eDate && startDate>=sDate) || (endDate<=eDate && endDate>=sDate) || (startDate<=sDate && endDate>=eDate)){
                tripLocationList.append(prevLocation!)
            }
            prevLocation = loc
        }
        if (prevLocation?.location?.timestamp)! < eDate {
            tripLocationList.append(prevLocation!)
        }
        return tripLocationList
    }
    
    //MARK: internal functions used to classify
    //Receives: all the activities made on a trip and the end date fo the timescale used
    //Returns: an activity classifier object that classified the activities sent.
    static func simpleFetchActivityFromActivities(activities: [UserActivity], startDate: Date, endDate: Date) -> ActivityClassfier {
        let actClass = ActivityClassfier(startDate: startDate, endDate: endDate)
        var prevAct: UserActivity?
        let sortedActivities = activities.sorted { (ua1, ua2) -> Bool in
            return ua1.compare(ua: ua2)
        }
        
        for act in sortedActivities {
            if prevAct != nil {
                actClass.feedActivitySample(activity: (prevAct!.activity)! ,activityEndDate: (act.activity?.startDate)!)
            }
            prevAct = act
        }
        if prevAct != nil {
            actClass.feedActivitySample(activity: (prevAct?.activity)! ,activityEndDate: endDate)
        }
        return actClass
    }
    
    // process trip mode and spliting by ML
    static func MLProcessTrip(trip: Trip) -> [Trip] {
        if trip.getLocationsortedList().count < 1 {
            Crashlytics.sharedInstance().setObjectValue(trip.getLocationsortedList().count, forKey: "TripEvaluationlocationsCount")
            Crashlytics.sharedInstance().recordCustomExceptionName("Error Processing MLProcessTrip", reason: "locations size: \(trip.getLocationsortedList().count)", frameArray: [CLSStackFrame]())
            return [Trip]()
        }
        
        let endDate = trip.endDate ?? trip.getLocationsortedList().last?.location?.timestamp ?? Date()
        trip.endDate = endDate
        let inputs = RawDataSegmentation.getInstance().inputsBelongingToLeg(legStartDate: trip.startDate, legEndDate: endDate)
        
        
        if inputs.count == 0 {
            Crashlytics.sharedInstance().setObjectValue(inputs.count, forKey: "TripEvaluationInputsCount")
            Crashlytics.sharedInstance().recordCustomExceptionName("Error Processing MLProcessTrip", reason: "inputs size: \(inputs.count)", frameArray: [CLSStackFrame]())
            return [Trip]()
        }
        
        let segments = RawDataDetection.getInstance().TripEvaluation(inputs: inputs)
//        RawDataSegmentation.getInstance().removeUntilInput(input: inputs.last!)
        
        let modes = segments.map { (segment) -> String in
            switch Int(segment.mode) {
            case Trip.modesOfTransport.walking.rawValue :
                return ActivityClassfier.WALKING
            case Trip.modesOfTransport.running.rawValue:
                return ActivityClassfier.RUNNING
            case Trip.modesOfTransport.automotive.rawValue:
                return ActivityClassfier.AUTOMOTIVE
            case Trip.modesOfTransport.Car.rawValue:
                return ActivityClassfier.CAR
            case Trip.modesOfTransport.cycling.rawValue:
                return ActivityClassfier.CYCLING
            case Trip.modesOfTransport.stationary.rawValue:
                return ActivityClassfier.STATIONARY
            case Trip.modesOfTransport.Bus.rawValue:
                return ActivityClassfier.BUS
            case Trip.modesOfTransport.Train.rawValue:
                return ActivityClassfier.TRAIN
            case Trip.modesOfTransport.Subway.rawValue:
                return ActivityClassfier.METRO
            case Trip.modesOfTransport.Tram.rawValue:
                return ActivityClassfier.TRAM
            case Trip.modesOfTransport.Ferry.rawValue:
                return ActivityClassfier.FERRY
            case Trip.modesOfTransport.Plane.rawValue:
                return ActivityClassfier.PLANE
            default:
                Crashlytics.sharedInstance().recordCustomExceptionName("Error Processing MLProcessTrip", reason: "invalid segment mode: \(Int(segment.mode))", frameArray: [CLSStackFrame]())
                return ActivityClassfier.WALKING
            }
        }
        
        var dates = segments.map { (segment) -> Date in
            Date(timeIntervalSince1970: inputs[segment.firstIndex].startDate.timeIntervalSince1970)
        }
        dates.removeFirst()
        dates.append(trip.endDate!)
//        dates.removeFirst
        
        return getTripsFromModeAndDates(trip: trip, modes: modes, endDates: dates)
    }
    
    static func simpleProcessTrip(trip: Trip) -> [Trip] {
        var trips = [Trip]()
        
        if DetectActivityModule.MockActivities{
            let activities = getMockActivitiesList(sDate: trip.startDate, eDate: trip.endDate!)
            if activities.count==0{
                trip.modeOfTransport="unknown"
                trips.append(trip)
                return trips
            }
            
            var endDates = [Date]()
            var modes = [String]()
            var prevAct: MockActivity?
            
            for act in activities {
                if prevAct != nil {
                    endDates.append(act.StartDate)
                    modes.append((prevAct?.modeOfTransport)!)
                }
                prevAct=act
            }
            endDates.append(trip.endDate!)
            modes.append((prevAct?.modeOfTransport)!)
            
            trips.append(contentsOf: ProcessActivityData.getTripsFromModeAndDates(trip: trip, modes: modes, endDates: endDates))
            
        } else {
            if trip.endDate == nil {
                trip.endDate=trip.getEndDate()
            }
            
            if trip.startDate < trip.endDate! {
                
                var startDate = trip.startDate
                var batchEndDate = Date()
                var classifiers = [ActivityClassfier]()
                while true {
                    batchEndDate = startDate.addingTimeInterval(ProcessActivityData.batchTime)
                    
                    if batchEndDate >= trip.endDate! {
                        batchEndDate=trip.endDate!
                    }
                    
                    let activities = ProcessActivityData.getActivitiesList(sDate: startDate, eDate: batchEndDate)
                    classifiers.append(ProcessActivityData.simpleFetchActivityFromActivities(activities: activities, startDate: startDate, endDate: trip.endDate!))
                    
                    if batchEndDate >= trip.endDate! {
                        break
                    }
                    
                    startDate=batchEndDate
                }
                
                trips.append(contentsOf: ProcessActivityData.getTripsFromClassifiers(trip: trip, classifiers: classifiers))
            }
        }
        return trips
    }
    
    private static func getTripsFromClassifiers(trip: Trip, classifiers: [ActivityClassfier]) -> [Trip] {
        var prevClassifier: ActivityClassfier?
        
        var endDates = [Date]()
        var modes = [String]()
        
        for classifier in classifiers {
            if prevClassifier != nil {
                if classifier.getClassifierResult() != prevClassifier?.getClassifierResult() {
                    //                    var tripEndDate=prevClassifier?.getActivity(activity: classifier.getClassifierResult())?.startDate
                    //                    if tripEndDate == nil {
                    let tripEndDate = classifier.getActivity(activity: classifier.getClassifierResult())?.startDate
                    //                    }
                    
                    endDates.append(tripEndDate!)
                    modes.append((prevClassifier?.getClassifierResult())!)
                }
            }
            prevClassifier=classifier
        }
        endDates.append(trip.endDate!)
        modes.append((prevClassifier?.getClassifierResult())!)
        
        print("ModesStart: \(modes)")
        print("endDatesStart: \(endDates)")
        (modes,endDates) = ProcessActivityData.processModesAndDates(modes: modes, endDates: endDates)
        print("ModesEnd: \(modes)")
        print("endDatesEnd: \(endDates)")
        
        return getTripsFromModeAndDates(trip: trip, modes: modes, endDates: endDates)
    }
    
    static func getTripsFromModeAndDates(trip: Trip, modes: [String], endDates: [Date]) -> [Trip] {
        var trips = [Trip]()
        var startDate = trip.startDate
        let tripSortedList = trip.getLocationsortedList()
        for (mode, eDate) in zip(modes, endDates) {
            let newTrip = Trip.getTrip(startDate: startDate, context: UserInfo.context!)!
            let locations = ProcessActivityData.getLocationsList(sDate: startDate, eDate: eDate, locations: tripSortedList)
            newTrip.modeOfTransport = mode
            

            newTrip.newLocations(locs: locations)
            
            //Re-add last with another nsmanaged oject.
            //If only one then the object can only be on one leg, this makes the map not close the lines when drawing
            if locations.count > 0{
                let loc = locations.last!
                newTrip.newLocation(location: loc.location!, context: UserInfo.context!)
            }
            newTrip.processCloseInformation()
            trips.append(newTrip)
            
            startDate = eDate
        }
        
        return trips
    }
    
    static func processModesAndDates(modes: [String], endDates: [Date] ) -> ([String],[Date]){
        var returnModes = modes, returnEndDates = endDates
        
        //Test if ends in stationary mode and removes
        if returnModes.last == ActivityClassfier.STATIONARY && returnModes.count > 1 {
            returnModes.removeLast()
            returnEndDates.remove(at: returnEndDates.index(of: returnEndDates.last!)! - 1) //remove last - 1 date so that the last mode will finish expand to the end of the trip
        }
        var listRemoveIndex = [Int]()
        
        //Test if there is stationary between two automotive
        var index = 0
        for mode in returnModes {
            if mode == ActivityClassfier.STATIONARY {
//                if let index = returnModes.index(of: mode) {
                    if index > 0 && index < returnModes.endIndex {
//                        if returnModes[index-1] == ActivityClassfier.AUTOMOTIVE && returnModes[index+1] == ActivityClassfier.AUTOMOTIVE {
                        if returnModes[index-1] == returnModes[index+1] {
                            if !listRemoveIndex.contains(index - 1) {
                                listRemoveIndex.append(index - 1)
                            }
                            if !listRemoveIndex.contains(index){
                                listRemoveIndex.append(index)
                            }
//                            listRemoveIndex.append(index)
//                            returnModes.remove(at: index)
//                            returnModes.remove(at: index - 1)
//                            returnEndDates.remove(at: index)
//                            returnEndDates.remove(at: index - 1)
                        } else if returnModes[index-1] == ActivityClassfier.AUTOMOTIVE {
                            if !listRemoveIndex.contains(index - 1) {
                                listRemoveIndex.append(index - 1)
                            }
                        } else if returnModes[index+1] == ActivityClassfier.AUTOMOTIVE {
                            if !listRemoveIndex.contains(index){
                                listRemoveIndex.append(index)
                            }
                        }
                    } else if index == 0 && returnModes.count > 1 {
                        if !listRemoveIndex.contains(index){
                            listRemoveIndex.append(index)
                        }
//                        returnModes.removeFirst()
//                        returnEndDates.removeFirst()
                    }
//                }
            } else if mode == ActivityClassfier.AUTOMOTIVE {
//                print("Automotive")
            }
            index += 1
        }
        
        //remove the modes on the following indexes
        for ind in listRemoveIndex.reversed() {
            returnEndDates.remove(at: ind)
            returnModes.remove(at: ind)
        }
        
        return (returnModes,returnEndDates)
    }
}

//MARK: Acivity classifier
class ActivityClassfier {
    var stationary = Double(0)
    var walking = Double(0)
    var running = Double(0)
    var automotive = Double(0)
    var cycling = Double(0)
    var unknown = Double(0)
    
    let startDate: Date
    let endDate: Date
    var activities = [CMMotionActivity]()
    
    //string Definitions
    static public let STATIONARY="stationary"
    static public let UNKNOWN="unknown"
    static public let WALKING="walking"
    static public let RUNNING="running"
    static public let AUTOMOTIVE="automotive"
    static public let BUS="bus"
    static public let TRAIN="train"
    static public let CAR="car"
    static public let METRO="subway"
    static public let TRAM="tram"
    static public let CYCLING="cycling"
    static public let FERRY="ferry"
    static public let PLANE="plane"
    
    init(startDate: Date, endDate: Date){
        self.startDate=startDate
        self.endDate=endDate
    }
    
    func feedActivitySample(activity: CMMotionActivity,activityEndDate: Date){
        self.activities.append(activity)
        let importance = calculateActivityImportance(activity: activity, activityEndDate: activityEndDate)
        
        if activity.stationary {
            self.stationary += importance
        } else if activity.walking {
            self.walking += importance
        } else if activity.running {
            self.running += importance
        } else if activity.automotive {
            self.automotive += importance
        } else if activity.cycling {
            self.cycling += importance
        } else {
            self.unknown += importance
        }
    }
    
    func calculateActivityImportance(activity: CMMotionActivity, activityEndDate: Date) -> Double {
        var classification: Double
        
        let duration = activityEndDate.timeIntervalSince(activity.startDate)
        let confidenceLevel = Double(activity.confidence.rawValue+1)
        classification =  confidenceLevel.multiplied(by: duration)
        
        return classification
    }
    
    func getClassifierResult() -> String {
        var max = Double.maximum(self.stationary, self.walking)
        max = Double.maximum(self.running, max)
        max = Double.maximum(self.automotive, max)
        max = Double.maximum(self.cycling, max)
        max = Double.maximum(self.unknown, max)
        if max == Double(0){
            return ActivityClassfier.UNKNOWN
        }
        if max==self.stationary {
            return ActivityClassfier.STATIONARY
        }
        if max==self.walking {
            return ActivityClassfier.WALKING
        }
        if max==self.running {
            return ActivityClassfier.RUNNING
        }
        if max==self.automotive {
            return ActivityClassfier.AUTOMOTIVE
        }
        if max==self.cycling {
            return ActivityClassfier.CYCLING
        }
        if max==self.unknown {
            return ActivityClassfier.UNKNOWN
        }
        return ActivityClassfier.UNKNOWN
    }
    
    func getActivity(activity: String) -> CMMotionActivity? {
        for act in self.activities {
            if act.stationary && activity == ActivityClassfier.STATIONARY {
                return act
            } else if act.walking && activity == ActivityClassfier.WALKING {
                return act
            } else if act.running && activity == ActivityClassfier.RUNNING {
                return act
            } else if act.automotive && activity == ActivityClassfier.AUTOMOTIVE {
                return act
            } else if act.cycling && activity == ActivityClassfier.CYCLING {
                return act
            } else if act.unknown && activity == ActivityClassfier.UNKNOWN {
                return act
            }
        }
        
        return nil
    }
}



