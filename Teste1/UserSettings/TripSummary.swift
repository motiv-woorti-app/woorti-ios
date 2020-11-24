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

class TripSummary: JsonParseable {
    
    var startDate: Date
    var totalDistance: Double
    var totalTime: Double
    
    enum CodingKeysSpec: String, CodingKey {
        case startDate
        case totalDistance
        case totalTime
    }
    
    init(){
        self.startDate = Date()
        self.totalDistance = 0.0
        self.totalTime = 0.0
    }
    
    
    convenience init(startDate: Date, totalDistance: Double, totalTime: Double) {
        self.init()
        self.startDate = startDate
        self.totalDistance = totalDistance
        self.totalTime = totalTime
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        if  let startDate = try container.decodeIfPresent(Double.self, forKey: .startDate),
            let totalDistance = try container.decodeIfPresent(Double.self, forKey: .totalDistance),
            let totalTime = try container.decodeIfPresent(Double.self, forKey: .totalTime){
            
            self.startDate = Date(timeIntervalSince1970: startDate.divided(by: Double(1000)))
            self.totalDistance = totalDistance
            self.totalTime = totalTime
            
        } else {
            throw NSError(domain: "decoding TripSummary error", code: 1, userInfo: ["Container" : container])
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysSpec.self)
        
        let startDateDouble = self.startDate.timeIntervalSince1970
        let (inteiro, _) = modf(startDateDouble)
        
        try container.encode(inteiro, forKey: .startDate)
        try container.encode(self.totalDistance, forKey: .totalDistance)
        try container.encode(self.totalTime, forKey: .totalTime)
        
        
    }
    
}

