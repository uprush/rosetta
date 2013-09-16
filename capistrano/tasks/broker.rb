require File.join(File.dirname(__FILE__), "../utils.rb")

namespace :rosetta do
  namespace :broker do
    desc "Set up Rosetta broker."
    task :setup, :roles => "broker" do
      remote_chef("broker")
    end
  end
end
