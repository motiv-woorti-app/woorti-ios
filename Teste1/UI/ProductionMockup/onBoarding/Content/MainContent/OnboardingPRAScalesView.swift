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
 * Onboarding view related with the importance that the user gives to his travel time (productivity, relaxing, fitness)
 * Contains sliders to choose a value between 0% and 100% for each factor
 */
class OnboardingPRAScalesView: UIView {

    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var Text0: UILabel!
    @IBOutlet weak var Text100: UILabel!
    @IBOutlet weak var Slider: UISlider!
    
    
    var textTitle: String = ""
    var layoutView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var textDescription: String = ""
    var infoIsOut = false
    
    @IBOutlet weak var infoImage: UIImageView!
    
    fileprivate func updateTitle() {
        MotivFont.motivRegularFontFor(text: "\(textTitle) \(Int(getValue()))%", label: Title, size: 15)
    }
    
    /*
     * show info baloon explaining productivity/relaxing/fitness
     */
    @objc func showInfo() {
        self.layoutView.removeFromSuperview()
        let newX = self.bounds.width / 2
        
        let center = CGPoint(x: newX, y: infoImage.center.y - (self.bounds.width/6 + infoImage.bounds.height))
        loadLayoutView(center: center, text: textDescription)
        
        self.addSubview(self.layoutView)
        infoIsOut = true
    }
    
    func removeInfo() {
        infoIsOut = false
        self.layoutView.removeFromSuperview()
    }
    
    @objc func clickInfoButton() {
        if infoIsOut {
            removeInfo()
        } else {
            showInfo()
        }
    }
    
    func loadLayoutView(center: CGPoint, text: String) {
        for view in layoutView.subviews {
            view.removeFromSuperview()
        }
        layoutView.frame = CGRect(x: 0, y: 0, width: self.bounds.width/1.5, height: self.bounds.width/4)
        layoutView.center = center
        MotivAuxiliaryFunctions.RoundView(view: layoutView, CompleteRoundCorners: true)
        layoutView.backgroundColor = MotivColors.WoortiOrangeT2
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: layoutView.bounds.width - 20, height: layoutView.bounds.height))
        label.center = CGPoint(x: layoutView.bounds.width/2, y: layoutView.bounds.height/2)
//        label.center = layoutView.center
        MotivFont.motivRegularFontFor(text: text, label: label, size: 9)
        label.textColor = MotivColors.WoortiOrange
        label.textAlignment = .center
        label.numberOfLines = 10
        layoutView.addSubview(label)
    }
    
    func LoadSliderViews(_ title: String,_ lableZero: String, _ label100: String, _ textDescription: String){
        Slider.minimumValue = 0
        Slider.maximumValue = 10
        Slider.isContinuous = true
        Slider.setValue((Slider.minimumValue + Slider.maximumValue)/2, animated: false)
        self.textTitle = title
        
        updateTitle()
//        self.Text0.text = lableZero
        MotivFont.motivRegularFontFor(text: lableZero, label: self.Text0, size: 9)
//        self.Text100.text = label100
        MotivFont.motivRegularFontFor(text: label100, label: self.Text100, size: 9)
        self.Slider.setValue(5, animated: false)
        
        self.Slider.thumbTintColor = MotivColors.WoortiOrange
        self.Slider.minimumTrackTintColor = MotivColors.WoortiOrange
        self.Slider.maximumTrackTintColor = UIColor.gray
//        self.Slider.addTarget(self, action: #selector(), for: .)
        self.Slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        
        self.infoImage.tintColor = MotivColors.WoortiOrange
        self.infoImage.isUserInteractionEnabled = true
        let gr = UITapGestureRecognizer(target: self, action: #selector(clickInfoButton))
        self.infoImage.addGestureRecognizer(gr)
        self.textDescription = textDescription
    }
    
    @objc func valueChanged() {
        removeInfo()
        updateTitle()
    }
    
    func setSliderValue(value: Float) {
        self.Slider.value = Float(Int(value/10))
        updateTitle()
        print( "set slider: \(Float(Int(value))) \(self.Slider.value)")
    }
    
//    @objc func sliderEditingStart(sender: UISlider, forEvent event: UIEvent) {
//        
//    }
    
    func getValue() -> Float {
        return Float(Int(Slider.value*10))
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
