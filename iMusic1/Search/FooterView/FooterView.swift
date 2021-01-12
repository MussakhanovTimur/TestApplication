//
//  FooterView.swift
//  iMusic1
//
//  Created by Тимур Мусаханов on 8/17/20.
//  Copyright © 2020 Тимур Мусаханов. All rights reserved.
//

import UIKit

class FooterView: UIView {
    
    private let myLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = #colorLiteral(red: 0.631372549, green: 0.6470588235, blue: 0.662745098, alpha: 1)
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupElements()
        
    }
    
    private func setupElements() {
        addSubview(myLabel)
        addSubview(activityIndicator)
        
        
        activityIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        myLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        myLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 8).isActive = true
    }
    
    func showLoader() {
        activityIndicator.startAnimating()
        myLabel.text = "LOADING"
    }
    
    func hideLoader() {
        activityIndicator.stopAnimating()
        myLabel.text = ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
