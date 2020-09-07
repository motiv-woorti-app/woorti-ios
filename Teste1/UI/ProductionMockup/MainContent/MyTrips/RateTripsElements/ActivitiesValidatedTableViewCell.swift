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

class ActivitiesValidatedTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    var part: FullTripPart?
    var images = [Images]()
    
    enum Images: String {
        case MTActivityCaringForSomeone
        case MTActivityCheckingEmail
        case MTActivityEatingDrinking
        case MTActivityExercising
        case MTActivityInternetBrowsing
        case MTActivityListenToAudioMedia
        case MTActivityObserveView
        case MTActivityOther
        case MTActivityPersonalCare
        case MTActivityPhoneCall
        case MTActivityPlayingGames
        case MTActivityReading
        case MTActivityRelaxingDoingNothing
        case MTActivitySleepingSnoozing
        case MTActivitySocialMedia
        case MTActivityTalkingToOthers
        case MTActivityTextMessages
        case MTActivityThinking
        case MTActivityVideo
        case MTActivityWriting
    }
    
    @IBOutlet weak var MOTImage: UIImageView!
    @IBOutlet weak var MOTAndDistance: UILabel!
    @IBOutlet weak var ValidatedP: UILabel!
    @IBOutlet weak var ValidatedPValue: UILabel!
    @IBOutlet weak var ValidatedMandP: UILabel!
    @IBOutlet weak var ValidatedMandPValue: UILabel!
    @IBOutlet weak var ValidatedBandH: UILabel!
    @IBOutlet weak var ValidatedBandHValue: UILabel!
    
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var ImagesCollectionView: UICollectionView!
    
    @IBOutlet weak var editButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.width * 0.1
        
        ImagesCollectionView.delegate = self
        ImagesCollectionView.dataSource = self
        
        MotivFont.motivRegularFontFor(text: "PRODUCTIVITY", label: self.ValidatedP, size: 11)
        MotivFont.motivRegularFontFor(text: "MIND & PLEASURE", label: self.ValidatedMandP, size: 11)
        MotivFont.motivRegularFontFor(text: "BODY & HEALTH", label: self.ValidatedBandH, size: 11)
        
        self.editButton.layer.cornerRadius = self.editButton.bounds.width * 0.1
        ImagesCollectionView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func loadCell(part: FullTripPart) {
        self.part = part
        if part.legUserActivities == nil {
            part.legUserActivities = [String]()
        }
        if part.legUserActivitiesType == nil {
            part.legUserActivitiesType = [Int]()
        }
        
        if let leg = self.part as? Trip {
//            self.MOTAndDistance.text = leg.getTextFromRealMotCode() ?? leg.correctedModeOfTransport ?? leg.modeOfTransport
            self.MOTAndDistance.text = leg.getTextModeToShow()
    //        if loaded {
    //            if  let prod = productiveStarView as? StarRatingView,
    //                let relax = relaxingStarView as? StarRatingView {
    //                prod.loadView(text: "Productivity", productive: true, leg: leg)
    //                relax.loadView(text: "Relaxing", productive: false, leg: leg)
    //            }
    //        }
            
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
            default:
                self.setImage(icon: IconImageCollectionViewCell.motIcons.baseline_adjust_black)
            }
        } else if let we = self.part as? WaitingEvent {
            self.MOTAndDistance.text = "Transfer"
            self.setImage(icon: IconImageCollectionViewCell.motIcons.baseline_shuffle_white)
        }
        
        self.TimeLabel.text = UtilityFunctions.getHourMinuteFromDate(date: part.startDate)
        
        self.images.removeAll()
        for activity in part.legUserActivities! {
//            let image = LegActivities.images[LegActivities.activitiesCodeText.index(of: activity)!]
            let index = (part.legUserActivities?.index(of: activity))!
            if (part.legUserActivitiesType?.count)! <= index {
                part.legUserActivities?.remove(at: index)
            } else {
                let type = part.legUserActivitiesType![index]
                let arrays = LegActivities.getArrays(type: ActivitySelect.type(rawValue: type)!, modeOfTRansport: part.getModeOftransport())
                if arrays.0.contains(activity) {
                    let image = arrays.1[arrays.0.index(of: activity)!]
                    self.images.append(Images(rawValue: image)!)
                } else {
                    let image = arrays.1[arrays.0.index(of: LegActivities.ActivityCodeForOther)!]
                    self.images.append(Images(rawValue: image)!)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.ImagesCollectionView.reloadData()
        }
    }
    
    func setImage(icon: IconImageCollectionViewCell.motIcons){
        self.MOTImage.image = UIImage(named: icon.rawValue)
        self.MOTImage.tintColor = UIColor.black
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.ImagesCollectionView.dequeueReusableCell(withReuseIdentifier: "ActivityImageCollectionViewCell", for: indexPath) as! ActivityImageCollectionViewCell
        cell.setImage(icon: self.images[indexPath.item])
        return cell
    }
    
    @objc func addActivity(_ notification: NSNotification) {
        if let activity = notification.userInfo?["activity"] as? String,
            let type = notification.userInfo?["type"] as? Int {
            let arrays = LegActivities.getArrays(type: ActivitySelect.type(rawValue: type)!, modeOfTRansport: part!.getModeOftransport())
            let image = arrays.1[arrays.0.index(of: activity) ?? arrays.0.index(of: LegActivities.ActivityCodeForOther)!]
            
            let indexOfActivity = self.part!.legUserActivities!.index(of: activity)
            
            if  self.part!.legUserActivities!.contains(activity)
                &&
                self.part!.legUserActivities![indexOfActivity ?? 0] == activity
                &&
                self.part!.legUserActivitiesType![indexOfActivity ?? 0] == type {
                ///////////////////////////////////////
                self.images.remove(at: self.images.index(of: Images(rawValue: image)!)!)
                self.part!.legUserActivities?.remove(at: indexOfActivity!)
                self.part!.legUserActivitiesType?.remove(at: indexOfActivity!)
                if self.images.count == 0 {
                    self.backgroundColor = UIColor.white
                    self.ImagesCollectionView.backgroundColor = UIColor.white
                }
            } else {
                self.images.append(Images(rawValue: image)!)
                self.part!.legUserActivities?.append(activity)
                self.part!.legUserActivitiesType?.append(type)
//                self.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
//                self.ImagesCollectionView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
            }
            DispatchQueue.main.async {
                self.ImagesCollectionView.reloadData()
            }
        }
    }
    
    @objc func endActivityFilling() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func addActivities(_ sender: Any) {
//        let info = images.map { $0.rawValue }
//
//        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTActivitiesViewController.callbacks.MTChooseActivitiesStart.rawValue), object: nil, userInfo: ["activity": info])
//
//        NotificationCenter.default.addObserver(self, selector: #selector(addActivity(_:)), name: NSNotification.Name(rawValue: MTActivitiesViewController.callbacks.MTChooseActivitiesAddActivity.rawValue), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(endActivityFilling), name: NSNotification.Name(rawValue: MTActivitiesViewController.callbacks.MTChooseActivitiesEnd.rawValue), object: nil)

        var type = ActivitySelect.type.productivity
        let info = part?.legUserActivities ?? [String]()
        let types = part?.legUserActivitiesType ?? [Int]()
        
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTActivitiesViewController.callbacks.MTChooseActivitiesStart.rawValue), object: nil, userInfo: ["activity": info, "activityTypes": types, "type": type])
        
        NotificationCenter.default.addObserver(self, selector: #selector(addActivity(_:)), name: NSNotification.Name(rawValue: MTActivitiesViewController.callbacks.MTChooseActivitiesAddActivity.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endActivityFilling), name: NSNotification.Name(rawValue: MTActivitiesViewController.callbacks.MTChooseActivitiesEnd.rawValue), object: nil)
    }
}
