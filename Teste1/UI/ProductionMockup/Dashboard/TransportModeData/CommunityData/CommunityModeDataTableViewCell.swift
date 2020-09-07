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
 * Table cell with mode, icon, progress bar and the stats place holder
 */
class CommunityModeDataTableViewCell: UITableViewCell {

    @IBOutlet weak var ModeLabel: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var CitizensLabel: UILabel!
    @IBOutlet weak var YouLabel: UILabel!
    @IBOutlet weak var ProgressBarCitizens: UIProgressView!
    @IBOutlet weak var ProgressBarYou: UIProgressView!
    @IBOutlet weak var CitizensRawValue: UILabel!
    @IBOutlet weak var CitizensPercentValue: UILabel!
    @IBOutlet weak var YouRawValue: UILabel!
    @IBOutlet weak var YouPercentValue: UILabel!
    
    var maxValuePerMode = (Trip.modesOfTransport.walking, Double(0))
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func loadCell(modeText: String, modeImage: UIImage, citizensRawValue: Double, youRawValue: Double, citizensPercent: Int, youPercent: Int) {
        MotivFont.motivBoldFontFor(text: NSLocalizedString(modeText, comment: ""), label: ModeLabel, size: 16)
        MotivFont.motivRegularFontFor(text: NSLocalizedString("Citizens", comment: ""), label: CitizensLabel, size: 14)
        MotivFont.motivRegularFontFor(text: NSLocalizedString("You", comment: ""), label: YouLabel, size: 14)
        
        ImageView.image = modeImage
        
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: ModeLabel, color: MotivColors.WoortiBlackT1)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: CitizensLabel, color: MotivColors.WoortiOrange)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: YouLabel, color: MotivColors.WoortiOrangeT1)
        
        let maxValue = max(citizensRawValue, youRawValue)
        var citizensPercentValue = 0
        var youPercentValue = 0
        
        ProgressBarCitizens.backgroundColor = UIColor.clear
        ProgressBarCitizens.progressTintColor = MotivColors.WoortiOrange
        if maxValue == 0.0 {
            citizensPercentValue = 0
            ProgressBarCitizens.progress = 0
        } else if maxValue == citizensRawValue {
            ProgressBarCitizens.progress = 1
            citizensPercentValue = 100
        } else {
            citizensPercentValue = Int(citizensRawValue * 100 / maxValue )
            ProgressBarCitizens.progress = Float(citizensPercentValue)/100
        }
        
        
        ProgressBarCitizens.layer.cornerRadius = 8
        ProgressBarCitizens.clipsToBounds = true
        ProgressBarCitizens.layer.sublayers![1].cornerRadius = 8
        ProgressBarCitizens.subviews[1].clipsToBounds = true
        
        
        ProgressBarYou.backgroundColor = UIColor.clear
        ProgressBarYou.progressTintColor = MotivColors.WoortiOrangeT1
        if maxValue == 0.0 {
            youPercentValue = 0
            ProgressBarYou.progress = 0
        } else if maxValue == youRawValue {
            ProgressBarYou.progress = 1
            youPercentValue = 100
        } else {
            youPercentValue = Int(youRawValue * 100 / maxValue )
            ProgressBarYou.progress = Float(youPercentValue)/100
        }
        
        
        ProgressBarYou.layer.cornerRadius = 8
        ProgressBarYou.clipsToBounds = true
        ProgressBarYou.layer.sublayers![1].cornerRadius = 8
        ProgressBarYou.subviews[1].clipsToBounds = true
        
      
        
        
        MotivFont.motivBoldFontFor(text: String(format: "%.1f", citizensRawValue), label: CitizensRawValue, size: 14)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: CitizensRawValue, color: MotivColors.WoortiOrange)
        
        MotivFont.motivBoldFontFor(text: String(format: "%.1f", youRawValue), label: YouRawValue, size: 14)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: YouRawValue, color: MotivColors.WoortiOrangeT1)
        
        MotivFont.motivBoldFontFor(text: String(format: "%d", Int(citizensPercent)) + "%", label: CitizensPercentValue, size: 14)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: CitizensPercentValue, color: MotivColors.WoortiOrange)
        
        MotivFont.motivBoldFontFor(text: String(format: "%d", Int(youPercent)) + "%", label: YouPercentValue, size: 14)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: YouPercentValue, color: MotivColors.WoortiOrangeT1)
        
        
        

        
        
    }
    
}
