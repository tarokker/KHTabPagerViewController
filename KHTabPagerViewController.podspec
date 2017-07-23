Pod::Spec.new do |s|

  s.name          = "KHTabPagerViewController"
  s.version       = "1.0.4"
  s.summary       = "KHTabPagerViewController is a more advanced pager view controller with full RTL flipped UI support."
  s.homepage      = "https://github.com/tarokker/KHTabPagerViewController"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "Kareem Hewady" => "kareem.hewady@gmail.com" }
  s.platform      = :ios, "8.0"
  s.source        = { :git => "https://github.com/tarokker/KHTabPagerViewController.git", :tag => "v1.0.0" }
  s.source_files  = "KHTabPagerViewControllerExample/KHTabPagerViewController", "KHTabPagerViewControllerExample/KHTabPagerViewController/**/*.{h,m}"
  s.requires_arc  = true

end
