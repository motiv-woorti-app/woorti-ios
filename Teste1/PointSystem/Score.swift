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
* Class to represent a score
* var id: code of a specific type of score
* var value: value that represents the score
*/
class Score: NSManagedObject, NSCoding, JsonParseable {
    @NSManaged private var id: String
    @NSManaged private var value: Double
    
    public static let entityName = "Score"
    
    enum CodingKeysSpec: String, CodingKey {
        case id
        case value
    }
    
    convenience init(id: String, value: Double, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: Score.entityName, in: context)!
        self.init(entity: entity, insertInto: context)
        self.id = id
        self.value = value
    }
    
    required convenience init(coder decoder: NSCoder) {
        let id = (decoder.decodeObject(forKey: CodingKeysSpec.id.rawValue) as? String ?? "")
        var value : Double
        switch(id){
        case TripScored.ids.purposeOfTrips.rawValue:
            value = (decoder.decodeObject(forKey: CodingKeysSpec.value.rawValue) as? Double ?? Double(20))
        case TripScored.ids.completeAllInfo.rawValue:
            value = (decoder.decodeObject(forKey: CodingKeysSpec.value.rawValue) as? Double ?? Double(15))
        case LegScored.ids.activities.rawValue:
            value = (decoder.decodeObject(forKey: CodingKeysSpec.value.rawValue) as? Double ?? Double(5))
        case LegScored.ids.modeValidated.rawValue:
            value = (decoder.decodeObject(forKey: CodingKeysSpec.value.rawValue) as? Double ?? Double(5))
        case LegScored.ids.worthwhilenessElements.rawValue:
            value = (decoder.decodeObject(forKey: CodingKeysSpec.value.rawValue) as? Double ?? Double(5))
        default:
            value = (decoder.decodeObject(forKey: CodingKeysSpec.value.rawValue) as? Double ?? Double(0))
        }
        self.init(id: id, value: value, context: UserInfo.context!)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: CodingKeysSpec.id.rawValue)
        coder.encode(value, forKey: CodingKeysSpec.value.rawValue)
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysSpec.self)
        try container.encode(id, forKey: .id)
        try container.encode(value, forKey: .value)
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: Score.entityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        if  let id = try container.decodeIfPresent(String.self, forKey: .id),
            let value = try container.decodeIfPresent(Double.self, forKey: .value) {
            
            self.id = id
            self.value = value
            
        }
    }
    
    public static func getScore(id: String, value: Double) -> Score? {
        var score: Score?
        if let ctx = UserInfo.context {
            UserInfo.ContextSemaphore.wait()
            score = Score(id: id, value: value, context: ctx)
            UserInfo.ContextSemaphore.signal()
        }
        return score
    }
    
    public func getScore() -> Double{
        return self.value
    }
    
    public func getId() -> String {
        return self.id
    }
    
    public func setValue(value: Double) -> Double {
        var score = value - self.value
        self.value = value
        return score
    }
    
    public func isScore(id: String) -> Bool {
        return self.id == id
    }
    
}
