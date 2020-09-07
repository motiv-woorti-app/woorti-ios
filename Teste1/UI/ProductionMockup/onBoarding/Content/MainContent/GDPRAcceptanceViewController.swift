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
 * Onboarding view regarding GDPR, user must accept the terms.
 */
class GDPRAcceptanceViewController: GenericViewController {

    @IBOutlet weak var contentPage: UIView!
    @IBOutlet weak var acceptanceView: UIView!
    @IBOutlet weak var topTextView: UITextView!
    @IBOutlet weak var lbliAccept: UILabel!
    @IBOutlet weak var lblprivacypolicy: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var image: UIImageView!
    
    var agreeed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let gestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(agree))
        let gestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(agree))

        image.addGestureRecognizer(gestureRecognizer1)
        lbliAccept.addGestureRecognizer(gestureRecognizer2)
        image.isUserInteractionEnabled = true
        lbliAccept.isUserInteractionEnabled = true
        
        let readMeGR = UITapGestureRecognizer(target: self, action: #selector(loadReadMe))
        lblprivacypolicy.addGestureRecognizer(readMeGR)
        

        self.view.backgroundColor = UIColor.clear
        
        MotivFont.motivRegularFontFor(key: "GRPD_Description",comment: "message: For the European MoTiV project research on travel time, this app collects anonymised data on:\n1. Your trips (time, location and transport used)\n2. Your expressed preferences and searches within the app", tv: self.topTextView, size: 13)
        
        let grpd = MotivFont.getRegularText(text: NSLocalizedString("GRPD_Description", comment: "message: For the European MoTiV project research on travel time, this app collects anonymised data on:\n1. Your trips (time, location and transport used)\n2. Your expressed preferences and searches within the app"), size: 13)
        grpd.addAttribute(.foregroundColor, value: UIColor.gray, range: NSRange(location: 0,length: grpd.length))
        self.topTextView.attributedText = grpd
        
        MotivFont.motivBoldFontFor(key: "GRPD_Accept",comment: "message: I accept MoTiV data protection conditions", label: self.lbliAccept, size: 16)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: lbliAccept, color: MotivColors.WoortiOrange)
        
        MotivFont.motivRegularFontFor(key: "GRPD_Read_Policy",comment: "message: MoTiV privacy policy is compliant with EU GDPR. Read More", label: self.lblprivacypolicy, size: 16)
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.nextButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Next" , comment: "message text of \"Next\" button message: Next", boldText: true, size: 17, disabled: !agreeed, CompleteRoundCorners: true)
        
        MotivAuxiliaryFunctions.RoundView(view: contentPage)
        
        loadImageForSelection()
        
        PowerManagementModule.GPSOnAppStart()
    }
    
    @objc func agree() {
        if agreeed {
            agreeed = false
            MotivAuxiliaryFunctions.loadStandardButton(button: self.nextButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Next" , comment: "message text of \"Next\" button message: Next", boldText: true, size: 17, disabled: !agreeed, CompleteRoundCorners: true)
            loadImageForSelection()
        } else {
            agreeed = true
            MotivAuxiliaryFunctions.loadStandardButton(button: self.nextButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Next" , comment: "message text of \"Next\" button message: Next", boldText: true, size: 17, disabled: !agreeed, CompleteRoundCorners: true)

            loadImageForSelection()
        }
    }
    
    @objc func loadReadMe() {
        let site = NSLocalizedString("Url_Privacy_Policy", comment: "") //"https://motivproject.eu/data-collection/data-protection.html"
        guard let url = URL(string: site) else {
            return
        }
        UIApplication.shared.open(url, options: [String : Any](), completionHandler: nil)
    }
    
    func loadImageForSelection() {
        if agreeed {
            self.image.image = UIImage(imageLiteralResourceName: "radio_button_checked_white").withRenderingMode(.alwaysTemplate)
            self.image.tintColor = MotivColors.WoortiOrange
        } else {
            self.image.image = UIImage(imageLiteralResourceName: "radio_button_unchecked_white").withRenderingMode(.alwaysTemplate)
            self.image.tintColor = MotivColors.WoortiOrange
        }
    }

    @IBAction func clickNext(_ sender: Any) {
        if agreeed {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: OnboardingTopAndContentViewController.OboardViews.OBVGOTOchangeToPermission.rawValue), object: nil)
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
