@echo OFF

REM Alterar valores aqui:
set CRIAR=nao
set URL=localhost\:12345
set USR=USER_NAME
set PWD=12345
set DB=oracle
set PORTA=4848
set POOL_NAME=nomeDoPool
set RES_NAME=jdbc/nomeDoResource

@echo.
@echo *********************************INSTRUCOES*******************************
@echo.
@echo.
@echo     1. Executar na pasta bin que possui asadmin.bat do Glassfish
@echo     2. O dominio deve estar rodando
@echo     3. valores para criar: "sim" ou "nao"
@echo     4. criar=nao se jah existe o pool de conexão, e quer atualizar
@echo     5. Atualizar pool existente nao altera o tipo de banco. Para isso,
@echo   deletar e criar um novo
@echo     6. Valores para DB: "postgresql" ou "oracle"
@echo     7. Colocar "\" antes de ":", como em "localhost\:12345"
@echo     8. A porta representa em qual dominio sera criado/alterado o pool.
@echo   Para ver qual a porta do dominio que deseja alterar, executar "list-domains -l"
@echo   no asadmin.bat e ler o valor da coluna ADMIN_PORT
@echo.
@echo.
@echo **********************************VARIAVEIS*******************************
@echo.
IF "%CRIAR%"=="sim" echo      Criar pool %POOL_NAME% e resource %RES_NAME%
IF "%CRIAR%"=="nao" echo      Atualizar pool %POOL_NAME%
@echo      na porta %PORTA%
@echo.
@echo      URL = "%URL%"
@echo      Usuario = "%USR%"
@echo      Senha = "%PWD%"
@echo      Banco de Dados = "%DB%"
@echo.
@echo ******************************FIM DAS VARIAVEIS***************************
@echo confirma valores?
pause

@echo OFF

IF "%CRIAR%" == "sim" GOTO DBDECISION
  call asadmin --port %PORTA% set resources.jdbc-connection-pool.%POOL_NAME%.property.password=%PWD%
  call asadmin --port %PORTA% set resources.jdbc-connection-pool.%POOL_NAME%.property.user=%USR%
  call asadmin --port %PORTA% set resources.jdbc-connection-pool.%POOL_NAME%.property.url=%URL%
GOTO END

:DBDECISION
  IF "%DB%" == "oracle" GOTO ORACLE
  IF "%DB%" == "postgresql" GOTO POSTGRE

:CRIAR
  call asadmin --port %PORTA% create-jdbc-connection-pool --datasourceclassname %DCN% --restype javax.sql.DataSource --driverclassname %DCN% --isolationlevel read-committed --property user=%USR%:password=%PWD%:url=%URL% %POOL_NAME%
  @echo.
  pause
  call asadmin --port %PORTA% create-jdbc-resource --connectionpoolid %POOL_NAME% %RES_NAME%
  GOTO END

:ORACLE
  SET DSCN=org.postgresql.ds.ORACLE
  SET DCN=Oracle
  GOTO CRIAR

:POSTGRE
  SET DSCN=org.postgresql.ds.PGSimpleDataSource
  SET DCN=Postgresql
  GOTO CRIAR

:END
@echo.
@echo.
@echo Ping:
@echo.
call asadmin --port %PORTA% ping-connection-pool %POOL_NAME%
@echo.
pause
