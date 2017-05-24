$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'clarat_base/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  ###################################
  #########   ENGINE INFO   #########
  ###################################

  s.name        = 'clarat_base'
  s.version     = ClaratBase::VERSION
  s.authors     = %w(KonstantinKo Twiek NilsVollmer)
  s.email       = ['dev@clarat.org']
  s.homepage    = 'http://www.clarat.org'
  s.summary     = 'The base for all clarat projects.'
  s.description = 'The base for all clarat projects like the admin backend or'\
                  ' the frontend website.'
  s.license     = 'MIT'

  s.files =
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  ####################################
  #########   DEPENDENCIES   #########
  ####################################

  s.add_dependency 'rails', '~> 4.2'
  s.add_dependency 'bundler', '>= 1.8.4'

  s.add_dependency 'rails-i18n'
  s.add_dependency 'web-console', '~> 2.0'
  s.add_dependency 'rails-observers' # observers got extracted since rails 4
  s.add_dependency 'enumerize', '2.0.1'
  s.add_dependency 'paper_trail'
  s.add_dependency 'sanitize' # parser based sanitization
  s.add_dependency 'closure_tree'
  s.add_dependency 'aasm' # State Machine
  s.add_dependency 'friendly_id', '>= 5.0'
  s.add_dependency 'geocoder'
  s.add_dependency 'redcarpet' # Markdown processing
  s.add_dependency 'algoliasearch-rails' # indexing & search
  s.add_dependency 'easy_translate' # automated translations of database entries
  s.add_dependency 'localeapp' # manual translations (yaml-files)

  # Background processing
  s.add_dependency 'sidekiq', '~> 4.1.2'

  s.add_development_dependency 'pry-rails' # pry is awsome
  s.add_development_dependency 'hirb' # hirb makes pry output even more awesome
  s.add_development_dependency 'pry-byebug' # kickass debugging
  s.add_development_dependency 'pry-stack_explorer' # step through stack
  s.add_development_dependency 'pry-doc' # read ruby docs in console

  # test suite
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'minitest', '5.10.1' # Testing using Minitest
  s.add_development_dependency 'minitest-matchers'
  s.add_development_dependency 'minitest-line'
  s.add_development_dependency 'minitest-rails-capybara'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'launchy' # save_and_open_page
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'memory_test_fix' # Sqlite inmemory fix
  s.add_development_dependency 'rake'
  s.add_development_dependency 'database_cleaner'
  # s.add_development_dependency 'colorize' # use this when RBP quits using `colored`
  # s.add_development_dependency 'fakeredis' ! need version > 0.5.0
  s.add_development_dependency 'fakeweb', '~> 1.3'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'pry-rescue'

  # test suite additions
  s.add_development_dependency 'rails_best_practices'
  s.add_development_dependency 'brakeman' # security test: execute with 'brakeman'
  s.add_development_dependency 'rubocop' # style enforcement

  # Code Coverage
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'coveralls'

  # dev help
  s.add_development_dependency 'thin' # Replace Webrick
  s.add_development_dependency 'bullet' # Notify about n+1 queries
  s.add_development_dependency 'letter_opener' # emails in browser
  s.add_development_dependency 'timecop' # time travel!
  s.add_development_dependency 'dotenv-rails' # handle environment variables
end
