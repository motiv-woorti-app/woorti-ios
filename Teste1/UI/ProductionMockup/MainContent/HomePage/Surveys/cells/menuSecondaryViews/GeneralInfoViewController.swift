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

class GeneralInfoViewController: GenericViewController, UITextFieldDelegate {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var AgeLabelValue: UILabel!
    @IBOutlet weak var EducationLabel: UILabel!
    @IBOutlet weak var GenderLabelValue: UILabel!
    @IBOutlet weak var CountryLabelValue: UILabel!
    @IBOutlet weak var CityLabelValue: UILabel!
    
    //    @IBOutlet weak var ageTv: UITextField!
//    @IBOutlet weak var genderTv: UITextField!
//
//
//    @IBOutlet weak var countryTv: UITextField!
//    @IBOutlet weak var ResidenceTv: UITextField!
    
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var eductaionInfoLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var resisdenceLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    
    @IBOutlet weak var residenceStackView: UIStackView!
    
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
    
    
    var type = typeOfChange.education
    
    enum typeOfChange {
        case education, age, gender, country, otherCountry, city
    }
    
    enum option {
        case Home
        case Work
    }
    
    enum callbacks: String {
        case retrunFromChangingValues = "GeneralInfoViewControllerretrunFromChangingValues"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = MotivColors.WoortiOrangeT3
        makeViewRound(view: mainView)
        loadViewInformation()
//        loadControl(textView: ageTv)
        loadControl(label: AgeLabelValue)
        loadControl(label: GenderLabelValue)
        loadControl(label: EducationLabel)
        loadControl(label: CountryLabelValue)
        loadControl(label: CityLabelValue)
        loadSaveButton()
        
        if let user = MotivUser.getInstance(){
            if(countries[CountryLabelValue.text!] == nil){
                print("country " + CountryLabelValue.text!)
                let cityLabel = residenceStackView.arrangedSubviews[1]
                cityLabel.isHidden = true
                let cityText = residenceStackView.arrangedSubviews[2]
                cityText.isHidden = false
                cityTextField.text = user.city
                CityLabelValue.text = nil
            }
            else if(user.city == "") {
                print("Empty string")
                updateResidenceStackView(emptyCity: true)
                
            }else {
                updateResidenceStackView(emptyCity: false)
            }
        }
        
