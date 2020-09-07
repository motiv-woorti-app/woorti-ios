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

class MytripsGenericMotTableViewCell: UITableViewCell {

    @IBOutlet weak var motImage: UIImageView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var firstLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var ContentView: UIView!
    
    var part: FullTripPart?
    var type = ChoosePartForFeedBackViewController.cells.Start
    
    enum Images: String {
        case Start = "Starting_Point_Fade"
        case Arrival = "Arrival_Point_Fade"
        case change = "Transfer_Fade"
        case directions_bike_black
        case directions_boat_black
        case directions_bus_black
        case directions_car_black
        case directions_railway_black
        case directions_walk_black
        case baseline_subway_black_18dp
        case baseline_airplanemode_active_black_18dp
        case baseline_adjust_black
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        MotivAuxiliaryFunctions.RoundView(view: self)
        self.backgroundColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadCell(image: Images, text: String, time: Date?, we: WaitingEvent? = nil) {
        setImage(value: image)
        MotivFont.motivBoldFontFor(text: text, label: secondLabel, size: 13)
        secondLabel.textColor = MotivColors.WoortiOrangeT1
        if let date = time {
            
            MotivFont.motivBoldFontFor(text: UtilityFunctions.getHourMinuteFromDate(date: date), label: firstLabel, size: 13)
            firstLabel.textColor = MotivColors.WoortiOrangeT1
        } else {
            self.firstLabel.text = ""
            self.firstLabelWidth.constant = 0
            firstLabel.textColor = MotivColors.WoortiOrangeT1
        }
    }
    
    public func setBackgroundToWhite() {
        contentView.backgroundColor = UIColor.white
    }
    
    func loadCell(part: FullTripPart) {
        self.part = part
        if let leg = part as? Trip {
            let image = leg.getImageFadedModeToShow()
            
            self.secondLabel.text = leg.getTextModeToShow()
            MotivFont.motivBoldFontFor(text: leg.getTextModeToShow(), label: secondLabel, size: 13)
            secondLabel.textColor = MotivColors.WoortiOrangeT1
            self.setImage(image: image)
            self.firstLabel.text = UtilityFunctions.getHourMinuteFromDate(date: leg.startDate)
            firstLabel.textColor = MotivColors.WoortiOrangeT1
            
            
        } else if let we = part as? WaitingEvent {
            let transfer = NSLocalizedString("Transfer", comment: "message: Transfer")
            loadCell(image: Images.change, text: transfer, time: we.startDate, we: we)
        }
    }
    
    func setImage(value: Images) {
        motImage.image = UIImage(named: value.rawValue)?.withRenderingMode(.alwaysTemplate)
        motImage.tintColor = MotivColors.WoortiOrangeT1
    }
    
    func setImage(image: UIImage) {
        motImage.image = image
    }
}
