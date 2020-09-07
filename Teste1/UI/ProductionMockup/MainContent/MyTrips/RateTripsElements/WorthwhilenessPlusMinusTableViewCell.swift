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

class WorthwhilenessPlusMinusTableViewCell: UITableViewCell {

    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBOutlet weak var minusButton: UIImageView!
    @IBOutlet weak var plusButton: UIImageView!
//
//    var plusSelected = false
//    var minusSelected = false
    
    var factor: WorthWhilenessFactors?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let mGR = UITapGestureRecognizer(target: self, action: #selector(clickMinus))
        minusButton.addGestureRecognizer(mGR)
        
        let pGR = UITapGestureRecognizer(target: self, action: #selector(clickPlus))
        plusButton.addGestureRecognizer(pGR)
        
        RedrawView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadCell(factor: WorthWhilenessFactors) {
        self.factor = factor
        RedrawView()
    }
    
    func RedrawView() {
        if let factor = factor {
            let factorText = NSLocalizedString(factor.text, comment: "factor")

            MotivFont.motivRegularFontFor(text: factorText, label: TitleLabel, size: 12)
            if factor.plus && factor.minus {
                TitleLabel.backgroundColor = MotivColors.WoortiOrangeT3
                TitleLabel.textColor = MotivColors.WoortiOrange
                minusButton.tintColor = UIColor.white
                minusButton.backgroundColor = MotivColors.WoortiOrange
                plusButton.tintColor = UIColor.white
                plusButton.backgroundColor = MotivColors.WoortiOrange
            } else if factor.plus {
                TitleLabel.backgroundColor = MotivColors.WoortiOrangeT3
                TitleLabel.textColor = MotivColors.WoortiGreen
                minusButton.tintColor = UIColor.gray
                minusButton.backgroundColor = MotivColors.WoortiOrangeT3
                plusButton.tintColor = UIColor.white
                plusButton.backgroundColor = MotivColors.WoortiGreen
            } else if factor.minus {
                TitleLabel.backgroundColor = MotivColors.WoortiOrangeT3
                TitleLabel.textColor = MotivColors.WoortiRed
                minusButton.tintColor = UIColor.white
                minusButton.backgroundColor = MotivColors.WoortiRed
                plusButton.tintColor = UIColor.gray
                plusButton.backgroundColor = MotivColors.WoortiOrangeT3
            } else {
                TitleLabel.backgroundColor = MotivColors.WoortiOrangeT3
                TitleLabel.textColor = UIColor.gray
                minusButton.tintColor = UIColor.gray
                minusButton.backgroundColor = MotivColors.WoortiOrangeT3
                plusButton.tintColor = UIColor.black
                plusButton.backgroundColor = MotivColors.WoortiOrangeT3
            }
            

            
            //TitleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            //TitleLabel.numberOfLines = 0
            
            MotivAuxiliaryFunctions.RoundView(view: TitleLabel, CompleteRoundCorners: false)
            MotivAuxiliaryFunctions.RoundView(view: minusButton, CompleteRoundCorners: false)
            MotivAuxiliaryFunctions.RoundView(view: plusButton, CompleteRoundCorners: false)
            
            
            
        }
    }
    
    @objc func clickPlus() {
        if let f = factor {
            f.plus = !f.plus
            RedrawView()
        }
    }
    
    @objc func clickMinus() {
        if let f = factor {
            f.minus = !f.minus
            RedrawView()
        }
    }

}
