import UIKit

final class ImagesListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private let segueIdentifier = "ShowSingleImage"
    private let photos: [String] = (0..<20).map { "\($0)" }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = .init(top: 12, left: 0, bottom: 12, right: 0)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == segueIdentifier,
              let vc = segue.destination as? SingleImageViewController,
              let indexPath = sender as? IndexPath else { return }

        let name = photos[indexPath.row]
        vc.image = UIImage(named: "\(name)_full_size") ?? UIImage(named: name)
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }

        configure(cell, at: indexPath)
        return cell
    }

    private func configure(_ cell: ImagesListCell, at indexPath: IndexPath) {
        let name = photos[indexPath.row]
        cell.cellImage.image = UIImage(named: name)
        cell.dateLabel.text = dateFormatter.string(from: Date())
        let isLiked = indexPath.row.isMultiple(of: 2)
        let likeImageName = isLiked ? "like_button_on" : "like_button_off"
        cell.likeButton.setImage(UIImage(named: likeImageName), for: .normal)
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photos[indexPath.row]) else { return 0 }

        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let width = tableView.bounds.width - insets.left - insets.right
        let scale = width / image.size.width
        return image.size.height * scale + insets.top + insets.bottom
    }
}
