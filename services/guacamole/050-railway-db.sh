#
# Railway: database schema and administrator before Guacamole starts (sourced by the image's
# entrypoint.sh, so this file only calls the helper and never exits).
#
#   helper exit 0  -> schema ready, default password replaced: start normally
#   helper exit 2  -> the default guacadmin password could not be replaced: start WITHOUT the
#                     database extension, so no account (and no default login) works
#   other          -> unexpected error: same as 2 (fail closed), the log says why
#
if /opt/railway/railway-guacamole-db; then
    :
else
    echo "[railway] Database authentication is DISABLED on this boot (fail closed): nobody can sign in until the problem above is fixed and the service is redeployed."
    export POSTGRESQL_ENABLED=false
fi
