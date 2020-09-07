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
import CoreMotion
import CoreData

/*
* Represents each individual part of the trip.
    variables: 
    - activities: Activities chosen by the user (activities while travelling).
    - fullTrip: reference to fullTrip
    - locations: Set of GPS locations
    - startDate: start timestamp
    - endDate: end timestamp
    - closed: trip has ended

    - wastedTime: Type of time wasted
    - infrastructureAndServicesFactors: Infrastructure factors (Deprecated)
    - comfortAndPleasentFactors: Comfort and Pleasantness factors
    - gettingThereFactors: Getting There factors
    - activitiesFactors: Activities Factors
    - whileYouRideFactors: While You Ride Factors
    - otherFactor: Other Factor
    - valueFromTrip: Set of ValueFromTrip inserted by the user

*/
class FullTripPart: NSManagedObject, JsonParseable {
    
    //MARK:properties coreData
    @NSManaged public var activities: NSSet //[UserActivity]
    @NSManaged public var fullTrip: FullTrip?
    @NSManaged public var locations: NSSet //[UserLocation]
    @NSManaged var startDate: Date
    @NSManaged var endDate: Date?
    @NSManaged var closed: Bool

    @NSManaged var wastedTime: Double
    @NSManaged var infrastructureAndServicesFactors: [worthwhilenessFactors]?
    @NSManaged var comfortAndPleasentFactors: [worthwhilenessFactors]?
    @NSManaged var gettingThereFactors: [worthwhilenessFactors]?
    @NSManaged var activitiesFactors: [worthwhilenessFactors]?
    @NSManaged var whileYouRideFactors: [worthwhilenessFactors]?
    
    
    @NSManaged var otherFactor: String?
    @NSManaged var valueFromTrip: [ValueFromTrip]?
    
    //UI filled variables Start
    @NSManaged public var productivityScore: Double
    @NSManaged public var relaxingScore: Double
    @NSManaged public var legUserActivities: [String]?
    @NSManaged public var legUserActivitiesType: [Int]?
    @NSManaged public var relaxingCDValues: NSSet //comfortDiscomfortValues
    @NSManaged public var productiveCDValues: NSSet //comfortDiscomfortValues
    
    @NSManaged public var relaxingFactorText: String
    @NSManaged public var productiveFactorText: String
    //UI filled variables End
    
    //Locking
    let locationListSem = DispatchSemaphore(value: 1)
    
    //mockActivities (deprecated)
    var mockActivities = [MockActivity]()
    
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FullTripPart> {
        return NSFetchRequest<FullTripPart>(entityName: "FullTripPart")
    }
    
    //MARK:properties
    public static let entityName = "FullTripPart"
    
