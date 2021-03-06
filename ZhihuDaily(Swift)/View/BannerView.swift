//
//  BannerView.swift
//  ZhihuDaily(Swift)
//
//  Created by ldming on 2016/12/9.
//
//

import UIKit

//Banner Delegate
protocol BannerViewDelegate {
    func tapBanner(topStories: Story)
}

class BannerView: UIView {

    var collectionView: UICollectionView!
    var pageControl: UIPageControl!
    let pageControlHeight: CGFloat = 37
    var autoScrollTimer: Timer?
    
    //Banner Data
    var topStories = [Story]() {
        didSet {
            collectionView.reloadData()
            collectionView.contentOffset.x = UIScreen.main.bounds.size.width
        }
    }
    
    //Banner Delegate
    var delegate: BannerViewDelegate?
    
    
    //Banner 随动
    var bannerOffset: CGFloat = 0 {
        didSet {
          collectionView.visibleCells.forEach { (cell) in
            
            guard let bannerCell = cell.contentView.subviews[0] as? BannerViewCell else {
                fatalError("BannerViewCell error")
            }
            
            bannerCell.bannerImageView.frame.origin.y = min(bannerOffset, 0)
            bannerCell.bannerImageView.frame.size.height = max(frame.height - bannerOffset, frame.height)
            
            bannerCell.bannerLabelView.alpha = 1 + bannerOffset / 150
            }
            
            
        }
    }
    
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        //重新调整BannerView位置
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: Theme.bannerViewHeight)
        
        setupCollectionView()
        setupPageControl()
        configAutoScrollTimer()
    }

}



// MARK: - setup
extension BannerView {

    
    func setupCollectionView() {
        //布局
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = frame.size
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        //collectionView
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Banner")
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        addSubview(collectionView)
        
    }
    
    
    func setupPageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: frame.height - pageControlHeight, width: frame.width, height: pageControlHeight))
        pageControl.isEnabled = false
        pageControl.numberOfPages = 5
        addSubview(pageControl)
        
    }
    
    
}



// MARK: - collectionView
extension BannerView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - collectionView DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if topStories.count == 0 {
            return 0
        }
        //第一张图和最后一图增加切换功能
        return topStories.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Banner", for: indexPath)
        
        //cell数据控制
        var index: Int
        if indexPath.row == 0 {
            index = 4
        }else if indexPath.row == 6 {
            index = 0
        }else {
            index = indexPath.row - 1
        }
        
        //处理cell的复用
        if !cell.contentView.subviews.isEmpty, let cellView = cell.contentView.subviews[0] as? BannerViewCell {
            cellView.configData(topStory: topStories[index])
        }else {
            let cellView = BannerViewCell(frame: frame)
            cellView.configData(topStory: topStories[index])
            cell.contentView.addSubview(cellView)
            
        }
        
        return cell
        
    }
    
    
    // MARK: - collectionView Delegate
    
    //监听滚动
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let screenWidth = UIScreen.main.bounds.size.width
        switch collectionView.contentOffset.x {
        case 0 :
            collectionView.contentOffset.x = 5 * screenWidth
            pageControl.currentPage = 4
        case 6 * screenWidth :
            collectionView.contentOffset.x = screenWidth
            pageControl.currentPage = 0
        default:
            pageControl.currentPage = Int ((collectionView.contentOffset.x) / screenWidth) - 1
            break
        }
        
    }
    
    //控制自动轮播
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        configAutoScrollTimer()
    }
    
    
    
    //监听点击
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //delegate
        delegate?.tapBanner(topStories: topStories[pageControl.currentPage])
    }
}



// MARK: - Banner自动定时轮播
extension BannerView {
    
    func configAutoScrollTimer() {
        
        autoScrollTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(autoScrollBanner), userInfo: nil, repeats: true)
        
    }
    
    func autoScrollBanner() {
        let currentOffsetX = collectionView.contentOffset.x
        let point = CGPoint(x: currentOffsetX + UIScreen.main.bounds.size.width, y: 0)
        collectionView.setContentOffset(point, animated: true)
    }
    
}

