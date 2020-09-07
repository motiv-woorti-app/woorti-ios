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

class CheckBoxQuestionTableViewCell: GenericQuestionTableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var CheckboxesTableView: UITableView!
    @IBOutlet weak var DoneButton: UIButton!
    
    @IBOutlet weak var checkBoxTableViewHeight: NSLayoutConstraint!
    var selectedCells = [CheckboxLineTableViewCell]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.CheckboxesTableView.register(UINib(nibName: "CheckboxLineTableViewCell", bundle: nil), forCellReuseIdentifier: "CheckboxLineTableViewCell")
        self.loadHeight()
        self.CheckboxesTableView.dataSource = self
        self.CheckboxesTableView.delegate = self
        
        GenericQuestionTableViewCell.loadStandardButton(button: DoneButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "Done", disabled: false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func answer() -> [Answer] {
        var answers = [Answer]()
        if  let ctx = UserInfo.context,
            let q = question {
            var answerNumbers = [Double]()
            var i = 0
            for cell in selectedCells {
                if cell.AnswerSelected {
//                    answers.append(Answer(QuestionID: q.questionId, QuestionType: q.questionType.rawValue, answer: cell.getAnswerText(), context: ctx))
//                    break
                    answerNumbers.append(Double(i))
                }
                i+=1
            }
            answers.append(Answer(QuestionID: q.questionId, answerNumbers: answerNumbers, answer: "", questionType: q.questionType.rawValue, context: ctx))
        }
        return answers
    }
    
    override func loadQuestionCell(question: Question, visible: Bool, parent: SurveyViewController, index: Int, language: String) {
        super.loadQuestionCell(question: question, visible: visible, parent: parent, index: index, language: language)
        self.Title.text = question.getQuestion(language: language)
        self.loadHeight()
        self.CheckboxesTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.question?.getAnswers().count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckboxLineTableViewCell") as! CheckboxLineTableViewCell
        
        if let answer = question?.getAnswers()[indexPath.row] {
            let isSelected = selectedCells.filter { (cell) -> Bool in
                (cell.Answer.text ?? "") == answer
                }.count > 0
            
            cell.loadAnswer(answer: answer, isSelected: isSelected)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CheckboxLineTableViewCell {
            let selectedWithSameAnswers = selectedCells.filter { (selectedCell) -> Bool in
                (selectedCell.Answer.text ?? "") == (cell.Answer.text ?? "0")
            }
            
            let isSelected = selectedWithSameAnswers.count > 0
            
            if isSelected {
                cell.deselectCell()
                self.selectedCells = selectedCells.filter { (selectedCell) -> Bool in
                    (selectedCell.Answer.text ?? "") != (cell.Answer.text ?? "")
                }

            } else {
                cell.selectCell()
                selectedCells.append(cell)
            }
        }
    }
    
    @IBAction func DoneSubmit(_ sender: Any) {
//        self.question?.answers = self.selectedCells.map({ (cell) -> String in
//            return cell.Answer.text ?? ""
//        })
        self.parent?.answeredQuestion(index: self.index + 1)
    }
    
    override func setVisibility() {
        super.setVisibility()
        self.CheckboxesTableView.reloadData()
    }
    
    func loadHeight() {
        var height = self.CheckboxesTableView.estimatedRowHeight * CGFloat(self.question?.getAnswers().count ?? 0)
        self.checkBoxTableViewHeight.constant = height
        height += self.Title.bounds.height + self.DoneButton.bounds.height + 10
        print("\(self.CheckboxesTableView.estimatedRowHeight) \(CGFloat(self.question?.getAnswers().count ?? 0)) \(self.Title.bounds.height) \(height)")
        
        setDrawHeight(height: Int(height))
    }
}
