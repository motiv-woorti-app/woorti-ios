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

class ChangeGeneralValueViewController: GenericViewController, UITableViewDelegate, UITableViewDataSource {

    var valuesToPrint: changeValueFor = valueForEducationalBackgrounds()
    var requester: GeneralInfoViewController?
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var simpleCountries = true
    var clicked = false
    var queue = DispatchQueue(label: "handleClick")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = MotivColors.WoortiOrangeT3

        //set up talbeview
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func reloadTitle() {
        MotivFont.motivRegularFontFor(key: valuesToPrint.getTitle(), comment: "", label: headerLabel, size: 17)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.headerLabel, color: MotivColors.WoortiOrange)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return valuesToPrint.getElementsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseAValueTableViewCell") as! ChooseAValueTableViewCell
        cell.loadCell(label: valuesToPrint.getText(forRow: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        queue.sync {
            
            if(simpleCountries && indexPath.row == 10){
                simpleCountries = false
                valuesToPrint = valueForOtherCountryBackgrounds()
                tableView.reloadData()
            }else{
                //send value to past view
                var userInfo = [String: Any]()
                userInfo["returnValueText"]  = valuesToPrint.getText(forRow: indexPath.row)
                userInfo["returnValuePos"] = indexPath.row
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: GeneralInfoViewController.callbacks.retrunFromChangingValues.rawValue), object: nil, userInfo: userInfo)
                
                //go back
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.ProfileBack.rawValue), object: nil)
            }
            
        }
    }
}

protocol changeValueFor {
    func getTitle() -> String
    
    func getElementsCount() -> Int
    
    func getText(forRow: Int) -> String
}

class valueForEducationalBackgrounds: changeValueFor {
    
//    let EducationalBackgrounds = ["Education_Basic",
//                                  "Education_Highschool",
//                                  "University"]
    
    let EducationalBackgrounds = ["Basic (up to 10th grade)",
                                  "High school (12th grade)",
                                  "University"]
    
    func getTitle() -> String {
        return NSLocalizedString("Educational_Background", comment: "")
    }
    
    func getElementsCount() -> Int {
        return EducationalBackgrounds.count
    }
    
    func getText(forRow: Int) -> String {
        if getElementsCount() > forRow {
            return NSLocalizedString(EducationalBackgrounds[forRow], comment: "")
        }
        return ""
    }
}


class valueForAgeBackgrounds: changeValueFor {
    
    let ages = ["16-19","20-24","25-29","30-39","40-49","50-64","65-74","75+"]
    
    func getTitle() -> String {
        return NSLocalizedString("What_Is_Your_Age", comment: "")
    }
    
    func getElementsCount() -> Int {
        return ages.count
    }
    
    func getText(forRow: Int) -> String {
        if getElementsCount() > forRow {
            return NSLocalizedString(ages[forRow], comment: "")
        }
        return ""
    }
}

class valueForGenderBackgrounds: changeValueFor {
    
    let Genders = ["Male","Female","Other"]
    
    func getTitle() -> String {
        return NSLocalizedString("Gender", comment: "")
    }
    
    func getElementsCount() -> Int {
        return Genders.count
    }
    
    func getText(forRow: Int) -> String {
        if getElementsCount() > forRow {
            return NSLocalizedString(Genders[forRow], comment: "")
        }
        return ""
    }
}

class valueForCountryBackgrounds: changeValueFor {
    
    
    var Countries = [
        "Portugal",
        "Slovakia",
        "Suomi",
        "España",
        "Belgique/België/Belgien",
        "Suisse/Svizzera/Schweiz",
        "Italia",
        "France",
        "Norge",
        "Hrvatska",
        "Other"]
    
    func getTitle() -> String {
        return NSLocalizedString("Where_Do_You_Live", comment: "")
    }
    
    func getElementsCount() -> Int {
        return Countries.count
    }
    
    func getText(forRow: Int) -> String {
        if getElementsCount() > forRow {
        
//            if let country = Languages.getCountriesForCountry(country: Countries[forRow]) {
////                user?.country = country.woortiID
//                return country.woortiID //NSLocalizedString(Countries[forRow], comment: "")
//            } else {
                return NSLocalizedString(Countries[forRow], comment: "")
            
            return NSLocalizedString(Countries[forRow], comment: "")
        }
        return ""
    }
}

class valueForOtherCountryBackgrounds: changeValueFor {
    
    
    let Countries = Languages.getOtherCountries()
    
    func getTitle() -> String {
        return NSLocalizedString("Where_Do_You_Live", comment: "")
    }
    
    func getElementsCount() -> Int {
        return Countries.count
    }
    
    func getText(forRow: Int) -> String {
        if getElementsCount() > forRow {
            
            return NSLocalizedString(Countries[forRow].name, comment: "")
            
            return NSLocalizedString(Countries[forRow].name, comment: "")
        }
        return ""
    }
}


class valueForCityBackgrounds: changeValueFor {
    
