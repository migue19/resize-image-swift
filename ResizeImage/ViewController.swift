//
//  ViewController.swift
//  ResizeImage
//
//  Created by Miguel Mexicano Herrera on 08/06/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var resizeImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //let urlString = "https://rockcontent.com/wp-content/uploads/2022/06/parts-url-1024x538.png.webp"
        let urlString = "https://artemis.imgix.net/giftcards/LiverpoolCover_square.jpg?fit=crop&w=960&h=570&auto=compress"
        if let url = URL(string: urlString) {
            downloadImage(from: url)
        }
    }
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
                let imageOriginal = UIImage(data: data)
                if let imageCompressData = imageOriginal?.jpeg(.low), let imageCompress = UIImage(data: imageCompressData) {
                    print(imageCompress)
                    self?.imageView.backgroundColor = .blue
                    self?.imageView.image = imageCompress
                    let imageResize = imageCompress.resizeImage(targetSize: CGSize(width: 100, height: 200))
                    self?.resizeImageView.contentMode = .center
                    self?.resizeImageView.image = imageResize
                    self?.resizeImageView.backgroundColor = .blue
                }
            }
        }
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue)
    }
    func resizeImage(targetSize: CGSize) -> UIImage? {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
