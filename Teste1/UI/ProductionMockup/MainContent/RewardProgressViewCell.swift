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

class RewardProgressViewCell: UITableViewCell {

    @IBOutlet weak var ProgressLabel: UILabel!
    
    @IBOutlet weak var RewardName: UILabel!
    
    @IBOutlet weak var DaysLeft: UILabel!
    
    @IBOutlet weak var ProgressView: UIView!
    
    @IBOutlet weak var LeftPoints: UILabel!
    
    @IBOutlet weak var ProgressBar: UIProgressView!
    
    @IBOutlet weak var RightPoints: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func loadCell(reward: Reward, rewardStatus: RewardStatus?){
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
      
        MotivFont.motivBoldFontFor(key: reward.rewardName, comment: "", label: RewardName, size: 16)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: RewardName, color: UIColor.white)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let daysLeftText = String(format: NSLocalizedString("Complete_Until", comment: ""), "\(formatter.string(from: reward.endDate))")
        MotivFont.motivRegularFontFor(key: daysLeftText, comment: "", label: DaysLeft, size: 14)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: DaysLeft, color: UIColor.white.withAlphaComponent(0.7))
        
        var rewardTypeText = "PTS"
        switch(reward.targetType) {
            case 1.0: rewardTypeText = NSLocalizedString("Points", comment: "")
            case 2.0: rewardTypeText = NSLocalizedString("Days", comment: "")
            case 3.0: rewardTypeText = NSLocalizedString("Trips", comment: "")
            case 4.0: rewardTypeText = NSLocalizedString("Points", comment: "")
            case 5.0: rewardTypeText = NSLocalizedString("Days", comment: "")
            case 6.0: rewardTypeText = NSLocalizedString("Trips", comment: "")
        default: rewardTypeText = NSLocalizedString("Points", comment: "")
        }
        
        let rightPointsText = "\(Int(reward.targetValue)) " + rewardTypeText
        var currentPoints = 0.0
        if let status = rewardStatus {
            currentPoints = status.currentValue
        }
        let leftPointsText = "\(Int(currentPoints)) " + rewardTypeText
        
        MotivFont.motivRegularFontFor(key: leftPointsText, comment: "", label: LeftPoints, size: 12)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: LeftPoints, color: UIColor.white.withAlphaComponent(0.7))
        MotivFont.motivRegularFontFor(key: rightPointsText, comment: "", label: RightPoints, size: 12)
         MotivFont.ChangeColorOnAttributedStringFromLabel(label: RightPoints, color: UIColor.white.withAlphaComponent(0.7))
        
        ProgressBar.setProgress(currentPoints == 0 ? 0 : Float(currentPoints / reward.targetValue), animated: false)
        
        self.backgroundColor = UIColor.clear
       

    }
    
    private func getDaysLeftToReward(date: Date) -> Int? {
        let calendar = NSCalendar.current
        let date1 = calendar.startOfDay(for: Date())
        let date2 = calendar.startOfDay(for: date)
        let daysLeft = calendar.dateComponents([.day], from: date1, to: date2)
        
        return daysLeft.day
    }
    
}
