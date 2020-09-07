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
import FBSDKLoginKit

/*
 * Controller to handle user Sign In
 */
class SignInViewController: UIViewController, GenericSignInVC, GIDSignInUIDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
        
    var btnSignIn : GIDSignInButton!
    var handle: AuthStateDidChangeListenerHandle?
    var txtEmail: String? = nil
    var txtPassword: String? = nil
    
    static let goToNextScreen = "SignInViewControllerGoTonext"
    
    @IBOutlet weak var UpperLabel: UILabel!
    @IBOutlet weak var requestResetEmail: UILabel!
    @IBOutlet weak var TextFieldToFill: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sign In"
        GIDSignIn.sharedInstance().uiDelegate = self
        
        btnSignIn = GIDSignInButton()
        btnSignIn.center = view.center
        btnSignIn.style = GIDSignInButtonStyle.standard
        view.addSubview(btnSignIn)
        
        MotivFont.motivRegularFontFor(text: "Forgot Your Password?", label: self.requestResetEmail, size: 15)
        let attributedString = NSMutableAttributedString(string: self.requestResetEmail.text ?? "")
        attributedString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: attributedString.length - 1))
        self.requestResetEmail.attributedText = attributedString
        self.requestResetEmail.isHidden = true
        let gr = UITapGestureRecognizer(target: self, action: #selector(resetPassword))
        self.requestResetEmail.addGestureRecognizer(gr)
        
        var belowGSignIn = btnSignIn.center
        belowGSignIn.y += btnSignIn.bounds.height + 10 //put below google button
        
        toggleAuthUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(GoToMainMenu), name: NSNotification.Name(rawValue: SignInViewController.goToNextScreen), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UiAlerts.getInstance().newView(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.toggleAuthUI()
            //self.getToken(processToken: ProcessSendToken())
            UserInfo.fetchUserTrips()
            self.toggleAuthUI()
        }
        toggleAuthUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    
    func toggleAuthUI() {
//        if (Auth.auth().currentUser != nil){
//            // Signed in
//            TextFieldToFill.isHidden = true
//            btnSignIn.isHidden = true
//        } else {
//            if (GIDSignIn.sharedInstance().hasAuthInKeychain()) {
//                GIDSignIn.sharedInstance().signOut()
//            }
//            btnSignIn.isHidden = false
//            TextFieldToFill.isHidden = false
//        }
    }
    
    @objc func resetPassword() {
        if let email = txtEmail {
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                print("resetPasswordError: \(String(describing: error))")
            }
            
            UiAlerts.getInstance().showResetPasswordAlert(email: email)
        }
    }
    
    func getToken(processToken: ProcessTokenResponse) {
        print("getIdToken in SignInViewController")
        MotivUser.getIdToken(view: self, processToken: processToken)
    }
    
    /*
     * Facebook login
     */
    func loginButton(_ loginButton: FBLoginButton!, didCompleteWith result: LoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        if result.isCancelled {
            return
        }
        
        if let token = result.token?.tokenString {
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    
                    print("\(error.localizedDescription)")
                    UiAlerts.getInstance().newView(view: self)
                    UiAlerts.getInstance().showAlertMsg(title: "Error Signing In", message: error.localizedDescription)
                    return
                }
                if let user = authResult?.user  {
                    UserInfo.email = user.email
                    //print("signed In User")
//                    self.GoToMainMenu()
                    
                    self.getToken(processToken: ProcessSendToken())
                }
            }
        }
    }
    
    /*
     * Facebook logout
     */
    func loginButtonDidLogOut(_ loginButton: FBLoginButton!) {
        
    }
    
    
    @IBAction func textBoxEndEditing(_ sender: Any) {
        if self.txtEmail == nil {
            self.txtEmail = self.TextFieldToFill.text
            self.TextFieldToFill.text = ""
            requestResetEmail.isHidden = false
            
            self.UpperLabel.text = "Set a Password to log In in the future"
            self.TextFieldToFill.textContentType = UITextContentType.password
        } else {
            self.txtPassword = self.TextFieldToFill.text
            self.TextFieldToFill.text = ""
            resignFirstResponder()
            self.registerUser()
        }
    }
    
    /*
     * Handle user sign in
     */
    func signInUser() {
            if  let email = txtEmail,
                let password = txtPassword {

                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    if let error = error {
                        UiAlerts.getInstance().showAlertMsg(error: error)
                        self.txtPassword = nil
                        self.txtEmail = nil
                        print("error: \(error)")
                        UiAlerts.getInstance().newView(view: self)
                        UiAlerts.getInstance().showAlertMsg(title: "Error Signing In", message: error.localizedDescription)
                    }
                    if let user = user?.user  {
                        UserInfo.email = user.email
                        self.getToken(processToken: ProcessSendToken())
                    }
                }
            }
    }

//    @IBAction func btnRegisterClick(_ sender: Any) {
    func registerUser() {
        if  let email = txtEmail,
            let password = txtPassword {

            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if let error = error {
//                    UiAlerts.getInstance().showAlertMsg(error: error)
//                    print("error: \(error)")
                    if let errCode = AuthErrorCode(rawValue: error._code) {
                        switch errCode {
                        case AuthErrorCode.emailAlreadyInUse:
                            self.signInUser()
                        default:
                            UiAlerts.getInstance().newView(view: self)
                            UiAlerts.getInstance().showAlertMsg(title: "Error registering", message: error.localizedDescription)
                            print("Create User Error: \(error)")
                        }
                    }
                    self.txtPassword = nil
                    self.txtEmail = nil
                    return
                }
                
                if let user = user?.user  {
                    UserInfo.email = user.email
                    //print("Created User")
//                    self.GoToMainMenu()
                    self.getToken(processToken: ProcessSendToken(true))
                }
            }
        }
    }
    
//    private func emailPasswordFilled() -> Bool {
//        if  let email = txtEmail.text,
//            let password = txtPassword.text {
//
//            return (email.count > 0) && (password.count) > 0
//        }
//        return false
//    }
    
    @objc func GoToMainMenu() {
        if Thread.isMainThread {
            if let user = MotivUser.getInstance() {
                if !(user.hasOnboardingFilledInfo)  {
                    if let presentedView = self.presentedViewController {
                        if (presentedViewController as? OnboardingViewController) == nil {
                            presentedView.dismiss(animated: true, completion: nil)
                            self.performSegue(withIdentifier: "GoToOnBoarding", sender: nil)
                        }
                    } else {
                        self.performSegue(withIdentifier: "GoToOnBoarding", sender: nil)
                    }
                } else {
                    if !(user.hasOnboardingInfo) {
                       MotivRequestManager.getInstance().requestSaveUserSettings()
                    }
                    if let presentedView = self.presentedViewController {
                        if (presentedViewController as? MainViewController) != nil {
                            presentedView.dismiss(animated: true, completion: nil)
                            self.performSegue(withIdentifier: "GoToMainMenu", sender: nil)
                        }
                    } else {
                        self.performSegue(withIdentifier: "GoToMainMenu", sender: nil)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.GoToMainMenu()
            }
        }
    }
}

protocol GenericSignInVC {
    func GoToMainMenu()
}
