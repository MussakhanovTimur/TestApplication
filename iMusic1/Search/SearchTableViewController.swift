//
//  SearchTableViewController.swift
//  iMusic1
//
//  Created by Тимур Мусаханов on 8/17/20.
//  Copyright © 2020 Тимур Мусаханов. All rights reserved.
//

import UIKit

protocol TrackMovingDelegate: class {
    func moveBackForPreviousTrack() -> Track?
    func moveForwardForPreviousTrack() -> Track?
}

class SearchTableViewController: UITableViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var timer: Timer?
    private let networkService = NetworkService()
    private var searchViewModal: [Track] = []
    weak var tabBarDelegate: MainTabBarControllerDelegate?
    private let trackDetailsView: TreckDetailView = TreckDetailView.loadFromNib()
    private lazy var footerView = FooterView()
    private let helpLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar(searchController.searchBar, textDidChange: "Eminem")
        setupTableView()
        setupSerchBar()
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "TrackCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: TrackCell.reuseId)
        tableView.tableFooterView = footerView
    }

    private func setupSerchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.setValue("Отмена", forKey: "cancelButtonText")
        searchController.obscuresBackgroundDuringPresentation = false
    }

    

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SearchTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModal.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reuseId,
                                                       for: indexPath) as? TrackCell else { return UITableViewCell() }
        let cellViewModal = searchViewModal[indexPath.row]
        cell.set(viewModel: cellViewModal)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellViewModal = searchViewModal[indexPath.row]
        tabBarDelegate?.maximizedTrackDeatilController(viewModel: cellViewModal)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        helpLabel.text = "Введите название трека.."
        helpLabel.textAlignment = .center
        helpLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        helpLabel.textColor = #colorLiteral(red: 0.631372549, green: 0.6470588235, blue: 0.662745098, alpha: 1)
        return helpLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return searchViewModal.count > 0 ? 0 : 250
    }
}

// MARK: - UISearchBarDelegate
extension SearchTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        helpLabel.text = ""
        footerView.showLoader()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            self?.networkService.fetchTracks(searchText: searchText) { [weak self] searchResponse in
                guard let results = searchResponse?.results else { return }
                self?.searchViewModal = results
                self?.tableView.reloadData()
                self?.footerView.hideLoader()
                self?.helpLabel.text = "Введите название трека.."
            }
        })
        
    }
}

// MARK: - TrackMovingDelegate
//Логика перехода от трека к треку
extension SearchTableViewController: TrackMovingDelegate {
    
    private func getTrack(isForwardTrack: Bool) -> Track? {
        
        guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
        tableView.deselectRow(at: indexPath, animated: true)
        var nextIndexPath: IndexPath?
        if isForwardTrack {
            nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            if nextIndexPath?.row == searchViewModal.count {
                nextIndexPath?.row = 0
            }
        } else {
            nextIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            if nextIndexPath?.row == -1 {
                nextIndexPath?.row = searchViewModal.count - 1
            }
        }
        tableView.selectRow(at: nextIndexPath, animated: true, scrollPosition: .none)
        guard let index = nextIndexPath else { return nil }
        let cellViewModal = searchViewModal[index.row]
        return cellViewModal
    }
    
    func moveBackForPreviousTrack() -> Track? {
        getTrack(isForwardTrack: false)
    }
    
    func moveForwardForPreviousTrack() -> Track? {
        getTrack(isForwardTrack: true)
    }
    
}
