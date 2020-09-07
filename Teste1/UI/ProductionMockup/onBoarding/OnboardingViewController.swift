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

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var TopImageView: UIImageView!
    @IBOutlet weak var langImage: UIImageView!
    @IBOutlet weak var LanguageContainer: UIView!
    @IBOutlet weak var BoxView: UIView!
    @IBOutlet weak var WelcomeTextView: UILabel!
    @IBOutlet weak var DescriptionText: UITextView!
    @IBOutlet weak var NextButton: UIButton!
    @IBOutlet weak var langLabel: UILabel!
    @IBOutlet weak var backimageView: UIImageView!
    private var optionSelected = OnboardingTopAndContentViewController.options.language

    @IBOutlet weak var titleView: UIView!
    
    func loadNextButton() {
        MotivAuxiliaryFunctions.loadStandardButton(button: self.NextButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Next" , comment: "message text of \"Next\" button message: Next", boldText: true, size: 15, disabled: false, CompleteRoundCorners: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //load back
//        self.view.backgroundColor = MotivColors.WoortiOrange
        MotivAuxiliaryFunctions.imagedNamedToBackground(name: "Orange_BG_Extended", view: self.view)
        // load box
        MotivAuxiliaryFunctions.RoundView(view: self.BoxView)
        MotivAuxiliaryFunctions.RoundView(view: self.LanguageContainer, CompleteRoundCorners: true)
        self.LanguageContainer.backgroundColor = MotivColors.WoortiOrangeT1
        //load welcome text
        MotivFont.motivBoldFontFor(key: "First_Onboarding_Screen_Welcome_Title", comment: "message: Your travel time is an important part of your life!", label: self.WelcomeTextView, size: 15)
//        MotivFont.motivBoldFontFor(text: "Your travel time is an important part of your life!", label: self.WelcomeTextView, size: 15)
        self.WelcomeTextView.textColor = MotivColors.WoortiOrange
        //load description text
        MotivFont.motivRegularFontFor(key: "First_Onboarding_Screen_Welcome_Description_Text", comment: "message: Did you know that a person spends about 2 years of her whole life commuting?\n\nWoorti will help you explore your travel time!", tv: self.DescriptionText, size: 15)
        
        //load Button
        self.loadNextButton()
        //load language
        let ChangeLanguageGR = UITapGestureRecognizer(target: self, action: #selector(changeLanguage))
        
        LanguageContainer.addGestureRecognizer(ChangeLanguageGR)
        let currentLang = Locale.preferredLanguages.first!
        MotivFont.motivRegularFontFor(text: currentLang, label: self.langLabel, size: 15)
        self.langLabel.textColor = UIColor.white
        langImage.tintColor = MotivColors.WoortiOrangeT3
        
        MotivAuxiliaryFunctions.ShadowOnView(view: self.titleView)
        
        self.backimageView.tintColor = UIColor.white
        let gr = UITapGestureRecognizer(target: self, action: #selector(back))
        self.backimageView.addGestureRecognizer(gr)
        backimageView.image = backimageView.image?.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        UserDefaults.
//        Bundle.main.localizations.filter({ $0 != "Base" })
//        Locale.current.languageCode
//        Bundle.main.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case "StartOnboarding":
            if let language = segue.destination as? OnboardingTopAndContentViewController {
                language.option = self.optionSelected
            }
        default:
            break
        }
    }
    
//    @IBAction func nextStartOnboarding(_ sender: Any) {
//        optionSelected = OnboardingTopAndContentViewController.options.onboarding
//        self.performSegue(withIdentifier: "StartOnboarding", sender: nil)
//    }
    
    @objc func changeLanguage(){
        optionSelected = OnboardingTopAndContentViewController.options.language
        self.performSegue(withIdentifier: "StartOnboarding", sender: nil)
    }
}
