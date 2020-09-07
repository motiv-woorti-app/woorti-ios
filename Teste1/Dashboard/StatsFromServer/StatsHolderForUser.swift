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
* Holds user stats for multiple time intervals
* var day1: Stats for last day
* var day3: Stats for last three days
* var day7: Stats for last seven days
* var day30: Stats for last thirty days
* var day365: Stats for last year
* var era: all-time stats 
*/
class StatsHolderForUser : JsonParseable {
    
    var day1 : StatsPerTimeIntervalForUser?
    var day3 : StatsPerTimeIntervalForUser?
    var day7 : StatsPerTimeIntervalForUser?
    var day30 : StatsPerTimeIntervalForUser?
    var day365 : StatsPerTimeIntervalForUser?
    var ever : StatsPerTimeIntervalForUser?
    
    enum CodingKeys: String, CodingKey {
        case day1
        case day3
        case day7
        case day30
        case day365
        case ever
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init()
        
        
        if  let day1 = try container.decodeIfPresent(StatsPerTimeIntervalForUser.self, forKey: .day1),
            let day3 = try container.decodeIfPresent(StatsPerTimeIntervalForUser.self, forKey: .day3)
        {
            let day7 = try container.decodeIfPresent(StatsPerTimeIntervalForUser.self, forKey: .day7)

            let day30 = try container.decodeIfPresent(StatsPerTimeIntervalForUser.self, forKey: .day30)

            let day365 = try container.decodeIfPresent(StatsPerTimeIntervalForUser.self, forKey: .day365)

            let era = try container.decodeIfPresent(StatsPerTimeIntervalForUser.self, forKey: .ever)

            
            self.day1 = day1
            self.day3 = day3
            self.day30 = day30
            self.day365 = day365
            self.day7 = day7
            self.ever = era
            
        } else {
            throw NSError(domain: "decoding Stats Holder", code: 1, userInfo: ["Container" : container])
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.day1, forKey: .day1)
        try container.encode(self.day3, forKey: .day3)
        try container.encode(self.day7, forKey: .day7)
        try container.encode(self.day30, forKey: .day30)
        try container.encode(self.day365, forKey: .day365)
        try container.encode(self.ever, forKey: .ever)
    }
    
    
}

