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

class ActivitiesUnvalidatedTableViewCell: UITableViewCell {
    
    var part: FullTripPart?
//    var images = [Images]()
    @IBOutlet weak var validatedLabel: UILabel!
    //    let Icons = ["😴","📖","","","","","","",""]
    
//    enum Images: String {
//        case baseline_adjust_black
//        case baseline_place_black
//    }
    
    @IBOutlet weak var ProductivityView: UIView!
    @IBOutlet weak var MindView: UIView!
    @IBOutlet weak var BodyView: UIView!

//    @IBOutlet weak var AddActivitiesButton: UIButton!
//    @IBOutlet weak var ImagesCollectionView: UICollectionView!
    
    @IBOutlet weak var ModeOfTransportAndDistance: UILabel!
    @IBOutlet weak var MOTImage: UIImageView!
    @IBOutlet weak var TimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        AddActivitiesButton.tintColor = UIColor.black
//    AddActivitiesButton.setImage(AddActivitiesButton.currentImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.width * 0.1
//        StartActivitiesRecognizer.delegate = self
        
        let StartProductionActivitiesRecognizer = UITapGestureRecognizer(target: self, action: #selector(startAddingActivities(gesture:)))
        self.ProductivityView.addGestureRecognizer(StartProductionActivitiesRecognizer)
        let StartMindActivitiesRecognizer = UITapGestureRecognizer(target: self, action: #selector(startAddingActivities(gesture:)))
        self.MindView.addGestureRecognizer(StartMindActivitiesRecognizer)
        let StartBodyActivitiesRecognizer = UITapGestureRecognizer(target: self, action: #selector(startAddingActivities(gesture:)))
        self.BodyView.addGestureRecognizer(StartBodyActivitiesRecognizer)
    }
    
//    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        return true
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return images.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = self.ImagesCollectionView.dequeueReusableCell(withReuseIdentifier: "ActivityImageCollectionViewCell", for: indexPath) as! ActivityImageCollectionViewCell
//        cell.setImage(icon: self.images[indexPath.item])
//        return cell
//    }
    
    func loadCell(part: FullTripPart) {
        self.part = part
        if part.legUserActivities == nil {
            part.legUserActivities = [String]()
        }
        if part.legUserActivitiesType == nil {
            part.legUserActivitiesType = [Int]()
        }
        
        if let leg = self.part as? Trip {
//            self.ModeOfTransportAndDistance.text = leg.getTextFromRealMotCode() ?? leg.correctedModeOfTransport ?? leg.modeOfTransport
            self.ModeOfTransportAndDistance.text = leg.getTextModeToShow()
            
//            self.TripRating.text = "VALIDATED PRODUCTIVITY \(leg.productivityScore) RELAXING \(leg.relaxingScore)"
            
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
//            self.TripRating.text = "VALIDATED PRODUCTIVITY \(we.productivityScore) RELAXING \(we.relaxingScore)"
            self.setImage(icon: IconImageCollectionViewCell.motIcons.baseline_shuffle_white)
        }
        
        self.TimeLabel.text = UtilityFunctions.getHourMinuteFromDate(date: part.startDate)
        
//        self.images.removeAll()
//        for activity in part.legUserActivities! {
//            let image = LegActivities.images[LegActivities.activitiesCodeText.index(of: activity)!]
//            self.images.append(Images(rawValue: image)!)
//        }
//
//        DispatchQueue.main.async {
//            self.ImagesCollectionView.reloadData()
//        }
    }
    
    func setImage(icon: IconImageCollectionViewCell.motIcons){
        self.MOTImage.image = UIImage(named: icon.rawValue)
        self.MOTImage.tintColor = UIColor.black
    }

    @objc func addActivity(_ notification: NSNotification) {
        if let activity = notification.userInfo?["activity"] as? String,
            let type = notification.userInfo?["type"] as? Int {
            if let indexOfRemoval = self.part!.legUserActivities!.index(of: activity),
                self.part!.legUserActivities![indexOfRemoval] == activity
                &&
                self.part!.legUserActivitiesType![indexOfRemoval] == type {
//                self.images.remove(at: self.images.index(of: Images(rawValue: image)!)!)
                
                self.part!.legUserActivities?.remove(at: indexOfRemoval)
                self.part!.legUserActivitiesType?.remove(at: indexOfRemoval)
                    
//                if self.images.count == 0 {
//                    self.backgroundColor = UIColor.white
//                    self.ImagesCollectionView.backgroundColor = UIColor.white
//                }
            } else {
//                self.images.append(Images(rawValue: image)!)
                self.part!.legUserActivities?.append(activity)
                self.part!.legUserActivitiesType?.append(type)
                self.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
//                self.ImagesCollectionView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
            }
//            DispatchQueue.main.async {
//                self.ImagesCollectionView.reloadData()
//            }
        }
    }

    @objc func endActivityFilling() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func startAddingActivities(gesture: UITapGestureRecognizer) {
        var type = ActivitySelect.type.productivity
        switch gesture.view {
        case self.ProductivityView:
            type = ActivitySelect.type.productivity
            break
        case self.MindView:
            type = ActivitySelect.type.mind
            break
        case self.BodyView:
            type = ActivitySelect.type.body
            break
        default:
            break
        }
        
        //        let info = images.map { $0.rawValue }
        let info = part?.legUserActivities ?? [String]()
        let types = part?.legUserActivitiesType ?? [Int]()
        
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTActivitiesViewController.callbacks.MTChooseActivitiesStart.rawValue), object: nil, userInfo: ["activity": info, "activityTypes": types, "type": type])
        
        NotificationCenter.default.addObserver(self, selector: #selector(addActivity(_:)), name: NSNotification.Name(rawValue: MTActivitiesViewController.callbacks.MTChooseActivitiesAddActivity.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endActivityFilling), name: NSNotification.Name(rawValue: MTActivitiesViewController.callbacks.MTChooseActivitiesEnd.rawValue), object: nil)
    }
}
