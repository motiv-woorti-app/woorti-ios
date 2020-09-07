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
 * Table cell with a selectable campaign.
 */
class ChooseCampaignTableViewCell: UITableViewCell {

    @IBOutlet weak var CheckBoxImage: UIImageView!
    
    @IBOutlet weak var titleCampaign: UILabel!
    @IBOutlet weak var bodyCampaign: UILabel!
    
    var isCampaignSelected = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectThisCampaign()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadCampaign(title: String, body: String) {
        MotivFont.motivBoldFontFor(text: title, label: self.titleCampaign, size: 15)
        self.titleCampaign.textColor = MotivColors.WoortiOrange
        MotivFont.motivBoldFontFor(text: body, label: self.bodyCampaign, size: 15)
        self.CheckBoxImage.tintColor = MotivColors.WoortiOrange
    }
    
    func selectThisCampaign() -> Bool {
        isCampaignSelected = !isCampaignSelected
        if isCampaignSelected {
            CheckBoxImage.image = UIImage(named: "baseline_check_box_black_18dp")
            self.titleCampaign.textColor = MotivColors.WoortiOrange
            self.CheckBoxImage.tintColor = MotivColors.WoortiOrange
//            self.bodyCampaign.textColor = UIColor.black
            
        } else {
            CheckBoxImage.image = UIImage(named: "baseline_check_box_outline_blank_black_18dp")
            self.titleCampaign.textColor = MotivColors.WoortiOrange
            self.CheckBoxImage.tintColor = MotivColors.WoortiOrange
//            self.titleCampaign.textColor = UIColor(red: 0.59, green: 0.59, blue: 0.59, alpha: 1)
//            self.bodyCampaign.textColor = UIColor(red: 0.59, green: 0.59, blue: 0.59, alpha: 1)
            
        }
        return isCampaignSelected
    }

}
