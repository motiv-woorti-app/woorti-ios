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

/*
 * Controller to show information about Woorti's mission. 
 */
class WoortiHelpAProjectViewController: UIViewController {

    @IBOutlet weak var titleImage: UIImageView!
//    @IBOutlet weak var poweredbyImage: UIImageView!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var checkSiteLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var backimageView: UIImageView!
    @IBOutlet weak var titleView: UIView!
    private var optionSelected = OnboardingTopAndContentViewController.options.language
    let site = NSLocalizedString("Url_Privacy_Policy", comment: "")  //"https://motivproject.eu/data-collection/data-protection.html"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        MotivAuxiliaryFunctions.imagedNamedToBackground(name: "Orange_BG_Extended", view: self.view)
        
        //Load Images
        self.backimageView.tintColor = UIColor.white
        let gr = UITapGestureRecognizer(target: self, action: #selector(back))
        self.backimageView.addGestureRecognizer(gr)
        
        //Load content
        MotivAuxiliaryFunctions.RoundView(view: self.contentView)
        MotivFont.motivBoldFontFor(key: "Second_Onboarding_Screen_Help_Reseach_Title", comment: "message: Help research for better transport.", label: self.titleLabel, size: 17)
        
        self.titleLabel.textColor = MotivColors.WoortiOrange
        
        MotivFont.motivBoldFontFor(key: "Second_Onboarding_Screen_Help_Reseach_Description", comment: "message: With the information you provide, Woorti will gather knowledge for better transport solutions and share it with researchers, transport operators and local authorities around Europe.", tv: self.descTextView, size: 15)
        
//        let site = "https://motivproject.eu/data-collection/data-protection.html"
        let text = String(format: MotivStringsGen.getInstance().Second_Onboarding_Screen_Help_Reseach_Check_Out_Site, site)
        MotivFont.motivRegularFontFor(text: text, label: self.checkSiteLabel, size: 9, underlined: true, range: NSRange.init(location: 10, length: site.count))
        
        self.checkSiteLabel.isUserInteractionEnabled = true
        self.checkSiteLabel.isEnabled = true
        let sgr = UITapGestureRecognizer(target: self, action: #selector(openUrl))
        self.checkSiteLabel.addGestureRecognizer(sgr)
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.nextButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Next" , comment: "message text of \"Next\" button message: Next", boldText: true, size: 17, disabled: false, CompleteRoundCorners: true)
        MotivAuxiliaryFunctions.ShadowOnView(view: titleView)
        
        backimageView.image = backimageView.image?.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
    }
    
    
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func openUrl() {
        guard let url = URL(string: site) else {
            return
        }
        UIApplication.shared.open(url, options: [String : Any](), completionHandler: nil)
    }
    
    @IBAction func nextStartOnboarding(_ sender: Any) {
        optionSelected = OnboardingTopAndContentViewController.options.onboarding
        self.performSegue(withIdentifier: "StartOnboarding", sender: nil)
    }
    
    /* Navigation */
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

}
