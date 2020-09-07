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

class AnsweredSurvey: NSManagedObject, JsonParseable {
    
    public static let MyEntityName = "AnsweredSurvey"
    
    @NSManaged var surveyID: Double
    @NSManaged var version: Double
//    @NSManaged var submissions: NSSet //[answer]
    @NSManaged var uid: String
    @NSManaged var triggerDate: Double
    @NSManaged var answerDate: Double
    @NSManaged var lang: String
    @NSManaged var answers: NSSet? //[answer]
    
    var reportingID: String = ""
    var reportingOS: String = ""
    
    enum CodingKeysSpec: String, CodingKey {
        case surveyID
        case version
//        case submissions
        case uid
        case triggerDate
        case answerDate
        case lang
        case answers
        case reportingID
        case reportingOS
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: AnsweredSurvey.MyEntityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()

        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        if  let surveyID = try container.decodeIfPresent(Double.self, forKey: .surveyID),
            let version = try container.decodeIfPresent(Double.self, forKey: .version),

              let uid = try container.decodeIfPresent(String.self, forKey: .uid),
              let triggerDate = try container.decodeIfPresent(Double.self, forKey: .triggerDate),
              let answerDate = try container.decodeIfPresent(Double.self, forKey: .answerDate),
              let lang = try container.decodeIfPresent(String.self, forKey: .lang),
              let answers = try container.decodeIfPresent([Answer].self, forKey: .answers) {
            
            self.surveyID = surveyID
            self.version = version

            self.uid = uid
            self.triggerDate = triggerDate
            self.answerDate = answerDate
            self.lang = lang
            self.answers = NSSet(array: answers)
        }
    }
    
    convenience init(surveyID: Double, version: Double, uid: String, triggerDate: Double, answerDate: Double, lang: String, context: NSManagedObjectContext) {
        UserInfo.ContextSemaphore.wait()
        let entity = NSEntityDescription.entity(forEntityName: AnsweredSurvey.MyEntityName, in: context)!
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        self.surveyID = surveyID
        self.version = version
        self.uid = uid
        self.triggerDate = triggerDate
        self.answerDate = answerDate
        self.lang = lang
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysSpec.self)
        try container.encode(surveyID, forKey: .surveyID)
        try container.encode(version, forKey: .version)

        try container.encode(uid, forKey: .uid)
        try container.encode(triggerDate, forKey: .triggerDate)
        try container.encode(answerDate, forKey: .answerDate)
        try container.encode(lang, forKey: .lang)
        try container.encode((answers?.allObjects ?? [Answer]()) as! [Answer], forKey: .answers)
        if self.reportingID.count > 0 {
            try container.encode(reportingID, forKey: .reportingID)
            try container.encode(reportingOS, forKey: .reportingOS)
        }
    }
    
   
}

