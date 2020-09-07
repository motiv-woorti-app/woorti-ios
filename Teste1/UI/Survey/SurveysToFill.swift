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
import UIKit


/*
 * Show available surveys
 */
class SurveysToFill: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    private var triggeredSurveys = [TriggeredSurvey]()
    
    @IBOutlet weak var surveysToFillTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return triggeredSurveys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "SurveyToFillTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? SurveyToFillTableViewCell else {
            fatalError("The dequeued cell is not an instance of SurveyToFillTableViewCell.")
        }
        
        //initialize the cell
        let triggeredSurvey = triggeredSurveys[indexPath.row]
        cell.setTriggeredSurvey(triggeredSurvey: triggeredSurvey)
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Surveys To Fill"
        surveysToFillTable.dataSource = self
        surveysToFillTable.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UiAlerts.getInstance().newView(view: self)
        refreshTableView()
    }
    
    func refreshTableView() {
        if Thread.isMainThread {
            triggeredSurveys = TriggeredSurvey.getTriggeredSurveysFromSurveys()
            surveysToFillTable.reloadData()
        }else {
            DispatchQueue.main.sync{
                refreshTableView()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SurveyToFillTableViewCell {
            GoToSurveyQuetions(cell: cell)
        }
    }
    
    func GoToSurveyQuetions(cell: SurveyToFillTableViewCell) {
        if Thread.isMainThread {
            let SurveyPageViewController = storyboard?.instantiateViewController(withIdentifier: "SurveyPageViewController") as! SurveyPageViewController
            
            if let ts = cell.getTriggeredSurvey() {
                SurveyPageViewController.setTriggeredSurvey(triggeredSurvey: ts)
            }
            
            navigationController?.pushViewController(SurveyPageViewController, animated: true)
        }else {
            DispatchQueue.main.sync{
                GoToSurveyQuetions(cell: cell)
            }
        }
    }

}

class TriggeredSurvey {
    var survey: Survey
    var date: Date
    
    init(survey: Survey, date: Date){
        self.date = date
        self.survey = survey
    }
    
    static func getTriggeredSurveysFromSurvey(survey: Survey) -> [TriggeredSurvey]{
        var te = [TriggeredSurvey]()
        
        survey.getTriggeredDates().forEach { (date) in
            te.append(TriggeredSurvey(survey: survey, date: date))
        }
        
        return te
    }
    
    static func getTriggeredSurveysFromSurveys() -> [TriggeredSurvey]{
        
        
        var te = [TriggeredSurvey]()
        let surveys = UserInfo.getSurveys().filter { (survey) -> Bool in
            return survey.isTriggered() && !survey.deletedSurvey
        }
        
        var surveyDictionary : [Double : Survey] = [:]
        
        for survey in surveys {
            surveyDictionary[survey.surveyID] = survey
        }
        
        let surveysToReturn = Array(surveyDictionary.values)
        
        surveysToReturn.forEach { (survey) in
            te.append(contentsOf: getTriggeredSurveysFromSurvey(survey: survey))
        }
        
        te.sort { (ts1, ts2) -> Bool in
            ts1.date > ts2.date
        }
        
        return te
    }
    
}
