//
//  ViewController.swift
//  ImageFeed
//
//  Created by Moxa on 11/01/26.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    private var imagesListServiceObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            }
            
        ImagesListService.shared.fetchPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            viewController.largeImageURL = URL(string: photos[indexPath.row].largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = ImagesListService.shared.photos.count
        photos = ImagesListService.shared.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)

        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        cell.cellImage.layer.cornerRadius = 16
        cell.cellImage.layer.masksToBounds = true
        
        cell.cellImage.addGradient()
        
        if let imageURL = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.setImage(
                with: imageURL,
                placeholder: UIImage(named: "stub") // По умолчанию ищем ассет "stub"
            ) { [weak self] _ in
                cell.cellImage.removeGradient()
                guard let self = self else { return }
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }

        cell.setIsLiked(photo.isLiked)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        guard imageWidth > 0 else { return 0 }
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.photos = ImagesListService.shared.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                let alert = UIAlertController(
                    title: "Что-то пошло не так(",
                    message: "Не удалось изменить статус лайка",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
}
