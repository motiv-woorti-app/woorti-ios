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
 * View that holds the top bar and a placeholder for content views.
 */
class MainViewController: UIViewController {

    @IBOutlet weak var menuLeadingContraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var toolbarTraillingConstraint: NSLayoutConstraint!
    @IBOutlet weak var defaultPageTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var MenuButton: UIButton!
    @IBOutlet weak var TopBar: UIView!
    
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    
    @IBOutlet weak var powerImage: UIImageView!
    @IBOutlet weak var editImageView: UIImageView!
    
    var defaultViewControler: GenericViewController?
    var sideMenu: SideMenuTableViewController?
    
    var fadeView: UIView?
    var topFadeView: UIView?
    var touch = UITapGestureRecognizer(target: self, action: #selector(setGoalPopup))
    
    private var canShowEdit = true
    
    enum MainViewOptions: String {
        case ToggleMenu
        case ShowRoutePlanner
        case ShowDefaultPage
        case ShowMyTrips
        case ShowMobilityCoach
        case ShowProfileAndSettings
        case ShowProfileAndSettingsDemographic
        case ShowDashboard
        
        case EnableGoalPopupImage
        case DisableGoalPopupImage
        case SendLogEmail
        case GoToReporting
        case ShowshowEdit
        case ShowHideEdit
        case LogOut
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editImageView.image = editImageView.image?.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
        
        MenuButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        powerImage.tintColor = MotivColors.WoortiOrangeT1
        self.view.backgroundColor = MotivColors.WoortiOrange
        self.TopBar.backgroundColor = MotivColors.WoortiOrange
        
        NotificationCenter.default.addObserver(self, selector: #selector(toggleMenu), name: NSNotification.Name(rawValue: MainViewOptions.ToggleMenu.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToDefault), name: NSNotification.Name(rawValue: MainViewOptions.ShowDefaultPage.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToMyTrips), name: NSNotification.Name(rawValue: MainViewOptions.ShowMyTrips.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToMobilityCoach), name: NSNotification.Name(rawValue: MainViewOptions.ShowMobilityCoach.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToProfileAndSettings), name: NSNotification.Name(rawValue: MainViewOptions.ShowProfileAndSettings.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToProfileAndSettingsDemographic), name: NSNotification.Name(rawValue: MainViewOptions.ShowProfileAndSettingsDemographic.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToDashboard), name: NSNotification.Name(rawValue: MainViewOptions.ShowDashboard.rawValue), object: nil)
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(enablePopupImage), name: NSNotification.Name(rawValue: MainViewOptions.EnableGoalPopupImage.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disablePopupImage), name: NSNotification.Name(rawValue: MainViewOptions.DisableGoalPopupImage.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showEdit), name: NSNotification.Name(rawValue: MainViewOptions.ShowshowEdit.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideEdit), name: NSNotification.Name(rawValue: MainViewOptions.ShowHideEdit.rawValue), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(logOut), name: NSNotification.Name(rawValue: MainViewOptions.LogOut.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(
            goToReporting), name: NSNotification.Name(rawValue: MainViewOptions.GoToReporting.rawValue), object: nil)
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(editTrip))
        self.editImageView.addGestureRecognizer(gr)
        
        let grshowPopup = UITapGestureRecognizer(target: self, action: #selector(showPopup))
        self.powerImage.addGestureRecognizer(grshowPopup)
        
        // Do any additional setup after loading the view.
        UserInfo.startUpTripDetectionOnStart()
        
        self.rightImageView.isHidden = true
        self.topTitle.text = "Home"
    }
    
    @objc func logOut() {
        print("LOG OUT, DISMISS VIEW")
        
        let vc = self.presentingViewController
        
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
     
    }

    
    @objc func showPopup() {
        MotivUser.getInstance()?.showBatteryPopup()
        self.powerImage.isHidden = true
        
        UiAlerts.getInstance().newView(view: self)
        UiAlerts.getInstance().showBateryConsumptionInfo()
    }
    
    @objc func sendLogEmail() {
        EmailManager.getInstance().sendEmail(view: self)
    }
    
    @objc func setGoalPopup() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MobilityCoachViewController.MobilityCoachSetGoalPopUp), object: nil)
    }
    
    @objc func editTrip() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyTripsViewController.MyTipsObserver.MTeditTrip.rawValue), object: nil)
    }
    
    @objc func enablePopupImage(){
        touch = UITapGestureRecognizer(target: self, action: #selector(setGoalPopup))
         self.rightImageView.addGestureRecognizer(touch)
    }
    
    @objc func disablePopupImage(){
         self.rightImageView.removeGestureRecognizer(touch)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func toggleMenu(forceClose: Bool = false) {
        if menuLeadingContraint.constant == 0 || forceClose {
            toolbarTraillingConstraint.constant = 0
            defaultPageTrailingConstraint.constant = 0
            menuLeadingContraint.constant = -224
            if fadeView != nil {
                fadeView?.removeFromSuperview()
            }
            if topFadeView != nil {
                topFadeView?.removeFromSuperview()
            }
        } else {
            toolbarTraillingConstraint.constant = 224
            defaultPageTrailingConstraint.constant = 224
            menuLeadingContraint.constant = 0
            if let firstFrame = defaultViewControler?.view.bounds {
                fadeView = UIView(frame: firstFrame)
                fadeView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                defaultViewControler?.view.addSubview(fadeView!)
                fadeView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleMenu)))
            }
            if let firstFrame = TopBar?.bounds {
                topFadeView = UIView(frame: firstFrame)
                topFadeView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                TopBar.addSubview(topFadeView!)
                topFadeView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleMenu)))
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func ClickOnMenu(_ sender: Any) {
        toggleMenu()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
            
        case let vc as DefaultViewController:
            self.defaultViewControler = vc
            
        case let vc as MyTripsViewController:
            self.defaultViewControler = vc
            
        case let vc as SideMenuTableViewController:
            self.sideMenu = vc
            
        case let surveyvc as SurveyViewController :
            surveyvc.loadReporting()
        default:
            break
        }
    }
    
    //entry for showing specific pages
    @objc func goToReporting(){
        self.performSegue(withIdentifier: "ShowSurvey", sender: nil)
    }
    
    @objc func changeToDefault(){
        let DefaultView = storyboard?.instantiateViewController(withIdentifier: "DefaultView") as! DefaultViewController
        self.defaultViewControler = DefaultView
        self.changeContainedView(newViewController: DefaultView)
        self.topTitle.text = NSLocalizedString("Drawer_Title_Home", comment: "")
        self.rightImageView.isHidden = true
        self.editImageView.isHidden = true
        self.powerImage.isHidden = true
        canShowEdit = false
    }
    
    @objc func changeToMyTrips(){
        let MyTrips = storyboard?.instantiateViewController(withIdentifier: "MyTrips") as! MyTripsViewController
        self.defaultViewControler = MyTrips
        self.changeContainedView(newViewController: MyTrips)
        self.topTitle.text = NSLocalizedString("Drawer_Title_My_Trips", comment: "")
        self.rightImageView.isHidden = true
        self.editImageView.isHidden = false
        self.editImageView.isUserInteractionEnabled = true
        self.powerImage.isHidden = !(MotivUser.getInstance()?.showBatteryPopup() ?? false)
        canShowEdit = true
    }
    
    @objc func changeToMobilityCoach(){
        let MobilityCoach = storyboard?.instantiateViewController(withIdentifier: "MobilityCoachViewController") as! MobilityCoachViewController
        self.defaultViewControler = MobilityCoach
        self.changeContainedView(newViewController: MobilityCoach)
        self.topTitle.text = NSLocalizedString("Drawer_Title_Mobility_Coach", comment: "")
        self.rightImageView.isHidden = false
        self.rightImageView.isUserInteractionEnabled = true
        self.editImageView.isHidden = true
        self.powerImage.isHidden = true
        canShowEdit = false
    }
    
    @objc func changeToProfileAndSettings() {
        let ProfileAndSettings = storyboard?.instantiateViewController(withIdentifier: "ProfileAndSettingsViewController") as! ProfileAndSettingsViewController
        self.defaultViewControler = ProfileAndSettings
        self.changeContainedView(newViewController: ProfileAndSettings)
        self.topTitle.text = NSLocalizedString("Drawer_Title_Settings", comment: "")
        self.rightImageView.isHidden = true
        self.editImageView.isHidden = true
        self.powerImage.isHidden = true
        canShowEdit = false
    }
    
    @objc func changeToProfileAndSettingsDemographic() {
        let ProfileAndSettings = storyboard?.instantiateViewController(withIdentifier: "ProfileAndSettingsViewController") as! ProfileAndSettingsViewController
        self.defaultViewControler = ProfileAndSettings
        self.changeContainedView(newViewController: ProfileAndSettings)
        self.topTitle.text = NSLocalizedString("Drawer_Title_Settings", comment: "")
        self.rightImageView.isHidden = true
        self.editImageView.isHidden = true
        self.powerImage.isHidden = true
        canShowEdit = false
        ProfileAndSettings.option = ProfileAndSettingsContentMainViewController.Option.DemographicInfo
        //ProfileAndSettings.goToSelectedScreen(option: ProfileAndSettingsContentMainViewController.Option.DemographicInfo)
    }
    
    @objc func changeToDashboard() {
        let Dashboard = storyboard?.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
        self.defaultViewControler = Dashboard
        self.changeContainedView(newViewController: Dashboard)
        self.topTitle.text = NSLocalizedString("Drawer_Title_Dashboard", comment: "")
        self.rightImageView.isHidden = true
        self.editImageView.isHidden = true
        self.powerImage.isHidden = true
        canShowEdit = false
    }
    
    @objc func showEdit() {
        if canShowEdit {
            self.editImageView.isHidden = false
            self.editImageView.isUserInteractionEnabled = true
        }
    }
    
    @objc func hideEdit() {
        self.editImageView.isHidden = true
        self.editImageView.isUserInteractionEnabled = false
    }
    
    //Changing view
    private func changeContainedView(newViewController: UIViewController){
        if self.defaultViewControler != nil {
            self.remove(asChildViewController: self.defaultViewControler!)
        }
        self.add(asChildViewController: newViewController)
        self.toggleMenu(forceClose: true)
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        self.contentView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = self.contentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStor.selfyboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
