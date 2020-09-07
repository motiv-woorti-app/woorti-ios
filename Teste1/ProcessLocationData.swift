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
import CoreLocation
import Crashlytics

//This class defines how new locations are handled by the system
//It is composed of a state machine that reads new locations and infers if the user has benn idle or not
//this information is then use to determine the starting and ending points of either trips or full trips
public class ProcessLocationData {
    
    public static var newFullTrip = false
    public static var startFromUI = false
    static var tVControler: FullTripTableViewController?
    //Structures for the new locations
    public let newLocationSemaphore = DispatchSemaphore(value: 0)
    public let newLocationSemaphoreSizeLimit = DispatchSemaphore(value: 10) //limite de pending events antes de começar a processar processar
    public var newLocationsArray = [CLLocation]()
    public var stateMachineLock = NSLock()
    //Structures for the postponed locations
    private let postponedLocationSemaphore = DispatchSemaphore(value: 1)
    private var postponedLocationsArray = [CLLocation]()
    
    static var processingThread: Thread? = nil
    
    public var newLocationLock = NSLock()
//    public var lastAddedLocation: CLLocation?
    
    enum LocationStates: String {
        //stoped: when fulltrip and trip are over
        //trip: When trip and full trip is happening
        //Waiting: when fulltrip is happening but not trip
        case stoped, trip, waiting
    }
    
    //MARK: properties
    public static let tripIdleTime = Double(5*60) //Time idle before trip is over: seconds (specs: 5*60)
    public static let fulltripIdleTime = Double(25*60) //Time idle before full trip is over (Stacks with idle trip time): seconds (specs: 25*60)
//    public static let tripIdleTime = Double(15) //Test
//    public static let fulltripIdleTime = Double(30) //Test
    public static let idleDistance = Double(100) //maximum distance between locations recognized as idle: meters (specs: 100)
    public static let startTripAccuracyThreshold = Double(120)
    public static var stoppedTracking = false
    private var timer: Timer?
    
    //State of the machine state at the moment
    var state = LocationStates.stoped
    
    //this variable has the last location where the user may have stopped
    var locationStoped: CLLocation?
    
    //MARK: functions
    init() {
        startProcessingLocations()
    }
    
