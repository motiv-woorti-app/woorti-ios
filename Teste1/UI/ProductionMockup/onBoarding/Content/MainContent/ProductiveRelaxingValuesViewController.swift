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
import Firebase

/*
 * After choosing the most regular modes, the user is required to select a productivity, relaxing and fitness value to each mode.
 * View is reused in Profile & Settings to update information. 
 */
class ProductiveRelaxingValuesViewController: GenericViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var NotSomethingLabel: UILabel!
    @IBOutlet weak var SomethingLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    
    @IBOutlet weak var contentPage: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var TableView: UITableView!
    var productive = true
    var type = typeOfScreen.prod
    
    
    enum typeOfScreen {
        case prod, enj, fit
    }
    
    var cells = [ProductiveRelaxingValuesTableViewCell]()
    
    var array = [MotSettings]()
    var fromOnboarding = true
    var hasRegistered = false
    var handle: AuthStateDidChangeListenerHandle?
    
    func prodText() {
        MotivFont.motivRegularFontFor(key: "Not_Productive", comment: "rating prefered modes of transport message: Not Productive", label: self.NotSomethingLabel, size: 9)
        MotivFont.motivRegularFontFor(key: "Productive", comment: "rating prefered modes of transport message: Productive", label: self.SomethingLabel, size: 9)
        MotivFont.motivBoldFontFor(key: "Rating_Prefered_Mot_Prod_Title", comment: "message: How productive are you when you travel by:", label: self.titleLabel, size: 15)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.titleLabel, color: MotivColors.WoortiGreen)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        TableView.delegate = self
        TableView.dataSource = self
        MotivAuxiliaryFunctions.loadStandardButton(button: self.nextButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Next" , comment: "message text of \"Next\" button message: Next", boldText: true, size: 17, disabled: false, CompleteRoundCorners: true)
        
        prodText()
        
        if let mots = MotivUser.getInstance()?.preferedMots.allObjects as? [MotSettings] {
            array.append(contentsOf: mots)
        } else {
            array.append(contentsOf: MotivUser.tmpPreferedMots)
        }
        
        MotivAuxiliaryFunctions.RoundView(view: contentPage)
//        self.view.backgroundColor = MotivColors.WoortiOrange
        if fromOnboarding {
            self.view.backgroundColor = UIColor.clear
        } else {
            self.view.backgroundColor = MotivColors.WoortiOrangeT3
        }
        
        self.titleLabel.textColor = MotivColors.WoortiOrange
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.titleLabel, color: MotivColors.WoortiOrange)
        MotivAuxiliaryFunctions.ShadowOnView(view: self.titleView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.gotoNextIfRegistered()
        }
    }
    
    func gotoNextIfRegistered() {
        if hasRegistered,
            Auth.auth().currentUser != nil {
            goToNextOnboardingScreen()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductiveRelaxingValuesTableViewCell") as! ProductiveRelaxingValuesTableViewCell
        
        let motSelected = array[indexPath.row]
        let index = MOTRegularityData.getInstance().findIndex(text: motSelected.motText)
        var image = ""
        if index == -1 {
            image = MOTRegularityData.getInstance().mots.first?.last?.1 ?? ""
        } else {
            image = MOTRegularityData.getInstance().motsSingleList[index].1
        }
        
        cell.LoadView(image: image, settings: motSelected)
        
        if cells.count > indexPath.row {
            cells[indexPath.row] = cell
        } else {
            cells.append(cell)
        }
        
        return cell
    }
    
    func goToNextOnboardingScreen() {
        if fromOnboarding {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:OnboardingTopAndContentViewController.OboardViews.OBVGOTOchangeToGDPR.rawValue), object: nil)
        }
    }
    
    func enjText() {
        MotivFont.motivBoldFontFor(key: "Rating_Prefered_Mot_Enj_Title", comment: "message: How much enjoyment do you get from your your travel time by:", label: self.titleLabel, size: 15)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.titleLabel, color: MotivColors.WoortiOrange)
        MotivFont.motivRegularFontFor(key: "Not_Enjoying", comment: "rating prefered modes of transport message: Not Enjoying", label: self.NotSomethingLabel, size: 9)
        MotivFont.motivRegularFontFor(key: "Enjoying", comment: "rating prefered modes of transport message: Enjoying", label: self.SomethingLabel, size: 9)
    }
    
    @IBAction func nextClick(_ sender: Any) {
        updateValues()
        if type == .prod {
            enjText()
            type = .enj
            updateSliders()
        } else if type == .enj {
            MotivFont.motivBoldFontFor(key: "Rating_Prefered_Mot_Fit_Title", comment: "message: How does your travel time contribute to your fitness when you travel by:", label: self.titleLabel, size: 15)
            MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.titleLabel, color: MotivColors.WoortiOrange)
            MotivFont.motivRegularFontFor(key: "Doesnt_Improve_My_Fitness", comment: "rating prefered modes of transport message: Improves my fitness", label: self.NotSomethingLabel, size: 9)
            MotivFont.motivRegularFontFor(key: "Improves_My_Fitness", comment: "rating prefered modes of transport message: Doesn't improve my fitness", label: self.SomethingLabel, size: 9)
            type = .fit
            updateSliders()
        } else {
            
            if fromOnboarding {
                if let hasOnboarding = MotivUser.getInstance()?.hasOnboardingInfo {
                   goToNextOnboardingScreen()
                }
                else {
                    self.performSegue(withIdentifier: "RegisterNewUser", sender: nil)
                }
                
            } else {
                self.dismiss(animated: true, completion: nil)
                MotivRequestManager.getInstance().requestSaveUserSettings()
            }
        }
    }
    
    func updateValues(){
        for cell in cells {
            switch type {
            case .prod:
                cell.refreshsettings(productive: true)
                break
            case .fit:
                cell.refreshsettings()
                break
            case .enj:
                cell.refreshsettings(productive: false)
                break
            }
        }
    }
    
    func updateSliders() {
        for cell in cells {
            switch type {
            case .prod:
                cell.refreshSliderValue(productive: true)
                break
            case .fit:
                cell.refreshSliderValue()
                break
            case .enj:
                cell.refreshSliderValue(productive: false)
                break
            }
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         Get the new view controller using segue.destinationViewController.
//         Pass the selected object to the new view controller.
        if let signIn = segue.destination as? WoortiSignInOrRegisterViewController {
            signIn.regsiterNewUser()
            self.hasRegistered = true
        }
    }

}