        self.cityTextField.delegate = self
        
        
        let gre = UITapGestureRecognizer(target: self, action: #selector(goToChangeValuesEducation))
        EducationLabel.addGestureRecognizer(gre)
        
        let gra = UITapGestureRecognizer(target: self, action: #selector(goToChangeValuesAge))
        AgeLabelValue.addGestureRecognizer(gra)
        
        let grg = UITapGestureRecognizer(target: self, action: #selector(goToChangeValuesGender))
        GenderLabelValue.addGestureRecognizer(grg)
        
        let grco = UITapGestureRecognizer(target: self, action: #selector(goToChangeValuesCountry))
        CountryLabelValue.addGestureRecognizer(grco)
        
        let grci = UITapGestureRecognizer(target: self, action: #selector(goToChangeValuesCity))
        CityLabelValue.addGestureRecognizer(grci)
        
        EducationLabel.isUserInteractionEnabled = true
        EducationLabel.isEnabled = true
        AgeLabelValue.isUserInteractionEnabled = true
        AgeLabelValue.isEnabled = true
        GenderLabelValue.isUserInteractionEnabled = true
        GenderLabelValue.isEnabled = true
        CountryLabelValue.isUserInteractionEnabled = true
        CountryLabelValue.isEnabled = true
        CityLabelValue.isUserInteractionEnabled = true
        CityLabelValue.isEnabled = true
        
        MotivFont.motivRegularFontFor(key: "Age", comment: "", label: ageLabel, size: 17)
        MotivFont.motivRegularFontFor(key: "Gender", comment: "", label: genderLabel, size: 17)
        MotivFont.motivRegularFontFor(key: "Education", comment: "", label: eductaionInfoLabel, size: 17)
        MotivFont.motivRegularFontFor(key: "Country", comment: "", label: countryLabel, size: 17)
        MotivFont.motivRegularFontFor(key: "City", comment: "", label: resisdenceLabel, size: 17)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeViewRound(view :UIView){
        view.layer.masksToBounds = true
        view.layer.cornerRadius = view.bounds.width * 0.05
    }
    
    @IBAction func finishChangingAddress(_ sender: Any) {
        resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.cityTextField.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        cityTextField.placeholder = ""
    }
    
    func loadViewInformation() {
        if let user = MotivUser.getInstance() {

            MotivFont.motivRegularFontFor(text: user.ageRange == "" ? " " : user.ageRange, label: self.AgeLabelValue, size: 14)
            MotivFont.motivRegularFontFor(text: user.gender == "" ? " " : MotivStringsGen.getInstance().getCodedToReadableInfo(info: user.gender), label: self.GenderLabelValue, size: 14)

            MotivFont.motivRegularFontFor(text: user.degree == "" ? " " : MotivStringsGen.getInstance().getCodedToReadableInfo(info: user.degree), label: self.EducationLabel, size: 14)
            
            if let country = Languages.getCountriesForWoortiCode(woortiID: user.country) {
                MotivFont.motivRegularFontFor(text: country.name, label: self.CountryLabelValue, size: 14)
            } else {
                MotivFont.motivRegularFontFor(text: user.country == "" ? " " : user.country, label: self.CountryLabelValue, size: 14)
            }
            
            MotivFont.motivRegularFontFor(text: user.city == "" ? " " : user.city, label: self.CityLabelValue, size: 14)
            
            loadControl(label: self.EducationLabel)


        }
    }
    

    
    
    @objc func goToChangeValuesEducation() {
        // create return function
        NotificationCenter.default.addObserver(self, selector: #selector(returnFromCahngingValues(_:)), name: NSNotification.Name(rawValue: GeneralInfoViewController.callbacks.retrunFromChangingValues.rawValue), object: nil)
        
        self.type = .education
        //Go To changeValeus
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForDemopgraphicInfo.rawValue), object: nil)
    }
    
    @objc func goToChangeValuesAge() {
        // create return function
        NotificationCenter.default.addObserver(self, selector: #selector(returnFromCahngingValues(_:)), name: NSNotification.Name(rawValue: GeneralInfoViewController.callbacks.retrunFromChangingValues.rawValue), object: nil)
        
        self.type = .age
        //Go To changeValeus
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForAge.rawValue), object: nil)
    }
    
    @objc func goToChangeValuesGender() {
        // create return function
        NotificationCenter.default.addObserver(self, selector: #selector(returnFromCahngingValues(_:)), name: NSNotification.Name(rawValue: GeneralInfoViewController.callbacks.retrunFromChangingValues.rawValue), object: nil)
        
        self.type = .gender
        //Go To changeValeus
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForGender.rawValue), object: nil)
    }
    
    @objc func goToChangeValuesCountry() {
        // create return function
        NotificationCenter.default.addObserver(self, selector: #selector(returnFromCahngingValues(_:)), name: NSNotification.Name(rawValue: GeneralInfoViewController.callbacks.retrunFromChangingValues.rawValue), object: nil)
        
        self.type = .country
        //Go To changeValeus
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForCountry.rawValue), object: nil)
    }
    
    @objc func goToChangeValuesOtherCountry() {
        // create return function
        NotificationCenter.default.addObserver(self, selector: #selector(returnFromCahngingValues(_:)), name: NSNotification.Name(rawValue: GeneralInfoViewController.callbacks.retrunFromChangingValues.rawValue), object: nil)
        
        self.type = .otherCountry
        //Go To changeValeus
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForOtherCountry.rawValue), object: nil)
    }
    
    @objc func goToChangeValuesCity() {
        // create return function
        NotificationCenter.default.addObserver(self, selector: #selector(returnFromCahngingValues(_:)), name: NSNotification.Name(rawValue: GeneralInfoViewController.callbacks.retrunFromChangingValues.rawValue), object: nil)
        
        self.type = .city
        //Go To changeValeus
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForCity.rawValue), object: nil)
    }
    
    //String keys
    let genderOptions = ["Male", "Female", "Other"]
    let educationOptions = ["Basic (up to 10th grade)", "High school (12th grade)", "University"]
    
    var selectedEducationPos = -1
    var selectedGenderPos = -1
    
