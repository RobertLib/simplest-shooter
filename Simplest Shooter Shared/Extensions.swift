//
//  Extensions.swift
//  Simplest Shooter
//
//  Created by Robert Libšanský on 07.01.2024.
//

import SpriteKit

#if os(OSX)
typealias Color = NSColor
typealias Font = NSFont
#else
typealias Color = UIColor
typealias Font = UIFont
#endif

extension SKColor {
    var sRGBAComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        #if os(iOS)
        let rgbColor = self
        #elseif os(OSX)
        let rgbColor = usingColorSpace(.extendedSRGB) ?? SKColor(red: 1, green: 1, blue: 1, alpha: 1)
        #endif

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension SKLabelNode {
    func addStroke(color: Color, width: CGFloat) {
        guard let labelText = text else { return }

        let font = Font(name: fontName!, size: fontSize)
        let attributedString: NSMutableAttributedString

        if let labelAttributedText = attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelAttributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }

        let attributes: [NSAttributedString.Key: Any] = [.strokeColor: color, .strokeWidth: -width, .font: font!, .foregroundColor: fontColor!]

        attributedString.addAttributes(attributes, range: NSMakeRange(0, attributedString.length))

        attributedText = attributedString
   }
}
