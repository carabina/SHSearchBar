//
//  ViewController.swift
//  SHSearchBar
//
//  Created by Stefan Herold on 08/01/2016.
//  Copyright (c) 2016 Stefan Herold. All rights reserved.
//

import UIKit
import SHSearchBar

class ViewController: UIViewController, SHSearchBarDelegate {

    var searchBar1: SHSearchBar!
    var searchBar2: SHSearchBar!
    var searchBar3: SHSearchBar!
    var searchBar4: SHSearchBar!
    var addressSearchbarTop: SHSearchBar!
    var addressSearchbarBottom: SHSearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SHSearchBar.kDefaultRasterSize = 11.0
        SHSearchBar.kDefaultAnimationDuration = 0.25
        
        view.backgroundColor = UIColor.white

        searchBar1 = defaultSearchBar()
        view.addSubview(searchBar1)

        searchBar2 = defaultSearchBar()
        searchBar2.textField.text = "Example With Text"
        view.addSubview(searchBar2)

        let search3ImgView = UIImageView(image: UIImage(named: "icon-search")?.withRenderingMode(.alwaysTemplate))
        search3ImgView.contentMode = .center
        search3ImgView.tintColor = UIColor(red: 0.75, green: 0, blue: 0, alpha: 1)
        searchBar3 = defaultSearchBar()
        searchBar3.textField.text = "Example With Left View"
        searchBar3.textField.leftView = search3ImgView
        view.addSubview(searchBar3)

        let search4ImgView = UIImageView(image: UIImage(named: "icon-search")?.withRenderingMode(.alwaysTemplate))
        search4ImgView.contentMode = .center
        search4ImgView.tintColor = UIColor(red: 0.75, green: 0, blue: 0, alpha: 1)
        searchBar4 = defaultSearchBar()
        searchBar4.textField.textAlignment = .center
        searchBar4.textField.text = "Example With Centered Text"
        searchBar4.textField.leftView = search4ImgView
        searchBar4.isHidden = true // TODO: centered text lets the icon on the left - this is not intended!
        view.addSubview(searchBar4)

        addressSearchbarTop = defaultSearchBar()
        addressSearchbarTop.textField.text = "Example With Text"
        addressSearchbarTop.updateBackgroundWith(6, corners: [.topLeft, .topRight], color: UIColor.white)
        view.addSubview(addressSearchbarTop)

        addressSearchbarBottom = defaultSearchBar()
        addressSearchbarBottom.textField.text = "Example With Text"
        addressSearchbarBottom.updateBackgroundWith(6, corners: [.bottomLeft, .bottomRight], color: UIColor.white)
        view.addSubview(addressSearchbarBottom)

        setupConstraints()
    }
    
    private func setupConstraints() {
        let views: [String: AnyObject] = ["TLG":topLayoutGuide, "search1":searchBar1, "search2":searchBar2, "search3":searchBar3, "search4":searchBar4, "addressTop":addressSearchbarTop, "addressBottom":addressSearchbarBottom]
        let metrics = ["margin":11, "SH":44]
        
        let formatList: [String] = [
            // SearchBar
            "H:|-(margin)-[search1]-(margin)-|",
            "H:|-(margin)-[search2]-(margin)-|",
            "H:|-(margin)-[search3]-(margin)-|",
            "H:|-(margin)-[search4]-(margin)-|",
            "H:|-(margin)-[addressTop]-(margin)-|",
            "H:|-(margin)-[addressBottom]-(margin)-|",
            "V:[TLG]-(margin)-[search1(SH)]-(margin)-[search2(SH)]-(margin)-[search3(SH)]-(margin)-[search4(SH)]-(margin)-[addressTop(SH)]-(1)-[addressBottom(SH)]"
            ]
        
        for format in formatList {
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: metrics, views: views))
        }

        
    }

    private func defaultSearchBar() -> SHSearchBar {
        let bar = SHSearchBar()
        bar.delegate = self
        bar.textField.placeholder = "Example"
        bar.updateBackgroundWith(6, corners: [.allCorners], color: UIColor.white)
        bar.layer.shadowColor = UIColor.black.cgColor
        bar.layer.shadowOffset = CGSize(width: 0, height: 3)
        bar.layer.shadowRadius = 5
        bar.layer.shadowOpacity = 0.25
        return bar
    }


    // MARK: - SHSearchBarDelegate

    func searchBarShouldReturn(_ searchBar: SHSearchBar) -> Bool {
        searchBar.textField.resignFirstResponder()
        return true
    }
}