    convenience init(startDate: Date, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: FullTripPart.entityName, in: context)!
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        self.startDate=startDate
    }
    
    func getModeOftransport() -> Trip.modesOfTransport {
        return Trip.modesOfTransport.transfer
    }
    
    public static func getFullTripPart(startDate: Date, context: NSManagedObjectContext) -> FullTripPart? {
        var ftp: FullTripPart?
        UserInfo.ContextSemaphore.wait()
        context.performAndWait {
            ftp = FullTripPart(startDate: startDate, context: context)
        }
        return ftp
    }
    
    //MARK: functions
    //add new activity mode to the trip part
    //Deprecated, moved to a single list of activities on the UserInfo
    public func newActivity(activity: CMMotionActivity,context: NSManagedObjectContext){
        
        activities = activities.adding(UserActivity.getUserActivity(userActivity: activity, context: context)!) as NSSet
    }
    
    //add new activity mode to the trip part
    public func newMockActivity(activity: MockActivity,context: NSManagedObjectContext){
        mockActivities.append(activity)
    }
    
    
    //add new location to the trip part
    public func newLocation(location: CLLocation, context: NSManagedObjectContext){
        newLocation(location: UserLocation.getUserLocation(userLocation: location, context: context)!)
    }
    
    //Add new UserLocation
    public func newLocation(location: UserLocation) {
        locationListSem.wait()
            locations = locations.adding(location) as NSSet
        locationListSem.signal()
    }
    
    //Add set of UserLocation
    public func newLocations(locs: [UserLocation]) {
        locationListSem.wait()
        locations = locations.addingObjects(from: locs) as NSSet
        locationListSem.signal()
    }
    
    //Deprecated
    public func addCDFactorValue(cdfactor: ComfortDiscomfortValues, type: ComfortDiscomfortValues.type, factorText: String){
        
        switch type {
        case .Production:
            self.productiveCDValues = self.productiveCDValues.adding(cdfactor) as NSSet
            self.productiveFactorText = factorText
        case .Relaxing:
            self.relaxingCDValues = self.relaxingCDValues.adding(cdfactor) as NSSet
            self.relaxingFactorText = factorText
        }
    }
    
    //Deprecated
    public func cleanFactors(type: ComfortDiscomfortValues.type){
        switch type {
        case .Production:
            self.productiveCDValues = NSSet()
            self.productiveFactorText = ""
        case .Relaxing:
            self.relaxingCDValues = NSSet()
            self.relaxingFactorText = ""
        }
        
    }
    
    //Print information (log info)
    public func printInfo() -> String {
        var responseText = ""
        
        responseText.append("\n")
        responseText.append("\n")
        responseText.append(" SDate: " + startDate.description(with: Locale.autoupdatingCurrent))
        if closed {responseText.append(" EDate: " + endDate!.description(with: Locale.autoupdatingCurrent))}
        responseText.append(" type: ")
        if isTrip() {
            responseText.append(" Trip ")
        }else{
            responseText.append(" WE ")
        }
        responseText.append("\n")
        
        for activity in activities {
            responseText.append("Modes: [")
            if ((activity as! UserActivity).activity?.walking)! {
                responseText.append("walking ")
            }
            if ((activity as! UserActivity).activity?.stationary)! {
                responseText.append("stationary ")
            }
            if ((activity as! UserActivity).activity?.automotive)! {
                responseText.append("automotive ")
            }
            if ((activity as! UserActivity).activity?.cycling)! {
                responseText.append("cycling ")
            }
            if ((activity as! UserActivity).activity?.running)! {
                responseText.append("running ")
            }
            if ((activity as! UserActivity).activity?.unknown)! {
                responseText.append("unknown ")
            }
            responseText.append("] Confidence level: " + ((activity as! UserActivity).activity?.confidence.rawValue.description)!)
            responseText.write("StartDate: " + ((activity as! UserActivity).activity?.startDate.description)! + "\n")
        }
        for location in getLocationsortedList() {
            responseText.append("coords:  ")
            //            responseText.append(((location as! UserLocation).location?.coordinate.latitude.description)! + " ")
            //            responseText.append(((location as! UserLocation).location?.coordinate.longitude.description)! + " ")
            //            responseText.append(((location as! UserLocation).location?.horizontalAccuracy.description)! + " ")
            //            responseText.append(((location as! UserLocation).location?.speed.description)! + " ")
            //            responseText.append(((location as! UserLocation).location?.timestamp.description)! + "\n")
            
            responseText.append((location.location?.coordinate.latitude.description)! + " ")
            responseText.append((location.location?.coordinate.longitude.description)! + " ")
            responseText.append((location.location?.horizontalAccuracy.description)! + " ")
            responseText.append((location.location?.speed.description)! + " ")
            responseText.append((location.location?.timestamp.description(with: Locale.autoupdatingCurrent))! + "\n")
        }
        return responseText
        
    }
    
    public func printFinalData() -> String {
        var responseText = ""
        responseText.append("Start Date: " + (startDate.description(with: Locale.autoupdatingCurrent)) + "\n")
        if(closed){
            responseText.append("End Date: " + (endDate?.description(with: Locale.autoupdatingCurrent))! + "\n")
        }else{
            responseText.append("Trip not finished yet \n")
        }
        
        return responseText
    }
    
    public func isTrip() -> Bool {
        return false
    }
    
    /*
    *   End leg with last location
    */
    public func endTripPart(endLocation: CLLocation){
        endDate=endLocation.timestamp
        newLocation(location: endLocation, context: UserInfo.context!)
        processCloseInformation()
        
    }
    
    //MARK: sorting functions
    public func getLocationsortedList() -> [UserLocation]{
        locationListSem.wait()
        var arraylocations: [UserLocation] = locations.allObjects as! [UserLocation]
        locationListSem.signal()
        arraylocations.sort(by: { (loc1, loc2) -> Bool in
            return (loc1.location!.timestamp) < (loc2.location!.timestamp)
        })
        return arraylocations
    }
    
    
    //Used to check if leg is empty and delete
    public func getLocationListCount() -> Int {
        locationListSem.wait()
        var count = locations.allObjects.count
        locationListSem.signal()
        return count
    }
    
    
    
    public func getActivitysortedList() -> [UserActivity]{
        var arrayActivities: [UserActivity] = activities.allObjects as! [UserActivity]
        
        UserInfo.context?.performAndWait {
            arrayActivities.sort(by: { (act1, act2) -> Bool in
                return (act1.activity!.startDate) < (act2.activity!.startDate)
            })
        }
        return arrayActivities
    }
    
    //MARK:functions CoreData
    
    // MARK: Generated accessors for activities
    @objc(addActivitiesObject:)
    @NSManaged public func addToActivities(_ value: UserActivity)
    
    @objc(removeActivitiesObject:)
    @NSManaged public func removeFromActivities(_ value: UserActivity)
    
    @objc(addActivities:)
    @NSManaged public func addToActivities(_ values: NSSet)
    
    @objc(removeActivities:)
    @NSManaged public func removeFromActivities(_ values: NSSet)
    
    // MARK: Generated accessors for locations
    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: UserLocation)
    
    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: UserLocation)
    
    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)
    
    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)
    
    //MARK:processing functions
    public func processCloseInformation(){
        self.closed=true
        self.endDate = getEndDate()
        
    }
    
    public func getEndDate() -> Date {
        if( self.endDate == nil ){
            guard let lastLocation =  getLocationsortedList().last?.location?.timestamp else {
                self.endDate = self.startDate
                return self.startDate
            }
            self.endDate = lastLocation
        }
        return self.endDate!
    }
    
    
    //MARK: ParseableFunctions
    enum CodingKeys: String, CodingKey {
        case startDate
        case endDate
        case locations
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: Trip.MyEntityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if  let startDate = try container.decodeIfPresent(Double.self, forKey: .startDate),
            let endDate = try container.decodeIfPresent(Double.self, forKey: .endDate),
            let locations = try container.decodeIfPresent([UserLocation].self, forKey: .locations) {
            
            self.startDate = Date(timeIntervalSince1970: startDate.divided(by: Double(1000)))
            self.endDate = Date(timeIntervalSince1970: endDate.divided(by: Double(1000)))
            self.locations = NSSet(array: locations)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startDate.timeIntervalSince1970.multiplied(by: Double(1000)), forKey: .startDate)
        try container.encode(endDate?.timeIntervalSince1970.multiplied(by: Double(1000)), forKey: .endDate)
        try container.encode(getLocationsortedList(), forKey: .locations)
    }
    
    /*
    * Delete Leg
    */
    public func delete() {
        for acts in getActivitysortedList() {
            acts.delete()
        }
        for locs in getLocationsortedList() {
            locs.delete()
        }
        UserInfo.context?.delete(self)
    }
    
    public func getScoreByCampaign() -> [String: Double] {
        return [String: Double]()
    }
}

