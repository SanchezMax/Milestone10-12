//
//  DetailViewController.swift
//  Milestone10-12
//
//  Created by Aleksey Novikov on 15.08.2023.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var image: UIImageView!
    var imageName: String?
    var caption: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        
        title = caption
        
        let path = getDocumentsDirectory().appendingPathComponent(imageName ?? "")
        let image = UIImage(contentsOfFile: path.path)
        self.image.image = image
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
