//
//  TodayViewController.swift
//  Trending Tv Shows
//
//  Created by Alex Paul on 1/6/21.
//

import UIKit

class WeeklyViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {

    var collectionView: UICollectionView!
    var shows: [Show] = []
    var filteredShows: [Show] = []
    var page = 1
    var show_ID = 0
    var isSearching = false
    var loadMoreMovies = true

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewcontroller()
        configureCollectionView()
        configureSearch()
        getTvshows(page: page)
    }

    func configureViewcontroller() {
        view.backgroundColor = .systemGray
    }

    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(TvCellCollectionViewCell.self, forCellWithReuseIdentifier: TvCellCollectionViewCell.reuseID)
    }

    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 3.0),
            heightDimension: .absolute(180)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        return UICollectionViewCompositionalLayout(section: section)
    }

    func configureSearch() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search TV Shows"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }

    func getTvshows(page: Int) {
        showLoadingView()
        NetworkManger.shared.get(.showList, showID: nil, page: page, urlString: "") { [weak self] (response: ApiResponse?) in
            self?.dismissLoadingView()
            guard let self = self else { return }
            guard let newShows = response?.shows else {
                self.alert(message: "Check Internet Connection", title: ErroMessage.unableToComplete.rawValue)
                return
            }
            DispatchQueue.main.async {
                if page == 1 {
                    self.shows = newShows
                } else {
                    self.shows.append(contentsOf: newShows)
                }
                self.collectionView.reloadData()
            }
        }
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredShows.count : shows.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TvCellCollectionViewCell.reuseID, for: indexPath) as! TvCellCollectionViewCell
        let show = isSearching ? filteredShows[indexPath.row] : shows[indexPath.row]
        cell.setCell(show: show)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedShow = isSearching ? filteredShows[indexPath.row] : shows[indexPath.row]
        let detailsVC = Details_ViewController(showID: selectedShow.id ?? 0)
        let navController = UINavigationController(rootViewController: detailsVC)
        present(navController, animated: true)
    }

    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        isSearching = !searchText.isEmpty
        filteredShows = shows.filter { $0.unwrappedName.lowercased().contains(searchText.lowercased()) }
        collectionView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        collectionView.reloadData()
    }

    // MARK: - Infinite Scrolling
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        if offsetY > contentHeight - height {
            guard loadMoreMovies else { return }
            page += 1
            getTvshows(page: page)
        }
    }
}
