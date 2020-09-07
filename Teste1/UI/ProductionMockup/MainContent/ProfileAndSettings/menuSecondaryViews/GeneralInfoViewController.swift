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

class GeneralInfoViewController: GenericViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var ageTv: UITextField!
    @IBOutlet weak var genderTv: UITextField!
    @IBOutlet weak var EducationLabel: UILabel!
    @IBOutlet weak var countryTv: UITextField!
    @IBOutlet weak var ResidenceTv: UITextField!
    
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
        loadControl(textView: ageTv)
        loadControl(textView: genderTv)
        loadControl(label: EducationLabel)
        loadControl(textView: countryTv)
        loadControl(textView: ResidenceTv)
        loadSaveButton()
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(goToChangeValues))
        EducationLabel.addGestureRecognizer(gr)
        
        EducationLabel.isUserInteractionEnabled = true
        EducationLabel.isEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeViewRound(view :UIView){
        view.layer.masksToBounds = true
        view.layer.cornerRadius = view.bounds.width * 0.05
    }
    
    func loadViewInformation() {
        if let user = MotivUser.getInstance() {
            self.ageTv.text = user.ageRange
            self.genderTv.text = user.gender
            MotivFont.motivRegularFontFor(text: user.degree == "" ? "aaddaadd" : user.degree, label: self.EducationLabel, size: 14)
            loadControl(label: self.EducationLabel)
            self.countryTv.text = user.country
            self.ResidenceTv.text = user.city
        }
    }
    
    @objc func goToChangeValues() {
        // create return function
        NotificationCenter.default.addObserver(self, selector: #selector(returnFromCahngingValues(_:)), name: NSNotification.Name(rawValue: GeneralInfoViewController.callbacks.retrunFromChangingValues.rawValue), object: nil)
        
        //Go To changeValeus
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileAndSettingsContentMainViewController.ProfileViews.profileChangeAValueForDemopgraphicInfo.rawValue), object: nil)
    }
    
    @objc func returnFromCahngingValues(_ notification: Notification) {
        // process info
        if let returnValue = notification.userInfo?["returnValue"] as? String {
            self.EducationLabel.text = returnValue
        }
        
        // remove observer
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadControl(textView: UITextField) {
        textView.textColor = UIColor.black
        textView.backgroundColor = MotivColors.WoortiOrangeT3
        MotivAuxiliaryFunctions.RoundView(view: textView, CompleteRoundCorners: true)
    }
    
    func loadControl(label: UILabel) {
        label.textColor = UIColor.black
        label.backgroundColor = MotivColors.WoortiOrangeT3
        label.layer.borderWidth = CGFloat(0.2)
        label.layer.borderColor = UIColor.black.cgColor
        MotivAuxiliaryFunctions.RoundView(view: label, CompleteRoundCorners: true)
    }
    
    @IBAction func finishChangingAddress(_ sender: Any) {
        resignFirstResponder()
    }
    
    func loadSaveButton(){
        saveButton.layer.masksToBounds = true
        saveButton.layer.cornerRadius = saveButton.bounds.height * 0.5
        MotivFont.motivBoldFontFor(text: "EDIT", label: saveButton.titleLabel!, size: 15)
        saveButton.setTitle("EDIT", for: .normal)
        saveButton.setTitleColor(UIColor.white, for: .normal)
        saveButton.backgroundColor = MotivColors.WoortiOrange
    }
    
    @IBAction func SaveClick(_ sender: Any) {
        if let user = MotivUser.getInstance() {
            var hasChanged = false
            if let age = self.ageTv.text {
                if user.ageRange != age {
                    user.ageRange = age
                    hasChanged = true
                }
            }
            
            if let gender = self.genderTv.text {
                if user.gender != gender {
                    user.gender = gender
                    hasChanged = true
                }
            }
            
            if let degree = self.EducationLabel.text {
                if user.degree != degree {
                    user.degree = degree
                    hasChanged = true
                }
            }

            if let country = self.countryTv.text {
                if user.country != country {
                    user.country = country
                    hasChanged = true
                }
            }
            
            if let city = self.ResidenceTv.text {
                if user.city != city {
                    user.city = city
                    hasChanged = true
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                if hasChanged {
                    UserInfo.appDelegate?.saveContext()
                    MotivRequestManager.getInstance().requestSaveUserSettings()
                }
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}
