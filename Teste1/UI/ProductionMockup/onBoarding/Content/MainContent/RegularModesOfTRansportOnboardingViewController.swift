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
 * Onboarding view to choose the modes of transport regularly used.
 * Divided in sections (Public Transportation, Private Transportation, Active Transportation).
 * View is reused in Profile & Settings to update the information.
 */
class RegularModesOfTRansportOnboardingViewController: GenericViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var motsTableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    var motcells = [[ModeOftransportState]]()
    
    @IBOutlet weak var contentPage: UIView!
    
    @IBOutlet weak var titleView: UIView!
    enum openPopup: String {
        case OpenPublic = "OpenPublicRegularModesOfTRansportOnboardingViewController"
        case OpenActive = "OpenActiveRegularModesOfTRansportOnboardingViewController"
        case OpenPrivate = "OpenPrivateRegularModesOfTRansportOnboardingViewController"
    }
    
    //popover
    var fadeView: UIView?
    @IBOutlet weak var popOver: UIView!
    @IBOutlet weak var popUpTitle: UILabel!
    @IBOutlet weak var popupBackButton: UIImageView!
    @IBOutlet weak var popupTextfield: UITextField!
    @IBOutlet weak var popupSaveButton: UIButton!
    var popupOtherSection = 0
    public var fromOnboarding = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        motsTableView.delegate = self
        motsTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.nextButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Next" , comment: "message text of \"Next\" button message: Next", boldText: true, size: 17, disabled: false, CompleteRoundCorners: true)
        
        MotivFont.motivBoldFontFor(key: "Regualr_Modes_Of_Transport_Title", comment: "message: Which modes of transport do you use regularly?", label: self.titleLabel, size: 17)
        titleLabel.textColor = MotivColors.WoortiOrange
        MotivAuxiliaryFunctions.RoundView(view: contentPage)
        if fromOnboarding {
            self.view.backgroundColor = UIColor.clear
        } else {
            self.view.backgroundColor = MotivColors.WoortiOrangeT3
        }
        
        MOTRegularityData.getInstance().resetValues()
        MotivAuxiliaryFunctions.ShadowOnView(view: self.titleView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openPublicPopup), name: NSNotification.Name(rawValue: openPopup.OpenPublic.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openActivePopup), name: NSNotification.Name(rawValue: openPopup.OpenActive.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openPrivatePopup), name: NSNotification.Name(rawValue: openPopup.OpenPrivate.rawValue), object: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return MOTRegularityData.getInstance().mots.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return mots.count
        if section < MOTRegularityData.getInstance().mots.count {
            return MOTRegularityData.getInstance().mots[section].count
        }
        return 0
    }
    
    fileprivate func getNameForSection(_ section: Int) -> String {
        switch section {
        case 0:
            return MotivStringsGen.getInstance().Public_Transport
        case 1:
            return MotivStringsGen.getInstance().Active_Semi_active
        case 2:
            return MotivStringsGen.getInstance().Private_Motirized
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.sectionHeaderHeight))
        view.backgroundColor = UIColor.white
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: view.bounds.width - 30, height: tableView.sectionHeaderHeight))
        label.center = view.center
        label.textAlignment = .center
        
        label.textColor = UIColor.black
        MotivFont.motivBoldFontFor(text: getNameForSection(section), label: label, size: 15)
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var mot: ModeOftransportState?
        
        if motcells.count > indexPath.section,
            motcells[indexPath.section].count > indexPath.row {
            // if cell already exists
            mot = motcells[indexPath.section][indexPath.row]
        } else {
            if motcells.count <= indexPath.section {
                motcells.append([ModeOftransportState]())
            }
            let info = MOTRegularityData.getInstance().mots[indexPath.section][indexPath.row]
            mot = ModeOftransportState(mot: info)
            
            
            if let user = MotivUser.getInstance() {
                if (user.preferedMots.allObjects as? [MotSettings] ?? [MotSettings]()).contains(where: { (motSettings) -> Bool in motSettings.motText == mot?.mot.0
                }) {
                    // if user contains this mode of transport in the preferences
                    mot?.selected = true
                }
            }
    
            motcells[indexPath.section].append(mot!)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegularMOTSTableViewCell", for: indexPath) as! RegularMOTSTableViewCell
        cell.loadCell(mot: mot!)
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Store the selected transport modes and go to next screen.
     */
    @IBAction func NextClick(_ sender: Any) {
        var noneSelected = true
        if let user = MotivUser.getInstance() {
            user.preferedMots = NSSet(array: [MotSettings]())
            for section in motcells {
                for cell in section {
                    if let mot = cell.getValueIfSelected() {
                        let mots = MOTRegularityData.getInstance().getmotSettingsForRegularityData(text: mot)
                        user.preferedMots = user.preferedMots.adding(mots) as NSSet
                        noneSelected = false
                    }
                }
            }
        } else {
            MotivUser.tmpPreferedMots = [MotSettings]()
            for section in motcells {
                for cell in section {
                    if let mot = cell.getValueIfSelected() {
                        let mots = MOTRegularityData.getInstance().getmotSettingsForRegularityData(text: mot)
                        MotivUser.tmpPreferedMots.append(mots)
                        noneSelected = false
                    }
                }
            }
        }
        
        if noneSelected {
            UiAlerts.getInstance().newView(view: self)
            UiAlerts.getInstance().showNeedOneTransportMsg()
            return
        }
        if self.fromOnboarding {
            NotificationCenter.default.post( name: NSNotification.Name(rawValue: OnboardingTopAndContentViewController.OboardViews.OBVGOTOchangeToPRValues.rawValue), object: nil)
        } else {
            MotivRequestManager.getInstance().requestSaveUserSettings()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func openPublicPopup() {
        self.loadPopupButton(section: 0)
    }
    
    @objc func openActivePopup() {
        self.loadPopupButton(section: 1)
    }
    
    @objc func openPrivatePopup() {
        self.loadPopupButton(section: 2)
    }
    
    
    //popup
    func loadPopupButton(section: Int) {
        self.popupOtherSection = section
        MotivFont.motivBoldFontFor(text: "\(NSLocalizedString("Otehr", comment: "")) \(getNameForSection(section))", label: self.popUpTitle, size: 15)
        self.popUpTitle.textColor = MotivColors.WoortiOrange
        MotivAuxiliaryFunctions.RoundView(view: self.popOver)
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(closePopup))
        self.popupBackButton.addGestureRecognizer(gr)
        self.popupBackButton.image = self.popupBackButton.image?.withRenderingMode(.alwaysTemplate)
        self.popupBackButton.tintColor = MotivColors.WoortiOrange
        
        self.popupTextfield.textColor = MotivColors.WoortiOrange
        self.popupTextfield.backgroundColor = MotivColors.WoortiOrangeT3
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.popupSaveButton, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Save", comment: "", boldText: true, size: 15, disabled: false)
        
        self.popup()
    }
    
    @IBAction func popupSaveClick(_ sender: Any) {
        if let text = self.popupTextfield.text {
            switch popupOtherSection {
            case 0:
                MOTRegularityData.getInstance().otherPublic = text
            case 1:
                MOTRegularityData.getInstance().otherPublic = text
            case 2:
                MOTRegularityData.getInstance().otherPublic = text
            default:
                break
            }
            
            self.closePopup()
        }
    }
    
    @IBAction func PopUpTBEndEditing(_ sender: Any) {
        resignFirstResponder()
        self.popupTextfield.endEditing(true)
    }
    
    @objc func popup(){
        closePopup()
        self.fadeView = UIView(frame: self.view.bounds)
        fadeView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.addSubview(fadeView!)
        fadeView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closePopup)))
        
        let pobounds = popOver.bounds
        popOver.bounds = CGRect(x: pobounds.minX, y: pobounds.minY, width: self.view.bounds.width - 20, height: self.view.bounds.height - 20)
        self.view.addSubview(self.popOver)
        self.popOver.center = self.view.center
    }
    
    @objc func closePopup() {
        self.fadeView?.removeFromSuperview()
        self.popOver?.removeFromSuperview()
    }
}

