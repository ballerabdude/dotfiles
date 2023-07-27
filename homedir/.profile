#############################################################
# Generic configuration that applies to all shells
#############################################################

source ~/.shellvars
source ~/.shellfn
source ~/.shellpaths
source ~/.shellaliases
if [ -f ~/.secret_shell_exports ]; then
    source ~/.secret_shell_exports
fi