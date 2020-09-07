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

class Submission: NSManagedObject, JsonParseable {
    
    public static let MyEntityName = "Submission"
    
    @NSManaged var trigger: Trigger
    @NSManaged var triggeredDate: Date
    @NSManaged var uid: String
    @NSManaged var answerDate: Date
    @NSManaged var answers: NSSet //[answer]
    
    enum CodingKeysSpec: String, CodingKey {
        case trigger
        case triggeredDate
        case uid
        case answerDate
        case answers
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: Submission.MyEntityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()

        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        if  let trigger = try container.decodeIfPresent(TriggerPolymorphicDecoder.self, forKey: .trigger),
            let triggeredDate = try container.decodeIfPresent(Double.self, forKey: .triggeredDate),
            let uid = try container.decodeIfPresent(String.self, forKey: .uid),
            let answerDate = try container.decodeIfPresent(Double.self, forKey: .answerDate),
            let answers = try container.decodeIfPresent([Answer].self, forKey: .answers) {
            
            self.trigger = TriggerPolymorphicDecoder.decodePlymorphicTrigger(item: trigger)!
            self.triggeredDate = Date(timeIntervalSince1970: triggeredDate.divided(by: Double(1000)))
            self.uid = uid
            self.answerDate = Date(timeIntervalSince1970: answerDate.divided(by: Double(1000)))
            self.answers = NSSet(array: answers)
        }
    }
    
    convenience init(trigger: Trigger, triggeredDate: Date, uid: String, answers: NSSet, context: NSManagedObjectContext) {
        UserInfo.ContextSemaphore.wait()
        let entity = NSEntityDescription.entity(forEntityName: Submission.MyEntityName, in: context)!
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        self.trigger=trigger
        self.triggeredDate=triggeredDate
        self.uid=uid
        self.answers=answers
        self.answerDate = Date()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysSpec.self)
        try container.encode(trigger, forKey: .trigger)
        try container.encode(triggeredDate.timeIntervalSince1970.multiplied(by: Double(1000)), forKey: .triggeredDate)
        try container.encode(answerDate.timeIntervalSince1970.multiplied(by: Double(1000)), forKey: .answerDate)
        try container.encode(uid, forKey: .uid)
        try container.encode(answers.allObjects as! [Answer], forKey: .answers)
    }
    
}
