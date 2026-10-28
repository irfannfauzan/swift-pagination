//
//  DetailPicsumViewController.swift
//  swift-pagination
//
//  Created by Vokal-Ican on 28/10/26.
//

import UIKit

final class DetailPicsumViewController: UIViewController {

    private let picsum: Picsum
    
    private var loadTask: Task<Void, Never>?

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .secondarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(picsum: Picsum) {
        self.picsum = picsum
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = picsum.author
        view.backgroundColor = .systemBackground
        infoLabel.text = "\(picsum.author)\nUkuran asli \(picsum.size)"
        setupLayout()
        loadImage()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loadTask?.cancel()
    }

    private func setupLayout() {
        view.addSubview(imageView)
        view.addSubview(spinner)
        view.addSubview(infoLabel)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: safe.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.75),

            spinner.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),

            infoLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16)
        ])
    }

    private func loadImage() {
        guard let url = picsum.fullURL else { return }
        spinner.startAnimating()

        loadTask = Task { [weak self] in
            let image = await ImageLoader.shared.load(url)
            guard !Task.isCancelled else { return }
            self?.spinner.stopAnimating()
            self?.imageView.image = image ?? UIImage(systemName: "photo")
        }
    }
}
