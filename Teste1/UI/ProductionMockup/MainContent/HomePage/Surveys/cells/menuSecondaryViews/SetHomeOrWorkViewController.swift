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

class SetHomeOrWorkViewController: GenericViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textView: UITextField!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    var SetOption = option.Work
    var hasLoaded = false
    
    enum option {
        case Home
        case Work
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = MotivColors.WoortiOrangeT3
        makeViewRound(view: mainView)
        loadOptions()
        hasLoaded = true
        
        textView.textColor = MotivColors.WoortiOrange
        textView.backgroundColor = MotivColors.WoortiOrangeT3
        loadSaveButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeViewRound(view :UIView){
        view.layer.masksToBounds = true
        view.layer.cornerRadius = view.bounds.width * 0.05
    }
    
    func loadView(option: option) {
        self.SetOption = option
        if hasLoaded {
            loadOptions()
        }
    }
    
    @IBAction func finishChangingAddress(_ sender: Any) {
        resignFirstResponder()
    }
    
    private func loadOptions() {
        switch self.SetOption {
        case .Home:
            MotivFont.motivRegularFontFor(key: "Define_Home_Location", comment: "message: Define the location of your home to get trips faster", label: self.label, size: 17)
            self.textView.text = MotivUser.getInstance()?.homeAddress ?? ""
        case .Work:
            MotivFont.motivRegularFontFor(key: "Define_Work_Location", comment: "message: Define the location of your work to get trips faster", label: self.label, size: 17)
            self.textView.text = MotivUser.getInstance()?.workAddress ?? ""
        }
        self.label.textColor = MotivColors.WoortiOrange
    }
    
    func loadSaveButton(){
        saveButton.layer.masksToBounds = true
        saveButton.layer.cornerRadius = saveButton.bounds.height * 0.5
        saveButton.setTitleColor(UIColor.white, for: .normal)
        MotivFont.motivBoldFontFor(key: "Save", comment: "", button: saveButton, size: 15)
        saveButton.backgroundColor = MotivColors.WoortiGreen
    }
    
    @IBAction func SaveClick(_ sender: Any) {
        if let user = MotivUser.getInstance(),
            let address = self.textView.text {
            DispatchQueue.global(qos: .background).async {
                
                switch self.SetOption {
                case .Work:
                    if user.workAddress == address {
                        
                        self.dismiss(animated: true, completion: nil)
                        return
                    }
                    user.workAddress = address
                case .Home:
                    if user.homeAddress == address {
                        
                        self.dismiss(animated: true, completion: nil)
                        return
                    }
                    user.homeAddress = address
                }
                
                UserInfo.appDelegate?.saveContext()
                MotivRequestManager.getInstance().requestSaveUserSettings()
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
