//
//  FeedViewController.swift
//  Marslink
//
//  Created by lyricdon on 2017/5/25.
//  Copyright © 2017年 Ray Wenderlich. All rights reserved.
//

import UIKit
import IGListKit

class FeedViewController: UIViewController {

    let loader = JournalEntryLoader()
    let pathfinder = Pathfinder()
    let wxScanner = WxScanner()
    
    let collectionView: UICollectionView = {
    
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    
        view.backgroundColor = UIColor.black
    
        return view
    
    }()
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loader.loadLatest()
        
        view.addSubview(collectionView)
        
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        pathfinder.delegate = self
        pathfinder.connect()
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = view.bounds
    }

}

extension FeedViewController: ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        // 1
        var items: [ListDiffable] = [wxScanner.currentWeather]
        items += loader.entries as [ListDiffable]
        items += pathfinder.messages as [ListDiffable]
        // 2
        return items.sorted { (left: Any, right: Any) -> Bool in
          guard let
            left = left as? DateSortable,
            let right = right as? DateSortable
            else {
              return false
          }
          return left.date > right.date
        }

    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        
        if object is Message {
          return MessageSectionController()
        } else if object is Weather {
          return WeatherSectionController()
        } else {
          return JournalSectionController()
        }

    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

// MARK: - PathfinderDelegate
extension FeedViewController: PathfinderDelegate {
  func pathfinderDidUpdateMessages(pathfinder: Pathfinder) {
    adapter.performUpdates(animated: true)
  }
}
