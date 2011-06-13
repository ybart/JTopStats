namespace :xml do
  desc "Increment J-Top ids by one and references"
  task :fix do
    if ENV['path'].nil?
      puts "You should define 'path' environment variable."
      next
    end

    jtop = false
    File.open(ENV['path'], 'r') {|f|
      File.open(ENV['path'] + '.fixed', 'w') do |out|
        while line = f.readline do
          line = line.gsub(/<id_jTop>([0-9]+)<\/id_jTop>/) { |m|"<id_jTop>#{$1.to_i+1}</id_jTop>" }
          line = line.gsub(/<id>([0-9]+)<\/id>/) { |m|"<id>#{$1.to_i+1}</id>" } if jtop
          jtop = /<jTop>/.match line
          out.puts line
        end
      end
    }
  end
end