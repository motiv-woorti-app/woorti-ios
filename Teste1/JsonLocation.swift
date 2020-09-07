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
 * Json Representation of GPS location
 */
class JsonLocation: NSManagedObject, JsonParseable {
    
    @NSManaged public var lat: Float
    @NSManaged public var lon: Float
    
    public static let MyEntityName = "JsonLocation"
    
    enum CodingKeys: String, CodingKey {
        case lat
        case lon
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<JsonLocation> {
        return NSFetchRequest<JsonLocation>(entityName: "JsonLocation")
    }
    
    convenience init?(lat: Float,lon: Float) {
        guard let context = UserInfo.context else { return nil }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: JsonLocation.MyEntityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            return nil
            
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        self.lat=lat
        self.lon=lon
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: JsonLocation.MyEntityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if  let lat = try container.decodeIfPresent(String.self, forKey: .lat),
            let lon = try container.decodeIfPresent(String.self, forKey: .lon) {
            
            self.lat = Float(lat)!
            self.lon = Float(lon)!
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lat, forKey: .lat)
        try container.encode(lon, forKey: .lon)
    }
}
