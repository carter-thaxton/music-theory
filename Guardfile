
guard :test do
  watch(%r{^test/.+_test\.rb$})
  watch('test/test_helper.rb')  { 'test' }

  # pick up anything in a subdirectory of lib/ and associate with a test file directly under test/
  watch(%r{^lib/.*?([^/]+)\.rb$}) { |m| "test/#{m[1]}_test.rb" }
end
