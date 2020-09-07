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
 * Profile&Settings controller with specific settings options
 */
class ProfileAndSettingsContentMainViewController: UIViewController {

    @IBOutlet weak var contentPage: UIView!
    var defaultViewControler: GenericViewController?
    var topViewControler: ProfileAndSettingsTopViewController?
    var backControllers = [GenericViewController]()
    var option = Option.SetHomeAndWorkPlace
    var hasLoadedMain = false
    
    enum ProfileViews: String {
        case ProfileBack
        case profileBackToFirst
        case ProfileSetHome
        case ProfileSetWork
        case profileGenralInfo
        
        case profileChangeAValueForDemopgraphicInfo
        case profileChangeAValueForAge
        case profileChangeAValueForGender
        case profileChangeAValueForCountry
        case profileChangeAValueForCity
        case profileChangeAValueForOtherCountry
        
        case profileChangeAValueForHouseholdData
        case profileChangeAValueForHouseholdMarital
        case profileChangeAValueForHouseholdNumPersons
        case profileChangeAValueForHouseholdYearsResidence
        case profileChangeAValueForHouseholdLabour
        
        case profileChangeAValueForMobilityData
        case profileChangeAValueForCarOwner
        case profileChangeAValueForMotorBikeOwner
        case profileChangeAValueForSubscriptionPublicTransport
        case profileChangeAValueForSubscriptionCarSharing
        case profileChangeAValueForSubscriptionBikeSharing
        
        case profileWorthwhileTutorialFirst
        case profileWorthwhileTutorialSecond
        case profileWorthwhileTutorialPMB
        case profileWorthwhileMotList
        
        case profileCampaignScores
        case profileCampaignRewards
    }
    
    enum Option {
        case EditProfile
        case SetHomeAndWorkPlace
        case DemographicInfo
        case WorthwhilenessSettings
        case Tutorials
        case TransportPreferences
        case AppPermissions
        case AppLanguage
        case CampaignOptions
        case CampaignScores
        case ChangePassword
        case Feedback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = MotivColors.WoortiOrange
        
