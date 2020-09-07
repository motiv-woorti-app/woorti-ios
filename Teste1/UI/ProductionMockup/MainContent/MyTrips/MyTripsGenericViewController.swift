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

class MyTripsGenericViewController: UIViewController {

    @IBOutlet weak var contentPage: UIView!
    let CHANGETOEDITTRIP = "OptionsMenuSegue"
    let CHANGETOMAP = "ShowMapSegue"
    
    var defaultViewControler: MTGenericViewController?
    var topViewControler: MTTopBarViewController?
    
    private var backControllers = [MTGenericViewController]()
    var ftToConfirm: FullTrip?
    
    var topFadeView: UIView?
    
    enum MTViews: String {
        case MyTripsBack
        case MyTripsObjective
        case MyTripsRateTrip
        case MyTripsActivitiesTrip
        case MyTripsConfirmTrip
        case MyTripsEditTrip
        case MyTripsMapTrip
        case MyTripsTripWorthness
        case MyTripsFeedBackChoice
        case MyTripswastedTripPage
        case MyTripsworthwhilenessFactors
        case MyTripsValuePart
        case myTripsUseYourTrip
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(changeToBack), name: NSNotification.Name(rawValue: MTViews.MyTripsBack.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToRateTrip), name: NSNotification.Name(rawValue: MTViews.MyTripsRateTrip.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToActivitiesTrip), name: NSNotification.Name(rawValue: MTViews.MyTripsActivitiesTrip.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConfirmTrip), name: NSNotification.Name(rawValue: MTViews.MyTripsConfirmTrip.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToObjectiveTrip), name: NSNotification.Name(rawValue: MTViews.MyTripsObjective.rawValue), object: nil)
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(changeToTripWorthness), name: NSNotification.Name(rawValue: MTViews.MyTripsTripWorthness.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToFeedBackChoice), name: NSNotification.Name(rawValue: MTViews.MyTripsFeedBackChoice.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToTimeWasted), name: NSNotification.Name(rawValue: MTViews.MyTripswastedTripPage.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToWorthwhileFactors), name: NSNotification.Name(rawValue: MTViews.MyTripsworthwhilenessFactors.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToValuePart), name: NSNotification.Name(rawValue: MTViews.MyTripsValuePart.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToUseYourTrip), name: NSNotification.Name(rawValue: MTViews.myTripsUseYourTrip.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fadeTopViews), name: NSNotification.Name(rawValue: MTActivitiesViewController.callbacks.MTChooseActivitiesStart.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unfadeTopViews), name: NSNotification.Name(rawValue: MTActivitiesViewController.callbacks.MTChooseActivitiesEnd.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fadeTopViews), name: NSNotification.Name(rawValue: MTConfirmModesViewController.callbacks.MTChooseConfirmModeStartCarrousell.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unfadeTopViews), name: NSNotification.Name(rawValue: MTConfirmModesViewController.callbacks.MTChooseConfirmModeEndCarrousell.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToEditTrip), name: NSNotification.Name(rawValue: MTViews.MyTripsEditTrip.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToMap), name: NSNotification.Name(rawValue: MTViews.MyTripsMapTrip.rawValue), object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
        case let editMenu as OptionsMenuViewController:
            editMenu.setFT(ft: self.ftToConfirm!)
        case let vc as MTGenericViewController:
            self.defaultViewControler = vc
            vc.setFT(ft: self.ftToConfirm!)
            
