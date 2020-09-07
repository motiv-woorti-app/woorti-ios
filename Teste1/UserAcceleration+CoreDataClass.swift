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


public class UserAcceleration: NSManagedObject, JsonParseable {

    public static let entityName = "UserAcceleration"
    public static let LowAccelerationThreshold = Double(0.2)
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserAcceleration> {
        return NSFetchRequest<UserAcceleration>(entityName: "UserAcceleration")
    }
    
    @NSManaged public var x: Double
    @NSManaged public var y: Double
    @NSManaged public var z: Double
    @NSManaged public var timestamp: Date
    
    convenience init?(x: Double, y: Double, z:Double, date: Date) {
        guard let context = UserInfo.context else { return nil }
        guard let entity = NSEntityDescription.entity(forEntityName: UserAcceleration.entityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            return nil
            
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        
        self.x=x
        self.y=y
        self.z=z
        self.timestamp = date
    }
    
    public static func getUserAcceleration(x: Double, y: Double, z:Double, date: Date) -> UserAcceleration? {
        guard let context = UserInfo.context else { return nil }
        var ua: UserAcceleration?
        UserInfo.ContextSemaphore.wait()
        context.performAndWait {
            ua = UserAcceleration(x: x, y: y, z:z, date: date)
        }
        return ua
    }
    
    public func accelerationVector() -> Double {
        return (pow(x, 2) + pow(y, 2) + pow(z, 2)).squareRoot()
    }
    
    public static func processAllAccelerations(_ accs: [UserAcceleration]) -> Double {
        var mean = Double(0)
        for acc in accs {
            mean.add(acc.accelerationVector())
        }
        
        if accs.count == 0 {
            return mean
        }
        return mean.divided(by: Double(accs.count))
    }
    
    public static func processAllAccelerationsFiltered(_ accs: [UserAcceleration]) -> Double {
        var mean = Double(0)
        var accAboveThreshold = 0
        for acc in accs {
            if acc.accelerationVector() > LowAccelerationThreshold {
                mean.add(acc.accelerationVector())
                accAboveThreshold+=1
            }
        }
        
        if accAboveThreshold == 0 {
            return mean
        }
        return mean.divided(by: Double(accAboveThreshold))
    }
    
    public static func GetBellowThresholdDuration(_ accs: [UserAcceleration]) -> Double {
        if accs.count > 0 {
            let startDate = (accs.first?.timestamp)!
            let endDate = (accs.last?.timestamp)!
            var prevAcceleration: UserAcceleration?
            if startDate < endDate {
                let fullDuration = endDate.timeIntervalSince(startDate) //seconds
                var bellowThresholdDuration = Double(0)                 //seconds
                
                for acc in accs {
                    if prevAcceleration == nil {
                        prevAcceleration = acc
                        continue
                    }
                    if acc.accelerationVector() < LowAccelerationThreshold {
                        bellowThresholdDuration.add(acc.timestamp.timeIntervalSince(prevAcceleration!.timestamp))
                    }
                    prevAcceleration = acc
                }
                
                return bellowThresholdDuration.divided(by: fullDuration)
            }
        }
        return Double(0)
    }
    
    static func processAllAccelerationsForLeg(leg: Trip) {
        leg.accelerationMean = 0
        leg.filteredAcceleration = 0
        leg.filteredAccelerationBelowThreshold = 0
        
        let startDate = leg.startDate
        if let endDate = leg.endDate {
            let accs = getAccelerationList(sDate: startDate, eDate: endDate)
            if accs.count > 0 {
                var prevAcceleration: UserAcceleration?
                
                var meanAboveThreshold = Double(0)
                var accAboveThreshold = 0
                
                if startDate < endDate {
                    let fullDuration = endDate.timeIntervalSince(startDate) //seconds
                    
                    
                    //running the accelerations loop
                    for acc in accs {
                        //accMean
                        leg.accelerationMean.add(acc.accelerationVector())
                        
                        //filtered threshold
                        if acc.accelerationVector() > LowAccelerationThreshold {
                            meanAboveThreshold.add(acc.accelerationVector())
                            accAboveThreshold+=1
                        }
                        
                        //filtered threshold percentage
                        if prevAcceleration == nil {
                            prevAcceleration = acc
                            continue
                        }
                        if acc.accelerationVector() < LowAccelerationThreshold {
                            leg.filteredAccelerationBelowThreshold.add(acc.timestamp.timeIntervalSince(prevAcceleration!.timestamp))
                        }
                        //Update Prev
                        prevAcceleration = acc
                    }
                    
                    //setting values
                    if accAboveThreshold > 0 {
                        leg.filteredAcceleration = meanAboveThreshold.divided(by: Double(accAboveThreshold))
                    }
                    
                    leg.filteredAccelerationBelowThreshold.divide(by: fullDuration)
                    leg.accelerationMean.divide(by: Double(accs.count))
                }
            }
        }
    }
    
    static func getAccelerationList(sDate: Date, eDate: Date) -> [UserAcceleration] {
//        var prevAcceleration: UserAcceleration?
        var tripAccelerationList = [UserAcceleration]()
        for acc in UserInfo.getAccelerationsWithoutSort() {
            
//            if (prevAcceleration == nil){
//                prevAcceleration = acc
//                continue
//            }
//
//            let startDate = prevAcceleration!.timestamp
//            let endDate = acc.timestamp
            
//            if ((startDate<=eDate && startDate>=sDate) || (endDate<=eDate && endDate>=sDate) || (startDate<=sDate && endDate>=eDate)){
//                tripAccelerationList.append(prevAcceleration!)
//            }
            
//            prevAcceleration = acc
            
            
            if acc.timestamp > sDate && acc.timestamp < eDate {
                tripAccelerationList.append(acc)
            }
        }
//        if prevAcceleration == nil {
//            return tripAccelerationList
//        } else if (prevAcceleration?.timestamp)! < eDate {
//            tripAccelerationList.append(prevAcceleration!)
//        }
        return tripAccelerationList
    }
    
    //MARK: parseable functions and structs
    enum CodingKeysSpec: String, CodingKey {
        case xvalue
        case yvalue
        case zvalue
        case timestamp
        
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: Trip.MyEntityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        //        try self.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        if  let timestamp = try container.decodeIfPresent(Double.self, forKey: .timestamp),
            let xvalue = try container.decodeIfPresent(Double.self, forKey: .xvalue),
            let yvalue = try container.decodeIfPresent(Double.self, forKey: .yvalue),
            let zvalue = try container.decodeIfPresent(Double.self, forKey: .zvalue) {
            
            self.x = xvalue
            self.y = yvalue
            self.z = zvalue
            self.timestamp = Date(timeIntervalSince1970: timestamp.divided(by: Double(1000)))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysSpec.self)
        try container.encode(timestamp.timeIntervalSince1970.multiplied(by: Double(1000)), forKey: .timestamp)
        try container.encode(x, forKey: .xvalue)
        try container.encode(y, forKey: .yvalue)
        try container.encode(z, forKey: .zvalue)
    }
    
    
    public enum modesOfTransport: Int, Codable {
        case automotive = 0, cycling = 1, walking = 7, unknown = 4, stationary = 3, running = 8
        case Car = 9, Train = 10, Tram = 11, Subway = 12, Ferry = 13, Plane = 14
    }
}
