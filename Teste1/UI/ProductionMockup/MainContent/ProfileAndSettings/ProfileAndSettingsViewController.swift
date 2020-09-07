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
 * Parent Controller in Profile&Settings.
 * Shows options and redirects to specific pages.
 */
class ProfileAndSettingsViewController: GenericViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var sectionsTableView: UITableView!
    @IBOutlet weak var nameEmailView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var topEditImage: UIImageView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var VersionNumber: UILabel!
    @IBOutlet weak var woortiLabel: UILabel!
    
    let items = ProfileAndSettingsMenuItems.getProfileItems()
    let itemSize = CGFloat(50)
    
    var option = ProfileAndSettingsContentMainViewController.Option.EditProfile
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        self.sectionsTableView.delegate=self
        self.sectionsTableView.dataSource=self
        
        makeViewRound(view: nameEmailView)
        MotivAuxiliaryFunctions.ShadowOnView(view: nameEmailView)
        makeViewRound(view: sectionsTableView)
        MotivAuxiliaryFunctions.ShadowOnView(view: sectionsTableView)
        
        loadTopView()
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(editUser))
        self.topEditImage.addGestureRecognizer(gr)
        
        MotivFont.motivRegularFontFor(text: "Version 2.0.11", label: self.VersionNumber, size: 10)
        MotivFont.motivRegularFontFor(text: "woorti", label: self.woortiLabel, size: 16)
        
        self.woortiLabel.textColor = MotivColors.WoortiOrange
        self.VersionNumber.textColor = MotivColors.WoortiOrange
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // HACK TO JUMP TO DEMOGRAPHIC INFO (From Fill Profile Popup)
        if option == ProfileAndSettingsContentMainViewController.Option.DemographicInfo {
            goToSelectedScreen(option: self.option)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.option = ProfileAndSettingsContentMainViewController.Option.EditProfile
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.backgroundColor = MotivColors.WoortiOrangeT3
        self.topEditImage.image = self.topEditImage.image?.withRenderingMode(.alwaysTemplate)
        self.topEditImage.tintColor = MotivColors.WoortiOrange
    }
    
    func loadTopView() {
        if let user = MotivUser.getInstance() {
            MotivFont.motivRegularFontFor(text: user.email, label: self.emailLabel, size: 12)
            MotivFont.motivRegularFontFor(text: user.name, label: self.nameLabel, size: 15)
            self.nameLabel.textColor = MotivColors.WoortiOrange
        }
    }
    
    
    func makeViewRound(view :UIView){
        view.layer.masksToBounds = true
        view.layer.cornerRadius = view.bounds.width * 0.05
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableViewHeight.constant = itemSize * CGFloat(items.count)
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileMenuTableViewCell") as! ProfileMenuTableViewCell
        cell.loadCell(item: self.items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemSize
    }
    
    func goToSelectedScreen(option: ProfileAndSettingsContentMainViewController.Option){
        self.option = option
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "ProfileAndSettingsContentMainViewControllerSegue", sender: nil)
        }
        
    }
    
    @objc func editUser(){
        self.goToSelectedScreen(option: ProfileAndSettingsContentMainViewController.Option.EditProfile)
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.goToSelectedScreen(option: ProfileAndSettingsContentMainViewController.Option.SetHomeAndWorkPlace)
            break
            //home and work
        case 1:
            self.goToSelectedScreen(option: ProfileAndSettingsContentMainViewController.Option.DemographicInfo)
            break
            //demographic
        case 2:
            self.goToSelectedScreen(option: ProfileAndSettingsContentMainViewController.Option.WorthwhilenessSettings)
            break
            //worthwhileness
        case 3:
            self.goToSelectedScreen(option: ProfileAndSettingsContentMainViewController.Option.Tutorials)
            break
            //Tutorials
        case 4:
            self.goToSelectedScreen(option: ProfileAndSettingsContentMainViewController.Option.TransportPreferences)
            break
            //transport preferences
        case 5:
            self.goToSelectedScreen(option: ProfileAndSettingsContentMainViewController.Option.AppLanguage)
            break
        case 6:
            //campaigns
            self.goToSelectedScreen(option: ProfileAndSettingsContentMainViewController.Option.CampaignOptions)
            break
        case 7:
            //Reporting
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MainViewController.MainViewOptions.GoToReporting.rawValue), object: nil)
            break
        case 8:
            //Read Me
            loadReadMe()
            break
        case 9:
            //LogOut
            MotivUser.getInstance()?.signOut(view: self)
            break
        default:
            break
        }
    }

    func loadReadMe() {
        let site = NSLocalizedString("Url_Privacy_Policy", comment: "") //"https://motivproject.eu/data-collection/data-protection.html"
//        let site = "https://app.motiv.gsd.inesc-id.pt/privacyPolicy"
        guard let url = URL(string: site) else {
            return
        }
        UIApplication.shared.open(url, options: [String : Any](), completionHandler: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("Prepare SEGUE")
        switch segue.destination {
        case let contentPage as ProfileAndSettingsContentMainViewController:
            
            print("DO SEGUE")
            contentPage.setOptionToShow(option: self.option)
        default:
             print("DEFAULT SEGUE")
            break
        }
    }
}

