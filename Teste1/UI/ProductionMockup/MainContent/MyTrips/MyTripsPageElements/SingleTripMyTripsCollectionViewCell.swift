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

class SingleTripMyTripsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var startLocationLabel: UILabel!
    @IBOutlet weak var StopLocationLabel: UILabel!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var PlaceImage: UIImageView!
    @IBOutlet weak var adJustImage: UIImageView!
    
    enum statusIcons: String {
        case check_black
        case error_black
    }
    
    var ft: FullTrip?
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var TopViewWithConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.PlaceImage.tintColor = UIColor(displayP3Red: CGFloat(221)/CGFloat(255), green: CGFloat(131)/CGFloat(255), blue: CGFloat(48)/CGFloat(255), alpha: CGFloat(1))
        self.adJustImage.tintColor = UIColor(displayP3Red: CGFloat(221)/CGFloat(255), green: CGFloat(131)/CGFloat(255), blue: CGFloat(48)/CGFloat(255), alpha: CGFloat(1))
        
        self.layer.backgroundColor = UIColor(displayP3Red: CGFloat(247)/CGFloat(255), green: CGFloat(230)/CGFloat(255), blue: CGFloat(208)/CGFloat(255), alpha: CGFloat(1)).cgColor
        self.layer.borderColor = UIColor(displayP3Red: CGFloat(247)/CGFloat(255), green: CGFloat(230)/CGFloat(255), blue: CGFloat(208)/CGFloat(255), alpha: CGFloat(1)).cgColor
        self.layer.borderWidth = CGFloat(5)
        self.layer.cornerRadius = self.bounds.height * 0.1
    }
    
    func setImage(icon: statusIcons){
        self.statusImageView.image = UIImage(named: icon.rawValue)
        self.statusImageView.tintColor = UIColor.black
    }
    
    private func writeLocations(location: CLLocation, start: Bool) {
        CLGeocoder().reverseGeocodeLocation(location) { (plc, e) in
            print("enter placemarks \(Date().description)")
            if let error = e as? Error {
                return
            } else if let placemarks = plc as? [CLPlacemark] {
                if placemarks.count > 0 {
                    if start {
                        print(" start coordinate \(location.coordinate.latitude) \(location.coordinate.longitude) \(placemarks.first!.thoroughfare ?? "") \(placemarks.first!.subThoroughfare ?? "")")
//                        self.startLocationLabel.text = "\(placemarks.first!.thoroughfare ?? "") \(placemarks.first!.subThoroughfare ?? "")"
                        MotivFont.motivBoldFontFor(text: "\(placemarks.first!.thoroughfare ?? "") \(placemarks.first!.subThoroughfare ?? "")", label: self.startLocationLabel, size: 14)
                        if self.startLocationLabel.text == " " {
//                            self.startLocationLabel.text = "\(placemarks.first!.name ?? "")"
                            MotivFont.motivBoldFontFor(text: "\(placemarks.first!.name ?? "")", label: self.startLocationLabel, size: 14)
                        }
                        
//                        self.startTimeLabel.text = UtilityFunctions.getHourMinuteFromDate(date: location.timestamp)
                        MotivFont.motivRegularFontFor(text: UtilityFunctions.getHourMinuteFromDate(date: location.timestamp), label: self.startTimeLabel, size: 11)
                        
                    } else {
                        print(" stop coordinate \(location.coordinate.latitude) \(location.coordinate.longitude) \(placemarks.first!.thoroughfare ?? "") \(placemarks.first!.subThoroughfare ?? "")")
//                        self.StopLocationLabel.text = "\(placemarks.first!.thoroughfare ?? "") \(placemarks.first!.subThoroughfare ?? "")"
                        MotivFont.motivBoldFontFor(text: "\(placemarks.first!.thoroughfare ?? "") \(placemarks.first!.subThoroughfare ?? "")", label: self.StopLocationLabel, size: 14)
                        if self.StopLocationLabel.text == " " {
//                            self.StopLocationLabel.text = "\(placemarks.first!.name ?? "")"
                            MotivFont.motivBoldFontFor(text: "\(placemarks.first!.name ?? "")", label: self.StopLocationLabel, size: 14)
                        }
                        
//                        self.endTimeLabel.text = UtilityFunctions.getHourMinuteFromDate(date: location.timestamp)
                        MotivFont.motivRegularFontFor(text: UtilityFunctions.getHourMinuteFromDate(date: location.timestamp), label: self.endTimeLabel, size: 11)
                    }
                }
            }
        }
    }
    
    func loadcell(width: CGFloat, ft: FullTrip) {
        TopViewWithConstraint.constant = width
        self.ft = ft
        
        if ft.confirmed {
            setImage(icon: .check_black)
        } else {
            setImage(icon: .error_black)
        }
        var startLocationText = ft.getStartLocation()
        var endLocationText = ft.getEndLocation()
        
        let firstLocation = ft.getFirstLocation()
        let endLocation = ft.getLastLocation()
        
        if startLocationText == "" && firstLocation != nil{
            startLocationText = "\(firstLocation!.coordinate.latitude)" + ", " + "\(firstLocation!.coordinate.longitude)"
        }
        
        if endLocationText == "" && endLocation != nil{
            endLocationText = "\(endLocation!.coordinate.latitude)" + ", " + "\(endLocation!.coordinate.longitude)"
        }

        
        MotivFont.motivBoldFontFor(text: startLocationText, label: self.startLocationLabel, size: 14)
        MotivFont.motivBoldFontFor(text: endLocationText, label: self.StopLocationLabel, size: 14)
        
        
        if let firstLocation = ft.getFirstLocation() {
            MotivFont.motivRegularFontFor(text: UtilityFunctions.getHourMinuteFromDate(date: firstLocation.timestamp), label: self.startTimeLabel, size: 11)
        }
        
        if let lastLocation = ft.getLastLocation() {
            MotivFont.motivRegularFontFor(text: UtilityFunctions.getHourMinuteFromDate(date: lastLocation.timestamp), label: self.endTimeLabel, size: 11)
        }
        
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        frame.size.width = ceil(size.width)
        layoutAttributes.frame = frame
        print("SingleTripMyTripsCollectionViewCell size: \(size.height) \(size.width) ceil: \(ceil(size.height)) \(ceil(size.width))")
        return layoutAttributes
    }
    
}
