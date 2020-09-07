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
import CoreData
import UIKit

/*
*   Represents a trip part corresponding to one mode of transport.
    variables:
    - distance: trip distance in meters
    - duration: trip duration in seconds
    - avSpeed: average speed in m/s
    - mSpeed: max speed in m/s
    - modeOfTransport: detected mode in (unknown,Stationary,walking,running,automotive,cycling)
    - accelerationMean: Mean of all accelerations on the Trip
    - correctedModeOfTransport: corrected mode of transport
    - realMot: The one that is presented to the user based on the main mode of transport
    - wrongLeg: if leg never happened
    - filteredAcceleration: filtered average accelerations
    - filteredAccelerationBelowThreshold: filtered average accelerations below threshold
    - filteredSpeed: filtered average speed
    - filteredSpeedBelowThreshold: filtered average speed below threshold
    - accuracyMean: GPS accuracy mean
*/
class Trip: FullTripPart {
    
    //MARK:properties
    @NSManaged public var distance: Float                       
    @NSManaged public var duration: Float                     
    @NSManaged public var avSpeed: Float                  
    @NSManaged public var mSpeed: Float                  
    @NSManaged public var modeOfTransport: String?              
    @NSManaged public var accelerationMean: Double              
    @NSManaged public var correctedModeOfTransport: String?     
    @NSManaged var realMot: Double                              
    @NSManaged public var wrongLeg: Bool                       
    
    //UI filled variables start
    @NSManaged public var modeConfirmed: Bool
    //UI filled variables end
    
    @NSManaged var filteredAcceleration: Double
    @NSManaged var filteredAccelerationBelowThreshold: Double
    @NSManaged var filteredSpeed: Double
    @NSManaged var filteredSpeedBelowThreshold: Double
    @NSManaged var accuracyMean: Double
    @NSManaged var correctedModeCode: Double
    @NSManaged var otherMotText: String?
    
    public static let MyEntityName = "Trip"
    public static let SpeedMAxAccuracyThreshold = Double(100) // Threshold for the accuracy to calculate speed
    public static let SpeedFilteredThresholdThreshold = Double(1.08) // Threshold for the minimum speed m/s
    public static let minLocationDistance = Double(5) // in meters
    
    //newFields
    @NSManaged var originLeg: [GeneratedFrom]?
    @NSManaged var wasMerged: Bool
    @NSManaged var wasSplit: Bool
    
    @NSManaged public var score: LegScored?
    
