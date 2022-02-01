#!/bin/bash

ERROR_MJIDDLEWARE_NOT_SET=1
ERROR_DOMAIN_NOT_SET=2
ERROR_DOMAIN_NOT_FOUND=3
ERROR_ADMIN_URL_NOT_SET=4

MIDDLEWARE_HOME=$1
DOMAIN_HOME=$2
PLAN_ADMIN_URL=$3

PLAN_HELPER_HOME="${DOMAIN_HOME}/planHelper"
PLAN_USER_CONFIG_FILE="${PLAN_HELPER_HOME}/userdata.config"
PLAN_USER_CONFIG_KEYFILE="${PLAN_HELPER_HOME}/userdata.key"
PLAN_WLST_SH="${MIDDLEWARE_HOME}/oracle_common/common/bin/wlst.sh"
PLAN_SET_WSL_ENV="${MIDDLEWARE_HOME}/wlserver/server/bin/setWLSEnv.sh"

usage() {
    echo ""
    echo "Execute config.sh MIDDLEWARE_HOME DOMAIN_HOME ADMIN_URL"
    echo ""
    echo "Onde:"
    echo "  MIDDLEWARE_HOME - é o caminho absoluto da raiz onde o produto está instalado (ex: /u01/oracle/Middleware)"
    echo "  DOMAIN_HOME     - é o caminho absoluto da raiz do domínio a ser instalado (ex: /u01/oracle/Middleware/domains/my-domain)"
    echo "  ADMIN_URL       - é a URL de acesso do servidor adminstrativo com o protocolo T3 (ex: t3://servername:7001)"
    echo ""
}

verifyDomain() {
    if [ ! -d $DOMAIN_HOME ]
    then
        echo "Diretorio $DOMAIN_HOME não encontrado."
        exit $ERROR_DOMAIN_NOT_FOUND
    fi
}

if [ -z "$MIDDLEWARE_HOME" ]
then
    usage
    exit $ERROR_MJIDDLEWARE_NOT_SET
fi


if [ -z "$DOMAIN_HOME" ]
then
    usage
    exit $ERROR_DOMAIN_NOT_SET
fi

if [ -z "$PLAN_ADMIN_URL" ]
then
    usage
    exit $ERROR_ADMIN_URL_NOT_SET
fi

verifyDomain

echo ""
echo "Entre com o usuário e senha adminstrativo para uso no ambiente (Ex: weblogic)."
echo "e garanta que o servidor administrativo esteja disponível."
echo ""
read -p "Usuario: " username
read -p "Senha: " -s password

echo ""
echo ""
echo "Configurando o ambiente em ${PLAN_HELPER_HOME}..."

PLAN_HELPER_HOME=/u01/middleware/domains/login/planHelper
if [ -d "${PLAN_HELPER_HOME}" ]
then 
    rm -rf "${PLAN_HELPER_HOME}"
fi

mkdir -p "${PLAN_HELPER_HOME}"
cp planHelper/* "${PLAN_HELPER_HOME}"

sed -i "s/@PLAN_HELPER_HOME@/${PLAN_HELPER_HOME////\\/}/g"  "${PLAN_HELPER_HOME}/setUserOverridesLate.sh"
sed -i "s/@PLAN_HELPER_HOME@/${PLAN_HELPER_HOME////\\/}/g"  "${PLAN_HELPER_HOME}/updatePortal.sh"

cat > "${PLAN_HELPER_HOME}/setPlanHelperEnv.sh" << EOF
#!/bin/bash

export PLAN_HELPER_HOME="${PLAN_HELPER_HOME}"
export PLAN_ADMIN_URL="${PLAN_ADMIN_URL}"
export PLAN_USER_CONFIG_FILE="${PLAN_USER_CONFIG_FILE}"
export PLAN_USER_CONFIG_KEYFILE="${PLAN_USER_CONFIG_KEYFILE}"
export PLAN_WLST_SH="${PLAN_WLST_SH}"
export PLAN_SET_WSL_ENV="${PLAN_SET_WSL_ENV}"

EOF

find "${PLAN_HELPER_HOME}" -name "*.sh" -exec chmod 750 {} \; 
mv  "${PLAN_HELPER_HOME}/setUserOverridesLate.sh" "${DOMAIN_HOME}/bin/setUserOverridesLate.sh"

echo ""
echo "Atribuindo as credenciais..."

"${PLAN_WLST_SH}" "${PLAN_HELPER_HOME}/configUser.py" \
    "$username" "$password" "${PLAN_ADMIN_URL}" \
    "$PLAN_USER_CONFIG_FILE" "$PLAN_USER_CONFIG_KEYFILE" > /dev/null

echo ""

echo "Configuração realizada"
echo ""
exit 0