class MOTRegularityData {
//    let mots = ["Bus/Tram","Metro/Light Rail","Bicycle/Bike Sharing","Walking","Taxi/Uber","Train","Ferry","Motorcycle","Car/Car sharing"]
    var mots = [[(String,String)]]()
    var motsSingleList = [(String,String)]()
    
    var otherPublic = ""
    var otherActivity = ""
    var otherPrivate = ""
//    let motImages = ["directions_bus_black","baseline_subway_black_18dp","directions_bike_black","directions_walk_black","baseline_local_taxi_black_18dp","baseline_train_black_18dp","directions_boat_black","baseline_motorcycle_black_18dp","directions_car_black"]
    
    static var instance: MOTRegularityData? = nil
    
    private init() {
        let publicTransportMots = [
            ("Metro","Icon_Metro"),
            ("Tram","Icon_Tram"),
            ("Bus_Trolley_Bus","Icon_Bus"),
            ("Coach_Long_Distance_Bus","Icon_Coach"),
            ("Urban_Train","Icon_Urban_Train"),
            ("Regional_Intercity_Train","Icon_Regional_Intercity_Train"),
            ("high_speed_train","Icon_High_Speed_Train"),
            ("Ferry_Boat","Icon_Ferry_Boat"),
            ("Other_Public_Transport","Icon_Other")]
        let activeTransportMots = [
            ("Walking","Icon_Walking"),
            ("Jogging_Running","Icon_Jogging"),
            ("Wheelchair","Icon_Wheelchair"),
            ("Bicycle","Icon_Bicycle"),
            ("Electric_Bike","Icon_Electric_Bike"),
            ("Cargo_Bike","Icon_Cargo_Bike"),
            ("Bike_Sharing","Icon_Bike_Sharing"),
            ("Micro_Scooter","Icon_Micro_Scooter"),
            ("Other_Active_Semi_Active","Icon_Other")]
        let privateTransportMots = [
            ("Car_Driver","Icon_Private_Car_Driver"),
            ("Car_Passenger","Icon_Private_Car_Passenger"),
            ("Taxi_Ride_Hailing","Icon_Taxi"),
            ("Car_Sharing_Rental_Driver","Icon_Car_Sharing_Driver"),
            ("Car_Sharing_Rental_Passenger","Icon_Car_Sharing_Passenger"),
            ("Moped","Icon_Moped"),
            ("Motorcycle","Icon_Motorcycle"),
            ("Electric_Wheelchair_Cart","Icon_Electric_Wheelchair"),
            ("Other_Private_Motorised","Icon_Other")]
        mots.append(publicTransportMots)
        mots.append(activeTransportMots)
        mots.append(privateTransportMots)
        motsSingleList.append(contentsOf: publicTransportMots)
        motsSingleList.append(contentsOf: activeTransportMots)
        motsSingleList.append(contentsOf: privateTransportMots)
    }
    
