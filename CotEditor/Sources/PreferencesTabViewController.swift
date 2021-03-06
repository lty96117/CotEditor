//
//  PreferencesTabViewController.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2018-11-13.
//
//  ---------------------------------------------------------------------------
//
//  © 2018 1024jp
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Cocoa

final class PreferencesTabViewController: NSTabViewController {
    
    private var lastFrame: NSRect?
    
    
    
    // MARK: -
    // MARK: Tab View Controller Methods
    
    override var selectedTabViewItemIndex: Int {
        
        didSet {
            if self.isViewLoaded {  // avoid storing initial state (set in the storyboard)
                UserDefaults.standard[.lastPreferencesPaneIdentifier] = self.tabViewItems[selectedTabViewItemIndex].identifier as? String
            }
        }
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // workaround for that NSTabViewItem is not localized by storyboard (2018-11 macOS 10.14)
        self.localizeTabViewItems()
        
        // select last used pane
        if
            let identifier = UserDefaults.standard[.lastPreferencesPaneIdentifier],
            let item = self.tabViewItems.enumerated().first(where: { ($0.element.identifier as? String) == identifier })
        {
            self.selectedTabViewItemIndex = item.offset
        }
    }
    
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        self.switchPane(to: self.tabViewItems[self.selectedTabViewItemIndex], animated: false)
    }
    
    
    override func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        
        super.tabView(tabView, willSelect: tabViewItem)
        
        if let frame = self.lastFrame {
            tabView.selectedTabViewItem?.view?.frame = frame
        }
        
        self.lastFrame = tabViewItem?.view?.frame
    }
    
    
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        
        super.tabView(tabView, didSelect: tabViewItem)
        
        guard let tabViewItem = tabViewItem else { return assertionFailure() }
        
        self.switchPane(to: tabViewItem, animated: true)
    }
    
    
    
    // MARK: Private Methods
    
    /// resize window to fit to new view
    private func switchPane(to tabViewItem: NSTabViewItem, animated: Bool) {
        
        guard let viewFrame = self.lastFrame ?? tabViewItem.view?.frame else { return assertionFailure() }
        
        // initialize tabView's frame size
        guard let window = self.view.window else {
            self.view.frame = viewFrame
            return
        }
        
        // calculate window frame
        var frame = window.frameRect(forContentRect: viewFrame)
        frame.origin = window.frame.origin
        frame.origin.y += window.frame.height - frame.height
        
        if #available(macOS 10.13, *) {
            self.view.isHidden = true
        } else {
            // use `alphaValue` instead of `isHidden`
            // -> Because updating `isHidden` in completionHandler under macOS 10.12 causes
            //    either crash or skip initial update of the theme editor (although OK on 10.13 and above).
            self.view.alphaValue = 0
        }
        NSAnimationContext.runAnimationGroup({ context in
            context.allowsImplicitAnimation = animated
            
            window.setFrame(frame, display: false)
            
        }, completionHandler: { [weak self] in
            if #available(macOS 10.13, *) {
                self?.view.isHidden = false
            } else {
                self?.view.alphaValue = 1
            }
            window.title = tabViewItem.label
        })
    }
    
}



private extension PreferencesTabViewController {
    
    private static let ibIdentifiers: [String: String] = [
        "General": "CNJ-6L-fga",
        "Window": "5fL-58-BrZ",
        "Appearance": "icK-P1-6ta",
        "Edit": "sh3-xI-elX",
        "Format": "frU-Pc-xZT",
        "File Drop": "aO6-oS-ZGt",
        "Key Bindings": "b8q-WN-1ls",
        "Print": "UuB-iq-kOt",
        "Integration": "gEv-qP-tRM",
        ]
    
    
    /// localize tabViewItems using storyboard's .string
    func localizeTabViewItems() {
        
        for item in self.tabViewItems {
            guard
                let identifier = item.identifier as? String,
                let ibIdentifier = PreferencesTabViewController.ibIdentifiers[identifier]
                else { assertionFailure(); continue }
            
            let key = ibIdentifier + ".label"
            let localized = key.localized(tableName: "PreferencesWindow")
            
            guard key != localized else { continue }
            
            item.label = localized
        }
    }
    
}
