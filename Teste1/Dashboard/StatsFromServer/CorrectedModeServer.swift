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

class CorrectedModeServer : JsonParseable {
    
    var mode = 0
    var count = Int64(0)
    var distance = 0.0
    var duration = Int64(0)
    var wastedTimeMode = Int64(0)
    var wastedTimeModeCount = Int64(0)
    var valueFromTripMode : [ValueFromTripTotalServer]?
    var valueFromTripModeCount : [ValueFromTripTotalCountServer]?
    
    var wastedTimeWSum = Int64(0)
    var weightedSum = Int64(0)
    var valueFromTripModeWSum : [ValueFromTripTotalServer]?
    
    
    
    enum CodingKeys: String, CodingKey {
        case mode
        case count
        case distance
        case duration
        case wastedTimeMode
        case wastedTimeWSum
        case wastedTimeModeCount
        case valueFromTripMode
        case valueFromTripModeCount
        case weightedSum
        case valueFromTripModeWSum
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init()
        
        if  let mode = try container.decodeIfPresent(Int.self, forKey: .mode),
            let count = try container.decodeIfPresent(Int64.self, forKey: .count),
            let distance = try container.decodeIfPresent(Double.self, forKey: .distance),
            let duration = try container.decodeIfPresent(Int64.self, forKey: .duration),
            let wastedTimeMode = try container.decodeIfPresent(Int64.self, forKey: .wastedTimeMode),
            let wastedTimeModeCount = try container.decodeIfPresent(Int64.self, forKey: .wastedTimeModeCount),
            let valueFromTripMode = try container.decodeIfPresent([ValueFromTripTotalServer].self, forKey: .valueFromTripMode),
            let valueFromTripModeCount = try container.decodeIfPresent([ValueFromTripTotalCountServer].self, forKey: .valueFromTripModeCount),
            let wastedTimeWSum = try container.decodeIfPresent(Int64.self, forKey: .wastedTimeWSum),
            let valueFromTripModeWSum = try container.decodeIfPresent([ValueFromTripTotalServer].self, forKey: .valueFromTripModeWSum){
            
            
            let weightedSum = try container.decodeIfPresent(Int64.self, forKey: .weightedSum)
            
            self.mode = mode
            self.count = count
            self.distance = distance
            self.duration = duration
            self.wastedTimeMode = wastedTimeMode
            self.wastedTimeModeCount = wastedTimeModeCount
            self.valueFromTripMode = valueFromTripMode
            self.valueFromTripModeCount = valueFromTripModeCount
            self.wastedTimeWSum = wastedTimeWSum
            if let sum = weightedSum {
                self.weightedSum = sum
            }
           
            self.valueFromTripModeWSum = valueFromTripModeWSum
            
        } else {
            throw NSError(domain: "decoding correct mode server", code: 1, userInfo: ["Container" : container])
        }
    }
}