            if let topView = self.topViewControler {
                topView.ft = self.ftToConfirm
                switch vc {
                case is MTTripObjectiveViewController:
                    topView.loadProgressBar(newIndex: Float(1))
                    topView.pointsToAdd(points: ScoreManager.getInstance().getAddedScoreForMainCampaign(type: ScoreManager.pointsType.pointsTripPurpose))
                case is MTConfirmModesViewController:
                    topView.loadProgressBar(newIndex: Float(0))
                    topView.pointsToAdd(points: ScoreManager.getInstance().getAddedScoreForMainCampaign(type: ScoreManager.pointsType.pointsTransportMode))
                case is RateTripViewController:
                    topView.loadProgressBar(newIndex: Float(2))
                    topView.pointsToAdd(points: Double(0))
                case is MTActivitiesViewController:
                    topView.loadProgressBar(newIndex: Float(3))
                    topView.pointsToAdd(points: Double(0))
                case is MyTripsWorthwhileFactorsViewController:
                    topView.loadProgressBar(newIndex: Float(0))
                    topView.pointsToAdd(points: ScoreManager.getInstance().getAddedScoreForMainCampaign(type: ScoreManager.pointsType.pointsWorth))
                case is ValueForYourTripViewController:
                    topView.loadProgressBar(newIndex: Float(0))
                    topView.pointsToAdd(points: ScoreManager.getInstance().getAddedScoreForMainCampaign(type: ScoreManager.pointsType.pointsActivities))
                case is UseTripForViewController:
                    topView.loadProgressBar(newIndex: Float(3))
                    topView.pointsToAdd(points: ScoreManager.getInstance().getAddedScoreForMainCampaign(type: ScoreManager.pointsType.pointsAllInfo))
                default:
                    topView.pointsToAdd(points: Double(0))
                    topView.loadProgressBar(newIndex: Float(0))
                }
            }
        case let topMenu as MTTopBarViewController:
            topMenu.ft = self.ftToConfirm
            self.topViewControler = topMenu
        case let mapVC as TripMapViewController:
            mapVC.fullTripToShow = self.ftToConfirm
        default:
            break
        }
    }
    
    public func executeOnContainedView(vc: MTGenericViewController) {
        if let topView = self.topViewControler {
            topView.ft = self.ftToConfirm
            switch vc {
            case is MTTripObjectiveViewController:
                topView.loadProgressBar(newIndex: Float(1))
                topView.pointsToAdd(points: ScoreManager.getInstance().getAddedScoreForMainCampaign(type: ScoreManager.pointsType.pointsTripPurpose))
            case is MTConfirmModesViewController:
                topView.loadProgressBar(newIndex: Float(0))
                topView.pointsToAdd(points: ScoreManager.getInstance().getAddedScoreForMainCampaign(type: ScoreManager.pointsType.pointsTransportMode))
            case is RateTripViewController:
                topView.loadProgressBar(newIndex: Float(2))
                topView.pointsToAdd(points: Double(0))
            case is MTActivitiesViewController:
                topView.loadProgressBar(newIndex: Float(3))
                topView.pointsToAdd(points: Double(0))
            case is MyTripsWorthwhileFactorsViewController:
                topView.loadProgressBar(newIndex: Float(0))
                topView.pointsToAdd(points: ScoreManager.getInstance().getAddedScoreForMainCampaign(type: ScoreManager.pointsType.pointsWorth))
            case is ValueForYourTripViewController:
                topView.loadProgressBar(newIndex: Float(0))
                topView.pointsToAdd(points: ScoreManager.getInstance().getAddedScoreForMainCampaign(type: ScoreManager.pointsType.pointsActivities))
            case is UseTripForViewController:
                topView.loadProgressBar(newIndex: Float(3))
                topView.pointsToAdd(points: ScoreManager.getInstance().getAddedScoreForMainCampaign(type: ScoreManager.pointsType.pointsAllInfo))
            default:
                topView.pointsToAdd(points: Double(0))
                topView.loadProgressBar(newIndex: Float(0))
            }
        }
    }
    
    @objc func changeToBack(){
        if backControllers.count == 0 {
            self.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyTripsViewController.StartedOrFinishedTrip), object: nil)
        } else {
            let prevVC = backControllers.removeLast()
            self.changeContainedView(newViewController: prevVC)
        }
    }
    
    @objc func changeToObjectiveTrip(){
        let TripObjectiveVC = storyboard?.instantiateViewController(withIdentifier: "MTTripObjectiveViewController") as! MTTripObjectiveViewController
        
        if let topView = self.topViewControler {
            topView.loadProgressBar(newIndex: Float(1))
        }
        
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: TripObjectiveVC)
    }
    
    @objc func changeToActivitiesTrip(){
        let RateTripViewController = storyboard?.instantiateViewController(withIdentifier: "MTActivitiesViewController") as! MTActivitiesViewController
        
        if let topView = self.topViewControler {
            topView.loadProgressBar(newIndex: Float(3))
        }
        
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: RateTripViewController)
    }
    
    @objc func changeToTripWorthness(){
        let RateTripViewController = storyboard?.instantiateViewController(withIdentifier: "TripWorthnessViewController") as! TripWorthnessViewController
        
        if let topView = self.topViewControler {
            topView.loadProgressBar(newIndex: Float(3))
        }
        
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: RateTripViewController)
    }
    
    @objc func changeToFeedBackChoice(){
        let RateTripViewController = storyboard?.instantiateViewController(withIdentifier: "ChoosePartForFeedBackViewController") as! ChoosePartForFeedBackViewController
        
        if let topView = self.topViewControler {
            topView.loadProgressBar(newIndex: Float(3))
        }
        
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: RateTripViewController)
    }
    
    @objc func changeToTimeWasted(){
        let RateTripViewController = storyboard?.instantiateViewController(withIdentifier: "MyTripsTimeWastedViewController") as! MyTripsTimeWastedViewController
        
        if let topView = self.topViewControler {
            topView.loadProgressBar(newIndex: Float(3))
        }
        
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: RateTripViewController)
    }
    
    @objc func changeToWorthwhileFactors(){
        let RateTripViewController = storyboard?.instantiateViewController(withIdentifier: "MyTripsWorthwhileFactorsViewController") as! MyTripsWorthwhileFactorsViewController
        
        if let topView = self.topViewControler {
            topView.loadProgressBar(newIndex: Float(3))
        }
        
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: RateTripViewController)
    }
    
    @objc func changeToRateTrip(){
        let RateTripViewController = storyboard?.instantiateViewController(withIdentifier: "RateTripViewController") as! RateTripViewController
        if let topView = self.topViewControler {
            topView.loadProgressBar(newIndex: Float(2))
        }
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: RateTripViewController)
    }
    
    @objc func changeToValuePart(){
        let RateTripViewController = storyboard?.instantiateViewController(withIdentifier: "ValueForYourTripViewController") as! ValueForYourTripViewController
        if let topView = self.topViewControler {
            topView.loadProgressBar(newIndex: Float(2))
        }
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: RateTripViewController)
    }

    @objc func changeToUseYourTrip(){
        let RateTripViewController = storyboard?.instantiateViewController(withIdentifier: "UseTripForViewController") as! UseTripForViewController
        if let topView = self.topViewControler {
            topView.loadProgressBar(newIndex: Float(2))
        }
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: RateTripViewController)
    }
    
    
    @objc func changeToEditTrip() {

        self.performSegue(withIdentifier: CHANGETOEDITTRIP, sender: self)
    }
    
    @objc func changeToMap() {
        self.performSegue(withIdentifier: CHANGETOMAP, sender: self)
    }
    
    
    @objc func ConfirmTrip(){
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyTripsViewController.StartedOrFinishedTrip), object: nil)

    }

    //Changing view
    private func changeContainedView(newViewController: MTGenericViewController){
        if self.defaultViewControler != nil {
            self.remove(asChildViewController: self.defaultViewControler!)
        }
        newViewController.setFT(ft: self.ftToConfirm!)
        self.defaultViewControler = newViewController
        self.add(asChildViewController: newViewController)
        //execute custom funcs on each controller
        self.executeOnContainedView(vc: newViewController)
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        self.contentPage.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = self.contentPage.bounds
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
    
    @objc func fadeTopViews() {
        if let firstFrame = topViewControler?.view.bounds {
            topFadeView = UIView(frame: firstFrame)
            topFadeView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            topViewControler?.view.addSubview(topFadeView!)
            topFadeView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endActivitySelection)))
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func endActivitySelection(){
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTActivitiesViewController.callbacks.MTChooseActivitiesEnd.rawValue), object: nil)
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTConfirmModesViewController.callbacks.MTChooseConfirmModeEndCarrousell.rawValue), object: nil)
    }
    
    @objc func unfadeTopViews() {
        
        if topFadeView != nil {
            topFadeView?.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
