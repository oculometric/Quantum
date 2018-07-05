//
//  ExecCommandViewController.swift
//  Quantum
//
//  Created by Javax on 01/07/2018.
//  Copyright © 2018 Javax Inc. All rights reserved.
//

import Cocoa

class ExecCommandViewController: NSViewController {
	
	let task = Process()
	let pipe = Pipe()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.window?.title = "Execute Command"
	}
	
	override func viewDidAppear() {
		// Do view setup here.
		let path = (NSApp.orderedDocuments as! Document).executionCommand
		if (path != nil && path != "") {
			// Set the task parameters
			if FileManager.default.fileExists(atPath: path) {
				
				task.launchPath = path
				//task.arguments = ["Test"]
				
				// Create a Pipe and make the task
				// put all the output there
				
				task.standardOutput = pipe
				let main = Thread.current
				
				spinner.startAnimation(self)
				
				let delayQueue = DispatchQueue(label: "net.Javax-Inc.Quatum", qos: .userInitiated)
				let _: DispatchTimeInterval = .seconds(2)
				
				delayQueue.async {
					self.task.launch()
					while (self.task.isRunning) {
						let data = self.pipe.fileHandleForReading.readDataToEndOfFile()
						let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
						self.perform(#selector (ExecCommandViewController.setText), on: main, with: output! as String, waitUntilDone: false)
					}
					self.perform(#selector (ExecCommandViewController.stopAnimating), on: main, with: nil, waitUntilDone: false)
				}
			} else {
				setText(t: "Command executable not found.")
			}
			
		} else {
			setText(t: "No execution command found.")
		}
	}
	
	@IBOutlet var spinner: NSProgressIndicator!
	
	@IBOutlet var outputView: NSTextView!
	
	@objc func setText (t:String) {
		self.outputView.string = "\n" + self.outputView.string + t
		Swift.print (t)
	}
	
	@objc func stopAnimating () {
		self.spinner.stopAnimation(self)
		let data = self.pipe.fileHandleForReading.readDataToEndOfFile()
		let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
		setText(t: output! as String)
	}
	
	@IBAction func cancelButton(_ sender: Any) {
		if (task.isRunning) {
			task.terminate()
			spinner.stopAnimation(sender)
		}
		self.dismiss(sender)
		//self.view.window?.close()
	}
	
}
