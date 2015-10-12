# vim: tabstop=2:expandtab:shiftwidth=2
require 'logger'

module StEng::NBUMgmt

  def stop_nb(logger)
    logger.info("Stopping NB")
    output = %x(/etc/init.d/netbackup stop)
    logger.info("Exit status: #{$?.exitstatus}")
    logger.debug(output)
  end

  def start_nb(logger)
    logger.info("Starting NB")
    output = %x(/etc/init.d/netbackup start)
    logger.info("Exit status: #{$?.exitstatus}")
    logger.debug(output)
  end

end
