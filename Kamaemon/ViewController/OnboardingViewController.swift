//
//  OnboardingViewController.swift
//  Kamaemon
//
//  Created by mad2 on 17/1/22.
//

import Foundation
import UIKit
class OnboardingViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnGetStarted: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBAction func getStartedBtnClick(_ sender: Any) {
        let controller = storyboard?.instantiateViewController(identifier: "ViewController") as! UIViewController
                    controller.modalPresentationStyle = .fullScreen
                    controller.modalTransitionStyle = .flipHorizontal
                    present(controller, animated: true, completion: nil)
    }
    
    var scrollWidth: CGFloat! = 0.0
       var scrollHeight: CGFloat! = 0.0

       //data for the slides
       var titles = ["Community Spirit","A Win Win Situation","Competitive Kindness"]
       var descs = ["Lorem ipsum dolor sit amet, consectetur adipiscing elit.","Lorem ipsum dolor sit amet, consectetur adipiscing elit.","Lorem ipsum dolor sit amet, consectetur adipiscing elit."]
       var imgs = ["hug","family","giving-person"]

       //get dynamic width and height of scrollview and save it
       override func viewDidLayoutSubviews() {
           scrollWidth = scrollView.frame.size.width
           scrollHeight = scrollView.frame.size.height
       }

       override func viewDidLoad() {
           super.viewDidLoad()
           self.view.layoutIfNeeded()
           //to call viewDidLayoutSubviews() and get dynamic width and height of scrollview

           self.scrollView.delegate = self
           scrollView.isPagingEnabled = true
           scrollView.showsHorizontalScrollIndicator = false
           scrollView.showsVerticalScrollIndicator = false

           //crete the slides and add them
           var frame = CGRect(x: 0, y: 0, width: 0, height: 0)

           for index in 0..<titles.count {
               frame.origin.x = scrollWidth * CGFloat(index)
               frame.size = CGSize(width: scrollWidth, height: scrollHeight)

               let slide = UIView(frame: frame)

               //subviews
               let imageView = UIImageView.init(image: UIImage.init(named: imgs[index]))
               imageView.frame = CGRect(x:0,y:0,width:300,height:300)
               imageView.contentMode = .scaleAspectFit
               imageView.center = CGPoint(x:scrollWidth/2,y: scrollHeight/2 - 50)
             
               let txt1 = UILabel.init(frame: CGRect(x:32,y:imageView.frame.maxY+30,width:scrollWidth-64,height:30))
               txt1.textAlignment = .center
               txt1.font = UIFont.boldSystemFont(ofSize: 20.0)
               txt1.numberOfLines = 3
               txt1.text = titles[index]

               let txt2 = UILabel.init(frame: CGRect(x:32,y:txt1.frame.maxY+10,width:scrollWidth-64,height:50))
               txt2.textAlignment = .center
               txt2.numberOfLines = 3
               txt2.font = UIFont.systemFont(ofSize: 18.0)
               txt2.text = descs[index]

               slide.addSubview(imageView)
               slide.addSubview(txt1)
               slide.addSubview(txt2)
               scrollView.addSubview(slide)

           }

           //set width of scrollview to accomodate all the slides
           scrollView.contentSize = CGSize(width: scrollWidth * CGFloat(titles.count), height: scrollHeight)

           //disable vertical scroll/bounce
           self.scrollView.contentSize.height = 1.0

           //initial state
           pageControl.numberOfPages = titles.count
           pageControl.currentPage = 0

       }

       //indicator
       @IBAction func pageChanged(_ sender: Any) {
           scrollView!.scrollRectToVisible(CGRect(x: scrollWidth * CGFloat ((pageControl?.currentPage)!), y: 0, width: scrollWidth, height: scrollHeight), animated: true)
       }

       func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
           setIndiactorForCurrentPage()
       }

       func setIndiactorForCurrentPage()  {
           let page = (scrollView?.contentOffset.x)!/scrollWidth
           pageControl?.currentPage = Int(page)
       }
}