        NotificationCenter.default.addObserver(self, selector: #selector(changesToFirst), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileBackToFirst.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToBack), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.ProfileBack.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToSetHome), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.ProfileSetHome.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToSetWork), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.ProfileSetWork.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToGeneralInfo), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileGenralInfo.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToWorthwhileTutFirstPage), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileWorthwhileTutorialFirst.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToWorthwhileTutSecondPage), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileWorthwhileTutorialSecond.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToWorthwhileTutPMB), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileWorthwhileTutorialPMB.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToWorthwhileMOT), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileWorthwhileMotList.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToHouseholdData), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForHouseholdData.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToChangeAValueForDemographicInfo), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForDemopgraphicInfo.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToChangeAValueForAge), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForAge.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToChangeAValueForGender), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForGender.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToChangeAValueForCountry), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForCountry.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToChangeAValueForCity), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForCity.rawValue), object: nil)
        
        
        //Other country
         NotificationCenter.default.addObserver(self, selector: #selector(changeToChangeAValueForOtherCountry), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForOtherCountry.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToChangeAValueForMaritalStatus), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForHouseholdMarital.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToChangeAValueForNumberPersons), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForHouseholdNumPersons.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToChangeAValueForYearsResidence), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForHouseholdYearsResidence.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToChangeAValueForLabour), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForHouseholdLabour.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(goToCampaignScores), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileCampaignScores.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(goToCampaignRewards), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileCampaignRewards.rawValue), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToChangeAValueForMobilityData), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForMobilityData.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToChangeAValueForCarOwner), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForCarOwner.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToChangeAValueForMotorbikeOwner), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForMotorBikeOwner.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToChangeAValueForSubscriptionPubTrans), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForSubscriptionPublicTransport.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToChangeAValueForSubscriptionCarSharing), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForSubscriptionCarSharing.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToChangeAValueForSubscriptionBikeSharing), name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForSubscriptionBikeSharing.rawValue), object: nil)
        
        ChangeToSelectedMainView()
        hasLoadedMain = true
        // Do any additional setup after loading the view.
    }
    
    fileprivate func ChangeToSelectedMainView() {
        switch self.option {
        case .EditProfile:
            changeToEditProfile()
            break
        case .SetHomeAndWorkPlace:
            changeTohomeAndWork()
            break
        case .DemographicInfo:
            changeToDemInfo()
            break
        case .Tutorials:
            changeToTuts()
            break
        case .WorthwhilenessSettings:
            changeToWorthwhileSettings()
            break
        case .AppLanguage:
            changeToAppLanguage()
        case .CampaignOptions:
            changeToCampaignOptions()
        case .TransportPreferences:
            changeToRegularTransportMode()
        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setOptionToShow(option: Option) {
        self.option = option
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
        case let vc as GenericViewController:
            self.defaultViewControler = vc
            if hasLoadedMain {
                ChangeToSelectedMainView()
            }
        case let topMenu as ProfileAndSettingsTopViewController:
            self.topViewControler = topMenu
        default:
            break
        }
    }
    
    @objc func changesToFirst(){
        while(backControllers.count > 0) {
            changeToBack()
        }
    }
    
    @objc func changeToBack(){
        if backControllers.count == 0 {
            self.dismiss(animated: true, completion: nil)
        } else {
            let prevVC = backControllers.removeLast()
            self.changeContainedView(newViewController: prevVC)
        }
    }
    
    //start: change to main views
    @objc func changeToEditProfile() {
        let editProfile = storyboard?.instantiateViewController(withIdentifier: "ProfileEditUserViewController") as! ProfileEditUserViewController
        self.changeContainedView(newViewController: editProfile)
        self.topViewControler?.changeTitle(text: NSLocalizedString("Edit_Profile", comment: "Message: Edit Profile"))
    }
    
    @objc func changeTohomeAndWork() {
        let HomeAndWork = storyboard?.instantiateViewController(withIdentifier: "SetHomeAndWorkViewController") as! SetHomeAndWorkViewController
        self.changeContainedView(newViewController: HomeAndWork)
        self.topViewControler?.changeTitle(text: NSLocalizedString("Set_Home_And_Work", comment: "Message: Set home and work"))
    }
    
    
    
    @objc func changeToDemInfo() {
        let DemInfo = storyboard?.instantiateViewController(withIdentifier: "DemographicInformationViewController") as! DemographicInformationViewController
        self.changeContainedView(newViewController: DemInfo)
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Info", comment: "Message: Demographic info"))
    }
    
    @objc func changeToHouseholdData() {
        let DemInfo = storyboard?.instantiateViewController(withIdentifier: "HouseHoldGenericDataViewController") as! HouseHoldGenericDataViewController
        self.changeContainedView(newViewController: DemInfo)
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Info", comment: "Message: Demographic info"))
    }
    
    @objc func changeToChangeAValueForMobilityData() {
        let DemInfo = storyboard?.instantiateViewController(withIdentifier: "HouseHoldGenericDataViewController") as! HouseHoldGenericDataViewController
        self.changeContainedView(newViewController: DemInfo)
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Info", comment: "Message: Demographic info"))
        DemInfo.DataContent = MobilityData()
    }
    
    @objc func changeToTuts() {
        let Tuts = storyboard?.instantiateViewController(withIdentifier: "ViewTutorialListViewController") as! ViewTutorialListViewController
        self.changeContainedView(newViewController: Tuts)
        self.topViewControler?.changeTitle(text: NSLocalizedString("Tutorials", comment: "Message: Tutorials"))
    }
    
    @objc func changeToWorthwhileSettings() {
        let worthwhile = storyboard?.instantiateViewController(withIdentifier: "WorthwhilenessSettingsViewController") as! WorthwhilenessSettingsViewController
        self.changeContainedView(newViewController: worthwhile)
        self.topViewControler?.changeTitle(text: NSLocalizedString("Worthwhileness_Settings", comment: "Message: Worthwhileness settings"))
    }
    
    
    
    @objc func changeToAppLanguage() {
        let Language = storyboard?.instantiateViewController(withIdentifier: "ProfileAppLanguageViewController") as! ProfileAppLanguageViewController
        self.changeContainedView(newViewController: Language)
        self.topViewControler?.changeTitle(text: NSLocalizedString("App_Language", comment: "Message: App language"))
    }
    
    @objc func changeToCampaignOptions() {
        let campaignOptions = storyboard?.instantiateViewController(withIdentifier: "CampaignOptionsViewController") as! CampaignOptionsViewController
        self.changeContainedView(newViewController: campaignOptions)
        self.topViewControler?.changeTitle(text: NSLocalizedString("Campaigns", comment: "Message: Campaign Scores"))
    }
    
    @objc func changeToRegularTransportMode() {
        let regularMot = storyboard?.instantiateViewController(withIdentifier: "RegularModesOfTRansportOnboardingViewControllerProf") as! RegularModesOfTRansportOnboardingViewController
        regularMot.fromOnboarding = false
        self.changeContainedView(newViewController: regularMot)
        self.topViewControler?.changeTitle(text: NSLocalizedString("Transport_Preferences", comment: "Message: TransportPreferences"))
    }
    
    //end: change to main views
    
    //start: change to secondary views
    
    @objc func goToCampaignScores() {
        let campaignScores = storyboard?.instantiateViewController(withIdentifier: "CampaignScoreViewController") as! CampaignScoreViewController
        self.changeContainedView(newViewController: campaignScores)
        self.topViewControler?.changeTitle(text: NSLocalizedString("Campaign_Scores", comment: ""))
       
    }
    
    @objc func goToCampaignRewards() {
        let campaignRewards = storyboard?.instantiateViewController(withIdentifier: "CampaignRewardsViewController") as! CampaignRewardsViewController
        self.changeContainedView(newViewController: campaignRewards)
        self.topViewControler?.changeTitle(text: NSLocalizedString("Rewards", comment: ""))
        
    }
    
    @objc func changeToSetHome(){
        let Home = storyboard?.instantiateViewController(withIdentifier: "SetHomeOrWorkViewController") as! SetHomeOrWorkViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Set_Home", comment: "Message: Set home"))
        Home.loadView(option: SetHomeOrWorkViewController.option.Home)
        
        changeToGenericVc(gvc: Home)
    }
    
    @objc func changeToSetWork(){
        let Work = storyboard?.instantiateViewController(withIdentifier: "SetHomeOrWorkViewController") as! SetHomeOrWorkViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Set_Work", comment: "Message: Set work"))
        Work.loadView(option: SetHomeOrWorkViewController.option.Work)
        
        changeToGenericVc(gvc: Work)
    }
    
    @objc func changeToGeneralInfo(){
        let Work = storyboard?.instantiateViewController(withIdentifier: "GeneralInfoViewController") as! GeneralInfoViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Option_General", comment: "Message: general"))
        
        changeToGenericVc(gvc: Work)
    }
    
    @objc func changeToChangeAValueForDemographicInfo() {
        let DemInfo = storyboard?.instantiateViewController(withIdentifier: "ChangeGeneralValueViewController") as! ChangeGeneralValueViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Info", comment: "Message: Demographic info"))
        
        changeToGenericVc(gvc: DemInfo)
        DemInfo.reloadTitle()
    }
    
    @objc func changeToChangeAValueForAge() {
        let DemInfo = storyboard?.instantiateViewController(withIdentifier: "ChangeGeneralValueViewController") as! ChangeGeneralValueViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Info", comment: "Message: Demographic info"))
        DemInfo.valuesToPrint = valueForAgeBackgrounds()
        changeToGenericVc(gvc: DemInfo)
        DemInfo.reloadTitle()
    }
    
    @objc func changeToChangeAValueForMaritalStatus() {
        let DemInfo = storyboard?.instantiateViewController(withIdentifier: "ChangeGeneralValueViewController") as! ChangeGeneralValueViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Info", comment: "Message: Demographic info"))
        DemInfo.valuesToPrint = MaritalStatusHouseHoldInfo()
        changeToGenericVc(gvc: DemInfo)
        DemInfo.reloadTitle()
    }
    
    @objc func changeToChangeAValueForNumberPersons() {
        let DemInfo = storyboard?.instantiateViewController(withIdentifier: "ChangeGeneralValueViewController") as! ChangeGeneralValueViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Info", comment: "Message: Demographic info"))
        DemInfo.valuesToPrint = NumberPersonsHouseHoldInfo()
        changeToGenericVc(gvc: DemInfo)
        DemInfo.reloadTitle()
    }
    
    @objc func changeToChangeAValueForYearsResidence() {
        let DemInfo = storyboard?.instantiateViewController(withIdentifier: "ChangeGeneralValueViewController") as! ChangeGeneralValueViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Info", comment: "Message: Demographic info"))
        DemInfo.valuesToPrint = YearsResidenceHouseHoldInfo()
        changeToGenericVc(gvc: DemInfo)
        DemInfo.reloadTitle()
    }
    
    @objc func changeToChangeAValueForLabour() {
        let DemInfo = storyboard?.instantiateViewController(withIdentifier: "ChangeGeneralValueViewController") as! ChangeGeneralValueViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Info", comment: "Message: Demographic info"))
        DemInfo.valuesToPrint = LabourHouseHoldInfo()
        changeToGenericVc(gvc: DemInfo)
        DemInfo.reloadTitle()
    }
    
    @objc func changeToChangeAValueForGender() {
        let DemInfo = storyboard?.instantiateViewController(withIdentifier: "ChangeGeneralValueViewController") as! ChangeGeneralValueViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Info", comment: "Message: Demographic info"))
        DemInfo.valuesToPrint = valueForGenderBackgrounds()
        changeToGenericVc(gvc: DemInfo)
        DemInfo.reloadTitle()
    }
    
    @objc func changeToChangeAValueForCountry() {
        let DemInfo = storyboard?.instantiateViewController(withIdentifier: "ChangeGeneralValueViewController") as! ChangeGeneralValueViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Info", comment: "Message: Demographic info"))
        DemInfo.valuesToPrint = valueForCountryBackgrounds()
        changeToGenericVc(gvc: DemInfo)
        DemInfo.reloadTitle()
    }
    
    @objc func changeToChangeAValueForOtherCountry() {
        let DemInfo = storyboard?.instantiateViewController(withIdentifier: "ChangeGeneralValueViewController") as! ChangeGeneralValueViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Info", comment: "Message: Demographic info"))
        DemInfo.valuesToPrint = valueForOtherCountryBackgrounds()
        changeToGenericVc(gvc: DemInfo)
        DemInfo.reloadTitle()
    }
    
    @objc func changeToChangeAValueForCity() {
        let DemInfo = storyboard?.instantiateViewController(withIdentifier: "ChangeGeneralValueViewController") as! ChangeGeneralValueViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Info", comment: "Message: Demographic info"))
        DemInfo.valuesToPrint = valueForCityBackgrounds()
        changeToGenericVc(gvc: DemInfo)
        DemInfo.reloadTitle()
    }
    
    //
    @objc func changeToChangeAValueForCarOwner() {
        let DemInfo = storyboard?.instantiateViewController(withIdentifier: "ChangeGeneralValueViewController") as! ChangeGeneralValueViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Info", comment: "Message: Demographic info"))
        DemInfo.valuesToPrint = CarOwnerYesNoInfo()
        changeToGenericVc(gvc: DemInfo)
        DemInfo.reloadTitle()
    }
    
    @objc func changeToChangeAValueForMotorbikeOwner() {
        let DemInfo = storyboard?.instantiateViewController(withIdentifier: "ChangeGeneralValueViewController") as! ChangeGeneralValueViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Info", comment: "Message: Demographic info"))
        DemInfo.valuesToPrint = MotorbikeOwnerYesNoInfo()
        changeToGenericVc(gvc: DemInfo)
        DemInfo.reloadTitle()
    }
    
    @objc func changeToChangeAValueForSubscriptionPubTrans() {
        let DemInfo = storyboard?.instantiateViewController(withIdentifier: "ChangeGeneralValueViewController") as! ChangeGeneralValueViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Info", comment: "Message: Demographic info"))
        DemInfo.valuesToPrint = SubsPubTransYesNoInfo()
        changeToGenericVc(gvc: DemInfo)
        DemInfo.reloadTitle()
    }
    
    @objc func changeToChangeAValueForSubscriptionCarSharing() {
        let DemInfo = storyboard?.instantiateViewController(withIdentifier: "ChangeGeneralValueViewController") as! ChangeGeneralValueViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Info", comment: "Message: Demographic info"))
        DemInfo.valuesToPrint = SubsCarSharingYesNoInfo()
        changeToGenericVc(gvc: DemInfo)
        DemInfo.reloadTitle()
    }
    
    @objc func changeToChangeAValueForSubscriptionBikeSharing() {
        let DemInfo = storyboard?.instantiateViewController(withIdentifier: "ChangeGeneralValueViewController") as! ChangeGeneralValueViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Demographic_Info", comment: "Message: Demographic info"))
        DemInfo.valuesToPrint = SubsBikeSharingYesNoInfo()
        changeToGenericVc(gvc: DemInfo)
        DemInfo.reloadTitle()
    }
    
    //
    @objc func changeToWorthwhileTutFirstPage(){
        let TutWorthwhileTrip = storyboard?.instantiateViewController(withIdentifier: "WorthwhilenessTutorialFirstScreenViewController") as! WorthwhilenessTutorialFirstScreenViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("What_Is_A_Worthwhile_Trip", comment: "Message: What is a worthwhile trip"))
        
        changeToGenericVc(gvc: TutWorthwhileTrip)
    }
    
    @objc func changeToWorthwhileTutSecondPage(){
        let TutWorthwhileTrip = storyboard?.instantiateViewController(withIdentifier: "WorthwhilenessTutorialSecondScreenViewControllerViewController") as! WorthwhilenessTutorialSecondScreenViewControllerViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("What_Is_A_Worthwhile_Trip", comment: "Message: What is a worthwhile trip"))
        
        changeToGenericVc(gvc: TutWorthwhileTrip)
    }
    
