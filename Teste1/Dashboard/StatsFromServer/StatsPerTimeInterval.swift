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
* Contains trip metrics calculated for a given time interval for a given community
*/
class StatsPerTimeInterval : JsonParseable {

    var dateType = ""
    var geoType = ""
    var name = ""
    var date = Int64(0)
    var overallScoreCount = 0
    var overallScoreTotal = 0
    var totalDistance = 0.0
    var totalDuration = Int64(0)
    var totalLegs = Int64(0)
    var wastedTimeTotal = Int64(0)
    var wastedTimeTotalCount = Int64(0)
    var valueFromTripTotal : [ValueFromTripTotalServer]?
    var valueFromTripTotalCount : [ValueFromTripTotalCountServer]?
    var correctedModes : [CorrectedModeServer]?
    var totalUsers = 0
    
    enum CodingKeys: String, CodingKey {
        case dateType
        case geoType
        case name
        case date
        case overallScoreCount
        case overallScoreTotal
        case totalDistance
        case totalDuration
        case totalLegs
        case wastedTimeTotal
        case wastedTimeTotalCount
        case valueFromTripTotal
        case valueFromTripTotalCount
        case correctedModes
        case totalUsers
    }
    
    
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init()
        
        if  let dateType = try container.decodeIfPresent(String.self, forKey: .dateType),
            let geoType = try container.decodeIfPresent(String.self, forKey: .geoType),
            let name = try container.decodeIfPresent(String.self, forKey: .name),
            let date = try container.decodeIfPresent(Int64.self, forKey: .date),
            let overallScoreCount = try container.decodeIfPresent(Int.self, forKey: .overallScoreCount),
            let overallScoreTotal = try container.decodeIfPresent(Int.self, forKey: .overallScoreTotal),
            let totalDistance = try container.decodeIfPresent(Double.self, forKey: .totalDistance),
            let totalDuration = try container.decodeIfPresent(Int64.self, forKey: .totalDuration),
            let totalLegs = try container.decodeIfPresent(Int64.self, forKey: .totalLegs),
            let totalUsers = try container.decodeIfPresent(Int.self, forKey: .totalUsers),
            let wastedTimeTotal = try container.decodeIfPresent(Int64.self, forKey: .wastedTimeTotal),
            let wastedTimeTotalCount = try container.decodeIfPresent(Int64.self, forKey: .wastedTimeTotalCount),
            let valueFromTripTotal = try container.decodeIfPresent([ValueFromTripTotalServer].self, forKey: .valueFromTripTotal),
            let valueFromTripTotalCount = try container.decodeIfPresent([ValueFromTripTotalCountServer].self, forKey: .valueFromTripTotalCount),
            let correctedModes = try container.decodeIfPresent([CorrectedModeServer].self, forKey: .correctedModes) {
            
                self.dateType = dateType
                self.geoType = geoType
                self.name = name
                self.date = date
                self.overallScoreCount = overallScoreCount
                self.overallScoreTotal = overallScoreTotal
                self.totalDistance = totalDistance
                self.totalDuration = totalDuration
                self.totalLegs = totalLegs
                self.totalUsers = totalUsers
                self.wastedTimeTotal = wastedTimeTotal
                self.wastedTimeTotalCount = wastedTimeTotalCount
                self.valueFromTripTotal = valueFromTripTotal
                self.valueFromTripTotalCount = valueFromTripTotalCount
                self.correctedModes = correctedModes
            
        } else {
            throw NSError(domain: "decoding Stats per time", code: 1, userInfo: ["Container" : container])
        }
    }

}
