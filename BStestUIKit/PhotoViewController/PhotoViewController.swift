//
//  ViewController.swift
//  BStestUIKit
//
//  Created by Evgeny on 24.09.23.
//

import UIKit

class PhotoViewController: UIViewController {
    
    private let viewModel = PhotoViewModel()
    private let photoView = PhotoView()
    
    let itemsPerRow: CGFloat = 2
    let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    var isDarkModeEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        photoView.collectionView.delegate = self
        photoView.collectionView.dataSource = self
        view.addSubview(photoView)
        photoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoView.topAnchor.constraint(equalTo: view.topAnchor),
            photoView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            photoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func fetchData() {
        viewModel.fetchPhotoes { [weak self] in
            self?.photoView.collectionView.reloadData()
        }
    }
}

extension PhotoViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photoes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath)
        configureCell(cell, forItemAt: indexPath)
        return cell
    }
    
    func configureCell(_ cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.backgroundColor = .lightGray
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let imageView = createImageView(for: cell.contentView.bounds)
        
        viewModel.loadImage(at: viewModel.photoes[indexPath.item].image ?? " ", into: imageView)
        
        let nameLabel = createNameLabel(for: cell.contentView.bounds, indexPath: indexPath)
        
        cell.contentView.addSubview(imageView)
        cell.contentView.addSubview(nameLabel)
    }
    
    func createImageView(for frame: CGRect) -> UIImageView {
        let imageView = UIImageView(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }
    
    func createNameLabel(for frame: CGRect, indexPath: IndexPath) -> UILabel {
        let nameLabel = UILabel(frame: CGRect(x: 0, y: frame.height - 40, width: frame.width, height: 40))
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = .white
        nameLabel.text = viewModel.photoes[indexPath.item].name
        nameLabel.textColor = .black
        nameLabel.layer.opacity = 0.8
        return nameLabel
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            viewModel.selectedItem = viewModel.photoes[indexPath.item]
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Ошибка", message: "Камера недоступна на вашем устройстве.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastItem = viewModel.photoes.count - 1
        if indexPath.item == lastItem && !viewModel.isLoading {
            viewModel.currentPage += 1
            fetchData()
        }
    }
}

extension PhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                if let imageData = image.jpegData(compressionQuality: 1.0) {
                    viewModel.uploadPhoto(photo: viewModel.selectedItem!, imageData: imageData, developerName: "Evgeny Smorgun") { id, error in
                        if let id = id {
                            print("Фотография успешно загружена с ID: \(id)")
                        } else if let error = error {
                            print("Ошибка загрузки фотографии: \(error.localizedDescription)")
                        }
                    }
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Метод, вызываемый при отмене выбора изображения
        picker.dismiss(animated: true, completion: nil)
    }
}
