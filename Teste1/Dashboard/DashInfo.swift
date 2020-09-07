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

/*
* DashInfo contains the information that represents the user's habits in a given time period.
*/
class DashInfo: NSManagedObject {
    
    @NSManaged public var calories: Double
    @NSManaged public var co2Footprint: Double
    @NSManaged public var distance: Double
    @NSManaged public var duration: Double
    @NSManaged public var enjoymentWorth: Double
    @NSManaged public var fitnessWorth: Double
    @NSManaged public var productiveWorth: Double
    @NSManaged public var totalWorth: Double
    @NSManaged public var type: Double
    @NSManaged public var year: Double
    @NSManaged public var activitiesInfo: [String: Double]
    
    public static let entityName = "DashInfo"
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DashInfo> {
        return NSFetchRequest<DashInfo>(entityName: DashInfo.entityName)
    }
    
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: DashInfo.entityName, in: context)!
        self.init(entity: entity, insertInto: context)

        self.calories = Double(0)
        self.co2Footprint = Double(0)
        self.distance = Double(0)
        self.duration = Double(0)
        self.enjoymentWorth = Double(0)
        self.fitnessWorth = Double(0)
        self.productiveWorth = Double(0)
        self.totalWorth += Double(0)
        self.type = Double(0)
        self.year = Double(0)
        self.activitiesInfo = [String: Double]()
    }
    
    public static func getDashInfo(context: NSManagedObjectContext) -> DashInfo? {
        var Info: DashInfo?
        UserInfo.ContextSemaphore.wait()
        UserInfo.context?.performAndWait {
            Info = DashInfo(context: context)
        }
        UserInfo.ContextSemaphore.signal()
        return Info
    }
    
    /**
    * Merge results from other DashInfo
    - parameter di: DashInfo object with stats to merge
    */
    func joinFrom(di: DashInfo) {
        self.calories += di.calories
        self.co2Footprint += di.co2Footprint
        self.duration += di.duration
        self.enjoymentWorth = mergePercentages(perc1: self.enjoymentWorth, time1: self.duration, perc2: di.enjoymentWorth, time2: di.duration)
        self.fitnessWorth = mergePercentages(perc1: self.fitnessWorth, time1: self.duration, perc2: di.fitnessWorth, time2: di.duration)
        self.productiveWorth = mergePercentages(perc1: self.productiveWorth, time1: self.duration, perc2: di.productiveWorth, time2: di.duration)
        self.totalWorth = mergePercentages(perc1: self.totalWorth, time1: self.duration, perc2: di.totalWorth, time2: di.duration)
        self.distance += di.distance
        self.activitiesInfo.merge(di.activitiesInfo) { (d1, d2) -> Double in
            return d1 + d2
        }
    }

    /**
    * Merge two percentages, considering the time window. 
    */
    private func mergePercentages(perc1: Double, time1: Double, perc2: Double, time2: Double) -> Double {
        let value1 = perc1 * time1
        let value2 = perc2 * time2
        
        return (value1 + value2)/(time1 + time2)
    }
    
    /**
    * Updates the DashInfo information with one trip
    - parameter ft: FullTrip with data to add to stats
    */
    func addInfoFromFT(ft: FullTrip) {
        self.distance += Double(ft.distance).divided(by: 1000)
        
        var intermediateProdWorth = Double(0)
        var intermediateEnjWorth = Double(0)
        var intermediateFitWorth = Double(0)
        var intermediateTotalWorth = Double(0)
        
        for part in ft.getTripPartsortedList() {
            //calories
            self.calories += DashInfo.getCaloriesFromPart(part: part)
            //carbon
            self.co2Footprint += DashInfo.getCO2FromPart(part: part)
            //Worthwhileness
            intermediateProdWorth += getProductivityWorthFromPart(part: part)
            intermediateEnjWorth += getEnjoymentWorthFromPart(part: part)
            intermediateFitWorth += getFitnessWorthFromPart(part: part)
            intermediateTotalWorth += getTotalWorthFromPart(part: part)
            
            self.activitiesInfo.merge(getActivitiesFrom(part: part)) { (d1, d2) -> Double in
                return d1 + d2
            }
        }
        
        let plusDuration = Double(ft.duration).divided(by: 60)
        
        intermediateProdWorth = intermediateProdWorth / plusDuration
        intermediateEnjWorth = intermediateEnjWorth / plusDuration
        intermediateFitWorth = intermediateFitWorth / plusDuration
        intermediateTotalWorth = intermediateTotalWorth / plusDuration
        
        self.enjoymentWorth = mergePercentages(perc1: self.enjoymentWorth, time1: self.duration, perc2: intermediateProdWorth, time2: plusDuration)
        self.fitnessWorth = mergePercentages(perc1: self.fitnessWorth, time1: self.duration, perc2: intermediateEnjWorth, time2: plusDuration)
        self.productiveWorth = mergePercentages(perc1: self.productiveWorth, time1: self.duration, perc2: intermediateFitWorth, time2: plusDuration)
        self.totalWorth = mergePercentages(perc1: self.totalWorth, time1: self.duration, perc2: intermediateTotalWorth, time2: plusDuration)
        self.duration += plusDuration
    }
    
    // calculating funtions
    
    /**
    * Get calories per kilometer for a given trip
    - parameter part: FullTripPart to infer calories spent
    */
    static func getCaloriesFromPart(part: FullTripPart) -> Double {
        if let leg = part as? Trip {
            var calsPerKms = 0
            switch leg.getModeOftransport() {
            case .electricBike:
                calsPerKms = 13
            case .cycling, .bikeSharing, .skate:
                calsPerKms = 26
            case .cargoBike:
                calsPerKms = 39
            case .walking, .wheelChair:
                calsPerKms = 45
            case .running:
                calsPerKms = 90
            default:
                break
            }
            return Double(leg.distance.divided(by: 1000).multiplied(by: Float(calsPerKms)))
        }
        return 0
    }
    
    /**
    * Get calories per kilometer depending on the transport mode
    - parameter mode: code of the transport mode used
    */
    static func getCaloriesFromMode(mode: Trip.modesOfTransport) -> Int {
        var calsPerKms = 0
        switch mode {
        case .electricBike:
            calsPerKms = 13
        case .cycling, .bikeSharing, .skate:
            calsPerKms = 26
        case .cargoBike:
            calsPerKms = 39
        case .walking, .wheelChair:
            calsPerKms = 45
        case .running:
            calsPerKms = 90
        default:
            break
        }
        return calsPerKms
    }
    
    /**
    * Get CO2 per kilometer for a given trip
    - parameter part: FullTripPart to infer CO2 spent
    */
    static func getCO2FromPart(part: FullTripPart) -> Double {
        if let leg = part as? Trip {
            var carbonPerKm = 0.0
            switch leg.getModeOftransport() {
            case .electricBike:
                carbonPerKm = 6.0
            case .microScooter:
                carbonPerKm = 12.0
            case .Subway, .Tram, .Train, .intercityTrain:
                carbonPerKm = 14.0
            case .electricWheelchair:
                carbonPerKm = 15.0
            case .highSpeedTrain:
                carbonPerKm = 25.0
            case .moped:
                carbonPerKm = 60.0
            case .Bus, .busLongDistance:
                carbonPerKm = 68.0
            case .carPassenger, .carSharingPassenger, .motorcycle:
                carbonPerKm = 80.0
            case .rideHailing:
                carbonPerKm = 100.0
            case .Car, .carSharing:
                carbonPerKm = 120.0
            case .Ferry:
                carbonPerKm = 256.5
            case .Plane:
                carbonPerKm = 285
            default:
                break
            }
            return Double(leg.distance.divided(by: 1000).multiplied(by: Float(carbonPerKm)))
        }
        return 0
    }
    
    /**
    * Get CO2 per kilometer depending on the transport mode
    - parameter mode: code of the transport mode used
    */
    static func getCO2FromMode(mode: Trip.modesOfTransport) -> Double {

        var carbonPerKm = 0.0
        switch mode {
        case .electricBike:
            carbonPerKm = 6.0
        case .microScooter:
            carbonPerKm = 12.0
        case .Subway, .Tram, .Train, .intercityTrain:
            carbonPerKm = 14.0
        case .electricWheelchair:
            carbonPerKm = 15.0
        case .highSpeedTrain:
            carbonPerKm = 25.0
        case .moped:
            carbonPerKm = 60.0
        case .Bus, .busLongDistance:
            carbonPerKm = 68.0
        case .carPassenger, .carSharingPassenger, .motorcycle:
            carbonPerKm = 80.0
        case .rideHailing:
            carbonPerKm = 100.0
        case .Car, .carSharing:
            carbonPerKm = 120.0
        case .Ferry:
            carbonPerKm = 256.5
        case .Plane:
            carbonPerKm = 285
        default:
            break
        }
        return carbonPerKm
    }
    
    //worthwhilenessFactors
    
    /**
    * Get Worthwhileness score for a trip (Waiting Event or Trip)
    - parameter part: FullTripPart to infer worthwhileness score
    */
    func getProductivityWorthFromPart(part: FullTripPart) -> Double {
        if let durationMinutes = part.endDate?.timeIntervalSince(part.startDate).divided(by: 60) {
            switch part {
            case let leg as Trip:
                let w = worthwhilenessForPEF(type: .prod, mode: leg.getModeOftransport())
                return durationMinutes * w
            default: // WE(transfer)
                let w = worthwhilenessForPEF(type: .prod, mode: .transfer)
                return durationMinutes * w
            }
        }
        return 0
    }
    
    /**
    * Get Enjoyment score for a trip (Waiting Event or Trip)
    - parameter part: FullTripPart to infer enjoyment score
    */
    func getEnjoymentWorthFromPart(part: FullTripPart) -> Double {
        if let durationMinutes = part.endDate?.timeIntervalSince(part.startDate).divided(by: 60) {
            switch part {
            case let leg as Trip:
                let w = worthwhilenessForPEF(type: .enj, mode: leg.getModeOftransport())
                return durationMinutes * w
            default: // WE(transfer)
                let w = worthwhilenessForPEF(type: .enj, mode: .transfer)
                return durationMinutes * w
            }
        }
        return 0
    }
    
    /**
    * Get Fitness score for a trip (Waiting Event or Trip)
    - parameter part: FullTripPart to infer fitness score
    */
    func getFitnessWorthFromPart(part: FullTripPart) -> Double {
        if let durationMinutes = part.endDate?.timeIntervalSince(part.startDate).divided(by: 60) {
            switch part {
            case let leg as Trip:
                let w = worthwhilenessForPEF(type: .fit, mode: leg.getModeOftransport())
                return durationMinutes * w
            default: // WE(transfer)
                let w = worthwhilenessForPEF(type: .fit, mode: .transfer)
                return durationMinutes * w
            }
        }
        return 0
    }
    
    /**
    * Get Total Worth score for a trip (Waiting Event or Trip)
    - parameter part: FullTripPart to infer score
    */
    func getTotalWorthFromPart(part: FullTripPart) -> Double {
        if let durationMinutes = part.endDate?.timeIntervalSince(part.startDate).divided(by: 60) {
            switch part {
            case let leg as Trip:
                let w = worthwhilenessTotalValue(mode: leg.getModeOftransport())
                return durationMinutes * w
            default: // WE(transfer)
                let w = worthwhilenessTotalValue(mode: .transfer)
                return durationMinutes * w
            }
        }
        return 0
    }
    
    /**
    * Get Map of Activities performed during the trip and their corresponding duration
    - parameter part: FullTripPart to obtain activities
    */
    func getActivitiesFrom(part: FullTripPart) -> [String: Double] {
        var activities = [String: Double]()
        let acts = part.legUserActivities ?? [String]()
        if let durationMinutes = part.endDate?.timeIntervalSince(part.startDate).divided(by: 60) {
            for act in acts {
                activities[act] = durationMinutes.divided(by: Double(acts.count))
            }
        }
        return activities
    }
    
    //auxiliar functions for worthwhileness factors
    enum typeOfCalculation {
        case prod, enj, fit
    }
    
    
    /**
    * Get the factor c for (prod, enj, fitness)
    */
    func getWorthwhilenessWeightC() -> (Double, Double, Double) {
        if let user = MotivUser.getInstance() {
            return (Double(user.prodValue),Double(user.relValue),Double(user.actValue))
        }
        return (0, 0, 0)
    }
    
    /**
    * Get the default weight of worthwhileness score for mode
    */
    func getWorthwhilenessWeightforMode(mode: Trip.modesOfTransport) -> (Double, Double, Double) {
        if let user = MotivUser.getInstance() {
            for preferedMot in user.getPreferedMots() {
                if mode.rawValue == Int(preferedMot.mot) {
                    return (Double(preferedMot.motsProd), Double(preferedMot.motsRelax), Double(preferedMot.motsFit))
                }
            }
        }
        return getWorthwhilenessDefaultWeightforMode(mode: mode)
    }
    
    /**
    * Get weight of worthwhileness score for mode
    - parameter mode: mode of transport code
    */
    func getWorthwhilenessDefaultWeightforMode(mode: Trip.modesOfTransport) -> (Double, Double, Double) {
        
        switch mode {
        case .Subway, .Train:
            return (70, 70, 10)
        case .Tram:
            return (50, 60, 10)
        case .Bus, .busLongDistance:
            return (40, 50, 10)
        case .intercityTrain, .highSpeedTrain:
            return (80, 80, 10)
        case .Ferry:
            return (60, 70, 10)
        case .Plane:
            return (60, 50, 0)
        case .walking, .wheelChair:
            return (20, 70, 90)
        case .running:
            return (10, 70, 100)
        case .cycling, .electricBike, .cargoBike, .bikeSharing, .microScooter, .skate:
            return (10, 70, 80)
        case .Car, .carSharing:
            return (20, 40, 0)
        case .carPassenger, .carSharingPassenger, .taxi:
            return (40, 40, 0)
        case .moped, .motorcycle:
            return (0, 40, 0)
        case .electricWheelchair:
            return (20, 70, 10)
        default:
            break
        }
        return (0, 0, 0)
    }
    
    /**
    * Get worthwhileness weight for productivity, enjoyment, fitness
    * - parameter type: code (prod, enj, fit)
    * - mode: mode of transport
    */
    func worthwhilenessForPEF(type: typeOfCalculation, mode: Trip.modesOfTransport) -> Double {
        let weights = self.getWorthwhilenessWeightforMode(mode: mode)
        switch type {
        case .prod:
            return weights.0/100.0
        case .enj:
            return weights.1/100.0
        case .fit:
            return weights.2/100.0
        }
    }
    
    /**
    * Calculate worthwhileness total value
    * - mode: mode of transport
    */
    func worthwhilenessTotalValue(mode: Trip.modesOfTransport) -> Double {
        let weights = self.getWorthwhilenessWeightforMode(mode: mode)
        let C = self.getWorthwhilenessWeightC()
        let top = (weights.0/100.0 * C.0/100.0) + (weights.1/100.0 * C.1/100.0) + (weights.2/100.0 * C.2/100.0)
        let bottom = C.0/100.0 + C.1/100.0 + C.2/100.0
        return top / bottom
    }
}
