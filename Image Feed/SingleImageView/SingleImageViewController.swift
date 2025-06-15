import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage! {
        didSet {
            if isViewLoaded {
                updateImage()
            }
        }
    }
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        updateImage()
    }

    @IBAction private func didTapBackButton() {
        dismiss(animated: true)
    }

    @IBAction private func didTapShareButton(_ sender: UIButton) {
        let shareVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(shareVC, animated: true)
    }

    private func updateImage() {
        imageView.image = image
        rescaleAndCenterImage()
    }

    private func rescaleAndCenterImage() {
        view.layoutIfNeeded()
        let scrollSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = scrollSize.width / imageSize.width
        let vScale = scrollSize.height / imageSize.height
        let scale = min(scrollView.maximumZoomScale, max(scrollView.minimumZoomScale, max(hScale, vScale)))
        
        scrollView.setZoomScale(scale, animated: false)

        let offsetX = max((scrollView.contentSize.width - scrollSize.width) / 2, 0)
        let offsetY = max((scrollView.contentSize.height - scrollSize.height) / 2, 0)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