    @objc func changeToWorthwhileTutPMB(){
        let TutWorthwhileTrip = storyboard?.instantiateViewController(withIdentifier: "WorthwhileTutorialPMBViewController") as! WorthwhileTutorialPMBViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("What_Is_A_Worthwhile_Trip", comment: "Message: What is a worthwhile trip"))
        
        changeToGenericVc(gvc: TutWorthwhileTrip)
    }
    
    @objc func changeToWorthwhileMOT(){
        let WorthwhileMot = storyboard?.instantiateViewController(withIdentifier: "ProductiveRelaxingValuesViewControllerProf") as! ProductiveRelaxingValuesViewController
        self.topViewControler?.changeTitle(text: NSLocalizedString("Worthwhileness_Settings", comment: "Message: Worthwhileness settings"))
        WorthwhileMot.fromOnboarding = false
        changeToGenericVc(gvc: WorthwhileMot)
    }
    
    func changeToGenericVc(gvc: GenericViewController){
        if self.defaultViewControler != nil {
            backControllers.append(self.defaultViewControler!)
        }
        self.changeContainedView(newViewController: gvc)
    }
    
    //end: change to secondary views
    
    // start: auxiliary change content functions
    private func changeContainedView(newViewController: GenericViewController){
        if self.defaultViewControler != nil {
            self.remove(asChildViewController: self.defaultViewControler!)
        }
        self.defaultViewControler = newViewController
        self.add(asChildViewController: newViewController)
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
    // end: auxiliary change content functions

}
