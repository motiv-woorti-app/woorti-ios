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

/**
* Used to trigger survey on different user actions (end trip, start trip, reporting)
*/
class Trigger: NSManagedObject, JsonParseable {
    
    
    public static let MyEntityName = "Trigger"
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: Trigger.MyEntityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()

    }
    
    func triggerType() -> String {
        return "Trigger"
    }
    
    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeysSpec.self)
        print("\n\nencoding Trigger\n\n")
    }
    
}


class TriggerEvent: Trigger {
    
    @NSManaged private var triggerTypeValue: String
    
    var trigger: TriggerEvents? {
        get {
            return TriggerEvents(rawValue: self.triggerTypeValue)!
        }
        set {
            self.triggerTypeValue = (newValue?.rawValue)!
        }
        
    }
    public static let entityName = "TriggerEvent"
    
    enum CodingKeysSpec: String, CodingKey {
        case trigger
    }
    
    override func triggerType() -> String {
        return "TriggerEvent"
    }
    
    enum TriggerEvents: String {
        case endTrip
        case startTrip
        case endSearch
        case userOpensApp
        case reporting
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: TriggerEvent.entityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        if  let event = try container.decodeIfPresent(String.self, forKey: .trigger){
            switch (event.lowercased()) {
            case TriggerEvents.endTrip.rawValue.lowercased():
                self.trigger = TriggerEvents.endTrip
            case TriggerEvents.startTrip.rawValue.lowercased():
                self.trigger = TriggerEvents.startTrip
            case TriggerEvents.endSearch.rawValue.lowercased():
                self.trigger = TriggerEvents.endSearch
            case TriggerEvents.userOpensApp.rawValue.lowercased():
                self.trigger = TriggerEvents.userOpensApp
            case TriggerEvents.userOpensApp.rawValue.lowercased():
                self.trigger = TriggerEvents.userOpensApp
            case TriggerEvents.reporting.rawValue.lowercased():
                self.trigger = TriggerEvents.reporting
            default:
                self.trigger = TriggerEvents.startTrip
            }
        }
    }
    
    convenience init(event: String, context: NSManagedObjectContext) {
        UserInfo.ContextSemaphore.wait()
        let entity = NSEntityDescription.entity(forEntityName: TriggerEvent.entityName, in: context)!
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        switch (event.lowercased()) {
        case TriggerEvents.endTrip.rawValue.lowercased():
            self.trigger = TriggerEvents.endTrip
        case TriggerEvents.startTrip.rawValue.lowercased():
            self.trigger = TriggerEvents.startTrip
        case TriggerEvents.endSearch.rawValue.lowercased():
            self.trigger = TriggerEvents.endSearch
        case TriggerEvents.userOpensApp.rawValue.lowercased():
            self.trigger = TriggerEvents.userOpensApp
        case TriggerEvents.reporting.rawValue.lowercased():
            self.trigger = TriggerEvents.reporting
        default:
            self.trigger = TriggerEvents.startTrip
        }
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}

class TriggerOnce: Trigger {
    public static let entityName = "TriggerOnce"
    @NSManaged var timestamp: Date?
    @NSManaged var triggered: Bool
    
    enum CodingKeysSpec: String, CodingKey {
        case timestamp
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: TriggerOnce.entityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        if  let date = try container.decodeIfPresent(Double.self, forKey: .timestamp){
            
           self.timestamp = Date(timeIntervalSince1970: date / Double(1000))
        }
    }
    
    func wasTriggered() -> Bool {
        return self.triggered ?? false
    }
    
    convenience init(timestamp: Double, context: NSManagedObjectContext) {
        UserInfo.ContextSemaphore.wait()
        let entity = NSEntityDescription.entity(forEntityName: TriggerOnce.entityName, in: context)!
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        self.timestamp = Date(timeIntervalSince1970: timestamp.divided(by: Double(1000)))
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    override func triggerType() -> String {
        return "TriggerOnce"
    }
}

class TriggerRepeatable: Trigger {
    public static let entityName = "TriggerRepeatable"
    @NSManaged var startday: Date?
    @NSManaged var timeInBetween: Double
    @NSManaged var triggered: [Date]?
    
    enum CodingKeysSpec: String, CodingKey {
        case startday
        case timeInBetween
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: TriggerRepeatable.entityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        if  let date = try container.decodeIfPresent(Double.self, forKey: .startday),
            let timeInBetween = try container.decodeIfPresent(Double.self, forKey: .timeInBetween){
            
            self.startday = Date(timeIntervalSince1970: date.divided(by: Double(1000)))
            self.timeInBetween = timeInBetween
        }
    }
    
    convenience init(startday: Double, timeInBetween: Double, context: NSManagedObjectContext) {
        UserInfo.ContextSemaphore.wait()
        let entity = NSEntityDescription.entity(forEntityName: TriggerOnce.entityName, in: context)!
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        self.startday = Date(timeIntervalSince1970: startday.divided(by: Double(1000)))
        self.timeInBetween = timeInBetween
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    override func triggerType() -> String {
        return "TriggerRepeatable"
    }
}

struct TriggerPolymorphicDecoder: JsonParseable {
    // event
    var trigger: String?
    // once
    var timestamp: Double?
    // repeatable
    var startday: Double?
    var timeInBetween: Double?
    
    enum CodingKeysSpec: String, CodingKey {
        case trigger
        case timestamp
        case startday
        case timeInBetween
    }
    
    
    static func decodePlymorphicTrigger(item: TriggerPolymorphicDecoder) -> Trigger? {
        if let ctx = UserInfo.context {
            if item.trigger != nil {
                let eventTrigger = TriggerEvent(event: item.trigger!,context: ctx)
                
                return eventTrigger
            } else if item.timestamp != nil {
                let onceTrigger = TriggerOnce(timestamp: item.timestamp!, context: ctx)
                
                return onceTrigger
            } else if item.startday != nil && item.timeInBetween != nil  {
                let repeatableTrigger = TriggerRepeatable(startday: item.startday!, timeInBetween: item.timeInBetween!, context: ctx)
                return repeatableTrigger
            } else {
                let errorTrigger = TriggerEvent(event: "",context: ctx) // defaults to startTrip
                Crashlytics.sharedInstance().recordCustomExceptionName("Trigger not identified", reason: "PolymorphicTrigger without the required: " + item.toJsonString(), frameArray: [CLSStackFrame]())
                return errorTrigger
            }
        }
        return nil
    }
    
    
}
