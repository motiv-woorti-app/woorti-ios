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

class OnboardingTopAndContentViewController: UIViewController {

    var defaultViewControler: GenericViewController?
    var topViewControler: TopOnboardingViewController?
    var backControllers = [GenericViewController]()
    
    @IBOutlet weak var contentPage: UIView!
    
    var option: options = .onboarding
    private var hasLoadedMain = false
    
    enum options {
        case language
        case onboarding
    }
    
    enum OboardViews: String {
        case OBVBack
        case OBVGoToSecondPage
        case OBVGoToProdHelathActiveTutorial
        case OBVGoToMeasureWorthwileness
        case OBVGOTOchangeToRegularMOT
        case OBVGOTOchangeToPRValues
        case OBVGOTOchangeToGDPR
        case OBVGOTOchangeToPermission
        case OBVGOTOchangeToWYName
        case OBVGOTOchangeTochooseCoutryCity
        case OBVGOTOchangeTochooseCoutryCityOther
        case OBVGOTOchangeTochooseCampaigns
        case OBVGOTOchangeTochooseAge
        case OBVGOTOchangeTochooseGender
        case OBVGOTOchangeTochooseDegree
        case OBVGOTOchangeToMain
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(changeToBack), name: NSNotification.Name(rawValue: OboardViews.OBVBack.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToSecondPage), name: NSNotification.Name(rawValue: OboardViews.OBVGoToSecondPage.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToMeasureWorthwileness), name: NSNotification.Name(rawValue: OboardViews.OBVGoToMeasureWorthwileness.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToRegularModesOfTRansport), name: NSNotification.Name(rawValue: OboardViews.OBVGOTOchangeToRegularMOT.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToproductiveRelaxingValues), name: NSNotification.Name(rawValue: OboardViews.OBVGOTOchangeToPRValues.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeTogDPRAcceptance), name: NSNotification.Name(rawValue: OboardViews.OBVGOTOchangeToGDPR.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeTogPermissions), name: NSNotification.Name(rawValue: OboardViews.OBVGOTOchangeToPermission.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeTogWYName), name: NSNotification.Name(rawValue: OboardViews.OBVGOTOchangeToWYName.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToCountryCity), name: NSNotification.Name(rawValue: OboardViews.OBVGOTOchangeTochooseCoutryCity.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToCountryCityOther), name: NSNotification.Name(rawValue: OboardViews.OBVGOTOchangeTochooseCoutryCityOther.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToCampaigns), name: NSNotification.Name(rawValue: OboardViews.OBVGOTOchangeTochooseCampaigns.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToAge), name: NSNotification.Name(rawValue: OboardViews.OBVGOTOchangeTochooseAge.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToGender), name: NSNotification.Name(rawValue: OboardViews.OBVGOTOchangeTochooseGender.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToDegree), name: NSNotification.Name(rawValue: OboardViews.OBVGOTOchangeTochooseDegree.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToMainmenu), name: NSNotification.Name(rawValue: OboardViews.OBVGOTOchangeToMain.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToPMB), name: NSNotification.Name(rawValue: OboardViews.OBVGoToProdHelathActiveTutorial.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadYellowBackgroundCollor), name: NSNotification.Name(rawValue: TopOnboardingViewController.callbacks.TopViewBGYellow.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadOrangeBackgroundCollor), name: NSNotification.Name(rawValue: TopOnboardingViewController.callbacks.TopViewBGOrange.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadBlueBackgroundCollor), name: NSNotification.Name(rawValue: TopOnboardingViewController.callbacks.TopViewBGBlue.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadGreenBackgroundCollor), name: NSNotification.Name(rawValue: TopOnboardingViewController.callbacks.TopViewBGGreen.rawValue), object: nil)
        
        ChangeToSelectedMainView()
        hasLoadedMain = true
        
        self.view.backgroundColor = MotivColors.WoortiOrange
        
        MotivAuxiliaryFunctions.imagedNamedToBackground(name: "Orange_BG_Extended", view: self.view)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func ChangeToSelectedMainView() {
        if defaultViewControler != nil {
            switch self.option {
            case .language:
                break
            case .onboarding:
                self.changeToFirstPage()
                break
            }
        }
    }
    
    @objc func loadOrangeBackgroundCollor() {
        MotivAuxiliaryFunctions.imagedNamedToBackground(name: "Orange_BG_Extended", view: self.view)
    }
    
    @objc func loadYellowBackgroundCollor() {
        MotivAuxiliaryFunctions.imagedNamedToBackground(name: "Yellow_BG_Extended", view: self.view)
    }
    
    @objc func loadBlueBackgroundCollor() {
        MotivAuxiliaryFunctions.imagedNamedToBackground(name: "Blue_BG_Extended", view: self.view)
    }
    
