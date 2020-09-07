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

class UnvalidatedConfirmModeTableViewCell: UITableViewCell {
    
    private var leg: Trip?
    public var parentView: MTConfirmModesViewController?
    
    @IBOutlet weak var ModeOfTransportAndDistance: UILabel!
    @IBOutlet weak var MOTImage: UIImageView!
    @IBOutlet weak var AutoDetected: UILabel!
    @IBOutlet weak var QuetionLabel: UILabel!
    @IBOutlet weak var HoursLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var topViewForShadow: UIView!
    
    func loadCell(leg: Trip, parentTableView: MTConfirmModesViewController, disabled: Bool) {
        self.leg = leg
        self.parentView = parentTableView
        
        if disabled {
            noButton.isUserInteractionEnabled = false
            yesButton.isUserInteractionEnabled = false
        }
        
        MotivAuxiliaryFunctions.ShadowOnView(view: self.topViewForShadow)
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.width * 0.1
        

        if [Trip.modesOfTransport.walking.rawValue,Trip.modesOfTransport.running.rawValue].contains(leg.getFinalModeOfTRansport()) {
            MotivFont.motivRegularFontFor(text: "\(leg.getTextModeToShow()) \(Int(leg.distance))m", label: self.ModeOfTransportAndDistance, size: 15)
        } else {
            let distanceKm = String(format: "%.1fkm", leg.distance / 1000.0)
            MotivFont.motivRegularFontFor(text: "\(leg.getTextModeToShow()) " + distanceKm, label: self.ModeOfTransportAndDistance, size: 15)
        }
        
        if leg.modeOfTransport == (leg.correctedModeOfTransport ?? leg.modeOfTransport) {

            MotivFont.motivRegularFontFor(text: "", label: self.AutoDetected, size: 12)
        } else {

            MotivFont.motivRegularFontFor(text: "", label: self.AutoDetected, size: 12)
        }

        
        print("corrected: \(leg.correctedModeOfTransport ?? "") detected: \(leg.modeOfTransport ?? "") data: \(leg.getTextModeToShow())")
        
        let didYouGoBy = NSLocalizedString("Did_You_Go_The_Mode", comment: "message: Did you go by %@ ?")
        let wereYou = NSLocalizedString("Were_You_Walking_Or_Running", comment: "message: were you %@ ?")
        
        switch leg.getTextFromRealMotCode()?.lowercased() ?? leg.correctedModeOfTransport?.lowercased() ?? leg.modeOfTransport?.lowercased() ?? "" {
            case ActivityClassfier.UNKNOWN.lowercased() :
//                self.setImage(icon: IconImageCollectionViewCell.motIcons.baseline_adjust_black)
                MotivFont.motivBoldFontFor(text: String(format: didYouGoBy, leg.getTextModeToShow()), label: self.QuetionLabel, size: 15)
            case ActivityClassfier.CAR.lowercased(), ActivityClassfier.AUTOMOTIVE.lowercased() :
//                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_car_black)
                MotivFont.motivBoldFontFor(text: String(format: didYouGoBy, leg.getTextModeToShow()), label: self.QuetionLabel, size: 15)
            case ActivityClassfier.BUS.lowercased() :
//                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_bus_black)
                MotivFont.motivBoldFontFor(text: String(format: didYouGoBy, leg.getTextModeToShow()), label: self.QuetionLabel, size: 15)
            case ActivityClassfier.CYCLING.lowercased(), "bicycle" :
//                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_bike_black)
                MotivFont.motivBoldFontFor(text: String(format: didYouGoBy, leg.getTextModeToShow()), label: self.QuetionLabel, size: 15)
            case ActivityClassfier.WALKING.lowercased() :
//                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_walk_black)
                MotivFont.motivBoldFontFor(text: String(format: wereYou, leg.getTextModeToShow()), label: self.QuetionLabel, size: 15)
            case ActivityClassfier.RUNNING.lowercased() :
//                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_walk_black)
                MotivFont.motivBoldFontFor(text: String(format: wereYou, leg.getTextModeToShow()), label: self.QuetionLabel, size: 15)
            case ActivityClassfier.STATIONARY.lowercased() :
//                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_railway_black)
                MotivFont.motivBoldFontFor(text: String(format: didYouGoBy, leg.getTextModeToShow()), label: self.QuetionLabel, size: 15)
            case ActivityClassfier.TRAM.lowercased() :
//                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_railway_black)
                MotivFont.motivBoldFontFor(text: String(format: didYouGoBy, leg.getTextModeToShow()), label: self.QuetionLabel, size: 15)
            case ActivityClassfier.TRAIN.lowercased() :
//                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_railway_black)
                MotivFont.motivBoldFontFor(text: String(format: didYouGoBy, leg.getTextModeToShow()), label: self.QuetionLabel, size: 15)
            case ActivityClassfier.METRO.lowercased(), "metro" :
//                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_railway_black)
                MotivFont.motivBoldFontFor(text: String(format: didYouGoBy, leg.getTextModeToShow()), label: self.QuetionLabel, size: 15)
            case ActivityClassfier.FERRY.lowercased() :
//                self.setImage(icon: IconImageCollectionViewCell.motIcons.directions_boat_black)
                MotivFont.motivBoldFontFor(text: String(format: didYouGoBy, leg.getTextModeToShow()), label: self.QuetionLabel, size: 15)
            default:
//                self.setImage(icon: IconImageCollectionViewCell.motIcons.baseline_adjust_black)
                MotivFont.motivBoldFontFor(text: String(format: didYouGoBy, leg.getTextModeToShow()), label: self.QuetionLabel, size: 15)
        }
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: QuetionLabel, color: MotivColors.WoortiBlack)
        
