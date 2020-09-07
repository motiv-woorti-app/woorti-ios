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
import Firebase

/*
* Class to represent status of reward
* var userid: id of the user
* var rewardID: id of the reward
* var currentValue: current score for reward
* var rewardVersion: version to sync with server
* var hasBeenSentToServer: check if server received current status
* var timestampsOfDaysWithTrips: set of unique days with trips
*/
class RewardStatus: NSManagedObject, JsonParseable {
    
    public static let MyEntityName = "RewardStatus"
    
    @NSManaged var userid: String
    @NSManaged var rewardID: String
    @NSManaged var currentValue: Double
    @NSManaged var rewardVersion: Double
    @NSManaged var hasBeenSentToServer: Bool
    @NSManaged var timestampsOfDaysWithTrips: [Double]

    
    enum CodingKeysSpec: String, CodingKey {
        case userid
        case rewardID
        case currentValue
        case rewardVersion
        case hasBeenSentToServer
        case timestampsOfDaysWithTrips
    }
    
    convenience init(userid: String, rewardID: String, currentValue: Double, rewardVersion: Double, timestampsOfDaysWithTrips: [Double]) {
        let context = UserInfo.context!
        let entity = NSEntityDescription.entity(forEntityName: RewardStatus.MyEntityName, in: context)!
        self.init(entity: entity, insertInto: context)
        self.userid = userid
        self.rewardID = rewardID
        self.currentValue = currentValue
        self.rewardVersion = rewardVersion
        self.hasBeenSentToServer = false
        self.timestampsOfDaysWithTrips = timestampsOfDaysWithTrips
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: RewardStatus.MyEntityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        print("Decoding reward status")
        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        if  let userid = try container.decodeIfPresent(String.self, forKey: .userid),
            let rewardID = try container.decodeIfPresent(String.self, forKey: .rewardID),
            let currentValue = try container.decodeIfPresent(Double.self, forKey: .currentValue),
            let rewardVersion = try container.decodeIfPresent(Double.self, forKey: .rewardVersion),
            let timestampsOfDaysWithTrips = try container.decodeIfPresent([Double].self, forKey: .timestampsOfDaysWithTrips){
            self.userid = userid
            self.rewardID = rewardID
            self.currentValue = currentValue
            self.rewardVersion = rewardVersion
            self.timestampsOfDaysWithTrips = timestampsOfDaysWithTrips
        } else {
            throw NSError(domain: "decoding Reward", code: 1, userInfo: ["Container" : container])
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysSpec.self)
        
        try container.encode(self.userid, forKey: .userid)
        try container.encode(self.rewardID, forKey: .rewardID)
        try container.encode(self.currentValue, forKey: .currentValue)
        try container.encode(self.rewardVersion, forKey: .rewardVersion)
        try container.encode(self.timestampsOfDaysWithTrips, forKey: .timestampsOfDaysWithTrips)
        
    }
    
}


