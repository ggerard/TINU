//
//  EFIPartitionMounterUIClasses.swift
//  TINU
//
//  Created by Pietro Caruso on 08/08/18.
//  Copyright © 2018 Pietro Caruso. All rights reserved.
//

import Cocoa

#if (!macOnlyMode && TINU) || (!TINU && isTool)
public class EFIPartitionToolInterface{
	public class EFIPartitionItem: ShadowView{
		
		public let tileHeight: CGFloat = 60
		
		let titleLabel = NSTextField()
        let placeHolderLabel = NSTextField()
        
		let mountButton = NSButton()
		let unmountButton = NSButton()
        let editConfigButton = NSButton()
		let showInFinderButton = NSButton()
        let ejectButton = NSButton()
		let coverView = NSView()
		
		let spinner = NSProgressIndicator()
		
        var hasConfig = false
		var isMounted = false
        
        var isEjectable = false
        
		var bsdid: String = ""
		
		var partitions: [PartitionItem] = []
        
        var isBar = false
		
		public override func draw(_ dirtyRect: NSRect) {
			super.draw(dirtyRect)
			
			let buttonWidth: CGFloat = 170
			let buttonsHeigth: CGFloat = 32
			
			let tileWidth = self.frame.width / 3.2
			let margin: CGFloat = self.frame.width * 0.015625 //(self.frame.width - ((self.frame.width / 3.2) * 3)) / 4
			
			self.wantsLayer = true
			self.needsLayout = true
			
			titleLabel.isEditable = false
			titleLabel.isSelectable = false
			titleLabel.drawsBackground = false
			titleLabel.isBordered = false
			titleLabel.isBezeled = false
			titleLabel.alignment = .left
			
			titleLabel.frame.origin = NSPoint(x: margin, y: self.frame.height - 29)
			titleLabel.frame.size = NSSize(width: self.frame.size.width - (margin * 3) - 24, height: 24)
			titleLabel.font = NSFont.boldSystemFont(ofSize: 20)//NSFont.systemFont(ofSize: 30)
			
			self.addSubview(titleLabel)
            
			mountButton.title = "Mount EFI partition"
			mountButton.bezelStyle = .rounded
			mountButton.setButtonType(.momentaryPushIn)
			
			mountButton.frame.size = NSSize(width: buttonWidth, height: buttonsHeigth)
			
			mountButton.frame.origin = NSPoint(x: self.frame.size.width - buttonWidth - margin / 2, y: 5)
			
			mountButton.font = NSFont.boldSystemFont(ofSize: 13)
			mountButton.isContinuous = true
			mountButton.target = self
			mountButton.action = #selector(EFIPartitionItem.mountPartition(_:))
			
			self.addSubview(mountButton)
			
			unmountButton.title = "Unmount EFI partition"
			unmountButton.bezelStyle = .rounded
			unmountButton.setButtonType(.momentaryPushIn)
			
			unmountButton.frame.size = mountButton.frame.size
			
			unmountButton.frame.origin = mountButton.frame.origin
			
			unmountButton.font = NSFont.boldSystemFont(ofSize: 13)
			unmountButton.isContinuous = true
			unmountButton.target = self
			unmountButton.action = #selector(EFIPartitionItem.unmountPartition(_:))
			
			self.addSubview(unmountButton)
			
			showInFinderButton.title = "Open in Finder"
			showInFinderButton.bezelStyle = .rounded
			showInFinderButton.setButtonType(.momentaryPushIn)
			
			showInFinderButton.frame.size = NSSize(width: buttonWidth, height: buttonsHeigth)
			
			showInFinderButton.frame.origin = NSPoint(x: margin / 2, y: 5)
			
			showInFinderButton.font = NSFont.systemFont(ofSize: 13)
			showInFinderButton.isContinuous = true
			showInFinderButton.target = self
			showInFinderButton.action = #selector(EFIPartitionItem.showPartition(_:))
			
			self.addSubview(showInFinderButton)
            
            #if !macOnlyMode
            
            editConfigButton.title = "Edit config.plist"
            editConfigButton.bezelStyle = .rounded
            editConfigButton.setButtonType(.momentaryPushIn)
            
            editConfigButton.frame.size = NSSize(width: buttonWidth, height: buttonsHeigth)
            
            editConfigButton.frame.origin = NSPoint(x: showInFinderButton.frame.origin.x + showInFinderButton.frame.size.width + 5, y: 5)
            
            editConfigButton.font = NSFont.systemFont(ofSize: 13)
            editConfigButton.isContinuous = true
            editConfigButton.target = self
            editConfigButton.action = #selector(EFIPartitionItem.editConfig(_:))
            
            self.addSubview(editConfigButton)
            
            #endif
            
            ejectButton.title = ""
            ejectButton.bezelStyle = .texturedRounded
            ejectButton.setButtonType(.momentaryPushIn)
            ejectButton.isBordered = false
            
            ejectButton.imageScaling = .scaleProportionallyUpOrDown
            ejectButton.imagePosition = .imageOnly
            ejectButton.image = IconsManager.shared.getIconFor(path: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/EjectMediaIcon.icns", name: "EFIIcon")
            
            ejectButton.frame.size = NSSize(width: titleLabel.frame.height, height: titleLabel.frame.height)
            
            ejectButton.frame.origin = NSPoint(x: titleLabel.frame.size.width + margin * 2, y: titleLabel.frame.origin.y)
            
            ejectButton.isContinuous = true
            ejectButton.target = self
            ejectButton.action = #selector(EFIPartitionItem.ejectDrive(_:))
            
            self.addSubview(ejectButton)
			
			spinner.style = .spinningStyle
			
			spinner.frame.size = NSSize(width: 30, height: 30)
			
			spinner.frame.origin = NSPoint(x: (self.frame.width / 2) - (spinner.frame.size.width / 2), y: (self.frame.height / 2) - (spinner.frame.size.height / 2))
			
			coverView.addSubview(spinner)
			coverView.frame.size = self.frame.size
			coverView.frame.origin = NSPoint.zero
			coverView.backgroundColor = .controlColor
			coverView.wantsLayer = true
			coverView.layer?.opacity = 0.7
			coverView.layer?.cornerRadius = (self.layer?.cornerRadius)!
			coverView.layer?.zPosition = 10
			
			self.addSubview(coverView)
            
            self.spinner.isDisplayedWhenStopped = false
            self.spinner.usesThreadedAnimation = true
			
            let partCount = partitions.count
			
			if partCount == 0{
				
				placeHolderLabel.isEditable = false
				placeHolderLabel.isSelectable = false
				placeHolderLabel.drawsBackground = false
				placeHolderLabel.isBordered = false
				placeHolderLabel.isBezeled = false
				placeHolderLabel.alignment = .left
				
				placeHolderLabel.frame.origin = NSPoint(x: 10, y: titleLabel.frame.origin.y - (tileHeight / 2))
				placeHolderLabel.frame.size = NSSize(width: self.frame.size.width - 20 , height: 28)
				placeHolderLabel.font = NSFont.systemFont(ofSize: 18)
				
				placeHolderLabel.stringValue = "No mounted partitions found"
				
				self.addSubview(placeHolderLabel)
				
			}else{
				
                var alternate: CGFloat = 0
				var prev = titleLabel.frame.origin.y - self.tileHeight - 15
				
				Swift.print("Adding tiles for drive: \(titleLabel.stringValue)")
                
                var distance: CGFloat = 0
                
                distance = 0
                
                /*
                if partCount < 3{
                    distance = (tileWidth + margin) / CGFloat(partCount)
                }*/
				
				for partition in partitions{
					partition.frame.size = CGSize(width: tileWidth, height: tileHeight)
					
					partition.frame.origin.y = prev
					
                    partition.frame.origin.x = (tileWidth * alternate) + (margin * (alternate + 1)) + distance
                    
                    if alternate == 2{
                        prev -= self.tileHeight + margin
                        alternate = 0
                    }else{
                        alternate += 1
                    }
                    
					self.addSubview(partition)
					
					Swift.print("  Tile added: \(partition.nameLabel.stringValue)")
				}
				
			}
            
            /*
            for c in self.subviews{
                if let l = c as? NSTextField{
                    l.drawsBackground = true
                    (l as NSView).backgroundColor = (l.superview! as NSView).backgroundColor
                }
                
                //c.backgroundColor = .red
            }*/
            
            checkMounted()
		}
        
        override public func updateLayer() {
            coverView.backgroundColor = .controlColor
            self.backgroundColor = .controlBackgroundColor
        }
		
		@objc private func mountPartition(_ sender: Any){
            Swift.print("--button clicked")
            
            if let controller = self.window?.contentViewController as? EFIPartitionMounterViewController{
                Swift.print("--got controller")
                changeLoadMode(enabled: true)
                Swift.print("--enabled load")
				DispatchQueue.global(qos: .background).async {
                    Swift.print("--entered background process")
					self.isMounted = controller.eFIManager.mountPartition(self.bsdid)
                    if !self.hasConfig && self.isMounted{
                        if let mountPoint = dm.getDevicePropertyInfoNew(self.bsdid, propertyName: "MountPoint"){
                            self.hasConfig = FileManager.default.fileExists(atPath: mountPoint + "/EFI/CLOVER/config.plist")
                        }
                    }
                    Swift.print("--mount called")
                    DispatchQueue.main.async {
                        self.checkMounted()
                        Swift.print("--mounted checked")
                    }
                }
            }
        }
        
        @objc private func unmountPartition(_ sender: Any){
            if let controller = self.window?.contentViewController as? EFIPartitionMounterViewController{
                changeLoadMode(enabled: true)
                DispatchQueue.global(qos: .background).async {
                    self.isMounted = !controller.eFIManager.unmountPartition(self.bsdid)
                    DispatchQueue.main.async {
                        self.checkMounted()
                    }
                }
            }
        }
        
        @objc private func showPartition(_ sender: Any){
            DispatchQueue.global(qos: .background).async {
                if let mountPoint = dm.getDevicePropertyInfoNew(self.bsdid, propertyName: "MountPoint"){
                    NSWorkspace.shared().open(URL(fileURLWithPath: mountPoint, isDirectory: true))
                }
            }
        }
        
        #if !macOnlyMode
        @objc private func editConfig(_ sender: Any)
        {
            DispatchQueue.global(qos: .background).async
                {
                    if let mountPoint = dm.getDevicePropertyInfoNew(self.bsdid, propertyName: "MountPoint")
                    {
                        if !NSWorkspace.shared().openFile(mountPoint + "/EFI/CLOVER/config.plist", withApplication: "Clover Configurator")
                        {
                            DispatchQueue.main.sync
                                {
                                    if !dialogYesNo(question: "Download clover configurator?", text: "Clover configurator is not installed in your system, do you want to download and install it?", style: .informational)
                                    {
                                        NSWorkspace.shared().open(URL(string: "https://mackie100projects.altervista.org/download-clover-configurator/")!)
                                    }
                                    else
                                    {
                                        if !dialogYesNo(question: "Open \"config.plist\" with another editor?", text: "You choose to not download \"Clover Configurator\", do you want to edit your \"config.plist\" file with another app?" , style: .informational)
                                        {
                                            
                                            if !NSWorkspace.shared().openFile(mountPoint + "/EFI/CLOVER/config.plist")
                                            {
                                                msgBoxWarning("Impossible to open \"config.plist\"!", "Impossible to find an app to open the \"config.plist\" file!")
                                            }
                                        }
                                    }
                            }
                        }
                    }
            }
        }
        #endif
        
        @objc private func ejectDrive(_ sender: Any){
            changeLoadMode(enabled: true)
            DispatchQueue.global(qos: .background).async{
                
                let driveID = dm.getDriveBSDIDFromVolumeBSDID(volumeID: self.bsdid)
                
                var res = false
                
                var text = ""
                
                text = getOut(cmd: "diskutil unmountDisk \(driveID)")
                
                res = (text.contains("Unmount of all volumes on") && text.contains("was successful")) || (text.isEmpty)
                
                if res{
                    log("Drive unmounted with success: \(driveID)")
                    
                    DispatchQueue.main.async {
                        
                        
                        if let controler = self.window?.windowController?.contentViewController as? EFIPartitionMounterViewController{
                            
                            let disk = self.titleLabel.stringValue
                            msgBox("You can remove \"\(disk)\"", "Now it's safe to remove \"\(disk)\" from the computer", .informational)
                            
                            self.checkMounted()
                            
                            controler.refresh(controler)
                        }else{
                        
                            self.checkMounted()
                            
                        }
                        
                        
                    }
                    
                }else{
                    log("Drive not unmounted, error generated: \(text)")
                    
                    msgBoxWarning("Impossible to eject \"\(driveID)\"", "There was an error while trying to eject this disk: \(driveID)\n\nDiagnostics info: \n\nCommand executed: diskutil unmountDisk \(driveID)\nOutput: \(text)")
                }
            }
        }
        
		func checkMounted(){
			
            changeLoadMode(enabled: false)
            
			showInFinderButton.isHidden = !isMounted || sharedIsOnRecovery
			unmountButton.isHidden = !isMounted
			
			mountButton.isHidden = isMounted
            
            editConfigButton.isHidden = !(isMounted && hasConfig && !sharedIsOnRecovery)
            
            ejectButton.isHidden = !isEjectable || (isMounted && partitions.isEmpty)
            
		}
        
        private func changeLoadMode(enabled: Bool){
            
            mountButton.isEnabled = !enabled
            unmountButton.isEnabled = !enabled
            showInFinderButton.isEnabled = !enabled
            editConfigButton.isEnabled = !enabled
            ejectButton.isEnabled = !enabled
            
            coverView.isHidden = !enabled
            
            if enabled{
                spinner.startAnimation(coverView)
            }else{
                spinner.stopAnimation(coverView)
            }
        }
		
	}
    
    
	
