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
import CoreLocation

class SingleTripCellTableViewCell: UITableViewCell {

    @IBOutlet weak var startLocationLabel: UILabel!
    @IBOutlet weak var StopLocationLabel: UILabel!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var PlaceImage: UIImageView!
    @IBOutlet weak var adJustImage: UIImageView!
    
    enum statusIcons: String {
        case ic_check_circle
        case ic_radio_button_unchecked
        case arrow_forward_ios_white
    }
    
    var selectableCell = false
    
    var ft: FullTrip?
    var wasSelected = false
    
    @IBOutlet weak var statusImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.PlaceImage.tintColor = MotivColors.WoortiOrange
//        self.adJustImage.tintColor = MotivColors.WoortiOrange
        
        self.layer.backgroundColor = UIColor.white.cgColor

        MotivAuxiliaryFunctions.RoundView(view: self)
        self.layer.borderWidth = CGFloat(5)
        self.layer.borderColor = MotivColors.WoortiOrangeT3.cgColor
        self.layer.cornerRadius = self.bounds.height * 0.1
    }
    
    func setImage(icon: statusIcons){
        
        switch icon {
        case .ic_check_circle:
            self.statusImageView.image = UIImage(named: "Confirmation")
        default:
            self.statusImageView.image = UIImage(named: icon.rawValue)?.withRenderingMode(.alwaysTemplate)
            self.statusImageView.tintColor = MotivColors.WoortiOrange
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadcell(ft: FullTrip, selectable: Bool, selected: Bool) {
        self.ft = ft
        
        self.selectableCell = selectable
        self.wasSelected = selected
        
        if self.selectableCell {
            if self.wasSelected {
                setImage(icon: .ic_check_circle)
            } else {
                setImage(icon: .ic_radio_button_unchecked)
            }
        } else {
            setImage(icon: .arrow_forward_ios_white)
        }
        
        self.startLocationLabel.text = ft.getStartLocation()
        self.StopLocationLabel.text = ft.getEndLocation()
        
        
        if let firstLocation = ft.getFirstLocation() {
            self.startTimeLabel.text = UtilityFunctions.getHourMinuteFromDate(date: firstLocation.timestamp)
        }
        
        if let lastLocation = ft.getLastLocation() {
            self.endTimeLabel.text = UtilityFunctions.getHourMinuteFromDate(date: lastLocation.timestamp)
        }
        
        //        writeLocations(location: self.ft!.getFirstLocation()!, start: true)
        //        writeLocations(location: self.ft!.getLastLocation()!, start: false)
        
        
    }
}
