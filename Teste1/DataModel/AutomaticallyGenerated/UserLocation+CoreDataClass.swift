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


public class UserLocation: NSManagedObject, JsonParseable {
    
    public static let entityName = "UserLocation"
    
    convenience init(userLocation: CLLocation, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: UserLocation.entityName, in: context)!
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        location=userLocation
    }
    
    public static func getUserLocation(userLocation: CLLocation, context: NSManagedObjectContext) -> UserLocation? {
        var ul: UserLocation?
        UserInfo.ContextSemaphore.wait(timeout: DispatchTime(uptimeNanoseconds: 1000 * 1000 * 5))
        context.performAndWait {
            ul = UserLocation(userLocation: userLocation, context: context)
        }
        return ul
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserLocation> {
        return NSFetchRequest<UserLocation>(entityName: UserLocation.entityName)
    }
    
    @NSManaged public var location: CLLocation?
    @NSManaged private var part: FullTripPart?
    
    
    //MARK: ParseableFunctions
    enum CodingKeys: String, CodingKey {
        case lat
        case lon
        case acc
        case timestamp
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: UserLocation.entityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        //        try self.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if  let lat = try container.decodeIfPresent(Double.self, forKey: .lat),
            let lon = try container.decodeIfPresent(Double.self, forKey: .lon),
            let timestamp = try container.decodeIfPresent(Double.self, forKey: .timestamp),
            let acc = try container.decodeIfPresent(Double.self, forKey: .acc) {
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
//            let location = CLLocation(coordinate: coordinate, altitude: 0, horizontalAccuracy: acc, verticalAccuracy: 0, timestamp: timestamp)
            location = CLLocation(coordinate: coordinate, altitude: 0, horizontalAccuracy: acc, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: timestamp))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(location?.coordinate.latitude, forKey: .lat)
        try container.encode(location?.coordinate.longitude, forKey: .lon)
        try container.encode(location?.horizontalAccuracy, forKey: .acc)
        try container.encode(((location?.timestamp.timeIntervalSince1970 ?? 0) * 1000), forKey: .timestamp)
    }
    
    public func delete() {
        UserInfo.context?.delete(self)
    }
}
