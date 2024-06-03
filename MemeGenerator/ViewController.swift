//
//  ViewController.swift
//  MemeGenerator
//
//  Created by Olha Pylypiv on 20.05.2024.
//

import UIKit

enum TextPosition {
    case top, bottom
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    var memeImage: UIImage? {
        didSet {
            imageView.image = memeImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Meme Generator"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPictureTapped))
    }
    
    @objc func importPictureTapped() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func setTopText(_ sender: UIButton) {
        guard imageView.image != nil else {return}
        let ac = UIAlertController(title: "Enter top text", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let setTopTextAction = UIAlertAction(title: "Done", style: .default) {
            [weak self, weak ac] _ in
            guard let text = ac?.textFields?[0].text else {return}
            self?.setTextOnImage(text: text, position: .top)
        }
        ac.addAction(setTopTextAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func setBottomText(_ sender: UIButton) {
        guard imageView.image != nil else {return}
        let ac = UIAlertController(title: "Enter bottom text", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let setBottomTextAction = UIAlertAction(title: "Done", style: .default) {
            [weak self, weak ac] _ in
            guard let text = ac?.textFields?[0].text else {return}
            self?.setTextOnImage(text: text, position: .bottom)
        }
        ac.addAction(setBottomTextAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        guard let image = memeImage else {
            print("No image found.")
            return
        }
        //let imageData = image.jpegData(compressionQuality: 0.8)
        let activityVC = UIActivityViewController(activityItems: [image as Any], applicationActivities: [])
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.saveImageToPhotoLibrary(image)
            }
        }
        present(activityVC, animated: true)
    }
    
    func saveImageToPhotoLibrary(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your meme image has been\n saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        memeImage = image
        dismiss(animated: true)
    }
    
    func setTextOnImage(text: String, position: TextPosition ) {
        guard let image = imageView.image else {return}
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: image.size.width, height: image.size.height))
        let img = renderer.image {
            ctx in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key : Any] = [
                .font : UIFont(name: "Impact", size: 75) ?? UIFont.systemFont(ofSize: 65),
                .paragraphStyle : paragraphStyle,
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -1.0
            ]
            
            let attributedString = NSAttributedString(string: text, attributes: attrs)
            let textHeight = attributedString.size().height
            let textRect: CGRect
            switch position {
            case .top:
                textRect = CGRect(x: 0, y: 0, width: image.size.width, height: textHeight)
            case .bottom:
                textRect = CGRect(x: 0, y: image.size.height - textHeight, width: image.size.width, height: textHeight)
            }
            image.draw(at: CGPoint(x: 0, y: 0))
            attributedString.draw(with: textRect, options: .usesLineFragmentOrigin, context: nil)
        }
        memeImage = img
    }
}

