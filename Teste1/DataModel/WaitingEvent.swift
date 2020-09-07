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
import CoreData
import CoreLocation

/*
* FullTripPart consisting in a Waiting Event
* The user is stationary (e.g., waiting for bus)
*/
class WaitingEvent: FullTripPart {
    
    public static let MyEntityName = "WaitingEvent"
    @NSManaged public var score: TransferScored?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WaitingEvent> {
        return NSFetchRequest<WaitingEvent>(entityName: WaitingEvent.MyEntityName)
    }
    
    convenience init(startDate: Date, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: WaitingEvent.MyEntityName, in: context)!
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        self.startDate=startDate
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    @NSManaged public var avLocation: UserLocation?
    
    //MARK:process Functions
    override public func processCloseInformation(){
        super.processCloseInformation()
        self.avLocation = averageLocation(locations: self.getLocationsortedList())
    }
    
    
    //MARK: print functions
    override public func printFinalData() -> String {
        var responseText = ""
        responseText.append("-------------------\n")
        responseText.append("type: Waiting event \n")
        responseText.append(super.printFinalData())
        if(closed){
            responseText.append("Average position: \n")
            responseText.append("latitude:" + (avLocation?.location?.coordinate.latitude.description ?? "0") + "\n")
            responseText.append("longitude:" + (avLocation?.location?.coordinate.longitude.description ?? "0") + " \n")
        }
        return responseText
    }
    
    /*
    * Return a main location for this waiting event
    */
    func averageLocation(locations: [UserLocation]) -> UserLocation{
        var midLocation: UserLocation?
        var distance =  Double(0)
        for loc1 in locations {
            var locDistance = Double(0)
            for loc2 in locations {
                locDistance.add(loc1.location!.distance(from: loc2.location!))
            }
            if distance<locDistance || midLocation == nil {
                midLocation=loc1
                distance=locDistance
            }
        }
        return midLocation!
    }
    
    /*
    * Return distance obtained from the locations
    */
    public func distance() -> Double {
        let locs = getLocationsortedList()
        if locs.count == 0 {
            return Double(0)
        }
        if let first = locs.first?.location,
            let last = locs.last?.location {
            return first.distance(from: last)
        }
        return Double(0)
    }
    
    /*
    * Return mode of transport. Implemented as Transfer.
    */
    override func getModeOftransport() -> Trip.modesOfTransport {
        return Trip.modesOfTransport.transfer
    }

    //MARK: ParseableFunctions
    enum CodingKeysSpec: String, CodingKey {
        case startDate
        case endDate
        case locations
        case avLocationLat
        case avLocationLon
        case type
        case productivityRelaxingRating
        case RelaxingFactors
        case ProductiveFactors
        case ProductiveFactorsText
        case RelaxingFactorsText
        
        case genericActivities
        
        case ProdActivities
        case MindActivities
        case BodyActivities
        
        case wastedTime
        case infrastructureAndServicesFactors
        case comfortAndPleasentFactors
        case gettingThereFactors
        case activitiesFactors 
        case whileYouRideFactors 
        case otherFactor
        case valueFromTrip
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: WaitingEvent.MyEntityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        if  let startDate = try container.decodeIfPresent(Double.self, forKey: .startDate),
            let endDate = try container.decodeIfPresent(Double.self, forKey: .endDate),
            let locations = try container.decodeIfPresent([UserLocation].self, forKey: .locations),
            let avLat = try container.decodeIfPresent(Double.self, forKey: .avLocationLat),
            let avLon = try container.decodeIfPresent(Double.self, forKey: .avLocationLon) {
            
            self.startDate = Date(timeIntervalSince1970: startDate.divided(by: Double(1000)))
            self.endDate = Date(timeIntervalSince1970: endDate.divided(by: Double(1000)))
            let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: avLat, longitude: avLon), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
            self.avLocation = UserLocation.getUserLocation(userLocation: location, context: UserInfo.context!)!
            self.locations = NSSet(array: locations)
        }
    }
    
    /*
     * Encode WaitingEvent to JSON
    */ 
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysSpec.self)
        try container.encode(startDate.timeIntervalSince1970.multiplied(by: Double(1000)), forKey: .startDate)
        try container.encode(endDate?.timeIntervalSince1970.multiplied(by: Double(1000)), forKey: .endDate)
        try container.encode(avLocation?.location?.coordinate.latitude, forKey: .avLocationLat)
        try container.encode(avLocation?.location?.coordinate.longitude, forKey: .avLocationLon)
        try container.encode(getLocationsortedList(), forKey: .locations)
        try container.encode("WaitingEvent", forKey: .type)
        
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
        
        try container.encode(wastedTime, forKey: .wastedTime)
        try container.encode(infrastructureAndServicesFactors ?? [worthwhilenessFactors](), forKey: .infrastructureAndServicesFactors)
        try container.encode(comfortAndPleasentFactors ?? [worthwhilenessFactors](), forKey: .comfortAndPleasentFactors)
        try container.encode(gettingThereFactors ?? [worthwhilenessFactors](), forKey: .gettingThereFactors)
        try container.encode(otherFactor ?? "", forKey: .otherFactor)
        try container.encode(valueFromTrip ?? [ValueFromTrip](), forKey: .valueFromTrip)
    }
    
    /*
    * Create a new waiting event for given startDate
    */
    public static func getWaitingEvent(startDate: Date, context: NSManagedObjectContext) -> WaitingEvent? {
        var we: WaitingEvent?
        UserInfo.ContextSemaphore.wait()
        context.performAndWait {
            we = WaitingEvent(startDate: startDate, context: context)
        }
        
        return we
    }
    
    /*
    * Update scores after answering worthwhileness
    */
    public func answerWorthwileness() {
        let newScores = getScore().answerWorthwileness()
        if let user = MotivUser.getInstance() {
            user.diffPoints(points: newScores)
        }
    }
    
    /*
    * Update scores after answering activities
    */
    public func answerActivities() {
        let newScores = getScore().answerActivities()
        if let user = MotivUser.getInstance() {
            user.diffPoints(points: newScores)
        }
    }
    
    /*
    * Get score of waiting event
    */
    private func getScore() -> TransferScored {
        if self.score == nil {
            self.score = TransferScored.getTripScored()
        }
        return self.score!
    }
    
    /*
    * Get sum of all scores
    */
    public func getScoreSum() -> Double {
        return getScore().getScore()
    }
    
    /*
    * Get Sum for a given campaign
    * parameters:
    * campaignId - Id of given campaign
    */
    public func getScoreSumForCampaign(campaignId: String) -> Double {
        return getScore().getScoreForCampaign(campaignId: campaignId)
    }
    
    /*
    * Get dictionary of scores by campaignID
    */    
    override public func getScoreByCampaign() -> [String: Double] {
        return getScore().getResultScores()
    }
}
