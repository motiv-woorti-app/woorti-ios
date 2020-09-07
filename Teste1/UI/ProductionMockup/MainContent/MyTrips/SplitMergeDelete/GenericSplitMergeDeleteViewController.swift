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

class GenericSplitMergeDeleteViewController: MTGenericViewController {
    
    var defaultViewControler: MTGenericViewController?
    var topViewControler: SplitMergeDeleteTopViewController?
    var option = Option.split
    
    var topFadeView: UIView?
    
    var backControllers = [MTGenericViewController]()
    @IBOutlet weak var contentPage: UIView!
    
    private var hasLoaded = false
    
    enum Option {
        case split
        case merge
        case delete
    }
    
    enum MTViews: String {
        case SMDMyTripsBack
        case SMDMyTripsSplitMap
        case SMDMyTripsBackFromDelete
        case SMDMyTripsBackEnd
    }
    
    enum MOTNotifs: String {
        case SMDFadeTOMOTView
        case SMDunFadeTOMOTView
    }
    
    // motSelection
    @IBOutlet weak var ChooseModeOfTRansportView: UIView!
    var fadeView: UIView?
    @IBOutlet weak var MainView: UIView!
    var MotSelectionView: GenericModeOfTransportPicker?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(changeToBack), name: NSNotification.Name(rawValue: MTViews.SMDMyTripsBack.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToBackFromDelete), name: NSNotification.Name(rawValue: MTViews.SMDMyTripsBackFromDelete.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToBackEndAll), name: NSNotification.Name(rawValue: MTViews.SMDMyTripsBackEnd.rawValue), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToSplitMap), name: NSNotification.Name(rawValue: MTViews.SMDMyTripsSplitMap.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fadeTopViews), name: NSNotification.Name(rawValue: SMDMergeViewController.callbacks.SMDFadeOnMerge.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unfadeTopViews), name: NSNotification.Name(rawValue: SMDMergeViewController.callbacks.SMDUnFadeOnMerge.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fadeTOMOTViews(_:)), name: NSNotification.Name(rawValue: MOTNotifs.SMDFadeTOMOTView.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unfadeTOMOTViews), name: NSNotification.Name(rawValue: MOTNotifs.SMDunFadeTOMOTView.rawValue), object: nil)
        // Do any additional setup after loading the view.
        ChangeToSelectedMainView()
        hasLoaded = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeToBackOnLast() {
        if let parent = self.presentingViewController as? OptionsMenuViewController {
            self.dismiss(animated: true, completion: nil)
            parent.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    fileprivate func ChangeToSelectedMainView() {
        switch self.option {
        case .split:
            break
        case .merge:
            changeToMergeTrips()
            break
        case .delete:
            changeToDeleteTrips()
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let vc as MTGenericViewController:
            self.defaultViewControler = vc
            vc.setFT(ft: self.getFt()!)
            if hasLoaded {
                ChangeToSelectedMainView()
            }
        case let topMenu as SplitMergeDeleteTopViewController:
            self.topViewControler = topMenu
        default:
            break
        }
    }
    
    func setOptionToShow(option: Option) {
        self.option = option
    }
    
    //Change to views
    @objc func changeToBack(){
        if backControllers.count == 0 {
            changeToBackOnLast()
        } else {
            let prevVC = backControllers.removeLast()
            self.changeContainedView(newViewController: prevVC)
        }
    }
    
    @objc func changeToBackFromDelete(){
        if backControllers.count == 0 {
            changeToBackOnLast()
        } else {
            changeToBack()
        }
    }
    
    @objc func changeToBackEndAll(){
        while backControllers.count > 0 {
            changeToBack()
        }
    }
    
    @objc func changeToSplitMap(_ notification: NSNotification){
        if let parts = notification.userInfo?["parts"] as? [FullTripPart],
            let type = notification.userInfo?["type"] as? SplitMapViewViewController.mapType{
            
            let splitMapViewViewController = storyboard?.instantiateViewController(withIdentifier: "SplitMapViewViewController") as! SplitMapViewViewController
            
            var min = -1
            var max = -1
            
            if let allParts = self.getFt()?.getTripPartsortedList() {
                for leg in parts {
                    if let place = allParts.index(of: leg) {
                        if place < min || min == -1 {
                            min = place
                        }
                        if place > max {
                            max = place
                        }
                    }
                }
            }
            
            splitMapViewViewController.SetUp(start: min, end: max, type: type)
            if self.defaultViewControler != nil {
                backControllers.append(self.defaultViewControler!)
            }
            self.changeContainedView(newViewController: splitMapViewViewController)
        }
    }
    
    @objc func changeToMergeTrips() {
        let sMDMergeViewController = storyboard?.instantiateViewController(withIdentifier: "SMDMergeViewController") as! SMDMergeViewController
        self.changeContainedView(newViewController: sMDMergeViewController)
    }
    
    
    @objc func changeToDeleteTrips() {
        let sMDMergeViewController = storyboard?.instantiateViewController(withIdentifier: "SMDDeleteViewController") as! SMDDeleteViewController
        self.changeContainedView(newViewController: sMDMergeViewController)
    }

    //Changing view
    private func changeContainedView(newViewController: MTGenericViewController){
        if Thread.current.isMainThread {
            if self.defaultViewControler != nil {
                self.remove(asChildViewController: self.defaultViewControler!)
            }
            newViewController.setFT(ft: self.getFt()!)
            self.defaultViewControler = newViewController
            self.add(asChildViewController: newViewController)
        } else {
            DispatchQueue.main.async {
                self.changeContainedView(newViewController: newViewController)
            }
        }
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
    
    //fade/unfade
    
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
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  SMDMergeViewController.callbacks.SMDUnFadeOnMerge.rawValue), object: nil)
    }
    
    @objc func unfadeTopViews() {
        
        if topFadeView != nil {
            topFadeView?.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    // MotChoosing
    //fading top view
    @objc func fadeTOMOTViews(_ notification: NSNotification) {
        if let getter = notification.userInfo?["getter"] as? MotGetter {
            
            let bundle = Bundle(for: type(of: self))
            let nib = UINib(nibName: "GenericModeOfTransportPickerView", bundle: bundle)
            MotSelectionView = nib.instantiate(withOwner: self, options: nil).first as! GenericModeOfTransportPicker
            MotSelectionView?.setMotGetter(getter: getter)
            
            
            self.ChooseModeOfTRansportView.bounds = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.view.bounds.width - 20 , height: self.view.bounds.height - 20 )
            self.view.addSubview(self.ChooseModeOfTRansportView)
            
            self.ChooseModeOfTRansportView.layer.cornerRadius = self.ChooseModeOfTRansportView.bounds.width * 0.05
            self.ChooseModeOfTRansportView.layer.masksToBounds = true
            
            MotSelectionView?.frame = ChooseModeOfTRansportView.bounds
            ChooseModeOfTRansportView.addSubview(MotSelectionView!)
            self.ChooseModeOfTRansportView.center = self.view.center
            
            self.view.bringSubview(toFront: self.ChooseModeOfTRansportView)
            if let firstFrame = MainView?.bounds {
                fadeView = UIView(frame: firstFrame)
                fadeView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                MainView?.addSubview(fadeView!)
                fadeView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(unfadeTOMOTViews)))
            }
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func unfadeTOMOTViews() {
        
        //        self.ChooseModeOfTRansportView.isHidden = true
        //        self.fadeView?.removeFromSuperview()
        self.ChooseModeOfTRansportView?.removeFromSuperview()
        
        if fadeView != nil {
            fadeView?.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
