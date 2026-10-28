//
//  PicsumCell.swift
//  swift-pagination
//
//  Created by Vokal-Ican on 28/10/26.
//

import UIKit

final class PicsumCell: UITableViewCell {

    static let reuseID = "PhotoCell"

    // MARK: - Properties

    private var loadTask: Task<Void, Never>?
    private var currentURL: URL?

    // MARK: - UI

    private let thumbView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.backgroundColor = .secondarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let sizeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [authorLabel, sizeLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    private lazy var rowStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [thumbView, textStack])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        contentView.addSubview(rowStack)

        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            rowStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            rowStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rowStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            thumbView.widthAnchor.constraint(equalToConstant: 64),
            thumbView.heightAnchor.constraint(equalToConstant: 64)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        loadTask?.cancel()
        loadTask = nil
        currentURL = nil
        thumbView.image = nil
    }

    // MARK: - Configure

    func configure(with picsum: Picsum) {
        authorLabel.text = picsum.author
        sizeLabel.text = picsum.size
        currentURL = picsum.thumbnailURL

        guard let url = picsum.thumbnailURL else { return }

        if let cached = ImageLoader.shared.cachedImage(for: url) {
            thumbView.image = cached
            return
        }

        loadTask = Task { [weak self] in
            let image = await ImageLoader.shared.load(url)
            guard !Task.isCancelled, self?.currentURL == url else { return }
            self?.thumbView.image = image
        }
    }
}
