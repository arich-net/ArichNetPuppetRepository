SET PROGRAMFILESBASE=%ProgramFiles%
if not "%ProgramFiles(x86)%" ==  "" set PROGRAMFILESBASE=%ProgramFiles(x86)%

SET BASEDIR=%~dp0..
SET BASEDIR=%BASEDIR:\bin\..=%

SET SERVER_CONFIG=%BASEDIR%\etc\server.cfg
SET CLIENT_CONFIG=%BASEDIR%\etc\client.cfg

SET MCOLLECTIVED=%BASEDIR%\bin\mcollectived

REM Lets auto start the service
REM SET MC_STARTTYPE=manual
SET MC_STARTTYPE=auto

SET PATH=%BASEDIR%\bin;%PATH%

SET RUBYLIB=%BASEDIR%\lib;%RUBYLIB%

SET PUPPET_DIR=%PROGRAMFILESBASE%\Puppet Labs\Puppet
SET PATH=%PUPPET_DIR%\sys\ruby\bin;%PATH%

REM Use puppetlabs ruby lib
SET RUBYLIB=%PUPPET_DIR%\puppet\lib;%PUPPET_DIR%\facter\lib;%RUBYLIB%
SET RUBYLIB=%RUBYLIB:\=/%

SET RUBY="ruby"
