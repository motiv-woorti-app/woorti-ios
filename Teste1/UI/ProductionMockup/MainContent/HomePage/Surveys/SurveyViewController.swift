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
 * controller to handle survey questions
 */
class SurveyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SegmentedProgressBarDelegate {
    @IBOutlet weak var QuestionsTableView: UITableView!
    var cells = [GenericQuestionTableViewCell]()
    var triggeredSurvey: TriggeredSurvey?
    var LastQuestionAnswered = -1
    @IBOutlet weak var QuestionsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var confirmAllButton: UIButton!
    @IBOutlet weak var ProgressBar: UIView!
    private var spb: SegmentedProgressBar!
    public var type = surveyType.survey
    
    @IBOutlet weak var SurveyHeaderTitle: UILabel!
    @IBOutlet weak var SurveyTitle: UILabel!
    @IBOutlet weak var SurveyDescription: UITextView!
    
    @IBOutlet weak var BottomAcceptView: UIView!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var DescLabel: UILabel!
    @IBOutlet weak var SkipView: UIView!
    @IBOutlet weak var SkipLabel: UILabel!
    
    @IBOutlet weak var confirmReportButton: UIButton!
    private var Hasloaded = false
    
    @IBOutlet var popUp: UIView!
    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var confirmAndLeave: UIButton!
    @IBOutlet weak var confirmAndSubmitMore: UIButton!
    
    var fadeView: UIView?
    
    //semaphore used to get report.
    private var getReportSem = DispatchSemaphore(value: 0)
    
    var surveyTitleText = "Bike + Bus"
    var SurveyDescriptionText = "Carris is considering introducing bicycle racks in all its busese. But its a 200m € investment of taxpayer money and we would like your opinin on the matter."
    
    enum surveyType {
        case reporting, survey
    }
    
    @IBOutlet weak var numberOfQuestionsLabel: UILabel!
    @IBOutlet weak var BeginButton: UIButton!
    
    func segmentedProgressBarChangedIndex(index: Int) {
//        self.ProgressBar.skip()
    }
    
    func segmentedProgressBarFinished() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        QuestionsTableView.register(UINib(nibName: "RadioButtonQuestionTableViewCell", bundle: nil), forCellReuseIdentifier: "RadioButtonQuestionTableViewCell")
        QuestionsTableView.register(UINib(nibName: "ParagraphQuestionTableViewCell", bundle: nil), forCellReuseIdentifier: "ParagraphQuestionTableViewCell")
        QuestionsTableView.register(UINib(nibName: "YesNoQuestionTableViewCell", bundle: nil), forCellReuseIdentifier: "YesNoQuestionTableViewCell")
        QuestionsTableView.register(UINib(nibName: "CheckBoxQuestionTableViewCell", bundle: nil), forCellReuseIdentifier: "CheckBoxQuestionTableViewCell")
        cells = [GenericQuestionTableViewCell]()
        
        QuestionsTableView.delegate = self
        QuestionsTableView.dataSource = self
        // Do any additional setup after loading the view.
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        let beginText = NSLocalizedString("Begin", value: "Begin", comment: "")
        GenericQuestionTableViewCell.loadStandardButton(button: BeginButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: beginText, disabled: (self.LastQuestionAnswered != -1))
        
        let endText = NSLocalizedString("End", value: "Begin", comment: "")
        GenericQuestionTableViewCell.loadStandardButton(button: confirmAllButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: endText, disabled: self.triggeredSurvey == nil)
        confirmAllButton.isEnabled = self.triggeredSurvey != nil
        confirmAllButton.isUserInteractionEnabled = self.triggeredSurvey != nil
        
        Hasloaded = true
        loadProgressBar()
        if type == .reporting {
            self.loadBottomView()
            MotivAuxiliaryFunctions.RoundView(view: popUp)
            MotivFont.motivBoldFontFor(text: "Thank you for submitting this issue. Confirm submission or proceed to another issue", label: self.popupTitle, size: 11)
            self.popupTitle.textColor = UIColor.black
            
            MotivAuxiliaryFunctions.loadStandardButton(button: self.confirmAndLeave, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, text: "Confirm and leave", boldText: false, size: 9, disabled: false)
            MotivAuxiliaryFunctions.loadStandardButton(button: self.confirmAndSubmitMore, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, text: "Confirm and submit more", boldText: false, size: 9, disabled: false)
            
            confirmAllButton.isEnabled = true
            confirmAllButton.isUserInteractionEnabled = true
        } else {
            self.BottomAcceptView.isHidden = true
            confirmAllButton.isEnabled = self.triggeredSurvey != nil
            confirmAllButton.isUserInteractionEnabled = self.triggeredSurvey != nil
        }
        
