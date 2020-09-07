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
import UIKit
import Firebase
import FirebaseAuth

/**
 Class with the definition of each Trip, it has the following parameters:
 - Rest Request variables (used to send closed Trip to MoTiV Server):
 - endpoint: MoTiV server endpoint
 - responseClass: class representing the Json Response from server
 - url: server Url
 
 - Managed (Saved on core data):
 - startDate: Date when Trip started
 - endDate: Date when Trip ended, nil if trip is still in progress
 - distance: Distance of the Trip in meters, only available if closed
 - duration: Duration of the Trip in seconds, only available if closed
 - avSpeed: Average speed of the Trip in Km/h, only available if closed
 - avSpeed: Average speed of the Trip in Km/h, only available if closed
 - closed: Trip is closed, Thi also indicates if the previous values have been processed
 - trips: Complete Set of Legs and Waiting Events of this Trip
 
 - Sincronization:
 - tripsSem: Default value of 1, used to sincronize access to trips set
 
 - Core data Unmanaged Properties:
 - entityName: The name of the Class used to identify the Core data object on the model. (Do not change)
 
 - Attention: trips has to be a set beacuse of Core Data specification, if any type of the managed  is to change it also has to be changed on the data model and the previous state may not be recuperable
 */
class FullTrip: NSManagedObject, JsonRequest {
    
    //MARK: Rest Request properties
    var endpoint: String = "/api/trips"
    var responseClass: JsonResponse = FullTripResponse()
    var url: String {get {return "https://app.motiv.gsd.inesc-id.pt:8000"}}
    
    //MARK: Managed properties
    @NSManaged public var startDate: Date?      //Trip Start DAte
    @NSManaged public var endDate: Date?        //Trip end DAte
    @NSManaged public var distance: Float       //in meters
    @NSManaged public var duration: Float       //in seconds
    @NSManaged public var avSpeed: Float        //in Km/h
    @NSManaged public var mSpeed: Float         //in Km/h
    @NSManaged public var closed: Bool          //Trip is closed
    @NSManaged public var trips: NSMutableSet   //FullTripPart
    @NSManaged public var sentToServer: Bool    //FullTripPart
    @NSManaged public var confirmed: Bool       //FullTripPart
    @NSManaged public var uid: String?          //FullTripPart
    @NSManaged public var objective: [String]?
    @NSManaged public var overallScore: Double
    @NSManaged public var didYouHaveToArrive: Double
    @NSManaged public var howOften: Double
    @NSManaged public var usetripMoreFor: Double
    @NSManaged public var shareInformation: String
    
    @NSManaged public var startLocation: String?
    @NSManaged public var endLocation: String?
    
    @NSManaged public var score: TripScored?
    @NSManaged public var manualTripStart: Bool
    @NSManaged public var manualTripEnd: Bool
    
    @NSManaged public var numSplits: Double
    @NSManaged public var numMerges: Double
    @NSManaged public var numDeletes: Double
    
    @NSManaged public var validationDate: Date?
    
    
    
    let startLocationTextSem = DispatchSemaphore(value: 0)
    let endLocationTextSem = DispatchSemaphore(value: 0)
    
    
    func getStartLocation() -> String {
        if startLocation != nil && startLocation != "" {
            return startLocation!
        } else if let firstLocation = self.getFirstLocation() {
            CLGeocoder().reverseGeocodeLocation(firstLocation) { (plc, e) in
                if let error = e as? Error {
                    self.startLocationTextSem.signal()
                    return
                } else if let placemarks = plc as? [CLPlacemark] {
                    if placemarks.count > 0 {
                        self.startLocation = "\(placemarks.first!.thoroughfare ?? "") \(placemarks.first!.subThoroughfare ?? "")"
                    }
                }
                self.startLocationTextSem.signal()
            }
            self.startLocationTextSem.wait(timeout: DispatchTime(uptimeNanoseconds: 1000*1000*10)) //Waits 100 ms
            return self.startLocation ?? "Unknown Address"
        } else {
            return "Unknown Address"
        }
    }
    
    func getEndLocation() -> String {
        if endLocation != nil && endLocation != ""{
            return endLocation!
        } else if let lastLocation = self.getLastLocation() {
            CLGeocoder().reverseGeocodeLocation(lastLocation) { (plc, e) in
                if let error = e as? Error {
                    self.endLocationTextSem.signal()
                    return
                } else if let placemarks = plc as? [CLPlacemark] {
                    if placemarks.count > 0 {
                        self.endLocation = "\(placemarks.first!.thoroughfare ?? "") \(placemarks.first!.subThoroughfare ?? "")"
                    }
                }
                self.endLocationTextSem.signal()
            }
            self.endLocationTextSem.wait(timeout: DispatchTime(uptimeNanoseconds: 1000*1000*10)) //Waits 100 ms
            return self.endLocation ?? "Unknown Address"
        } else {
            return "Unknown Address"
        }
    }
    
    enum didYouHaveToArriveEnum: Int {
        case No = 0, Yes, NotSure
    }
    
    enum howOftenEnum: Int {
        case Regular = 0, Ocasional, firstTime, NotSure
    }
    
    enum usetripMoreForEnum: Int {
        case Productive = 0, Enjoyment, Fitness, None
    }
    
    private var tripsSem = DispatchSemaphore(value: 1)
    private let sendToServerSem = DispatchSemaphore(value: 0) //sincronize sending one at a time
    private let sendToServerLock = NSLock()
    
