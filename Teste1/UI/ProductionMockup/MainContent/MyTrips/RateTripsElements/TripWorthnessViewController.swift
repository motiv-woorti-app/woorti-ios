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

class TripWorthnessViewController: MTGenericViewController {

    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBOutlet weak var LousyLabel: UILabel!
    @IBOutlet weak var GreatLabel: UILabel!
    
    @IBOutlet weak var oneStar: UIImageView!
    @IBOutlet weak var TwoStar: UIImageView!
    @IBOutlet weak var ThreeStar: UIImageView!
    @IBOutlet weak var FourStar: UIImageView!
    @IBOutlet weak var FiveStar: UIImageView!
    @IBOutlet var stars: [UIImageView]!
    var starsOrdered = [UIImageView]()
    
    @IBOutlet weak var allView: UIView!
    @IBOutlet weak var titleLabelView: UIView!
    
    enum images: String {
        case ic_star_border_white
        case ic_star_white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = MotivColors.WoortiOrangeT2
//        loadImage()
        MotivFont.motivBoldFontFor(key: "Overall_Feel_About_Trip" , comment: "message: Overall, how did you feel about this trip?", label: self.TitleLabel, size: 17)
        self.TitleLabel.textColor = MotivColors.WoortiOrange
        
        MotivFont.motivBoldFontFor(key: "Lousy", comment: "message: Lousy", label: self.LousyLabel, size: 9)
        MotivFont.motivBoldFontFor(key: "Great", comment: "message: Great", label: self.GreatLabel, size: 9)
        
        MotivAuxiliaryFunctions.RoundView(view: allView)
        MotivAuxiliaryFunctions.ShadowOnView(view: titleLabelView)
        
        let grOne = UITapGestureRecognizer(target: self, action: #selector(onClickOneStar))
        let grTwo = UITapGestureRecognizer(target: self, action: #selector(onClickTwoStar))
        let grThree = UITapGestureRecognizer(target: self, action: #selector(onClickThreeStar))
        let grFour = UITapGestureRecognizer(target: self, action: #selector(onClickFourStar))
        let grFive = UITapGestureRecognizer(target: self, action: #selector(onClickFiveStar))
        
        oneStar.addGestureRecognizer(grOne)
        TwoStar.addGestureRecognizer(grTwo)
        ThreeStar.addGestureRecognizer(grThree)
        FourStar.addGestureRecognizer(grFour)
        FiveStar.addGestureRecognizer(grFive)
        
        starsOrdered.append(oneStar)
        starsOrdered.append(TwoStar)
        starsOrdered.append(ThreeStar)
        starsOrdered.append(FourStar)
        starsOrdered.append(FiveStar)
        
        
        self.loadImage(start: false)
    }
    
    func loadImage(start: Bool = false) {
        let score = getFt()?.overallScore ?? -1
        for im in starsOrdered {
            if let ind = starsOrdered.index(of: im) {
                if ind > Int(score) - 1 || start {
                    im.image = UIImage(named: "Star_Grey")
                } else {
                    im.image = UIImage(named: "Star_Yellow")
                }
            }
        }
    }
    
    @objc func onClickOneStar() {
        if let ft = self.getFt() {
            ft.overallScore = Double(1)
        }
        moveNext()
    }
    
    @objc func onClickTwoStar() {
        if let ft = self.getFt() {
            ft.overallScore = Double(2)
        }
        moveNext()
    }
    
    @objc func onClickThreeStar() {
        if let ft = self.getFt() {
            ft.overallScore = Double(3)
        }
        moveNext()
    }
    
    @objc func onClickFourStar() {
        if let ft = self.getFt() {
            ft.overallScore = Double(4)
        }
        moveNext()
    }
    
    @objc func onClickFiveStar() {
        if let ft = self.getFt() {
            ft.overallScore = Double(5)
        }
        moveNext()
    }
    
    func moveNext() {
        self.loadImage()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MyTripsGenericViewController.MTViews.MyTripsObjective.rawValue), object: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
