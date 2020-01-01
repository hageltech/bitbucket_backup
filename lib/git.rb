module Git
  def self.all_repos(root = 'repos')
    projects = Dir.children(root)
    projects.map do |project|
      Dir.children("#{root}/#{project}").map do |repo|
        {
          dir: "#{root}/#{project}/#{repo}",
          project: project,
          name: repo,
        }
      end
    end.flatten
  end

  def self.git(dir, command, raise_on_error=true)
    Dir.chdir(dir) { system(command) }
    raise "'#{command}' exited with status #{$?.exitstatus}" if !$?.success? && raise_on_error
    $?.success?
  end

  def self.backup_repo(root, username, project, name, url)
    repo_parent = root + username + project
    repo_dir = repo_parent + name
    if File.directory?(repo_dir)
      puts "directory #{name} already exists, updating from remote"
      git(repo_dir, 'git remote update --prune')
    else
      puts "directory #{name} does not exist, cloning from remote"
      FileUtils.mkdir_p repo_parent
      git(repo_parent, "git clone --mirror #{url} #{name}")
    end
    git(repo_dir, 'git lfs fetch --all')
    puts
  end
end
