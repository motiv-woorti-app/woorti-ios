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

class RadioButtonQuestionTableViewCell: GenericQuestionTableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBOutlet weak var RadioButtonTableView: UITableView!
    @IBOutlet weak var RadioTableViewHeight: NSLayoutConstraint!
    
    var selectedCells = [RadioButtonLineTableViewCell]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.RadioButtonTableView.register(UINib(nibName: "RadioButtonLineTableViewCell", bundle: nil), forCellReuseIdentifier: "RadioButtonLineTableViewCell")
        self.loadHeight()
        self.RadioButtonTableView.delegate = self
        self.RadioButtonTableView.dataSource = self
        //self.RadioButtonTableView.rowHeight = UITableViewAutomaticDimension
        self.RadioButtonTableView.tableFooterView = UIView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func loadQuestionCell(question: Question, visible: Bool, parent: SurveyViewController, index: Int, language: String) {
        print("RadioCell", "loaded question")
        super.loadQuestionCell(question: question, visible: visible, parent: parent, index: index, language: language)
        self.TitleLabel.text = question.getQuestion(language: language)
        self.loadHeight()
        self.RadioButtonTableView.reloadData()
    }
    
    override func answer() -> [Answer] {
        var answers = [Answer]()
        if  let ctx = UserInfo.context,
            let q = question {
            for cell in selectedCells {
                if cell.isCellSelected {
//                    answers.append(Answer(QuestionID: q.questionId, QuestionType: q.questionType.rawValue, answer: cell.getAnswerText(), context: ctx))
                    answers.append(Answer(QuestionID: q.questionId, answerNumbers: [Double(q.getAnswers().index(of: cell.getAnswerText()) ?? -1)], answer: cell.getAnswerText(), questionType: q.questionType.rawValue, context: ctx))
                    break
                }
            }
        }
        return answers
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.question?.getAnswers().count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RadioButtonLineTableViewCell") as! RadioButtonLineTableViewCell
        
        if let answer = question?.getAnswers()[indexPath.row] {
            let isSelected = selectedCells.filter { (cell) -> Bool in
                (cell.AnswerLabel.text ?? "") == answer
            }.count > 0
            
            cell.loadAnswer(answer: answer, isSelected: isSelected)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? RadioButtonLineTableViewCell {
            let selectedWithSameAnswers = selectedCells.filter { (selectedCell) -> Bool in
                (selectedCell.AnswerLabel.text ?? "") == (cell.AnswerLabel.text ?? "0")
                }
            
            let isSelected = selectedWithSameAnswers.count > 0
            
            for selectedCell in selectedCells {
                selectedCell.deselectCell()
            }
            
            if !isSelected {
                cell.selectCell()
                selectedCells = [cell]
            } else {
                selectedCells = [RadioButtonLineTableViewCell]()
            }
            
//            self.question?.answers = selectedCells.map({ (cell) -> String in
//                return cell.AnswerLabel.text ?? ""
//            })
            
            self.parent?.answeredQuestion(index: self.index + 1)
        }
    }
    
    override func setVisibility() {
        super.setVisibility()
        if self.visible {
            DispatchQueue.main.async {
                self.RadioButtonTableView.delegate = self
                self.RadioButtonTableView.dataSource = self
                self.RadioButtonTableView.reloadData()
                self.RadioButtonTableView.layoutSubviews()
                self.RadioButtonTableView.layoutIfNeeded()
            }
        }
//        self.RadioButtonTableView.reloadData()
    }
    
    func loadHeight() {
        var height = self.RadioButtonTableView.estimatedRowHeight * CGFloat(self.question?.getAnswers().count ?? 0)
        self.RadioTableViewHeight.constant = height
        height += self.TitleLabel.bounds.height
        print("Height for Radio Button: \(self.RadioButtonTableView.estimatedRowHeight) \(CGFloat(self.question?.getAnswers().count ?? 0)) \(self.TitleLabel.bounds.height) \(height)")
        
        setDrawHeight(height: Int(height))
    }
}
