notification :off

guard 'rake', :task => 'test' do
  watch(%r{^manifests\/(.+)\.pp$})
  watch(%r{^templates\/(.+)\.erb$})
  watch(%r{^spec\/(.+)\.rb$})
end
