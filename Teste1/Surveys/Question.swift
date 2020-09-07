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

class Question: NSManagedObject, JsonParseable {
    
    public static let MyEntityName = "Question"
    
    @NSManaged var question: [String: String]
    @NSManaged var answers: [String: [String]]
    @NSManaged var questionId: String
    @NSManaged var order: Int16
    @NSManaged var languageOfCreation: String
    
    @NSManaged var questionTypeValue: String
    
    var questionType: QuestionType {
        get {
            return QuestionType(rawValue: self.questionTypeValue) ?? QuestionType.paragraph
        }
        set {
            self.questionTypeValue = newValue.rawValue
        }
    }
    
    public enum QuestionType: String {
        case shortText
        case multipleChoice
        case scale
        case checkboxes
        case grid
        case paragraph
        case dropdown
        case yesNo
    }
    
    enum CodingKeysSpec: String, CodingKey {
        case question
        case answers
        case questionId
        case questionType
        case languageOfCreation
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: Question.MyEntityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        
        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        if  let question = try container.decodeIfPresent([String: String].self, forKey: .question),
            let answers = try container.decodeIfPresent([String: [String]].self, forKey: .answers),
            let questionId = try container.decodeIfPresent(String.self, forKey: .questionId),
            let questionType = try container.decodeIfPresent(String.self, forKey: .questionType),
            let languageOfCreation = try container.decodeIfPresent(String.self, forKey: .languageOfCreation) {
            
            self.question = question
            self.answers = answers
            self.questionId = questionId
            switch (questionType) {
            case QuestionType.shortText.rawValue:
                self.questionType = QuestionType.shortText
            case QuestionType.multipleChoice.rawValue:
                self.questionType = QuestionType.multipleChoice
            case QuestionType.scale.rawValue:
                self.questionType = QuestionType.scale
            case QuestionType.checkboxes.rawValue:
                self.questionType = QuestionType.checkboxes
            case QuestionType.grid.rawValue:
                self.questionType = QuestionType.grid
            case QuestionType.paragraph.rawValue:
                self.questionType = QuestionType.paragraph
            case QuestionType.dropdown.rawValue:
                self.questionType = QuestionType.dropdown
            case QuestionType.yesNo.rawValue:
                self.questionType = QuestionType.yesNo
            default:
                self.questionType = QuestionType.shortText
            }
            self.languageOfCreation = languageOfCreation
            self.order=0
        }
    }
    
    func getQuestion(language: String? = nil) -> String {
        
        if  let lang1 = language,
            let rtlang = self.question[lang1]{
            return rtlang
        }
        let lang = Languages.getLanguageForSMCode(smartphoneID: MotivUser.getInstance()?.language ?? Languages.getLanguages().first!.smartphoneID)
        return self.question[(lang?.woortiID) ?? ""] ?? self.question[self.languageOfCreation] ?? ""
    }
    
    func getAnswers(language: String? = nil) -> [String] {
        if  let lang1 = language,
            let rtlang = self.answers[lang1] {
            
            return rtlang
        }
        let lang = Languages.getLanguageForSMCode(smartphoneID: MotivUser.getInstance()?.language ?? Languages.getLanguages().first!.smartphoneID)
        return self.answers[(lang?.woortiID) ?? ""] ?? self.answers[self.languageOfCreation] ?? [String]()
    }
    
    func hasLang(language: String) -> Bool {
        return question[language] == nil || answers[language] == nil
    }
    
    
    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeysSpec.self)
//        try container.encode(startDate.timeIntervalSince1970.multiplied(by: Double(1000)), forKey: .startDate)
//        try container.encode(endDate?.timeIntervalSince1970.multiplied(by: Double(1000)), forKey: .endDate)
//        //        try container.encode(avLocation, forKey: .avLocation)
//        try container.encode(avLocation?.location?.coordinate.latitude, forKey: .avLocationLat)
//        try container.encode(avLocation?.location?.coordinate.longitude, forKey: .avLocationLon)
//        try container.encode(getLocationsortedList(), forKey: .locations)
//        try container.encode("WaitingEvent", forKey: .type)
    }
    
    convenience init(startDate: Date, context: NSManagedObjectContext) {
        UserInfo.ContextSemaphore.wait()
        let entity = NSEntityDescription.entity(forEntityName: Question.MyEntityName, in: context)!
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
    }
    
}
