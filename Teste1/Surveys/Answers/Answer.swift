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

class Answer: NSManagedObject, JsonParseable {
    
    public static let MyEntityName = "Answer"
    
    @NSManaged var questionID: String
    @NSManaged var answerNumbers: [Double]
    @NSManaged var answerText: String
    @NSManaged var questionType: String
    
    enum CodingKeysSpec: String, CodingKey {
        case questionID
        case questionType
//        case answerNumbers
//        case answerText
        case answer
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = UserInfo.context else { throw NSError() }
        UserInfo.ContextSemaphore.wait()
        guard let entity = NSEntityDescription.entity(forEntityName: Answer.MyEntityName, in: context) else {
            UserInfo.ContextSemaphore.signal()
            throw NSError()
        }
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        
        let container = try decoder.container(keyedBy: CodingKeysSpec.self)
        if  let QuestionID = try container.decodeIfPresent(String.self, forKey: .questionID),
            let QuestionType = try container.decodeIfPresent(String.self, forKey: .questionType),

            let answerText = try container.decodeIfPresent(String.self, forKey: .answer) {

            self.questionID = QuestionID
            self.questionType = QuestionType
            self.answerNumbers = [Double]()
            self.answerText = answerText
        }
    }
    
    convenience init(QuestionID: String, answerNumbers: [Double], answer: String, questionType: String, context: NSManagedObjectContext) {
        UserInfo.ContextSemaphore.wait()
        let entity = NSEntityDescription.entity(forEntityName: Answer.MyEntityName, in: context)!
        self.init(entity: entity, insertInto: context)
        UserInfo.ContextSemaphore.signal()
        self.questionID = QuestionID
        self.answerNumbers = answerNumbers
        self.answerText = answer
        self.questionType = questionType
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysSpec.self)
        try container.encode(questionID, forKey: .questionID)
        try container.encode(questionType, forKey: .questionType)


        switch questionType {
        case Question.QuestionType.scale.rawValue, Question.QuestionType.dropdown.rawValue, Question.QuestionType.multipleChoice.rawValue:
            try container.encode(Int(self.answerNumbers.first!), forKey: .answer)
            break
        case Question.QuestionType.paragraph.rawValue, Question.QuestionType.shortText.rawValue:
            try container.encode(self.answerText, forKey: .answer)
            break
        case Question.QuestionType.yesNo.rawValue:
            if self.answerNumbers.first ?? Double(0) == Double(1){
                try container.encode(true, forKey: .answer)
            } else {
                try container.encode(false, forKey: .answer)
            }
            break
        case Question.QuestionType.checkboxes.rawValue:
            try container.encode(self.answerNumbers, forKey: .answer)
            break
        default:
            try container.encode("unknown type", forKey: .answer)
        }
    }
    
}
