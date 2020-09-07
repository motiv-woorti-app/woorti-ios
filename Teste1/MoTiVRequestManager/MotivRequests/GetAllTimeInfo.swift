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

/**
* Class to perform request for user's all time information regarding time/co2/calories spent travelling
*/
class GetAllTimeInfo: JsonRequest {
    var responseClass: JsonResponse = GetAllTimeInfoResponse()
    var endpoint = "/api/rewards/statusAllTime"
    var url: String {get {return "https://app.motiv.gsd.inesc-id.pt:8000"}}
    
    var voided = Double(0)
    
    func makeRequest(accessToken: String?){
        
        RestModule(urlString: url + endpoint, jsonData: "[]".data(using: .utf8)!, method: RestModule.Method.PUT, responseFunction: self, accessToken: accessToken).makeRequest()
    }
    
    enum CodingKeys: String, CodingKey {
        case voided
    }
}


class GetAllTimeInfoHandler: ResponseHandler {
    
    func handleResponse(resp: JsonResponse) {
        if let allTimeInfo = resp as? GetAllTimeInfoResponse {
            if allTimeInfo.allTimeTripInfo.numberTotalDaysWithTrips >= 0 && allTimeInfo.allTimeTripInfo.numberTotalTrips >= 0 {
                RewardManager.instance.updateAllTimeRewards(allTimeDays: allTimeInfo.allTimeTripInfo.numberTotalDaysWithTrips, allTimeTrips: allTimeInfo.allTimeTripInfo.numberTotalTrips)
                
            }
       
        }
    }
}

class GetAllTimeInfoResponse: JsonResponse {
    var responseHandler: ResponseHandler? = GetAllTimeInfoHandler()
    
    var allTimeTripInfo = AllTimeInfo()
    
    enum CodingKeys: String, CodingKey {
        case allTimeTripInfo
    }
    
}

class AllTimeInfo : JsonParseable {
    
    var rewards = [RewardStatus]()
    var numberTotalDaysWithTrips = 0.0
    var numberTotalTrips = 0.0
    
    enum CodingKeys: String, CodingKey {
        case rewards
        case numberTotalDaysWithTrips
        case numberTotalTrips
    }
    
    convenience init(rewards: [RewardStatus], numberTotalDaysWithTrips: Double, numberTotalTrips: Double) {
        self.init()
        self.rewards = [RewardStatus]()
        self.numberTotalDaysWithTrips = 0.0
        self.numberTotalTrips = 0.0
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init()
       
        if  let rewards = try container.decodeIfPresent([RewardStatus].self, forKey: .rewards),
            let numberTotalDaysWithTrips = try container.decodeIfPresent(Double.self, forKey: .numberTotalDaysWithTrips),
            let numberTotalTrips = try container.decodeIfPresent(Double.self, forKey: .numberTotalTrips) {
            
            
            self.rewards = rewards
            self.numberTotalDaysWithTrips = numberTotalDaysWithTrips
            self.numberTotalTrips = numberTotalTrips
            
        } else {
            throw NSError(domain: "decoding Reward", code: 1, userInfo: ["Container" : container])
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.rewards, forKey: .rewards)
        try container.encode(self.numberTotalDaysWithTrips, forKey: .numberTotalDaysWithTrips)
        try container.encode(self.numberTotalTrips, forKey: .numberTotalTrips)
    }
    
}

