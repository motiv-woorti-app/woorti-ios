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

class ConfirmScreenCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var LegIdentifier: UILabel!
    
    @IBOutlet weak var WalkingSwitch: UISwitch!
    @IBOutlet weak var RunningSwitch: UISwitch!
    @IBOutlet weak var BycicleSwitch: UISwitch!
    @IBOutlet weak var BusSwitch: UISwitch!
    @IBOutlet weak var TrainSwitch: UISwitch!
    @IBOutlet weak var CarSwitch: UISwitch!
    @IBOutlet weak var MetroSwitch: UISwitch!
    @IBOutlet weak var TramSwitch: UISwitch!
    @IBOutlet weak var FerrySwitch: UISwitch!
    @IBOutlet weak var PlaneSwitch: UISwitch!
    
    @IBOutlet weak var nobtn: UIButton!
    
    var leg: Trip?
    
    @IBAction func WalkingSwitchClick(_ sender: Any) {
        ClickSwitch(sender as! UISwitch)
        self.leg?.correctedModeOfTransport = ActivityClassfier.WALKING
        UserInfo.appDelegate?.saveContext()
    }
    @IBAction func RunningSwitchClick(_ sender: Any) {
        ClickSwitch(sender as! UISwitch)
        self.leg?.correctedModeOfTransport = ActivityClassfier.RUNNING
        UserInfo.appDelegate?.saveContext()
    }
    @IBAction func BycicleSwitchClick(_ sender: Any) {
        ClickSwitch(sender as! UISwitch)
        self.leg?.correctedModeOfTransport = ActivityClassfier.CYCLING
        UserInfo.appDelegate?.saveContext()
    }
    @IBAction func BusSwitchClick(_ sender: Any) {
        ClickSwitch(sender as! UISwitch)
        self.leg?.correctedModeOfTransport = ActivityClassfier.BUS
        UserInfo.appDelegate?.saveContext()
    }
    @IBAction func TrainSwitchClick(_ sender: Any) {
        ClickSwitch(sender as! UISwitch)
        self.leg?.correctedModeOfTransport = ActivityClassfier.TRAIN
        UserInfo.appDelegate?.saveContext()
    }
    @IBAction func CarSwitchClick(_ sender: Any) {
        ClickSwitch(sender as! UISwitch)
        self.leg?.correctedModeOfTransport = ActivityClassfier.CAR
        UserInfo.appDelegate?.saveContext()
    }
    @IBAction func MetroSwitchClick(_ sender: Any) {
        ClickSwitch(sender as! UISwitch)
        self.leg?.correctedModeOfTransport = ActivityClassfier.METRO
        UserInfo.appDelegate?.saveContext()
    }
    @IBAction func TramSwitchClick(_ sender: Any) {
        ClickSwitch(sender as! UISwitch)
        self.leg?.correctedModeOfTransport = ActivityClassfier.TRAM
        UserInfo.appDelegate?.saveContext()
    }
    @IBAction func FerrySwitchClick(_ sender: Any) {
        ClickSwitch(sender as! UISwitch)
        self.leg?.correctedModeOfTransport = ActivityClassfier.FERRY
        UserInfo.appDelegate?.saveContext()
    }
    @IBAction func PlaneSwitchClick(_ sender: Any) {
        ClickSwitch(sender as! UISwitch)
        self.leg?.correctedModeOfTransport = ActivityClassfier.PLANE
        UserInfo.appDelegate?.saveContext()
    }
    
    fileprivate func updateNobtn() {
        if (self.leg?.wrongLeg)! {
            nobtn.setTitle("Yes", for: .normal)
        } else {
            nobtn.setTitle("No", for: .normal)
        }
    }
    
    @IBAction func NoButton(_ sender: Any) {
        
        self.leg?.wrongLeg = !(self.leg?.wrongLeg ?? true)
        updateNobtn()
    }
    
    func ClickSwitch(_ sender: UISwitch){
        WalkingSwitch.setOn(false, animated: true)
        RunningSwitch.setOn(false, animated: true)
        BycicleSwitch.setOn( false, animated: true)
        BusSwitch.setOn( false, animated: true)
        TrainSwitch.setOn( false, animated: true)
        CarSwitch.setOn( false, animated: true)
        MetroSwitch.setOn( false, animated: true)
        TramSwitch.setOn( false, animated: true)
        FerrySwitch.setOn( false, animated: true)
        PlaneSwitch.setOn( false, animated: true)
        
        sender.setOn( true, animated: true)
    }
}
