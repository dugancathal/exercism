require './test/test_helper'

require 'vcr'

test_dir = File.join(FileUtils.pwd, 'test/fixtures')

VCR.configure do |c|
  c.cassette_library_dir = File.join(test_dir, 'vcr_cassettes')
  c.hook_into :fakeweb
end

require 'approvals'
Approvals.configure do |c|
  c.approvals_path = File.join(test_dir, 'approvals') + '/'
end

class ApiTest < Minitest::Test

  def project_dir
    '/tmp'
  end

  def home
    'test/fixtures/home'
  end

  def teardown
    FileUtils.rm_rf File.join(project_dir, 'ruby')
    FileUtils.rm_rf File.join(project_dir, 'javascript')
  end

  def test_fetch_assignment_from_api
    assignment_dir = File.join(project_dir, 'ruby', 'bob')
    readme_path = File.join(assignment_dir, 'README.md')
    tests_path = File.join(assignment_dir, 'test.rb')

    Exercism.stub(:home, home) do
      VCR.use_cassette('alice-gets-bob') do
        Exercism::Api.new('http://localhost:4567', Exercism.user, project_dir).fetch

        Approvals.verify(File.read(readme_path), :name => 'alice_gets_bob_readme', :format => :txt)
        Approvals.verify(File.read(tests_path), :name => 'alice_gets_bob_tests', :format => :txt)
      end
    end
  end

  def test_fetch_upcoming_assignment_from_api
    assignment_dir = File.join(project_dir, 'ruby', 'word-count')
    readme_path = File.join(assignment_dir, 'README.md')
    tests_path = File.join(assignment_dir, 'test.rb')

    Exercism.stub(:home, home) do
      VCR.use_cassette('alice-gets-word-count') do
        Exercism::Api.new('http://localhost:4567', Exercism.user, project_dir).peek

        Approvals.verify(File.read(readme_path), :name => 'alice_gets_word_count_readme', :format => :txt)
        Approvals.verify(File.read(tests_path), :name => 'alice_gets_word_count_tests', :format => :txt)
      end
    end
  end

  def test_send_assignment_to_api
    assignment_dir = File.join(project_dir, 'ruby', 'bob')
    FileUtils.mkdir_p(assignment_dir)
    submission = File.join(assignment_dir, 'bob.rb')
    File.open(submission, 'w') do |f|
      f.write "puts 'hello world'"
    end

    Exercism.stub(:home, home) do
      VCR.use_cassette('alice-submits-bob') do
        response = Exercism::Api.new('http://localhost:4567', Exercism.user).submit(submission)
        assert_equal 201, response.status
      end
    end
  end

  def test_send_stash_to_api
    submission = File.join(FileUtils.pwd, 'bob.rb')
    File.open(submission, 'w') do |f|
      f.write "puts 'hello world'"
    end

    Exercism.stub(:home, home) do
      VCR.use_cassette('alice-submits-stash') do
        response = Exercism::Api.new('http://192.168.213.37:4567', Exercism.user).stash(submission)
        assert_equal 201, response.status
      end
    end
  end

  def test_fetch_stash_from_api
    Exercism.stub(:home, home) do
      VCR.use_cassette('alice-gets-stash') do
        response = Exercism::Api.new('http://192.168.213.37:4567', Exercism.user).loot
        assert response
      end
    end
  end

end
