require 'logger'

class ImLog
  def self.logger(is_stdout, is_file, filepath, rotate_max_bytes, rotate_backup_count)
    if is_stdout
      logger = Logger.new(STDOUT)
    elsif is_file
      unless File.exist?(filepath)
        f = open(filepath, "w")
        f.close
      end
      #logger = Logger.new(filepath, 'daily')
      logger = Logger.new(filepath, rotate_backup_count, rotate_max_bytes)
    end
    logger.formatter = Logger::Formatter.new
    logger.datetime_format = "%Y-%m-%d %H:%M:%S"
    return logger
  end
end