    convenience init(startDate: Date, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: Trip.MyEntityName, in: context)!
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        self.startDate=startDate
        self.correctedModeCode = Double(-1)
    }
    
    public static func getTrip(startDate: Date, context: NSManagedObjectContext) -> Trip? {
        var trip: Trip?
        UserInfo.ContextSemaphore.wait()
        context.performAndWait {
            trip = Trip(startDate: startDate, context: context)
        }
        return trip
    }
    
    /*
    * trip has ended. close trip.
    */
    public override func endTripPart(endLocation: CLLocation){
        super.endTripPart(endLocation: endLocation)
    }
    
    /*
    * Differentiate between Trip and Waiting Event
    */
    override public func isTrip() -> Bool {
        return true
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
        return NSFetchRequest<Trip>(entityName: Trip.MyEntityName)
    }
    
    //MARK: print functions
    override public func printFinalData() -> String {
        var responseText = ""
        responseText.append("-------------------\n")
        responseText.append("type: Leg \n")
        responseText.append(super.printFinalData())
        if(closed) {
            responseText.append("Distance traveled: \(distance.description)m\n")
            responseText.append("Time traveled: \(UserInfo.printHoursMinutesSeconds(seconds: Int(duration)))\n")
            responseText.append("Average speed: " + avSpeed.description + "km/H\n")
            responseText.append("Maximum speed: " + mSpeed.description + "km/H\n")
            
            if (modeOfTransport ?? "") == "stationary" {
                responseText.append("Mode of Transport: train\n")
            } else {
                responseText.append("Mode of Transport: " + (modeOfTransport ?? "") + "\n")
            }
            if (correctedModeOfTransport ?? "").count > 1{
                responseText.append("Corrected mode of transport: \(correctedModeOfTransport!)\n")
            }
            responseText.append("Average Acceleration: " + (accelerationMean.description) + "\n")
            responseText.append("Average Accuracy: " + (accuracyMean.description) + "\n")
            responseText.append("Filtered Acceleration: " + (filteredAcceleration.description) + "\n")
            responseText.append("Acceleration bellow threshold percentage: " + (filteredAccelerationBelowThreshold*100).description + "%\n")
            responseText.append("Filtered average speed: " + filteredSpeed.description + "km/H\n")
            responseText.append("Filtered average speed Bellow th: " + (filteredSpeedBelowThreshold*100).description + "%\n")
            responseText.append("Wrong Leg: \(wrongLeg.description)\n")
        }
        return responseText
    }
    
    /*
    * Get average speed without filtered speeds
    */
    public func getFilteredSpeed(threshold: Double, withLocation: Bool = false) -> (Double,Double) {
        let locations = getLocationsortedList()
        var prevLocation: UserLocation?
        var filteredSpeed = Double(0)
        var NumOfFilteredSpeeds=0
        var NumOfSpeedsProcessed=0
        for loc in locations{
            if (loc.location?.horizontalAccuracy)! > self.accuracyMean {
                continue
            }
            if prevLocation != nil {
                //IF above a certain threshold then we should not compare the speed
                if((prevLocation?.location?.distance(from: loc.location!)) ?? Trip.minLocationDistance < Trip.minLocationDistance && loc != locations.last){
                    continue
                }
                
                NumOfSpeedsProcessed += 1
                let (gpsSpeed,speed) = ProcessLocationData.processSpeed(current: loc.location!, prev: (prevLocation?.location)!)
                if gpsSpeed != nil {
                    if gpsSpeed! > threshold {
                        filteredSpeed.add(gpsSpeed!)
                        NumOfFilteredSpeeds += 1
                    }
                } else if !speed.isZero {
                    if speed > threshold {
                        filteredSpeed.add(speed)
                        NumOfFilteredSpeeds += 1
                    }
                }
            }
            prevLocation=loc
        }
        if NumOfFilteredSpeeds > 0 {
            return (filteredSpeed.divided(by: Double(NumOfFilteredSpeeds)) , Double(NumOfSpeedsProcessed - NumOfFilteredSpeeds).divided(by: Double(NumOfSpeedsProcessed)))
        } else if !withLocation {
            return getFilteredSpeed(threshold: threshold, withLocation: true)
        }
        return (Double(0),Double(0))
    }
    
    /*
    * Get GPS accuracy mean of trip locations
    */
    public func processAccuracyMean() -> Double {
        var accuracyMean = Double(0)
        let locationsArray = getLocationsortedList()
        if locationsArray.count < 1 {
            return Double(0)
        }
        for loc in locationsArray {
            if let location = loc.location {
                accuracyMean.add(location.horizontalAccuracy)
            }
        }
        return accuracyMean.divided(by: Double(locationsArray.count))
    }
    
    /*
    * Get Mode of transport internal text
    */
    public func getTextFromRealMotCode() -> String? {
        if let user = MotivUser.getInstance(),
            let mot = user.getMotFromCode(code: self.realMot) {
            return mot.text
        }
        return nil
    }
    
    /*
    * Get Mode of transport text to show
    */
    public func getMainTextFromRealMotCode() -> String? {
        if let user = MotivUser.getInstance() {
            return user.getMotFromCode(code: user.getMainFromSecondary(secondaryCode: self.realMot))?.text
        }
        
        return nil
    }
    
    //MARK:process Functions
    fileprivate func processLocations(_ locations: [UserLocation], withLocations: Bool = false) {
        var prevLocation: UserLocation?
        avSpeed=Float(0)
        mSpeed=Float(0)
        filteredSpeed = Double(0)
        var speedsCount = 0
        
        var NumOfFilteredSpeeds=0
        var NumOfSpeedsProcessed=0
        let threshold = Trip.SpeedFilteredThresholdThreshold
        
        for loc in locations{
            if (loc.location?.horizontalAccuracy)! > self.accuracyMean * 1.75 {
                continue
            }
            if prevLocation != nil {
                //IF above a certain threshold then we should not compare the speed
                if((prevLocation?.location?.distance(from: loc.location!)) ?? Trip.minLocationDistance < Trip.minLocationDistance && loc != locations.last){
                    continue
                }
                
                NumOfSpeedsProcessed += 1
                //add distance
                distance = distance.advanced(by: Float(loc.location!.distance(from: prevLocation!.location!)))
                let (gpsSpeed,speed) = ProcessLocationData.processSpeed(current: loc.location!, prev: (prevLocation?.location)!)
                if gpsSpeed != nil {
                    if gpsSpeed! < Double(1200) {
                        //averageSpeed
                        avSpeed = avSpeed.advanced(by: Float(gpsSpeed!))
                        if mSpeed.isLess(than: Float(gpsSpeed!)) {
                            mSpeed=Float(gpsSpeed!)
                        }
                        speedsCount+=1
                        
                        //filtered Speed
                        if gpsSpeed! > threshold {
                            filteredSpeed = filteredSpeed.advanced(by: gpsSpeed!)
                            NumOfFilteredSpeeds += 1
                        }
                    }
                } else if !speed.isZero && speed < Double(1200) {
                    //averageSpeed
                    avSpeed.add(Float(speed))
                    if mSpeed.isLess(than: Float(speed)) {
                        mSpeed=Float(speed)
                    }
                    speedsCount+=1
                    
                    //filteredSpeed
                    if speed > threshold {
                        filteredSpeed.add(speed)
                        NumOfFilteredSpeeds += 1
                    }
                }
            }
            prevLocation=loc
        }
        if speedsCount > 0 && NumOfSpeedsProcessed > 0 {
            avSpeed.divide(by: Float(speedsCount))
            if NumOfFilteredSpeeds > 0 {
                filteredSpeed.divide(by: Double(NumOfFilteredSpeeds))
            }
            filteredSpeedBelowThreshold = Double(NumOfSpeedsProcessed - NumOfFilteredSpeeds).divided(by: Double(NumOfSpeedsProcessed))
        } else if !withLocations {
            processLocations(locations,withLocations: true)
        }
    }
    
    public func setRealMots() {
        if let user = MotivUser.getInstance(),
            self.realMot == Double(-1) {
            if closed {
                self.realMot = user.getMainFromSecondary(secondaryCode: user.getMotFromText(text: self.modeOfTransport ?? "")?.motCode ?? Double(0))
            }
        }
    }
    
    /*
    * Perform the closing of this leg.
    */
    override public func processCloseInformation(){
        super.processCloseInformation()
        let locations = getLocationsortedList()
        distance=Float(0)
        duration=Float((endDate?.timeIntervalSince(startDate))!)
        accelerationMean = Double(0)
        accuracyMean = processAccuracyMean()
        
        processLocations(locations)
        UserAcceleration.processAllAccelerationsForLeg(leg: self)
        
        if let user = MotivUser.getInstance() {
            self.realMot = user.getMainFromSecondary(secondaryCode: user.getMotFromText(text: self.modeOfTransport ?? "")?.motCode ?? Double(0))
        } else {
            self.realMot = Double(-1)
        }
    }
    

    /*
    * Get Most Probable Coordinate for splitting
    */
    public func getMostProbableCoordinate(location: CLLocationCoordinate2D) -> CLLocation? {
        let locations = getLocationsortedList()
        let middleLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        var nearest: CLLocation? = nil
        for loc in locations{
            if nearest == nil {
                nearest = loc.location
            } else if let location = loc.location {
                let distance = location.distance(from: middleLocation)
                print("\(distance.description)")
                let nearestDistance = nearest!.distance(from: middleLocation)
                if (distance < nearestDistance) {
                    nearest = location
                }
            }
        }
        //if nearest is first or last do not split Leg
        if let near = nearest,
            let first = locations.first?.location,
            let last = locations.last?.location {
            // first
            if (near.coordinate.latitude == first.coordinate.latitude && near.coordinate.longitude == first.coordinate.longitude) {
                if locations.count > 1 {
                    return locations[1].location
                }
                return nil
            }
            // last
            if (near.coordinate.latitude == last.coordinate.latitude && near.coordinate.longitude == last.coordinate.longitude){
                if locations.count > 1 {
                    return locations[locations.count - 2].location
                }
                return nil
            }
        }
        return nearest
    }
    
    //MARK: ParseableFunctions
    enum CodingKeysSpec: String, CodingKey {
        case startDate
        case endDate
        case locations
        case distance
        case duration
        case avSpeed
        case mSpeed
        case modeOfTransport
        case detectedModeOfTransport
        case correctedModeOfTransport
        case accelerationMean
        case type
        case filteredAcceleration
        case filteredAccelerationBelowThreshold
        case filteredSpeed
        case filteredSpeedBelowThreshold
        case accuracyMean
        case wrongLeg
        case accelerations
        case activityList
        case didCorrectModeOfTRansport
        case productivityRelaxingRating
        case RelaxingFactors
        case ProductiveFactors
        case ProductiveFactorsText
        case RelaxingFactorsText
        
        case genericActivities
        
        case ProdActivities
        case MindActivities
        case BodyActivities
        
        case trueDistance
        case wasMerged
        case wasSplit
        
        case wastedTime
        case infrastructureAndServicesFactors
        case comfortAndPleasentFactors
        case gettingThereFactors
        case activitiesFactors 
        case whileYouRideFactors 
        
        case otherFactor
        case valueFromTrip
        case otherMotText
    }
    
    /*
    * Check if leg was split
    */
    func splittedFromLeg(parentLeg: Trip) {
        var currentLegDistance = Double(self.distance)
        if let originLegs = parentLeg.originLeg {
            // parent leg is not the original 
            for origin in originLegs {
                let minDistance = min(currentLegDistance, origin.distance)
                self.originLeg?.append(GeneratedFrom.getGeneratedFrom(distance: minDistance, modeOfTransport: origin.modeOfTransport)!)
                
                currentLegDistance.subtract(minDistance)
                if currentLegDistance == 0 {
                    // resulting leg done
                    return
                }
            }
        } else {
            // parent leg is the original leg
            self.originLeg?.append(GeneratedFrom.getGeneratedFrom(distance: currentLegDistance, modeOfTransport: parentLeg.realMot)!)
        }
        wasSplit = true
    }
    
    /*
    * Check if leg was merged
    */
    func mergedFromLegs(parentParts: [FullTripPart]) {
        for part in parentParts {
            switch part {
            case let leg as Trip:
                if let origins = leg.originLeg {
                    var addedFirst = false
                    if let selfOrigin = self.originLeg,
                        let last = selfOrigin.last,
                        let lastLegOrigin = origins.first,
                        last.modeOfTransport == lastLegOrigin.modeOfTransport {
                        last.distance.add(lastLegOrigin.distance)
                        addedFirst = true
                    }
                    
                    for origin in origins {
                        if !(origin == origins.first && addedFirst) {
                            self.originLeg?.append(origin)
                        }
                    }
                } else {
                    if let selfOrigin = self.originLeg,
                        let last = selfOrigin.last,
                        last.modeOfTransport == leg.realMot {
                        
                        last.distance.add(Double(leg.distance))
                    
                    } else {
                        self.originLeg?.append(GeneratedFrom.getGeneratedFrom(distance: Double(leg.distance), modeOfTransport: leg.realMot)!)
                    }
                }
                break
            default:
                break
            }
        }
        wasMerged = true
    }
    
    /*
    * Check if leg was merged with some waiting event
    */
    func mergedWithWE() {
        if  let origins = self.originLeg,
            let lastOrigin = origins.last {
            
            var distanceFromPrevious = Double(0)
            
            for origin in origins {
                if origin != lastOrigin {
                    distanceFromPrevious.add(origin.distance)
                }
            }
            
            lastOrigin.distance = Double(Double(self.distance) - distanceFromPrevious)
        }
        wasMerged = true
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
        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        if  let startDate = try container.decodeIfPresent(Double.self, forKey: .startDate),
            let endDate = try container.decodeIfPresent(Double.self, forKey: .endDate),
            let locations = try container.decodeIfPresent([UserLocation].self, forKey: .locations),
            let distance = try container.decodeIfPresent(Float.self, forKey: .distance),
            let duration = try container.decodeIfPresent(Float.self, forKey: .duration),
            let avSpeed = try container.decodeIfPresent(Float.self, forKey: .avSpeed),
            let modeOfTransport = try container.decodeIfPresent(Int.self, forKey: .modeOfTransport),
            let mSpeed = try container.decodeIfPresent(Float.self, forKey: .mSpeed),
            let accelerationMean = try container.decodeIfPresent(Double.self, forKey: .accelerationMean),
            let wrongLeg = try container.decodeIfPresent(Bool.self, forKey: .wrongLeg),
            let filteredAcceleration = try container.decodeIfPresent(Double.self, forKey: .filteredAcceleration),
            let filteredAccelerationBelowThreshold = try container.decodeIfPresent(Double.self, forKey: .filteredAccelerationBelowThreshold),
            let filteredSpeed = try container.decodeIfPresent(Double.self, forKey: .filteredSpeed),
            let filteredSpeedBelowThreshold = try container.decodeIfPresent(Double.self, forKey: .filteredSpeedBelowThreshold),
            let accuracyMean = try container.decodeIfPresent(Double.self, forKey: .accuracyMean),
            let accelerations = try container.decodeIfPresent([UserAcceleration].self, forKey: .accelerations) {
            
            self.startDate = Date(timeIntervalSince1970: startDate.divided(by: Double(1000)))
            self.endDate = Date(timeIntervalSince1970: endDate.divided(by: Double(1000)))
            self.locations = NSSet(array: locations)
            self.distance = distance
            self.duration = duration
            
            var modeOfTRansport=""
            switch modeOfTransport {
            case modesOfTransport.automotive.rawValue:
                modeOfTRansport = "automotive"
            case modesOfTransport.cycling.rawValue:
                modeOfTRansport = "cycling"
            case modesOfTransport.walking.rawValue:
                modeOfTRansport = "walking"
            case modesOfTransport.unknown.rawValue:
                modeOfTRansport = "unknown"
            case modesOfTransport.stationary.rawValue:
                modeOfTRansport = "stationary"
            default:
                modeOfTRansport = "unknown"
            }
            
            self.modeOfTransport = modeOfTRansport
            self.avSpeed = avSpeed
            self.mSpeed = mSpeed
            self.closed = true
            self.accelerationMean = accelerationMean
            self.wrongLeg = wrongLeg
            self.filteredAcceleration = filteredAcceleration
            self.filteredAccelerationBelowThreshold = filteredAccelerationBelowThreshold
            self.filteredSpeed = filteredSpeed
            self.filteredSpeedBelowThreshold = filteredSpeedBelowThreshold
            self.accuracyMean = accuracyMean
        }
    }
    
    public func getActivityAndDetectedModeOfTRansport(_ modeOfTRansport: inout Int, _ DetectedModeOfTRansport: inout Int) {
        switch modeOfTransport {
        case ActivityClassfier.AUTOMOTIVE, ActivityClassfier.CAR:
            modeOfTRansport = modesOfTransport.automotive.rawValue
            DetectedModeOfTRansport = modesOfTransport.Car.rawValue
        case ActivityClassfier.CYCLING:
            modeOfTRansport = modesOfTransport.cycling.rawValue
            DetectedModeOfTRansport = modesOfTransport.cycling.rawValue
        case ActivityClassfier.WALKING, ActivityClassfier.RUNNING:
            modeOfTRansport = modesOfTransport.walking.rawValue
            DetectedModeOfTRansport = modesOfTransport.walking.rawValue
        case ActivityClassfier.STATIONARY:
            modeOfTRansport = modesOfTransport.stationary.rawValue
            DetectedModeOfTRansport = modesOfTransport.Train.rawValue
        case ActivityClassfier.BUS:
            modeOfTRansport = modesOfTransport.Bus.rawValue
            DetectedModeOfTRansport = modesOfTransport.Bus.rawValue
        case ActivityClassfier.TRAIN:
            modeOfTRansport = modesOfTransport.Train.rawValue
            DetectedModeOfTRansport = modesOfTransport.Train.rawValue
        case ActivityClassfier.TRAM:
            modeOfTRansport = modesOfTransport.Tram.rawValue
            DetectedModeOfTRansport = modesOfTransport.Tram.rawValue
        case ActivityClassfier.FERRY:
            modeOfTRansport = modesOfTransport.Ferry.rawValue
            DetectedModeOfTRansport = modesOfTransport.Ferry.rawValue
        case ActivityClassfier.METRO:
            modeOfTRansport = modesOfTransport.Tram.rawValue
            DetectedModeOfTRansport = modesOfTransport.Tram.rawValue
        case ActivityClassfier.PLANE:
            modeOfTRansport = modesOfTransport.Plane.rawValue
            DetectedModeOfTRansport = modesOfTransport.Plane.rawValue
        default:
            modeOfTRansport = modesOfTransport.unknown.rawValue
            DetectedModeOfTRansport = modesOfTransport.unknown.rawValue
        }
    }
    
    public func getFinalModeOfTRansport() -> Int {
        var modeOfTRansport = 0
        var DetectedModeOfTRansport = 0
        getActivityAndDetectedModeOfTRansport(&modeOfTRansport, &DetectedModeOfTRansport)
        return getModeOfTRansportID(DetectedModeOfTRansport: DetectedModeOfTRansport)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysSpec.self)
        try container.encode(startDate.timeIntervalSince1970.multiplied(by: Double(1000)), forKey: .startDate)
        try container.encode(endDate?.timeIntervalSince1970.multiplied(by: Double(1000)), forKey: .endDate)
        try container.encode(distance, forKey: .distance)
        try container.encode(duration, forKey: .duration)
        try container.encode(avSpeed, forKey: .avSpeed)
        try container.encode(mSpeed, forKey: .mSpeed)
        var modeOfTRansport = 0
        var DetectedModeOfTRansport = 0
        getActivityAndDetectedModeOfTRansport(&modeOfTRansport, &DetectedModeOfTRansport)
        try container.encode(modeOfTRansport, forKey: .modeOfTransport)
        try container.encode(DetectedModeOfTRansport, forKey: .detectedModeOfTransport)
        
        try container.encode(getLocationsortedList(), forKey: .locations)
        try container.encode(accelerationMean, forKey: .accelerationMean)
        try container.encode("Trip", forKey: .type)
        try container.encode(wrongLeg, forKey: .wrongLeg)
        try container.encode(filteredAcceleration, forKey: .filteredAcceleration)
        try container.encode(filteredAccelerationBelowThreshold, forKey: .filteredAccelerationBelowThreshold)
        try container.encode(filteredSpeed, forKey: .filteredSpeed)
        try container.encode(filteredSpeedBelowThreshold, forKey: .filteredSpeedBelowThreshold)
        try container.encode(accuracyMean, forKey: .accuracyMean)
        let accelerations = UserAcceleration.getAccelerationList(sDate: self.startDate, eDate: self.endDate!)
        try container.encode(accelerations, forKey: .accelerations)
        let activities = ProcessActivityData.getActivitiesList(sDate: self.startDate, eDate: self.endDate!)
        try container.encode(activities, forKey: .activityList)
        let coorrected = getModeOfTRansportID(DetectedModeOfTRansport: DetectedModeOfTRansport)
        try container.encode(coorrected, forKey: .correctedModeOfTransport)
        let rating = RPTripRating(rel: Int(self.relaxingScore), prod: Int(self.productivityScore))
        try container.encode(rating, forKey: .productivityRelaxingRating)
        let relaxingfactors = self.relaxingCDValues.allObjects as! [ComfortDiscomfortValues]
        try container.encode(relaxingfactors, forKey: .RelaxingFactors)
        let productivefactors = self.productiveCDValues.allObjects as! [ComfortDiscomfortValues]
        try container.encode(productivefactors, forKey: .ProductiveFactors)
        try container.encode(productiveFactorText, forKey: .ProductiveFactorsText)
        try container.encode(relaxingFactorText, forKey: .RelaxingFactorsText)
        let (pa,pm,pb) = LegsToSend.getActivities(part: self)
        try container.encode(pa, forKey: .genericActivities)
        try container.encode(self.getTrueDistance(), forKey: .trueDistance)
        try container.encode(wasMerged, forKey: .wasMerged)
        try container.encode(wasSplit, forKey: .wasSplit)
        
        try container.encode(wastedTime, forKey: .wastedTime)
        try container.encode(infrastructureAndServicesFactors ?? [worthwhilenessFactors](), forKey: .infrastructureAndServicesFactors)
        try container.encode(comfortAndPleasentFactors ?? [worthwhilenessFactors](), forKey: .comfortAndPleasentFactors)
        try container.encode(gettingThereFactors ?? [worthwhilenessFactors](), forKey: .gettingThereFactors)
        try container.encode(otherFactor ?? "", forKey: .otherFactor)
        try container.encode(valueFromTrip ?? [ValueFromTrip](), forKey: .valueFromTrip)
        try container.encode(otherMotText ?? "", forKey: .otherMotText)
    }
    
    override func getModeOftransport() -> Trip.modesOfTransport {
        return Trip.modesOfTransport(rawValue: Int(realMot))!
    }
    
    /*
    * Get true distance. If leg was split, get correctly detected distance.
    */
    func getTrueDistance() -> Double {
        var modeOfTRansport = 0
        var DetectedModeOfTRansport = 0
        getActivityAndDetectedModeOfTRansport(&modeOfTRansport, &DetectedModeOfTRansport)
        
        var computedTrueDistance = 0.0
        if let generatedLegs = self.originLeg {
            for gf in generatedLegs {
                if let user = MotivUser.getInstance(),
                    gf.modeOfTransport == self.realMot ?? user.getMotFromText(text: self.correctedModeOfTransport ?? "")?.motCode {
                    computedTrueDistance =  Double(self.distance)
                }
            }
        } else if let user = MotivUser.getInstance(),
            Double(DetectedModeOfTRansport) == self.realMot ?? user.getMotFromText(text: self.correctedModeOfTransport ?? "")?.motCode {
            computedTrueDistance = Double(self.distance)
        }
        return computedTrueDistance
    }
    
    public func getModeOfTRansportID(DetectedModeOfTRansport: Int) -> Int {
        var coorrected = modesOfTransport.automotive.rawValue
        switch correctedModeOfTransport ?? "" {
        case ActivityClassfier.WALKING:
            coorrected = modesOfTransport.walking.rawValue
            break
        case ActivityClassfier.RUNNING:
            coorrected = modesOfTransport.running.rawValue
            break
        case ActivityClassfier.AUTOMOTIVE:
            coorrected = modesOfTransport.automotive.rawValue
            break
        case ActivityClassfier.CAR:
            coorrected = modesOfTransport.Car.rawValue
            break
        case ActivityClassfier.CYCLING:
            coorrected = modesOfTransport.cycling.rawValue
            break
        case ActivityClassfier.STATIONARY:
            coorrected = modesOfTransport.stationary.rawValue
            break
        case ActivityClassfier.BUS:
            coorrected = modesOfTransport.Bus.rawValue
            break
        case ActivityClassfier.TRAIN:
            coorrected = modesOfTransport.Train.rawValue
            break
        case ActivityClassfier.METRO:
            coorrected = modesOfTransport.Subway.rawValue
            break
        case ActivityClassfier.TRAM:
            coorrected = modesOfTransport.Tram.rawValue
            break
        case ActivityClassfier.FERRY:
            coorrected = modesOfTransport.Ferry.rawValue
            break
        case ActivityClassfier.PLANE:
            coorrected = modesOfTransport.Plane.rawValue
            break
        case ActivityClassfier.UNKNOWN:
            coorrected = DetectedModeOfTRansport
            break
        default:
            //            coorrected = modesOfTransport.unknown.rawValue
            coorrected = DetectedModeOfTRansport
        }
        return coorrected
    }
    
    
    public enum modesOfTransport: Int {
        case transfer = -1
        case automotive = 0, cycling = 1, walking = 7, unknown = 4, stationary = 3, running = 8
        case Car = 9, Train = 10, Tram = 11, Subway = 12, Ferry = 13, Plane = 14, Bus = 15
        case electricBike = 16, bikeSharing = 17, microScooter = 18, skate = 19, motorcycle = 20, moped = 21, carPassenger = 22, taxi = 23, rideHailing = 24, carSharing = 25, carpooling = 26, busLongDistance = 27, highSpeedTrain = 28, other = 29, otherPublic = 30, otherActive = 31, otherPrivate = 32, intercityTrain = 33, wheelChair = 34, cargoBike = 35, carSharingPassenger = 36, electricWheelchair = 37
    }
    
    static public func getModeOfTransportById(id: Int) -> Trip.modesOfTransport {
        switch id {
        case -1:
            return Trip.modesOfTransport.transfer
        case 0:
            return Trip.modesOfTransport.automotive
        case 1:
            return Trip.modesOfTransport.cycling
        case 3:
            return Trip.modesOfTransport.stationary
        case 4:
            return Trip.modesOfTransport.unknown
        case 7:
            return Trip.modesOfTransport.walking
        case 8:
            return Trip.modesOfTransport.running
        case 9:
            return Trip.modesOfTransport.Car
        case 10:
            return Trip.modesOfTransport.Train
        case 11:
            return Trip.modesOfTransport.Tram
        case 12:
            return Trip.modesOfTransport.Subway
        case 13:
            return Trip.modesOfTransport.Ferry
        case 14:
            return Trip.modesOfTransport.Plane
        case 15:
            return Trip.modesOfTransport.Bus
        case 16:
            return Trip.modesOfTransport.electricBike
        case 17:
            return Trip.modesOfTransport.bikeSharing
        case 18:
            return Trip.modesOfTransport.microScooter
        case 19:
            return Trip.modesOfTransport.skate
        case 20:
            return Trip.modesOfTransport.motorcycle
        case 21:
            return Trip.modesOfTransport.moped
        case 22:
            return Trip.modesOfTransport.carPassenger
        case 23:
            return Trip.modesOfTransport.taxi
        case 24:
            return Trip.modesOfTransport.rideHailing
        case 25:
            return Trip.modesOfTransport.carSharing
        case 26:
            return Trip.modesOfTransport.carpooling
        case 27:
            return Trip.modesOfTransport.busLongDistance
        case 28:
            return Trip.modesOfTransport.highSpeedTrain
        case 29:
            return Trip.modesOfTransport.other
        case 30:
            return Trip.modesOfTransport.otherPublic
        case 31:
            return Trip.modesOfTransport.otherActive
        case 32:
            return Trip.modesOfTransport.otherPrivate
        case 33:
            return Trip.modesOfTransport.intercityTrain
        case 34:
            return Trip.modesOfTransport.wheelChair
        case 35:
            return Trip.modesOfTransport.cargoBike
        case 36:
            return Trip.modesOfTransport.carSharingPassenger
        case 36:
            return Trip.modesOfTransport.electricWheelchair
        default:
            return Trip.modesOfTransport.walking
        }
    }
    
    /*
    * Parameter: mot
    * return Label to show and Image to show
    */
    static public func getLabelAndPictureFromModeOfTRansport(mot: modesOfTransport) -> (String, UIImage) {
        return (Trip.getTextModeToShow(forMode: mot.rawValue),Trip.getImageModeToShow(forMode: mot.rawValue) )
    }
    
    /*
    * return transport text to show
    */
    public func getTextModeToShow() -> String {
        let motText = motToCell.getTextForModeOfTransport(mode: Int(self.realMot), otherText: self.otherMotText ?? "")
        let Mode = NSLocalizedString(motText, comment: "Mode of Transport")
        return Mode == "" ? self.correctedModeOfTransport ?? "" : Mode
    }
    
    /*
    * return transport text to show for some mode
    */
    static public func getTextModeToShow(forMode: Int) -> String {
        let motText = motToCell.getTextForModeOfTransport(mode: forMode, otherText: "Other")
        return motText
    }
    
    /*
    * return transport image to show
    */
    public func getImageModeToShow() -> UIImage {
        return motToCell.getImageForModeOfTransport(mode: Int(self.realMot))!
    }
    
        /*
    * return transport image to show for some mode
    */
    static public func getImageModeToShow(forMode: Int) -> UIImage {
        return motToCell.getImageForModeOfTransport(mode: forMode)!
    }
    
    public func getImageFadedModeToShow() -> UIImage {
        return motToCell.getImageFadedForModeOfTransport(mode: Int(self.realMot))!
    }

    /*
    * Check if user was stationary
    */
    public func isStill() -> Bool {
        return ActivityClassfier.STATIONARY == self.modeOfTransport
    }
    
    /*
    * Update user score after answering worthwhileness
    */
    public func answerWorthwileness() {
        let newScores = getScore().answerWorthwileness()
        if let user = MotivUser.getInstance() {
            user.diffPoints(points: newScores)
        }
    }
    
    /*
    * Update user score after inserting activities while travelling
    */
    public func answerActivities() {
        let newScores = getScore().answerActivities()
        if let user = MotivUser.getInstance() {
            user.diffPoints(points: newScores)
        }
    }
    
    /*
    * Update user score after answering the correct mode
    */
    public func answerMode() {
        let newScores = getScore().answerMode()
        if let user = MotivUser.getInstance() {
            user.diffPoints(points: newScores)
        }
    }
    
    /*
    * Get scores associated with this leg
    */
    private func getScore() -> LegScored {
        if self.score == nil {
            self.score = LegScored.getLegScored()
        }
        return self.score!
    }
    
    /*
    * Get sums of all the scores
    */
    public func getScoreSum() -> Double {
        return getScore().getScore()
    }
    
    /*
    * Get sums of all the scores for some campaign
    */
    public func getScoreSumForCampaign(campaignId: String) -> Double {
        return getScore().getScoreForCampaign(campaignId: campaignId)
    }
    
    /*
    * Return dictionary of scores by campaign
    */
    override public func getScoreByCampaign() -> [String: Double] {
        return getScore().getResultScores()
    }
}
