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

class SMDRadioButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var StartImage: UIImageView!
    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var nextImage: UIImageView!
    private var selectedForMerge = false
    @IBOutlet weak var timeLabel: UILabel!
    
    var part: FullTripPart?
    
    func loadCell(part: FullTripPart) {
        self.part = part
        var lblText = ""
        if let leg = part as? Trip {
            lblText = leg.getMainTextFromRealMotCode() ?? leg.correctedModeOfTransport ?? leg.modeOfTransport ?? ""
            
            switch leg.getMainTextFromRealMotCode() ?? leg.correctedModeOfTransport ?? leg.modeOfTransport ?? "" {
            case ActivityClassfier.UNKNOWN :
                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_walk_black)
            case ActivityClassfier.CAR, ActivityClassfier.AUTOMOTIVE :
                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_car_black)
            case ActivityClassfier.BUS :
                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_bus_black)
            case ActivityClassfier.CYCLING :
                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_bike_black)
            case ActivityClassfier.WALKING :
                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_walk_black)
                lblText.append(" \(Int(leg.distance))m")
            case ActivityClassfier.RUNNING :
                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_walk_black)
            case ActivityClassfier.STATIONARY :
                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_railway_black)
            case ActivityClassfier.TRAIN :
                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_railway_black)
            case ActivityClassfier.TRAIN :
                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_railway_black)
            case ActivityClassfier.METRO :
                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_railway_black)
            case ActivityClassfier.FERRY :
                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_boat_black)
            default:
                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_walk_black)
            }
        } else if let we = part as? WaitingEvent {
            var lblText = "Transfer"
//            self.setImage(icon: SMDStartTableViewCell.Images.change)
            updateNextImage()
            self.StartImage.image = UIImage(named: SMDStartTableViewCell.Images.change.rawValue)
            self.StartImage.tintColor = UIColor.black
        }
        self.Label.text = lblText
        
        self.timeLabel.text = UtilityFunctions.getHourMinuteFromDate(date: part.startDate)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
    }
    
    func toggleSelect(){
        self.selectedForMerge = !self.selectedForMerge
        updateNextImage()
    }
    
    func isSelectedForMerge() -> Bool {
        return self.selectedForMerge
    }
    
    func updateNextImage(){
        if self.selectedForMerge {
            nextImage.image = UIImage(named: "radio_button_checked_white")?.withRenderingMode(.alwaysTemplate)
//            nextImage.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.09)
        } else {
            nextImage.image = UIImage(named: "radio_button_unchecked_white")?.withRenderingMode(.alwaysTemplate)
//            nextImage.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.09)
        }
        nextImage.tintColor = UIColor.black
    }
    
    func setImage(icon: IconImageCollectionViewCell.motIcons){
//        nextImage.image = nextImage.image?.withRenderingMode(.alwaysTemplate)
//        nextImage.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.09)
        updateNextImage()
        self.StartImage.image = UIImage(named: icon.rawValue)
        self.StartImage.tintColor = UIColor.black
    }
    
}
