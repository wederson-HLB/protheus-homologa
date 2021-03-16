#Include "topconn.ch"
#Include "tbiconn.ch"
#include "fileio.ch"  
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
/*
Funcao      : GTGEN008
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Rotina para copia dos arquivos do servidor do ponto eletronico para o server GTCORP.
Autor       : Jean Victor Rocha
Revisão		:
Data/Hora   : 28/11/2012
Módulo      : Ponto eletronico
*/
*----------------------*
User function GTGEN008()
*----------------------*
Local i
Local cLog		:= ""
Local cSrvPOnto := "\\10.11.201.26\afd"
Local cDestino	:= "\AFD"
Local aDir		:= Directory(cSrvPOnto+"\*.TXT","D")
Local aDest		:= Directory(cDestino+"\*.TXT","D")
Local cArqLog	:= "LOG.TXT"

Private nHandle := 0

Private aDiv := {}

Private cServer:= "webmail.br.gt.com"
Private cEmail := "totvs@br.gt.com"
Private cPass  := "System@2015"

Private cDe      := padr('totvs@br.gt.com',200)
Private cPara    := PADR('suporte.sistemas@br.gt.com',200)

Private cCc      := padr('',200)
Private cAssunto := padr('AFD - Arquivos desatualizados - '+DTOC(Date()),200)
Private cMsg     := ""


cLog += (REPLICATE("=",100))+CHR(13)+CHR(10)
cLog += ("= Importação de arquivos AFD. "+DTOC(date())+" - "+TIME())+CHR(13)+CHR(10)
cLog += (REPLICATE("=",100))+CHR(13)+CHR(10)
cLog += ("- Origem:'"+cSrvPOnto+"\' Destino:'"+cDestino+"'.")+CHR(13)+CHR(10)

