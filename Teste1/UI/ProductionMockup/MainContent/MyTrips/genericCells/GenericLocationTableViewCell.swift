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

class GenericLocationTableViewCell: UITableViewCell {
    @IBOutlet weak var StartImage: UIImageView!
    
    @IBOutlet weak var Information: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    
    enum Images: String {
        case Start = "Starting_Point_Fade"
        case Arrival = "Arrival_Point_Fade"
        case change = "Transfer_Fade"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        StartImage.image = StartImage.image?.withRenderingMode(.alwaysTemplate)
//        StartImage.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.09)
//        StartImage.tintColor = UIColor(displayP3Red: CGFloat(231)/CGFloat(255), green: CGFloat(168)/CGFloat(255), blue: CGFloat(94)/CGFloat(255), alpha: CGFloat(1))
        StartImage.tintColor = MotivColors.WoortiOrangeT1
    }
    
    func setImage(value: Images) {
        
        StartImage.image = UIImage(named: value.rawValue)?.withRenderingMode(.alwaysTemplate)
//        StartImage.tintColor = UIColor(displayP3Red: CGFloat(231)/CGFloat(255), green: CGFloat(168)/CGFloat(255), blue: CGFloat(94)/CGFloat(255), alpha: CGFloat(1))
        StartImage.tintColor = MotivColors.WoortiOrangeT1
    }
    
    func loadCell(image: Images, text: String, time: Date?) {
        setImage(value: image)
        Information.text = text
        if let date = time {
            self.TimeLabel.text = UtilityFunctions.getHourMinuteFromDate(date: date)
        } else {
            self.TimeLabel.text = ""
        }
        TimeLabel.textColor = MotivColors.WoortiOrangeT1
        Information.textColor = MotivColors.WoortiOrangeT1
        MotivAuxiliaryFunctions.RoundView(view: self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
