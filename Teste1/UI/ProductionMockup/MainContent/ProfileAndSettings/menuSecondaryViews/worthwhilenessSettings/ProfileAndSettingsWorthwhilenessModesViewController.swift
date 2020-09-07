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

class ProfileAndSettingsWorthwhilenessModesViewController: GenericViewController, UITableViewDelegate, UITableViewDataSource {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        motsTableView.delegate = self
        motsTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        //        nextButton.backgroundColor = UIColor(red: 0.88, green: 0.94, blue: 0.99, alpha: 1)
        //        nextButton.layer.cornerRadius = 9
        //        nextButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        //        nextButton.layer.shadowColor = UIColor(red: 0, green: 0.03, blue: 0, alpha: 0.18).cgColor
        //        nextButton.layer.shadowOpacity = 1
        //        nextButton.layer.shadowRadius = 4
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.nextButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, text: "Next", boldText: true, size: 17, disabled: false, CompleteRoundCorners: true)
        
        
        MotivFont.motivBoldFontFor(text: "Which modes of transport do you use regularly?", label: self.titleLabel, size: 17)
        titleLabel.textColor = MotivColors.WoortiOrange
        MotivAuxiliaryFunctions.RoundView(view: contentPage)
        //        self.view.backgroundColor = MotivColors.WoortiOrange
        self.view.backgroundColor = UIColor.clear
        
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
            return "Public Transport"
        case 1:
            return "Active/Semi-active"
        case 2:
            return "Private Motirized"
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
            mot = motcells[indexPath.section][indexPath.row]
            //            if motcells[indexPath.row].getValue() {
            //                cell.selectCellIfRedraw()
            //            }
            //            motcells[indexPath.row] = cell
        } else {
            
            if motcells.count <= indexPath.section {
                motcells.append([ModeOftransportState]())
            }
            let info = MOTRegularityData.getInstance().mots[indexPath.section][indexPath.row]
            mot = ModeOftransportState(mot: info)
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
    
    @IBAction func NextClick(_ sender: Any) {
        if let user = MotivUser.getInstance() {
            user.preferedMots = NSSet(array: [MotSettings]())
            for section in motcells {
                for cell in section {
                    if let mot = cell.getValueIfSelected() {
                        let mots = MOTRegularityData.getInstance().getmotSettingsForRegularityData(text: mot)
                        user.preferedMots = user.preferedMots.adding(mots) as NSSet
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
                    }
                }
            }
        }
        NotificationCenter.default.post( name: NSNotification.Name(rawValue: OnboardingTopAndContentViewController.OboardViews.OBVGOTOchangeToPRValues.rawValue), object: nil)
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
        MotivFont.motivBoldFontFor(text: "Other \(getNameForSection(section))", label: self.popUpTitle, size: 15)
        self.popUpTitle.textColor = MotivColors.WoortiOrange
        MotivAuxiliaryFunctions.RoundView(view: self.popOver)
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(closePopup))
        self.popupBackButton.addGestureRecognizer(gr)
        self.popupBackButton.image = self.popupBackButton.image?.withRenderingMode(.alwaysTemplate)
        self.popupBackButton.tintColor = MotivColors.WoortiOrange
        
        self.popupTextfield.textColor = MotivColors.WoortiOrange
        self.popupTextfield.backgroundColor = MotivColors.WoortiOrangeT3
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.popupSaveButton, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, text: "SAVE", boldText: true, size: 15, disabled: false)
        
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
