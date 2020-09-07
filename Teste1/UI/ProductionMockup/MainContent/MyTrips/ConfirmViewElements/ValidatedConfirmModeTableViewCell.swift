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

class ValidatedConfirmModeTableViewCell: UITableViewCell {

    public var leg: Trip?
    
    @IBOutlet weak var ModeOfTransportAndDistance: UILabel!
    @IBOutlet weak var MOTImage: UIImageView!
    @IBOutlet weak var AutoDetected: UILabel!
    @IBOutlet weak var QuetionLabel: UILabel!
//    @IBOutlet weak var PointsLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func loadCell(leg: Trip, disabled: Bool) {
        self.leg = leg
//        self.ModeOfTransportAndDistance.text = leg.getTextModeToShow()
//        MotivFont.motivBoldFontFor(text: leg.getTextModeToShow(), label: self.ModeOfTransportAndDistance, size: 15)
        if leg.modeOfTransport == (leg.correctedModeOfTransport ?? leg.modeOfTransport) {
            self.AutoDetected.text = ""
//            MotivFont.motivBoldFontFor(text: "Auto Detected", label: self.AutoDetected, size: 15)
        } else {
//            self.AutoDetected.text = "Corrected"
//            MotivFont.motivBoldFontFor(text: "Corrected", label: self.AutoDetected, size: 15)
        }
        
        if [Trip.modesOfTransport.walking.rawValue,Trip.modesOfTransport.running.rawValue].contains(leg.getFinalModeOfTRansport()) {
            MotivFont.motivBoldFontFor(text: "\(leg.getTextModeToShow()) \(Int(leg.distance))m", label: self.ModeOfTransportAndDistance, size: 15)
        } else {
            let distanceKm = String(format: "%.1fkm", leg.distance / 1000.0)
            MotivFont.motivBoldFontFor(text: "\(leg.getTextModeToShow()) " + distanceKm, label: self.ModeOfTransportAndDistance, size: 15)
        }
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.ModeOfTransportAndDistance, color: MotivColors.WoortiOrangeT1)
        

        MotivFont.motivBoldFontFor(text: UtilityFunctions.getHourMinuteFromDate(date: leg.startDate), label: self.timeLabel, size: 15)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.timeLabel, color: MotivColors.WoortiOrangeT1)
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.width * 0.1
        

        let validated = NSLocalizedString("Validated", comment: "")
        MotivFont.motivRegularFontFor(text: "[\(validated)]", label: self.QuetionLabel, size: 13)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.QuetionLabel, color: MotivColors.WoortiOrangeT1)
        
        print("corrected: \(leg.correctedModeOfTransport ?? "") detected: \(leg.modeOfTransport ?? "")")
        
        switch leg.getMainTextFromRealMotCode()?.lowercased() ?? leg.correctedModeOfTransport?.lowercased() ?? leg.modeOfTransport?.lowercased() ?? "" {
        case ActivityClassfier.UNKNOWN.lowercased() :
            self.setImage(icon: IconImageCollectionViewCell.motIcons.baseline_adjust_black)
        case ActivityClassfier.CAR.lowercased(), ActivityClassfier.AUTOMOTIVE.lowercased() :
            self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_car_black)
        case ActivityClassfier.BUS.lowercased() :
            self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_bus_black)
        case ActivityClassfier.CYCLING.lowercased(), "bicycle" :
            self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_bike_black)
        case ActivityClassfier.WALKING.lowercased() :
            self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_walk_black)
        case ActivityClassfier.RUNNING.lowercased() :
            self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_walk_black)
        case ActivityClassfier.STATIONARY.lowercased() :
            self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_railway_black)
        case ActivityClassfier.TRAM.lowercased() :
            self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_railway_black)
        case ActivityClassfier.TRAIN.lowercased() :
            self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_railway_black)
        case ActivityClassfier.METRO.lowercased(), "metro" :
            self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_railway_black)
        case ActivityClassfier.FERRY.lowercased() :
            self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_boat_black)
        default:
            self.setImage(icon: IconImageCollectionViewCell.motIcons.baseline_adjust_black)
        }
        
        self.setImage(image: leg.getImageFadedModeToShow())
    }
    
    func setImage(icon: IconImageCollectionViewCell.motIcons){
        self.MOTImage.image = UIImage(named: icon.rawValue)
        self.MOTImage.tintColor = UIColor.black
    }
    
    
    func setImage(image: UIImage){
        self.MOTImage.image = image
    }
}
