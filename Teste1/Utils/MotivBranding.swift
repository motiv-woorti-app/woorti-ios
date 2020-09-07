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

class MotivColors {
    static let WoortiOrange = colorFromRGBAInt(R: 237, G: 126, B: 3, A: 1)
    static let WoortiOrangeT1 = colorFromRGBAInt(R: 246, G: 190, B: 129, A: 1)
    static let WoortiOrangeT2 = colorFromRGBAInt(R: 251, G: 229, B: 205, A: 1)
    static let WoortiOrangeT3 = colorFromRGBAInt(R: 253, G: 242, B: 230, A: 1)
    static let WoortiOrangecellBG = colorFromRGBAInt(R: 250, G: 216, B: 179, A: 1)
    
    static let WoortiBrown = colorFromRGBAInt(R: 174, G: 97, B: 42, A: 1)
    static let WoortiBrownT1 = colorFromRGBAInt(R: 198, G: 144, B: 106, A: 1)
    static let WoortiBrownT2 = colorFromRGBAInt(R: 214, G: 176, B: 148, A: 1)
    static let WoortiBrownT3 = colorFromRGBAInt(R: 239, G: 223, B: 212, A: 1)
    
    static let WoortiBlack = colorFromRGBAInt(R: 18, G: 16, B: 12, A: 1)
    static let WoortiBlackT1 = colorFromRGBAInt(R: 113, G: 112, B: 109, A: 1)
    static let WoortiBlackT2 = colorFromRGBAInt(R: 208, G: 207, B: 206, A: 1)
    static let WoortiBlackT3 = colorFromRGBAInt(R: 231, G: 231, B: 231, A: 1)
    
    static let WoortiYellow = colorFromRGBAInt(R: 255, G: 176, B: 32, A: 1)
    static let WoortiYellowT1 = colorFromRGBAInt(R: 255, G: 192, B: 77, A: 1)
    static let WoortiYellowT2 = colorFromRGBAInt(R: 255, G: 208, B: 121, A: 1)
    static let WoortiYellowT3 = colorFromRGBAInt(R: 255, G: 233, B: 166, A: 1)

    static let WoortiGreen = colorFromRGBAInt(R: 130, G: 207, B: 144, A: 1)
    static let WoortiGreenT1 = colorFromRGBAInt(R: 155, G: 217, B: 166, A: 1)
    static let WoortiGreenT2 = colorFromRGBAInt(R: 186, G: 226, B: 188, A: 1)
    static let WoortiGreenT3 = colorFromRGBAInt(R: 205, G: 236, B: 211, A: 1)
    
    static let WoortiBlue = colorFromRGBAInt(R: 28, G: 176, B: 246, A: 1)
    static let WoortiBlueT1 = colorFromRGBAInt(R: 73, G: 192, B: 248, A: 1)
    static let WoortiBlueT2 = colorFromRGBAInt(R: 119, G: 208, B: 250, A: 1)
    static let WoortiBlueT3 = colorFromRGBAInt(R: 164, G: 223, B: 251, A: 1)
    
    static let WoortiDarkBlue = colorFromRGBAInt(R: 72, G: 83, B: 112, A: 1)
    static let WoortiDarkBlueT1 = colorFromRGBAInt(R: 109, G: 117, B: 141, A: 1)
    static let WoortiDarkBlueT2 = colorFromRGBAInt(R: 145, G: 152, B: 169, A: 1)
    static let WoortiDarkBlueT3 = colorFromRGBAInt(R: 182, G: 126, B: 198, A: 1)
    
    static let WoortiRed = colorFromRGBAInt(R: 246, G: 80, B: 88, A: 1)
    static let WoortiRedT1 = colorFromRGBAInt(R: 248, G: 115, B: 121, A: 1)
    static let WoortiRedT2 = colorFromRGBAInt(R: 250, G: 150, B: 155, A: 1)
    static let WoortiRedT3 = colorFromRGBAInt(R: 253, G: 220, B: 222, A: 1)
    
    private static func colorFromRGBA(R: CGFloat, G: CGFloat, B: CGFloat, A: CGFloat) -> UIColor {
        return UIColor(displayP3Red: R/CGFloat(255), green: G/CGFloat(255), blue: B/CGFloat(255), alpha: A)
    }
    
    private static func colorFromRGBAInt(R: Int, G: Int, B: Int, A: Int) -> UIColor {
        return colorFromRGBA(R: CGFloat(R), G: CGFloat(G), B: CGFloat(B), A: CGFloat(A))
    }
}

class MotivFont {
    
