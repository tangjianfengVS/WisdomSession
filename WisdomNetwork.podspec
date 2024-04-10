Pod::Spec.new do |s|
  s.name      = 'WisdomNetwork'
  s.version   = '0.0.3'
  s.license   = { :type => "MIT", :file => "LICENSE" }
  s.authors   = { 'tangjianfeng' => '497609288@qq.com' }
  s.homepage  = 'https://github.com/tangjianfengVS/WisdomNetwork'
  s.source    = { :git => 'https://github.com/tangjianfengVS/WisdomNetwork.git', :tag => s.version }
  s.summary   = 'Based on 【Kingfisher】 library, encapsulated network framework library'

  s.description   = 'Based on 【Kingfisher】 library, encapsulated network framework library(基于 Kingfisher 库，封装的网络框架库).'

  s.platform      = :ios, '12.0'
  s.swift_version = ['5.5', '5.6', '5.7', '5.8.1']

  s.ios.deployment_target = '12.0'
  # s.osx.deployment_target = ''
  # s.watchos.deployment_target = ''
  # s.tvos.deployment_target = ''

  #s.source_files  = 'Source/*.swift', 'Source/*.{h,m}'
  s.dependency 'Alamofire', '5.8.0'
  s.static_framework = true

  s.default_subspecs = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Source/Core/*.swift', 'Source/Core/*.{h,m}'
  end


end