	public class PartitionItem: NSView {
		let imageView = NSImageView()
		let nameLabel = NSTextField()
		
		override public func draw(_ dirtyRect: NSRect) {
            
            //self.backgroundColor = .red
            
			imageView.frame.size = NSSize(width: self.frame.size.height, height: self.frame.size.height)
			imageView.frame.origin = NSPoint.zero
			imageView.imageScaling = .scaleProportionallyUpOrDown
			imageView.isEditable = false
			
			self.addSubview(imageView)
			
			nameLabel.isEditable = false
			nameLabel.isSelectable = false
			nameLabel.drawsBackground = false
			nameLabel.isBordered = false
			nameLabel.isBezeled = false
			nameLabel.alignment = .left
			
			var h: CGFloat = 22
			
            let div = Int(nameLabel.stringValue.count / 16)
            
            if div < 3{
				h *= CGFloat(div + 1)
            }else{
                h *= 3
            }
			
			nameLabel.frame.origin = NSPoint(x: self.frame.size.height, y: (self.frame.height / 2) - (h / 2))
			nameLabel.frame.size = NSSize(width: self.frame.size.width - self.frame.size.height, height: h)
			nameLabel.font = NSFont.systemFont(ofSize: 15)
			
			self.addSubview(nameLabel)
            
		}
		
        
        
	}
}
#endif