    @objc func loadGreenBackgroundCollor() {
        MotivAuxiliaryFunctions.imagedNamedToBackground(name: "Green_BG_Extended", view: self.view)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let vc as GenericViewController:
            self.defaultViewControler = vc
            
            if hasLoadedMain {
                ChangeToSelectedMainView()
            }
        case let topMenu as TopOnboardingViewController:
            self.topViewControler = topMenu
            switch self.option {
            case .language:
                self.topViewControler?.load(option: self.option, title: "")
                break
            case .onboarding:
                self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().What_Is_A_Worthwhile_Trip)
                break
            }
        default:
            break
        }
    }

    //Change to views
    @objc func changeToBack(){
        if backControllers.count == 0 {
            self.dismiss(animated: true, completion: nil)
//            changeToBackOnLast()
        } else {
            if let vc = self.defaultViewControler as? ProductiveRelaxingValuesViewController,
                vc.type != .prod{
                switch vc.type {
                case .prod:
                    break
                case .enj:
                    vc.type = .prod
                    vc.updateValues()
                    vc.prodText()
                    vc.updateSliders()
                case .fit:
                    vc.type = .enj
                    vc.updateValues()
                    vc.enjText()
                    vc.updateSliders()
                }
            } else if let vc = self.defaultViewControler as? WhereDoYouLiveOnboardViewController,
                vc.type == WhereDoYouLiveOnboardViewController.tvType.cities || vc.type == WhereDoYouLiveOnboardViewController.tvType.otherCountries {
                vc.type = WhereDoYouLiveOnboardViewController.tvType.countries
                vc.reloadTableView()
            } else {
                let prevVC = backControllers.removeLast()
                self.changeContainedView(newViewController: prevVC)
                switch prevVC {
                case is FirstOnBoardingViewController:
                    self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().What_Is_A_Worthwhile_Trip)
                case is SecondOnBoardingViewController:
                    self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().What_Is_A_Worthwhile_Trip)
                case is MeasureWorthwilenessOnboardingViewController:
                    self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().What_Is_A_Worthwhile_Trip)
                case is RegularModesOfTRansportOnboardingViewController:
                    self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().What_Is_A_Worthwhile_Trip)
                case is ProductiveRelaxingValuesViewController:
                    self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().What_Is_A_Worthwhile_Trip)
                case is GDPRAcceptanceViewController:
                    self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().Data_Protection)
                case is OnboardingPermissionsViewController:
                    self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().Permissions)
                case is OnboardingWhatsYourNameViewController:
                    self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().A_Little_About_You)
                case is WhereDoYouLiveOnboardViewController:
                    self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().A_Little_About_You)
                case is WhereDoYouLiveOtherViewController:
                    self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().A_Little_About_You)
                case is ChooseCampaignViewController:
                    self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().A_Little_About_You)
                case is ChooseYourAgeViewController:
                    self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().A_Little_About_You)
                case is ChooseGenderViewController:
                    self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().A_Little_About_You)
                case is ChooseDegreeViewController:
                    self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().A_Little_About_You)
                case is ProdMindBodyScreensViewController:
                    self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().What_Is_A_Worthwhile_Trip)
                default:
                    break
                }
            }
        }
    }
    
    @objc func changeToFirstPage(){
        let firstOnBoardingViewController = storyboard?.instantiateViewController(withIdentifier: "FirstOnBoardingViewController") as! FirstOnBoardingViewController
//        if self.defaultViewControler != nil {
//            backControllers.append(self.defaultViewControler!)
//        }
        self.changeContainedView(newViewController: firstOnBoardingViewController)
        self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().What_Is_A_Worthwhile_Trip)
    }
    
    @objc func changeToSecondPage(){
        let secondOnBoardingViewController = storyboard?.instantiateViewController(withIdentifier: "SecondOnBoardingViewController") as! SecondOnBoardingViewController
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: secondOnBoardingViewController)
        self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().What_Is_A_Worthwhile_Trip)
    }
    
    @objc func changeToMeasureWorthwileness(){
        let measureWorthwilenessOnboardingViewController = storyboard?.instantiateViewController(withIdentifier: "MeasureWorthwilenessOnboardingViewController") as! MeasureWorthwilenessOnboardingViewController
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: measureWorthwilenessOnboardingViewController)
        self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().What_Is_A_Worthwhile_Trip)
    }
    
    @objc func changeToRegularModesOfTRansport(){
        let regularModesOfTRansportOnboardingViewController = storyboard?.instantiateViewController(withIdentifier: "RegularModesOfTRansportOnboardingViewController") as! RegularModesOfTRansportOnboardingViewController
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: regularModesOfTRansportOnboardingViewController)
        self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().What_Is_A_Worthwhile_Trip)
    }
    
    @objc func changeToproductiveRelaxingValues(){
        let productiveRelaxingValuesViewController = storyboard?.instantiateViewController(withIdentifier: "ProductiveRelaxingValuesViewController") as! ProductiveRelaxingValuesViewController
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: productiveRelaxingValuesViewController)
        self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().What_Is_A_Worthwhile_Trip)
    }
    
    @objc func changeTogDPRAcceptance(){
        let gDPRAcceptanceViewController = storyboard?.instantiateViewController(withIdentifier: "GDPRAcceptanceViewController") as! GDPRAcceptanceViewController
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: gDPRAcceptanceViewController)
        self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().Data_Protection)
    }
    
    @objc func changeTogPermissions(){
        let onboardingPermissionsViewController = storyboard?.instantiateViewController(withIdentifier: "OnboardingPermissionsViewController") as! OnboardingPermissionsViewController
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: onboardingPermissionsViewController)
        self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().Permissions)
    }
    
    @objc func changeTogWYName(){
        let onboardingPermissionsViewController = storyboard?.instantiateViewController(withIdentifier: "OnboardingWhatsYourNameViewController") as! OnboardingWhatsYourNameViewController
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: onboardingPermissionsViewController)
        self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().A_Little_About_You)
    }
    
    
    @objc func changeToCountryCity(){
        let whereDoYouLiveOnboardViewController = storyboard?.instantiateViewController(withIdentifier: "WhereDoYouLiveOnboardViewController") as! WhereDoYouLiveOnboardViewController
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: whereDoYouLiveOnboardViewController)
        self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().A_Little_About_You)
    }
    
    @objc func changeToCountryCityOther(){
        let whereDoYouLiveOtherViewController = storyboard?.instantiateViewController(withIdentifier: "WhereDoYouLiveOtherViewController") as! WhereDoYouLiveOtherViewController
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: whereDoYouLiveOtherViewController)
        self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().A_Little_About_You)
    }
    
    @objc func changeToCampaigns(){
        let chooseCampaignViewController = storyboard?.instantiateViewController(withIdentifier: "ChooseCampaignViewController") as! ChooseCampaignViewController
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: chooseCampaignViewController)
        self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().A_Little_About_You)
    }
    
    @objc func changeToAge(){
        DispatchQueue.main.sync{
            let chooseYourAgeViewController = storyboard?.instantiateViewController(withIdentifier: "ChooseYourAgeViewController") as! ChooseYourAgeViewController
            if self.defaultViewControler != nil {
                backControllers.append(self.defaultViewControler!)
            }
            self.changeContainedView(newViewController: chooseYourAgeViewController)
            self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().A_Little_About_You)
        }
    }
    
    @objc func changeToGender(){
        let ChooseGenderViewController = storyboard?.instantiateViewController(withIdentifier: "ChooseGenderViewController") as! ChooseGenderViewController
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: ChooseGenderViewController)
        self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().A_Little_About_You)
    }
    
    @objc func changeToDegree(){
        let chooseDegreeViewController = storyboard?.instantiateViewController(withIdentifier: "ChooseDegreeViewController") as! ChooseDegreeViewController
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: chooseDegreeViewController)
        self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().A_Little_About_You)
    }
    
    @objc func changeToPMB(){
        let chooseDegreeViewController = storyboard?.instantiateViewController(withIdentifier: "ProdMindBodyScreensViewController") as! ProdMindBodyScreensViewController
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: chooseDegreeViewController)
        self.topViewControler?.load(option: self.option, title: MotivStringsGen.getInstance().What_Is_A_Worthwhile_Trip)
    }
    
    @objc func changeToMainmenu(){
//        self.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "GoToMainMenu", sender: nil)
    }
    
    //Changing view
    private func changeContainedView(newViewController: GenericViewController){
        if self.defaultViewControler != nil {
//            self.defaultViewControler!.view.isHidden = true
            self.remove(asChildViewController: self.defaultViewControler!)
        }
        self.defaultViewControler = newViewController
//        self.defaultViewControler!.view.isHidden = true
        self.add(asChildViewController: newViewController)
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        if Thread.isMainThread {
            // Add Child View Controller
            addChildViewController(viewController)
            
            // Add Child View as Subview
            self.contentPage.addSubview(viewController.view)
            
            // Configure Child View
            viewController.view.frame = self.contentPage.bounds
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            // Notify Child View Controller
            viewController.didMove(toParentViewController: self)
        } else {
            DispatchQueue.main.async {
                self.add(asChildViewController:  viewController)
            }
        }
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        if Thread.isMainThread {
            // Notify Child View Controller
            viewController.willMove(toParentViewController: nil)
            
            // Remove Child View From Superview
            viewController.view.removeFromSuperview()
            
            // Notify Child View Controller
            viewController.removeFromParentViewController()
        } else {
            DispatchQueue.main.async {
                self.remove(asChildViewController:  viewController)
            }
        }
    }
}
