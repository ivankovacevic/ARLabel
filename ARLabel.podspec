Pod::Spec.new do |s|
  s.name         = "ARLabel"
  s.version      = "0.0.1"
  s.summary      = "Version of UILabel that adjusts label font size to fit its frame, specifically designed for animations."
  s.homepage     = "https://github.com/ivankovacevic/ARLabel"
  s.author 		   = { "Ivan Kovacevic" => "ivan.kovacevic@gmail.com" }
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.source       = { :git => "https://github.com/ivankovacevic/ARLabel.git", :commit => "577debd" }
  s.platform     = :ios, '6.0'

  s.source_files = 'ARLabel.{h,m}'
  s.frameworks   = 'CoreGraphics', 'UIKit', 'Foundation'

  s.requires_arc = true
end
