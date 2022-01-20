//
//  TutorialPageVC.swift
//  Goojess
//
//  Created by Frederick Dupray.
//  Copyright © 2017 Simon Blomqvist EHL. All rights reserved.
//

import UIKit

var tutorialPageController: TutorialPageVC?

class TutorialPageVC: UIPageViewController {

    
    override var prefersStatusBarHidden : Bool {
        
        return true
    }
    
    
    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        
        return [self.viewController("StepOne"), self.viewController("StepFour"), self.viewController("StepTwo")]
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        tutorialPageController = self
        
        if let firstViewController = orderedViewControllers.first {
            
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    fileprivate func viewController(_ name: String) -> UIViewController {
        
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    

    
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        
        guard let firstViewController = viewControllers?.first, let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
            
            return 0
        }
        
        return firstViewControllerIndex
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension TutorialPageVC: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
            
            guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            
            guard previousIndex >= 0 else {
                return nil
            }
            
            guard orderedViewControllers.count > previousIndex else {
                return nil
            }
            
            return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {
            
            guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
                
                return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            
            let orderedViewControllersCount = orderedViewControllers.count
            
            guard orderedViewControllersCount != nextIndex else {
                
                return nil
            }
            
            guard orderedViewControllersCount > nextIndex else {
                
                return nil
            }
            
            return orderedViewControllers[nextIndex]
    }
}