    //MARK: Core data properties
    static public let entityName = "FullTrip"
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FullTrip> {
        return NSFetchRequest<FullTrip>(entityName: "FullTrip")
    }
    
    
    //MARK: functions INIT
    /**
     Function to initialize a Trip whith a given startLocation
     - parameters:
     - startLocation: The first location for this Trip
     - context: The NSManagedContext where we are going to add this object
     */
    convenience init(startLocation: CLLocation, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: FullTrip.entityName, in: context)!
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        self.newLeg(startLocation: startLocation, context: context)
        self.closed=false
        if let user = Auth.auth().currentUser {
            self.uid = user.uid
        }
        self.confirmed=false
        self.sentToServer=false
    }
    
    public static func getFullTrip(startLocation: CLLocation, context: NSManagedObjectContext) -> FullTrip? {
        var fullTrip: FullTrip?
        UserInfo.ContextSemaphore.wait()
        context.performAndWait {
            fullTrip = FullTrip(startLocation: startLocation, context: context)
        }
        return fullTrip
    }
    
    /*
    * Delete legs without valid locations
    */
    public func deleteEmptyLegs(){
        for leg in getTripOrderedList() {
            if leg.getLocationListCount() < 1 {
                tripsSem.wait()
                removeFromTrips(leg)
                tripsSem.signal()
            }
        }
    }
    
    //MARK: trip filling functions
    /**
     Opens a new LEG on the latest trip available if there is a open Waiting Event on the Trip it will be closed.
     - parameters:
     - startLocation: The first location for this Leg
     - context: The NSManagedContext where we are going to add this object
     */
    public func newLeg(startLocation: CLLocation, context: NSManagedObjectContext, fromStateMachine: Bool = false) {
        //start trip
        let closedWE: FullTripPart?  = getTripPartsortedList().last
        if closedWE != nil {
            if let locationList = closedWE?.getLocationsortedList(), locationList.count > 1 {
                let lastLocation = locationList.last!.location
                let prevLocation = locationList[locationList.count - 2].location

                if lastLocation!.distance(from: prevLocation!) > 150 { // in meters
                    let tripParts = self.getTripPartsortedList()
                    if let leg = self.getTripOrderedList().last, tripParts.index(of: leg) == tripParts.count - 2  {
                        self.JoinLastTwoAfterNoLocations()
                        leg.closed = false
                        return
                    }
                }
            }
        }
//        //TestCode for metro
        if !splitFiveMinutesForNext(onLocation: startLocation, context: context) {
            let trip = Trip.getTrip(startDate: startLocation.timestamp,context: context)!
            tripsSem.wait()
            trips = NSMutableSet(set: trips.adding(trip))
            //addToTrips(trip)
            tripsSem.signal()
        }
        //add new location
        newLocation(location: startLocation, context: context)
        //Close waiting envet
        closedWE?.endTripPart(endLocation: startLocation)
    }
    
    /**
     Closes and processes the current LEG on the latest trip available and opens a Waiting event after it.
     - parameters:
     - startLocation: The first location for this Waiting Event
     - context: The NSManagedContext where we are going to add this object
     */
    public func endLeg(endLocation: CLLocation, context: NSManagedObjectContext){
        //close trip
        let closedLeg: FullTripPart? = getTripPartsortedList().last
        newLocation(location: endLocation, context: context)
        //start waiting event
        if !splitFiveMinutesForNext(onLocation: endLocation, context: context) {
            tripsSem.wait()
            if let we = WaitingEvent.getWaitingEvent(startDate: endLocation.timestamp, context: context) {
                trips = NSMutableSet(set: trips.adding(we))
            } else {
                Crashlytics.sharedInstance().recordCustomExceptionName("Waiting Event: not initialized", reason: "This waiting event was not initialized on endLeg", frameArray: [CLSStackFrame]())
            }
            tripsSem.signal()
        }
        //Close the trip
        closedLeg?.endTripPart(endLocation: endLocation)
        if closedLeg != nil {
            ProcessActivityData.processTrip(fullTrip: self, part: closedLeg!)
        }
    }
    
    /**
     add new location to the the latest Trip. It will add the location on the last leg/Waiting event of the most recent Trip
     - parameters:
     - location: the new location to add to the Trip and its parts(Leg/Waiting Event)
     - context: The NSManagedContext where we are going to add this object
     */
    public func newLocation(location: CLLocation, context: NSManagedObjectContext){
        getTripPartsortedList().last?.newLocation(location: location, context: context)
    }
    
    /**
     This function closes the Trip and processes its information.
     Also removes the last Waiting Event on this Trip
     - parameters:
     - endLocation: The last location for This Trip
     */
    public func close(endLocation: CLLocation) -> Bool {
        getTripPartsortedList().last?.endTripPart(endLocation: endLocation)
        splitFiveMinutesForLastLeg()
        //test cleanup
        cleanTrip()
        if self.getTripOrderedList().count < 1 {
            self.delete()
            return false
        }
        processFullTrip()
        closed = true
        
        return true
    }
    
    //MARK: print a Trip Functions
    public func printInfo() -> String {
        var responseText: String = ""
        responseText.append("\n ----------- \n")
        tripsSem.wait()
        let printTrips = trips.copy() as! NSMutableSet
        tripsSem.signal()
        for trip in printTrips {
            responseText.append((trip as! FullTripPart).printInfo())
        }
        return responseText
    }
    
    //Print Short description to a Label
    public func printOnCell() -> String{
        var responseText: String = ""
        if closed {
            if let sd = startDate {
                responseText.append("StartDate: " + sd.description)
            } else {
                responseText.append("Ongoing Processing of trip. Please Refresh")
            }
        } else {
            if let sd = getTripPartsortedList().first?.startDate {
                responseText.append("StartDate: " + sd.description)
            } else {
                responseText.append("Ongoing Processing of trip. Please Refresh")
            }
        }
        return responseText
    }
    
    public func printFinalData() -> String {
        var responseText: String = ""
        responseText.append("Trip \n")
        if closed {
            responseText.append("Start Date: " + (startDate?.description(with: Locale.autoupdatingCurrent) ?? "No start Date") + "\n")
            responseText.append("End Date: " + (endDate?.description(with: Locale.autoupdatingCurrent) ?? "No End Date") + "\n")
            responseText.append("Distance traveled: " + distance.description + "m\n")
            responseText.append("time traveled: \(UserInfo.printHoursMinutesSeconds(seconds: Int(duration)))\n")
            responseText.append("average speed: " + avSpeed.description + "km/H\n")
            responseText.append("Maximum speed: " + mSpeed.description + "km/H\n")
        } else {
            responseText.append("StartDate: " + (getTripPartsortedList().first?.startDate.description(with: Locale.autoupdatingCurrent) ?? "No start Date") + "\n")
            responseText.append("Full trip not finished yet\n")
        }
        for trip in getTripPartsortedList(){
            if let rTrip = trip as? Trip {
                responseText.append(rTrip.printFinalData())
            }
            if let weTrip = trip as? WaitingEvent {
                responseText.append(weTrip.printFinalData())
            }
        }
        
        return responseText
    }
    
    //MARK:sort functions for nssets
    /**
     Sorts and returns the trips set in a new array.
     Sorts Legs and Waiting Events by starDate
     
     - Returns: sorted array of the Legs and Waiting Events
     */
    public func getTripPartsortedList() -> [FullTripPart]{
        tripsSem.wait()
        var arrayTripParts: [FullTripPart] = trips.allObjects as! [FullTripPart]
        tripsSem.signal()
        arrayTripParts.sort(by: { (tp1, tp2) -> Bool in
            //order by startdate or, if they are the same, order by the one that has endDate filled first
            if tp1.startDate < tp2.startDate {
                return true
            } else if tp1.startDate == tp2.startDate {
                return (tp1.endDate ?? Date()) < (tp2.endDate ?? Date())
            }
            return false
        })
        return arrayTripParts
    }
    
    // MARK: Generated accessors for trips
    
    @objc(addTripsObject:)
    @NSManaged public func addToTrips(_ value: FullTripPart)
    
    @objc(removeTripsObject:)
    @NSManaged public func removeFromTrips(_ value: FullTripPart)
    
    @objc(addTrips:)
    @NSManaged public func addToTrips(_ values: NSSet)
    
    @objc(removeTrips:)
    @NSManaged public func removeFromTrips(_ values: NSSet)
    
    //MARK: Processing Functions
    /**
     Fucntion used to remove the last Waiting event of a Trip when processing the Trip
     */
    public func removeLastWaitingEvent() {
        guard let we = getTripPartsortedList().last as? WaitingEvent else {
            return
        }
        tripsSem.wait()
        removeFromTrips(we)
        tripsSem.signal()
    }
    
    public func removeFirstWaitingEvent() {
        guard let we = getTripPartsortedList().first as? WaitingEvent else {
            return
        }
        tripsSem.wait()
        removeFromTrips(we)
        tripsSem.signal()
    }
    
    fileprivate func ProcessSpeedFromTrips() {
        distance = 0
        duration = 0
        mSpeed = 0
        avSpeed = 0
        
        for part in getTripPartsortedList() {
            if let trip = part as? Trip {
                duration.add(trip.duration)
                distance.add(trip.distance)
                if mSpeed.isZero || mSpeed < trip.mSpeed {
                    mSpeed=trip.mSpeed
                }
                avSpeed.add(trip.avSpeed * trip.duration)
            }
        }
        avSpeed.divide(by: duration)
    }
    
    fileprivate func ProcessSpeed(_ withLocations: Bool = false) {
        var locationsCount = Float(0)
        mSpeed = 0
        avSpeed = 0
        
        for trip in getTripPartsortedList() {
            if trip.isTrip() {
                distance.add((trip as! Trip).distance)
            }
            var prevLocation: UserLocation?
            let locations = trip.getLocationsortedList()
            for loc in locations{
                if prevLocation != nil {
                    //IF above a certain threshold then we should not compare the speed
                    if (loc.location?.horizontalAccuracy)! > Trip.SpeedMAxAccuracyThreshold ||
                        (prevLocation!.location?.horizontalAccuracy)! > Trip.SpeedMAxAccuracyThreshold {
                        continue
                    }else if((prevLocation?.location?.distance(from: loc.location!)) ?? Trip.minLocationDistance < Trip.minLocationDistance && loc != locations.last){
                        continue
                    }
                    
                    let (gpsSpeed, speed) = ProcessLocationData.processSpeed(current: loc.location!, prev: (prevLocation?.location)!)
                    if gpsSpeed != nil {
                        if gpsSpeed! < Double(1200) {
                            avSpeed.add(Float(gpsSpeed!))
                            locationsCount.add(1)
                            if Float(gpsSpeed!) > mSpeed {
                                mSpeed=Float(gpsSpeed!)
                            }
                        }
                    } else if withLocations && !speed.isZero && speed < Double(1200) {
                        avSpeed.add(Float(speed))
                        locationsCount.add(1)
                        if Float(speed) > mSpeed {
                            mSpeed=Float(speed)
                        }
                    }
                    
                }
                prevLocation=loc
            }
        }
        if locationsCount > 0 {
            avSpeed.divide(by: locationsCount)
        } else if withLocations {
            ProcessSpeed(true)
        }
    }
    
    /**
     Function that processes the entire Trip
     */
    public func processFullTrip(){
        if getTripPartsortedList().count > 0 {
            startDate = getTripPartsortedList().first?.startDate
            endDate = getTripPartsortedList().last?.endDate ?? getTripPartsortedList().last?.getLocationsortedList().last?.location?.timestamp ?? Date()
            duration = Float((endDate?.timeIntervalSince(startDate!))!)
            distance = 0
            ProcessSpeedFromTrips()
            closed = true
            
            // remove
            if startDate != nil && endDate != nil {
                RawDataSegmentation.getInstance().removeInputsFromDates(startDate: startDate!, endDate: endDate!)
            }
        }
    }
    
    public func setRealMots() {
        for trip in getTripOrderedList() {
            trip.setRealMots()
        }
    }
    
    /**
     Function to close and process all Trips that where open at the start of the APP
     */
    public func CloseFt() -> Bool{
        if !closed {
            let lastLocation = getLastLocation()
            if lastLocation != nil {
                if !close(endLocation: lastLocation!) {
                    return false
                }
            }
            ProcessActivityData.processFullTrip(fullTrip: self)
            processFullTrip()
            return true
        }
        return false
    }
    
    
    /**
     Retrieves the last location for this Trip
     - returns: The last location of the last Leg/Waiting Event if there are any Legs/Waiting Events
     */
    public func getLastLocation() -> CLLocation? {
        tripsSem.wait()
        let tripCount = trips.count
        tripsSem.signal()
        if tripCount > 0 {
            let lastTrip = getTripPartsortedList().last
            if lastTrip != nil {
                let lastLocation = lastTrip?.getLocationsortedList().last
                if lastLocation != nil {
                    return lastLocation?.location
                }
                
            }
            
            
            
            
        }
        return nil
    }
    
    /**
     Retrieves the first location for this Trip
     - returns: The first location of the first Leg/Waiting Event if there are any Legs/Waiting Events
     */
    public func getFirstLocation() -> CLLocation? {
        tripsSem.wait()
        let tripCount = trips.count
        tripsSem.signal()
        if tripCount > 0 {
            let lastTrip = getTripPartsortedList().first
            if lastTrip != nil {
                let lastLocation = lastTrip?.getLocationsortedList().first
                if lastLocation != nil {
                    return lastLocation?.location
                }
            }
        }
        return nil
    }
    /**
     Used for testing
     - returns: True if the Trip has at least one coordinate(Location)
     */
    public func hasCoords() -> Bool {
        for part in getTripPartsortedList(){
            if part.locations.count > 0{
                return true
            }
        }
        return false
    }
    
    //MARK: ParseableFunctions
    /**
     Parseable Enum, one for each variable we want to appear in Json format.
     The name here is the one that appear on the Json when it is constructed
     */
    enum CodingKeys: String, CodingKey {
        case startDate
        case endDate
        case distance
        case duration
        case avSpeed
        case mSpeed
        case trips
        case model
        case countryInfo
        case cityInfo
        case oSVersion
        case oS
        case objectives
        case finalAddress
        case startAddress
        case overallScore, didYouHaveToArrive, howOften, usetripMoreFor, shareInformation
        case validationDate
        
        case manualTripStart, manualTripEnd
        case numSplits, numMerges, numDeletes
    }
    
    /**
     Required initializer to deserialize from Json.
     Conforms to Decoder.
     Puts object in default container when created,
     if there is no container the object will not be created
     - parameters:
     - decoder: conforms to init(decoder:) from Decoder
     */
    required convenience init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: FullTrip.entityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        //        try self.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if  let startDate = try container.decodeIfPresent(Double.self, forKey: .startDate),
            let endDate = try container.decodeIfPresent(Double.self, forKey: .endDate),
            let validationDate = try container.decodeIfPresent(Double.self, forKey: .validationDate),
            let distance = try container.decodeIfPresent(Float.self, forKey: .distance),
            let duration = try container.decodeIfPresent(Float.self, forKey: .duration),
            let avSpeed = try container.decodeIfPresent(Float.self, forKey: .avSpeed),
            let mSpeed = try container.decodeIfPresent(Float.self, forKey: .mSpeed),
            let trips = try container.decodeIfPresent([FulltripPartPolymorphicDecoder].self, forKey: .trips)?.map(polymorphicDecode(item:)) {
            
            self.startDate = Date(timeIntervalSince1970: startDate.divided(by: Double(1000)))
            self.endDate = Date(timeIntervalSince1970: endDate.divided(by: Double(1000)))
            self.distance = distance
            self.duration = duration
            self.avSpeed = avSpeed
            self.mSpeed = mSpeed
            self.trips = NSMutableSet(array: trips)
            self.closed = true
            if let user = Auth.auth().currentUser {
                self.uid = user.uid
            }
            self.confirmed=true
            self.sentToServer=true
        }
    }
    
    /**
     Function used to handle polymorphic Leg/Waiting Event lists sent by the server.
     Used to transform a generic part into a concrete and recognizable one.
     part(Leg/Waiting Event)
     - parameters:
     - item: generic structure with both the Leg and Waiting Event fields.
     - returns: Leg or Waiting event depending on the item
     */
    func polymorphicDecode(item: FulltripPartPolymorphicDecoder) throws -> FullTripPart {
        if let ctx = UserInfo.context {
            if item.avLocationLat != nil {
                if let we = WaitingEvent.getWaitingEvent(startDate: Date(timeIntervalSince1970: item.startDate.divided(by: Double(1000))), context: ctx) {
                    let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: item.avLocationLat!, longitude: item.avLocationLon!), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
                    we.avLocation=UserLocation.getUserLocation(userLocation: location, context: ctx)!

                    we.locations = we.locations.addingObjects(from: item.locations) as NSSet
                    we.endDate = Date(timeIntervalSince1970: item.endDate.divided(by: Double(1000)))
                    we.closed=true
                    return we
                }  else {
                    Crashlytics.sharedInstance().recordCustomExceptionName("Waiting Event: not initialized", reason: "This waiting event was not initialized on polymorphicDecode", frameArray: [CLSStackFrame]())
                }
            } else {
                let trip = Trip.getTrip(startDate: Date(timeIntervalSince1970: item.startDate.divided(by: Double(1000))), context: ctx)!
                
                trip.locations = trip.locations.addingObjects(from: item.locations) as NSSet
                trip.endDate = Date(timeIntervalSince1970: item.endDate.divided(by: Double(1000)))
                trip.distance = item.distance!
                trip.duration = item.duration!
                trip.avSpeed = item.avSpeed!
                trip.mSpeed = item.mSpeed!
                
                var modeOfTRansport=""
                switch item.modeOfTransport! {
                case Trip.modesOfTransport.automotive.rawValue:
                    modeOfTRansport = "automotive"
                case Trip.modesOfTransport.cycling.rawValue:
                    modeOfTRansport = "cycling"
                case Trip.modesOfTransport.walking.rawValue:
                    modeOfTRansport = "walking"
                case Trip.modesOfTransport.unknown.rawValue:
                    modeOfTRansport = "unknown"
                case Trip.modesOfTransport.stationary.rawValue:
                    modeOfTRansport = "stationary"
                default:
                    modeOfTRansport = "unknown"
                }
                
                trip.modeOfTransport = modeOfTRansport
                trip.accelerationMean = 0
                trip.closed=true
                return trip
            }
        }
        
        //if gets here then error
        throw NSError(domain: "Decoding Trip Parts", code: 0, userInfo: [String: Any]())
    }
    
    /**
     Generic function to encode this class into Json
     - parameters:
     - encoder: conforms to Encodable encode(encoder:)
     */
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startDate?.timeIntervalSince1970.multiplied(by: Double(1000)), forKey: .startDate)
        try container.encode(endDate?.timeIntervalSince1970.multiplied(by: Double(1000)), forKey: .endDate)
        try container.encode(distance, forKey: .distance)
        try container.encode(duration, forKey: .duration)
        try container.encode(avSpeed, forKey: .avSpeed)
        try container.encode(mSpeed, forKey: .mSpeed)
        try container.encode(getTripPartsortedList(), forKey: .trips)
        try container.encode(UIDevice.current.systemVersion, forKey: .oSVersion)
        try container.encode(UIDevice.current.model, forKey: .model)
        try container.encode("2.0.11", forKey: .oS)
        try container.encode(validationDate?.timeIntervalSince1970.multiplied(by: Double(1000)), forKey: .validationDate)
        let tripObjectives = objective?.map({ (str) -> TripObjective in
            TripObjective(code: str)
        }) ?? [TripObjective]()
        try container.encode(tripObjectives, forKey: .objectives)
        try container.encode(startLocation ?? "", forKey: .startAddress)
        try container.encode(endLocation ?? "", forKey: .finalAddress)
        var country: String = ""
        var locality: String = ""
        
        let sem = DispatchSemaphore(value: 0)
        if let lastLocation = getLastLocation() {
            CLGeocoder().reverseGeocodeLocation(lastLocation) { (plc, e) in
                if let error = e as? Error {
                    sem.signal()
                    return
                } else if let placemarks = plc as? [CLPlacemark] {
                    for placemark in placemarks{
                        if placemark.country != nil {
                            country = "\(placemark.country!.description)"
                        }
                        if placemark.locality != nil {
                            locality = "\(placemark.locality!.description)"
                        }
                        if country.count > 0 && locality.count > 0 {
                            break
                        }
                    }
                }
                sem.signal()
            }
        }
        sem.wait(timeout: DispatchTime(uptimeNanoseconds: (DispatchTime.now().uptimeNanoseconds + 1 * 1000 * 1000 * 1000))) //in nanoseconds

        try container.encode(country, forKey: .countryInfo)
        try container.encode(locality, forKey: .cityInfo)

        
        try container.encode(overallScore, forKey: .overallScore)
        try container.encode(didYouHaveToArrive, forKey: .didYouHaveToArrive)
        try container.encode(howOften, forKey: .howOften)
        try container.encode(usetripMoreFor, forKey: .usetripMoreFor)
        try container.encode(shareInformation, forKey: .shareInformation)
        
        try container.encode(manualTripStart, forKey: .manualTripStart)
        try container.encode(manualTripEnd, forKey: .manualTripEnd)
        
        try container.encode(numSplits, forKey: .numSplits)
        try container.encode(numMerges, forKey: .numMerges)
        try container.encode(numDeletes, forKey: .numDeletes)
        

        
    }
    
    //MARK: Json request
    /**
     specialized makeRequest to encapsulate the MoTiV server Url
     - parameters:
     - accessToken: the user access token as provided by firebase to authenticate on our server
     */
    func makeRequest(accessToken: String?){
        RestModule(urlString: url+endpoint, jsonData: self.toJsonData(), method: RestModule.Method.POST, responseFunction: self, accessToken: accessToken).makeRequest()
    }
    
    func responseFunc(response: String) {
        MotivRequestManager.getInstance().tripBeingSentToServer = false
        
        //Do not show popup for old trips being sent
        if let validationDate = self.validationDate, (Calendar.current.dateComponents([.hour], from: validationDate, to: Date()).hour! > 1){
            self.sendToServerSem.signal()
            return
        }
        
        //Handle Trip Submission popups
        if (response != "") {
            self.sentToServer = true
            UiAlerts.getInstance().showAlertMsgForTripValidation(title: "", message: NSLocalizedString("Trip_Submission_Successful", comment: ""), seconds: 2.0)
        }
        else {
            UiAlerts.getInstance().showAlertMsgForTripValidation(title: "", message: NSLocalizedString("Trip_Submission_Not_Submitted", comment: ""), seconds: 2.0)
        }
        self.sendToServerSem.signal()
    }
    
    func getDeviceInfo() -> String {
        return "version \(UIDevice.current.systemVersion) model: \(UIDevice.current.model)"
    }
    
    func getTripOrderedList() -> [Trip] {
        var trips = [Trip]()
        for part in getTripPartsortedList() {
            if let trip = part as? Trip{
                trips.append(trip)
            }
        }
        return trips
    }
    
    //confirm the send of a trip to back office
    public func confirmTrip(){
        if self.closed {
            if let user = MotivUser.getInstance(),
                !self.confirmed {
                user.processYearlyInfoForTrip(ft: self)
    
            }
            
            if !self.confirmed {
                if let startDate = self.startDate {
                    for campaign in MotivUser.getInstance()!.getCampaigns() {
                        let score = getScoreSumForCampaign(campaignId: campaign.campaignId)
                        RewardManager.instance.checkAndAssignScoreForTrip(campaignId: campaign.campaignId, date: startDate, score: score)
                    }
                }
            }
            
            self.sentToServer = false
            self.confirmed = true
            self.validationDate = Date()
            
            
            
           
            
            DispatchQueue.global(qos: .background).async {
                self.sendToServerLock.lock()
                
                

                let sem = DispatchSemaphore(value: 0)
                
                let manager = MotivRequestManager.getInstance()
                manager.tripBeingSentToServer = true
                
                manager.sendTrip(trip: self)
                self.sendToServerSem.wait()
            
                UserInfo.appDelegate?.saveContext()
                
                MotivRequestManager.getInstance().requestSaveUserSettings()
                self.sendToServerLock.unlock()
            }
        }
    }
    
    
    public func joinWithnext(part: FullTripPart, modeOfTRansport: String = "", fromInterface: Bool){
        if fromInterface {
            self.numMerges = self.numMerges + 1
        }
        let parts = getTripPartsortedList()
        if let index = parts.index(of: part) {
            if index >= 0 && index < parts.count - 1 {
                if let leg = part as? Trip {
                    if let nextLeg = parts[index + 1] as? Trip {
                        let bg = FiniteBackgroundTask()
                        bg.registerBackgroundTask(withName: "JoinLegWithNextLeg")
                        joinLegs(prevLeg: leg, leg: nextLeg, modeOfTRansport: modeOfTRansport, fromInterface: fromInterface)
                        bg.endBackgroundTask()
                    } else if let nextWE = parts[index + 1] as? WaitingEvent {
                        let bg = FiniteBackgroundTask()
                        bg.registerBackgroundTask(withName: "JoinLegWithNextWe")
                        joinLegWE(we: nextWE, leg: leg, modeOfTRansport: modeOfTRansport, fromInterface: true)
                        bg.endBackgroundTask()
                    }
                } else if let we = part as? WaitingEvent {
                    if let nextLeg = parts[index + 1] as? Trip {
                        let bg = FiniteBackgroundTask()
                        bg.registerBackgroundTask(withName: "JoinWeWithNextLeg")
                        joinLegWE(we: we, leg: nextLeg, modeOfTRansport: modeOfTRansport, fromInterface: true)
                        bg.endBackgroundTask()
                    } else if let nextWE = parts[index + 1] as? WaitingEvent {
                        let bg = FiniteBackgroundTask()
                        bg.registerBackgroundTask(withName: "JoinWeWithNextWe")
                        self.joinWeWe(prevWe: we, we: nextWE)
                        bg.endBackgroundTask()
                    }
                }
            }
        }
    }
    
    public func JoinLastTwoAfterNoLocations() {
        let parts = self.getTripPartsortedList()
        if parts.count > 1 {
            guard let we = parts.last as? WaitingEvent else {
                Crashlytics.sharedInstance().recordCustomExceptionName("JoinLastTwoAfterNoLocations: last is not we", reason: "last element of the fulltrip is not a we", frameArray: [CLSStackFrame]())
                return
            }
            guard let leg = parts[parts.count - 2] as? Trip else {
                Crashlytics.sharedInstance().recordCustomExceptionName("JoinLastTwoAfterNoLocations: one to last is not Trip", reason: "one to last element is not Trip", frameArray: [CLSStackFrame]())
                return
            }
            
            joinLegWE(we: we, leg: leg, modeOfTRansport: "", CloseLeg: false, fromInterface: false)
        }
    }
    
    public func joinLegWE(we: WaitingEvent, leg: Trip, modeOfTRansport: String = "", CloseLeg: Bool = true, fromInterface: Bool){
        for loc in we.getLocationsortedList() {
            leg.newLocation(location: loc)
        }
        leg.startDate = leg.getLocationsortedList().first?.location?.timestamp ?? Date(timeIntervalSince1970: 0)
        leg.closed = false
        //mode of transport detected
        if CloseLeg {
            leg.correctedModeOfTransport = modeOfTRansport
        //close Leg
            leg.processCloseInformation()
        }
        if fromInterface {
            leg.mergedWithWE()
        }
        //clean Trip
        self.removeFromTrips(we)
        //reclose Trip
        self.closed = false
        if CloseLeg {
            self.processFullTrip()
        }
    }
    
    public func joinLegWEAsWE(we: WaitingEvent, leg: Trip, modeOfTRansport: String = "", Close: Bool = true, fromInterface: Bool){
        for loc in leg.getLocationsortedList() {
            we.newLocation(location: loc)
        }
        we.startDate = leg.getLocationsortedList().first?.location?.timestamp ?? Date(timeIntervalSince1970: 0)
        we.closed = false
        //mode of transport detected
        if Close {
            we.processCloseInformation()
        }
        //        //clean Trip
        self.removeFromTrips(we)
        //        //reclose Trip
        self.closed = false
        if Close {
            self.processFullTrip()
        }
    }
    
    public func joinWeWe(prevWe: WaitingEvent,we: WaitingEvent) {
        for loc in we.getLocationsortedList() {
            prevWe.newLocation(location: loc)
        }
        prevWe.startDate = prevWe.getLocationsortedList().first?.location?.timestamp ?? Date(timeIntervalSince1970: 0)
        prevWe.closed = false
        //mode of transport detected
        //        //close we
        prevWe.processCloseInformation()
        //        //clean Trip
        self.removeFromTrips(we)
        //        //reclose Trip
        self.closed = false
        self.processFullTrip()
    }
    
    public func JoinMultipleLegs(prev: Trip, trips: [Trip]) {
        var newLeg = prev
        for trip in trips {
            newLeg = self.joinLegs(prevLeg: newLeg, leg: trip, fromInterface: false)
        }
    }
    
    public func joinLegs(prevLeg: Trip, leg: Trip, modeOfTRansport: String = "", fromInterface: Bool) -> Trip {
        let newLeg = Trip.getTrip(startDate: prevLeg.startDate, context: UserInfo.context!)!
        //Locations
        var locations = [UserLocation]()
        locations.append(contentsOf: prevLeg.getLocationsortedList())
        locations.append(contentsOf: leg.getLocationsortedList())
        for loc in locations {
            newLeg.newLocation(location: loc)
        }
        //mode of transport detected
        newLeg.modeOfTransport = (fromInterface ? ActivityClassfier.UNKNOWN : prevLeg.modeOfTransport ) ?? "" // leg é considereda logo errada
        newLeg.correctedModeOfTransport = modeOfTRansport
        //close Leg
        newLeg.processCloseInformation()
        //clean Trip
        self.removeFromTrips(prevLeg)
        self.removeFromTrips(leg)
        self.trips.remove(prevLeg)
        self.trips.remove(leg)
        self.addToTrips(newLeg)
        if fromInterface {
            // if from interface store previous
            newLeg.mergedFromLegs(parentParts: [prevLeg,leg])
        }
        //reclose Trip
        self.closed = false
        self.processFullTrip()
        return newLeg
    }
    
    public func splitLeg(locations: CLLocationCoordinate2D, leg: Trip, fromInterface: Bool) {
        if let middleCoordinate = leg.getMostProbableCoordinate(location: locations) {
            let middleTimestamp = middleCoordinate.timestamp
            //create legs
            let firstNewLeg = Trip.getTrip(startDate: leg.startDate, context: UserInfo.context!)!
            let secondNewLeg = Trip.getTrip(startDate: middleTimestamp, context: UserInfo.context!)!
            //retrieve locations for each new leg
            let firstLocations = ProcessActivityData.getLocationsList(sDate: leg.startDate, eDate: middleTimestamp, locations: leg.getLocationsortedList())
            let secondLocations = ProcessActivityData.getLocationsList(sDate: middleTimestamp, eDate: leg.endDate!, locations: leg.getLocationsortedList())
            //set locations on new legs
            for loc in firstLocations {
                firstNewLeg.newLocation(location: loc)
            }
            for loc in secondLocations {
                secondNewLeg.newLocation(location: loc)
            }
            //mode of transport detected
            firstNewLeg.modeOfTransport = leg.modeOfTransport ?? ""
            firstNewLeg.correctedModeOfTransport = leg.correctedModeOfTransport
            secondNewLeg.modeOfTransport = leg.modeOfTransport ?? ""
            secondNewLeg.correctedModeOfTransport = leg.correctedModeOfTransport
            //close legs
            firstNewLeg.processCloseInformation()
            secondNewLeg.processCloseInformation()
            // if form interface reload the
            if fromInterface {
                firstNewLeg.splittedFromLeg(parentLeg: leg)
                secondNewLeg.splittedFromLeg(parentLeg: leg)
            }
            //clean Trip
            self.removeFromTrips(leg)
            self.addToTrips(firstNewLeg)
            self.addToTrips(secondNewLeg)
            //reclose Trip
            self.closed = false
            self.processFullTrip()
        }
    }
    
    public func splitFiveMinutesForNext(onLocation: CLLocation, context: NSManagedObjectContext) -> Bool {
        if let lastpart = self.getTripPartsortedList().last {

            var LocationsToNext = filterFor5Min100M(onLocation: onLocation, onPart: lastpart, toNext: true)
            
            switch lastpart {
            case let leg as Trip:
                lastpart.removeFromLocations(NSSet(array: LocationsToNext))
                let transfer = WaitingEvent.getWaitingEvent(startDate: LocationsToNext.first?.location?.timestamp ?? onLocation.timestamp, context: context)!
                transfer.newLocations(locs: LocationsToNext.reversed())
                context.performAndWait {
                    self.addToTrips(transfer)
                }
                break
            case let transfer as WaitingEvent:
                if LocationsToNext.count < 1 {
                    if let lastlocation = lastpart.getLocationsortedList().last,
                        lastlocation.location?.timestamp.addingTimeInterval(TimeInterval(60*5)) ?? Date(timeIntervalSince1970: 0) > onLocation.timestamp {
                        LocationsToNext.append(lastlocation)
                    }
                }
                lastpart.removeFromLocations(NSSet(array: LocationsToNext))
                let trip = Trip.getTrip(startDate: LocationsToNext.first?.location?.timestamp ?? onLocation.timestamp, context: context)!
                trip.newLocations(locs: LocationsToNext.reversed())
                context.performAndWait {
                    self.addToTrips(trip)
                }
                break
            default:
                break
            }
            return true
        }
        
        return false
    }
    
    func splitFiveMinutesForLastLeg() {
        let parts = self.getTripPartsortedList()
        if parts.count < 2 {
            //then there is only one part, most likely a leg
            return
        }
        if  let lastWE = parts.last as? WaitingEvent,
            let lastLeg = parts[parts.count - 2] as? Trip,
            let lastLegLocation = lastLeg.getLocationsortedList().last?.location {
            
            let locationsToPrev = filterFor5Min100M(onLocation: lastLegLocation, onPart: lastWE, toNext: false)
            
            
            if locationsToPrev != nil && locationsToPrev.count > 0 {
                lastLeg.newLocations(locs: locationsToPrev)
            }
        }
    }
    
    func filterFor5Min100M(onLocation: CLLocation, onPart: FullTripPart, toNext: Bool) -> [UserLocation] {
        var LocationsToNext = [UserLocation]()
        for location in onPart.getLocationsortedList().reversed()  {
            if location.location?.distance(from: onLocation) ?? 100 < Double(100) {
                if (location.location?.timestamp.addingTimeInterval(TimeInterval(60*5)) ?? Date(timeIntervalSince1970: 0) > onLocation.timestamp
                    && toNext) {
                    // get the previous five minutes of location
                    LocationsToNext.append(location)
                } else if (location.location?.timestamp ?? Date(timeIntervalSince1970: 0) < onLocation.timestamp.addingTimeInterval(TimeInterval(60*5))
                    && !toNext) {
                    // get the next five minutes of location
                    LocationsToNext.append(location)
                }
            } else {
                break
            }
        }
        return LocationsToNext
    }
    
    public func cleanTrip(){
        removeLastWaitingEvent()
        removeFirstWaitingEvent()
        if self.getTripOrderedList().count < 1 {
            delete()
        }
        
    }
    
    /*
    * Remove self
    */
    public func delete() {
        for part in getTripPartsortedList() {
            if let we = part as? WaitingEvent {
                we.delete()
            }
            if let trip = part as? Trip {
                trip.delete()
            }
        }
        UserInfo.removeTrip(trip: self)
        UserInfo.context?.delete(self)
    }
    
    //Intra-Leg proessing
    func IntraLegProcessing() {
        let parts = self.getTripPartsortedList()
        var ind = 0
        
        while(ind < parts.count) {
            let part = parts[ind]
            if let leg = part as? Trip {
                // Leg
                if leg.isStill() {
                    // Still Leg
                    if (ind == parts.count-1) { 
                        //remove still
                        self.removeFromTrips(leg)
                        IntraLegProcessing()
                        return
                    } else if let nextWe = parts[ind + 1] as? WaitingEvent {
                        //Join leg with next we
                        self.joinLegWEAsWE(we: nextWe, leg: leg, fromInterface: false)
                        IntraLegProcessing()
                        return
                    } else if ind > 0 && ind + 1 < parts.count - 1,
                        let lastLeg = parts[ind - 1] as? Trip,
                        let nextLeg = parts[ind + 1] as? Trip {
                        
                        if lastLeg.modeOfTransport == nextLeg.modeOfTransport {
                            //if previous leg is equal to next leg and we were still join all
                            self.JoinMultipleLegs(prev: lastLeg, trips: [leg,nextLeg])
                            IntraLegProcessing()
                            return
                        }
                    }
                }
                
                if  ind + 1 < parts.count,
                    let nextLeg = parts[ind + 1] as? Trip,
                    leg.modeOfTransport == nextLeg.modeOfTransport {
                    
                    //Join we with next leg if modes are the same
                    self.joinLegs(prevLeg: leg, leg: nextLeg, fromInterface: false)
                    IntraLegProcessing()
                    return
                }
                
            } else if let we = part as? WaitingEvent {
                // Waiting events
                if (ind == 0 || ind == parts.count-1) {
                    //remove we
                    self.removeFromTrips(we)
                    IntraLegProcessing()
                    return
                } else if let nextLeg = parts[ind + 1] as? Trip, nextLeg.isStill(){
                    //Join we with next leg
                    self.joinLegWEAsWE(we: we, leg: nextLeg, fromInterface: false)
                    IntraLegProcessing()
                    return
                } else if let nextWe = parts[ind + 1] as? WaitingEvent {
                    //Join we with next leg
                    self.joinWeWe(prevWe: we, we: nextWe)
                    IntraLegProcessing()
                    return
                }
            }
            ind += 1
        }
    }
    
    // scores
    public func answerPurpose() {
        let newScores = getScore().answerPurpose()
        if let user = MotivUser.getInstance() {
            user.diffPoints(points: newScores)
        }
    }
    
    public func answerCompleteAllInfo() {
        let newScores = getScore().answerCompleteAllInfo()
        if let user = MotivUser.getInstance() {
            user.diffPoints(points: newScores)
        }
    }
    
    private func getScore() -> TripScored {
        if self.score == nil {
            self.score = TripScored.getTripScored()
        }
        return self.score!
    }
    
    public func getScoreSum() -> Double {
        let score = self.getTripPartsortedList().reduce(Double(0)) { (prev, part) -> Double in
            var value = Double(0)
            switch part {
            case let trip as Trip:
                value = trip.getScoreSum()
                
            case let we as WaitingEvent:
                value = we.getScoreSum()
                
            default:
                break
            }
        
            return prev + value
        }
        
        return getScore().getScore() + score
 
    }
    
    public func getScoreSumForCampaign(campaignId: String) -> Double {
        let score = self.getTripPartsortedList().reduce(Double(0)) { (prev, part) -> Double in
            var value = Double(0)
            switch part {
            case let trip as Trip:
                value = trip.getScoreSumForCampaign(campaignId: campaignId)
                
            case let we as WaitingEvent:
                value = we.getScoreSumForCampaign(campaignId: campaignId)
                
            default:
                break
            }
            
            return prev + value
        }
        
        return getScore().getScoreFor(campaignId: campaignId) + score
    }
    
    public func getScoreByCampaign() -> [String: Double] {
        let score = self.getTripPartsortedList().reduce([String: Double]()) { (prev, part) -> [String: Double] in
            prev.merging(part.getScoreByCampaign(), uniquingKeysWith: { (v1, v2) -> Double in
                v1 + v2
            })
        }
        return score.merging(self.getScore().getResultScores(), uniquingKeysWith: { (v1, v2) -> Double in
            v1 + v2
        })
    }
}

class TripObjective: JsonParseable {
    let tripObjectiveCode: Int
    let tripObjectiveString: String
    
    static let objectives = ["Going to Work", "Going to School", "Going home", "Movies/Theatre",
    "Mall/Shopping", "Groceries", "Eating out", "Cafes", "Party"];
    
    enum CodingKeys: String, CodingKey {
        case tripObjectiveCode
        case tripObjectiveString
    }
    
    init(code :String) {
        self.tripObjectiveString = code
        self.tripObjectiveCode = TripObjective.objectives.index(of: code) ?? 9
    }
}