class ProfileAndSettingsMenuItems {
    let text: String
    let image: images
    
    enum images: String {
        case arrow_forward_ios_white
        case error_black
    }
    
    init(text: String, image: images = images.arrow_forward_ios_white) {
        self.text = text
        self.image = image
    }
    
    static func getProfileItems() -> [ProfileAndSettingsMenuItems] {
        var pi = [ProfileAndSettingsMenuItems]()
        pi.append(ProfileAndSettingsMenuItems(text: NSLocalizedString("Set_Home_And_Work", comment: "message: Set Home and work places")))
        pi.append(ProfileAndSettingsMenuItems(text: NSLocalizedString("Demographic_Info", comment: "message: Demographic information")))
        pi.append(ProfileAndSettingsMenuItems(text: NSLocalizedString("Worthwhileness_Settings", comment: "message: Worthwhile settings")))
        pi.append(ProfileAndSettingsMenuItems(text: NSLocalizedString("Tutorials", comment: "message: Tutorials")))
        pi.append(ProfileAndSettingsMenuItems(text: NSLocalizedString("Transport_Preferences", comment: "message: Transport preferences")))
        pi.append(ProfileAndSettingsMenuItems(text: NSLocalizedString("App_Language", comment: "message: App language")))
        pi.append(ProfileAndSettingsMenuItems(text: NSLocalizedString("Campaigns", comment: "message: Campaign")))
        pi.append(ProfileAndSettingsMenuItems(text: NSLocalizedString("Feedback", comment: "message: Feedback")))
        pi.append(ProfileAndSettingsMenuItems(text: NSLocalizedString("Privacy_Policy", comment: "message: privacy policy")))
        pi.append(ProfileAndSettingsMenuItems(text: NSLocalizedString("Log_Out", comment: "message: Log out")))
        return pi
    }
    
    static func getHomeAndWorkItems() -> [ProfileAndSettingsMenuItems] {
        var pi = [ProfileAndSettingsMenuItems]()
        pi.append(ProfileAndSettingsMenuItems(text: NSLocalizedString("Home", comment: "message: Home")))
        pi.append(ProfileAndSettingsMenuItems(text: NSLocalizedString("Work", comment: "message: Work")))
        return pi
    }
    
    static func getDemInfoItems() -> [ProfileAndSettingsMenuItems] {
        var pi = [ProfileAndSettingsMenuItems]()
        pi.append(ProfileAndSettingsMenuItems(text: NSLocalizedString("Demographic_Option_General", comment: "message: General")))
        pi.append(ProfileAndSettingsMenuItems(text: NSLocalizedString("Household_Data", comment: "")))
        return pi
    }
    
    static func getCampaignOptionItems() -> [ProfileAndSettingsMenuItems] {
        var pi = [ProfileAndSettingsMenuItems]()
        pi.append(ProfileAndSettingsMenuItems(text: NSLocalizedString("Campaign_Scores", comment: "")))
        pi.append(ProfileAndSettingsMenuItems(text: NSLocalizedString("Rewards", comment: "")))
        
        
        return pi
    }
    
    static func getTutsItems() -> [ProfileAndSettingsMenuItems] {
        var pi = [ProfileAndSettingsMenuItems]()
        pi.append(ProfileAndSettingsMenuItems(text: NSLocalizedString("Tutorial_Option_What_Is_Worthwhileness", comment: "message: What is worthwhileness")))
        pi.append(ProfileAndSettingsMenuItems(text: NSLocalizedString("Report_Trips_Tutorial", comment: "message: ")))
        return pi
    }
}
