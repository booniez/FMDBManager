Pod::Spec.new do |s|
s.name         = "FMDBCat"
s.version      = "0.0.1"
s.summary      = "FMDB tools"
s.homepage     = "https://github.com/yuantrybest/FMDBManager"
s.license      = "MIT"
s.author       = { "JLM" => "1490305371@qq.com" }
s.platform     = :ios, "9.0"
s.source       = { :git => "https://github.com/yuantrybest/FMDBManager.git", :tag => s.version }
s.source_files  = 'FMDBLibrary/Library/*.{swift}'
