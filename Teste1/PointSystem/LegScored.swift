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


/**
* Class to represent the score attributed to one leg
*/
class LegScored: Scored {
    
    enum ids: String {
        case worthwhilenessElements
        case activities
        case modeValidated
    }
    
    public static let entityNameChild = "LegScored"
    
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: LegScored.entityNameChild, in: context)!
        self.init(entity: entity, insertInto: context)
    }
    
    /**
    * Generate an instance of LegScored
    */
    public static func getLegScored() -> LegScored? {
        var score: LegScored?
        if let ctx = UserInfo.context {
            UserInfo.ContextSemaphore.wait()
            score = LegScored(context: ctx)
            UserInfo.ContextSemaphore.signal()
        }
        return score
    }
    
    /**
    * Process user answer to leg's worthwhileness
    */
    public func answerWorthwileness() -> [String: Double] {
        var result = [String: Double]()
        for campaign in self.getCampaigns() {
            let campaignId = campaign.getID()
            let id = ids.worthwhilenessElements.rawValue
            let value = campaign.pointsWorth
            result[campaign.getID()] = self.updateScoreValue(campaignId: campaignId, id: id, value: value)
        }
        return result
    }
    
    /**
    * Process user answer to leg's activities
    */
    public func answerActivities() -> [String: Double] {
        var result = [String: Double]()
        for campaign in self.getCampaigns() {
            let campaignId = campaign.getID()
            let id = ids.activities.rawValue
            let value = campaign.pointsActivities
            result[campaign.getID()] = self.updateScoreValue(campaignId: campaignId, id: id, value: value)
        }
        return result
    }
    
    /**
    * Process user answer to leg's mode
    */
    public func answerMode() -> [String: Double] {
        var result = [String: Double]()
        for campaign in self.getCampaigns() {
            let campaignId = campaign.getID()
            let id = ids.modeValidated.rawValue
            let value = campaign.pointsTransportMode
            result[campaign.getID()] = self.updateScoreValue(campaignId: campaignId, id: id, value: value)
        }
        
        return result
    }
    
}
