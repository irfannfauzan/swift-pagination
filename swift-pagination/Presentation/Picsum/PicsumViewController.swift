//
//  PicsumViewController.swift
//  swift-pagination
//
//  Created by Vokal-Ican on 28/10/26.
//

import UIKit

final class PicsumViewController: UIViewController {

    // MARK: - State

    private enum ViewState {
        case loading
        case error(String)
        case empty
        case loaded
    }

    private var state: ViewState = .loading {
        didSet { render() }
    }

    // MARK: - Properties

    private let service = PicsumService()
    private var picsum: [Picsum] = []
    private var page = 1
    private var isLoadingMore = false
    private var hasMore = true
    private var loadTask: Task<Void, Never>?

    // MARK: - UI

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var retryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Coba lagi"
        return UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
            self?.loadFirstPage()
        })
    }()

    private lazy var messageStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [messageLabel, retryButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let footerSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.frame = CGRect(x: 0, y: 0, width: 0, height: 56)
        return spinner
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addAction(UIAction { [weak self] _ in self?.refresh() }, for: .valueChanged)
        return control
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.register(PicsumCell.self, forCellReuseIdentifier: PicsumCell.reuseID)
        table.refreshControl = refreshControl
        table.tableFooterView = footerSpinner
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photos"
        view.backgroundColor = .systemBackground
        setupLayout()
        loadFirstPage()
    }

    deinit {
        loadTask?.cancel()
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(messageStack)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            messageStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            messageStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    // MARK: - Render

    private func render() {
        switch state {
        case .loading:
            loadingIndicator.startAnimating()
            tableView.isHidden = true
            messageStack.isHidden = true

        case .error(let message):
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            messageStack.isHidden = false
            messageLabel.text = message
            retryButton.isHidden = false

        case .empty:
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            messageStack.isHidden = false
            messageLabel.text = "Belum ada foto"
            retryButton.isHidden = true

        case .loaded:
            loadingIndicator.stopAnimating()
            messageStack.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }

    // MARK: - Load

    private func loadFirstPage() {
        state = .loading
        page = 1
        hasMore = true
        fetch(isRefresh: true)
    }

    private func refresh() {
        page = 1
        hasMore = true
        fetch(isRefresh: true)
    }

    private func loadMore() {
        guard !isLoadingMore, hasMore, case .loaded = state else { return }
        fetch(isRefresh: false)
    }

    private func fetch(isRefresh: Bool) {
        loadTask?.cancel()
        isLoadingMore = true
        if !isRefresh { footerSpinner.startAnimating() }

        let pageToLoad = page

        loadTask = Task { [weak self] in
            guard let self else { return }
            defer {
                isLoadingMore = false
                footerSpinner.stopAnimating()
                refreshControl.endRefreshing()
            }

            do {
                let newPicsum = try await service.fetchPicsum(page: pageToLoad)
                guard !Task.isCancelled else { return }

                if isRefresh {
                    picsum = newPicsum
                } else {
                    picsum.append(contentsOf: newPicsum)
                }

                hasMore = !newPicsum.isEmpty
                page = pageToLoad + 1
                state = picsum.isEmpty ? .empty : .loaded

            } catch {
                guard !Task.isCancelled else { return }
                if picsum.isEmpty {
                    state = .error(error.localizedDescription)
                } else {
                    showToast(error.localizedDescription)      
                }
            }
        }
    }

    // MARK: - Helpers

    private func showToast(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak alert] in
            alert?.dismiss(animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension PicsumViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        picsum.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PicsumCell.reuseID, for: indexPath
        ) as? PicsumCell else {
            return UITableViewCell()
        }
        cell.configure(with: picsum[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PicsumViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= picsum.count - 5 {
            loadMore()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detail = DetailPicsumViewController(picsum: picsum[indexPath.row])
        navigationController?.pushViewController(detail, animated: true)
    }
}
