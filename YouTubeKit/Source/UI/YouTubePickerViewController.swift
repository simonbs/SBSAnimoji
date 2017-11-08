//
//  YouTubePickerViewController.swift
//  YouTubeKit
//
//  Created by Simon Støvring on 08/11/2017.
//  Copyright © 2017 SimonBS. All rights reserved.
//

import UIKit

@objc public protocol YouTubePickerViewControllerDelegate: class {
    func youTubePickerViewController(_ youTubePickerViewController: YouTubePickerViewController, didPickVideoWithId videoId: String)
}

@objcMembers public class YouTubePickerViewController: UITableViewController {
    private enum ReuseIdentifier: String {
        case videoCell = "videoCells"
    }
    
    public weak var delegate: YouTubePickerViewControllerDelegate?
    
    private let youTubeClient: YouTubeClient
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchResultsContainer: YouTubeSearchResultsContainer?
    private var currentURLSessionTask: URLSessionTask?
    
    public init(key: String) {
        youTubeClient = YouTubeClient(key: key)
        super.init(nibName: nil, bundle: nil)
        title = "Search YouTube"
        definesPresentationContext = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancel))
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = searchController.searchBar
        tableView.register(YouTubeSearchResultTableViewCell.self, forCellReuseIdentifier: ReuseIdentifier.videoCell.rawValue)
    }
}

private extension YouTubePickerViewController {
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    private func search(for query: String) {
        currentURLSessionTask?.cancel()
        currentURLSessionTask = youTubeClient.search(query: query) { [weak self] result in
            switch result {
            case .value(let searchResultsContainer):
                self?.didLoadSearchResultsContainer(searchResultsContainer)
            case .error(let error):
                self?.didFailLoadingSearchResultsContainer(error: error)
            }
        }
    }
    
    private func clearResults() {
        searchResultsContainer = nil
        tableView.reloadData()
    }
    
    private func didLoadSearchResultsContainer(_ searchResultsContainer: YouTubeSearchResultsContainer) {
        self.searchResultsContainer = searchResultsContainer
        tableView.reloadData()
    }
    
    private func didFailLoadingSearchResultsContainer(error: YouTubeClientError) {
        guard !isCancellationError(error) else { return }
        print(error)
    }
    
    private func isCancellationError(_ error: YouTubeClientError) -> Bool {
        if case let .networkingError(innerError) = error, (innerError as NSError).code == NSURLErrorCancelled {
            return true
        } else {
            return false
        }
    }
}

extension YouTubePickerViewController {
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return searchResultsContainer != nil ? 1 : 0
    }
    
    public override func tableView(_ tablsadeView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searchResultsContainer = searchResultsContainer {
            return searchResultsContainer.items.count
        } else {
            return 0
        }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.videoCell.rawValue)
        guard let cell = _cell as? YouTubeSearchResultTableViewCell else {
            fatalError("Cell not convertible to YouTubeSearchResultTableViewCell.")
        }
        let searchResultItem = searchResultsContainer?.items[indexPath.item]
        cell.videoNameLabel.text = searchResultItem?.snippet.title
        return cell
    }
}

extension YouTubePickerViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let searchResultItem = searchResultsContainer?.items[indexPath.item] else { return }
        delegate?.youTubePickerViewController(self, didPickVideoWithId: searchResultItem.id.videoId)
    }
}

extension YouTubePickerViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        if let query = searchController.searchBar.text, !query.isEmpty {
            search(for: query)
        } else {
            clearResults()
        }
    }
}