    public func forceStopTripOnCurrentLocation(fromUI: Bool = false){
        DispatchQueue.global(qos: .background).sync {
            self.stateMachineLock.lock()
            var location: CLLocation? = nil
            if newLocationsArray.count > 0 {
                location = self.newLocationsArray.removeFirst()
                self.newLocationsArray.removeAll()
            } else if self.locationStoped != nil {
                location = self.locationStoped!
            }
            if let loc = location {
                switch self.state {
                case .trip:
                    print("Ending trip")
                    UserInfo.endTrip(endLocation: loc)
                    UserInfo.endFullTrip(endLocation: loc, fromUI: fromUI)
                case .waiting:
                    print("Ending WE")
                    UserInfo.endFullTrip(endLocation: loc, fromUI: fromUI)
                default:
                    break
                }
            }
            self.locationStoped = nil
            self.state = .stoped
            self.stateMachineLock.unlock()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SideMenuTableViewController.TripStateChanged), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyTripsViewController.StartedOrFinishedTrip), object: nil)
        }
    }
    
    public func cleanLocationList() {
        self.newLocationLock.lock()
        self.newLocationsArray.removeAll()
        self.newLocationLock.unlock()
    }
    
    public func startProcessingLocations(){
        DispatchQueue.global(qos: .background).async {
            ProcessLocationData.processingThread = Thread.current
            while(true){
                print("START PROCESSING LOCATIONS")
                self.newLocationSemaphore.wait()
                self.newLocationLock.lock()
                if self.newLocationsArray.count > 0 {
                    var locations = [CLLocation]()
                    locations.append(contentsOf: self.newLocationsArray)
                    self.newLocationsArray.removeAll()
                    self.newLocationLock.unlock()
                    
                    self.stateMachineLock.lock()
                    for location in locations{
                        self.newLocationSemaphoreSizeLimit.signal()
                        self.newLocation(newLocation: location)
                        print("Processed NewLocation! lat: " + location.coordinate.latitude.description + " lon: " + location.coordinate.longitude.description + " accuracy: " + location.horizontalAccuracy.description)
                    }
                    self.stateMachineLock.unlock()
                    
                    UserInfo.appDelegate?.saveContext()
                } else {
                    self.newLocationLock.unlock()
                    self.stateMachineLock.unlock()
                }
            }
        }
    }
    
    func getLastLocation() -> CLLocation? {
        self.newLocationLock.lock()
        let location = self.newLocationsArray.last
        self.newLocationLock.unlock()
        return location
    }
    
    func addLocation(newLocation: CLLocation) {
        DispatchQueue.global(qos: .background).async {
            
            RawDataSegmentation.getInstance().newLocation(ua: UserLocation.getUserLocation(userLocation: newLocation, context: UserInfo.context!)!)
            
            NotificationEngine.getInstance().debugNotification(title: "new Coordinate", body: "location accuracy: \(newLocation.horizontalAccuracy) from: \(newLocation.timestamp) at: \(UtilityFunctions.getLocaleDate(date: Date())) lat: \(newLocation.coordinate.latitude) lon: \(newLocation.coordinate.longitude) coordinates to process: \(self.newLocationsArray.count)", notify: false)

            print("Get NewLocation!")
            
            if let pThread = ProcessLocationData.processingThread {
                NotificationEngine.getInstance().debugNotification(title: "ThreadState", body: "location thread: isCancelled: \(pThread.isCancelled) isFinished: \(pThread.isFinished) isExecuting: \(pThread.isExecuting) qualityOfService: \(pThread.qualityOfService.rawValue) isMainThread: \(pThread.isMainThread)", notify: false)
            }
            
            self.newLocationSemaphoreSizeLimit.wait()
            self.newLocationLock.lock()
            
            if !ProcessLocationData.stoppedTracking {
                self.newLocationsArray.append(newLocation)
                NotificationEngine.getInstance().debugNotification(title: "adding a location", body: "Location Array count: \(self.newLocationsArray.count)", notify: false)
                print("Location Array count: \(self.newLocationsArray.count)")
                self.newLocationLock.unlock()
                self.newLocationSemaphore.signal()
            } else {
                self.newLocationLock.unlock()
//                self.newLocationSemaphoreSizeLimit.wait()
            }
            print("Added Get NewLocation!")
            
        }
    }
    
    //used to know if firstLocation contains secondLocation
    func iscontained(firstLocation: CLLocation, secondLocation: CLLocation) -> Bool {
        return firstLocation.distance(from: secondLocation) + secondLocation.horizontalAccuracy < firstLocation.horizontalAccuracy
    }
    
    //used to process a new location (state machine transistion code)
    func newLocation(newLocation: CLLocation){
        print("processState: \(self.state.rawValue)")
        print("Start Processing Value location \(newLocation.debugDescription) at \(Date())")
        NotificationEngine.getInstance().debugNotification(title: "Start Processing Value", body: "location \(newLocation.debugDescription) at \(UtilityFunctions.getLocaleDate(date: Date()))", notify: false)

        Crashlytics.sharedInstance().setObjectValue(newLocation, forKey: "LastProcessedLocation")
        Crashlytics.sharedInstance().setObjectValue(self.locationStoped, forKey: "LastStoppedLocation")

        
        if self.locationStoped == nil {
            self.locationStoped = newLocation
            //doesn't return because of processing first on forced trip
        } else if self.iscontained(firstLocation: self.locationStoped!, secondLocation: newLocation) {
            self.locationStoped = newLocation
        }
        
        switch self.state {
        case .stoped:
            if isLocationHighAccuracy(location: newLocation) {
                self.insideFence(newLocation: newLocation) // for debuggin purposes only
                return
            }
            
            //Stopped state
            if (self.canStartTrip(location: newLocation) || ProcessLocationData.newFullTrip) { //Fora do idle range
                //update stoped location
                self.locationStoped=newLocation
                //start the full trip
                var locations = self.processPostponedLocations(lastLocation: newLocation)
                locations.append(newLocation)
                let first = locations.removeFirst()
                UserInfo.newFullTrip(startLocation: first, fromUI: ProcessLocationData.startFromUI)
                for locartion in locations {
                    UserInfo.newLocation(location: locartion)
                }
                ProcessLocationData.tVControler?.addTableViewCell()
                self.entersInTrip()
                PowerManagementModule.fullTripStarts()
                PowerManagementModule.TurnGpsOn()
                self.state = LocationStates.trip
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SideMenuTableViewController.TripStateChanged), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyTripsViewController.StartedOrFinishedTrip), object: nil)

                Crashlytics.sharedInstance().setObjectValue(self.state.rawValue, forKey: "state")

                ProcessLocationData.newFullTrip=false
                ProcessLocationData.startFromUI=false
                UserInfo.appDelegate?.saveContext()
                
                NotificationEngine.getInstance().debugNotification(title: "Trip Detection", body: "Changed to \(self.state) at \(UtilityFunctions.getLocaleDate(date: Date()))")
            } else {
                self.addPostponedLocation(loc: newLocation)
            }
            break
        case .trip:
            //trip state
            UserInfo.newLocation(location: newLocation)

            if !self.insideFence(newLocation: newLocation) { //Fora de idle range
                self.locationStoped=newLocation
                self.entersInTrip()
            } else if(self.timeGreaterThan(newLocation: newLocation, time: ProcessLocationData.tripIdleTime)){ //dentro de idle range a mais tempo do que o trip
                //finish trip
//                Thread.sleep(forTimeInterval: 1) // Test
                UserInfo.endTrip(endLocation: newLocation)
                self.entersInWE()
                //change state
                self.state=LocationStates.waiting
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SideMenuTableViewController.TripStateChanged), object: nil)
//                processPostponedLocations()
//                print("Trip -> WE")
                Crashlytics.sharedInstance().setObjectValue(self.state.rawValue, forKey: "state")
                UserInfo.appDelegate?.saveContext()
                NotificationEngine.getInstance().debugNotification(title: "Trip Detection", body: "Changed to \(self.state) at \(UtilityFunctions.getLocaleDate(date: Date()))")
            }
            break
        case .waiting:
            //waiting state
            UserInfo.newLocation(location: newLocation)
