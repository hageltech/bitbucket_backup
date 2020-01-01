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

  def self.push(dir, target)
    puts "Pushing '#{dir}' to '#{target}'"
    git(dir, 'git remote get-url bitbucket', false) ||
      git(dir, "git remote add --mirror=push bitbucket #{target}")
    git(dir, 'git push --mirror bitbucket')
  end
end
