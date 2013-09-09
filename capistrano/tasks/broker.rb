namespace :rosetta do
  namespace :broker do
    desc "Set up Rosetta broker."
    task :setup, :roles => "broker" do
      # ...
      run "date"
    end
  end
end