struct FulltripPartPolymorphicDecoder: Decodable {
    
    var locations: [UserLocation]
    var startDate: Double
    var endDate: Double
    
    //Trip
    var distance: Float?
    var duration: Float?
    var avSpeed: Float?
    var mSpeed: Float?
    var modeOfTransport: Int?
    var accelerationMean: Double?
    
    //WE
    var avLocationLat: Double?
    var avLocationLon: Double?
    
}

class LegsToSend: JsonParseable {
    let code: String
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case code
        case text
    }
    
    init(code: String, text: String) {
        self.code = code
        self.text = text
    }
    
    public static func getActivities(part: FullTripPart) -> ([LegsToSend],[LegsToSend],[LegsToSend]) {
        var pa = [LegsToSend]()
        var pm = [LegsToSend]()
        var pb = [LegsToSend]()
        
        for type in part.legUserActivitiesType ?? [Int]() {
            if  let index = part.legUserActivitiesType?.index(of: type),
                let code = part.legUserActivities?[index],
                let actType = ActivitySelect.type(rawValue: type) {
                
                
                let (codes, images) = LegActivities.getArrays(type: actType, modeOfTRansport: part.getModeOftransport())
                if  let arraysInd = codes.index(of: code) ?? codes.index(of: LegActivities.ActivityCodeForOther) {
                    let codeToSend = images[arraysInd]
                    var txtToSend = ""
                    
                    if codes[arraysInd] == LegActivities.ActivityCodeForOther {
                        txtToSend = code
                    }
                    
                    switch actType {
                        case .productivity:
                            pa.append(LegsToSend(code: codeToSend, text: txtToSend))
                            break
                        case .mind:
                            pm.append(LegsToSend(code: codeToSend, text: txtToSend))
                            break
                        case .body:
                            pb.append(LegsToSend(code: codeToSend, text: txtToSend))
                            break
                    }
                }
            }
        }
        return (pa,pm,pb)
    }
}

