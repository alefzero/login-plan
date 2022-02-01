from time import sleep
try:
    print('*Conectando no servidor administrativo')
    connect(userConfigFile=sys.argv[1], userKeyFile=sys.argv[2], url=sys.argv[3])

    maxTime=300
    waiting=5
    print('*Acompanhando o status do servidor: ' + sys.argv[4])

    while maxTime > 0:
        status=state(sys.argv[4], 'Server', returnMap='true').values()[0]
        print('*Servidor: ' + sys.argv[4] + ' --> ' + status)
        if status == 'RUNNING':
            exit('Servidor OK', 0)
        elif status in ['STARTING', 'RESUMING']:
            sleep(waiting)
            maxTime = maxTime - waiting
            # Just Wait
        else:
            print('*Estado incompatível do servidor')
            exit('', 1)

    print ('*Tempo de espera máximo esgotado (5min).')
    exit('', 2)

except Exception, e:
    print(' Foi encontrada uma exceção: ' + e)

exit('', 99)
