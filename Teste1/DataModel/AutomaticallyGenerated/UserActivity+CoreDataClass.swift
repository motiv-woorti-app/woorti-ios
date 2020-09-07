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
import CoreMotion


public class UserActivity: NSManagedObject, JsonParseable {
    
    public static let entityName = "UserActivity"
    
    convenience init(userActivity: CMMotionActivity, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: UserActivity.entityName, in: context)!
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        activity=userActivity
    }
    
    public static func getUserActivity(userActivity: CMMotionActivity, context: NSManagedObjectContext) -> UserActivity? {
        print("BBB_ new user activity")
        var ua: UserActivity?
        UserInfo.ContextSemaphore.wait()
        context.performAndWait {
            ua = UserActivity(userActivity: userActivity, context: context)
        }
         print("BBB_ AFTER new user activity")
        return ua
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserActivity> {
        return NSFetchRequest<UserActivity>(entityName: UserActivity.entityName)
    }
    
    @NSManaged public var activity: CMMotionActivity?
    @NSManaged private var part: FullTripPart?
    
    func compare(ua: UserActivity) -> Bool {
        return self.activity!.startDate < ua.activity!.startDate
    }
    
    //MARK: parseable functions and structs
    enum CodingKeysSpec: String, CodingKey {
        case listOfDetectedActivities
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
        if  let timestamp = try container.decodeIfPresent(Double.self, forKey: .timestamp)
//            let xvalue = try container.decodeIfPresent(Double.self, forKey: .xvalue),
//            let yvalue = try container.decodeIfPresent(Double.self, forKey: .yvalue),
//            let zvalue = try container.decodeIfPresent(Double.self, forKey: .zvalue)
            {
        
//            self.x = xvalue
//            self.y = yvalue
//            self.z = zvalue
//            self.timestamp = Date(timeIntervalSince1970: timestamp.divided(by: Double(1000)))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysSpec.self)
        if let act = activity {
            try container.encode(act.startDate.timeIntervalSince1970 * Double(1000), forKey: .timestamp)
            var listOfDetectedActivities = [activityAndroidAdapter]()
            listOfDetectedActivities.append(activityAndroidAdapter(act: act))
            try container.encode(listOfDetectedActivities, forKey: .listOfDetectedActivities)
        }
    }
    
    
    public enum modesOfTransport: Int {
        case automotive = 0, cycling = 1, walking = 7, unknown = 4, stationary = 3, running = 8
        case Car = 9, Train = 10, Tram = 11, Subway = 12, Ferry = 13, Plane = 14
    }
    
    public func delete() {
        UserInfo.context?.delete(self)
    }
    
    public static func deleteActivity(ua: UserActivity){
        guard let ctx = UserInfo.context else {
            return
        }
        ctx.delete(ua)
    }
}

public class activityAndroidAdapter: Codable {
    var confidenceLevel: Int
    var type: UserAcceleration.modesOfTransport
    
    init(act: CMMotionActivity){
        confidenceLevel = (act.confidence.rawValue + 1) * 33
        type = UserAcceleration.modesOfTransport.unknown
        type = getModeOfTRansport(act: act)
    }
    
    public func getModeOfTRansport(act: CMMotionActivity) -> UserAcceleration.modesOfTransport {
        if act.walking {
            return UserAcceleration.modesOfTransport.walking
        } else if act.stationary {
            return UserAcceleration.modesOfTransport.stationary
        } else if act.automotive {
            return UserAcceleration.modesOfTransport.automotive
        } else if act.cycling {
            return UserAcceleration.modesOfTransport.cycling
        } else if act.running {
            return UserAcceleration.modesOfTransport.running
        } else {
            return UserAcceleration.modesOfTransport.unknown
        }
    }
    
    enum CodingKeysSpec: String, CodingKey {
        case confidenceLevel
        case type
    }
    
    
}

