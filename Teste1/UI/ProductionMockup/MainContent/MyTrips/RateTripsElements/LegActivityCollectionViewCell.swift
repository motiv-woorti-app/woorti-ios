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

class LegActivityCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var Image: UIImageView?
    @IBOutlet weak var textLabel: UILabel?
    var activity: ActivitySelect?
    var cellIsSelected = false
    
    func loadCell(activity: ActivitySelect, cellIsSelected: Bool) {
        self.activity = activity
        self.Image?.image = UIImage(named: activity.image)
        MotivFont.motivRegularFontFor(key: activity.text, comment: "", label: self.textLabel!, size: 8)
//        self.textLabel?.text = activity.text
        self.cellIsSelected = cellIsSelected
        MotivAuxiliaryFunctions.RoundView(view: self)
        drawView()
    }
    
    func SelectCell() {
        cellIsSelected = true
        drawView()
    }
    
    func deselectCell() {
        cellIsSelected = false
        drawView()
    }
    
    func drawView() {
        if cellIsSelected {
            self.backgroundColor = MotivColors.WoortiOrangeT3
            MotivFont.motivBoldFontFor(text: self.textLabel?.text ?? "", label: self.textLabel!, size: Int((self.textLabel?.font.pointSize)!))
            self.textLabel?.textColor = MotivColors.WoortiOrange
        } else {
            self.backgroundColor = UIColor.white
            MotivFont.motivRegularFontFor(text: self.textLabel?.text ?? "", label: self.textLabel!, size: Int((self.textLabel?.font.pointSize)!))
            self.textLabel?.textColor = UIColor.black
        }
        
        DispatchQueue.main.async {
            self.layoutIfNeeded()
        }
    }
}


class ActivitySelect {
    
    let type: type
    let image: String
    let text: String
    
//    enum image: String {
//        case directions_walk_black
//    }
    
    enum type: Int {
        case productivity
        case mind
        case body
    }
    
    init(type: type, image: String, text: String) {
        self.type = type
        self.image = image
        self.text = text
    }
    
    static func getActivities(type: type, modeOfTRansport: Trip.modesOfTransport) -> [ActivitySelect] {
        var activities = [ActivitySelect]()
//        switch type {
//        case .productivity:
        let arrays = LegActivities.getArrays(type: type, modeOfTRansport: modeOfTRansport)
        
        for text in arrays.0 {
            let image = arrays.1[arrays.0.index(of: text)!]
            activities.append(ActivitySelect(type: type, image: image, text: text))
        }
        return activities
    }
    
    static func isOther(act: ActivitySelect) -> Bool {
        return act.text == LegActivities.ActivityCodeForOther
    }
}
