# Serviço de redeploy via WebLogic para o WebCenter

## Visão Geral
Este serviço traz uma solução de contorno onde um ambiente recebe uma 
nova configuração via _Deployment Plan_, mas que não resiste ao reinicio do servidor.

Ao reinciar um dos servidores indicados em ```setUserOverides.sh```, o serviço acompanha o servidor e solicita o _redeploy_ assim que seu status fica como _RUNNING_.

## Instalação

Clonar o repositório e executar o arquivo ```config.sh```.

