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

class SurveyPageTableViewCellScale: SurveyPageTableViewCell {

    @IBOutlet weak var QuestionText: UILabel!
    @IBOutlet weak var numberScaler: UISlider!
    @IBOutlet weak var ResponseLabel: UILabel!
    @IBOutlet weak var minValueLabel: UILabel!
    @IBOutlet weak var maxValueLAbel: UILabel!
    
    private var question: Question?
    static let reuseIdentifier = "SurveyPageTableViewCellScale"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func setQuestion(question: Question, tv: UITableView, language: String){
        self.tv=tv
        QuestionText.adjustsFontForContentSizeCategory = true
        ResponseLabel.adjustsFontForContentSizeCategory = true
        ResponseLabel.text = ""
        
        self.question = question
        if self.QuestionText != nil {
            self.QuestionText.text=question.getQuestion(language: language)
        }
        setSlider()
    }
    
    private func setSlider(){
        numberScaler.maximumValue = 5
        numberScaler.minimumValue = 0
        
        minValueLabel.text = "0"
        maxValueLAbel.text = "5"
        
        if let answers = self.question?.getAnswers() {
            if answers.count > 1 {
                if let min = Float(answers[0]),
                    let max = Float(answers[1]) {
                    numberScaler.minimumValue = min
                    numberScaler.maximumValue = max
                    
                    
                }
                minValueLabel.text = answers[0]
                maxValueLAbel.text = answers[1]
            }
        }
        
        numberScaler.value = (numberScaler.maximumValue - numberScaler.minimumValue)/2
    }
    
    override func answer() -> [Answer] {
        var answers = [Answer]()
        if  let ctx = UserInfo.context,
            let q = question{
//            answers.append(Answer(QuestionID: q.questionId, QuestionType: q.questionType.rawValue, answer: ResponseLabel.text ?? "", context: ctx))
            answers.append(Answer(QuestionID: q.questionId, answerNumbers: [Double(ResponseLabel.text ?? "0") ?? Double(0)], answer: ResponseLabel.text ?? "", questionType: q.questionType.rawValue, context: ctx))
        }
        return answers
        
    }
    
    @IBAction func onChangeSlider(_ sender: Any) {
        ResponseLabel.text = String(Int(numberScaler.value))
    }
    
    override func getSize() -> CGFloat {
        return CGFloat(146)
    }
    
}