//            addPostponedLocation(loc: newLocation)
            if !self.insideFence(newLocation: newLocation){ //Fora de idle range
//                DetectMotionModule.startMotionManager()
//                processPostponedLocations()
                //update stoped location
                self.locationStoped=newLocation
                //start trip
                UserInfo.newTrip(startLocation: newLocation)
                self.entersInTrip()
                UserInfo.resetActivityList()
                self.state=LocationStates.trip
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SideMenuTableViewController.TripStateChanged), object: nil)
//                print("WE -> Trip")
                Crashlytics.sharedInstance().setObjectValue(self.state.rawValue, forKey: "state")
                UserInfo.appDelegate?.saveContext()
                let titleStartTripNotification = NSLocalizedString("Woorti_Just_Detected_Start_Trip", comment: "")
                NotificationEngine.getInstance().debugNotification(title: "", body: titleStartTripNotification)
            }else if self.timeGreaterThan(newLocation: newLocation, time: ProcessLocationData.fulltripIdleTime) { //Dentro de idle range a mais tempo do que o full trip idle time
//                processPostponedLocations()
                //finish full trip
                self.timer?.invalidate()
                UserInfo.endFullTrip(endLocation: newLocation)
//                Thread.sleep(forTimeInterval: 1) // Test
                PowerManagementModule.fullTripEnds()
                DetectMotionModule.stopMotionManager()
                UserInfo.resetActivityList()
                //change state
                self.state=LocationStates.stoped
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SideMenuTableViewController.TripStateChanged), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyTripsViewController.StartedOrFinishedTrip), object: nil)
                self.locationStoped = nil
//                print("WE -> Stoped")
                Crashlytics.sharedInstance().setObjectValue(self.state.rawValue, forKey: "state")
                UserInfo.appDelegate?.saveContext()
                NotificationEngine.getInstance().debugNotification(title: NSLocalizedString("Your_Trip_As_Ended", comment: ""), body: NSLocalizedString("You_Can_Now_Report_About_It_In_Woorti", comment: ""))
            }
            break
        }
        NotificationEngine.getInstance().debugNotification(title: "Stopped Processing Value", body: "location \(newLocation.debugDescription) at \(UtilityFunctions.getLocaleDate(date: Date()))", notify: false)
        print("Stopped Processing Value location \(newLocation.debugDescription) at \(UtilityFunctions.getLocaleDate(date: Date()))")
