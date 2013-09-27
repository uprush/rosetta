require File.join(File.dirname(__FILE__), "../utils.rb")

namespace :rosetta do
  namespace :indexer do
    desc "Set up Rosetta indexer."
    task :setup, :roles => "indexer" do
      remote_chef("indexer")
    end
  end
end
