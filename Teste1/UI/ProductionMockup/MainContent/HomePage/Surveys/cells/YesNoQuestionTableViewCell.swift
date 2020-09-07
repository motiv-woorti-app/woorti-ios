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

import UIKit

class YesNoQuestionTableViewCell: GenericQuestionTableViewCell {
    
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    var response = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        GenericQuestionTableViewCell.loadStandardButton(button: yesButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "Yes", disabled: false)
        GenericQuestionTableViewCell.loadStandardButton(button: noButton, color: GenericQuestionTableViewCell.RedButtonColor, text: "No", disabled: false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func SubmitYesResponse(_ sender: Any) {
        self.parent?.answeredQuestion(index: self.index + 1)
        response = true
//        self.question?.answers = ["yes"]
    }
    
    override func answer() -> [Answer] {
        var answers = [Answer]()
        if  let ctx = UserInfo.context,
            let q = question {
//            answers.append(Answer(QuestionID: q.questionId, QuestionType: q.questionType.rawValue, answer: response.description, context: ctx))
            var answer = [Double]()
            if response {
                answer.append(Double(1))
            } else {
                answer.append(Double(0))
            }
            
            
            answers.append(Answer(QuestionID: q.questionId, answerNumbers: answer, answer: response.description, questionType: q.questionType.rawValue, context: ctx))
        }
        return answers
    }
    
    @IBAction func SubmitNoResponse(_ sender: Any) {
        self.parent?.answeredQuestion(index: self.index + 1)
        response = false
//        self.question?.answers = ["no"]
    }
    
    override func loadQuestionCell(question: Question, visible: Bool, parent: SurveyViewController, index: Int, language: String) {
        super.loadQuestionCell(question: question, visible: visible, parent: parent, index: index, language: language)
        self.Title.text = question.getQuestion(language: language)
        self.setDrawHeight(height: 118)
    }
}
