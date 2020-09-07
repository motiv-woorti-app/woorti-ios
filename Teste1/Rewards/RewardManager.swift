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

/*
*   Singleton used to manage current rewards
*/
class RewardManager {
    
    static let instance = RewardManager()
    
    var atLeastOneRewardCompleted = false
    var completedRewardsName = [String]()
    
    private init(){
        
    }
    
    /*
    *Updates reward status
    *Returns True if any reward was completed and the list of completed rewards names
    * var campaignId: ID of the campaign to check for rewards
    * var date: date of trip
    * var score: score assigned to trip
    */
    public func checkAndAssignScoreForTrip(campaignId: String, date: Date, score: Double){
        let rewardData = MotivUser.getInstance()?.rewards.allObjects as? [Reward] ?? [Reward]()
        let rewardStatuses = MotivUser.getInstance()!.getRewardStatus()
        
        let rewardsForTargetCampaign = getRewardsforTargetCampaign(rewards: rewardData, campaignId: campaignId)
        
        var hasNewStatus = false
        
        for reward in rewardsForTargetCampaign {
            if isRewardActive(reward: reward, date: date) {
                //Create or Update RewardStatus Object
                var rewardStatus : RewardStatus
                hasNewStatus = false
                
                if let tempRewardStatus = getRewardStatusFromId(rewardStatusSet: rewardStatuses, id: reward.rewardId){  //RewardStatus exists
                    rewardStatus = tempRewardStatus
                } else {                                                //Create new RewardStatus
                    hasNewStatus = true
                    rewardStatus = RewardStatus(userid: "", rewardID: reward.rewardId, currentValue: 0.0, rewardVersion: 0.0, timestampsOfDaysWithTrips: [Double]())
                }
                
                let pointsBefore = rewardStatus.currentValue
                
                switch(reward.targetType){
                case 1.0: //POINTS
                    rewardStatus.currentValue += score
                    rewardStatus.rewardVersion += 1
                    rewardStatus.hasBeenSentToServer = false
                    
                case 2.0: //DAYS:
                    if checkIfTripIsFromANewDay(tripDate: date, timestamps: rewardStatus.timestampsOfDaysWithTrips) {
                        rewardStatus.currentValue += 1
                        rewardStatus.rewardVersion += 1
                        rewardStatus.timestampsOfDaysWithTrips.append(Double(date.timeIntervalSince1970))
                        rewardStatus.hasBeenSentToServer = false
                    }
                    
                case 3.0: //TRIPS
                    rewardStatus.currentValue += 1
                    rewardStatus.rewardVersion += 1
                    rewardStatus.hasBeenSentToServer = false
                default:
                    print("Unused reward type")
                }
                
                if(hasNewStatus) {
                    MotivUser.getInstance()?.addNewRewardStatus(reward: rewardStatus)

                }
                
                if pointsBefore < reward.targetValue && rewardStatus.currentValue >= reward.targetValue {
                    self.atLeastOneRewardCompleted = true
                    self.completedRewardsName.append(reward.rewardName)
                }
                
                
            } else {
                print("RewardManager, Reward is not active")
            }
            
            
        }
        
    }
    
    /*
    *Updates reward status from answered surveys
    * var campaignId: ID of the campaign to check for rewards
    * var score: score assigned to survey
    */
    public func checkAndAssignScoreForSurveys(campaignId: String, score: Double) {
        let rewardData = MotivUser.getInstance()?.rewards.allObjects as? [Reward] ?? [Reward]()
        let rewardStatuses = MotivUser.getInstance()?.rewardStatus.allObjects as? [RewardStatus] ?? [RewardStatus]()
        
        let rewardsForTargetCampaign = getRewardsforTargetCampaign(rewards: rewardData, campaignId: campaignId)
        
        var hasNewStatus = false
        
        for reward in rewardsForTargetCampaign {
            
            if isRewardActive(reward: reward, date: Date()) {
                print("RewardManager, reward is active")
            
                var rewardStatus : RewardStatus
                
                if let tempRewardStatus = getRewardStatusFromId(rewardStatusSet: rewardStatuses, id: reward.rewardId){  //RewardStatus exists
                    rewardStatus = tempRewardStatus
                } else {                                                //Create new RewardStatus
                    print("--RewardManager, creating new status")
                    hasNewStatus = true
                    rewardStatus = RewardStatus(userid: "", rewardID: reward.rewardId, currentValue: 0.0, rewardVersion: 0.0, timestampsOfDaysWithTrips: [Double]())
                }
                
                 var pointsBefore = rewardStatus.currentValue
                
                
                switch(reward.targetType){
                case 1.0: //POINTS
                    rewardStatus.currentValue += score
                    rewardStatus.rewardVersion += 1
                    rewardStatus.hasBeenSentToServer = false
                default:
                    print("Surveys only target points reward")
                }
                
                if(hasNewStatus) {
                    MotivUser.getInstance()?.addNewRewardStatus(reward: rewardStatus)
                    
                }
                
                if pointsBefore < reward.targetValue && rewardStatus.currentValue >= reward.targetValue {
                    atLeastOneRewardCompleted = true
                    self.completedRewardsName.append(reward.rewardName)
                }
            }
            
        }
        
    }
    
