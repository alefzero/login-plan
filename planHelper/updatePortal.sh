#!/bin/bash

# Este script atualiza a aplicação no servidor especificado
# Author: Alexandre Marcelo 
# Criado em: 2022-Jan-31
# Github: https://github.com/alefzero

DOMAIN_HOME=$1
SERVER_NAME=$2
PLAN_APP_NAME=webcenterr 

source @PLAN_HELPER_HOME@/setPlanHelperEnv.sh

starLog() { 
    cat < /dev/stdin | while read data
    do 
        if [ "${data:0:1}" == "*" ]
        then
            echo "$(date): ${data:1} " >> "${PLAN_HELPER_HOME}/redeploy.log"
        fi
    done
}

fullLog() { 
    cat < /dev/stdin | while read data
    do 
        echo "    ${data} " >> "${PLAN_HELPER_HOME}/redeploy.log"
    done
}

echo "*Aguardando o inicio do servidor ${SERVER_NAME}..." | starLog

pushd "${DOMAIN_HOME}"

"${PLAN_WLST_SH}" "${PLAN_HELPER_HOME}/serverStatus.py"  "${PLAN_USER_CONFIG_FILE}" "${PLAN_USER_CONFIG_KEYFILE}" \
        "${PLAN_ADMIN_URL}" "${SERVER_NAME}" 2>&1 | starLog 

SERVER_STATUS=$?

if [ $SERVER_STATUS -ne 0 ]
then
    echo "*O servidor ${SERVER_NAME} se encontra em um estado incompatível (${SERVER_STATUS})... Nenhuma atualização será executada." | starLog
else
    echo "*Iniciando o processo de redeploy..." | starLog
    source "${PLAN_SET_WSL_ENV}" > /dev/null
    DEPLOY_DATA="$(java weblogic.Deployer -adminurl "${PLAN_ADMIN_URL}"  \
        -name "${PLAN_APP_NAME}" -redeploy -plan "${PLAN_HELPER_HOME}/plan.xml" \
        -userConfigFile  "${PLAN_USER_CONFIG_FILE}" \
        -userkeyfile "${PLAN_USER_CONFIG_KEYFILE}" )"
    if [ $? -ne 0 ]
    then
        echo "*Houve um erro durante o processo de redeploy: " | starLog
        echo $DEPLOY_DATA | fullLog
    else
        echo "*Processo de redeploy disparado via ${SERVER_NAME} finalizado." | starLog
    fi
fi
popd
