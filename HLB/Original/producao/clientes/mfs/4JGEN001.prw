#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TBICONN.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "COLORS.CH"

/*
Funcao      : 4JGEN001()
Parametros  : 
Retorno     : 
Objetivos   : Customização para exportar arquivo CT2 em TXT no layout do cliente.
Autor       : Jean Victor Rocha
Data/Hora   : 22/01/2015
*/
*----------------------*
User Function 4JGEN001()
*----------------------*
Private cPerg := "4JGEN001"
Private cArq := cPerg+".TXT"
Private cDir := GetTempPath()
Private nHdl := 0

//Ajuste de Perguntes
U_PUTSX1( cPerg, "01", "Data De:"			, "Data De:"		, "Data De:"		, "", "D",08,00,00,"G","" , "","","","MV_PAR01")
U_PUTSX1( cPerg, "02", "Data Ate:"		, "Data Ate:"		, "Data Ate:"		, "", "D",08,00,00,"G","" , "","","","MV_PAR02")
U_PUTSX1( cPerg, "03", "Diretorio:"		, "Diretorio:"		, "Diretorio:"		, "", "C",30,00,00,"C","" , "","","","MV_PAR03","","","","c:\")

If !Pergunte(cPerg)
	Return .F.
EndIf

cDtDe	:= DTOS(MV_PAR01)
cDtAte	:= DTOS(MV_PAR02)
MV_PAR03 := ALLTRIM(MV_PAR03)

//Caso não seja informado o diretorio pelo usuario, sera utilizado o Temporario da maquina do usuario.
If !EMPTY(MV_PAR03)
	cDir := MV_PAR03
EndIf

//ajusta a barra no final do caminho da pasta informada.
If RIGHT(cDir,1) <> "\"
	cDir := cDir + "\"
EndIf

//Valida o diretorio informado pelo usuario.
If !File(cDir) .and. UPPER(cDir) <> "C:\"
	MsgInfo("Diretorio informado invalido!","HLB BRASIL")
	Return .F.
EndIf


Processa({|| Main()})

Return .T.

/*
Funcao      : Main()
Parametros  : 
Retorno     : 
Objetivos   : Função principal
Autor       : Jean Victor Rocha
Data/Hora   : 22/01/2015
*/
*--------------------*
Static Function Main()
*--------------------*
Local cQry := ""

cQry += " Select *
cQry += " From "+RETSQLNAME("CT2")
cQry += " Where D_E_L_E_T_ <> '*'
//AOA - 22/04/2015 - Filtrar apenas moeda 1, cliente não trabalha com moeda 4.
cQry += "   AND CT2_MOEDLC = '01'
If !EMPTY(cDtDe)
	cQry += " 	AND CT2_DATA >= '"+cDtDe+"'
EndIf
If !EMPTY(cDtAte)
	cQry += " 	AND CT2_DATA <= '"+cDtAte+"'
EndIf

If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf

DbUseArea(.T.,"TOPCONN",TcGenqry(,,cQry),"QRY",.F.,.F.)

//Só gerar a barra de progresso
ProcRegua(QRY->(RecCount()))
IncProc()

QRY->(DbGoTop())
If QRY->(!EOF())
	//Apaga o arquivo antigo.
	If File(cDir+cArq)
		If FErase(cDir+cArq) <> 0
			MsgInfo("Não foi possivel apagar o arquivo '"+cArq+"' na pasta temporaria!","HLB BRASIL")
			Return .F.
		EndIf
	EndIf

	nHdl := FCREATE(cDir+cArq,0 )
	FWRITE(nHdl, "" )
	fclose(nHdl)

	cAux := ""
	While QRY->(!EOF())
		cAux += QRY->CT2_DATA
		cAux += STRZERO(VAL(QRY->CT2_LOTE	),6)
		cAux += STRZERO(VAL(QRY->CT2_SBLOTE	),3)
		cAux += STRZERO(VAL(QRY->CT2_DOC	),6)
		cAux += STRZERO(VAL(QRY->CT2_LINHA	),3)
		cAux += ALLTRIM(QRY->CT2_MOEDLC)+SPACE(2-LEN(ALLTRIM(QRY->CT2_MOEDLC)))
		cAux += LEFT(ALLTRIM(QRY->CT2_DC),1)
		cAux += ALLTRIM(QRY->CT2_DEBITO)+SPACE(20-LEN(ALLTRIM(QRY->CT2_DEBITO)))
		cAux += ALLTRIM(QRY->CT2_CREDIT)+SPACE(20-LEN(ALLTRIM(QRY->CT2_CREDIT)))
		cAux += STRZERO(VAL(STRTRAN(TRANSFORM(QRY->CT2_VALOR,"@R 999999999999999.99"),".","")),17)
		cAux += LEFT(ALLTRIM(QRY->CT2_HIST),40)+SPACE(40-LEN(ALLTRIM(QRY->CT2_HIST)))
		cAux += LEFT(ALLTRIM(QRY->CT2_TPSALD),1)
		cAux += STRZERO(VAL(STRTRAN(TRANSFORM(QRY->CT2_VLR04,"@R 999999999999999.99"),".","")),17)
		cAux += ALLTRIM(QRY->CT2_CCD)+SPACE(9-LEN(ALLTRIM(QRY->CT2_CCD)))
		cAux += ALLTRIM(QRY->CT2_CCC)+SPACE(9-LEN(ALLTRIM(QRY->CT2_CCC)))

		cAux += CHR(13)+CHR(10)

		//Grava caso a variavel esteja com muitos dados.
		If Len(cAux) >= 1000000//Proximo a 1Mega
			cAux := GrvArq(cAux)
		EndIf

		QRY->(DbSkip())
	EndDo
	GrvArq(cAux)

	MsgInfo("Processamento Finalizado!","Grant Thorton Brasil")

Else
	MsgInfo("Sem dados para exibição","Grant Thorton Brasil")
	Return .t.
EndIf

Return .T.

/*
Funcao      : GrvArq()
Parametros  : 
Retorno     : 
Objetivos   : Grava a String enviada no arquivo.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------*
Static Function GrvArq(cMsg)
*--------------------------*
Local nHdl := Fopen(cDir+cArq)

FSeek(nHdl,0,2)
FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""
