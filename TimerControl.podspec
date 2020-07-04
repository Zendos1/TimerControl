
Pod::Spec.new do |s|
  s.name         = "TimerControl"
  s.version      = "1.0.6"
  s.summary      = "A customisable UIView countdown timer control"
  s.description  = <<-DESC
  TimerControl is a customisable UIView based countdown timer control.
  It represents a visible reducing arc for the remaining seconds in a defined countdown duration.
                   DESC
  s.homepage     = "https://github.com/Zendos1/TimerControl"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author    = "Mark Jones"
  s.platform     = :ios, "12.0"
  s.source       = { :git => "https://github.com/Zendos1/TimerControl.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.exclude_files = "Sources/**/Info.plist", "Package.swift"
  s.screenshot = "https://raw.github.com/Zendos1/TimerControl/master/Screenshots/demo1.gif"
  s.swift_version = "5.1"
end
