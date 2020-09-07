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
* Abstract class to represent an abstract score
*/
class Scored: NSManagedObject {
    // scores for each campaign
    @NSManaged private var scores: [String:[Score]]
    @NSManaged private var totalScore: [String: Double]
    
    public static let entityName = "Scored"
    
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: Scored.entityName, in: context)!
        self.init(entity: entity, insertInto: context)
        self.scores = [String:[Score]]()
        self.totalScore = [String: Double]()
    }
    
    public static func getScored() -> Scored? {
        var score: Scored?
        if let ctx = UserInfo.context {
            UserInfo.ContextSemaphore.wait()
            score = Scored(context: ctx)
            UserInfo.ContextSemaphore.signal()
        }
        return score
    }
    
    /**
    * Retrieve the score for a selected campaign
    * parameter campaignId: ID of the campaign 
    */
    public func getScoreFor(campaignId: String) -> Double {
        if let scoresToCalc = totalScore[campaignId] {
            return scoresToCalc
        }
        return Double(0)
    }
    
    /**
    * Retrieve the total score from all campaigns
    */
    public func getScore() -> Double {
        return totalScore.reduce(0, { (prev, score) -> Double in
            prev + score.value
        })
    }
    
    /**
    * Retrieve the score for a selected campaign
    * parameter campaignId: ID of the campaign 
    */
    public func getScoreForCampaign(campaignId: String) -> Double {
        if let score = totalScore[campaignId] {
            return score
        }
        return 0.0
    }
    
    /**
    * Update score if it doesn't exist in campaign
    * parameter campaignId: ID of the campaign
    * parameter value: score representation
    */
    func diffPoints(campaignId: String, value: Double) {
        if self.totalScore.index(forKey: campaignId) != nil {
            self.totalScore[campaignId] = self.totalScore[campaignId]! + value
        }
        else {
            self.totalScore[campaignId] = value
        }
    }
    
    /**
    * Process an update for a score of a given campaign
    * parameter campaignId: ID of the campaign
    * parameter id: id of score
    * parameter value: score representation
    */
    func updateScoreValue(campaignId: String, id: String, value: Double) -> Double {
        print("==== Updating campaign=" + campaignId + "with type=" + id + ", score=" + String(value))
        if var scoresForCmapaign = self.scores[campaignId] {
            var hasScore = false;
            for score in scoresForCmapaign {
                print("====== Campaign score: " + score.getId() + ", with score=" + String(score.getScore()))
                if score.isScore(id: id) {
                    print("======== Replacing score, old Value=" + String(score.getScore()))
                    hasScore = true
                    let diff = score.setValue(value: value)
                    print("======== Diff for old score =" + String(diff))
                    print("======== NEW SCORE = " + String(score.getScore()))
                    self.diffPoints(campaignId: campaignId, value: diff)
                    MotivUser.getInstance()?.addPointsTo(campaignID: campaignId, points: diff)
                    return diff
                }
            }
            //NEW CODE
            if(!hasScore){
                if let newScore = Score.getScore(id: id, value: value){
                    scoresForCmapaign.append(newScore)
                    print("===== Added new scoreId=" + newScore.getId() + ", score=" + String(newScore.getScore()))
                    self.diffPoints(campaignId: campaignId, value: value)
                }
            }
            
            self.scores[campaignId] = scoresForCmapaign
        } else {
            let newScore = Score.getScore(id: id, value: value)
            self.scores[campaignId] = [newScore!]
            self.diffPoints(campaignId: campaignId, value: value)
            print("===== Added new score + " + newScore!.getId())
        }
        MotivUser.getInstance()?.addPointsTo(campaignID: campaignId, points: value)
        return value
    }
    
    /**
    * Get a Map with score per campaign
    */
    func getResultScores() -> [String: Double] {
        return self.totalScore
    }
    
    /**
    * Get campaigns where user is inserted
    */
    func getCampaigns() -> [MockCampaign] {
        if let user = MotivUser.getInstance() {
            return user.getCampaigns()
        }
        return [MockCampaign]()
    }
    
    static func getPossibleModePoints() -> Double{
        var score = 0.0
        if let user = MotivUser.getInstance() {
            let campaigns = user.getCampaigns()
            
            for campaign in campaigns{
                return campaign.pointsTransportMode
            }
        }
        return score
    }
    
    static func getPossibleAllInfoPoints() -> Double{
        var score = 0.0
        if let user = MotivUser.getInstance() {
            let campaigns = user.getCampaigns()
            
            for campaign in campaigns{
                return campaign.pointsAllInfo
            }
        }
        return score
    }
    
    static func getPossiblePurposePoints() -> Double{
        var score = 0.0
        if let user = MotivUser.getInstance() {
            let campaigns = user.getCampaigns()
            
            for campaign in campaigns{
                return campaign.pointsTripPurpose
            }
        }
        return score
    }
    
    static func getPossibleWorthPoints() -> Double{
        var score = 0.0
        if let user = MotivUser.getInstance() {
            let campaigns = user.getCampaigns()
            
            for campaign in campaigns{
                return campaign.pointsWorth
            }
        }
        return score
    }
    
    static func getPossibleActivitiesPoints() -> Double{
        var score = 0.0
        if let user = MotivUser.getInstance() {
            let campaigns = user.getCampaigns()
            
            for campaign in campaigns{
                return campaign.pointsActivities
            }
        }
        return score
    }
}
