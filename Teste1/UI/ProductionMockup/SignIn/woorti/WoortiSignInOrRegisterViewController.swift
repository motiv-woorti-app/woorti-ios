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
 * Class used both on SignIn or Register screens.
 */
class WoortiSignInOrRegisterViewController: UIViewController, GenericSignInVC, GIDSignInUIDelegate  {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        //
    }
    

    //Header
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var viewTitle: UILabel!
    
    //Sign in box
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var lblerroHeight: NSLayoutConstraint!
    @IBOutlet weak var tfEmail: UITextField!
    var email: String? = nil
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfPasswordAgain: UITextField!
    var password: String? = nil
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var lblForgotPassword: UILabel!
    
    var errorString = ""
    
    //sign in with gogle or facebook
    @IBOutlet weak var stvGoogleAndFB: UIStackView!
    var btnSignIn : GIDSignInButton!

    var handle: AuthStateDidChangeListenerHandle?
    var loadedStack = false
    

    @IBOutlet weak var googleButton: UIView!
    @IBOutlet weak var lbldidntSignInYet: UILabel!
    @IBOutlet weak var googleLabel: UILabel!
    
    // type of screen
    var typeOfScreen = type.signIn
    var startLogRegister = true
    
    enum type {
        case register
        case signIn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self

        MotivAuxiliaryFunctions.imagedNamedToBackground(name: "Orange_BG_Extended", view: self.view)
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(changeToRegisterUser))
        self.lbldidntSignInYet.addGestureRecognizer(gr)
        let ggr = UITapGestureRecognizer(target: self, action: #selector(googleSignIn))
        self.googleButton.addGestureRecognizer(ggr)
        
        MotivFont.motivRegularFontFor(key: "Log_In_With_Google", comment: "login with google button message", label: googleLabel, size: 15)
        self.googleLabel.textColor = UIColor.gray
        ReloadView()

        backButton.image = backButton.image?.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
    }
    
    @objc func changeToRegisterUser() {
        regsiterNewUser()
        ReloadView()
    }
    
    @objc func notLoggedIn() {
        if Thread.isMainThread {
            var errorMessage = MotivStringsGen.getInstance().Error_Log_In
            if self.errorString != "" {
                errorMessage = errorString
            }
          
            MotivFont.motivRegularFontFor(text: "\(errorMessage) \(errorString)", label: self.lblError, size: 15)
            self.lblError.textColor = MotivColors.WoortiRed
            self.lblerroHeight.constant = CGFloat(80)
        } else {
            DispatchQueue.main.async {
                self.notLoggedIn()
            }
        }
    }
    
    @objc func emailAlreadyInUse() {
        if Thread.isMainThread {
            let errorMessage = NSLocalizedString("Error_Sign_Up_User_Exists", comment: "") //of type a %@ b
            
            MotivFont.motivRegularFontFor(text: errorMessage, label: self.lblError, size: 15)
            self.lblError.textColor = MotivColors.WoortiRed
            self.lblerroHeight.constant = CGFloat(80)
        } else {
            DispatchQueue.main.async {
                self.emailAlreadyInUse()
            }
        }
    }
    
    @objc func networkError() {
        if Thread.isMainThread {
            let errorMessage = NSLocalizedString("Connectivity_Error", comment: "")  //of type a %@ b
            
            //            MotivFont.motivRegularFontFor(text: "It seems that \(self.tfEmail.text ?? "") has already signed-in. Shall we log you in?", label: self.lblError, size: 15)
            MotivFont.motivRegularFontFor(text: errorMessage, label: self.lblError, size: 15)
            self.lblError.textColor = MotivColors.WoortiRed
            self.lblerroHeight.constant = CGFloat(80)
        } else {
            DispatchQueue.main.async {
                self.emailAlreadyInUse()
            }
        }
    }
    
    @objc func wrongPassword() {
        if Thread.isMainThread {
            let errorMessage = NSLocalizedString("Error_Log_In_Wrong_User_Password", comment: "")  //of type a %@ b
            
            //            MotivFont.motivRegularFontFor(text: "It seems that \(self.tfEmail.text ?? "") has already signed-in. Shall we log you in?", label: self.lblError, size: 15)
            MotivFont.motivRegularFontFor(text: errorMessage, label: self.lblError, size: 15)
            self.lblError.textColor = MotivColors.WoortiRed
            self.lblerroHeight.constant = CGFloat(80)
        } else {
            DispatchQueue.main.async {
                self.emailAlreadyInUse()
            }
        }
    }
    
    @IBAction func emailTextBoxEndEditing(_ sender: Any) {
        self.email = self.tfEmail.text
        if self.hasEmailPasswordFilled() {
            if self.typeOfScreen == type.signIn {
                MotivAuxiliaryFunctions.loadStandardButton(button: self.btnLogin, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Log_In", comment: "Log in button message", boldText: false, size: 14, disabled: false, CompleteRoundCorners: true)
            } else {
                MotivAuxiliaryFunctions.loadStandardButton(button: self.btnLogin, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Sign_In", comment: "sign in button message", boldText: false, size: 14, disabled: false, CompleteRoundCorners: true)
            }
        }
    }
    
    @IBAction func passwordAgainBoxEndEditing(_ sender: Any) {
        if let pass = password, let passAgain = tfPasswordAgain.text, pass.count > 0, passAgain == pass {
            if self.hasEmailPasswordFilled() {
                MotivAuxiliaryFunctions.loadStandardButton(button: self.btnLogin, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Register", comment: "register button message", boldText: false, size: 14, disabled: false, CompleteRoundCorners: true)
            } else {
                let emailString = MotivStringsGen.getInstance().Email
                let passswordString = MotivStringsGen.getInstance().Password
                let notFilledString = MotivStringsGen.getInstance().Not_Filled
                let text = String(format: notFilledString, email != nil ? passswordString : emailString)
                MotivFont.motivRegularFontFor(text: text, label: self.lblError, size: 15)
                self.lblerroHeight.constant = CGFloat(80)
            }
        } else {
            MotivFont.motivRegularFontFor(key: "Passwords_Dont_Match", comment: "erro message shown to the user when registering and the passwords dont match", label: self.lblError, size: 15)
            self.lblerroHeight.constant = CGFloat(80)
        }
    }
    
    
    @IBAction func passwordTextBoxEndEditing(_ sender: Any) {
        self.password = self.tfPassword.text
        if self.hasEmailPasswordFilled() {
            if self.typeOfScreen == type.signIn {
                MotivAuxiliaryFunctions.loadStandardButton(button: self.btnLogin, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Log_In", comment: "Log in button message", boldText: false, size: 14, disabled: false, CompleteRoundCorners: true)
            } else {
                MotivAuxiliaryFunctions.loadStandardButton(button: self.btnLogin, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Sign_In", comment: "sign in button message", boldText: false, size: 14, disabled: false, CompleteRoundCorners: true)
            }
        } else {
            let emailString = MotivStringsGen.getInstance().Email
            let passswordString = MotivStringsGen.getInstance().Password
            let notFilledString = MotivStringsGen.getInstance().Not_Filled
            MotivFont.motivRegularFontFor(text: "\(email != nil ? passswordString : emailString) \(notFilledString)", label: self.lblError, size: 15)
            self.lblerroHeight.constant = CGFloat(80)
        }
    }
    
    @IBAction func logInClick(_ sender: Any) {
        if self.hasEmailPasswordFilled() {
            if self.typeOfScreen == type.signIn {
                signInUser()
            } else {
                registerUser()
            }
        } else {
            //Show error to the user
            self.notLoggedIn()
            let emailString = MotivStringsGen.getInstance().Email
            let passswordString = MotivStringsGen.getInstance().Password
            let notFilledString = MotivStringsGen.getInstance().Not_Filled
            MotivFont.motivRegularFontFor(text: "\(email != nil ? passswordString : emailString) \(notFilledString)", label: self.lblError, size: 15)
        }
    }
    
    func hasEmailPasswordFilled() -> Bool {
        if (self.tfEmail.text ?? "") != "" {
            self.email = self.tfEmail.text
        }
        if (self.tfPassword.text ?? "") != "" {
            self.password = self.tfPassword.text
        }
        return self.email != nil && self.password != nil
    }
    
    var activeUser:User!
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let h = handle {
            Auth.auth().removeStateDidChangeListener(h)
        }
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if let user = user {
               if(SignInManager.instance.differentUser(user: user)) {
                    print("-> LOGGED IN AS \(user.email)")
                    self.getToken(processToken: ProcessSendToken())
                }
            } else {
                print("-> NOT LOGGED IN")
            }
            
            self.ReloadView()
            
            if user == nil && !self.startLogRegister {
                print("Not dismissing on SignIn/Register")

                //self.dismiss(animated: true, completion: nil)
            }
            self.startLogRegister = false
        }
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(GoToMainMenu), name: NSNotification.Name(rawValue: SignInViewController.goToNextScreen), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notLoggedIn), name: NSNotification.Name(rawValue: WoortiSignInV2ViewController.callbacks.notLoggedIn.rawValue), object: nil)
        self.ReloadView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadHeader() {
        let gr = UITapGestureRecognizer(target: self, action: #selector(back))
        self.backButton.addGestureRecognizer(gr)
        self.backButton.image = self.backButton.image?.withRenderingMode(.alwaysTemplate)
        self.backButton.tintColor = MotivColors.WoortiOrangeT3
        
        MotivFont.motivRegularFontFor(key: "Welcome_Back", comment: "title that appears on the top of the login page", label: self.viewTitle, size: 17)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.viewTitle, color: UIColor.white)
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadBox() {
        //handle the box
        MotivAuxiliaryFunctions.RoundView(view: self.boxView)
        
        loadTextFields(tf: self.tfEmail, key: "Enter_Your_Email_Address", comment: "placeholder for email in login/register")
        loadTextFields(tf: self.tfPassword, key: "Enter_Your_Password", comment: "placeholder for password in login/register")
        loadTextFields(tf: self.tfPasswordAgain, key: "Enter_Your_Password_Again", comment: "placeholder for password when registering only")
        
        //handle the button
        if typeOfScreen == .register {
            MotivAuxiliaryFunctions.loadStandardButton(button: self.btnLogin, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Sign_In", comment: "sign in button message", boldText: false, size: 14, disabled: false, CompleteRoundCorners: true)
            self.lblForgotPassword.isHidden = true
            self.tfPasswordAgain.isHidden = false
        } else {
            MotivAuxiliaryFunctions.loadStandardButton(button: self.btnLogin, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Log_In", comment: "Log in button message", boldText: false, size: 14, disabled: false, CompleteRoundCorners: true)
            //handle the label
            MotivFont.motivRegularFontFor(key: "Forgot_Your_Password", comment: "Forgot your Password? message for login screen", label: self.lblForgotPassword, size: 14, underlined: true)
            lblForgotPassword.textColor = MotivColors.WoortiOrange
            self.lblForgotPassword.isUserInteractionEnabled = true
            let gr = UITapGestureRecognizer(target: self, action: #selector(resetPassword))
            for ingr in self.lblForgotPassword.gestureRecognizers ?? [UIGestureRecognizer]() {
                self.lblForgotPassword.removeGestureRecognizer(ingr)
            }
            self.lblForgotPassword.addGestureRecognizer(gr)
            self.lblForgotPassword.isHidden = false
            self.tfPasswordAgain.isHidden = true
        }
    }
    
    @objc func resetPassword() {
        self.performSegue(withIdentifier: "GoToResetPWD", sender: nil)
    }
    
    func regsiterNewUser() {
        self.typeOfScreen = type.register
    }
    
    func loadTextFields(tf: UITextField, placeholder: String) {
        tf.backgroundColor = MotivColors.WoortiOrangeT3
        tf.placeholder = placeholder
        tf.textColor = MotivColors.WoortiOrange
    }
    
    func loadTextFields(tf: UITextField, key: String, comment: String) {
        let placeholder = NSLocalizedString(key, comment: comment)
        loadTextFields(tf: tf, placeholder: placeholder)
    }
    
    @objc func googleSignIn() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func loadGFStack() {
        
        MotivAuxiliaryFunctions.RoundView(view: googleButton, CompleteRoundCorners: true)
        googleButton.isUserInteractionEnabled = true
        
        
        if self.typeOfScreen == .signIn {
            MotivFont.motivRegularFontFor(key: "Didnt_sign_up_yet", comment: "didn't sign up yet message in the login page", label: self.lbldidntSignInYet, size: 15, underlined: true, range: nil)
            self.lbldidntSignInYet.textColor = UIColor.white
            self.lbldidntSignInYet.isUserInteractionEnabled = true
            lbldidntSignInYet.isHidden = false
        } else {
            lbldidntSignInYet.isHidden = true
        }
    }
    
    func ReloadView() {
        if Thread.isMainThread {
            self.loadHeader()
            self.loadBox()
            self.loadGFStack()
        } else {
            DispatchQueue.main.async {
                self.ReloadView()
            }
        }
    }
    
    @objc func GoToMainMenu() {
        if Thread.isMainThread {
            if(!SignInManager.instance.checkGoToMainMenu()){
                return
            }

            if let user = MotivUser.getInstance() {
                if self.typeOfScreen == type.register { //if register continue with the onboarding
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:OnboardingTopAndContentViewController.OboardViews.OBVGOTOchangeToGDPR.rawValue), object: nil)
//                    self.dismiss(animated: true, completion: nil)
                    if let presenting = self.presentingViewController as? OnboardingTopAndContentViewController {
                        
                        presenting.changeTogDPRAcceptance()
                    }
                    self.dismiss(animated: true, completion: nil)
                } else if !(user.hasOnboardingFilledInfo)  {
                    print("Woorti SignIn/Register DOES NOT HAVE ONBOARDING")
                    if let presentedView = self.presentedViewController {
                        if (presentedViewController as? OnboardingViewController) == nil {
                             
                            self.performSegue(withIdentifier: "GoToOnBoarding", sender: nil)
                            NotificationCenter.default.removeObserver(self)
                        }
                    } else {
                        
                        self.performSegue(withIdentifier: "GoToOnBoarding", sender: nil)
                        NotificationCenter.default.removeObserver(self)
                    }
                } else {
                    if !(user.hasOnboardingInfo) {
                        MotivRequestManager.getInstance().requestSaveUserSettings()
                    }
                    if let presentedView = self.presentedViewController {
                        if (presentedViewController as? MainViewController) == nil {
                            
                            //presentedView.dismiss(animated: true, completion: nil)
                            self.performSegue(withIdentifier: "GoToMainMenu", sender: nil)
                            NotificationCenter.default.removeObserver(self)
                        }
                    } else {
                        self.performSegue(withIdentifier: "GoToMainMenu", sender: nil)
                        NotificationCenter.default.removeObserver(self)
                    }
                }
            }
            SignInManager.instance.availableMainMenu()
        } else {
            DispatchQueue.main.async {
                self.GoToMainMenu()
            }
        }
    }
    
    func loginButton(_ loginButton: FBLoginButton!, didCompleteWith result: LoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        if result.isCancelled {
            return
        }
        
        if let token = result?.token?.tokenString {
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
    
    func getToken(processToken: ProcessTokenResponse) {
        print("getIdToken in WoortiSignInOrRegister")
        SignInManager.instance.getToken(view: self, processToken: processToken)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton!) {
        
        
    }
    
    func registerUser() {
        if  let email = self.email,
            let password = self.password {
            
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    print("REGISTER_ERROR_START - " + error.localizedDescription);
                    if let errCode = AuthErrorCode(rawValue: error._code) {
                        print("REGISTER_ERROR_errCode - \(errCode.rawValue)");
                        switch errCode {
                        case AuthErrorCode.emailAlreadyInUse:
                            self.emailAlreadyInUse()
                            break
                        case AuthErrorCode.credentialAlreadyInUse:
                            self.emailAlreadyInUse()
                            break
                        case AuthErrorCode.networkError:
                            self.networkError()
                            break
                        default:
                            print("Create User Error: \(error)")
                        }
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: WoortiSignInV2ViewController.callbacks.notLoggedIn.rawValue), object: nil)
                    return
                }
                print("USER CREATED")
                SignInManager.instance.goToOnboardingFromRegister = true
                if let user = user?.user  {
                    UserInfo.email = user.email
                }
            }
        }
    }
    
    func signInUser() {
        if  let email = self.email,
            let password = self.password {
            
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    print("ERROR ON SIGN IN")
                    UiAlerts.getInstance().newView(view: self)
                    UiAlerts.getInstance().showAlertMsg(error: error)
                    if let errCode = AuthErrorCode(rawValue: error._code) {
                        switch errCode {
                            case AuthErrorCode.networkError:
                                self.networkError()
                                break
                            case AuthErrorCode.userDisabled:
                                self.errorString = "(user disabled)"
                            case AuthErrorCode.wrongPassword:
                                self.wrongPassword()
                            case AuthErrorCode.invalidEmail:
                                self.errorString = "(invalid email)"
                            default:
                                break
                        }
                    }
                }
                if let user = user?.user  {
                    UserInfo.email = user.email
                }
            }
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           // Get the new view controller using segue.destinationViewController.
           // Pass the selected object to the new view controller.
           if let dest = segue.destination as? OnboardingViewController {
               print("Going to Onboarding from SignIn/Register")
           }
       }

}
