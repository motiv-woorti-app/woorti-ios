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
 * Onboarding view to select Productivity/Relaxing/Fitness for a preferred mode.
 */
class ProductiveRelaxingValuesTableViewCell: UITableViewCell {

    var settings: MotSettings?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        Slider.maximumValue = 100
        Slider.minimumValue = 0
        Slider.value = 50
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var Slider: UISliderWithCustomImage!
    @IBOutlet weak var Label: UILabel!
    

    @IBAction func ValueChangedOnSlider(_ sender: Any) {
        valueChanged()
    }
    
    func valueChanged() {
        MotivFont.motivRegularFontFor(text: "\(Int(Slider.value))%", label: Label, size: 14)
    }
    
    func getValue() -> Float {
        return floor(Slider.value)
    }
    
    func LoadView(image: String, settings: MotSettings) {
        let image = UIImage(named: image)
        self.Slider.minimumTrackTintColor = MotivColors.WoortiOrange
        self.Slider.maximumTrackTintColor = UIColor.gray

        
        Slider.contentMode = .scaleAspectFit

        let thImg = MotivAuxiliaryFunctions.resizeImageToMaxSize(image: image!, maxSize: CGFloat(40))
        Slider.setThumbImage(thImg, for: .normal)
        self.settings = settings
        refreshSliderValue(productive: true)
    }
    
    func refreshsettings(productive: Bool? = nil) {
        if let productive = productive {
            if productive {
                self.settings?.motsProd = Double(getValue())
            } else {
                self.settings?.motsRelax = Double(getValue())
            }
        } else {
            self.settings?.motsFit = Double(getValue())
        }
    }
    
    func refreshSliderValue(productive: Bool? = nil) {
        if let productive = productive {
            if productive {
                if self.settings?.motsProd ?? Double(0) >= 0 {
                    Slider.value = Float(self.settings!.motsProd)
                } else {
                   Slider.value = Float(50)
                }
            } else {
                if self.settings?.motsRelax ?? Double(0) >= 0 {
                    Slider.value = Float(self.settings!.motsRelax)
                } else {
                    Slider.value = Float(50)
                }
            }
        } else {
            if self.settings?.motsFit ?? Double(0) >= 0 {
                Slider.value = Float(self.settings!.motsFit)
            } else {
                Slider.value = Float(50)
            }
        }
        valueChanged()
    }
}


class UISliderWithCustomImage: UISlider {
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let rect = super.thumbRect(forBounds : bounds, trackRect: rect, value: value)
        return CGRect(x: rect.minX, y: rect.minY, width: CGFloat(40), height: CGFloat(40))
    }
}