    func findIndex(text: String) -> Int {
        var ind = 0
        for value in self.motsSingleList {
            if value.0 == text {
                return ind
            }
            ind += 1
        }
        return -1
    }
    
    func getStringFromSection(section: [(String,String)], text: String, sectionInd: Int) -> String {
        for cell in section {
            if cell.0 == text {
                if cell == section.last ?? ("","") {
                    switch sectionInd {
                    case 0:
                        return otherPublic
                    case 1:
                        return otherActivity
                    case 2:
                        return otherPrivate
                    default:
                        break
                    }
                }
                return cell.0
            }
        }
        return ""
    }
    
    func getmotSettingsForRegularityData(text: String) -> MotSettings {
        var mot = ""
        var sectionInd = 0
        for section in self.mots {
            mot = getStringFromSection(section: section, text: text, sectionInd: sectionInd)
            if mot.count > 0 {
                break
            }
            sectionInd += 1
        }
        
        return MotSettings.getmotSettings(mot: findIndex(text: text), motText: mot)
    }
    
    func resetValues() {
        otherPublic = ""
        otherActivity = ""
        otherPrivate = ""
    }
    
    static func getInstance() -> MOTRegularityData {
        if instance == nil {
           instance = MOTRegularityData()
        }
        return instance!
    }
}

class ModeOftransportState {
    var mot: (String,String) // Text, Image
    var selected = false
    
    init(mot: (String,String)) {
        self.mot = mot
    }
    
    func getValueIfSelected() -> String? {
        return selected ? mot.0 : nil
    }
}