        self.setImage(image: leg.getImageModeToShow())
        
//        self.HoursLabel.text = UtilityFunctions.getHourMinuteFromDate(date: leg.startDate)
        MotivFont.motivRegularFontFor(text: UtilityFunctions.getHourMinuteFromDate(date: leg.startDate), label: self.HoursLabel, size: 15)
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.noButton, bColor: MotivColors.WoortiRed, tColor: UIColor.white, key: "No", comment: "No button", boldText: true, size: 15, disabled: false)
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.yesButton, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Yes", comment: "Yes button", boldText: true, size: 15, disabled: false)
        
//        GenericQuestionTableViewCell.loadStandardButton(button: self.noButton, color: GenericQuestionTableViewCell.RedButtonColor, text: "NO", disabled: false)
//        GenericQuestionTableViewCell.loadStandardButton(button: self.yesButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "YES", disabled: false)
    }
    
    @IBAction func ConfirmModeOftransport(_ sender: Any) {
//        self.leg!.realMot = MotivUser.getInstance()!.getMotFromText(text: self.leg!.modeOfTransport!)
//        self.leg!.correctedModeOfTransport = self.leg!.modeOfTransport
        if self.leg!.correctedModeOfTransport == nil {
           self.leg!.correctedModeOfTransport = self.leg!.modeOfTransport
        }
        
        self.leg!.modeConfirmed = true
        self.leg?.answerMode()
        DispatchQueue.main.async {
            self.parentView?.updateValidated()
        }
    }
    
    @IBAction func ChangeModeOfTransport(_ sender: Any) {

//        self.leg!.modeConfirmed = true
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTConfirmModesViewController.callbacks.MTChooseConfirmModeStartCarrousell.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(correctedModeOfTRansport), name: NSNotification.Name(rawValue: MTConfirmModesViewController.callbacks.MTChooseConfirmModeEndCarrousell.rawValue), object: nil)
    }
    
    @objc func correctedModeOfTRansport(_ notification: NSNotification){
        if let mot = notification.userInfo?["mot"] as? motToCell {
            self.leg?.correctedModeOfTransport = mot.strMode
            self.leg?.correctedModeCode = Double(mot.mode)
            self.leg?.realMot = Double(mot.mode)
            self.leg?.otherMotText = mot.otherValue
            self.leg?.modeConfirmed = true
            self.leg?.answerMode()
            DispatchQueue.main.async {
                self.parentView?.updateValidated()
            }
        } else if let motText = notification.userInfo?["mot"] as? String,
            let mot = motToCell.getMotFromText(text: motText) {
            
            self.leg?.correctedModeOfTransport = mot.strMode
            self.leg?.correctedModeCode = Double(mot.mode)
            self.leg?.realMot = Double(mot.mode)
            self.leg?.otherMotText = mot.otherValue
            self.leg?.modeConfirmed = true
            self.leg?.answerMode()
            DispatchQueue.main.async {
                self.parentView?.updateValidated()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

    }

    func setImage(icon: IconImageCollectionViewCell.motIcons){
        self.MOTImage.image = UIImage(named: icon.rawValue)
        self.MOTImage.tintColor = UIColor.black
    }
    
    func setImage(image: UIImage){
        self.MOTImage.image = image
    }
}