    /*
    *Updates reward status from completed profile
    * var campaignId: ID of the campaign to check for rewards
    * var score: score assigned to profile
    */
    public func checkAndAssignScoreForProfile(campaignId: String, score: Double) {
        let rewardData = MotivUser.getInstance()?.rewards.allObjects as? [Reward] ?? [Reward]()
        let rewardStatuses = MotivUser.getInstance()?.rewardStatus.allObjects as? [RewardStatus] ?? [RewardStatus]()
        
        let rewardsForTargetCampaign = getRewardsforTargetCampaign(rewards: rewardData, campaignId: campaignId)
        
        var hasNewStatus = false
        
        for reward in rewardsForTargetCampaign {
            
            if isRewardActive(reward: reward, date: Date()) {
                
                var rewardStatus : RewardStatus

                if let tempRewardStatus = getRewardStatusFromId(rewardStatusSet: rewardStatuses, id: reward.rewardId){  //RewardStatus exists
                    rewardStatus = tempRewardStatus
                } else {                                                //Create new RewardStatus
                    hasNewStatus = true
                    rewardStatus = RewardStatus(userid: "", rewardID: reward.rewardId, currentValue: 0.0, rewardVersion: 0.0, timestampsOfDaysWithTrips: [Double]())
                }
                
                var pointsBefore = rewardStatus.currentValue
                
                
                switch(reward.targetType){
                case 1.0: //POINTS
                    rewardStatus.currentValue += score
                    rewardStatus.rewardVersion += 1
                    rewardStatus.hasBeenSentToServer = false
                default:
                    print("Profile only assigns scores of type points")
                }
                
                if(hasNewStatus) {
                    MotivUser.getInstance()?.addNewRewardStatus(reward: rewardStatus)
                    
                }
                
                if pointsBefore < reward.targetValue && rewardStatus.currentValue >= reward.targetValue {
                    atLeastOneRewardCompleted = true
                    self.completedRewardsName.append(reward.rewardName)
                }
            }
            
        }
        
    }
    
    /*
    * Check if date of trip is unique for reward (for rewards of type :DAYS)
    * var tripDate: date of the trip
    * var timestamps: current days with trips on reward 
    */
    public func checkIfTripIsFromANewDay(tripDate: Date, timestamps: [Double]) -> Bool{
        for ts in timestamps {
            let dateTS = Date(timeIntervalSince1970: ts)
            if Calendar.current.isDate(tripDate, inSameDayAs: dateTS){
                return false
            }
        }
        return true
    }
    
    /*
    * Obtain rewards available for given campaign
    * var rewards: all rewards
    * var campaignId: id of the target campaign
    */
    public func getRewardsforTargetCampaign(rewards: [Reward], campaignId: String) -> [Reward]{
        var tempRewards = [Reward]()
        for reward in rewards {
            if reward.targetCampaignId == campaignId {
                tempRewards.append(reward)
            }
        }
        return tempRewards
    }
    
    
    /*
    * Get status for reward with given id
    * var rewardStatusSet: all reward status
    * var id: id of target reward
    */
    public func getRewardStatusFromId(rewardStatusSet: [RewardStatus], id: String) -> RewardStatus? {
        for reward in rewardStatusSet {
            if reward.rewardID == id {
                return reward
            }
        }
        
        return nil
    }
    
    /*
    * update rewards with type :ALL_TIME
    * var allTimeDays: all time number of days with trips from user
    * var allTimeTrips: all time number of trips from user
    */
    public func updateAllTimeRewards(allTimeDays: Double, allTimeTrips: Double){
        if let user = MotivUser.getInstance() {
            let rewards = user.getRewards()
            let rewardStatus = user.getRewardStatus()
            
            for reward in rewards {
                var score = 0.0
                switch(reward.targetType) {
                case Reward.TargetType.ALL_TIME_POINTS.rawValue:
                    score = user.fullPoints[reward.targetCampaignId] ?? 0
                    updateRewardStatusAllTime(statuses: rewardStatus, id: reward.rewardId, score: score)
                break
                case Reward.TargetType.ALL_TIME_TRIPS.rawValue:
                    score = allTimeTrips
                    updateRewardStatusAllTime(statuses: rewardStatus, id: reward.rewardId, score: score)
                break
                case Reward.TargetType.ALL_TIME_DAYS.rawValue:
                    score = allTimeDays
                    updateRewardStatusAllTime(statuses: rewardStatus, id: reward.rewardId, score: score)
                break
                default:
                    break
                }
                
                
            }

        }
    }
    
    /*
    * update rewards status for rewards with given id
    * var statuses: set of all reward status
    * var id: if of target reward
    * var score: score to assign
    */
    public func updateRewardStatusAllTime(statuses: [RewardStatus], id: String, score: Double) {
        var rewardStatus : RewardStatus
        var hasNewStatus = false
        
        if let tempRewardStatus = getRewardStatusFromId(rewardStatusSet: statuses, id: id){  //RewardStatus exists
            rewardStatus = tempRewardStatus
        } else {                                                //Create new RewardStatus
            hasNewStatus = true
            rewardStatus = RewardStatus(userid: "", rewardID: id, currentValue: 0.0, rewardVersion: 0.0, timestampsOfDaysWithTrips: [Double]())
        }
        
        rewardStatus.currentValue = score
        rewardStatus.rewardVersion += 1
        rewardStatus.hasBeenSentToServer = false
        
        if hasNewStatus {
            MotivUser.getInstance()?.addNewRewardStatus(reward: rewardStatus)
        }
    }
    
    
    public func isRewardActive(reward: Reward, date: Date) -> Bool {
        return date >= reward.startDate && date <= reward.endDate && !reward.removed
    }
    
    public func resetRewardCompletionChecker(){
        atLeastOneRewardCompleted = false
        completedRewardsName = [String]()
    }
    
    
    
}
