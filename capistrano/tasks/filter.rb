require File.join(File.dirname(__FILE__), "../utils.rb")

namespace :rosetta do
  namespace :filter do
    desc "Set up Rosetta filter."
    task :setup, :roles => "filter" do
      remote_chef("filter")
    end
  end
end