/*
*   Activities done while travelling. Set and get possible activities for each mode. 
*/
class LegActivities: JsonParseable {
    let intCode: Int
    let textCode: String
    let type: Int
    
    enum CodingKeys: String, CodingKey {
        case intCode
        case textCode
        case type
    }
    
    init(text: String, type: ActivitySelect.type) {
        let arrays = LegActivities.getArrays(type: type, modeOfTRansport: Trip.modesOfTransport.automotive)
        self.intCode = arrays.0.index(of: text)!
        self.textCode = text
        self.type = type.rawValue
    }
    
    static func getArrays(type: ActivitySelect.type, modeOfTRansport: Trip.modesOfTransport) -> ([String],[String]) {
        switch type {
        case .productivity:
            var indexToCount = [Int]()
            switch modeOfTRansport {
            // Driver
            case .automotive, .cycling, .walking, .running, .Car, .electricBike, .bikeSharing, .microScooter, .skate, .motorcycle, .moped, .carSharing, .wheelChair, .cargoBike, .electricWheelchair:
                indexToCount.append(0)
                indexToCount.append(2)
                indexToCount.append(5)
                indexToCount.append(7)
                indexToCount.append(8)
                indexToCount.append(9)
                indexToCount.append(10)
                indexToCount.append(11)
                indexToCount.append(12)
                break
            // nonDriver
            case .transfer, .stationary, .Train, .Tram, .Subway, .Ferry, .Plane, .Bus, .carPassenger, .taxi, .rideHailing, .busLongDistance, .intercityTrain, .highSpeedTrain, .carSharingPassenger:
                indexToCount.append(1)
                indexToCount.append(2)
                indexToCount.append(3)
                indexToCount.append(4)
                indexToCount.append(5)
                indexToCount.append(6)
                indexToCount.append(7)
                indexToCount.append(8)
                indexToCount.append(9)
                indexToCount.append(10)
                indexToCount.append(11)
                indexToCount.append(12)
                break
            //other
            default:
                indexToCount.append(0)
                indexToCount.append(1)
                indexToCount.append(2)
                indexToCount.append(3)
                indexToCount.append(4)
                indexToCount.append(5)
                indexToCount.append(6)
                indexToCount.append(7)
                indexToCount.append(8)
                indexToCount.append(9)
                indexToCount.append(10)
                indexToCount.append(11)
                indexToCount.append(12)
                break
            
                
            }
            
            var activitiestmp = activitiesCodeTextProductivity
            activitiestmp[0] = getFirstActivityForDrivingModeOfTransprot(mot: modeOfTRansport)
            
            let activities = indexToCount.map { (ind) -> String in
                return activitiestmp[ind]
            }
            
            let activitiesImages = indexToCount.map { (ind) -> String in
                return imagesProductivity[ind]
            }
            
            return (activities, activitiesImages)
        case .mind:
            return (activitiesCodeTextMind,imagesMind)
        case .body:
            return (activitiesCodeTextBody,imagesBody)
        }
    }
    
    static func getFirstActivityForDrivingModeOfTransprot(mot: Trip.modesOfTransport) -> String {
        switch mot {
        case .walking:
            return "The_Walk_Itself"
        case .running:
            return "Running"
        case .wheelChair, .moped, .motorcycle, .electricWheelchair:
            return "Riding"
        case .cycling, .electricBike, .cargoBike, .bikeSharing, .microScooter:
            return "Cycling"
        case .skate:
            return "Skating"
        case .Car, .carSharing:
            return "Driving"
        default:
            return "Riding"
        }
    }
    
    static let ActivityCodeForOther = "Other"

