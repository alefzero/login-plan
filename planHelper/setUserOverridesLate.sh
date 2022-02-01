#!/bin/bash

# Gancho para o disparo do redeploy
# Author: Alexandre Marcelo 
# Criado em: 2022-Jan-31
# Github: https://github.com/alefzero

source @PLAN_HELPER_HOME@/setPlanHelperEnv.sh

# Specify any server-specific java command line options by server name or partial match
case "${SERVER_NAME}" in
    WC_Portal_server*)
        echo "Agendando redeploy da aplicação do Portal via ${SERVER_NAME}"
        echo "com um novo plano de execução ao final do processo (contorno bug-oracle)."
        pushd "${PLAN_HELPER_HOME}"
        nohup ./updatePortal.sh "${DOMAIN_HOME}" "${SERVER_NAME}" > /dev/null 2>&1 < /dev/null &
        popd
        ;;
esac

