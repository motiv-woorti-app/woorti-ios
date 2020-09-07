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

/*
 * Page with a survey
 * User answers the questions and submits. 
 */
class SurveyPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    private var triggeredSurvey: TriggeredSurvey?
    @IBOutlet weak var QuestionsTable: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    private var cells = [SurveyPageTableViewCell]()
    
    func setTriggeredSurvey(triggeredSurvey: TriggeredSurvey) {
        self.triggeredSurvey = triggeredSurvey
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cells = [SurveyPageTableViewCell]()
        return triggeredSurvey?.survey.questions?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        //initialize the cell
        if let question = triggeredSurvey?.survey.getquestionsOrdered()[indexPath.row] {
            if let cell = SurveyPageTableViewCell.getSurveyCellFromQuestion(question: question, tableView: tableView, indexPath: indexPath) {
                cell.setQuestion(question: question, tv: tableView, language: (triggeredSurvey?.survey.chooseLanguage(language: (MotivUser.getInstance()?.language) ?? Languages.getLanguages().first!.smartphoneID))!)
                if indexPath.row < cells.count {
                    cells[indexPath.row] = cell
                } else {
                    cells.insert(cell, at: indexPath.row)
                }
            
                return cell
            }
        }
        
        // error handling
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SurveyPageTableViewCell.parentReuseIdentifier, for: indexPath) as? SurveyPageTableViewCell else {
            fatalError("The dequeued cell is not an instance of SurveyToFillTableViewCell.")
        }
        if let question = triggeredSurvey?.survey.getquestionsOrdered()[indexPath.row] {
            cell.setQuestion(question: question, tv: tableView, language: (triggeredSurvey?.survey.chooseLanguage(language: (MotivUser.getInstance()?.language) ?? Languages.getLanguages().first!.smartphoneID))!)
            if indexPath.row < cells.count {
                cells[indexPath.row] = cell
            } else {
                cells.insert(cell, at: indexPath.row)
            }
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if cells.endIndex > indexPath.row {
            return cells[indexPath.row].getSize()
        }
        return 80
    }
    
    @IBAction func clickSubmitSurvey(_ sender: Any) {
        submitAnswers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Answer Survey"
        QuestionsTable.dataSource = self
        QuestionsTable.delegate = self
        QuestionsTable.estimatedRowHeight = 300
        QuestionsTable.rowHeight = UITableViewAutomaticDimension
        QuestionsTable.allowsSelection = false;
        QuestionsTable.bounces = false
        QuestionsTable.isScrollEnabled = true

        
        registerCells()
    }
    
    func registerCells() {
        QuestionsTable.register(UINib(nibName: "SurveyPageTableViewCellShotText", bundle: nil), forCellReuseIdentifier: SurveyPageTableViewCellShotText.reuseIdentifier)
        QuestionsTable.register(UINib(nibName: "SurveyPageTableViewCellDropdown", bundle: nil), forCellReuseIdentifier: SurveyPageTableViewCellDropdown.reuseIdentifier)
        QuestionsTable.register(UINib(nibName: "SurveyPageTableViewCellRadioButton", bundle: nil), forCellReuseIdentifier: SurveyPageTableViewCellRadioButton.reuseIdentifier)
        QuestionsTable.register(UINib(nibName: "SurveyPageTableViewCellScale", bundle: nil), forCellReuseIdentifier: SurveyPageTableViewCellScale.reuseIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UiAlerts.getInstance().newView(view: self)
        refreshTableView()
    }
    
    func refreshTableView() {
        if Thread.isMainThread {
            QuestionsTable.reloadData()
            var frame = QuestionsTable.frame
            frame.size.height = QuestionsTable.contentSize.height
            QuestionsTable.frame = frame
            
        } else {
            DispatchQueue.main.sync{
                refreshTableView()
            }
        }
    }
    

    func submitAnswers(){
        //remove triggered survey to be answered
        if  var tDates = triggeredSurvey?.survey.triggeredDates,
            let index = triggeredSurvey?.survey.triggeredDates.index(of: (triggeredSurvey?.date) ?? Date()){
            tDates.remove(at: index)
        }
        
        //get all answers from cells
        var answers = [Answer]()
        for cell in cells {
            answers.append(contentsOf: cell.answer())
        }
        
        //set answered questions
        if let survey = triggeredSurvey?.survey,
            let tDate = triggeredSurvey?.date,
            let uid = MotivUser.getInstance()?.userid {
        UserInfo.answerQuestions(surveyID: survey.surveyID, version: survey.version, trigger: survey.trigger!, triggerDate: tDate, uid: uid, answers: answers)
        }
        
        UserInfo.appDelegate?.saveContext()
        
        //send to server
        if let token = MotivUser.getInstance()?.getToken() {
            let sendAnswers = SendAnsweredSurveysRequest()
            sendAnswers.makeRequest(accessToken: token)
        } else {
            print("error: no token")
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
}
