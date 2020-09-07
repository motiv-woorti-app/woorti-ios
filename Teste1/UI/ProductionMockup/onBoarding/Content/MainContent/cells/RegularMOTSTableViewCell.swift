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

/*
 * Onboarding View to choose the user's preferred modes.
 */
class RegularMOTSTableViewCell: UITableViewCell {

    @IBOutlet weak var TitleText: UILabel!
    @IBOutlet weak var selectedSwitch: UISwitch!
    
    var mot: ModeOftransportState?
    @IBOutlet weak var motImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = MotivColors.WoortiOrangeT1
        reDraw()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func SwitchOnValueChanged(_ sender: Any) {
        let mots = MOTRegularityData.getInstance().mots
        self.mot?.selected = selectedSwitch.isOn
        if mots.count > 2 {
            if selectedSwitch.isOn {
                switch self.TitleText.text ?? "" {
                case mots[0].last?.0 ?? "++":
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: RegularModesOfTRansportOnboardingViewController.openPopup.OpenPublic.rawValue), object: nil)
                    break
                case mots[1].last?.0 ?? "++":
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: RegularModesOfTRansportOnboardingViewController.openPopup.OpenActive.rawValue), object: nil)
                    break
                case mots[2].last?.0 ?? "++":
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: RegularModesOfTRansportOnboardingViewController.openPopup.OpenPrivate.rawValue), object: nil)
                    break
                default:
                    break
        
                }
            }
        }
        reDraw()
    }
    
    func reDraw() {
        if self.selectedSwitch.isOn {
            MotivAuxiliaryFunctions.RoundView(view: selectedSwitch, CompleteRoundCorners: true)
            self.selectedSwitch.thumbTintColor = MotivColors.WoortiOrangeT1
            self.selectedSwitch.onTintColor = MotivColors.WoortiOrange
            self.selectedSwitch.backgroundColor = MotivColors.WoortiOrangeT2
            self.selectedSwitch.tintColor = MotivColors.WoortiOrangeT2
        } else {
            MotivAuxiliaryFunctions.RoundView(view: selectedSwitch, CompleteRoundCorners: true)
            self.selectedSwitch.thumbTintColor = MotivColors.WoortiOrangeT2
            self.selectedSwitch.onTintColor = MotivColors.WoortiOrange
            self.selectedSwitch.backgroundColor = MotivColors.WoortiOrangeT1
            self.selectedSwitch.tintColor = MotivColors.WoortiOrangeT1
        }
    }
    
    func loadCell(mot: ModeOftransportState) {
        self.mot = mot
        let text = NSLocalizedString(mot.mot.0, comment: "Mode Of Transport for \(mot.mot.0)")
        let image = mot.mot.1
        
        
        MotivFont.motivRegularFontFor(text: text, label: self.TitleText, size: 12)
        self.selectedSwitch.setOn(false, animated: false)
        self.motImage.image = UIImage(named: image)
        self.motImage.tintColor = UIColor.black
        
        selectedSwitch.setOn(self.mot?.selected ?? false, animated: false)
        
        TitleText.numberOfLines = 0
        TitleText.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        reDraw()
    }
    
    func selectCellIfRedraw() {
        self.selectedSwitch.isOn = true
    }
    
    func getValue() -> Bool{
        return selectedSwitch.isOn
    }
    
    func getValueIfSelected() -> String? {
        if getValue() {
            return self.TitleText?.text
        } else {
            return nil
        }
    }
}