    private static let regularFont = "Montserrat-Regular"
    private static let boldFont = "Montserrat-Bold"
    
    private static func offset() -> Int {
        let sWidth = UIScreen.main.bounds.width
        var offset = 0
        if sWidth > 800/2 {
            offset = 1 + Int((sWidth - 800/2)/5)
        }
        return offset
    }
    
    private static func offsetHeight() -> Int {
        let sWidth = UIScreen.main.bounds.height
        var offset = 0
        if sWidth > 1200/2 {
            offset = 1 + Int((sWidth - 1200/2)/50)
        }
        return offset
    }
    
    // final functions
    private static func motivFontFor(text: String, label: UILabel, size: Int, font: String, underlined: Bool = false, range: NSRange? = nil) {
        if Thread.isMainThread {
            let offset = MotivFont.offset()
            
            label.font = UIFont(name: font, size: CGFloat(size + offset))
            var attributedText = NSMutableAttributedString(string: text)
            if underlined {
                let underlineAttribute = [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
                if let uRange = range {
                    attributedText.addAttributes(underlineAttribute, range: uRange)
                } else {
                    attributedText = NSMutableAttributedString(string: text, attributes: underlineAttribute)
                }
            }
            
            attributedText.addAttribute(.foregroundColor, value: UIColor.gray, range: NSRange(location: 0, length: attributedText.length))
            attributedText.addAttribute(.font, value: UIFont(name: font, size: CGFloat(size + offset)), range: NSRange(location: 0, length: attributedText.length))
            
            label.attributedText = attributedText
        } else {
            DispatchQueue.main.sync {
                motivFontFor(text: text, label: label, size: size, font: font, underlined: underlined, range: range)
            }
        }
    }
    
    public static func motivAttributedFontFor(attributedText: NSMutableAttributedString, label: UILabel, underlined: Bool = false, range: NSRange? = nil) {
        if Thread.isMainThread {
            let offset = MotivFont.offset()
            
//            label.font = UIFont(name: font, size: CGFloat(size + offset))
//            var attributedText = NSMutableAttributedString(string: text)
//            if underlined {
//                let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
//                if let uRange = range {
//                    attributedText.addAttributes(underlineAttribute, range: uRange)
//                } else {
//                    attributedText = NSMutableAttributedString(string: text, attributes: underlineAttribute)
//                }
//            }
            
            label.attributedText = attributedText
        } else {
            DispatchQueue.main.sync {
                motivAttributedFontFor(attributedText: attributedText, label: label, underlined: underlined, range: range)
            }
        }
    }
    
    private static func motivFontFor(text: String, button: UIButton, size: Int, font: String) {
        let offset = MotivFont.offset()
        button.titleLabel?.font = UIFont(name: font, size: CGFloat(size + offset))
        button.setTitle(text, for: .normal)
    }
    
    private static func motivFontFor(text: String, tv: UITextView, size: Int, font: String) {
        let offset = MotivFont.offset()
        let heightOffset = MotivFont.offsetHeight()
        tv.font = UIFont(name: font, size: CGFloat(size + offset + heightOffset))
//        attributedText.addAttribute(.foregroundColor, value: UIColor.gray, range: NSRange(location: 0, length: attributedText.length))
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        tv.attributedText = NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray, NSAttributedStringKey.font: UIFont(name: font, size: CGFloat(size + offset + heightOffset)), NSAttributedStringKey.paragraphStyle: paragraph])
    }
    
    //high level functions
    
    //-------------button-------------
    public static func motivBoldFontFor(key: String, comment: String , button: UIButton, size: Int) {
        let text = NSLocalizedString(key, comment: comment)
        motivBoldFontFor(text: text, button: button, size: size)
    }
    
    public static func motivBoldFontFor(text: String, button: UIButton, size: Int) {
        MotivFont.motivFontFor(text: text, button: button, size: size, font: MotivFont.boldFont)
    }
    
    public static func motivRegularFontFor(key: String, comment: String, button: UIButton, size: Int) {
        let text = NSLocalizedString(key, comment: comment)
        motivRegularFontFor(text: text, button: button, size: size)
    }
    
    public static func motivRegularFontFor(text: String, button: UIButton, size: Int) {
        MotivFont.motivFontFor(text: text, button: button, size: size, font: MotivFont.regularFont)
    }
    
    //-------------textview-------------
    public static func motivBoldFontFor(key: String, comment: String , tv: UITextView, size: Int) {
        let text = NSLocalizedString(key, comment: comment)
        motivBoldFontFor(text: text, tv: tv, size: size)
    }
    
    public static func motivBoldFontFor(text: String, tv: UITextView, size: Int) {
        MotivFont.motivFontFor(text: text, tv: tv, size: size, font: MotivFont.boldFont)
    }
    
    public static func motivRegularFontFor(key: String, comment: String , tv: UITextView, size: Int) {
        let text = NSLocalizedString(key, comment: comment)
        motivRegularFontFor(text: text, tv: tv, size: size)
    }
    
    public static func motivRegularFontFor(text: String, tv: UITextView, size: Int) {
        MotivFont.motivFontFor(text: text, tv: tv, size: size, font: MotivFont.regularFont)
    }
    
    //-------------Label-------------
    public static func motivBoldFontFor(key: String, comment: String , label: UILabel, size: Int, underlined: Bool = false) {
        let text = NSLocalizedString(key, comment: comment)
        motivBoldFontFor(text: text, label: label, size: size, underlined: underlined)
    }
    
    public static func motivBoldFontFor(text: String, label: UILabel, size: Int, underlined: Bool = false) {
        MotivFont.motivFontFor(text: text, label: label, size: size, font: MotivFont.boldFont, underlined: underlined)
    }
    
    public static func motivRegularFontFor(key: String, comment: String, label: UILabel, size: Int, underlined: Bool = false, range: NSRange? = nil) {
        let text = NSLocalizedString(key, comment: comment)
        motivRegularFontFor(text: text, label: label, size: size, underlined: underlined, range: range)
    }
    
    public static func motivRegularFontFor(text: String, label: UILabel, size: Int, underlined: Bool = false, range: NSRange? = nil) {
        MotivFont.motivFontFor(text: text, label: label, size: size, font: MotivFont.regularFont, underlined: underlined, range: range)
    }
    
    //-------------Attributed Strings-------------
    public static func getBoldText(text: String, size: Int) -> NSMutableAttributedString {
        let offset = MotivFont.offset()
        let attributes = [NSAttributedStringKey.font: UIFont(name: MotivFont.boldFont, size: CGFloat(size + offset))]
        let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
        return attributedText
    }
    
    public static func getRegularText(text: String, size: Int) -> NSMutableAttributedString {
        let offset = MotivFont.offset()
        let attributes = [NSAttributedStringKey.font: UIFont(name: MotivFont.boldFont, size: CGFloat(size + offset))]
        let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
        return attributedText
    }
    
    // change color in label with attributed string
    public static func  ChangeColorOnAttributedStringFromLabel(label: UILabel, color: UIColor) {
        let att = NSMutableAttributedString(attributedString: label.attributedText!)
        att.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: att.length))
        label.attributedText = att
    }
    
}

