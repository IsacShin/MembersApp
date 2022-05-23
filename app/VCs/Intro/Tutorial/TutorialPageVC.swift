//
//  TutorialPageVC.swift
//  app
//
//  Created by 신이삭 on 2021/05/27.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit

class TutorialPageVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    lazy var VCArray:[UIViewController] = {
        return [self.VCInstance(name: "TutorialPage1VC"),
                self.VCInstance(name: "TutorialPage2VC"),
                self.VCInstance(name: "TutorialPage3VC"),
                self.VCInstance(name: "TutorialPage4VC")]
    }()
    
    private func VCInstance(name: String)->UIViewController{
        return UIStoryboard(name: "Tutorial", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
        
        if let firstVC = VCArray.first{
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews{
            if view is UIScrollView{
                view.frame = UIScreen.main.bounds
            }else if view is UIPageControl{
                view.backgroundColor = UIColor.clear
            }
        }
    }
    

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = VCArray.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else{
            return nil
        }
        
        guard VCArray.count > previousIndex else{
            return nil
        }
        
        return VCArray[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = VCArray.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < VCArray.count else{
            return nil
        }
        
        guard VCArray.count > nextIndex else{
            return nil
        }
        
        return VCArray[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        
        if let vc = pageViewController.viewControllers?.first {
            if let parent = vc.parent?.parent as? TutorialVC {
                parent.pageControl.currentPage = vc.view.tag
            }
        }
    }
}
