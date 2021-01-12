//
//  MainTabBarController.swift
//  iMusic1
//
//  Created by Тимур Мусаханов on 8/17/20.
//  Copyright © 2020 Тимур Мусаханов. All rights reserved.
//

import UIKit

protocol MainTabBarControllerDelegate: class {
    func minimizedTrackDeatilController()
    func maximizedTrackDeatilController(viewModel: Track?)
}

class MainTabBarController: UITabBarController {
    
    private let storyboardSearchVC: SearchTableViewController = SearchTableViewController.loadFromStoryboard()
    private let trackDetailsView: TreckDetailView = TreckDetailView.loadFromNib()
    private var minimizedTopAnchorConstraint: NSLayoutConstraint?
    private var maximizedTopAnchorConstraint: NSLayoutConstraint?
    private var bottomAnchorConstraint: NSLayoutConstraint?
    private lazy var searchVCTableAnchor = storyboardSearchVC.view.bottomAnchor.constraint(equalTo: trackDetailsView.topAnchor, constant: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.3764705882, alpha: 1)
        viewControllers = [generateViewController(rootViewController: storyboardSearchVC, image: #imageLiteral(resourceName: "search"), title: "Поиск"),
                           generateViewController(rootViewController: ViewController(), image: #imageLiteral(resourceName: "library"), title: "Медиатека")]
        storyboardSearchVC.tabBarDelegate = self
        trackDetailsView.tabBarDelegate = self
        setuptrackDetailViewController()
    }
    
    private func generateViewController(rootViewController: UIViewController,
                                        image: UIImage,
                                        title: String) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.title = title
        navigationVC.tabBarItem.image = image
        rootViewController.title = title
        navigationVC.navigationBar.prefersLargeTitles = true
        return navigationVC
    }
    
    private func setuptrackDetailViewController() {
        trackDetailsView.delegate = storyboardSearchVC
        view.insertSubview(trackDetailsView, belowSubview: tabBar)
        
        trackDetailsView.translatesAutoresizingMaskIntoConstraints = false
        maximizedTopAnchorConstraint = trackDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.size.height)
        minimizedTopAnchorConstraint = trackDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -65)
        bottomAnchorConstraint = trackDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                                          constant: 0)
        
        maximizedTopAnchorConstraint?.isActive = true
        
        trackDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trackDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
}

extension MainTabBarController: MainTabBarControllerDelegate {
    func maximizedTrackDeatilController(viewModel: Track?) {
        UIView.animate(withDuration: 0.8,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
                        
                        self.maximizedTopAnchorConstraint?.constant = 0
                        self.minimizedTopAnchorConstraint?.isActive = false
                        self.maximizedTopAnchorConstraint?.isActive = true
                        self.bottomAnchorConstraint?.isActive = true
                        
                        self.view.layoutIfNeeded()
                        self.tabBar.alpha = 0
                        self.trackDetailsView.miniTrackView.alpha = 0
                        self.trackDetailsView.maxizedStackView.alpha = 1
                        
                        
                        
                        
        },
                       completion: nil)
        guard let viewsModel = viewModel else { return }
        trackDetailsView.set(viewModal: viewsModel)
    }
    
    
    func minimizedTrackDeatilController() {
        UIView.animate(withDuration: 0.8,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
                        
                        self.maximizedTopAnchorConstraint?.isActive = false
                        self.bottomAnchorConstraint?.isActive = false
//                        self.searchVCTableAnchor.isActive = true
                        self.minimizedTopAnchorConstraint?.isActive = true
                        
                        self.view.layoutIfNeeded()
                        self.tabBar.alpha = 1
                        self.trackDetailsView.miniTrackView.alpha = 1
                        self.trackDetailsView.maxizedStackView.alpha = 0
                        
                        
        },
                       completion: nil)
    }
    
}

