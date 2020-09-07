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

class ValueSliderView: UIView {

    static var dotImage = UIImage(named: "baseline_dot_white")?.withRenderingMode(.alwaysTemplate)
    @IBOutlet weak var barView: UIView!
    var selectedImageValue = selectedIamge.none
    @IBOutlet weak var noneImageView: UIImageView!
    @IBOutlet weak var someImageView: UIImageView!
    @IBOutlet weak var highImageView: UIImageView!
    
    @IBOutlet weak var draggableImage: UIImageView!
    var imageForSelected = ""
    var borderColor = UIColor.clear
    var dragging = false
    
    
    enum selectedIamge: Int {
        case none = 0, some, high
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func awakeFromNib() {
        MotivAuxiliaryFunctions.RoundView(view: noneImageView, CompleteRoundCorners: true)
        MotivAuxiliaryFunctions.RoundView(view: someImageView, CompleteRoundCorners: true)
        MotivAuxiliaryFunctions.RoundView( view: highImageView, CompleteRoundCorners: true)
        drawAll()
        
        self.noneImageView.isUserInteractionEnabled = true
        self.someImageView.isUserInteractionEnabled = true
        self.highImageView.isUserInteractionEnabled = true
        self.draggableImage.isUserInteractionEnabled = true
        
        let nGR = UITapGestureRecognizer(target: self, action: #selector(selctFirstIamge))
        self.noneImageView.addGestureRecognizer(nGR)
        
        let sGR = UITapGestureRecognizer(target: self, action: #selector(selctSecondIamge))
        self.someImageView.addGestureRecognizer(sGR)
        
        let hGR = UITapGestureRecognizer(target: self, action: #selector(selctThirdIamge))
        self.highImageView.addGestureRecognizer(hGR)
        
        
        let pGR = UIPanGestureRecognizer(target: self, action: #selector(draggedView(_:)))
        pGR.minimumNumberOfTouches = 0
        self.draggableImage.addGestureRecognizer(pGR)
        
        //Slider
//        self.slider.minimumValue = 0
//        self.slider.minimumValue = 2
//        self.slider.isContinuous = true
//        self.slider.minimumTrackTintColor = UIColor.gray
//        self.slider.maximumTrackTintColor = UIColor.gray
//        let im = UIImage(named: imageForSelected)?.withRenderingMode(.alwaysOriginal)
        
////        self.noneImageView.layer.masksToBounds = true.layer
//        self.noneImageView.layer.cornerRadius = self.noneImageView.bounds.width / 2
//        self.noneImageView.layer.borderWidth = 5
//        self.noneImageView.layer.borderColor = borderColor.cgColor
//        self.noneImageView.tintColor = UIColor.clear
//        self.slider.setThumbImage(im, for: .normal)
//        self.slider.setThumbImage(im, for: .highlighted)
    }
    
    @objc func draggedView(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            dragging = true
        case .ended, .cancelled:
            dragging = true
        default:
            break
        }
        let minx = barView.center.x - (barView.bounds.width/2)
        let maxx = barView.center.x + (barView.bounds.width/2)
        self.bringSubview(toFront: draggableImage)
        let translation = sender.translation(in: self)
        let newX = max( min( draggableImage.center.x + translation.x, maxx), minx)
//        draggableImage.center = CGPoint(x: newX, y: draggableImage.center.y)
        GetNewInput(x: newX, ended: sender.state == .ended)
        sender.setTranslation(CGPoint.zero, in: self)
    }
    
    func GetNewInput(x: CGFloat, ended: Bool) {
        let distNone = abs( noneImageView.center.x - (ended ? draggableImage.center.x : x) )
        let distSome = abs( someImageView.center.x - x )
        let distHigh = abs( highImageView.center.x - x )
        let minDist = min(distHigh, min(distNone, distSome))
        
        if !ended {
            draggableImage.center = CGPoint(x: x, y: draggableImage.center.y)
        }
        if distNone == minDist {
            if ended {
                draggableImage.center = noneImageView.center
            }
            selctFirstIamge()
        } else if distSome == minDist{
            if ended {
                draggableImage.center = someImageView.center
            }
            selctSecondIamge()
        } else {
            if ended {
                draggableImage.center = highImageView.center
            }
            selctThirdIamge()
        }
    }
    
    @objc func selctFirstIamge() {
        if self.selectedImageValue != .none {
           self.selectedImageValue = .none
            drawAll()
            if !dragging {
                draggableImage.center = noneImageView.center
            }
        }
    }
    
    @objc func selctSecondIamge() {
        if self.selectedImageValue != .some {
            self.selectedImageValue = .some
            drawAll()
            if !dragging {
                draggableImage.center = someImageView.center
            }
        }
    }
    
    @objc func selctThirdIamge() {
        if self.selectedImageValue != .high {
            self.selectedImageValue = .high
            drawAll()
            if !dragging {
                draggableImage.center = highImageView.center
            }
        }
    }
    
    func drawAll() {
        if Thread.isMainThread {
            drawFirstIamge()
            drawSecondIamge()
            drawThirdIamge()
        } else {
            DispatchQueue.main.async {
                self.drawAll()
            }
        }
    }
    
    func getValue() -> Int {
        return self.selectedImageValue.rawValue
    }
    
    func loadIamge(image: String, borderColor: UIColor) {
        self.imageForSelected = image
        self.draggableImage.image = UIImage(named: imageForSelected)?.withRenderingMode(.alwaysOriginal)
        MotivAuxiliaryFunctions.RoundView(view: self.draggableImage, CompleteRoundCorners: true)
//        self.borderColor = borderColor
//        self.draggableImage.layer.masksToBounds = true
//        self.draggableImage.layer.cornerRadius = self.draggableImage.bounds.width / 2
//        self.draggableImage.layer.borderWidth = 5
//        self.draggableImage.layer.borderColor = borderColor.cgColor
//        self.draggableImage.tintColor = UIColor.clear
//        self.drawAll()
        self.bringSubview(toFront: draggableImage)
    }
    
    func drawImage() {
//        if selectedImageValue == .none {
//            self.slider.setThumbImage(UIImage(named: imageForSelected)?.withRenderingMode(.alwaysOriginal), for: .application)
//            self.noneImageView.layer.masksToBounds = true
//            self.noneImageView.layer.cornerRadius = self.noneImageView.bounds.width / 2
//            self.noneImageView.layer.borderWidth = 5
//            self.noneImageView.layer.borderColor = borderColor.cgColor
//            self.noneImageView.tintColor = UIColor.clear
//        } else {
//            self.noneImageView.image = ValueSliderView.dotImage
//            self.noneImageView.layer.masksToBounds = true
//            self.noneImageView.layer.cornerRadius = self.noneImageView.bounds.width / 2
//            self.noneImageView.tintColor = barView.backgroundColor
//            self.noneImageView.backgroundColor = UIColor.clear
//            self.noneImageView.layer.borderWidth = 0
//            self.noneImageView.layer.borderColor = UIColor.clear.cgColor
//        }
        self.noneImageView.image = ValueSliderView.dotImage
        self.noneImageView.layer.masksToBounds = true
        self.noneImageView.layer.cornerRadius = self.noneImageView.bounds.width / 2
        self.noneImageView.tintColor = barView.backgroundColor
        self.noneImageView.backgroundColor = UIColor.clear
        self.noneImageView.layer.borderWidth = 0
        self.noneImageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func drawFirstIamge() {
//        if selectedImageValue == .none {
//            self.noneImageView.image = UIImage(named: imageForSelected)?.withRenderingMode(.alwaysOriginal)
//            self.noneImageView.layer.masksToBounds = true
//            self.noneImageView.layer.cornerRadius = self.noneImageView.bounds.width / 2
//            self.noneImageView.layer.borderWidth = 5
//            self.noneImageView.layer.borderColor = borderColor.cgColor
//            self.noneImageView.tintColor = UIColor.clear
//        } else {
//            self.noneImageView.image = ValueSliderView.dotImage
//            self.noneImageView.layer.masksToBounds = true
//            self.noneImageView.layer.cornerRadius = self.noneImageView.bounds.width / 2
//            self.noneImageView.tintColor = barView.backgroundColor
//            self.noneImageView.backgroundColor = UIColor.clear
//            self.noneImageView.layer.borderWidth = 0
//            self.noneImageView.layer.borderColor = UIColor.clear.cgColor
//        }
        self.noneImageView.image = ValueSliderView.dotImage
        self.noneImageView.layer.masksToBounds = true
        self.noneImageView.layer.cornerRadius = self.noneImageView.bounds.width / 2
        self.noneImageView.tintColor = barView.backgroundColor
        self.noneImageView.backgroundColor = UIColor.clear
        self.noneImageView.layer.borderWidth = 0
        self.noneImageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func drawSecondIamge() {
//        if selectedImageValue == .some {
//            self.someImageView.image = UIImage(named: imageForSelected)?.withRenderingMode(.alwaysOriginal)
//            self.someImageView.layer.masksToBounds = true
//            self.someImageView.layer.cornerRadius = self.someImageView.bounds.width / 2
//            self.someImageView.layer.borderWidth = 5
//            self.someImageView.layer.borderColor = borderColor.cgColor
//        } else {
//            self.someImageView.image = ValueSliderView.dotImage
//            self.someImageView.layer.masksToBounds = true
//            self.someImageView.layer.cornerRadius = self.someImageView.bounds.width / 2
//            self.someImageView.tintColor = barView.backgroundColor
//            self.someImageView.backgroundColor = UIColor.clear
//            self.someImageView.layer.borderWidth = 0
//            self.someImageView.layer.borderColor = UIColor.clear.cgColor
//        }
        self.someImageView.image = ValueSliderView.dotImage
        self.someImageView.layer.masksToBounds = true
        self.someImageView.layer.cornerRadius = self.someImageView.bounds.width / 2
        self.someImageView.tintColor = barView.backgroundColor
        self.someImageView.backgroundColor = UIColor.clear
        self.someImageView.layer.borderWidth = 0
        self.someImageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func drawThirdIamge() {
//        if selectedImageValue == .high {
//            self.highImageView.image = UIImage(named: imageForSelected)?.withRenderingMode(.alwaysOriginal)
//            self.highImageView.layer.masksToBounds = true
//            self.highImageView.layer.cornerRadius = self.highImageView.bounds.width / 2
//            self.highImageView.layer.borderWidth = 5
//            self.highImageView.layer.borderColor = borderColor.cgColor
//        } else {
            self.highImageView.image = ValueSliderView.dotImage
            self.highImageView.layer.masksToBounds = true
            self.highImageView.layer.cornerRadius = self.highImageView.bounds.width / 2
            self.highImageView.tintColor = barView.backgroundColor
            self.highImageView.backgroundColor = UIColor.clear
            self.highImageView.layer.borderWidth = 0
            self.highImageView.layer.borderColor = UIColor.clear.cgColor
//        }
    }
}


