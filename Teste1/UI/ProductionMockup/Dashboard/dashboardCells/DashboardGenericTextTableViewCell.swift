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
import EzPopup

/*
 * Dashboard cell to show co2/calories information. 
 */

class DashboardGenericTextTableViewCell: UITableViewCell {
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var ImageLabel: UIImageView!
    @IBOutlet weak var InfoButton: UIImageView!
    
    
    public enum CellType : String {
        case CALORIES
        case CO2
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadCell(text: NSMutableAttributedString, image: UIImage?, cellType: CellType) {
        MotivFont.motivAttributedFontFor(attributedText: text, label: descLabel)
        descLabel.textColor = UIColor.white
        
        if let image = image {
            ImageLabel.image = image.withRenderingMode(.alwaysTemplate) 
            ImageLabel.tintColor = UIColor.white
        }
        
        ImageLabel.isUserInteractionEnabled = true
        
        self.InfoButton.isHidden = true
        
        switch cellType {
        case CellType.CALORIES:
            let clickCalories = UITapGestureRecognizer(target: self, action: #selector(goToCalories))
            self.ImageLabel.addGestureRecognizer(clickCalories)
            break
        case CellType.CO2:
            let clickCo2 = UITapGestureRecognizer(target: self, action: #selector(goToCo2))
            self.ImageLabel.addGestureRecognizer(clickCo2)
            self.InfoButton.isHidden = false
            self.InfoButton.isUserInteractionEnabled = true
            let clickInfo = UITapGestureRecognizer(target: self, action: #selector(openInfoBalloon))
            self.InfoButton.addGestureRecognizer(clickInfo)
            break
        default:
            break
        }
        
        
    }
    
    @objc func goToCalories() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: DashboardViewController.GoToOptions.CaloriesSpentInTravel.rawValue), object: nil)
    }
    
    @objc func goToCo2() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: DashboardViewController.GoToOptions.Co2SpentInTravel.rawValue), object: nil)
    }
    
    @objc func openInfoBalloon() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: DashboardViewController.GoToOptions.Co2Info.rawValue), object: nil)
    }
    
    
    
    
}
