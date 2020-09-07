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
* Reward related with user engagement
* var rewardId: Id of the reward
* var rewardName: Name of the reward
* var targetCampaignId: Id of campaign eligible to the reward
* var startDate: start date of the reward
* var endDate: end date of the reward
* var targetType: type of the reward target (points, days, trips, etc.)
* var targetValue: minimum target value to be eligible for reward
* var organizerName: organizer of the reward
* var linkToContact: url to contact organizer
* var removed: indicates wheter reward was removed
* var defaultLanguage: default language of the reward
*/
class Reward: NSManagedObject, JsonParseable {
    
    public static let MyEntityName = "Reward"
    
    @NSManaged var rewardId: String
    @NSManaged var rewardName: String
    @NSManaged var targetCampaignId: String
    @NSManaged var startDate: Date
    @NSManaged var endDate: Date
    @NSManaged var targetType: Double
    
    @NSManaged var targetValue: Double
    @NSManaged var organizerName: String
    @NSManaged var linkToContact: String
    @NSManaged var removed: Bool
    
    @NSManaged var defaultLanguage: String
    
    @NSManaged var allDescriptions: NSSet
    
    
    
    enum CodingKeysSpec: String, CodingKey {
        case rewardId
        case rewardName
        case targetCampaignId
        case startDate
        case endDate
        case targetType
        case targetValue
        case organizerName
        case linkToContact
        case defaultLanguage
        case removed
        case descriptions
    }
    
    enum TargetType : Double {
        case POINTS = 1.0
        case DAYS = 2.0
        case TRIPS = 3.0
        case ALL_TIME_POINTS = 4.0
        case ALL_TIME_DAYS = 5.0
        case ALL_TIME_TRIPS = 6.0
    }
    
    convenience init(rewardId: String, rewardName: String, targetCampaignId: String, startDate: Date, endDate: Date, targetType: Double, targetValue: Double) {
        let context = UserInfo.context!
        let entity = NSEntityDescription.entity(forEntityName: Reward.MyEntityName, in: context)!
        self.init(entity: entity, insertInto: context)
    }
    
    required convenience init(from decoder: Decoder) throws {
        
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: Reward.MyEntityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        var result = [String: Any]()
        if  let rewardId = try container.decodeIfPresent(String.self, forKey: .rewardId),
            let rewardName = try container.decodeIfPresent(String.self, forKey: .rewardName),
            
            let targetCampaignId = try container.decodeIfPresent(String.self, forKey: .targetCampaignId),
            let startDate = try container.decodeIfPresent(Double.self, forKey: .startDate),
            let endDate = try container.decodeIfPresent(Double.self, forKey: .endDate),
            
            let targetType = try container.decodeIfPresent(Double.self, forKey: .targetType),
            let targetValue = try container.decodeIfPresent(Double.self, forKey: .targetValue),
            
            let organizerName = try container.decodeIfPresent(String.self, forKey: .organizerName),
            let linkToContact = try container.decodeIfPresent(String.self, forKey: .linkToContact),
            let removed = try container.decodeIfPresent(Bool.self, forKey: .removed),
            let defaultLanguage = try container.decodeIfPresent(String.self, forKey: .defaultLanguage),
            let descriptionsDict = try container.decodeIfPresent([String:Description].self, forKey: .descriptions){
          
            
            self.rewardId = rewardId
            self.rewardName = rewardName
            self.targetCampaignId = targetCampaignId
            self.startDate = Date(timeIntervalSince1970: startDate.divided(by: Double(1000)))
            self.endDate = Date(timeIntervalSince1970: endDate.divided(by: Double(1000)))
            self.targetType = targetType
            self.targetValue = targetValue
            self.organizerName = organizerName
            self.linkToContact = linkToContact
            self.removed = removed
            self.defaultLanguage = defaultLanguage
            
            var descriptionsSet = [Description]()
            for key in descriptionsDict.keys {
                descriptionsSet.append(Description(lang: key, shortDescription: descriptionsDict[key]!.myShortDescription, longDescription: descriptionsDict[key]!.longDescription))
            }
            
            self.allDescriptions = NSSet(array: descriptionsSet)
        
        } else {
            throw NSError(domain: "decoding Reward", code: 1, userInfo: ["Container" : container])
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysSpec.self)
        
        try container.encode(self.rewardId, forKey: .rewardId)
        try container.encode(self.rewardName, forKey: .rewardName)
        try container.encode(self.targetCampaignId, forKey: .targetCampaignId)
        try container.encode(self.startDate, forKey: .startDate)
        try container.encode(self.endDate, forKey: .endDate)
        try container.encode(self.targetType, forKey: .targetType)
        try container.encode(self.targetValue, forKey: .targetValue)
        try container.encode(self.organizerName, forKey: .organizerName)
        try container.encode(self.linkToContact, forKey: .linkToContact)
        try container.encode(self.removed, forKey: .removed)
        try container.encode(self.defaultLanguage, forKey: .defaultLanguage)
    }
    
    public func isRewardActive(date: Date) -> Bool {
        return date >= self.startDate && date <= self.endDate && !self.removed
    }
    
    public func canShowReward(timeToAdd: Double) -> Bool {
        return (Date() > self.startDate) && (Date() < self.endDate.addingTimeInterval(timeToAdd))
    }
    
    @objc func openUrl() {
        guard let url = URL(string: linkToContact) else {
            return
        }
        UIApplication.shared.open(url, options: [String : Any](), completionHandler: nil)
    }

}