    static let activitiesCodeTextProductivity = [
        "Driving_Cycling_Walking",
        "Relaxing_Sleeping",
        "Browsing_Social_Media",
        "Reading_Writing_Paper",
        "Reading_Writing_Device",
        "Listening_To_Audio",
        "Walking_Video_Gaming",
        "Talking_Including_Phone",
        "Accompanying_Someone",
        "Eating_Drinking",
        "Personal_Caring",
        "Thinking",
        ActivityCodeForOther
    ];
    
    static let imagesProductivity = [
        "Driving_Cycling_Walking",
        "Relaxing_Sleeping",
        "Browsing_Social_Media",
        "Reading_Writing_Paper",
        "Reading_Writing_Device",
        "Listening_To_Audio",
        "Walking_Video_Gaming",
        "Talking_Including_Phone",
        "Accompanying_Someone",
        "Eating_Drinking",
        "Personal_Caring",
        "Thinking",
        "Other"
    ]
    
    static let activitiesCodeTextMind = [
        "Sleeping/Snoozing",
        "Relaxing/Doing Nothing",
        "Reading",
        "Talking with Other",
        "Observing The View",
        "Listening to Audio Media",
        "Watching Video",
        "Text Messages",
        "Phone Call",
        "Internet Browsing",
        "Social Media (Facebook, ...)",
        "Playing Games"
    ];
    
    static let imagesMind = [
        "MTActivitySleepingSnoozing",
        "MTActivityRelaxingDoingNothing",
        "MTActivityReading",
        "MTActivityTalkingToOthers",
        "MTActivityObserveView",
        "MTActivityListenToAudioMedia",
        "MTActivityVideo",
        "MTActivityTextMessages",
        "MTActivityPhoneCall",
        "MTActivityInternetBrowsing",
        "MTActivitySocialMedia",
        "MTActivityPlayingGames"
    ]
    
    static let activitiesCodeTextBody = [
        "Sleeping/Snoozing",
        "Eating/Drinking",
        "Exercising (Walk, Run, ...)",
        "Personal Care",
        ActivityCodeForOther
    ];
    
    static let imagesBody = [
        "MTActivityReading",
        "MTActivityEatingDrinking",
        "MTActivityExercising",
        "MTActivityPersonalCare",
        "MTActivityOther"
    ]
}

class RPTripRating: JsonParseable {
    
    let productivity: Int
    let relaxing: Int
    
    init(rel: Int, prod: Int) {
        self.relaxing = rel
        self.productivity = prod
    }
    
    enum CodingKeys: String, CodingKey {
        case productivity
        case relaxing
    }
}

@objc class worthwhilenessFactors: NSObject, NSCoding, JsonParseable {
    let code: Int
    let plus: Bool
    let minus: Bool
    
    
    enum CodingKeys: String, CodingKey {
        case code
        case plus
        case minus
    }
    
    init(code: Int, plus: Bool, minus: Bool) {
        self.code = code
        self.plus = plus
        self.minus = minus
    }
    
    required convenience init(coder decoder: NSCoder) {
        let code = (decoder.decodeObject(forKey: CodingKeys.code.rawValue) as? Int ?? 0)
        let plus = (decoder.decodeObject(forKey: CodingKeys.plus.rawValue) as? Bool  ?? false)
        let minus = (decoder.decodeObject(forKey: CodingKeys.minus.rawValue) as? Bool ?? false)
        
        self.init(code: code, plus: plus, minus: minus)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.code, forKey: CodingKeys.code.rawValue)
        coder.encode(self.plus, forKey: CodingKeys.plus.rawValue)
        coder.encode(self.minus, forKey: CodingKeys.minus.rawValue)
    }
}

@objc class ValueFromTrip: NSObject,NSCoding, JsonParseable {
    let code: Double
    let value: Double
    
    enum CodingKeys: String, CodingKey {
        case code
        case value
    }
    
    init(code: Double, value: Double) {
        self.code = code
        self.value = value
    }
    
    required convenience init(coder decoder: NSCoder) {
        let code = (decoder.decodeObject(forKey: CodingKeys.code.rawValue) as? Int ?? -1)
        let value = (decoder.decodeObject(forKey: CodingKeys.value.rawValue) as? Int ?? -1)
        
        self.init(code: Double(code), value: Double(value))
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(Int(self.code), forKey: CodingKeys.code.rawValue)
        coder.encode(Int(self.value), forKey: CodingKeys.value.rawValue)
    }
}






