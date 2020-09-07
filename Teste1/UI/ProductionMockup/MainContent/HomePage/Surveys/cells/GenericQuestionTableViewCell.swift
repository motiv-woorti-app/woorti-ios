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

class GenericQuestionTableViewCell: UITableViewCell {

    var question: Question?
    var visible = false
    
    var index = 0
    var parent: SurveyViewController?
    var frontView: UIView?
    static let DisabledQuestionColor = UIColor(displayP3Red: CGFloat(247)/CGFloat(255), green: CGFloat(230)/CGFloat(255), blue: CGFloat(208)/CGFloat(255), alpha: CGFloat(0.7))
    
    static let GreenButtonColor = UIColor(displayP3Red: CGFloat(149)/CGFloat(255), green: CGFloat(205)/CGFloat(255), blue: CGFloat(149)/CGFloat(255), alpha: CGFloat(1))
    static let RedButtonColor = UIColor(displayP3Red: CGFloat(183)/CGFloat(255), green: CGFloat(75)/CGFloat(255), blue: CGFloat(76)/CGFloat(255), alpha: CGFloat(1))
    
    static let OrangeButtonColor = UIColor(displayP3Red: CGFloat(221)/CGFloat(255), green: CGFloat(131)/CGFloat(255), blue: CGFloat(48)/CGFloat(255), alpha: CGFloat(1))
    
    var drawHeight = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.width * 0.1
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.borderWidth = CGFloat(5)
        self.layer.borderColor = UIColor(displayP3Red: CGFloat(247)/CGFloat(255), green: CGFloat(230)/CGFloat(255), blue: CGFloat(208)/CGFloat(255), alpha: CGFloat(1)).cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func answer() -> [Answer] {
        return [Answer]()
    }
    
    func setVisibility() {
        if let frontView = self.frontView {
            self.sendSubview(toBack: frontView)
            frontView.isHidden = true
            self.willRemoveSubview(frontView)
            frontView.removeFromSuperview()
            self.frontView = nil
        }
        
        if !self.visible {
            let bounds = self.bounds
            self.frontView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
            self.frontView!.backgroundColor = GenericQuestionTableViewCell.DisabledQuestionColor
            self.addSubview(frontView!)
        }
        
        DispatchQueue.main.async {
            self.layoutIfNeeded()
            self.layoutSubviews()
        }
    }
    
    func loadQuestionCell(question: Question, visible: Bool, parent: SurveyViewController, index: Int, language: String){
        self.question = question
        self.visible = visible
        self.parent = parent
        self.index = index
        
        setVisibility()
    }

    func getDrawHeight() -> Int {
        return self.drawHeight
    }
    
    func setDrawHeight(height: Int){
        self.drawHeight = height + 15
        self.parent?.reloadData()
        setVisibility()
    }
    
    static func loadStandardButton(button: UIButton, color: UIColor, text: String, disabled: Bool) {
        
        if disabled {
            button.backgroundColor = color.withAlphaComponent(0.6)
        } else {
            button.backgroundColor = color
        }
        button.tintColor = UIColor.white
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.bounds.height * 0.1
        
        button.setTitle(text, for: .normal)
    }
}
