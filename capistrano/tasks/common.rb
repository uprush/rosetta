namespace :rosetta do
  namespace :common do
    desc "Set up Rosetta broker."
    task :execute do
      target = ENV["TARGET"] || "common"
      cmd = ENV["COMMAND"] || "date"
      run cmd, :roles => target
    end

    desc "Distribute cookbooks to target servers."
    task :dist_cookbook do
      target = ENV["TARGET"] || "common"
      rosetta = ENV["ROSETTA_HOME"] || "#{ENV["HOME"]}/rosetta"
      my_rosetta = File.join(File.dirname(__FILE__), "../../")
      servers = find_servers :role => target
      servers.each do |server|
        `rsync -avz --delete #{my_rosetta}/ #{server}:#{rosetta}/`
      end

      cmd = "sudo rsync -avz --delete #{rosetta}/chef/cookbooks/ /var/chef/cookbooks/"
      run cmd, :roles => target
    end
  end
end
