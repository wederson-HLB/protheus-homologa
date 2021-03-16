#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FONT.CH"
/*
Funcao      : PNM090VER
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Efetua BKP no momento do fechamento do Ponto.
Autor       : Jean Victor Rocha.
Data/Hora   :
*/
*-----------------------*
User Function PNM090VER()
*-----------------------*
Local lRet := .T.
lRet := ExecBkp("VER")

Return(lRet)

*-----------------------*
User Function PNM090END()
*-----------------------*
Local lRet := .T.
lRet := ExecBkp("END")

Return(lRet)

/*
Funcao      : ExecBkp
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : 
Autor       : 
Data/Hora   : 
*/
*------------------------------*
Static Function ExecBkp(cOrigem)
*------------------------------*
Local lRet := .T.
Local _cAlias  := "SPI"
Local _WAlias := "W"+_cAlias
Local _cArqSQL := RetSqlName("SPI")
Local _cIndSQL := RetSqlName("SPI")+"1"
Local _cPath := "\PON\BKP_FECHA\"

If !file("\PON")
	If (nErro:=MakeDir("\PON")) <> 0
		MsgInfo("- Não foi possivel criação do diretorio '" + "\PON" + "' - Erro: " + ALLTRIM(STR(nErro)),"Grant Thornton Brasil" )
		Return .F.
	EndIf
EndIf
If !file("\PON\BKP_FECHA")
	If (nErro:=MakeDir("\PON\BKP_FECHA")) <> 0
		MsgInfo("- Não foi possivel criação do diretorio '" + "\BKP_FECHA" + "' - Erro: " + ALLTRIM(STR(nErro)),"Grant Thornton Brasil" )
		Return .F.
	EndIf
EndIf

aDirMIG := Directory("\PON\BKP_FECHA\*.DBF")
For i:=1 to Len(aDirMIG)
	compacta("\PON\BKP_FECHA\"+aDirMIG[i][1],"\PON\BKP_FECHA\BACKUP.RAR")
Next i

StartJob("U_DownBase      "+_cArqSQL , GetEnvServer() , .F., _cArqSQL,_cPath,_WAlias,_cIndSQL,cEmpAnt,cFilAnt,cOrigem)

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif 
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,"Select COUNT(*) AS COUNT From "+_cArqSQL),"QRY",.F.,.T.)
nTam := QRY->COUNT
QRY->(DbClosearea())

Processa({|| Barra()})

Return .T.

/*
Funcao      : Barra
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : 
Autor       : 
Data/Hora   : 
*/
*---------------------*
Static Function Barra()  
*---------------------*
Local nTempo := INT(nTam/3400)
ProcRegua(nTempo)
For i:=1 to nTempo
	IncProc("Efetuando Backup de Banco de Horas, por favor aguarde...")
	Sleep(1000)
Next i 
Return .T.

/*
Funcao      : DownBase
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Função para execução das threads de download da base de dados.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*--------------------------------------------------------------------------*
User Function DownBase(_cArqSQL,_cPath,_WAlias,_cIndSQL,cEmp,cFilEmp,cPonto)
*--------------------------------------------------------------------------*
Local _nQuant
Local _cArqDBF

RpcSetType(3)
RpcSetEnv(cEmp, cFilEmp)

IF TCCANOPEN(_cArqSQL) // É UM ARQUIVO DO SQL			
	_cArqDBF := AllTrim(_cPath)+_cArqSQL+"_"+cEmp+"_"+cPonto+"_"+DTOS(Date())+"_"+STRTRAN(TIME(),":","")+".DBF"
	dbUseArea( .T., "TOPCONN", (_cArqSQL), (_WAlias), .T., .F. )
	IF TCCANOPEN(_cArqSQL,_cIndSQL) 
		DbSetIndex(_cIndSQL)
		_nQuant := RecCount()
	ElseIf TCCANOPEN(_cArqSQL)
		_nQuant := RecCount()
	ENDIF			  
	IF _nQuant > 0
		__dbCopy((_cArqDBF),{ },,,,,.F.,"DBFCDX")
		(_WAlias)->(MSUNLOCK())
	END IF          
	(_WAlias)->(dbCloseArea())
ENDIF

RpcClearEnv()

Return .T.

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar o arquivo(boleto html)
Autor       : 
Data/Hora   : 
*/
*----------------------------------------*
Static Function compacta(cArquivo,cArqRar)
*----------------------------------------*
Local lRet		:=.F.
Local cRootPath	:=GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
Local lWait  	:= .T.
Local cPath     := "C:\Program Files (x86)\WinRAR\"

lRet:=WaitRunSrv( cCommand , lWait , cPath )
/* COMANDOS RAR
    a       Adicionar arquivos ao arquivo.
            Exemplo:
            criar ou atualizar o arquivo existente myarch, adicionado todos os
            arquivos no diretório atual
            rar a myarch
   -ep1    Excluir diretório base dos nomes. Não salvar o caminho fornecido na
            linha de comandos.
            Exemplo:
            todos os arquivos e diretórios do diretório tmp serão adicionados
            ao arquivo 'pasta', mas o caminho não incluirá 'tmp\'
            rar a -ep1 -r pasta 'tmp\*'
            Isto é equivalente aos comandos:
            cd tmp
            rar a -r pasta
            cd ..
    -o+     Substituir arquivos existentes.
    m[f]    Mover para o arquivo [apenas arquivos]. Ao mover arquivos e
            diretórios irá resultar numa eliminação dos arquivos e
            diretórios após uma operação de compressão bem sucedida.
            Os diretórios não serão removidos se o modificador 'f' for
            utilizado e/ou o comando adicional '-ed' for aplicado.    */

Return(lRet)