    let countries = [
        "Portugal": ["Lisbon","Porto","Other"],
        "Slovakia": ["Žilina", "Bratislava", "Trnava","Nitra","Trenčín", "Banská Bystrica","Košice","Prešov","Other"],
        "Suomi": ["Helsinki","Tampere","Turku","Oulu","Etelä-Suomi","Länsi-Suomi","Keski-Suomi", "Itä-Suomi","Pohjois-Suomi", "Other"],
        "España": ["Barcelona","Girona","Tarragona","Lleida","Other"],
        "Belgique/België/Belgien": ["Antwerp", "Brugge", "Brussels", "Gent", "Leuven","Other"],
        "Suisse/Svizzera/Schweiz": ["Lausanne","Genève","Montreux","Fribourg", "Bern", "Basel", "Zurich", "Neuchâtel", "Yverdon-les-Bains","Other"],
        "Italia": ["Milan","Other"],
        "France": ["Paris", "Lyon", "Grenoble", "Nevers", "Nantes","Bordeaux", "Toulouse", "Strasbourg", "Amiens", "Angers", "Lille", "Brest", "Marseille", "Saint Brieuc", "Montpellier", "Other"],
        "Norge": ["Oslo","Bergen","Trondheim","Stavager","Drammen","Fredrikstad","Porsgrunn","Skien", "Kristiansand","Ålesund","Tønsberg","Other"],
        "Hrvatska": ["Zagreb","Velika Gorica","Samobor", "Zaprešić", "Dugo selo", "Zagrebačka županija","Split","Rijeka","Osijek","Varaždin","Zadar","Other"],
        "Other": ["Other"]]
    
    
    
    func getTitle() -> String {
        return NSLocalizedString("Where_Do_You_Live", comment: "")
    }
    
    func getElementsCount() -> Int {
        let userCountry = MotivUser.getInstance()?.country
        
        if let country = Languages.getCountriesForWoortiCode(woortiID: userCountry!) {
            return countries[country.name]!.count
        }
        else{
            print("E NULL")
            return 0
        }
    }
    
    func getText(forRow: Int) -> String {
        var userCountry = MotivUser.getInstance()!.country
        
        if let country = Languages.getCountriesForWoortiCode(woortiID: userCountry) {
        
            if getElementsCount() > forRow {
                return NSLocalizedString(countries[country.name]![forRow], comment: "")
            }
        }
        return ""
    }
}

class MaritalStatusHouseHoldInfo: changeValueFor {
    func getTitle() -> String {
        return "Marital_Status"
    }
    
    let MaritalStatus = ["Marital_Single",
                         "Marital_Married",
                         "Marital_Partnership",
                         "Marital_Divorced",
                         "Marital_Widowed"]
    
    func getElementsCount() -> Int {
        return MaritalStatus.count
    }
    
    func getText(forRow: Int) -> String {
        if getElementsCount() > forRow {
            return NSLocalizedString(MaritalStatus[forRow], comment: "")
        }
        return ""
    }
}

class NumberPersonsHouseHoldInfo: changeValueFor {
    func getTitle() -> String {
        return "Number_People_Household"
    }
    
    let HouseholdPeople = ["1",
                         "2",
                         "3",
                         "4",
                         "5+"]
    
    func getElementsCount() -> Int {
        return HouseholdPeople.count
    }
    
    func getText(forRow: Int) -> String {
        if getElementsCount() > forRow {
            return NSLocalizedString(HouseholdPeople[forRow], comment: "")
        }
        return ""
    }
}

class YearsResidenceHouseHoldInfo: changeValueFor {
    func getTitle() -> String {
        return "Household_Years_Residence"
    }
    
    let MaritalStatus = ["Years_Residence_Less_Than_One",
                         "Years_Residence_One_To_Five",
                         "Years_Residence_More_Than_Five"]
    
    func getElementsCount() -> Int {
        return MaritalStatus.count
    }
    
    func getText(forRow: Int) -> String {
        if getElementsCount() > forRow {
            return NSLocalizedString(MaritalStatus[forRow], comment: "")
        }
        return ""
    }
}

class LabourHouseHoldInfo: changeValueFor {
    func getTitle() -> String {
        return "Household_Labour_Status"
    }
    
    let LabourHousehold = ["Labour_Student",
                         "Labour_Employed_Full_Time",
                         "Labour_Employed_Part_Time",
                         "Labour_Unemployed",
                         "Labour_Pensioner"]
    
    func getElementsCount() -> Int {
        return LabourHousehold.count
    }
    
    func getText(forRow: Int) -> String {
        if getElementsCount() > forRow {
            return NSLocalizedString(LabourHousehold[forRow], comment: "")
        }
        return ""
    }
}

class GenericYesNoInfo: changeValueFor {
    func getTitle() -> String {
        return "Generic yes no"
    }
    
    let genericYesNoArray = ["Yes",
                           "No"]
    
    func getElementsCount() -> Int {
        return genericYesNoArray.count
    }
    
    func getText(forRow: Int) -> String {
        if getElementsCount() > forRow {
            return NSLocalizedString(genericYesNoArray[forRow], comment: "")
        }
        return ""
    }
}

class CarOwnerYesNoInfo: GenericYesNoInfo {
    override func getTitle() -> String {
        return "Car_Owner"
    }
}

class MotorbikeOwnerYesNoInfo: GenericYesNoInfo {
    override func getTitle() -> String {
        return "Motorbike_Owner"
    }
}

class SubsPubTransYesNoInfo: GenericYesNoInfo {
    override func getTitle() -> String {
        return "Subscription_Public_Transport"
    }
}

class SubsCarSharingYesNoInfo: GenericYesNoInfo {
    override func getTitle() -> String {
        return "Subscription_Car_Sharing"
    }
}

class SubsBikeSharingYesNoInfo: GenericYesNoInfo {
    override func getTitle() -> String {
        return "Subscription_Bike_Sharing"
    }
}

