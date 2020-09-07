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

class LessonTableViewCell: UITableViewCell {
    
    var lesson: Lesson?
    
    @IBOutlet weak var thumbImage: UIImageView?
    @IBOutlet weak var View: UIView?
    @IBOutlet weak var LessonTitle: UILabel?
    @IBOutlet weak var lessonDescrion: UILabel?
    
    @IBOutlet weak var lowerLine: UIView!
    @IBOutlet weak var upperLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.thumbImage?.layer.cornerRadius = (self.thumbImage?.bounds.height ?? 0)/2
        self.thumbImage?.layer.borderWidth = 5
        self.thumbImage?.layer.borderColor = UIColor.white.cgColor
        self.thumbImage?.clipsToBounds = true
        self.View?.layer.cornerRadius = (self.View?.bounds.height ?? 0)/2
        self.View?.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadCell(lesson: Lesson, type: Lesson.cellType, first: Bool = false, last:Bool = false) {
        self.lesson = lesson
        
        self.thumbImage?.image = lesson.getThumbImage()
        self.LessonTitle?.text = lesson.title
        self.lessonDescrion?.text = lesson.subTitle
        

        if first {
            self.upperLine.isHidden = true
        } else if last {
            self.lowerLine.isHidden = true
        }

        switch type {
        case .faded:
            self.View?.layer.opacity = 0.8
            self.thumbImage?.layer.opacity = 0.8
            break
        case .full:
//            self.thumbImage?.layer.shadowRadius = 4
//            self.thumbImage?.layer.shadowColor = UIColor.black.cgColor
//            self.View?.layer.shadowRadius = 4
            
//            self.View?.layer.shadowOffset = CGSize(width: 10, height: 10)
//            self.View?.layer.shadowColor = UIColor.black.cgColor
//            self.View?.layer.shadowOpacity = 1
//            self.View?.layer.shadowRadius = 5
//
//            self.thumbImage?.layer.shadowOffset = CGSize(width: 10, height: 30)
//            self.thumbImage?.layer.shadowColor = UIColor.black.cgColor
//            self.thumbImage?.layer.shadowOpacity = 1
//            self.thumbImage?.layer.shadowRadius = 50
            
            
            break
        case .next:
            self.thumbImage?.layer.borderColor = UIColor(red: 244/255, green: 217/255, blue: 184/255, alpha: 0.5).cgColor
            self.View?.layer.backgroundColor = UIColor(red: 244/255, green: 217/255, blue: 184/255, alpha: 0.5).cgColor
            self.LessonTitle?.layer.opacity = 0.5
            self.lessonDescrion?.layer.opacity = 0.5
            break
        }
    }
}
