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

/*
 * Dashboard popup to explain co2 stats. 
 */
class Co2InfoPopup: GenericViewController {
    
    @IBOutlet weak var MainView: UIView!
    @IBOutlet var ContainerView: UIView!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var InfoLabel: UILabel!
    @IBOutlet weak var TipLabel: UILabel!
    @IBOutlet weak var LinkLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ContainerView.backgroundColor = UIColor.clear

        self.ImageView.image = UIImage(named: "co2_icon")!
        
        
        MotivFont.motivBoldFontFor(text: NSLocalizedString("What_Is_The_Carbon_Budget", comment: ""), label: TitleLabel, size: 16)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: TitleLabel, color: MotivColors.WoortiOrange)
        
        var  infoText = NSLocalizedString("The_Carbon_Budget_Is", comment: "")
        infoText = infoText.replacingOccurrences(of: "\\n", with: "\n")
        
        MotivFont.motivBoldFontFor(text: infoText, label: InfoLabel, size: 14)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: InfoLabel, color: MotivColors.WoortiBlackT1)
        
        MotivFont.motivBoldFontFor(text: NSLocalizedString("CO2_Budget_Example", comment: ""), label: TipLabel, size: 13)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: TipLabel, color: MotivColors.WoortiBlackT2)
        
        MotivFont.motivRegularFontFor(text: NSLocalizedString("CO2_Budget_Link_Text", comment: ""), label: LinkLabel, size: 12, underlined: true)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: LinkLabel, color: MotivColors.WoortiBlackT2)
        LinkLabel.isUserInteractionEnabled = true
        let gestureLink = UITapGestureRecognizer(target: self, action: #selector(openLink))
        LinkLabel.addGestureRecognizer(gestureLink)
        
        
        makeViewRound(view: MainView)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ClosePopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  UseTripForViewController.oberserverOptions.goToNext.rawValue), object: nil)
    }
    
    @objc func openLink() {
        print("Dashboard_CO2, clicked link")
        let site = "https://motivproject.eu/data-collection/woorti-app-faqs.html"
        guard let url = URL(string: site) else {
            return
        }
        UIApplication.shared.open(url, options: [String : Any](), completionHandler: nil)
    }
    
    
    func makeViewRound(view :UIView){
        view.layer.masksToBounds = true
        view.layer.cornerRadius = view.bounds.width * 0.05
    }
    
    
}