//        self.stateMachineLock.unlock()
        return
        //            self.semaphore.signal()
    }
    
    public func CloseEntireTrip(newLocation: CLLocation) {
        DispatchQueue.global(qos: .background).async {
            if  self.state != .stoped
                && (self.locationStoped?.timestamp.addingTimeInterval(60*30) ?? newLocation.timestamp) <= newLocation.timestamp {
                self.timer?.invalidate()
                
                self.changeToWaitingEvent()
                while(self.state != .waiting) {
                    Thread.sleep(forTimeInterval: 0.5)
                }
                self.ChangeToStopped()
            }
        }
    }
    
    public func entersInTrip(){
        DispatchQueue.main.async {
            self.timer?.invalidate()
            print("timer to end trip \(Date()) plus \(ProcessLocationData.tripIdleTime) ")
            self.timer=Timer.scheduledTimer(timeInterval: TimeInterval(ProcessLocationData.tripIdleTime), target: self, selector: #selector(self.changeToWaitingEvent), userInfo: nil, repeats: false)
        }
    }
    
    public func entersInWE(){
        DispatchQueue.main.async {
            self.timer?.invalidate()
            print("timer to end WE \(Date()) plus \(ProcessLocationData.fulltripIdleTime) ")
            self.timer=Timer.scheduledTimer(timeInterval: TimeInterval(ProcessLocationData.fulltripIdleTime), target: self, selector: #selector(self.ChangeToStopped), userInfo: nil, repeats: false)
        }
    }
    
    @objc public func changeToWaitingEvent() {
        DispatchQueue.global(qos: .background).async {
            self.stateMachineLock.lock()
            print("ProcessState: change to waiting event")
            
//            let averageOfLastInputPercentage = RawDataSegmentation.getInstance().inputs.last?.input.accelsBelowFilter ?? Double(0)
            
            if self.state==LocationStates.trip {
//                &&
//                (!DetectLocationModule.lastLocationIsUnknown ||
//                (DetectLocationModule.lastLocationIsUnknown && averageOfLastInputPercentage < 0.3)) {
            
                self.state=LocationStates.waiting
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SideMenuTableViewController.TripStateChanged), object: nil)
                UserInfo.endTrip(endLocation: self.locationStoped!)
                self.entersInWE()
                UserInfo.appDelegate?.saveContext()
//                DetectMotionModule.stopMotionManager()
                NotificationEngine.getInstance().debugNotification(title: "Trip Detection(On Timer)", body: "Changed to \(self.state) at \(UtilityFunctions.getLocaleDate(date: Date()))")
            }
            Crashlytics.sharedInstance().setObjectValue(self.state.rawValue, forKey: "state")
            self.stateMachineLock.unlock()
        }
    }
    
    @objc public func ChangeToStopped(){
        DispatchQueue.global(qos: .background).async {
            self.stateMachineLock.lock()
            print("ProcessState: change to stopped")
            if self.state==LocationStates.waiting {
                self.state=LocationStates.stoped
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SideMenuTableViewController.TripStateChanged), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyTripsViewController.StartedOrFinishedTrip), object: nil)

                UserInfo.endFullTrip(endLocation: self.locationStoped!)
                self.locationStoped=nil
                UserInfo.appDelegate?.saveContext()
                DetectMotionModule.stopMotionManager()
                PowerManagementModule.fullTripEnds()
                NotificationEngine.getInstance().debugNotification(title: "Trip Detection(On Timer)", body: "Changed to \(self.state) at \(UtilityFunctions.getLocaleDate(date: Date()))")
            }
            Crashlytics.sharedInstance().setObjectValue(self.state.rawValue, forKey: "state")
            self.stateMachineLock.unlock()
        }
    }
    
    public static func processSpeed(current: CLLocation, prev: CLLocation) -> (Double?,Double) {
        var fromGps: Double? = nil
        if current.speed > 0 {
            fromGps = current.speed
        }

        let distance = current.distance(from: prev) / 1000 //(KM)
        let time = current.timestamp.timeIntervalSince(prev.timestamp) / 3600 // (H)
        if time == 0 {
            return (fromGps,Double(0))
        }
        let speed = distance.divided(by: time)
        
        return (fromGps,speed)
    }
    
    public func startFullTrip(fromUI: Bool = false) {
        //change state
        self.stateMachineLock.lock()
        if state==LocationStates.stoped {
            //start the full trip
            if (locationStoped != nil) {
                UserInfo.newFullTrip(startLocation: locationStoped!, fromUI: fromUI)
                state = LocationStates.trip
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SideMenuTableViewController.TripStateChanged), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyTripsViewController.StartedOrFinishedTrip), object: nil)
                ProcessLocationData.tVControler?.addTableViewCell()
            } else if let current = DetectLocationModule.getCurrentLocation() {
                UserInfo.newFullTrip(startLocation: current, fromUI: fromUI)
                state = LocationStates.trip
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: SideMenuTableViewController.TripStateChanged), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyTripsViewController.StartedOrFinishedTrip), object: nil)
                ProcessLocationData.tVControler?.addTableViewCell()
            } else {
                ProcessLocationData.newFullTrip = true
                ProcessLocationData.startFromUI = fromUI
            }
