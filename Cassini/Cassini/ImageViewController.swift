//
//  ImageViewController.swift
//  Cassini
//
//  Created by Mark on 6/30/16.
//  Copyright © 2016 Mark. All rights reserved.
//
//This time we create imageView in code instead of dragging in

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    //Model
    var imageURL: URL? {
        didSet {
            image = nil
            if view.window != nil {
                print("fetch image")
                fetchImage()
            }
        }
    }
    
    //View
    @IBOutlet weak var scollView: UIScrollView! {
        didSet {
            scollView.contentSize = imageView.frame.size
            scollView.delegate = self
            scollView.minimumZoomScale = 0.03
            scollView.maximumZoomScale = 1.3
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    fileprivate func fetchImage() {
        if let url = imageURL{
            //same thing as scrollView outlet in image set
            spinner?.startAnimating()
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async{
                let contentOfURL = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if url == self.imageURL{
                        print("I am in current window and ready to update UI")
                        if let imageData = contentOfURL {
                            self.image = UIImage(data: imageData)
                        } else {
                            self.spinner?.stopAnimating()
                            print("Couldn't fetch image data")
                        }
                    } else {
                        print("Fetching is crossing fire in different windows")
                    }
                }
            }
        }
        
    }
    
    //View
    fileprivate var imageView = UIImageView()
    
    //use computed property to save time so that every time when we want to set new image,
    //we can just say image = ...
    fileprivate var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scollView?.contentSize = imageView.frame.size
            spinner?.stopAnimating()
        }
    }
    
    //This is the place to fire off expensive operations like fetching data
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scollView.addSubview(imageView)
        
        
        // Do any additional setup after loading the view.
    }
    
}
