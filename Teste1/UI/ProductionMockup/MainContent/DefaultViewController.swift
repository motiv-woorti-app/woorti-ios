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
import CoreLocation

/*
 * Dashboard view controller
 * View that appears after login
 * Shows stats, surveys, rewards, stories.
 */
class DefaultViewController: GenericViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var feedCollectionView: UICollectionView!
    @IBOutlet weak var feedCollectionViewsize: NSLayoutConstraint!
    @IBOutlet weak var todaysTravelReportMainView: UIView!
    @IBOutlet weak var goingHomeMainView: UIView!
    @IBOutlet weak var goingToWorkMAinView: UIView!
    
    @IBOutlet weak var TotalPointsValueLabel: UILabel!
    @IBOutlet weak var lblTotalPoints: UILabel!
    
    
    @IBOutlet weak var TotalDaysLabel: UILabel!
    @IBOutlet weak var TotalDaysValueLabel: UILabel!
    
    @IBOutlet weak var TotalTripsLabel: UILabel!
    @IBOutlet weak var TotalTripsValueLabel: UILabel!
    
    @IBOutlet weak var lblReward: UILabel!
    @IBOutlet weak var lblNameOfTheReward: UILabel!
    @IBOutlet weak var lblDaysLeft: UILabel!
    @IBOutlet weak var vProgressView: UIView!
    
    @IBOutlet weak var lblGoalStreak: UILabel!
    @IBOutlet weak var stckGoalStreak: UIStackView!
    
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var minutesMoreOrLess: UILabel!
    @IBOutlet weak var kmsLabel: UILabel!
    @IBOutlet weak var kmsMoreOrLess: UILabel!
    
    @IBOutlet weak var todaysTravelReport: UILabel!
    
    @IBOutlet weak var RewardsTable: UITableView!
    @IBOutlet weak var ProgressLabel: UILabel!
    @IBOutlet weak var TasksLabel: UILabel!
    
    var feeds = [FeedItem]()
    var feedSize = 0
    var itemSize = 117
    
    var feedToGo: FeedItem?
    
    var rewards = [Reward]()
    var rewardStatus = [RewardStatus]()
    
    enum DefaultViewOptions: String {
        case ShowRouteRankPage
    }
    
    func showGoals() {
        if let user = MotivUser.getInstance(),
            user.hasSetGoal {
            lblGoalStreak.isHidden = false
            stckGoalStreak.isHidden = false
        } else {
            lblGoalStreak.isHidden = true
            stckGoalStreak.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SignInManager.instance.availableMainMenu()
        MotivAuxiliaryFunctions.imagedNamedToBackground(name: "Orange_BG_Extended", view: self.view)
        
        self.RoundView(view: self.todaysTravelReportMainView, withRadius: self.todaysTravelReportMainView.bounds.width * 0.05)
        
        self.RoundView(view: self.goingHomeMainView)
        self.RoundView(view: self.goingToWorkMAinView)
        
        self.feedCollectionView.delegate = self
        self.feedCollectionView.dataSource = self
        
        if let user = MotivUser.getInstance() {
            rewards = user.getRewards()
            rewards = rewards.filter( {$0.canShowReward(timeToAdd: 60 * 60 * 24 * 30)})
            rewardStatus = user.getRewardStatus()
        }
        
        if rewards.count == 0 {
            ProgressLabel.isHidden = true
        } else {
            ProgressLabel.isHidden = false
        }
        self.TotalPointsValueLabel.isHidden = true
        
        ProgressLabel.text = NSLocalizedString("Progress", comment: "").uppercased()
        TasksLabel.text = NSLocalizedString("Tasks", comment: "").uppercased()
        
        
        self.RewardsTable.delegate = self
        self.RewardsTable.dataSource = self
        self.RewardsTable.register(UINib(nibName: "RewardProgressViewCell", bundle: nil), forCellReuseIdentifier: "RewardProgressViewCell")
        RewardsTable.rowHeight = UITableViewAutomaticDimension
        RewardsTable.separatorColor = UIColor.clear
        RewardsTable.backgroundColor = UIColor.clear
        RewardsTable.tableFooterView = UIView()
        MotivAuxiliaryFunctions.RoundView(view: RewardsTable)
        
        
        MotivFont.motivBoldFontFor(key: "Seven_Day_Travel_Report", comment: "", label: todaysTravelReport, size: 16)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: todaysTravelReport, color: MotivColors.WoortiOrange)
        MotivFont.motivRegularFontFor(key: "Total_Points", comment: "", label: lblTotalPoints, size: 12)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: lblTotalPoints, color: UIColor.white.withAlphaComponent(0.5))
        
        MotivFont.motivRegularFontFor(key: "Days", comment: "", label: TotalDaysLabel, size: 12)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: TotalDaysLabel, color: UIColor.white.withAlphaComponent(0.5))
        
        MotivFont.motivRegularFontFor(key: "Trips", comment: "", label: TotalTripsLabel, size: 12)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: TotalTripsLabel
            , color: UIColor.white.withAlphaComponent(0.5))
        
        DispatchQueue.global(qos: .background).async {
            self.feeds = FeedItem.getFeeds()
            self.feedSize = self.feeds.count
            self.reloadCollectionView()
        }
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(goToDashboard))
        self.todaysTravelReportMainView.addGestureRecognizer(gr)
        
        self.feedCollectionView.backgroundColor = UIColor.clear
        let info = UserInfo.processLast7DaysTravelReport()
        
        var worthwhileness7days = 0.0
    
        
        //Load information for dashboard. Contains Trip stats to show.
        DispatchQueue.global(qos: .background).async {
            Thread.sleep(forTimeInterval: 0.8)
            let dashInfoHandler = DashInfoHandler()
            let dashInfo = dashInfoHandler.getInfoForTime(time: DashInfoHandler.type.Week)
            
            worthwhileness7days = (dashInfo.totalWorth * 100) ?? 0.0
            
            var worthwhilenessText = ""
            if worthwhileness7days != nil && !worthwhileness7days.isNaN {
                worthwhilenessText = String(format: "%.0f", worthwhileness7days) + "%"
            } else {
                String(format: "%.0f", 0) + "%"
            }
            
            DispatchQueue.main.sync {
                // 7 days report, HOURS SPENT | WORTHWHILENESS
                MotivFont.motivBoldFontFor(text: String(format: "%.1f", info.1 / 3600), label: self.minutesLabel, size: 30)
                MotivFont.motivBoldFontFor(text: worthwhilenessText, label: self.kmsLabel, size: 30)
                
                // HOURS SPENT 7 days report
                MotivFont.motivRegularFontFor(text: NSLocalizedString("Hours", comment: ""), label: self.minutesMoreOrLess, size: 15)
                
                //Worthwhileness 7 days report
                MotivFont.motivRegularFontFor(text: NSLocalizedString("Worthwhileness", comment: ""), label: self.kmsMoreOrLess, size: 15)
            }
        }
        
        //showPoints()
        showGoals()
        
        let fullTripList = UserInfo.getFullTrips()
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        var dayMap = [String : FullTrip]()
        var tripCount = 0
        
        let methodStart = Date()
        for trip in fullTripList {
            if trip.confirmed {
                tripCount += 1
                let date = formatter.string(from: trip.startDate!)
                dayMap[date] = trip
            }
        }
        let methodFinish = Date()
        
        MotivFont.motivBoldFontFor(text: "\(Int(dayMap.count))", label: self.TotalDaysValueLabel, size: 30)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.TotalDaysValueLabel, color: UIColor.white)
        
        MotivFont.motivBoldFontFor(text: "\(Int(tripCount))", label: self.TotalTripsValueLabel, size: 30)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.TotalTripsValueLabel, color: UIColor.white)
        
        
        
        
        DispatchQueue.global(qos: .background).async {
            let scoreMainCampaign = ScoreManager.getInstance().getScoreForMainCampaign()
            DispatchQueue.main.async {
                MotivFont.motivBoldFontFor(text: "\(Int(scoreMainCampaign))", label: self.TotalPointsValueLabel, size: 30)
                MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.TotalPointsValueLabel, color: UIColor.white)
                self.TotalPointsValueLabel.isHidden = false
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            Thread.sleep(forTimeInterval: 1)
            print("Send User Settings")
            MotivRequestManager.getInstance().requestSaveUserSettings()
            
            Thread.sleep(forTimeInterval: 1)
            print("Requesting Campaign Full List")
            MotivRequestManager.getInstance().requestCampaignsFullList()
            
            Thread.sleep(forTimeInterval: 1.5)
            print("Requesting Surveys")
            MotivRequestManager.getInstance().UpdateMySurveys()
            
            NotificationEngine.getInstance().notifyDatedSurveys()
            MotivUser.getInstance()?.trySendNextNotificationFromElsewhere()
            NotificationEngine.getInstance().notifyOnceTripSurveys() // Temp func to fire all once surveys if should already have fired
            
            //UPDATE REWARDS
            Thread.sleep(forTimeInterval: 0.5)
            print("Requesting Rewards")
            MotivRequestManager.getInstance().requestRewards()
            Thread.sleep(forTimeInterval: 0.5)
  
            MotivRequestManager.getInstance().syncRewardStatusWithServer()

            
            
            
        }
        
        //Send trip summaries
        DispatchQueue.global(qos: .background).async {
            Thread.sleep(forTimeInterval: 0.5)
            if let user = MotivUser.getInstance() {
                let lastSummarySent = user.lastSummarySent
                
                var tripSummaryList = [TripSummary]()
                
                let tripList = UserInfo.getFullTrips()
                
                for trip in tripList {
                    
                    if let startDate = trip.startDate {
                        if(startDate > Date(timeIntervalSince1970: lastSummarySent)){
                            print("Adding trip to summary")
                            var newSummary = TripSummary(startDate: startDate, totalDistance: Double(modf(trip.distance).0), totalTime:  Double(modf(trip.duration).0) * 1000)
                            tripSummaryList.append(newSummary)
                        }
                    }
                }
                
                if(tripSummaryList.count > 0){
                    MotivRequestManager.getInstance().sendSummaries(tripSummaries: tripSummaryList)
                }
                
            }
        }
        
        
        //Resend trips to server (once).
        //Caused by temporary orient crash
        let preferences = UserDefaults.standard
        
        let resendTripsFlag = "resendTripsFlag"
        if preferences.object(forKey: resendTripsFlag) == nil {
            print("resendTripsFlag does not exist")
            markTripsAsNotSent()
        } else {
            print("resendTripsFlag exists")
        }
    
    }
    

    func markTripsAsNotSent(){
        let preferences = UserDefaults.standard
        if let user = MotivUser.getInstance(){
            
            let fulltrips = UserInfo.getFullTrips()
            
            let dateFormat = DateFormatter()
            
            dateFormat.dateFormat = "yyyy-MM-dd HH:mm"
            
            if let minDate = dateFormat.date(from: "2019-10-25 00:00") {
                for trip in fulltrips {
                    if let startDate = trip.startDate {
                        if startDate > minDate {
                            print("Trip is after 25/Oct")
                            print(trip.startDate)
                            print(minDate)
                            trip.sentToServer = false
                        }
                    }
                }
            }
            preferences.set(true, forKey: "resendTripsFlag")
            
            let didSave = preferences.synchronize()
            
        }
    }
 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func goToDashboard() {
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MainViewController.MainViewOptions.ShowDashboard.rawValue), object: nil)
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async {
            self.feedCollectionViewsize.constant = CGFloat(((self.feedSize + 1)/2) * self.itemSize + ((self.feedSize + 1)/2) * 5)
            self.feedCollectionView.reloadData()
        }
    }
    
    //Feed task collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.feedSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell?
        
        switch feeds[indexPath.item] {
        case let survey as SurveyFeedItem:
            let SurveyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewSurveyTaskFeedCollectionViewCell", for: indexPath) as! NewSurveyTaskFeedCollectionViewCell
            SurveyCell.cellLoad(survey: survey.triggeredSurvey.survey)
            cell = SurveyCell
        case let story as StoryFeedItem:
            let storycell = collectionView.dequeueReusableCell(withReuseIdentifier: "LatestStoryTaskFeedCollectionViewCell", for: indexPath) as! LatestStoryTaskFeedCollectionViewCell
            storycell.loadCell(story: story.lesson)
            cell = storycell
        case let Trip as TripValidationFeedItem:
            let tripcell = collectionView.dequeueReusableCell(withReuseIdentifier: "TripValidationTaskCollectionViewCell", for: indexPath) as! TripValidationTaskCollectionViewCell
            tripcell.loadCell()
            cell = tripcell
        default:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewSurveyTaskFeedCollectionViewCell", for: indexPath) as! NewSurveyTaskFeedCollectionViewCell
            
        }
        
        
        self.RoundView(view: cell!)
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.feedToGo = self.feeds[indexPath.item]
        switch self.feedToGo {
        case let _ as StoryFeedItem:
            self.performSegue(withIdentifier: "ShowLessonSegue", sender: nil)
        case let _ as SurveyFeedItem:
            self.performSegue(withIdentifier: "ShowSurvey", sender: nil)
        case let _ as TripValidationFeedItem:
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MainViewController.MainViewOptions.ShowMyTrips.rawValue), object: nil)
        default:
            self.performSegue(withIdentifier: "ShowSurvey", sender: nil)
        }
    }
    
    
    func RoundView(view: UIView, withRadius: CGFloat? = nil){
        
        if let radius = withRadius {
            view.layer.cornerRadius = radius
        } else {
            view.layer.cornerRadius = view.bounds.width * 0.1
        }
        
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.9, green: 0.89, blue: 0.89, alpha: 1).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.18).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 4
        
        view.layer.masksToBounds = true
    }
    
    //REWARD TABLE POPULATE FUNCTIONS
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Starting Table with \(rewards.count)")
        return rewards.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Start cell for row at")
        let cell = tableView.dequeueReusableCell(withIdentifier: "RewardProgressViewCell") as! RewardProgressViewCell
        let cellReward = rewards[indexPath.row]
        
        //Fetch reward status
        let cellRewardStatus = MotivUser.getInstance()!.getRewardStatusById(id: cellReward.rewardId)
        
        
        cell.loadCell(reward: cellReward, rewardStatus: cellRewardStatus)
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("CLICKED REWARD ROW")
    }
    
    
    //MARK: Start of menu functions
    @objc func showRoutePlanner() {
        performSegue(withIdentifier: "showRouteRank", sender: nil)
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MainViewController.MainViewOptions.ToggleMenu.rawValue), object: nil)
    }

    //MARK: End of menu functions
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        switch segue.destination {
        case let lessonVC as LessonViewController :
            if let lessonFeed = feedToGo as? StoryFeedItem {
                lessonVC.loadLesson(lesson: lessonFeed.lesson)
            }
        case let surveyvc as SurveyViewController :
            if let survey = feedToGo as? SurveyFeedItem {
                surveyvc.LoadSurvey(triggeredSurvey: survey.triggeredSurvey)
            }
        default:
            break
        }
        self.feedToGo = nil
    }
 

}

