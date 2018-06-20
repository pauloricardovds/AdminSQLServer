/************* ATENÇÃO ESTE SCRIPT DEVE SER EXECUTADO NA REPLICA PRIMARIA. 
Reduzindo arquivos de log do SQL Server Availability Group Cluster ou Database Mirror
Um problema muito comum é o crescimento do arquivo de log dos arquivos .LDF do Microsoft SQL Server.
Criado por Paulo Ricardo
**********************************************************************/

/**Verifique se existe alguma transação aberta antes, pois isso poderá impactar na liberação do log.*/

dbcc opentran

/*************1. Identifique os arquivos de log que você deseja reduzir*************
************************************************************************/

DBCC SQLPERF (LOGSPACE);
/*******************************************************************
2. Em seguida, faça backup do arquivo de log para liberar espaço no arquivo, caso você não tenha espaço disponível para fazer o backup é possível fazer backup em um dispositivo nulo, OBS. (BACKUP = NULL, NÃO É RECOMENTADO EXECUTAR EM EMBIENTE DE PRODUÇÃO POIS PODERAR PERDER DADOS QUE NÃO FORAM PERSISTIDO NO .MDF.) 
**********************************************************************/

REGISTRO DE BACKUP DatabaseName TO DISK = 'NUL:'

/***************************************************************************
3. Em seguida, verifique se é possível liberar o log no campo STATUS =0, 
Se o status for STATUS = 2 vá para o passo 4 ou se estiver STATUS = 0 pule para o passo 5.
*************************************************************************/

Use DatabaseName 
GO 
dbcc loginfo


/****************************************************************************
4.  O comando abaixo força a liberação do log sem precisar alterar o tipo de recuperação do banco, na verdade não é possível fazer esta alteração quando se tem AG ou D Mirror, SE POSSÍVEL NUNCA RODE ESTE COMANDO EM PRODUÇÃO
************************************************************************/

DBCC SHRINKFILE (DatabaseName_Log, EMPTYFILE);


/*********************************************************************
5. Agora que o log de transações foi esvaziado, é possível liberar o espaço alocado.
***********************************************************************/

DBCC SHRINKFILE (myDatabaseName_Log, 500);

/***************************************************************************
6. Se depois dos passos acima não der certo, PLANO B caso você tenha AG. Siga os passos abaixo.
LEMBRANDO, o comando abaixo remove o Database do AVAILABILITY GROUP.
*************************************************************************/
ALTER AVAILABILITY GROUP [AVAILABILITY_GROUP_NAME]
REMOVE DATABASE [DatabaseName];

/***************************************************************************
7. Altere o modo de recuperação do DATABASE.
********************************************************************/
ALTER DATABASE [DatabaseName] SET RECOVERY SIMPLE WITH NO_WAIT


/*******************************************************************
8 . Volte passa o passo 6, é seja feliz o espaço em disco será liberado 
***************************************************************************/