class MotivAuxiliaryFunctions {
    
    static func ShadowOnView(view: UIView) {
        view.layer.shadowColor = MotivColors.WoortiBlackT3.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 0.0
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 4.0
    }
    
    static func BorerOnView(uiview: UIView) {
        uiview.layer.borderWidth = CGFloat(0.25)
        uiview.layer.borderColor = UIColor.black.cgColor
    }
    
    static func gradientOnView(view: UIView) {
        let gradient = CAGradientLayer()
        var bounds = CGRect(x: view.bounds.minX, y: view.bounds.minY, width: view.bounds.width, height: 10)
        gradient.frame = bounds
        gradient.colors = [UIColor.gray.withAlphaComponent(CGFloat(0.3)).cgColor, UIColor.white.withAlphaComponent(CGFloat(0.3)).cgColor]
        
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    public static func loadStandardButton(button: UIButton, bColor: UIColor, tColor: UIColor, key: String, comment: String, boldText: Bool, size: Int, disabled: Bool, border: Bool = false, borderColor: UIColor = UIColor.white, CompleteRoundCorners: Bool = false) {
        let text = NSLocalizedString(key, comment: comment)
        loadStandardButton(button: button, bColor: bColor, tColor: tColor, text: text, boldText: boldText, size: size, disabled: disabled, border: border, borderColor: borderColor, CompleteRoundCorners: CompleteRoundCorners)
    }
    
    public static func loadStandardButton(button: UIButton, bColor: UIColor, tColor: UIColor, text: String, boldText: Bool, size: Int, disabled: Bool, border: Bool = false, borderColor: UIColor = UIColor.white, CompleteRoundCorners: Bool = false) {
        
        if disabled {
            button.backgroundColor = bColor.withAlphaComponent(0.6)
        } else {
            button.backgroundColor = bColor
        }
        button.tintColor = tColor
        button.layer.masksToBounds = true
        if CompleteRoundCorners {
            button.layer.cornerRadius = button.bounds.height * 0.5
        } else {
            button.layer.cornerRadius = button.bounds.height * 0.25
        }
        
        if border {
            button.layer.borderWidth = CGFloat(1)
            button.layer.borderColor = borderColor.cgColor
        }
        
//        button.setTitle(text, for: .normal)
        if boldText {
            MotivFont.motivBoldFontFor(text: text, button: button, size: size)
        } else {
            MotivFont.motivRegularFontFor(text: text, button: button, size: size)
        }
    }
    
    static func imagedNamedToBackground(name: String, view: UIView) {
        if let image = UIImage(named: name) {
            MotivAuxiliaryFunctions.imageToBackground(image: MotivAuxiliaryFunctions.resizeImage(image: image, bounds: view.bounds), view: view)
        }
    }
    
    static func resizeImage(image: UIImage, bounds: CGRect) -> UIImage {
        
//        let scale = newWidth / image.size.width
//        let newHeight = image.size.height * scale
//        UIGraphicsBeginImageContext(CGSize(width: bounds.width, height: bounds.height))
        UIGraphicsBeginImageContextWithOptions(CGSize(width: bounds.width, height: bounds.height), true, image.scale)
//        image.drawInRect(CGRect(0, 0, bounds.width, bounds.height))
        
        // //Resize and Draw
        //.resizableImage(withCapInsets: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), resizingMode: .stretch)
        let size = image.size
        let heightEdge = bounds.height - size.height
        let widthEdge = bounds.width - size.width
        
        image.draw(in: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        
//        image.resizableImage(withCapInsets: UIEdgeInsets(top: heightEdge/2, left: widthEdge/2, bottom: heightEdge/2, right: widthEdge/2), resizingMode: .stretch).draw(in: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    static func imageToBackground(image: UIImage, view: UIView) {
        view.backgroundColor = UIColor(patternImage: image)
    }
    
    static func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func resizeImageToMaxSize(image: UIImage, maxSize: CGFloat) -> UIImage {
        var newWidth = CGFloat(0)
        var newHeight = CGFloat(0)
        if image.size.height > image.size.width {
            newHeight = maxSize
            let scale = newHeight / image.size.height
            newWidth = image.size.width * scale
        } else {
            newWidth = maxSize
            let scale = newWidth / image.size.width
            newHeight = image.size.height * scale
        }
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func RoundView(view: UIView, CompleteRoundCorners: Bool = false){
        if Thread.isMainThread {
            view.layer.masksToBounds = true
            if CompleteRoundCorners {
                view.layer.cornerRadius = view.bounds.height * 0.5
            } else {
    //            view.layer.cornerRadius = view.bounds.height * 0.2
                view.layer.cornerRadius = min(15, view.bounds.height * 0.25)
            }
    //        view.layer.borderWidth = 1
    //        view.layer.borderColor = UIColor(red: 0.9, green: 0.89, blue: 0.89, alpha: 1).cgColor
    //        view.layer.shadowOffset = CGSize(width: 0, height: 2)
    //        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.18).cgColor
    //        view.layer.shadowOpacity = 1
    //        view.layer.shadowRadius = 4
        } else {
            DispatchQueue.main.sync {
                RoundView(view: view, CompleteRoundCorners: CompleteRoundCorners)
            }
        }
    }
}

class MotivStringsGen {
    static let instance = MotivStringsGen()
    //WoortiSignInV2ViewController
    let Start_Now = NSLocalizedString("Start_Now", value: "Start Now", comment: "splash screen start now button message")
    let Log_In = NSLocalizedString("Log_In", value: "Log In", comment: "splash screen start now button message")
    
    //WoortiSignInOrRegisterViewController
    let Log_In_With_Google = NSLocalizedString("Log_In_With_Google", value: "Log in with Google", comment: "login with google button message")
    let Register = NSLocalizedString("Register", value: "Register", comment: "register button message")
    let User_Already_Signed_In = NSLocalizedString("User_Already_Signed_In", value:  "It seems that %@ has already signed-in. Shall we log you in?", comment: "error shown to the user when registering with a already signed in email account")
    let Passwords_Dont_Match = NSLocalizedString("Passwords_Dont_Match", value: "Register", comment: "register button message")
    let Email = NSLocalizedString("Email", value: "email", comment: "email message")
    let Password = NSLocalizedString("Password", value: "password", comment: "password message")
    let Not_Filled = NSLocalizedString("Not_Filled" , value: "%@ not filled", comment: "%@ not filled")
    let Sign_In = NSLocalizedString("Sign_In", value: "Sign In", comment: "sign in button message")
    let Welcome_Back = NSLocalizedString("Welcome_Back", value: "Welcome Back", comment: "title that appears on the top of the login page")
    let Enter_Your_Email_Address = NSLocalizedString("Enter_Your_Email_Address", value: "Enter your email address", comment: "placeholder for email in login/register")
    let Enter_Your_Password = NSLocalizedString("Enter_Your_Password", value: "Enter your password", comment: "placeholder for password in login/register")
    let Enter_Your_Password_Again = NSLocalizedString("Enter_Your_Password_Again", value: "Enter your password Again", comment: "placeholder for password when registering only")
    let Forgot_Your_Password = NSLocalizedString("Forgot_Your_Password", value: "Forgot your Password?", comment: "placeholder for password when registering only")
    let Didnt_sign_up_yet = NSLocalizedString("Didnt_sign_up_yet", value: "Forgot your Password?", comment: "placeholder for password when registering only")
    let Error_Log_In = NSLocalizedString("Error_Log_In", value: "There was an error in loggin in. Please try again or reset your password.", comment: "error shown to the user when log in failed")
    
    //ResetPWDViewController
    let Youve_Got_Mail = NSLocalizedString("Youve_Got_Mail", value: "you've got mail!", comment: "you've got mail!")
    let Forgot_Password = NSLocalizedString("Forgot_Password", value: "you've got mail!", comment: "Forgot Password")
    let Reset_Password = NSLocalizedString("Reset_Password", value: "Reset Password", comment: "Reset Password")
    let Email_Has_Been_Sent = NSLocalizedString("Email_Has_Been_Sent", comment: "message shown when clcicking to reset a password message: If %@ has an account with Woorti, you will be receiving an email to reset your password")
    let Back_To_Login = NSLocalizedString("Back_To_Login", value: "BACK TO LOGIN", comment: "message: BACK TO LOGIN")
    let No_Worries_Message = NSLocalizedString("No_Worries_Message", value: "No worries! Enter your email address below and we will send you a email to reset your password.", comment: "message: No worries! Enter your email address below and we will send you a email to reset your password.")
    
    //OnboardingViewController
    let Next = NSLocalizedString("Next", value: "Next", comment: "message text of \"Next\" button message: Next")
    let First_Onboarding_Screen_Welcome_Title = NSLocalizedString("First_Onboarding_Screen_Welcome_Title", value: "Your travel time is an important part of your life!", comment: "message: Your travel time is an important part of your life!")
    let First_Onboarding_Screen_Welcome_Description_Text = NSLocalizedString("First_Onboarding_Screen_Welcome_Description_Text", value: "Did you know that a person spends about 2 years of her whole life commuting?\n\nWoorti will help you explore your travel time!", comment: "message: Did you know that a person spends about 2 years of her whole life commuting?\n\nWoorti will help you explore your travel time!")
    
    //WoortiHelpAProjectViewController
    let Second_Onboarding_Screen_Help_Reseach_Title =  NSLocalizedString("Second_Onboarding_Screen_Help_Reseach_Title", value: "Didn't sign-up yet? Press here", comment: "didn't sign up yet message in the login page")
    let Second_Onboarding_Screen_Help_Reseach_Description =  NSLocalizedString("Second_Onboarding_Screen_Help_Reseach_Description", value: "With the information you provide, Woorti will gather knowledge for better transport solutions and share it with researchers, transport operators and local authorities around Europe.", comment: "message: With the information you provide, Woorti will gather knowledge for better transport solutions and share it with researchers, transport operators and local authorities around Europe.")
    let Second_Onboarding_Screen_Help_Reseach_Check_Out_Site =  NSLocalizedString("Second_Onboarding_Screen_Help_Reseach_Check_Out_Site", value: "Check out %@ for more information", comment: "message: Check out %@ for more information")
    
    //OnboardingTopAndContentViewController
    let What_Is_A_Worthwhile_Trip = NSLocalizedString("What_Is_A_Worthwhile_Trip", value: "What is a worthwhile trip", comment: "title for the first onboarding page message: What is a worthwhile trip")
    let Data_Protection = NSLocalizedString("Data_Protection", value: "Data Protection", comment: "title for the first onboarding pages message: Data Protection")
    let Permissions = NSLocalizedString("Permissions", value: "Permissions", comment: "title for the first onboarding pages message: Permissions")
    let A_Little_About_You = NSLocalizedString("A_Little_About_You", value: "A Little About You", comment: "title for the info pages message: A Little About You")
    
    //OnBoardLanguageViewController
    let Change_Language = NSLocalizedString("Change_Language", value: "Change Language", comment: "change language screen title message: Change Language ")
    
    //FirstOnBoardingViewController
    let Third_Onboarding_Screen_Description = NSLocalizedString("Third_Onboarding_Screen_Description", value: "While some like to study or work when they travel, others like to relax and disconnect. Some take the opportunity to exercise. While others jumpstart their day with music.", comment: "message: While some like to study or work when they travel, others like to relax and disconnect. Some take the opportunity to exercise. While others jumpstart their day with music.")
    
    //SecondOnBoardingViewController
    let Fourth_Onboarding_Screen_Description = NSLocalizedString("Fourth_Onboarding_Screen_Description", value: "Everyone defines what is a worthwhile travel time in his or her different way.\n\nLet's see what that means to you!", comment: "message: Everyone defines what is a worthwhile travel time in his or her different way.\n\nLet's see what that means to you!")
    let Proceed_To_Productivity = NSLocalizedString("Proceed_To_Productivity", value: "Proceed to Productivity", comment: "proceed to productivity button message: Proceed to Productivity")
    
    //ProdMindBodyScreensViewController
    let Productivity = NSLocalizedString("Productivity", value: "Productivity", comment: "message: Productivity")
    let Productivity_Worthwhile_Description_Score = NSLocalizedString("Productivity_Worthwhile_Description_Score", value: "Using travel time to get things done, not only for work or study, but also personal things like managing home or family stuff…", comment: "message: Using travel time to get things done, not only for work or study, but also personal things like managing home or family stuff…")
    let Proceed_To_Enjoyment = NSLocalizedString("Proceed_To_Enjoyment", value: "Proceed to Enjoyment", comment: "message: Proceed to Enjoyment")
    
    let Enjoyment = NSLocalizedString("Enjoyment", value: "Enjoyment", comment: "message: Enjoyment")
    let Enjoyment_Worthwhile_Description_Score = NSLocalizedString("Enjoyment_Worthwhile_Description_Score", value: "Relaxing or having fun; taking time to listen to music, rest or meditate; engaging in social media; observing the surroundings…", comment: "message: Relaxing or having fun; taking time to listen to music, rest or meditate; engaging in social media; observing the surroundings…")
    let Proceed_To_Fitness = NSLocalizedString("Proceed_To_Fitness", value: "Proceed to Fitness", comment: "message: Proceed to Fitness")
    
    let Fitness = NSLocalizedString("Fitness", value: "Fitness", comment: "message: Fitness")
    let Fitness_Worthwhile_Description_Score = NSLocalizedString("Fitness_Worthwhile_Description_Score", value: "When you walk, cycle, or even run on your travels, you’re getting exercise and staying in shape.", comment: "message: When you walk, cycle, or even run on your travels, you’re getting exercise and staying in shape.")
    let Now_You = NSLocalizedString("Now_You", value: "NOW YOU!", comment: "message: NOW YOU!")
    
    //MeasureWorthwilenessOnboardingViewController
    let Productivity_Worthwhile_Low_Score = NSLocalizedString("Productivity_Worthwhile_Low_Score", value: "I don’t work when I travel", comment: "message: I don’t work when I travel")
    let Productivity_Worthwhile_High_Score = NSLocalizedString("Productivity_Worthwhile_High_Score", value: "I used my  trip to get stuff done!", comment: "message: I used my  trip to get stuff done!")
    
    let Enjoyment_Worthwhile_Low_Score = NSLocalizedString("FitnesEnjoyment_Worthwhile_Low_Scores", value: "message: Travelling is not at all relaxing", comment: "message: message: Travelling is not at all relaxing")
    let Enjoyment_Worthwhile_High_Score = NSLocalizedString("Enjoyment_Worthwhile_High_Score", value: "When I travel, \nI chill", comment: "message: When I travel, \nI chill")
    
    let Fitness_Worthwhile_Low_Score = NSLocalizedString("Fitness_Worthwhile_Low_Score", value: "Exercise is in the gym/field", comment: "message: Exercise is in the gym/field")
    let Fitness_Worthwhile_High_Score = NSLocalizedString("Fitness_Worthwhile_High_Score", value: "Travel time is a great way to feel the burn", comment: "message: Travel time is a great way to feel the burn")
    
    let Rate_Worthwhileness_Screen_Title = NSLocalizedString("Rate_Worthwhileness_Screen_Title", value: "How important are the travel time worthwhileness elements for you, when you travel?", comment: "message: How important are the travel time worthwhileness elements for you, when you travel?")
    
    //RegularModesOfTRansportOnboardingViewController
    let Regualr_Modes_Of_Transport_Title = NSLocalizedString("Regualr_Modes_Of_Transport_Title", value: "Which modes of transport do you use regularly?", comment: "message: Which modes of transport do you use regularly?")
    
    let Public_Transport = NSLocalizedString("Public_Transport", value: "Public Transport", comment: "message: Public Transport")
    let Active_Semi_active = NSLocalizedString("Active_Semi_active", value: "Active/Semi-active", comment: "message: Active/Semi-active")
    let Private_Motirized = NSLocalizedString("Private_Motirized", value: "Private Motirized", comment: "message: Private Motirized")
    
    //ProductiveRelaxingValuesViewController
    let Rating_Prefered_Mot_Prod_Title = NSLocalizedString("Rating_Prefered_Mot_Prod_Title", value: "How productive are you when you travel by:", comment: "message: How productive are you when you travel by:")
    let Not_Productive = NSLocalizedString("Not_Productive", value: "Not Productive", comment: "rating prefered modes of transport message: Not Productive")
    let Productive = NSLocalizedString("Productive", value: "Productive", comment: "rating prefered modes of transport message: Productive")
    
    let Rating_Prefered_Mot_Enj_Title = NSLocalizedString("Rating_Prefered_Mot_Enj_Title", value: "How much enjoyment do you get from your your travel time by:", comment: "message: How much enjoyment do you get from your your travel time by:")
    let Not_Enjoying = NSLocalizedString("Not_Enjoying", value: "Not Enjoying", comment: "rating prefered modes of transport message: Not Enjoying")
    let Enjoying = NSLocalizedString("Enjoying", value: "Enjoying", comment: "rating prefered modes of transport message: Enjoying")
    
    let Rating_Prefered_Mot_Fit_Title = NSLocalizedString("Rating_Prefered_Mot_Fit_Title", value: "How does your travel time contribute to your fitness when you travel by:", comment: "message: How does your travel time contribute to your fitness when you travel by:")
    let Improves_My_Fitness = NSLocalizedString("Improves_My_Fitness", value: "Improves my fitness", comment: "rating prefered modes of transport message: Improves my fitness")
    let Doesnt_Improve_My_Fitness = NSLocalizedString("Doesnt_Improve_My_Fitness", value: "Doesn't improve my fitness", comment: "rating prefered modes of transport message: Doesn't improve my fitness")
    
    //GDPRAcceptanceViewController
    let GRPD_Description = NSLocalizedString("GRPD_Description", value: "For the European MoTiV project research on travel time, this app collects anonymised data on:\n1. Your trips (time, location and transport used)\n2. Your expressed preferences and searches within the app", comment: "message: For the European MoTiV project research on travel time, this app collects anonymised data on:\n1. Your trips (time, location and transport used)\n2. Your expressed preferences and searches within the app")
    let GRPD_Accept = NSLocalizedString("GRPD_Accept", value: "I accept MoTiV data protection conditions", comment: "message: I accept MoTiV data protection conditions")
    let GRPD_Read_Policy = NSLocalizedString("GRPD_Read_Policy", value: "MoTiV privacy policy is compliant with EU GDPR. Read More", comment: "message: MoTiV privacy policy is compliant with EU GDPR. Read More")
    
    //OnboardingPermissionsViewController
    let Ok_Cool = NSLocalizedString("Ok_Cool", value: "Ok cool", comment: "message: Ok cool")
    let Ask_location_permission_String = NSLocalizedString("Ask_location_permission_String", value: "Thanks! To record your trips we need your permission to let Woorti access to your location at all times.\n\nIt should not excessively consume your battery.", comment: "message: Thanks! To record your trips we need your permission to let Woorti access to your location at all times.\n\nIt should not excessively consume your battery.")
    let Ask_notification_permission_String = NSLocalizedString("Ask_notification_permission_String", value: "Lastly, we will be asking you questions regarding your experiences as you travel. Your opinion really matters to us! \n\n To do this we need to be able to send you notifications", comment: "message: Lastly, we will be asking you questions regarding your experiences as you travel. Your opinion really matters to us! \n\n To do this we need to be able to send you notifications")
    let Ask_location_permission_String_when_user_has_denied = NSLocalizedString("Ask_location_permission_String_when_user_has_denied", value: "Sorry! For Woorti to function properly we really need that you allow it to access your location at all times.", comment: "message: Sorry! For Woorti to function properly we really need that you allow it to access your location at all times.")
    
    //OnboardingWhatsYourNameViewController
    let What_Is_Your_Name = NSLocalizedString("What_Is_Your_Name", value: "What is your name?", comment: "message: What is your name?")
    let Enter_Your_Name = NSLocalizedString("Enter_Your_Name", value: "Enter your name", comment: "name Placeholder message: Enter your name")
    
    //WhereDoYouLiveOnboardViewController
    let Where_Do_You_Live = NSLocalizedString("Where_Do_You_Live", value: "Where do you live?", comment: "message: Where do you live?")
    
    //ChooseYourAgeViewController
    let What_Is_Your_Age = NSLocalizedString("What_Is_Your_Age", value: "What is your age?", comment: "message: What is your age?")
    
    
    //STATIC INFO TO SEND TO SERVER
    //INFO KEYS
    //ChooseGenderViewController
    let Male = "Male"
    let Female = "Female"
    let Other = "Other"
    let Gender = NSLocalizedString("Gender", value: "Gender", comment: "message: Gender")
    
    //Educational
    let Education_Basic = "Basic (up to 10th grade)"
    let Education_High = "High school (12th grade)"
    let Education_University = "University"
    
    //Marital Status
    let Marital_Single = "Single"
    let Marital_Married = "Married"
    let Marital_SO = "Significant other"
    let Marital_Partnership = "Registered partnership"
    let Marital_Divorced = "Divorced"
    let Marital_Widowed = "Widowed"
    
    //Labour Status
    let Labour_Student = "Student"
    let Labour_Full_Time = "Employed full Time"
    let Labour_Part_Time = "Employed part-time"
    let Labour_Unemployed = "Unemployed"
    let Labour_Pensioner = "Pensioner"
    
    //Years of residence
    let Years_Less_One = "Less than 1"
    let Years_One_To_Five = "1 to 5"
    let Years_More_Five = "More than 5"
    
    //my trips home work
    let Do_You_Want_To_Set_This_Location_Home = NSLocalizedString("Do_You_Want_To_Set_This_Location_Home", value: "Do you wish to set the destination location of this trip as your home address in your private Profile?\nThis will improve your experience with Woorti.", comment: "message: Do you wish to set the destination location of this trip as your home address in your private Profile?\nThis will improve your experience with Woorti.")
    let Do_You_Want_To_Set_This_Location_Work = NSLocalizedString("Do_You_Want_To_Set_This_Location_Work", value: "Do you wish to set the destination location of this trip as your work address in your private Profile?\nThis will improve your experience with Woorti.", comment: "message: Do you wish to set the destination location of this trip as your work address in your private Profile?\nThis will improve your experience with Woorti.")
    private init() {}
    
    func getCodedToReadableInfo(info: String) -> String {
        switch info {
            
        //Gender
        case self.Male:
            return NSLocalizedString("Male", comment: "")
        case self.Female:
            return NSLocalizedString("Female",comment: "")
        case self.Other:
            return NSLocalizedString("Other",comment: "")
            
        //Education
        case self.Education_Basic:
            return NSLocalizedString("Education_Basic",comment: "")
        case self.Education_High:
            return NSLocalizedString("Education_Highschool",comment: "")
        case self.Education_University:
            return NSLocalizedString("Education_University",comment: "")
            
        //Marital
        case self.Marital_Single:
            return NSLocalizedString("Marital_Single",comment: "")
        case self.Marital_Married:
            return NSLocalizedString("Marital_Married",comment: "")
        case self.Marital_Divorced:
            return NSLocalizedString("Marital_Divorced",comment: "")
        case self.Marital_Partnership:
            return NSLocalizedString("Marital_Partnership",comment: "")
        case self.Marital_Widowed:
            return NSLocalizedString("Marital_Widowed",comment: "")
            
        //Labour
        case self.Labour_Student:
            return NSLocalizedString("Labour_Student",comment: "")
        case self.Labour_Full_Time:
            return NSLocalizedString("Labour_Employed_Full_Time",comment: "")
        case self.Labour_Part_Time:
            return NSLocalizedString("Labour_Employed_Part_Time",comment: "")
        case self.Labour_Unemployed:
            return NSLocalizedString("Labour_Unemployed",comment: "")
        case self.Labour_Pensioner:
            return NSLocalizedString("Labour_Pensioner",comment: "")
            
        //Residence
        case self.Years_Less_One:
            return NSLocalizedString("Years_Residence_Less_Than_One",comment: "")
        case self.Years_One_To_Five:
            return NSLocalizedString("Years_Residence_One_To_Five",comment: "")
        case self.Years_More_Five:
            return NSLocalizedString("Years_Residence_More_Than_Five",comment: "")
            
            
        default:
            return info
        }
    }
    
    static func getInstance() -> MotivStringsGen {
        return instance
    }
}
