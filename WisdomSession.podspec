Pod::Spec.new do |s|
  s.name      = 'WisdomSession'
  s.version   = '0.1.8'
  s.license   = { :type => "MIT", :file => "LICENSE" }
  s.authors   = { 'tangjianfeng' => '497609288@qq.com' }
  s.homepage  = 'https://github.com/tangjianfengVS/WisdomSession'
  s.source    = { :git => 'https://github.com/tangjianfengVS/WisdomSession.git', :tag => s.version }
  s.summary   = 'Based on 【Alamofire】 library, encapsulated network framework library'

  s.description   = 'Based on 【Alamofire】 library, encapsulated network framework library(基于 Alamofire 库，封装的网络框架库).'

  s.swift_version = ['5.5', '5.6', '5.7', '5.8', '5.9', '6.0']

  # 多平台支持：不要使用 s.platform（单值属性会被覆盖，导致只支持最后一个平台）
  # 仅声明各平台 deployment_target 即可同时支持 iOS 与 macOS
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  # s.watchos.deployment_target = ''
  # s.tvos.deployment_target = ''

  s.dependency 'Alamofire'

  s.static_framework = true

  #s.source_files  = 'Source/*.swift', 'Source/*.{h,m}'

  s.default_subspecs = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Source/Core/*.swift', 'Source/Core/*.{h,m}'
  end


end
