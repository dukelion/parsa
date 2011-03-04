require "config"
require "lib/log_filename.rb"
require "lib/remote_file_getter.rb"
require "lib/log_parser"
require "lib/log_data_manager"
require "lib/utils"

LOG.info "Starting parsa"

log_filename = LogFilename.get

data = RemoteFileGetterData.new
data.host        = CONFIG["host"]
data.username    = CONFIG["username"]
data.password    = CONFIG["password"]
data.remote_file = CONFIG["remote_dir"] + "/" + log_filename
data.local_file  = CONFIG["local_dir"] + "/" + log_filename

remote_getter = RemoteFileGetter.new
remote_getter.get_file(data)

log_parser = LogParser.new
log_data_manager = LogDataManager.new
lines_number = CountLines.of data.local_file
processed_lines = 0
checkpoints = [1, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 96, 97, 98, 99]

File.readlines(data.local_file).collect do |line|
  processed_lines += 1
  log_data = log_parser.parse(line)
  next if log_data.nil?
  log_data_manager.save log_data
  percent = (processed_lines * 100 / lines_number)
  if checkpoints.include?(percent)
    checkpoints.delete(percent)
    puts "#{percent}% is done..."
  end
end

LOG.info "Ending parsa"
