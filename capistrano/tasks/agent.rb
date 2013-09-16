namespace :rosetta do
  namespace :agent do
    desc "Set up Rosetta agent."
    task :setup, :roles => :agent do
      remote_chef("agent")
    end
  end
end
