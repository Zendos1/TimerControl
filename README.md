# TimerControl

TimerControl is a customisable UIView based countdown timer control.
It represents a visible reducing arc for the remaining seconds in a defined countdown duration. 

[![Platform](https://img.shields.io/cocoapods/p/TimerControl)](https://cocoapods.org/pods/TimerControl)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-green)](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)
[![Cocoapods](https://img.shields.io/cocoapods/v/TimerControl)](https://cocoapods.org/pods/TimerControl)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/Zendos1/TimerControl/blob/master/LICENSE)

## Demo
<p align="center">
  <img width="326" height="294" src="https://raw.github.com/Zendos1/TimerControl/master/Screenshots/demo1.gif">
</p>

## Getting Started

To use TimerControl in your Xcode project. 
Include TimerControl framework in your project.
Create a UIView either programatically or in a xib or storyboard, set the type of the UIView to `TimerControlView`.
Ensure the UIView has a 1:1 aspect ratio - TimerControl will not draw and will crash the host application unless it is strictly 1:1.

### Prerequisites

* iOS 12
* Xcode 11

## Installing
### - [Swift Package Manager](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)
In Xcode goto `Xcode>File>Swift Packages>Add Package Dependency`,
Paste the below url for TimerControl into the *Repository URL* textfield
'''
https://github.com/Zendos1/TimerControl
'''

### - [Cocoapods](https://cocoapods.org/)
To include TimerControl to your project using cocoapods, add the following to your podfile
```
pod 'TimerControl'
```
To instruct cocoapods to pull down the new dependency, 
run the following command through terminal in the same folder location as the podfile.
```
pod install
```

### - [Carthage](https://github.com/Carthage/Carthage)
To include TimerControl to your project using Carthage, add the following to your Cartfile
```
github "Zendos1/TimerControl"
```
To instruct Carthage to pull down and build the new dependency,
run the following command through terminal in the same folder location as the Cartfile.
```
carthage update --platform ios
```
Carthage will pull down TimerControl framework and build to a folder called `Builds`.
In the General tab of your Xcode project, under `Frameworks, Libraries and Embedded content`, Drag the `Carthage/Builds/iOS/TimerControl.framework` into Xcode. Because TimerControl is a dynamic framework - Ensure that the framework has `Embedded` selected in the dropdown beside the framework under `Frameworks, Libraries and Embedded content`

You should also add a `New Run Script phase` under the *Build Phases* tab in Xcode. 
Add the following script:  
```
/usr/local/bin/carthage copy-frameworks
```
In the same Run Script Phase, under `Input Files`, add an entry for the new framework:
```
$(SRCROOT)/Carthage/Build/iOS/TimerControl.framework
```
The Run Script Phase entry is a Carthage solution to an issue with simulator architectures being included for frameworks during AppStore submissions. Further details can be found on the Carthage homepage linked above.
	

## Usage
There is an Example project included in the repository. 
Open the `TimerControl.xcworkspace`, The `Example` project can be seen in the File Navigator.
The Xcode *Example* target can be run on simulator to see the framework in operation.

To use TimerControl: 
Include TimerControl framework in your project using one of the above processes.
Create a UIView either programatically or in a xib or storyboard, set the type of the UIView to `TimerControlView`.
Ensure the UIView has a 1:1 aspect ratio - TimerControl will not draw and will crash the host application unless it is strictly 1:1.

The visual setup of the TimerControl can be configured before it is used by calling hte below API with the desired configurations.
If the configuration API is not called then the default values are used for all configurable options.

>`configureTimerControl(innerColor: UIColor = .gray, outerColor: UIColor = .blue, counterTextColor: UIColor = .white, arcWidth: Int = 1, arcDashPattern: TimerControlDashPattern = .none)`

The configurable values are: 
- innerColor: UIColor describing the innerOval color
- outerColor: UIColor describing the outer arc color
- counterTextColor: UIColor describing the counter text color
- arcWidth: a value between 1 and 10 describing the arc width as a proportion of the view size
- arcDashPattern: TimerControlDashPattern enum with 4 preset patterns (.none, .medium, .narrow, .wide)

To start the timer, use the below API, passing the number of desired seconds as the duration parameter: 

>`startTimer(duration: Int)`

To stop the timer, use the following API: 

> `stopTimer()`

To gain more control over the active timer, the ***TimerControlDelegate*** can be used.
Set the TimerControl delegate object to your class and implement the delegate methods below:

>`timerCompleted()`

>`timerTicked()`

This way the host application can be notified when the timer ticks and when the timer completes.

## Contributing
If you would like to contribute to TimerControl please open a [Pull Request](https://github.com/Zendos1/TimerControl/pulls) or an [Issue](https://github.com/Zendos1/TimerControl/issues)

## License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/Zendos1/TimerControl/blob/master/LICENSE) file for details