class FeedItem {
    
    public static func getFeeds() -> [FeedItem] {
        var feeds = [FeedItem]()
        
        if UserInfo.getFullTrips().contains(where: { (ft) -> Bool in
            !ft.confirmed
        }) {
            feeds.append(TripValidationFeedItem())
        }
        /////-------------- Martelos Maximus Start ------------------
        
        var tmpFeedsSurvey = TriggeredSurvey.getTriggeredSurveysFromSurveys().map { (TriggeredSurvey) -> FeedItem in
            return SurveyFeedItem(triggeredSurvey: TriggeredSurvey)
            }.prefix(2)
        
        
        var tmpFeedsStory = MotivUser.getInstance()!.getLessonsForFeed().map { (lesson) -> FeedItem in
            return StoryFeedItem(lesson: lesson)
            }.suffix(2)
        
        var value = 0
        
        while (tmpFeedsSurvey.count > 0 || tmpFeedsStory.count > 0) {
            
            switch value {
            case 0:
                if let nextValue = tmpFeedsStory.popLast() {
                   feeds.append(nextValue)
                }
                value=1
            case 1:
                if let nextValue = tmpFeedsSurvey.popFirst() {
                    feeds.append(nextValue)
                }
                value=0
            default:
                break
            }
            
        }
        
        /////-------------- Martelos Maximus End ------------------
        
        return feeds
    }
}

class TripFeedItem: FeedItem {
    var trip: Trip
    
    init( trip: Trip){
        self.trip = trip
    }
}

class StoryFeedItem: FeedItem {
    var lesson: Lesson
    
    init( lesson: Lesson){
        self.lesson = lesson
    }
}

class SurveyFeedItem: FeedItem {
    var triggeredSurvey: TriggeredSurvey
    
    init(triggeredSurvey: TriggeredSurvey){
        self.triggeredSurvey = triggeredSurvey
    }
}

class TripValidationFeedItem: FeedItem {
    
}



class IntrinsicTableView : UITableView {
    
    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIViewNoIntrinsicMetric, height: contentSize.height)
    }
}
