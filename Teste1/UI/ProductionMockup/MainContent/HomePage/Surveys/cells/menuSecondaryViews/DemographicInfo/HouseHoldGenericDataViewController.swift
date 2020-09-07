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

class HouseHoldGenericDataViewController: GenericViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var GeneralHouseholdTAbleView: UITableView!

    var DataContent: genericHouseHoldInfo = HouseHoldData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSaveButton()
        // Do any additional setup after loading the view.
        GeneralHouseholdTAbleView.delegate = self
        GeneralHouseholdTAbleView.dataSource = self
        self.view.backgroundColor = MotivColors.WoortiOrangeT3
        GeneralHouseholdTAbleView.backgroundColor = MotivColors.WoortiOrangeT3
        
        MotivAuxiliaryFunctions.RoundView(view: GeneralHouseholdTAbleView)
    }
    
    func loadSaveButton(){
        saveButton.layer.masksToBounds = true
        saveButton.layer.cornerRadius = saveButton.bounds.height * 0.5
        MotivFont.motivBoldFontFor(key: "Edit", comment: "", button: saveButton, size: 15)
        saveButton.setTitleColor(UIColor.white, for: .normal)
        saveButton.backgroundColor = MotivColors.WoortiOrange
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataContent.getElementsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenericHouseholdDataTableViewCell") as! GenericHouseholdDataTableViewCell
        let row = DataContent.getText(forRow: indexPath.row)
        cell.loadCell(title: row.0, value: row.1)
        
        
        
        return cell
    }
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(44)
    }
 */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.addObserver(self, selector: #selector(returnFromCahngingValues(_:)), name: NSNotification.Name(rawValue: GeneralInfoViewController.callbacks.retrunFromChangingValues.rawValue), object: nil)
        
        DataContent.executeOnclick(forRow: indexPath.row)
    }
    
    @IBAction func clickSaveAll(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            UserInfo.appDelegate?.saveContext()
            MotivRequestManager.getInstance().requestSaveUserSettings()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func returnFromCahngingValues(_ notification: Notification) {
        // process info
        if let returnValue = notification.userInfo?["returnValueText"] as? String {
            if let returnValuePos = notification.userInfo?["returnValuePos"] as? Int {
                DataContent.setValue(text: returnValue, pos: returnValuePos)
            }
        }
        // remove observer
        NotificationCenter.default.removeObserver(self)
        DispatchQueue.main.async {
            self.GeneralHouseholdTAbleView.reloadData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
    }
}

protocol genericHouseHoldInfo {
    func getElementsCount() -> Int
    func getText(forRow: Int) -> (String, String) // Title, value
    func executeOnclick(forRow: Int)
    func setValue(text: String, pos: Int)
}

class HouseHoldData: genericHouseHoldInfo {
    var householdData = [(String,String)]()
    var clicked = 0
    
    private func reload() {
        
        var maritalText = ""
        if let marital = MotivUser.getInstance()!.maritalStatusHousehold {
            maritalText = MotivStringsGen.getInstance().getCodedToReadableInfo(info: marital)
        }
        
        var numberPeopleText = ""
        if let numberPeople = MotivUser.getInstance()!.humberPeopleHousehold {
            numberPeopleText = MotivStringsGen.getInstance().getCodedToReadableInfo(info: numberPeople)
        }
        
        var yearsResidenceText = ""
        if let yearsResidence = MotivUser.getInstance()!.yearsOfResidenceHousehold {
            yearsResidenceText = MotivStringsGen.getInstance().getCodedToReadableInfo(info: yearsResidence)
        }
        
        var labourText = ""
        if let labour = MotivUser.getInstance()!.labourStatusHousehold {
            labourText = MotivStringsGen.getInstance().getCodedToReadableInfo(info: labour)
        }
        
        householdData = [
            ("Marital_Status", maritalText),
            ("Number_People_Household", numberPeopleText),
            ("Household_Years_Residence", yearsResidenceText),
            ("Household_Labour_Status", labourText)]
    }
    
    init() {
        reload()
    }
    
    func getElementsCount() -> Int {
        return householdData.count
    }
    
    func getText(forRow: Int) -> (String, String) {
        if forRow < getElementsCount() {
            return householdData[forRow]
        }
        return ("", "")
    }
    
    func executeOnclick(forRow: Int) {
        clicked = forRow
        switch forRow {
        case 0:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForHouseholdMarital.rawValue), object: nil)
            break
        case 1:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForHouseholdNumPersons.rawValue), object: nil)
            break
        case 2:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForHouseholdYearsResidence.rawValue), object: nil)
            break
        case 3:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForHouseholdLabour.rawValue), object: nil)
            break
        default:
            break
        }
    }
    
    let maritalOptions = ["Single", "Married", "Registered partnership", "Divorced", "Widowed"]
    let yearsResidenceOptions = ["Less than 1", "1 to 5", "More than 5"]
    let labourOptions = ["Student", "Employed full Time", "Employed part-time", "Unemployed", "Pensioner"]
    
    func setValue(text: String, pos: Int) {
        switch clicked {
        case 0:
            if MotivUser.getInstance()!.maritalStatusHousehold == nil || MotivUser.getInstance()!.maritalStatusHousehold == "" {
                MotivUser.getInstance()!.addPointsFromProfile()
            }
            if (MotivUser.getInstance()!.maritalStatusHousehold != maritalOptions[pos]){
                MotivUser.getInstance()!.maritalStatusHousehold = maritalOptions[pos]
            }
            break
        case 1:
            if MotivUser.getInstance()!.humberPeopleHousehold == nil || MotivUser.getInstance()!.humberPeopleHousehold == "" {
                MotivUser.getInstance()!.addPointsFromProfile()
            }
            if(MotivUser.getInstance()!.humberPeopleHousehold != text){
                MotivUser.getInstance()!.humberPeopleHousehold = text
            }
            break
        case 2:
            if MotivUser.getInstance()!.yearsOfResidenceHousehold == nil || MotivUser.getInstance()!.yearsOfResidenceHousehold == "" {
                MotivUser.getInstance()!.addPointsFromProfile()
            }
            if(MotivUser.getInstance()!.yearsOfResidenceHousehold != yearsResidenceOptions[pos]){
                MotivUser.getInstance()!.yearsOfResidenceHousehold = yearsResidenceOptions[pos]
            }
            break
        case 3:
            if MotivUser.getInstance()!.labourStatusHousehold == nil || MotivUser.getInstance()!.labourStatusHousehold == "" {
                MotivUser.getInstance()!.addPointsFromProfile()
            }
            if(MotivUser.getInstance()!.labourStatusHousehold != labourOptions[pos]){
                MotivUser.getInstance()!.labourStatusHousehold = labourOptions[pos]
            }
            break
        default:
            break
        }
        reload()
    
    }
}