//            DetectMotionModule.startMotionManager()
            PowerManagementModule.fullTripStarts()
        }
        self.stateMachineLock.unlock()
    }
    
    //verify if new location is inside the defined fence or not
    private func insideFence(newLocation: CLLocation) -> Bool{
        if locationStoped == nil {
            return true
        }
        NotificationEngine.getInstance().debugNotification(title: "Inside Fence Check", body: "location stopped accuracy: \(locationStoped!.horizontalAccuracy) from: \(locationStoped!.timestamp)\nnewLocation accuracy: \(newLocation.horizontalAccuracy) from: \(newLocation.timestamp)\nDistance: \(newLocation.distance(from: locationStoped!)) < idleDistance: \(ProcessLocationData.idleDistance)", notify: false)
        return newLocation.distance(from: locationStoped!) < ProcessLocationData.idleDistance
    }
    
    //verify if the threshhold time has passed
    private func timeGreaterThan(newLocation: CLLocation, time: Double) -> Bool {
        let interval = newLocation.timestamp.timeIntervalSince((locationStoped?.timestamp)!)
        return !interval.isLessThanOrEqualTo(time)
    }
    
    //retrieve if the user is not currently on a full trip
    public func isStopped() -> Bool {
        return state == LocationStates.stoped
    }
    
    public func isLocationHighAccuracy(location: CLLocation) -> Bool {
        return location.horizontalAccuracy > ProcessLocationData.startTripAccuracyThreshold
    }
    
    
    //suppose a maximum error of 200 meters per location
    public func canStartTrip(location: CLLocation) -> Bool {
        let threshold = Double(95)
        if let stopped = self.locationStoped {
            let distance = stopped.distance(from: location)
            
            let etotal = location.horizontalAccuracy + stopped.horizontalAccuracy
            let Dmax = distance + etotal
            let over = max(Dmax - threshold, 0)
            let pfavorable = over/(etotal.multiplied(by: 2))
            
            let Dmin = max(distance - etotal, 0)
            let missing = max(threshold - Dmin, 0)
            let pthMissing = missing/threshold
            
            NotificationEngine.getInstance().debugNotification(title: "canStartTrip", body: "threshold: \(threshold), distance: \(distance), etotal: \(etotal), Dmax: \(Dmax), over: \(over), pfavorable: \(pfavorable), Dmin: \(Dmin), missing: \(missing), pthMissing: \(pthMissing) ", notify: false)

            if distance > threshold {
                return true
            }
            return pthMissing < 0.3 && pfavorable > 0
        }
        
        return false
    }
    
    //Postponed Location functions
    public func addPostponedLocation(loc: CLLocation) {
        postponedLocationSemaphore.wait()
        postponedLocationsArray.append(loc)
        postponedLocationSemaphore.signal()
    }
    
    public func removeAllPostponedLocation() {
        postponedLocationSemaphore.wait()
        postponedLocationsArray.removeAll()
        postponedLocationSemaphore.signal()
    }
    
    public func getPostponedLocations() -> [CLLocation] {
        var locs = [CLLocation]()
        postponedLocationSemaphore.wait()
        locs.append(contentsOf: postponedLocationsArray)
        postponedLocationsArray.removeAll()
        postponedLocationSemaphore.signal()
        return locs
    }
    
    public func processPostponedLocations(lastLocation: CLLocation) -> [CLLocation] {
        var potponedLocations = getPostponedLocations()
        var locs = potponedLocations.filter { (location) -> Bool in
            return  location.distance(from: lastLocation) < 100
                    &&
                    location.timestamp.addingTimeInterval(TimeInterval(5 * 60)) > lastLocation.timestamp
        }
        
        if locs.count < 1 {
            if let last = potponedLocations.last,
                last.timestamp.addingTimeInterval(TimeInterval(5 * 60)) > lastLocation.timestamp {
                locs.append(last)
            }
        }
        
        locs.sort { (loc1, loc2) -> Bool in
            loc1.timestamp < loc2.timestamp
        }
        
        return locs
    }
}
