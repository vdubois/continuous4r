require 'utils.rb'
# Notification avec libnotify (linux)
# Author:: Vincent Dubois
# Date : 05 octobre 2009 - version 0.0.5
class LibnotifyNotifier
  WORK_DIR = "tmp/continuous4r"
  attr_accessor :title, :message, :icon

  # constructor
  def initialize(title, message, icon = nil)
    @title = title
    @message = message
    @icon = icon
  end

  # notification
  def notify
    Utils.run_command("notify-send -t 40000#{@icon.nil? ? "" : " --icon=#{FileUtils.pwd}/#{WORK_DIR}/notification/#{@icon}"} '#{@title}' '#{@message}'")
  end
end
