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

class StarRatingView: UIView {
    
//    @IBOutlet weak var ViewWidthConstraint: NSLayoutConstraint!
//    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    var part: FullTripPart?
    var productive = false
    
    enum Images: String {
        case ic_star_white
        case ic_star_border_white
    }

    @IBOutlet weak var TypeOfRating: UILabel!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    
    var buttons = [UIButton]()
    var selectedValue = Double(0)
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        buttons.append(star1)
//        buttons.append(star2)
//        buttons.append(star3)
//        buttons.append(star4)
//        buttons.append(star5)
//        refreshView()
//        // Do any additional setup after loading the view.
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    
    func printImageOnButton(button: UIButton, image: Images) {
        let image = UIImage(named: image.rawValue)?.withRenderingMode(.alwaysTemplate)
        button.tintColor = UIColor.black
        button.setImage(image, for: .normal)
    }
    
    func refreshView() {
        for star in buttons {
            if Double(buttons.index(of: star) ?? buttons.count) >= selectedValue {
                printImageOnButton(button: star, image: Images.ic_star_border_white)
            } else {
                printImageOnButton(button: star, image: Images.ic_star_white)
            }
        }
    }
    
//    func getValueSelected() -> Double {
//        return self.selectedValue
//    }
    
    fileprivate func setMotPredefinedValue(_ mot: MotSettings) {
        var selectedValue = Double(-1)
        if self.productive {
            selectedValue = mot.motsProd
        } else {
            selectedValue = mot.motsRelax
        }
        
        switch selectedValue {
        case 0...20 :
            selectedValue = 1
            break
        case 20...40 :
            selectedValue = 2
            break
        case 40...60 :
            selectedValue = 3
            break
        case 60...80 :
            selectedValue = 4
            break
        case 80...100 :
            selectedValue = 5
            break
        default:
            break
        }
        
        if selectedValue > Double(-1) {
            self.selectedValue = selectedValue
        }
    }
    
    fileprivate func loadPredefinedValues() {
        if self.selectedValue < 1 {
            if let leg = self.part as? Trip,
                let user = MotivUser.getInstance() {
                //                    let modeOfTransport = leg.correctedModeOfTransport ?? leg.modeOfTransport ?? ""
                let preferedMots = user.preferedMots.allObjects as! [MotSettings]
                for mot in preferedMots {
                    switch mot.mot {
                    case Double(0): //Bus/Tram
                        if leg.getFinalModeOfTRansport() == Trip.modesOfTransport.Bus.rawValue {
                            setMotPredefinedValue(mot)
                        }
                        break
                    case Double(1): //metro/LightRail
                        if leg.getFinalModeOfTRansport() == Trip.modesOfTransport.Subway.rawValue {
                            setMotPredefinedValue(mot)
                        }
                        break
                    case Double(2): //Bycicle/BikeSharing
                        if leg.getFinalModeOfTRansport() == Trip.modesOfTransport.cycling.rawValue {
                            setMotPredefinedValue(mot)
                        }
                        break
                    case Double(3): //walking
                        if leg.getFinalModeOfTRansport() == Trip.modesOfTransport.walking.rawValue {
                            setMotPredefinedValue(mot)
                        }
                        break
                    case Double(4): //taxi/uber
                        break
                    case Double(5): //train
                        if leg.getFinalModeOfTRansport() == Trip.modesOfTransport.Train.rawValue {
                            setMotPredefinedValue(mot)
                        }
                        break
                    case Double(6): //Ferry
                        if leg.getFinalModeOfTRansport() == Trip.modesOfTransport.Ferry.rawValue {
                            setMotPredefinedValue(mot)
                        }
                        break
                    case Double(7): //motorcycle
                        break
                    case Double(8): //car/carSharing
                        if leg.getFinalModeOfTRansport() == Trip.modesOfTransport.Car.rawValue {
                            setMotPredefinedValue(mot)
                        }
                        break
                    default:
                        break
                    }
                }
                
            } else if let we = self.part as? WaitingEvent {
                
            }
        }
    }
    
    func loadView(text: String, productive: Bool, part: FullTripPart){
        self.part = part
        self.productive = productive
        if productive {
            self.selectedValue = part.productivityScore
        } else {
            self.selectedValue = part.relaxingScore
        }
        loadPredefinedValues()
        
        buttons.append(star1)
        buttons.append(star2)
        buttons.append(star3)
        buttons.append(star4)
        buttons.append(star5)
        refreshView()
        TypeOfRating.text = text
    }
    
    func setValue(score: Double){
        if productive {
            part?.productivityScore = score
        } else {
            part?.relaxingScore = score
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: RateTripViewController.Callback.ShowCDFactorsRatings.rawValue), object: nil, userInfo: ["part": self.part!, "productive": self.productive])
    }
    
    @IBAction func star1Click(_ sender: Any) {
        if self.selectedValue != Double(1) {
            self.selectedValue = Double(1)
            setValue(score: self.selectedValue)
            refreshView()
        }
    }
    @IBAction func star2Click(_ sender: Any) {
        if self.selectedValue != Double(2) {
            self.selectedValue = Double(2)
            setValue(score: self.selectedValue)
            refreshView()
        }
    }
    @IBAction func star3Click(_ sender: Any) {
        if self.selectedValue != Double(3) {
            self.selectedValue = Double(3)
            setValue(score: self.selectedValue)
            refreshView()
        }
    }
    @IBAction func star4Click(_ sender: Any) {
        if self.selectedValue != Double(4) {
            self.selectedValue = Double(4)
            setValue(score: self.selectedValue)
            refreshView()
        }
    }
    @IBAction func star5Click(_ sender: Any) {
        if self.selectedValue != Double(5) {
            self.selectedValue = Double(5)
            setValue(score: self.selectedValue)
            refreshView()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
