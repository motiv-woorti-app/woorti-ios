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

class Survey: NSManagedObject, JsonParseable {

    public static let MyEntityName = "Survey"
    
    @NSManaged var surveyID: Double
    @NSManaged var version: Double
    @NSManaged var globalSurveyTimestamp: Double
    @NSManaged var startDate: Date?
    @NSManaged var stopDate: Date?
    @NSManaged var deletedSurvey: Bool
    @NSManaged var urgent: Bool
    @NSManaged var trigger: Trigger?
    @NSManaged var launches: Launch // NSSet? // [Launch]?
    @NSManaged var questions: NSSet? // = [Question]()
    @NSManaged var triggeredDates: [Date]
    @NSManaged var defaultLanguage: String
    
    @NSManaged var estimatedDuration: Double
    
    
    @NSManaged var surveyName: String
    @NSManaged var surveyDescription: String
    @NSManaged var surveyPoints: Double
    @NSManaged var surveyType: String
    @NSManaged var campaigns: [Double]

    enum CodingKeysSpec: String, CodingKey {
        case surveyID
        case version
        case globalSurveyTimestamp
        case startDate
        case stopDate
        case deleted
        case urgent
        case trigger
        case launch
        case questions
        case defaultLanguage
        case estimatedDuration
        
        case surveyName
        case description
        case surveyPoints
        case surveyType
        case campaigns
    }

    required convenience init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        if  let surveyID = try container.decodeIfPresent(Double.self, forKey: .surveyID),
            let version = try container.decodeIfPresent(Double.self, forKey: .version),
            let globalSurveyTimestamp = try container.decodeIfPresent(Double.self, forKey: .globalSurveyTimestamp),
            let startDate = try container.decodeIfPresent(Double.self, forKey: .startDate),
            let stopDate = try container.decodeIfPresent(Double.self, forKey: .stopDate),
            let deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted),
            let urgent = try container.decodeIfPresent(Bool.self, forKey: .urgent),

            let trigger = try container.decodeIfPresent(TriggerPolymorphicDecoder.self, forKey: .trigger),
            let launches = try container.decodeIfPresent(Launch.self, forKey: .launch),
            let questions = try container.decodeIfPresent([Question].self, forKey: .questions),
            let defaultLanguage = try container.decodeIfPresent(String.self, forKey: .defaultLanguage){
        
        
            
            guard let context = UserInfo.context else { throw NSError() }
            UserInfo.ContextSemaphore.wait()
            guard let entity = NSEntityDescription.entity(forEntityName: Survey.MyEntityName, in: context) else {
                UserInfo.ContextSemaphore.signal()
                throw NSError()
            }
            self.init(entity: entity, insertInto: context)
            UserInfo.ContextSemaphore.signal()
            
            self.surveyID = surveyID
            self.version = version
            self.globalSurveyTimestamp = globalSurveyTimestamp
            self.startDate = Date(timeIntervalSince1970: startDate.divided(by: Double(1000)))
            self.stopDate = Date(timeIntervalSince1970: stopDate.divided(by: Double(1000)))
            self.deletedSurvey = deleted
            self.urgent = urgent
            self.trigger = TriggerPolymorphicDecoder.decodePlymorphicTrigger(item: trigger)!
            self.launches = launches
            self.questions = NSSet(array: setQuestionsOrder(questions: questions))
            self.triggeredDates = [Date]()
            self.defaultLanguage = defaultLanguage
            
            //Default value for estimated
            self.estimatedDuration = 15
            if container.contains(.estimatedDuration){
                if let estimatedDuration = try container.decodeIfPresent(Double.self, forKey: .estimatedDuration){
                    self.estimatedDuration = estimatedDuration
                }
            }
            
            
            
            self.surveyName = try container.decodeIfPresent(String.self, forKey: .surveyName) ?? ""
            self.surveyDescription = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
            self.surveyPoints = try container.decodeIfPresent(Double.self, forKey: .surveyPoints) ?? Double(0)
            self.surveyType = try container.decodeIfPresent(String.self, forKey: .surveyType) ?? ""
            self.campaigns = try container.decodeIfPresent([Double].self, forKey: .campaigns) ?? [Double]()
        } else {
            throw NSError(domain: "decoding Surevy", code: 1, userInfo: ["Container" : container])
        }
    }
    
    private func setQuestionsOrder(questions: [Question]) -> [Question] {
        var i = 0
        for question in questions {
            question.order = Int16(i)
            i += 1
        }
        return questions
    }
    
    public func getquestionsOrdered() -> [Question] {
        var qs = self.questions?.allObjects as! [Question]
        qs.sort { (q1, q2) -> Bool in
            return q1.order < q2.order
        }
        return qs
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
    
    public func chooseLanguage(language: String) -> String {
        for question in getquestionsOrdered() {
            if !question.hasLang(language: language) {
                return self.defaultLanguage
            }
        }
        return language
    }
    
    func triggerSurvey(date: Date){
        self.triggeredDates.append(date)
    }
    
    func isTriggered() -> Bool {
        return triggeredDates.count > 0
    }
    
    func getTriggeredDates() -> [Date] {
        return self.triggeredDates
    }
    
    func isSurveyValid() -> Bool {
        let date = Date()
        if let startDate = self.startDate, let stopDate = self.stopDate {
            return startDate <= date && stopDate >= date
        }
        return true
    }
}