        loadTitleSection()
        
    }
    
    @IBAction func confirmAndLeaveClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmAndSubmitMore(_ sender: Any) {
        cells = [GenericQuestionTableViewCell]()
        reloadData()
        loadBottomView()
        self.closePopup()
    }
    
    //popup
    @objc func popup(){
        closePopup()
        self.fadeView = UIView(frame: self.view.bounds)
        fadeView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.addSubview(fadeView!)
        fadeView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closePopup)))
        
        self.view.addSubview(self.popUp)
        self.popUp.center = self.view.center
    }
    
    @objc func closePopup() {
        self.fadeView?.removeFromSuperview()
        self.popUp?.removeFromSuperview()
    }
    
    func loadProgressBar() {
        if Thread.isMainThread {
            if let survey = self.triggeredSurvey, Hasloaded && spb == nil {
                spb = SegmentedProgressBar(numberOfSegments: survey.survey.questions?.count ?? 0, duration: 0)
                spb.frame = CGRect(x: 10, y: (ProgressBar.frame.maxY - ProgressBar.frame.minY).divided(by: CGFloat(2)) - CGFloat(2), width: ProgressBar.frame.width - 20, height: 4)
                spb.delegate = self
                spb.topColor = UIColor(displayP3Red: CGFloat(221)/CGFloat(255), green: CGFloat(131)/CGFloat(255), blue: CGFloat(48)/CGFloat(255), alpha: CGFloat(1))
                spb.bottomColor = UIColor.white
                spb.padding = 2
                ProgressBar.addSubview(spb)
                
                spb.layoutSubviews()
                spb.isPaused = true
                numberOfQuestionsLabel.text = "\(self.triggeredSurvey?.survey.questions?.count ?? 0) QUESTIONS"
            }
        } else {
            DispatchQueue.main.async {
                self.loadProgressBar()
            }
        }
    }
    
    func loadBottomView() {
        if Hasloaded {
            if Thread.isMainThread {
                MotivAuxiliaryFunctions.RoundView(view: BottomAcceptView)
                MotivFont.motivBoldFontFor(text: "Submit log", label: self.TitleLabel, size: 15)
                self.TitleLabel.textColor = MotivColors.WoortiOrange
                
                MotivFont.motivBoldFontFor(text: "To analise the issue, we would like to receive a log with information of the app activity. Please send the email that will be generated. If you like, you can also attach printscreens or a longer description of the issue to the email.", label: self.DescLabel, size: 11)
                self.DescLabel.textColor = UIColor.black
                self.DescLabel.numberOfLines = 0
                self.DescLabel.lineBreakMode = .byWordWrapping
                
                self.SkipView.isUserInteractionEnabled = true
                let gr = UITapGestureRecognizer(target: self, action: #selector(skip))
                self.SkipView.addGestureRecognizer(gr)
                
                MotivFont.motivRegularFontFor(text: "No log needed for this issue. Skip.", label: self.SkipLabel, size: 9)
                
                GenericQuestionTableViewCell.loadStandardButton(button: confirmReportButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "Send log", disabled: false)
                
                self.confirmAllButton.isHidden = true
                BottomAcceptView.isHidden = false
            } else {
                DispatchQueue.main.sync {
                    loadBottomView()
                }
            }
        }
    }
    
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @IBAction func beginSurvey(_ sender: Any) {
        self.answeredQuestion(index: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return triggeredSurvey?.survey.questions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let visible = self.LastQuestionAnswered >= indexPath.row
        if indexPath.row >= cells.count  {
            let question = triggeredSurvey?.survey.getquestionsOrdered()[indexPath.row]
            
            var cell: GenericQuestionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RadioButtonQuestionTableViewCell") as! RadioButtonQuestionTableViewCell
            cell.loadQuestionCell(question: question!, visible: visible, parent: self, index: indexPath.row, language: (triggeredSurvey?.survey.chooseLanguage(language: (MotivUser.getInstance()?.language) ?? Languages.getLanguages().first!.smartphoneID))!)
            
            switch question?.questionType ?? Question.QuestionType.yesNo {
            case Question.QuestionType.multipleChoice:
                print("------ RADIO BUTTON QUESTION")
                cell = tableView.dequeueReusableCell(withIdentifier: "RadioButtonQuestionTableViewCell") as! RadioButtonQuestionTableViewCell
                cell.loadQuestionCell(question: question!, visible: visible, parent: self, index: indexPath.row, language: (triggeredSurvey?.survey.chooseLanguage(language: (MotivUser.getInstance()?.language) ?? Languages.getLanguages().first!.smartphoneID))!)
                break
            case Question.QuestionType.scale:
                break
            case Question.QuestionType.checkboxes:
                print("------ CHECK BOX BUTTON QUESTION")
                cell = tableView.dequeueReusableCell(withIdentifier: "CheckBoxQuestionTableViewCell") as! CheckBoxQuestionTableViewCell
                cell.loadQuestionCell(question: question!, visible: visible, parent: self, index: indexPath.row, language: (triggeredSurvey?.survey.chooseLanguage(language: (MotivUser.getInstance()?.language) ?? Languages.getLanguages().first!.smartphoneID))!)
                break
            case Question.QuestionType.grid:
                break
            case Question.QuestionType.paragraph, Question.QuestionType.shortText: //Short text is temporary here, only untill we have the real UI/UX for short Text
                print("------ PARAGRAPH BUTTON QUESTION")
                cell = tableView.dequeueReusableCell(withIdentifier: "ParagraphQuestionTableViewCell") as! ParagraphQuestionTableViewCell
                cell.loadQuestionCell(question: question!, visible: visible, parent: self, index: indexPath.row, language: (triggeredSurvey?.survey.chooseLanguage(language: (MotivUser.getInstance()?.language) ?? Languages.getLanguages().first!.smartphoneID))!)
                break
            case Question.QuestionType.dropdown:
                break
            case Question.QuestionType.yesNo:
                print("------ YES NO BUTTON QUESTION")
                cell = tableView.dequeueReusableCell(withIdentifier: "YesNoQuestionTableViewCell") as! YesNoQuestionTableViewCell
                cell.loadQuestionCell(question: question!, visible: visible, parent: self, index: indexPath.row, language: (triggeredSurvey?.survey.chooseLanguage(language: (MotivUser.getInstance()?.language) ?? Languages.getLanguages().first!.smartphoneID))!)
                break
            }
            
            cells.append(cell)
            setTableViewHeight()
            
            return cell
        } else {
            setTableViewHeight()
            let cell = cells[indexPath.row]
            cell.visible = visible
            cell.setVisibility()
            return cell
        }
    }
    
    func answeredQuestion(index: Int){
        if LastQuestionAnswered < index {
            if LastQuestionAnswered != -1 {
                spb.skip()
            }
            LastQuestionAnswered = index
            GenericQuestionTableViewCell.loadStandardButton(button: BeginButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "BEGIN", disabled: (self.LastQuestionAnswered != -1))
            reloadData()
        }
        if (triggeredSurvey?.survey.questions?.count ?? 0) == LastQuestionAnswered {
            GenericQuestionTableViewCell.loadStandardButton(button: confirmAllButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "CONFIRM ALL", disabled: false)
        } else {
            GenericQuestionTableViewCell.loadStandardButton(button: confirmAllButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "CONFIRM ALL", disabled: true)
        }
    }
    
    func loadReporting() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.type = .reporting
            self.loadTitleSection()
            NotificationCenter.default.addObserver(self, selector: #selector(self.gotReportingSurvey), name: NSNotification.Name(rawValue: GetMySurveysHandler.callback.GotSurveysResponse.rawValue), object: nil)
            MotivRequestManager.getInstance().UpdateMyReprotingSurvey()
            if UserInfo.getSurveys().contains(where: { (survey) -> Bool in
                if let trigger = survey.trigger as? TriggerEvent {
                    return trigger.trigger == TriggerEvent.TriggerEvents.reporting
                }
                return false
            }) {
                self.getReportSem.wait(timeout: DispatchTime(uptimeNanoseconds: 1000 * 1000))
            } else {
                self.getReportSem.wait()
            }
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: GetMySurveysHandler.callback.GotSurveysResponse.rawValue), object: nil)

            let surveys = UserInfo.getSurveys()
            for survey in surveys {
                if let trigger = survey.trigger as? TriggerEvent,
                    trigger.trigger == TriggerEvent.TriggerEvents.reporting {
                    self.surveyTitleText = "Report"
                    self.SurveyDescriptionText = "Thank you for reporting an issue"
                    let ts = TriggeredSurvey(survey: survey, date: Date())
                    self.LoadSurvey(triggeredSurvey: ts)
                    self.loadBottomView()
                    break
                }
            }
            //        }
        }
    }
    
    @objc func gotReportingSurvey() {
        self.getReportSem.signal()
    }
    
    
    func LoadSurvey(triggeredSurvey: TriggeredSurvey) {
        if Thread.isMainThread {
            self.triggeredSurvey = triggeredSurvey
            self.cells = [GenericQuestionTableViewCell]()
            loadTitleSection()
            reloadData()
            loadProgressBar()
            if Hasloaded {
                GenericQuestionTableViewCell.loadStandardButton(button: confirmAllButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "CONFIRM ALL", disabled: self.triggeredSurvey == nil)
                confirmAllButton.isEnabled = self.triggeredSurvey != nil
                confirmAllButton.isUserInteractionEnabled = self.triggeredSurvey != nil
            }
        } else {
            DispatchQueue.main.async {
                self.LoadSurvey(triggeredSurvey: triggeredSurvey)
            }
        }
    }
    
    
    func loadTitleSection() {
        DispatchQueue.main.async {
            if self.triggeredSurvey == nil {
                if self.type == .reporting {
                    self.SurveyHeaderTitle.text = "Report"
                    self.SurveyTitle.text = "Loading Report"
                    self.SurveyDescription.text = "Please wait while the report is loading"
                } else {
                    self.SurveyHeaderTitle.text = "Survey"
                    self.SurveyTitle.text = "Loading Survey"
                    self.SurveyDescription.text = "Please wait while the survey is loading"
                }
            } else if self.Hasloaded {
                self.SurveyHeaderTitle.text = self.surveyTitleText
                if self.type == .reporting {
                    self.SurveyTitle.text = "Report Issue"
                } else {
                    let survey = self.triggeredSurvey!
                    self.surveyTitleText = survey.survey.surveyName
                    self.SurveyDescriptionText = survey.survey.surveyDescription
                    self.SurveyTitle.text = "\(self.surveyTitleText)"
                }
                self.SurveyDescription.text = self.SurveyDescriptionText
                
            }
        }
    }
    
    func setTableViewHeight() {
        let tableViewHeight = self.cells.reduce(1, { (height, cell) -> Int in
            height + cell.getDrawHeight()
        })
        
        if cells.count >= self.triggeredSurvey?.survey.questions?.count ?? 0 {
            self.QuestionsTableViewHeight.constant = CGFloat(tableViewHeight)
        } else {
            self.QuestionsTableViewHeight.constant = CGFloat(tableViewHeight + 500)
        }
    }
    
    func reloadData(){
        DispatchQueue.main.async {
            self.QuestionsTableView.reloadData()
            self.setTableViewHeight()
        }
    }
    
    @IBAction func dismissSurvey(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(cells[indexPath.row].getDrawHeight())
    }
    
    
    @objc func skip() {
        confirm(skip: true)
    }
    
    func confirm(skip: Bool) {
        var answers = [Answer]()
        
        for cell in cells {
            answers.append(contentsOf: cell.answer())
        }
        
        if self.type == .reporting,
            let first = cells.first,
            first.answer().count < 1 {
            return
        }
        
        GenericQuestionTableViewCell.loadStandardButton(button: confirmAllButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "CONFIRM ALL", disabled: false)
        confirmAllButton.isEnabled = false
        confirmAllButton.isUserInteractionEnabled = false
        
        if let survey = triggeredSurvey?.survey,
            let tDate = triggeredSurvey?.date,
            let uid = MotivUser.getInstance()?.userid {
            
            if self.type == .reporting {
                EmailManager.getInstance().generateID()
                let id = EmailManager.getInstance().getID()
                let os = "\(UIDevice.current.systemName)_\(UIDevice.current.systemVersion)"
//                let ctx = UserInfo.context
                
                UserInfo.answerQuestions(surveyID: survey.surveyID, version: survey.version, trigger: survey.trigger!, triggerDate: tDate, uid: uid, answers: answers, reportingID: id, reportingOS: os)
            } else {
                UserInfo.answerQuestions(surveyID: survey.surveyID, version: survey.version, trigger: survey.trigger!, triggerDate: tDate, uid: uid, answers: answers)
                MotivUser.getInstance()?.answerSurvey(survey: survey)
                
                if let triggerType = survey.trigger{
                     print("Answered survey type: " + triggerType.triggerType())
                }
               
                
                //unique survey
                if let te = survey.trigger as? TriggerOnce {
                    print("Survey answered, deleting repeated")
                    survey.deletedSurvey = true
                    //DELETE REPEATED SURVEYS EQUAL TO ANSWERED SURVEY
                    for otherSurvey in UserInfo.getSurveys() {
                        if(otherSurvey.surveyID == survey.surveyID){
                            print("Survey answered, repeated found - deleted")
                            otherSurvey.deletedSurvey = true
                        }
                    }
                    
                }
                
                
            
                
                
                for campaign in MotivUser.getInstance()!.getCampaigns() {
                    RewardManager.instance.checkAndAssignScoreForSurveys(campaignId: campaign.campaignId, score: survey.surveyPoints)
                }
                
            }
        }
        
        UserInfo.appDelegate?.saveContext()
        if self.type == .reporting {
            MotivRequestManager.getInstance().sendReport()
            if !skip {
                EmailManager.getInstance().sendEmail(view: self)
            }
            self.popup()
        } else {
            if !skip {
                MotivRequestManager.getInstance().sendAnswers()
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func confirmAll(_ sender: Any) {
        confirm(skip: false)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
