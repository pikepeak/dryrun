require 'tmpdir'
require 'fileutils'
require 'uri'
require_relative 'dryrun_utils'
require 'digest'

module DryRun

  class Github
    def initialize(url)
      @base_url = url
      @destination = get_destination
    end

    def get_destination
      Digest::SHA256.hexdigest @base_url
    end

    def is_valid
       starts_with_git = @base_url.split(//).first(4).join.eql? "git@"
       starts_with_http = @base_url.split(//).first(7).join.eql? "http://"
       starts_with_https = @base_url.split(//).first(8).join.eql? "https://"

      return (starts_with_git or starts_with_https or starts_with_http)
    end

    def clonable_url
      starts_with_git = @base_url.split(//).first(4).join.eql? "git@"
      ends_with_git = @base_url.split(//).last(4).join.eql? ".git"

      # ends with git but doesnt start with git
      if ends_with_git and !starts_with_git
        return @base_url
      end

      # ends with git but doesnt start with git
      if !ends_with_git and !starts_with_git
        return "#{@base_url}.git"
      end

      @base_url

      # end
    end

    ##
    ## CLONE THE REPOSITORY
    ##
    def clone
      clonable = self.clonable_url

      tmpdir = Dir.tmpdir+"/dryrun/#{@destination}"
      FileUtils.rm_rf(tmpdir)

      DryrunUtils.execute("git clone #{clonable} #{tmpdir}")

      tmpdir
    end

  end

end
