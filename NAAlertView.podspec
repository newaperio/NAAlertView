Pod::Spec.new do |s|
  s.name = 'NAAlertView'
  s.version = "0.0.3"
  s.platform = :ios
  s.summary = 'This is a styled alert view for use in iOS applications.'
  s.author = {
    'Jonathan Hooper' => 'Jonathan@newaperio.com'
  }
  s.license = 'MIT'
  s.homepage = 'https://github.com/newaperio/NAAlertView'
  s.source = {
    git: 'https://github.com/newaperio/NAAlertView.git',
    tag: '0.0.3'
  }
  s.source_files = '*.{h,m}'
end