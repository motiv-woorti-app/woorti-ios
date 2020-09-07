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

class RateUnvalidatedTableViewCell: UITableViewCell {
    
    var part: FullTripPart?

    @IBOutlet weak var ProductiveContainer: UIView!
    @IBOutlet weak var RelaxingContainer: UIView!
    @IBOutlet weak var validatedLabel: UILabel!
    
    @IBOutlet weak var ModeOfTransportAndDistance: UILabel!
    @IBOutlet weak var MOTImage: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    var productiveStarView: StarRatingView?
    var relaxingStarView: StarRatingView?
    
    var loaded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "StarRatingView", bundle: bundle)
        
//        if let productiveStarView = Bundle.main.loadNibNamed("StarRatingView", owner: self, options: nil)?.first as? StarRatingView {
        if let productiveStarView = nib.instantiate(withOwner: self, options: nil).first as? StarRatingView {
            
            productiveStarView.frame = ProductiveContainer.bounds
            ProductiveContainer.addSubview(productiveStarView)
//            productiveStarView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.productiveStarView = productiveStarView
//            productiveStarView.loadView(text: "Productivity", productive: true)
        }
//        if let relaxingStarView = Bundle.main.loadNibNamed("StarRatingView", owner: self, options: nil)?.first as? StarRatingView {

        if let relaxingStarView = nib.instantiate(withOwner: self, options: nil).first as? StarRatingView {
            relaxingStarView.frame = RelaxingContainer.bounds
            RelaxingContainer.addSubview(relaxingStarView)
//            relaxingStarView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.relaxingStarView = relaxingStarView
            
//            relaxingStarView.loadView(text: "Relaxing", productive: false)
        }
        
//        self.layer.borderColor = UIColor(displayP3Red: CGFloat(247)/CGFloat(255), green: CGFloat(230)/CGFloat(255), blue: CGFloat(208)/CGFloat(255), alpha: CGFloat(1)).cgColor
//        self.layer.borderWidth = CGFloat(5)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.width * 0.1
        
        loaded = true
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        if segue.identifier == "RelaxStarRating" {
//            if let relax = segue.destination as? StarRatingViewController {
//                self.RelaxingRating = relax
//                relax.loadView(text: "Relaxing")
//            }
//        } else if segue.identifier == "ProductivityStarRating" {
//            if let productivity = segue.destination as? StarRatingViewController {
//                self.Productivityrating = productivity
//                productivity.loadView(text: "Productivity")
//            }
//        }
//    }

    
    func loadCell(part: FullTripPart) {
        self.part = part
        if let leg = self.part as? Trip {
//            self.ModeOfTransportAndDistance.text = leg.getTextFromRealMotCode() ?? leg.correctedModeOfTransport ?? leg.modeOfTransport ?? ""
            self.ModeOfTransportAndDistance.text = leg.getTextModeToShow()
            if loaded {
                if  let prod = productiveStarView,
                    let relax = relaxingStarView {
                    prod.loadView(text: "Productivity", productive: true, part: leg)
                    relax.loadView(text: "Relaxing", productive: false, part: leg)
                }
            }
            
            self.timeLabel.text = UtilityFunctions.getHourMinuteFromDate(date: leg.startDate)
            
            switch leg.getTextFromRealMotCode() ?? leg.correctedModeOfTransport ?? leg.modeOfTransport ?? "" {
//            switch leg.getTextModeToShow() {
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
                self.setImage(icon: IconImageCollectionViewCell.motIcons.baseline_adjust_black)
            }
        } else if let we = self.part as? WaitingEvent {
            self.ModeOfTransportAndDistance.text = "Transfer"
            self.validatedLabel.text = ""
            if loaded {
                if  let prod = productiveStarView,
                    let relax = relaxingStarView {
                    prod.loadView(text: "Productivity", productive: true, part: we)
                    relax.loadView(text: "Relaxing", productive: false, part: we)
                }
            }
            self.setImage(icon: IconImageCollectionViewCell.motIcons.baseline_shuffle_white)
        }
    }
    
    func setImage(icon: IconImageCollectionViewCell.motIcons){
        self.MOTImage.image = UIImage(named: icon.rawValue)
        self.MOTImage.tintColor = UIColor.black
    }
}