//Faz Backup dos arquivos ja existentes.
cLog += ("- Backup --------------------------------------------------------")+CHR(13)+CHR(10)
If Len(aDest) > 0          
	cFolder := cDestino+"\BKP\"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","")
	MAKEDIR(cFolder)
	For i:= 1 to len(aDest)
		IF __CopyFile( cDestino+"\"+aDest[i][1], cFolder+"\"+aDest[i][1] )
			cLog += "- Copiado arquivo '"+aDest[i][1]+"' para pasta '"+cDestino+"\BKP\"+cFolder+"'."+CHR(13)+CHR(10)
			If aDest[i][1] <> "LOG.TXT" .OR. (aDest[i][1] == "LOG.TXT" .and. aDest[i][2] > 1048576)//se for maior que 1 MB zera o Log tbm.
				FERASE(cDestino+"\"+aDest[i][1])
			EndIf
			cLog += "- Infos: arquivo '"+aDest[i][1]+"'; Tam: "+ALLTRIM(STR(aDest[i][2]))+"Bytes; Dt Mod: "+DTOS(aDest[i][3])+"_"+aDest[i][4]+"."+CHR(13)+CHR(10)
			cLog += "- Apagado arquivo '"+aDest[i][1]+"' da pasta '"+cDestino+"'."+CHR(13)+CHR(10)
		Else
			cLog += "- Não foi possivel movimentação do arquivo '"+aDest[i][1]+"' da pasta '"+cDestino+"\BKP\"+cFolder+"'."+CHR(13)+CHR(10)
		EndIf
	Next i
	compacta(cFolder,cDestino+"\BKP\"+STRZERO(ANO(Date()),4)+STRZERO(MOnth(Date()),2))
EndIf

//Copia dos arquivos do servidor do ponto para o GTCORP.
cLog += ("- Processamento -------------------------------------------------")+CHR(13)+CHR(10)
For i:=1 to len(aDir)
	If (Date() - aDir[i][3]) >= 5
		//Realiza a conexão com o banco de dados GTHD.
		//AOA - 23/09/2016 - informado porta de conexão para o TCLINK.
		nCon := TCLink("MSSQL7/GTCORP_P11","10.0.30.5",7894)

		//Verifica Campo no SysObject
		BeginSql Alias 'SYS'
	    	SELECT COUNT(COLUMN_NAME) AS COUNT
	  		FROM INFORMATION_SCHEMA.COLUMNS 
	  		WHERE	TABLE_NAME = 'SP0CH0' 
				AND COLUMN_NAME = 'P0_P_ATIVO'
		EndSql
	
		//Inicio da Query
		BeginSql Alias 'QRY'
	    	SELECT *
		    FROM SP0CH0
			WHERE %notDel%     
			AND P0_ARQUIVO like "%"+%exp:aDir[i][1]%
		EndSql
				
		If SYS->COUNT >= 1 
			If QRY->P0_P_ATIVO == "1"//Sim
				aAdd(aDiv, "Relogio: "+QRY->P0_DESC+" - Arquivo: "+aDir[i][1]+", data: "+ DTOC(aDir[i][3])+" "+aDir[i][4]+", bytes: "+ALLTRIM(STR(aDir[i][2])))
			EndIf
		Else
			aAdd(aDiv, "Relogio: "+QRY->P0_DESC+" - Arquivo: "+aDir[i][1]+", data: "+ DTOC(aDir[i][3])+" "+aDir[i][4]+", bytes: "+ALLTRIM(STR(aDir[i][2])))		
		EndIf
        
		SYS->(DbCloseArea())
		QRY->(DbCloseArea())
	
		//Encerra a conexão
		TCunLink(nCon)
	EndIf
	IF __CopyFile( cSrvPOnto+"\"+aDir[i][1], cDestino+"\"+aDir[i][1] )
		cLog += ("- Importado arquivo '"+aDir[i][1]+"' com sucesso do local '"+cSrvPOnto+"'")+CHR(13)+CHR(10)
		cLog += "- Infos: arquivo '"+aDir[i][1]+"'; Tam: "+ALLTRIM(STR(aDir[i][2]))+"Bytes; Dt Mod: "+DTOS(aDir[i][3])+"_"+aDir[i][4]+"."+CHR(13)+CHR(10)
	Else
		cLog += ("- Erro na Importação do arquivo '"+aDir[i][1]+"'.")+CHR(13)+CHR(10)
	EndIf
Next i
cLog += ("- Finalizado Importação de arquivos AFD. "+DTOC(date())+" - "+TIME())+CHR(13)+CHR(10)

//Gravação do LOG da rotina---------------------------------------
If !File(cDestino+"\LOG.TXT")
	If (nHandle:=FCreate(cDestino+"\LOG.TXT", 0)) == -1
		//ERRO NA CRIACAO DO ARQUIVO DE LOG.
		Return .T.
	EndIf
	FClose(nHandle)	
EndIf

nHandle := Fopen(cDestino+"\LOG.TXT",2)
FSeek(nHandle,0,2)
FWRITE(nHandle, cLog )
fclose(nHandle)    

If Len(aDiv) > 0
	Email()
	EnviaMail()
EndIf

Return .T.            

*---------------------*
Static Function Email()
*---------------------*
Local cHora:= TIME()
Local i

cMsg += "<body style='background-color: #9370db'>"
cMsg += '	 <table height="361" width="844" bgColor="#fffaf0" border="0" bordercolor="#fffaf0" style="border-collapse: collapse" cellpadding="0" cellspacing="0"> '
If VAl(SUBSTR(cHora, 1, 2)) < 12
	cMsg += '		 <td colspan="5"> Bom Dia!'
ElseIf VAl(SUBSTR(cHora, 1, 2)) < 18
	cMsg += '		 <td colspan="5"> Boa Tarde!'
Else 
	cMsg += '		 <td colspan="5"> Boa Noite!'
EndIf
cMsg += '			<br></br>'
cMsg += '		 </td>'
cMsg += '		 <tr>'
cMsg += "			<td colspan='5'>Encontrado inconsistências nos arquivos AFD. Favor verificar!"
cMsg += '				<br></br>'
cMsg += '				<br></br>'
cMsg += '			</td>'
cMsg += '		 </tr>'
For i:=1 to len(aDiv)
	cMsg += '		 <tr>'
	cMsg += "			 <td colspan='5'>"+aDiv[i]+"</td>"
	cMsg += '		 </tr>'	
Next i
cMsg += '		<tr>'
cMsg += '			 <td colspan="5">'
cMsg += '				<br></br>'
cMsg += '				<br></br>'
cMsg += '				<br></br>'
cMsg += '				<em>'
cMsg += '					<strong>Este e-mail foi enviado automaticamente pelo Sistema de Monitoramento da Equipe TI da GRANT THORNTON BRASIL. </Strong>'
cMsg += '				</em>'
cMsg += '			 </td>'
cMsg += '		</tr>'
cMsg += '	 </Table>'
cMsg += ' <BR?>'
cMsg += CRLF 

Return .t.   

*--------------------------*
STATIC FUNCTION EnviaMail()
*--------------------------*
Local lResulConn := .T.
Local lResulSend := .T.
Local cError := ""  

CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn

If !lResulConn
   GET MAIL ERROR cError
   Conout("GTGEN008 - Falha na conexão "+cError)
   Return(.F.)
Endif

SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg  RESULT lResulSend   

GET MAIL ERROR cError
If !lResulSend
	Conout("GTGEN008 - Falha no Envio do e-mail " + cError)
Endif

DISCONNECT SMTP SERVER                         

Return .T.

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar arquivo
*/
*----------------------------------------*
Static Function compacta(cArquivo,cArqRar)
*----------------------------------------*
Local lRet		:=.F.
Local cRootPath	:=GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= 'C:\Program Files (x86)\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"'
Local lWait  	:= .T.
Local cPath     := "C:\Program Files (x86)\WinRAR\"

lRet := WaitRunSrv( cCommand , lWait , cPath )

Return(lRet)