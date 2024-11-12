//
//  AGSwiper.swift
//  AGSwiper
//
//  Created by Artur Gurgul on 11/11/2024.
// Copyright © 2024 Gurgul-PRO. All rights reserved.
//

import SwiftUI
import UIKit

import SwiftUI

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension UIView {
    func calculatedHeight() -> CGFloat {
        let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        return systemLayoutSizeFitting(targetSize,
                                       withHorizontalFittingPriority: .required,
                                       verticalFittingPriority: .fittingSizeLevel).height
    }
}

public struct AGSwiperWrapper<Element: Hashable>: View {
    private let elements: [Element]
    @Binding var currentPage: Int
    @State var currentPageHeight: CGFloat = 400
    var viewBuilder: (Element) -> any View

    public init (
        currentPage: Binding<Int>,
        elements: [Element],
        @ViewBuilder viewBuilder: @escaping (Element) -> some View
    ) {
        self._currentPage = currentPage
        self.elements = elements
        self.viewBuilder = viewBuilder
    }
    
    public var body: some View {
        
          // GeometryReader { geometry in
             //   VStack {
        AGSwiper(currentPage: $currentPage, currentPageHeight: $currentPageHeight, elements: elements) {element in
                    VStack {
//                        Text("Height: \(geometry.size.height)")
//                        Text("Height: \(geometry.size.height)")
//                        Text("Height: \(geometry.size.height)")
                        //Text("Height: \(geometry.size.height)")
                        AnyView(viewBuilder(element))
                           // .fixedSize(horizontal: false, vertical: true)
                           // .background(Color.red)
                        
                    }
                    
                }
                .frame(height: currentPageHeight)
                .padding(.bottom, 10)
                    //.fixedSize(horizontal: false, vertical: true)
                   // Spacer()
            //    }
         //   }
            
        
            
        
        //.frame(height: 310)
        //.fixedSize(horizontal: false, vertical: true)
    }
}

public struct AGSwiper<Element: Hashable>: UIViewRepresentable {
    private let elements: [Element]
    @Binding var currentPage: Int
    @Binding var currentPageHeight: CGFloat
    var viewBuilder: (Element) -> any View
    
    public init (
        currentPage: Binding<Int>,
        currentPageHeight: Binding<CGFloat>,
        elements: [Element],
        @ViewBuilder viewBuilder: @escaping (Element) -> some View
    ) {
        self._currentPage = currentPage
        self._currentPageHeight = currentPageHeight
        self.elements = elements
        self.viewBuilder = viewBuilder
        
//        DispatchQueue.main.async {
//            //self.currentPageHeight = 500
//            self._currentPageHeight.wrappedValue = 500
//        self._currentPage.update()
//            //$currentPageHeight.update()
//        }
        
    }

    public func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = context.coordinator

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

// How to add additional top padding
//        stackView.spacing = 10 // Adds spacing between subviews
//        stackView.isLayoutMarginsRelativeArrangement = true
//        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            //stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: CGFloat(elements.count))
        ])
        
        //scrollView.heightAnchor.constraint(equalToConstant: 400).isActive = true
//        scrollView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
//        scrollView.contentHuggingPriority(for: .vertical)
//        scrollView.contentCompressionResistancePriority(for: .vertical)
        
        context.coordinator.stackView = stackView
        addViews(to: stackView, context: context, scrollView: scrollView)
        
        return scrollView
    }

    func addViews(to stackView: UIStackView, context: Context, scrollView: UIScrollView) {
        for element in elements {
            let childView = viewBuilder(element)
            let hostingController = UIHostingController(rootView: AnyView(childView))
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            hostingController.view.backgroundColor = .clear
            stackView.addArrangedSubview(hostingController.view)
            
            NSLayoutConstraint.activate([
                //hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                hostingController.view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
            ])
        }
    }


    public func updateUIView(_ uiView: UIScrollView, context: Context) {
//        let offsetX = CGFloat(currentPage) * uiView.frame.size.width
//        if uiView.contentOffset.x != offsetX {
//            uiView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
//        }
        DispatchQueue.main.async {
            context.coordinator.didSelect(page: currentPage)
        }
    }
    


    public class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: AGSwiper
        weak var stackView: UIStackView?
        weak var parentViewController: UIViewController?

        init(_ parent: AGSwiper) {
            self.parent = parent
        }

        public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
            didSelect(page: page)
        }
        
        public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
            
        }
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
//            if scrollView.frame.size.width < 0.1 {
//                return
//            }
            let currentPage = parent.currentPage
            let currentPageHeight = stackView?.subviews[safe: currentPage]?.calculatedHeight() ?? 0
            
            scrollView.contentOffset.y = 0
            let transition = 0.15
            
            let fPage = scrollView.contentOffset.x / scrollView.frame.size.width
            
            let pageOffset = CGFloat(currentPage) - fPage
            let pageOffsetPercentage = min(abs(pageOffset / transition), 1)
            
            let theOtherPageHeight: CGFloat
            
            switch pageOffset {
            case ..<0:
                guard let theOtherPage = stackView?.subviews[safe: parent.currentPage + 1] else {
                    theOtherPageHeight = currentPageHeight
                    break
                }
                theOtherPageHeight = theOtherPage.calculatedHeight()
                print("right \(pageOffset): \(pageOffsetPercentage)")
            case 0:
                print("same")
                theOtherPageHeight = currentPageHeight
            default:
                guard let theOtherPage = stackView?.subviews[safe: parent.currentPage - 1] else {
                    theOtherPageHeight = currentPageHeight
                    break
                }
                theOtherPageHeight = theOtherPage.calculatedHeight()
                print("left \(pageOffset): \(pageOffsetPercentage)")
            }
            
            
//            print(page, fPage,  )
//            
//            if
            
            
            
            print ("V: \(currentPageHeight) \(pageOffsetPercentage) \(theOtherPageHeight)")
            print ("VV: \(currentPageHeight * (1 - pageOffsetPercentage) + theOtherPageHeight * pageOffsetPercentage)")
            parent.currentPageHeight = currentPageHeight * (1 - pageOffsetPercentage) + theOtherPageHeight * pageOffsetPercentage
            
        }
        
        fileprivate func didSelect(page: Int) {
            parent.currentPage = page
//            guard let view = stackView?.subviews[page] else {
//                return
//            }
            
           // parent.currentPageHeight = view.calculatedHeight()
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
