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

class ProfileEditUserViewController: GenericViewController {

    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var changePhotoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = MotivColors.WoortiOrangeT3
        topContainerView.layer.masksToBounds = true
        topContainerView.layer.cornerRadius = topContainerView.bounds.width * 0.05
        // Do any additional setup after loading the view.
        
        nameTextField.backgroundColor = MotivColors.WoortiOrangeT3
        emailTextField.backgroundColor = MotivColors.WoortiOrangeT3
        
        MotivFont.motivRegularFontFor(text: "Change photo", label: changePhotoLabel, size: 15)
        changePhotoLabel.textColor = MotivColors.WoortiOrange
        
        if let user = MotivUser.getInstance() {
            nameTextField.text = user.name
            emailTextField.text = user.email
        }
        
        self.loadSaveButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func finishChangingName(_ sender: Any) {
        resignFirstResponder()
    }
    
    @IBAction func SaveClick(_ sender: Any) {
        if let user = MotivUser.getInstance(),
            let newName = self.nameTextField.text {
            if user.name == newName {
                self.dismiss(animated: true, completion: nil)
                return
            }
            DispatchQueue.global(qos: .background).async {
                user.name = newName
                UserInfo.appDelegate?.saveContext()
                MotivRequestManager.getInstance().requestSaveUserSettings()
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func loadSaveButton(){
        saveButton.layer.masksToBounds = true
        saveButton.layer.cornerRadius = saveButton.bounds.height * 0.5
        MotivFont.motivBoldFontFor(text: "SAVE", label: saveButton.titleLabel!, size: 15)
        saveButton.setTitle("SAVE", for: .normal)
        saveButton.setTitleColor(UIColor.white, for: .normal)
        saveButton.backgroundColor = MotivColors.WoortiGreen
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
