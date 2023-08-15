//
//  TableViewController.swift
//  Milestone10-12
//
//  Created by Aleksey Novikov on 15.08.2023.
//

import UIKit

class TableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var photos = [Photo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(takePhoto))
        
        let defaults = UserDefaults.standard
        
        if let savedData = defaults.object(forKey: "Photos") as? Data {
            let decoder = JSONDecoder()
            
            do {
                photos = try decoder.decode([Photo].self, from: savedData)
            } catch {
                print("Failed to load photos.")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Photo", for: indexPath)
        cell.textLabel?.text = photos[indexPath.row].caption
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.imageName = photos[indexPath.row].imageName
            vc.caption = photos[indexPath.row].caption
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        dismiss(animated: true) {
            self.giveCaption(to: imageName)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    @objc func takePhoto() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .camera
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(picker.sourceType) {
            present(picker, animated: true)
        } else {
            let ac = UIAlertController(title: "Error", message: "Camera is not available", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
        }
    }
    
    func giveCaption(to image: String) {
        var caption = ""
        
        let ac = UIAlertController(title: "Excellent", message: "Now give this photo a caption", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(
            UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
                caption = ac?.textFields?[0].text ?? image
                let photo = Photo(imageName: image, caption: caption)
                self?.photos.append(photo)
                self?.save()
                self?.tableView.reloadData()
            }
        )
        present(ac, animated: true)
    }
    
    func save() {
        let encoder = JSONEncoder()
        
        if let savedData = try? encoder.encode(photos) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "Photos")
        } else {
            print("Failed to save photos.")
        }
    }
}

