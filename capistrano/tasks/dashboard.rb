require File.join(File.dirname(__FILE__), "../utils.rb")

namespace :rosetta do
  namespace :dashboard do
    desc "Set up Rosetta dashboard."
    task :setup, :roles => "dashboard" do
      remote_chef("dashboard")
    end
  end
end
