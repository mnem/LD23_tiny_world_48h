REDISTS = {
    :osx => 'https://bitbucket.org/rude/love/downloads/love-0.8.0-macosx-ub.zip',
    :w32 => 'https://bitbucket.org/rude/love/downloads/love-0.8.0-win-x86.zip',
    :w64 => 'https://bitbucket.org/rude/love/downloads/love-0.8.0-win-x64.zip'
}

NAME = 'LD48_Tiny_Worlds_-_mnem'

def fetch_and_extract_redist(prefix, src)
    archive = "redist/#{prefix}/#{File.basename src}"
    if not File.exists? archive
        puts "Fetching redist for #{prefix}"
        `curl #{src} --create-dirs -Lo #{archive}`
        `unzip #{archive} -d #{File.dirname archive}`
    end
end

desc "Ensures the redistributable archives are downloaded"
task :ensure_redist do
    REDISTS.each { |prefix, src| fetch_and_extract_redist prefix.to_s, src }
end

desc "Create love archive"
task :create_love do
    puts 'Making love'
    `rm -Rf dist/love`
    `mkdir -p dist/love`
    `cp README.md dist/love`
    `cd src;zip -r ../dist/love/#{NAME}.love *`
    puts 'Making love archive'
    `cd dist/love;zip #{NAME}-love.zip #{NAME}.love README.md`
end

desc "Create OSX archive"
task :create_osx => [:create_love] do
    puts "Creating OSX app"
    `rm -Rf dist/osx`
    `mkdir -p dist/osx`
    `cp -R redist/osx/love.app dist/osx/#{NAME}.app`
    `cp README.md dist/osx`
    `cp dist/love/#{NAME}.love dist/osx/#{NAME}.app/Contents/Resources`
    puts "Creating OSX archive"
    `cd dist/osx;zip -r #{NAME}-osx.zip #{NAME}.app README.md`
end

def create_win(type)
    puts "Creating #{type.to_s} exe"
    `rm -Rf dist/#{type.to_s}`
    `mkdir -p dist/#{type.to_s}/#{NAME}`
    `cp -R redist/#{type.to_s}/#{File.basename REDISTS[type], '.zip'}/* dist/#{type.to_s}/#{NAME}`
    `cp README.md dist/#{type.to_s}/#{NAME}`
    `cat dist/#{type.to_s}/#{NAME}/love.exe dist/love/#{NAME}.love > dist/#{type.to_s}/#{NAME}/#{NAME}.exe`
    `rm dist/#{type.to_s}/#{NAME}/love.exe`
    puts "Creating #{type.to_s} archive"
    `cd dist/#{type.to_s};zip -r #{NAME}-#{type.to_s}.zip #{NAME}`
end

desc "Create Win32 archive"
task :create_w32 => [:create_love] do
    create_win :w32
end

desc "Create Win64 archive"
task :create_w64 => [:create_love] do
    create_win :w64
end

desc "Creates all archives"
task :create_all => [:create_osx, :create_w32, :create_w64] do

end

desc "Runs the game from the src folder"
task :run do
    `love src`
end
