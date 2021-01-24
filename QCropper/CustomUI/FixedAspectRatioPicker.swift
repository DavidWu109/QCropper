//
//  FixedAspectRatioPicker.swift
//  QCropper
//
//  Created by david on 2021/1/24.
//

import Foundation
import UIKit


public class FixedAspectRatioPicker: UIView {

    weak var delegate: AspectRatioPickerDelegate?

    var selectedAspectRatio: AspectRatio = .freeForm {
        didSet {
            let buttonIndex = aspectRatios.firstIndex(of: selectedAspectRatio) ?? 0
            scrollView.subviews.forEach { view in
                if let button = view as? UIButton, button.tag == buttonIndex {
                    button.isSelected = true
//                    scrollView.scrollRectToVisible(button.frame.insetBy(dx: -30, dy: 0), animated: true)
                }
            }
        }
    }

    var rotated: Bool = false

    var aspectRatios: [AspectRatio] = [
        .original,
        .ratio(width: 3, height: 4),
        .ratio(width: 1, height: 1),
        .ratio(width: 4, height: 3)
        ] {
        didSet {
            reloadScrollView()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(scrollView)
        addSubview(label)
        addSubview(titleLb)
        addSubview(cancelButton)
        addSubview(confirmButton)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    lazy var scrollView: UIView = {
        let sv = UIView(frame: self.bounds)
        sv.backgroundColor = .clear
//        sv.decelerationRate = .fast
//        sv.showsHorizontalScrollIndicator = false
//        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    lazy var label: UILabel = {
        let text = "尺寸"
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let label = UILabel(frame: CGRect(origin: CGPoint(x: 15, y: 0),
                                          size: CGSize(width: text.width(withFont: font), height: 22)))
        label.alpha = 0.5
        label.textColor = UIColor.white
        label.font = font
        label.text = text
        return label
    }()
    
    lazy var titleLb: UILabel = {
        let text = "调整"
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        let height: CGFloat = 22
        let width = text.width(withFont: font)
        let x = (bounds.size.width - text.width(withFont: font)) / 2
        let y = bounds.size.height - height
        let label = UILabel(frame: CGRect(origin: CGPoint(x: x, y: y),
                                          size: CGSize(width: width, height: height)))
        label.textColor = UIColor.white
        label.font = font
        label.text = text
        return label
    }()
    
    lazy var cancelButton: IconButton = {
        let margin: CGFloat = 15
        let imgHeight: CGFloat = 20
        let imgWidth: CGFloat = 20 + margin * 2
        let button = IconButton("QCropper.crop.cancel")
        button.frame = CGRect(x: 0, y: bounds.size.height - imgHeight, width: imgWidth, height: imgHeight)
        button.tintColor = UIColor.white
        return button
    }()
    
    lazy var confirmButton: IconButton = {
        let margin: CGFloat = 15
        let imgHeight: CGFloat = 20
        let imgWidth: CGFloat = 20 + margin * 2
        let button = IconButton("QCropper.crop.confirm")
        button.tintColor = UIColor.white
        button.frame = CGRect(x: bounds.size.width - imgWidth, y: bounds.size.height - imgHeight, width: imgWidth , height: imgHeight)
        return button
    }()

    func reloadScrollView() {

        scrollView.subviews.forEach { button in
            if button is UIButton {
                button.removeFromSuperview()
            }
        }

        let buttonCount = aspectRatios.count
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let padding: CGFloat = 16
//        let margin = 2 * padding
        let buttonHeight: CGFloat = 22

        var x: CGFloat = bounds.size.width - padding
        for i in (0 ..< buttonCount).reversed() {
            let button = UIButton(frame: CGRect.zero)
            button.tag = i
            button.backgroundColor = UIColor.clear
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitleColor(UIColor(red: 5.0/255.0, green: 190.0/255.0, blue: 169.0/255.0, alpha: 1.0), for: .selected)
            button.layer.cornerRadius = buttonHeight / 2
            button.layer.masksToBounds = true
            button.titleLabel?.font = font
            button.addTarget(self, action: #selector(aspectRatioButtonPressed(_:)), for: .touchUpInside)

            let ar = aspectRatios[i]
            let title = ar.description
            let width = title.width(withFont: font) + padding * 2
            x -= width
            button.setTitle(title, for: .normal)
            button.frame = CGRect(x: x, y: 0, width: width, height: buttonHeight)

            scrollView.addSubview(button)
        }

        scrollView.height = buttonHeight
        scrollView.top = 0
//        scrollView.right = 0
//        scrollView.contentSize = CGSize(width: x + padding, height: buttonHeight)
    }

    @objc
    func aspectRatioButtonPressed(_ sender: UIButton) {
        if !sender.isSelected {
            scrollView.subviews.forEach { view in
                if let button = view as? UIButton {
                    button.isSelected = false
                }
            }

            if sender.tag < aspectRatios.count {
                selectedAspectRatio = aspectRatios[sender.tag]
            } else {
                selectedAspectRatio = .freeForm
            }

            delegate?.aspectRatioPickerDidSelectedAspectRatio(selectedAspectRatio)
        }
    }

    func rotateAspectRatios() {
        let selected = selectedAspectRatio
        aspectRatios = aspectRatios.map { $0.rotated }
        selectedAspectRatio = selected.rotated
        delegate?.aspectRatioPickerDidSelectedAspectRatio(selectedAspectRatio)
    }

}