class MobilityData: genericHouseHoldInfo {
    var MobilityData = [(String,String)]()
    var clicked = 0
    
    private func reload() {
        MobilityData = [
            ("Car_Owner", MotivUser.getInstance()!.carOwner ? "Yes" : "No"),
            ("Motorbike_Owner", MotivUser.getInstance()!.motorbikeOwner ? "Yes" : "No"),
            ("Subscription_Public_Transport", MotivUser.getInstance()!.subsPubTrans ? "Yes" : "No"),
            ("Subscription_Car_Sharing", MotivUser.getInstance()!.subsCarShare ? "Yes" : "No"),
            ("Subscription_Bike_Sharing", MotivUser.getInstance()!.subsBikShare ? "Yes" : "No")]
    }
    
    init() {
        reload()
    }
    
    func getElementsCount() -> Int {
        return MobilityData.count
    }
    
    func getText(forRow: Int) -> (String, String) {
        if forRow < getElementsCount() {
            return MobilityData[forRow]
        }
        return ("", "")
    }
    
    func executeOnclick(forRow: Int) {
        clicked = forRow
        switch forRow {
        case 0:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForCarOwner.rawValue), object: nil)
            break
        case 1:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForMotorBikeOwner.rawValue), object: nil)
            break
        case 2:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForSubscriptionPublicTransport.rawValue), object: nil)
            break
        case 3:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForSubscriptionCarSharing.rawValue), object: nil)
            break
        case 4:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForSubscriptionBikeSharing.rawValue), object: nil)
            break
        default:
            break
        }
    }
    
    func setValue(text: String, pos: Int) {
        let value = (text == "Yes" ? true : false)
        switch clicked {
        case 0:
            MotivUser.getInstance()!.carOwner = value
            break
        case 1:
            MotivUser.getInstance()!.motorbikeOwner = value
            break
        case 2:
            MotivUser.getInstance()!.subsPubTrans = value
            break
        case 3:
            MotivUser.getInstance()!.subsCarShare = value
            break
        case 4:
            MotivUser.getInstance()!.subsBikShare = value
            break
        default:
            break
        }
        reload()
    }
}
