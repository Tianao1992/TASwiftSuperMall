//
//  HomeViewController.swift
//  TASwiftSuperMall
//
//  Created by tianao on 2021/1/27.
//

import UIKit

class HomeViewController: UIViewController {
      
    // 轮播图数据源
    lazy var dataArr = [HomeListModel]()
    var collectionView: UICollectionView!
    static var collectionViewID = "collectionViewID"
    var timer: Timer? = nil
    var currendindex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "首页"
        setColletionView()
        loadData()

        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(travelingCollectionView), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer!, forMode: RunLoop.Mode.common)
        
    }
    
    func setColletionView() {
        let size  = CGRect(x: 0, y: nav_top, width: screenWidth, height: 300)
        let layout = UICollectionViewFlowLayout.init()
     
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: screenWidth, height: 300)
        collectionView = UICollectionView(frame: size, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.register(UINib(nibName: "HomeHeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Self.collectionViewID)
        
        view.addSubview(collectionView)
    }
    //请求轮播图数据
    func  loadData(){
        Network.GET(url: API.HomeAPi).success { [weak self ]json in
            let arrs = JSON(json)["data"]["banner"]["list"].arrayObject
            guard let models = arrs?.kj.modelArray(HomeListModel.self) else {return}
            self?.dataArr.append(contentsOf: models)
            self?.collectionView.reloadData()
        }.failed { (error) in
            print(error)
        }
    }
    
    //定时器方法
    @objc func travelingCollectionView(){
       
        guard  let currIndexPath = collectionView.indexPathsForVisibleItems.last else {
            print("Items 为nil")
            return
        }
        let  currIndexPathReset = IndexPath(item: currIndexPath.item, section: 50)
        collectionView.scrollToItem(at: currIndexPathReset, at: .left, animated: false)
        var  nextItme = currIndexPathReset.item + 1
        var  nextSection = currIndexPathReset.section
        if nextItme == self.dataArr.count {
             nextItme = 0
             nextSection += 1
        }
        
        let nextPath = IndexPath(item: nextItme, section: nextSection)
        collectionView.scrollToItem(at: nextPath, at: .left, animated: true)

    }
    func stopTimer(){
        timer?.invalidate()
        timer = nil
    }
    
    func openTimer(){
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(travelingCollectionView), userInfo: nil, repeats: true)
    
        RunLoop.main.add(self.timer!, forMode: RunLoop.Mode.common)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
}


extension HomeViewController: UICollectionViewDelegate {
   
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataArr.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //将50分区看做一组图片
        100
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.collectionViewID, for: indexPath) as! HomeHeaderCollectionViewCell
        let model = dataArr[indexPath.row]
        cell.titleLab.text = model.title
        cell.imageView.kf.setImage(with: URL(string:model.image))
        return cell
    }
    
   
    
  
    
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        openTimer()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if(collectionView.contentOffset.x > 0){
//            currendindex = (currendindex + 1) % dataArr.count
//        }else{
//            currendindex = (currendindex - 1 + dataArr.count) % dataArr.count
//        }
        
    }
}