    @objc func returnFromCahngingValues(_ notification: Notification) {
        
        // process info
        if let returnValue = notification.userInfo?["returnValueText"] as? String {
            if let returnValuePos = notification.userInfo?["returnValuePos"] as? Int {
                switch self.type {
                case .education:
                    self.selectedEducationPos = returnValuePos                  //Stores value in variable, only perma saves on Save
                    self.EducationLabel.text = MotivStringsGen.getInstance().getCodedToReadableInfo(info: educationOptions[selectedEducationPos])
                    break
                case .age:
                    self.AgeLabelValue.text = returnValue
                    break
                case .gender:
                    self.selectedGenderPos = returnValuePos                     //Stores value in variable, only perma saves on Save
                    self.GenderLabelValue.text = MotivStringsGen.getInstance().getCodedToReadableInfo(info: genderOptions[selectedGenderPos])
                    break
                case .country:
                    self.CountryLabelValue.text = returnValue
                    if let user = MotivUser.getInstance(){
                        if let country = Languages.getCountriesForCountry(country: returnValue) {
                            user.country = country.woortiID
                            
                            if let cities = countries[returnValue]{
                                self.CityLabelValue.text = cities.first
                                user.city = cities.first!
                                updateResidenceStackView(emptyCity: false)
                            }else {
                                updateResidenceStackView(emptyCity: true)
                                user.city = ""
                            }
                        } else {
                            
                            
                        }
                    }
                    
                    break
                case .otherCountry:
                    let user = MotivUser.getInstance()
                    break;
                    
                case .city:
                    let user = MotivUser.getInstance()
                    self.CityLabelValue.text = returnValue
                    user?.city = returnValue
                    break
                }
            }
        }
        
        // remove observer
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadControl(textView: UITextField) {
        textView.textColor = UIColor.black
        textView.backgroundColor = MotivColors.WoortiOrangeT3
        MotivAuxiliaryFunctions.RoundView(view: textView, CompleteRoundCorners: true)
    }
    
    func updateResidenceStackView(emptyCity: Bool){
        if emptyCity{
            let cityLabel = residenceStackView.arrangedSubviews[1]
            cityLabel.isHidden = true
            let cityText = residenceStackView.arrangedSubviews[2]
            cityText.isHidden = false
            cityTextField.text = nil
            cityTextField.placeholder = "Choose your city"
            CityLabelValue.text = nil
        } else {
            let cityLabel = residenceStackView.arrangedSubviews[1]
            cityLabel.isHidden = false
            let cityText = residenceStackView.arrangedSubviews[2]
            cityText.isHidden = true
        }
    }
    
    func loadControl(label: UILabel) {
        label.textColor = UIColor.black
        label.backgroundColor = MotivColors.WoortiOrangeT3
        label.layer.borderWidth = CGFloat(0.2)
        label.layer.borderColor = UIColor.black.cgColor
        MotivAuxiliaryFunctions.RoundView(view: label, CompleteRoundCorners: true)
    }

    
    func loadSaveButton(){
        saveButton.layer.masksToBounds = true
        saveButton.layer.cornerRadius = saveButton.bounds.height * 0.5
        MotivFont.motivBoldFontFor(key: "Edit", comment: "", button: saveButton, size: 15)
        saveButton.setTitleColor(UIColor.white, for: .normal)
        saveButton.backgroundColor = MotivColors.WoortiOrange
    }
    
    @IBAction func SaveClick(_ sender: Any) {
        if let user = MotivUser.getInstance() {
            var hasChanged = false
            var educationFirstTime = false
            if let age = self.AgeLabelValue.text {
                if user.ageRange != age {
                    user.ageRange = age
                    hasChanged = true
                    
                    let ages = ["16-19","20-24","25-29","30-39","40-49","50-64","65-74","75+"]
                    let minAges = [16,20,25,30,40,50,65,75]
                    let maxAges = [19,24,29,39,49,64,74,125]
                    
                    if let ind = ages.index(of: user.ageRange) {
                        user.minAge = Double(minAges[ind])
                        user.maxAge = Double(maxAges[ind])
                    }
                    
                }
            }
            
            if selectedGenderPos != -1 {
                if user.gender != genderOptions[selectedGenderPos] {
                    user.gender = genderOptions[selectedGenderPos]
                    hasChanged = true
                }
            }
            
            if selectedEducationPos != -1 {
                if user.degree == nil || user.degree == "" {
                    educationFirstTime = true
                }
                
                if user.degree != educationOptions[selectedEducationPos] {
                    user.degree = educationOptions[selectedEducationPos]
                    hasChanged = true
                    
                }
            }

            if  let country = self.CountryLabelValue.text,
                let countryStuff = Languages.getCountriesForCountry(country: country) {
                
                if user.country != countryStuff.woortiID {
                    user.country = countryStuff.woortiID
                    hasChanged = true
                }
            }
           if let city = self.CityLabelValue.text {
                if user.city != city {
                    user.city = city
                    hasChanged = true
                }
           } else {
                user.city = self.cityTextField.text!
                hasChanged = true
            }
            
            if educationFirstTime {
                MotivUser.getInstance()?.addPointsFromProfile()
            }
            
            DispatchQueue.global(qos: .background).async {
                UserInfo.appDelegate?.saveContext()
                MotivRequestManager.getInstance().requestSaveUserSettings()
                
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}
