import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - @IBOutlet properties
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Static properties
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Override methods
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Private methods
    private func setupCell(){
        cellImage.layer.cornerRadius = 16
        cellImage.layer.masksToBounds = true
        
        dateLabel.backgroundColor = UIColor(named: "ypLightBlack")
        dateLabel.font = .systemFont(ofSize: 13, weight: .regular)
        dateLabel.textColor = UIColor(named: "#FFFFFF")
        addGradientBackground()
    }
    
    private func addGradientBackground() {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.colors = [
            UIColor.ypWhite.withAlphaComponent(0.2).cgColor,
            UIColor.ypDarkGray.withAlphaComponent(0.4).cgColor
        ]
        
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        gradientLayer.frame = dateLabel.bounds.insetBy(dx: -4, dy: -1)
        gradientLayer.cornerRadius = 6
        
        dateLabel.layer.insertSublayer(gradientLayer, at: 0)
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = UIBezierPath(roundedRect: gradientLayer.bounds, cornerRadius: 6).cgPath
        borderLayer.lineWidth = 0.5
        borderLayer.strokeColor = UIColor.ypWhite.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        
        gradientLayer.addSublayer(borderLayer)
    }
}
