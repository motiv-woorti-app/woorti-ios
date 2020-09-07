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
import EzPopup

/*
 * Dashboard view controller that summs and shows stats regarding the user's trips and travelling habits.
 */
class DashboardViewController: GenericViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var youButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var DashboardTypeOptions: UITableView!
    
    @IBOutlet weak var dashboardTypesHeightConstraint: NSLayoutConstraint!
    
    //day table
    @IBOutlet weak var chooseDaysView: UIView!
    @IBOutlet weak var chooseDaysTableView: UITableView!
    @IBOutlet weak var chooseDaysTableHeight: NSLayoutConstraint!
    @IBOutlet weak var chooseDaysTableWidth: NSLayoutConstraint!
    
    var responderForTypeList : DashboardTypeDelegate?
    var responderForDaysList: DaysTableViewDelegate?
    let dashInfoHandler = DashInfoHandler()
    var dashInfo: DashInfo?
    
    var values = ["LastDaysTableViewCell", "OverallTripsTableViewCell", "WhileTravelingTableViewCell", "DashboardGenericTextTableViewCell1", "DashboardGenericTextTableViewCell2"] // "OverallTripsTableViewCell", "WhileTravelingTableViewCell",
    var height = [280, 400, 214, 170, 185] //height arrays //,255, 171
    var chosen = DashInfoHandler.type.ThreeDays
    var chosenDataSource : DashboardTypeOption?
    
    var dashboardTypeOptions = [DashboardTypeOption]()
    
    
    //Info Balloon
    var infoIsOut = false
    var layoutView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    enum GoToOptions : String {
        case TimeSpentInTravel
        case DistSpentInTravel
        case Co2SpentInTravel
        case CaloriesSpentInTravel
        case ShowInfoBalloon
        case RemoveInfoBallon
        case Productity
        case Enjoyment
        case Fitness
        case Worthwhile
        case Co2Info
    }
    
    func reloadTableViewHeight() {
        tableViewHeight.constant = CGFloat(height.reduce(0, { (sumHeight, height) -> Int in
            return sumHeight + height
        }))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.DashboardTypeOptions.layoutIfNeeded()
        dashboardTypesHeightConstraint.constant = self.DashboardTypeOptions.contentSize.height
        
    }
    @IBAction func youButtonClick(_ sender: UIButton) {
        
        if DashboardTypeOptions.isHidden {
            DashboardTypeOptions.isHidden = false
            self.scrollView.bringSubview(toFront: DashboardTypeOptions)
            //self.scrollView.sendSubview(toBack: self.tableView)
        }
        else {
            DashboardTypeOptions.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MotivAuxiliaryFunctions.imagedNamedToBackground(name: "Orange_BG_Extended", view: self.view)
        
        MotivAuxiliaryFunctions.loadStandardButton(button: youButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, text: "You", boldText: true, size: 14, disabled: false, border: false, borderColor: UIColor.clear, CompleteRoundCorners: false)
        
        var youButtonTitle : NSAttributedString
        if let chosenSource = self.chosenDataSource {
            youButtonTitle = NSAttributedString(string: chosenSource.name, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
            
        } else {
            youButtonTitle = NSAttributedString(string: "You", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        }
        youButton.setAttributedTitle(youButtonTitle, for: .normal)
        youButton.tintColor = UIColor.white
        youButton.setImage(UIImage(named: "cm_arrow_downward_white")?.withRenderingMode(.alwaysTemplate), for: .normal)
        youButton.titleLabel!.lineBreakMode = .byWordWrapping
        
        
       
       
        youButton.isHidden = false
        
        DashboardTypeOptions.isHidden = true
        
        responderForTypeList = DashboardTypeDelegate(parent: self)
        self.DashboardTypeOptions.delegate = responderForTypeList
        self.DashboardTypeOptions.dataSource = responderForTypeList
        
        /////////////////////////////////////////
        //      Type Options Populate
        
        //City and Country
        if let user = MotivUser.getInstance() {
            dashboardTypeOptions.append(DashboardTypeOption(type: "", name: NSLocalizedString("You", comment: "")))
            dashboardTypeOptions.append(DashboardTypeOption(type: NSLocalizedString("City_Region", comment: ""), name: user.city))
            dashboardTypeOptions.append(DashboardTypeOption(type: NSLocalizedString("Country", comment: ""), name: user.country))
            
            
            for campaign in user.getCampaigns() {
                if campaign.campaignId != MockCampaign.titleForDefaultCampaign {
                    dashboardTypeOptions.append(DashboardTypeOption(type: NSLocalizedString("Campaign", comment: ""), name: campaign.name, id: campaign.campaignId))
                }
            }
        }
        chosenDataSource = dashboardTypeOptions.first
        
        
        
        reloadTableViewHeight()
        
        self.DashboardTypeOptions.register(UINib(nibName: "DashboardTypeTableViewCell", bundle: nil), forCellReuseIdentifier: "DashboardTypeTableViewCell")
        
        self.tableView.register(UINib(nibName: "LastDaysTableViewCell", bundle: nil), forCellReuseIdentifier: "LastDaysTableViewCell")
        self.tableView.register(UINib(nibName: "OverallTripsTableViewCell", bundle: nil), forCellReuseIdentifier: "OverallTripsTableViewCell")
        self.tableView.register(UINib(nibName: "WhileTravelingTableViewCell", bundle: nil), forCellReuseIdentifier: "WhileTravelingTableViewCell")
        self.tableView.register(UINib(nibName: "DashboardGenericTextTableViewCell", bundle: nil), forCellReuseIdentifier: "DashboardGenericTextTableViewCell")
        
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.dashInfo = self.dashInfoHandler.getInfoForTime(time: .ThreeDays)
            DispatchQueue.main.sync {
                print("Debug tableview")
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }
        }
        
        
        // added the taleview to get onclick
        MotivAuxiliaryFunctions.ShadowOnView(view: chooseDaysView)
        MotivAuxiliaryFunctions.RoundView(view: chooseDaysView)
        self.chooseDaysTableView.register(UINib(nibName: "DaysTableViewCell", bundle: nil), forCellReuseIdentifier: "DaysTableViewCell")
        
        MotivAuxiliaryFunctions.RoundView(view: DashboardTypeOptions)
        
        NotificationCenter.default.addObserver(self, selector: #selector(goToTimeSpent), name: NSNotification.Name(rawValue: GoToOptions.TimeSpentInTravel.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToDistSpent), name: NSNotification.Name(rawValue: GoToOptions.DistSpentInTravel.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToCo2Spent), name: NSNotification.Name(rawValue: GoToOptions.Co2SpentInTravel.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToCaloriesSpent), name: NSNotification.Name(rawValue: GoToOptions.CaloriesSpentInTravel.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showInfoBalloon), name: NSNotification.Name(rawValue: GoToOptions.ShowInfoBalloon.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeInfoBalloon), name: NSNotification.Name(rawValue: GoToOptions.RemoveInfoBallon.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(goToProductivity), name: NSNotification.Name(rawValue: GoToOptions.Productity.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToEnjoyment), name: NSNotification.Name(rawValue: GoToOptions.Enjoyment.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToFitness), name: NSNotification.Name(rawValue: GoToOptions.Fitness.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToWorthwhile), name: NSNotification.Name(rawValue: GoToOptions.Worthwhile.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openCo2InfoBalloon), name: NSNotification.Name(rawValue: GoToOptions.Co2Info.rawValue), object: nil)
        
        MotivRequestManager.getInstance().requestDashboardStats()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        let smallSize = 15
        let bigSize = 20
        
        //Load each dashboard row
        if indexPath.row < values.count {
            switch values[indexPath.row] {
            case "LastDaysTableViewCell":
                cell = tableView.dequeueReusableCell(withIdentifier: "LastDaysTableViewCell") as! LastDaysTableViewCell
                (cell as! LastDaysTableViewCell).cellLoad(parent: self, di: self.dashInfo!, chosen: self.chosen.rawValue)
                self.initChoosetimeLapse(responder: (cell as! LastDaysTableViewCell))
            case "OverallTripsTableViewCell":
                cell = tableView.dequeueReusableCell(withIdentifier: "OverallTripsTableViewCell") as! OverallTripsTableViewCell
                if chosenDataSource?.type != "" {
                    (cell as! OverallTripsTableViewCell).canSelectCommunity = true
                }
                
                (cell as! OverallTripsTableViewCell).cellLoad(di: self.dashInfo!)
            case "WhileTravelingTableViewCell":
                cell = tableView.dequeueReusableCell(withIdentifier: "WhileTravelingTableViewCell") as! WhileTravelingTableViewCell
                (cell as! WhileTravelingTableViewCell).cellLoad(di: self.dashInfo!)
                height[indexPath.row] = Int((cell as! WhileTravelingTableViewCell).getSizeForMe())
                tableViewHeight.constant = CGFloat(height.reduce(0, { (sumHeight, height) -> Int in
                    return sumHeight + height
                }))
            case "DashboardGenericTextTableViewCell1":
                cell = tableView.dequeueReusableCell(withIdentifier: "DashboardGenericTextTableViewCell") as! DashboardGenericTextTableViewCell
                
                let cals = self.dashInfo!.calories
                let communityValues = getCommunityStatsToShow()
                
                var youString : NSMutableAttributedString
                var finalString : NSMutableAttributedString
                
                //INFO RELATIVE TO USER
                let initialString = String(format: NSLocalizedString("In_Total_You_Spent_Calories", comment: ""), "#")
                var splitString = initialString.components(separatedBy: "#")
                youString = MotivFont.getRegularText(text: splitString[0], size: smallSize)
                youString.append(MotivFont.getBoldText(text: String(format: "%.0f cals", cals), size: bigSize))
                if splitString.count == 2 {
                    youString.append(MotivFont.getBoldText(text: splitString[1], size: bigSize))
                }
                finalString = youString
                    
                if let chosenDataSource = self.chosenDataSource {
                    if chosenDataSource.type != "" {
                        let otherString = String(format: NSLocalizedString("In_Total_Users_Spent_Calories", comment: ""), "#")
                        splitString = otherString.components(separatedBy: "#")
                        let communityString = MotivFont.getRegularText(text: " " + splitString[0], size: smallSize)
                        communityString.append(MotivFont.getBoldText(text: String(format: "%d cals", communityValues.1), size: bigSize))
                        if splitString.count == 2 {
                            communityString.append(MotivFont.getBoldText(text: splitString[1], size: bigSize))
                        }
                        finalString.append(communityString)
                    }
                }
                
                (cell as! DashboardGenericTextTableViewCell).loadCell(text: finalString, image: UIImage(named: "kcal-icon-17"), cellType: DashboardGenericTextTableViewCell.CellType.CALORIES)
            case "DashboardGenericTextTableViewCell2":
                cell = tableView.dequeueReusableCell(withIdentifier: "DashboardGenericTextTableViewCell") as! DashboardGenericTextTableViewCell
                
                //                let eraDih = dashInfoHandle
                let perc = self.dashInfo!.co2Footprint
                
                var kgCo2perPersonPerDay = 1370.0
                var co2PerDay = 1370.0
                switch chosen {
                case .Day:
                    kgCo2perPersonPerDay *= 1
                    break
                case .ThreeDays:
                    kgCo2perPersonPerDay *= 3
                    break
                case .Week:
                    kgCo2perPersonPerDay *= 7
                    break
                case .Month:
                    kgCo2perPersonPerDay *= 30
                    break
                case .Year:
                    kgCo2perPersonPerDay *= 30 * 12
                    break
                case .Era:
                    kgCo2perPersonPerDay *= 30 * 12 * 20
                    break
                default:
                    break
                }
                
                
                let percTotal = (perc.divided(by: kgCo2perPersonPerDay).multiplied(by: 100))
                let communityValues = getCommunityStatsToShow()
                
                let initialString = String(format: NSLocalizedString("And_This_Counted_Carbon_Footprint", comment: ""), "#")
                
                var splitString = initialString.components(separatedBy: "#")
                
                var youString = MotivFont.getRegularText(text: splitString[0], size: smallSize)
                youString.append(MotivFont.getBoldText(text: String(format: "%.0f%%", percTotal), size: bigSize))
                youString.append(MotivFont.getRegularText(text: splitString[1], size: smallSize))
                
                var finalString = youString
                
                var co2Gamma = Double(30000 * communityValues.2.totalUsers) / communityValues.2.totalDistance
                if co2Gamma < 1 {
                    co2Gamma = 1
                }
                print("Dashboard_gama = \(co2Gamma)")
                
                if let chosenDataSource = self.chosenDataSource {
                    if chosenDataSource.type != "" {
                        let otherString = String(format: NSLocalizedString("And_This_Counted_Carbon_Footprint_Users", comment: ""), "#")
                        splitString = otherString.components(separatedBy: "#")
                        let communityString = MotivFont.getRegularText(text: " " + splitString[0], size: smallSize)
                        communityString.append(MotivFont.getBoldText(text: String(format: "%.0f%", (Double(communityValues.0).divided(by: co2PerDay).multiplied(by: 100)).multiplied(by: co2Gamma)) + "%", size: bigSize))
                        if splitString.count == 2 {
                            communityString.append(MotivFont.getBoldText(text: splitString[1], size: smallSize))
                        }
                        finalString.append(communityString)
                    }
                }
                
                
                (cell as! DashboardGenericTextTableViewCell).loadCell(text: finalString, image: UIImage(named: "periodic-table-co2"), cellType: DashboardGenericTextTableViewCell.CellType.CO2)
            default:
                cell = tableView.dequeueReusableCell(withIdentifier: "LastDaysTableViewCell") as! LastDaysTableViewCell
            }
        }
        return cell!
    }
    
    func reloadTableView(time: DashInfoHandler.type) {
        if Thread.isMainThread {
            self.dashInfo = self.dashInfoHandler.getInfoForTime(time: time)
            print("DASH_BUG" + dashInfo.debugDescription)
            self.tableView.reloadData()
            self.reloadTableViewHeight()
        } else {
            DispatchQueue.main.async {
                self.reloadTableView(time: time)
            }
        }
    }
    
    func reloadInfo(sourceType: DashboardTypeOption, time: DashInfoHandler.type){
        if Thread.isMainThread {
            self.dashInfo = self.dashInfoHandler.getInfoForTime(time: time)
            self.chosenDataSource = sourceType
            self.tableView.reloadData()
            self.reloadTableViewHeight()
        } else {
            DispatchQueue.main.async {
                self.reloadInfo(sourceType: sourceType, time: time)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(height[indexPath.row])
    }


    
    //selectionTableView
    func initChoosetimeLapse(responder: LastDaysTableViewCell) {
        if responderForDaysList == nil {
            
        }
        responderForDaysList = DaysTableViewDelegate(responder: responder, parent: self)
        self.chooseDaysTableView.delegate = responderForDaysList
        self.chooseDaysTableView.dataSource = responderForDaysList
    }
    
    /*
     * select desired period (day, 3days, week...).
     */
    func toggleChoosetimeLapse(responder: LastDaysTableViewCell, choice: Int) {
        if chooseDaysView.isHidden {
            chooseDaysTableView.reloadData()
            let place = responder.timeButton.frame
            //set width
            self.chooseDaysTableWidth.constant = place.width + 10
            //set height
            self.chooseDaysTableHeight.constant = CGFloat(responder.timeLapse.count) * responderForDaysList!.sizeForCells
            
            chooseDaysView.frame = CGRect(x: 0, y: 0, width: chooseDaysTableWidth.constant, height: chooseDaysTableHeight.constant)
            chooseDaysView.bounds = chooseDaysView.frame
            //set x and y
            let btnCenterY = place.maxY // - place.minY
            let btnCenterX = place.minX + (place.maxX - place.minX)/2
            let tableViewShift = tableView.frame.minY
            chooseDaysView.center = CGPoint(x: btnCenterX, y: 10 + tableViewShift + btnCenterY + (self.chooseDaysTableHeight.constant / 2))
            //add sub-view
            scrollView.addSubview(chooseDaysView)
            
        } else {
            //remove subview
            chooseDaysView.removeFromSuperview()
            var dashTypeChoice = DashInfoHandler.type(rawValue: choice)!
            if self.chosen != dashTypeChoice {
                //reloadAllView
                self.chosen = dashTypeChoice
                self.reloadTableView(time: dashTypeChoice)
            }
        }
        chooseDaysView.isHidden = !chooseDaysView.isHidden
    }
    
    
    @objc func goToTimeSpent(){
        if chosenDataSource?.name == dashboardTypeOptions.first?.name {
            print("Time spent for YOU")
            let newView = storyboard?.instantiateViewController(withIdentifier: "TransportModeDataViewController") as! TransportModeDataViewController
            newView.screenType = TransportModeDataViewController.screenTypeOptions.YOU_TIME.rawValue
            newView.eraType = chosen
            self.present(newView, animated: true)
        } else {
            goToCommunityTimeSpent()
        }
    }
    
    @objc func goToDistSpent(){
        if chosenDataSource?.name == dashboardTypeOptions.first?.name {
            print("Dist travelled for YOU")
            let newView = storyboard?.instantiateViewController(withIdentifier: "TransportModeDataViewController") as! TransportModeDataViewController
            newView.screenType = TransportModeDataViewController.screenTypeOptions.YOU_DISTANCE.rawValue
            newView.eraType = chosen
            self.present(newView, animated: true)
        } else {
            print("Dist travelled for Community")
            goToCommunityDistTravelled()
        }
    }
    
    @objc func goToCo2Spent(){
        print("Co2 spent selector")
        if chosenDataSource?.name == dashboardTypeOptions.first?.name {
            print("Co2 spent for YOU")
            let newView = storyboard?.instantiateViewController(withIdentifier: "TransportModeDataViewController") as! TransportModeDataViewController
            newView.screenType = TransportModeDataViewController.screenTypeOptions.YOU_CO2.rawValue
            newView.eraType = chosen
            self.present(newView, animated: true)
        } else {
            goToCommunityCo2Spent()
        }
    }
    
    @objc func goToCaloriesSpent(){
        if chosenDataSource?.name == dashboardTypeOptions.first?.name {
            print("Calories spent for YOU")
            let newView = storyboard?.instantiateViewController(withIdentifier: "TransportModeDataViewController") as! TransportModeDataViewController
            newView.screenType = TransportModeDataViewController.screenTypeOptions.YOU_CALORIES.rawValue
            newView.eraType = chosen
            self.present(newView, animated: true)
        } else {
            goToCommunityCaloriesSpent()
        }
    }
    
    func goToCommunityTimeSpent(){
        let newView = storyboard?.instantiateViewController(withIdentifier: "CommunityDataPerModeViewController") as! CommunityDataPerModeViewController
        newView.screenType = CommunityDataPerModeViewController.screenTypeOptions.COMMUNITY_TIME.rawValue
        newView.eraType = chosen
        newView.chosenDashboardType = self.chosenDataSource
        self.present(newView, animated: true)
    }
    
    func goToCommunityDistTravelled(){
        let newView = storyboard?.instantiateViewController(withIdentifier: "CommunityDataPerModeViewController") as! CommunityDataPerModeViewController
        newView.screenType = CommunityDataPerModeViewController.screenTypeOptions.COMMUNITY_DISTANCE.rawValue
        newView.eraType = chosen
        newView.chosenDashboardType = self.chosenDataSource
        self.present(newView, animated: true)
    }
    
    func goToCommunityCo2Spent(){
        let newView = storyboard?.instantiateViewController(withIdentifier: "CommunityDataPerModeViewController") as! CommunityDataPerModeViewController
        newView.screenType = CommunityDataPerModeViewController.screenTypeOptions.COMMUNITY_CO2.rawValue
        newView.eraType = chosen
        newView.chosenDashboardType = self.chosenDataSource
        self.present(newView, animated: true)
    }
    
    func goToCommunityCaloriesSpent(){
        let newView = storyboard?.instantiateViewController(withIdentifier: "CommunityDataPerModeViewController") as! CommunityDataPerModeViewController
        newView.screenType = CommunityDataPerModeViewController.screenTypeOptions.COMMUNITY_CALORIES.rawValue
        newView.eraType = chosen
        newView.chosenDashboardType = self.chosenDataSource
        self.present(newView, animated: true)
    }
    
    @objc func showInfoBalloon(){
        infoIsOut = true
        self.layoutView.removeFromSuperview()
        let newX = tableView.center.x
        var positionY = CGFloat(280)
        if let newY = tableView.cellForRow(at: IndexPath(item: 1, section: 1))?.bounds.minY {
            positionY = newY
            print("Balloon Y pos: \(positionY)")
        }
        
        let center = CGPoint(x: newX, y: positionY)
        loadLayoutView(center: center, text: NSLocalizedString("Dashboard_Balloon_Text_Worthwhile_From_Leg_Info_Recorded", comment: ""))
        
        self.view.addSubview(self.layoutView)
    }
    
    @objc func removeInfoBalloon(){
        infoIsOut = false
       self.layoutView.removeFromSuperview()
    }
    
    @objc func goToProductivity(){
        let newView = storyboard?.instantiateViewController(withIdentifier: "WorthwhilenessCommunityVC") as! WorthwhilenessCommunityVC
        newView.screenType = WorthwhilenessCommunityVC.screenTypeOptions.Productivity.rawValue
        newView.dashboard = self
        self.present(newView, animated: true)
    }
    
    @objc func goToEnjoyment(){
        let newView = storyboard?.instantiateViewController(withIdentifier: "WorthwhilenessCommunityVC") as! WorthwhilenessCommunityVC
        newView.screenType = WorthwhilenessCommunityVC.screenTypeOptions.Enjoyment.rawValue
        newView.dashboard = self
        self.present(newView, animated: true)
    }
    
    @objc func goToFitness(){
        let newView = storyboard?.instantiateViewController(withIdentifier: "WorthwhilenessCommunityVC") as! WorthwhilenessCommunityVC
        newView.screenType = WorthwhilenessCommunityVC.screenTypeOptions.Fitness.rawValue
        newView.dashboard = self
        self.present(newView, animated: true)
    }
    
    @objc func goToWorthwhile(){
        let newView = storyboard?.instantiateViewController(withIdentifier: "WorthwhilenessCommunityVC") as! WorthwhilenessCommunityVC
        newView.screenType = WorthwhilenessCommunityVC.screenTypeOptions.Worthwhileness.rawValue
        newView.dashboard = self
        self.present(newView, animated: true)
    }
    
    @objc func openCo2InfoBalloon() {
        let popupVC = UIStoryboard(name: "MoTiVProduction", bundle: nil).instantiateViewController(withIdentifier: "Co2InfoPopup") as! Co2InfoPopup
        let width = CGFloat(250)
        let height = CGFloat(450)
        let popup = PopupViewController(contentController: popupVC, position: .center(nil), popupWidth: width, popupHeight: height)
        popup.canTapOutsideToDismiss = true
        self.present(popup, animated: true, completion: nil)
    }
    
    func loadLayoutView(center: CGPoint, text: String) {
        for view in layoutView.subviews {
            view.removeFromSuperview()
        }
        layoutView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width/1.5, height: self.view.bounds.width/4)
        layoutView.center = center
        MotivAuxiliaryFunctions.RoundView(view: layoutView, CompleteRoundCorners: true)
        layoutView.backgroundColor = MotivColors.WoortiOrangeT2
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: layoutView.bounds.width - 20, height: layoutView.bounds.height))
        label.center = CGPoint(x: layoutView.bounds.width/2, y: layoutView.bounds.height/2)

        MotivFont.motivRegularFontFor(text: text, label: label, size: 9)
        label.textColor = MotivColors.WoortiOrange
        label.textAlignment = .center
        label.numberOfLines = 10
        layoutView.addSubview(label)
        
        layoutView.isUserInteractionEnabled = true
        let gr = UITapGestureRecognizer(target: self, action: #selector(removeInfoBalloon))
        self.layoutView.addGestureRecognizer(gr)
    }
    
    //FUNC TO RETURN (Co2, calories, totalDistance) for community
    func getCommunityStatsToShow() -> (Int, Int, StatsPerTimeInterval) {
        print("Dashboard - get community stats")
        if let globalStats = GlobalStatsManager.instance.statsFromServer {
            print("Dashboard - stats exist")
            if let dataSource = chosenDataSource {
                
                var statsHolder : StatsHolder?
                var stats : StatsPerTimeInterval        //Final stats relevant to show here
                
                
                //Get stats holder (city, country or campaign by id)
                statsHolder = globalStats.country!
                if dataSource.type == NSLocalizedString("Country", comment: "") {
                    statsHolder = globalStats.country!
                } else if dataSource.type == NSLocalizedString("City_Region", comment: "") {
                    statsHolder = globalStats.city!
                } else if dataSource.type == NSLocalizedString("Campaign", comment: "") {
                    if let statsById = globalStats.campaigns[dataSource.id!] {
                        statsHolder = statsById
                    }
                }
                
                print("Dashboard - got community stats holder")
                
                switch(chosen){
                case DashInfoHandler.type.Day:
                    stats = statsHolder!.day1!
                    break
                case DashInfoHandler.type.ThreeDays:
                    stats = statsHolder!.day3!
                    break
                case DashInfoHandler.type.Week:
                    stats = statsHolder!.day7!
                    break
                case DashInfoHandler.type.Month:
                    stats = statsHolder!.day30!
                    break
                case DashInfoHandler.type.Year:
                    stats = statsHolder!.day365!
                    break
                case DashInfoHandler.type.Era:
                    stats = statsHolder!.era!
                    break
                }
                var communityCo2 = 0.0
                var communityCalories = 0.0
                
                if let correctedModes = stats.correctedModes {
                    for mode in correctedModes {
                        communityCo2 += getModeCo2(mode: Trip.getModeOfTransportById(id: mode.mode), dist: mode.distance / 1000)
                        communityCalories += getModeCalories(mode: Trip.getModeOfTransportById(id: mode.mode), dist: mode.distance / 1000)
                    }
                }
                
                if stats.totalUsers == 0 {
                    stats.totalUsers = 1
                }
                return (Int(communityCo2) / stats.totalUsers, Int(communityCalories) / stats.totalUsers, stats)
            }
        }
        print("Dashboard - nil stats")
        return (10, 10, StatsPerTimeInterval())
    }
    
    func getModeCo2(mode: Trip.modesOfTransport, dist: Double) -> Double {
        return DashInfo.getCO2FromMode(mode: mode) * dist
    }
    
    func getModeCalories(mode: Trip.modesOfTransport, dist: Double) -> Double {
        return Double(DashInfo.getCaloriesFromMode(mode: mode)) * dist
    }
    
}

class DashboardTypeOption {
    var type : String
    var name : String
    var id : String?
    
    init(type: String, name: String, id: String? = nil){
        self.type = type
        self.name = name
        if let campaignId = id {
            self.id = campaignId        }
    }
    
    
    

}

class DaysTableViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    let responder: LastDaysTableViewCell
    let parent: DashboardViewController
    let sizeForCells = CGFloat(44)
    
    init(responder: LastDaysTableViewCell, parent: DashboardViewController) {
        self.responder = responder
        self.parent = parent
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responder.timeLapse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DaysTableViewCell") as! DaysTableViewCell
        cell.loadCell(text: responder.timeLapse[indexPath.row], selected: responder.chosen == indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        parent.toggleChoosetimeLapse(responder: responder, choice: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sizeForCells
    }
    
}

class DashboardTypeDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    let parent: DashboardViewController
    
    init(parent: DashboardViewController) {
        self.parent = parent
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parent.dashboardTypeOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        let optionType = parent.dashboardTypeOptions[indexPath.row]
        cell = tableView.dequeueReusableCell(withIdentifier: "DashboardTypeTableViewCell") as! DashboardTypeTableViewCell
        (cell as! DashboardTypeTableViewCell).loadCell(type: optionType.type, name: optionType.name)
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if GlobalStatsManager.instance.validateStats() {
        
            let option = parent.dashboardTypeOptions[indexPath.row]
            parent.DashboardTypeOptions.isHidden = true
            parent.chosenDataSource = option
            parent.reloadInfo(sourceType: option, time: parent.chosen)
            MotivAuxiliaryFunctions.loadStandardButton(button: parent.youButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, text: "You", boldText: true, size: 14, disabled: false, border: false, borderColor: UIColor.clear, CompleteRoundCorners: false)
            
            var youButtonTitle : NSAttributedString
            if let chosenSource = parent.chosenDataSource {
                youButtonTitle = NSAttributedString(string: chosenSource.name, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
                
            } else {
                youButtonTitle = NSAttributedString(string: "You", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
            }
           parent.youButton.setAttributedTitle(youButtonTitle, for: .normal)
           parent.youButton.tintColor = UIColor.white
           parent.youButton.setImage(UIImage(named: "cm_arrow_downward_white")?.withRenderingMode(.alwaysTemplate), for: .normal)
           parent.youButton.titleLabel!.lineBreakMode = .byWordWrapping
        }else {
            UiAlerts.getInstance().showAlertMsg(title: "", message: NSLocalizedString("Unable_Show_Stats", comment: ""))
            parent.DashboardTypeOptions.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}








