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

import Foundation
import UIKit
import Firebase
import GoogleSignIn

/*
 * Controller to reset the user's password
 */
class ResetPWDViewController: UIViewController {

    //Header
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var viewTitle: UILabel!
    
    // box
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var tfEmail: UITextField!
    var email: String? = nil
    @IBOutlet weak var btnLogin: UIButton!
    
    var hasSentMail = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MotivAuxiliaryFunctions.imagedNamedToBackground(name: "Orange_BG_Extended", view: self.view)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.ReloadView()
    }
    
    func loadHeader() {
        if (self.backButton.gestureRecognizers ?? [UIGestureRecognizer]()).count == 0 {
            let gr = UITapGestureRecognizer(target: self, action: #selector(back))
            self.backButton.addGestureRecognizer(gr)
        }
        backButton.image = backButton.image?.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
        
        if hasSentMail {
            MotivFont.motivRegularFontFor(key: "Youve_Got_Mail", comment: "you've got mail!", label: self.viewTitle, size: 17)
        } else {
            MotivFont.motivRegularFontFor(key: "Forgot_Password", comment: "Forgot Password", label: self.viewTitle, size: 17)
        }
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.viewTitle, color: UIColor.white)
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func emailTextBoxEndEditing(_ sender: Any) {
        self.email = self.tfEmail.text
        if (self.email ?? "").count > 0 {
            MotivAuxiliaryFunctions.loadStandardButton(button: self.btnLogin, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Reset_Password", comment: "Reset Password", boldText: true, size: 14, disabled: false, CompleteRoundCorners: true)
        }
    }
    
    func loadBox() {
        //handle the box
        MotivAuxiliaryFunctions.RoundView(view: self.boxView)
        //handle the label
        if let email = self.email, hasSentMail {
            let emailReceivedMessage = MotivStringsGen.getInstance().Email_Has_Been_Sent
            MotivFont.motivBoldFontFor(text: String(format: emailReceivedMessage, email), label: self.lblDesc, size: 14, underlined: false)
            self.lblDesc.textColor = MotivColors.WoortiOrange
            //handle the textfield
            self.tfEmail.isHidden = true
            //handle the button
            
            MotivAuxiliaryFunctions.loadStandardButton(button: self.btnLogin, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Back_To_Login", comment: "message: BACK TO LOGIN", boldText: true, size: 14, disabled: true, CompleteRoundCorners: true)
        } else {
            MotivFont.motivBoldFontFor(key: "No_Worries_Message" ,comment: " message: No worries! Enter your email address below and we will send you a email to reset your password.", label: self.lblDesc, size: 14, underlined: false)
            self.lblDesc.textColor = MotivColors.WoortiOrange
            //handle the textfield
            
            loadTextFields(tf: self.tfEmail, key: "Enter_Your_Email_Address", comment: "placeholder for email in login/register")
            
            self.tfEmail.isHidden = false
            //handle the button
            MotivAuxiliaryFunctions.loadStandardButton(button: self.btnLogin, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Reset_Password", comment: "Reset Password button message: RESET PASSWORD", boldText: true, size: 14, disabled: true, CompleteRoundCorners: true)
        }
    }
    
    func loadTextFields(tf: UITextField, key: String, comment: String) {
        let placeholder = NSLocalizedString(key, comment: comment)
        loadTextFields(tf: tf, placeholder: placeholder)
    }
    
    func loadTextFields(tf: UITextField, placeholder: String) {
        tf.backgroundColor = MotivColors.WoortiOrangeT3
        tf.placeholder = placeholder
        tf.textColor = MotivColors.WoortiOrange
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        if hasSentMail {
            self.dismiss(animated: true, completion: nil)
        } else {
            if let email = self.tfEmail.text {
                Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                    print("resetPasswordError: \(String(describing: error))")
                }

                UiAlerts.getInstance().showResetPasswordAlert(email: email)
                self.hasSentMail = true
                self.ReloadView()
            }
        }
    }
    
    func ReloadView() {
        if Thread.isMainThread {
            self.loadHeader()
            self.loadBox()
        } else {
            DispatchQueue.main.async {
                self.ReloadView()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
