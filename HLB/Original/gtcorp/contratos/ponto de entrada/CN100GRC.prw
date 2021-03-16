#include "rwmake.ch"
#include "protheus.ch"
#include 'Ap5Mail.ch'                         
/*
Funcao      : CN100GRV
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Gravação dos produtos de nota de debito no contrato com default de cobrança = "S"
Autor       : 
TDN         : Function CN100GRV - Função utilizada na gravação do contrato. Executada após o processamento das tabelas relacionadas ao contrato.
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Contratos.
*/     

*-------------------------*
 User Function CN100GRC()   
*-------------------------*

Local cAmbiente   := "GTCORP/GTCORPTESTE/ENVGTCORP01/ENVGTCORP02"
Local lPossuiR    := Iif(CN9->CN9_P_NDRE <> "2",.T.,.F.)
Local xProdND     := {}
Local cProd       := ""
Local nOpc        := Paramixb[1] 
Local cAlias      := GetArea()
Private cAlias    := GetArea()
Private cItem     := ""

//incluido para preencher classe de valor com o contrato
//matheus - 01/11/2011
if cEmpAnt $ "ZB/ZF"
	
	DbSelectArea("CTH")
	DbsetOrder(1)
	
	if !DbSeek(xFilial("CTH")+M->CN9_P_NUM)
		RecLock("CTH",.T.)
		CTH->CTH_FILIAL	:=xFilial("CTH")
		CTH->CTH_CLVL	:=M->CN9_P_NUM
		CTH->CTH_DESC01	:=M->CN9_P_NOME
		CTH->CTH_CLASSE	:="2"
		CTH->CTH_NORMAL	:="1"
		CTH->CTH_BLOQ	:="2"
		CTH->CTH_CLVLLP	:=M->CN9_P_NUM
		CTH->CTH_DTEXIS	:=STOD("19800101")
		CTH->(MsUnlock())
	endif
	
endif

If Upper(GetEnvServer()) $ Upper(cAmbiente)                      
	If lPossuiR .And. (nOpc == 3 .Or. nOpc == 4)
        cQuery := "" 
        cQuery := "SELECT B1_FILIAL, B1_COD, B1_DESC, B1_GRUPO, R_E_C_N_O_ RECNO "
        cQuery += ' FROM '+ RetSQLname("SB1")
        cQuery += " WHERE D_E_L_E_T_ <> '*' "
        cQuery += " AND B1_FILIAL = '"+xFilial("SB1")+ " '"
        cQuery += " AND B1_GRUPO = 'ND  ' "
        cQuery += " AND B1_MSBLQL <> '1' "
        cQuery += " ORDER BY B1_COD+B1_DESC "
        MEMOWRIT("SELSB1.SQL",cQuery)
        cQuery := ChangeQuery(cQuery)
        dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TMP", .F., .T.)
        dbSelectArea("TMP")
        DbGoTop()

        While !Eof()         
			aadd( xProdND, TMP->B1_COD )
            dbSelectArea("TMP")
            dbSkip()
        Enddo
        dbSelectArea("TMP")
        dbCloseArea("TMP")
        RestArea(cAlias)
        
		If Len(xProdND) > 0
			dbSelectArea("ZZ7")
			dbSetOrder(1)
			dbGoTop()
			If !dbSeek(xFilial("ZZ7")+CN9->CN9_NUMERO)
				dbSelectArea("ZZ7")
				RecLock("ZZ7",.T.)   
				ZZ7->ZZ7_FILIAL := xFilial("ZZ7")
				ZZ7->ZZ7_CONTRA := CN9->CN9_NUMERO
				ZZ7->ZZ7_CODIGO := CN9->CN9_CLIENT
				ZZ7->ZZ7_LOJA   := CN9->CN9_LOJACL
				ZZ7->ZZ7_DESC   := CN9->CN9_P_NOME
				ZZ7->ZZ7_ITEM   := CN9->CN9_CLIENT
				ZZ7->ZZ7_DESCI  := Posicione("CTD",1,xFilial("CTD")+CN9->CN9_CLIENT,"CTD_DESC01")
				MsUnlock()
			Else
//				dbSelectArea("ZZ7")
//				RecLock("ZZ7",.F.)   
//				ZZ7->ZZ7_FILIAL := xFilial("ZZ7")
//				ZZ7->ZZ7_ITEM   := CN9->CN9_P_ITEM
//				ZZ7->ZZ7_DESCI  := Posicione("CTD",1,xFilial("CTD")+CN9->CN9_P_ITEM,"CTD_DESC01")
//				MsUnlock()
			Endif

			For i:=1 to Len(xProdND)
				If !dbSeek(xFilial("ZZ9")+CN9->CN9_NUMERO+CN9->CN9_CLIENT+xProdND[i])
					dbSelectArea("ZZ9")
					RecLock("ZZ9",.T.)
					ZZ9->ZZ9_FILIAL := xFilial("ZZ9")
					ZZ9->ZZ9_CONTRA := CN9->CN9_NUMERO
					ZZ9->ZZ9_CODCLI := CN9->CN9_CLIENT
					ZZ9->ZZ9_CODIGO := xProdND[i]
					ZZ9->ZZ9_COBRAR := "S" // DEFAULT = SIM
					ZZ9->ZZ9_DESCP  := Posicione("SB1",1,xFilial("SB1")+xProdND[i],"B1_DESC")
					ZZ9->ZZ9_CONTA  := Posicione("SB1",1,xFilial("SB1")+xProdND[i],"B1_CONTA")
					ZZ9->ZZ9_DESCC  := Posicione("CT1",1,xFilial("CT1")+Posicione("SB1",1,xFilial("SB1")+xProdND[i],"B1_CONTA"),"CT1_DESC01")
					MsUnlock()
				Else
					dbSelectArea("ZZ9")
					RecLock("ZZ9",.F.)
					ZZ9->ZZ9_DESCP  := Posicione("SB1",1,xFilial("SB1")+xProdND[i],"B1_DESC")
					ZZ9->ZZ9_CONTA  := Posicione("SB1",1,xFilial("SB1")+xProdND[i],"B1_CONTA")
					ZZ9->ZZ9_DESCC  := Posicione("CT1",1,xFilial("CT1")+Posicione("SB1",1,xFilial("SB1")+xProdND[i],"B1_CONTA"),"CT1_DESC01")
					MsUnlock()
				Endif
			Next
		Endif
	ElseIf !lPossuiR .Or. nOpc == 5
		dbSelectArea("ZZ7")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("ZZ7")+CN9->CN9_NUMERO)
		    RecLock("ZZ7",.F.)
		    dbDelete()
		    MsUnlock()
	    Endif
       	dbSelectArea("ZZ9")
       	dbSetOrder(1)
       	dbGoTop()
		If dbSeek(xFilial("ZZ9")+CN9->CN9_NUMERO+CN9->CN9_CLIENT)
		    While !Eof() .And. CN9->CN9_NUMERO+CN9->CN9_CLIENT == ZZ9->ZZ9_CONTRA+ZZ9->ZZ9_CODCLI
   			    dbSelectArea("ZZ9")
   			    RecLock("ZZ9",.F.)
   			    dbDelete()
  			    MsUnlock()
   			    dbSkip()
	        Enddo
	    Endif   
	Endif
Endif

//ECR - 04/07/12 - Envia e-mail de aviso de inclusão de contrato
If nOpc == 3 //Inclusão
	MailInc()
Endif

RestArea(cAlias)

Return

/*
Função  : MailInc()
Autor   : Eduardo C. Romanini
Objetivo: Eviar e-mail de aviso de inclusão de contrato
Data    : 04/07/12
*/
*-----------------------*
Static Function MailInc()
*-----------------------*
Local lConectou    := .F.
Local lDisConectou := .F.
Local lEnviado     := .F.

Local cLogin    := ""
Local cServer   := ""
Local cAccount  := ""
Local cEnvia    := ""
Local cRecebe   := ""
Local cPassword := ""
Local cMensagem := ""
Local cCliFor   := ""

//Envia email de aviso de inclusão de contrato
cServer   := AllTrim(GetNewPar("MV_RELSERV"," "))
cAccount  := AllTrim(GetNewPar("MV_RELFROM"," "))
cEnvia    := "totvs@br.gt.com"
cRecebe   := "ricardo.souza@br.gt.com;adilson.moura@br.gt.com"
cPassword := AllTrim(GetNewPar("MV_RELPSW" ," "))

CN1->(DbSetOrder(1))
If CN1->(DbSeek(xFilial("CN1")+CN9->CN9_TPCTO))
	If CN1->CN1_ESPCTR == "1" //Compra
		cCliFor := 'F'
	ElseIf  CN1->CN1_ESPCTR == "2" //Venda
		cCliFor := 'C'
	EndIf
EndIf

cMensagem+="<html xmlns='http://www.w3.org/TR/REC-html40'>
cMensagem+="<head>"

cMensagem+="<style type='text/css'>"	

cMensagem+=".td_tit {
cMensagem+="	background:#A895CC;"
cMensagem+="	padding:.75pt .75pt .75pt .75pt;"
cMensagem+="	font-size:10pt;"
cMensagem+=" 	font-family:'Segoe UI','sans-serif';"
cMensagem+=" 	font-weight: bold;"
cMensagem+=" 	color: #FFF;"
cMensagem+=" 	text-align:center;"
cMensagem+="}

cMensagem+=".td_txt {
cMensagem+="	background:#D4BBFD;"
cMensagem+="	padding:.75pt .75pt .75pt .75pt;"
cMensagem+="	font-size:10pt;"
cMensagem+=" 	font-family:'Segoe UI','sans-serif';"
cMensagem+="}

cMensagem+="</style>"
cMensagem+="</head>"

cMensagem+="<body>"
	
cMensagem+="Foi incluido um novo contrato no sistema."	

cMensagem+="<br>"
cMensagem+="<br>"
	
cMensagem+="<table border='0'>"
cMensagem+="	<tr>"
cMensagem+="		<td class='td_tit' colspan='2'>Detalhes</td>"
cMensagem+="	</tr>"
cMensagem+="	<tr>"
cMensagem+="		<td class='td_tit'>Numero:</td>"
cMensagem+="		<td class='td_txt'>"+Alltrim(CN9->CN9_NUMERO)+"</td>"
cMensagem+="	</tr>"
cMensagem+="	<tr>"
cMensagem+="		<td class='td_tit'>Empresa:</td>"
cMensagem+="		<td class='td_txt'>"+Alltrim(SM0->M0_NOME)+"-"+Alltrim(SM0->M0_FILIAL)+"</td>"
cMensagem+="	</tr>"
cMensagem+="	<tr>"
cMensagem+="		<td class='td_tit'>Data Inicial:</td>"
cMensagem+="		<td class='td_txt'>"+DtoC(CN9->CN9_DTINIC)+"</td>"
cMensagem+="	</tr>"
cMensagem+="	<tr>"
cMensagem+="		<td class='td_tit'>Valor Inicial:</td>"
cMensagem+="		<td class='td_txt'>"+Transform(CN9->CN9_VLINI,"@E 999,999,999.99")+"</td>"
cMensagem+="	</tr>"
cMensagem+="</table>"

cMensagem+="<br>"

If cCliFor == "C"
    
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1")+CN9->CN9_CLIENT+CN9->CN9_LOJACL))

		cMensagem+="<table border='0'>"
		cMensagem+="	<tr>"
		cMensagem+="		<td class='td_tit' colspan='2'>Cliente</td>"
		cMensagem+="	</tr>"
		cMensagem+="	<tr>"
		cMensagem+="		<td class='td_tit'>Codigo</td>"
		cMensagem+="		<td class='td_txt'>"+Alltrim(CN9->CN9_CLIENT)+"</td>"
		cMensagem+="	</tr>"
		cMensagem+="	<tr>"
		cMensagem+="		<td class='td_tit'>Loja</td>"
		cMensagem+="		<td class='td_txt'>"+Alltrim(CN9->CN9_LOJACL)+"</td>"
		cMensagem+="	</tr>"
		cMensagem+="	<tr>"
		cMensagem+="		<td class='td_tit'>Nome</td>"
		cMensagem+="		<td class='td_txt'>"+Alltrim(SA1->A1_NOME)+"</td>"
		cMensagem+="	</tr>"
		cMensagem+="	<tr>"
		cMensagem+="		<td class='td_tit'>CNPJ</td>"
		cMensagem+="		<td class='td_txt'>"+Alltrim(SA1->A1_CGC)+"</td>"
		cMensagem+="	</tr>"
		cMensagem+="</table>"

	EndIf
   
Else
   		
	CNC->(DbSetOrder(1))
	If CNC->(DbSeek(xFilial("CNC")+CN9->CN9_NUMERO))

		cMensagem+="<table border='0'>"
		cMensagem+="	<tr>"
		cMensagem+="		<td class='td_tit' colspan='5'>Fornecedores</td>"
		cMensagem+="	</tr>"

		cMensagem+="<tr>"
		cMensagem+="	<td class='td_tit'>Codigo</td>"
		cMensagem+="	<td class='td_tit'>Loja</td>"
		cMensagem+="	<td class='td_tit'>Nome</td>"
		cMensagem+="	<td class='td_tit'>CNPJ</td>"
		cMensagem+="</tr>"

		While CNC->(!EOF()) .and. CNC->CNC_NUMERO == CN9->CN9_NUMERO
					
			SA2->(DbSetOrder(1))
			If SA2->(DbSeek(xFilial("SA2")+CNC->CNC_CODIGO+CNC->CNC_LOJA))                
					
				cMensagem+="<tr>"
				cMensagem+="	<td class='td_txt'>"+Alltrim(CNC->CNC_CODIGO)+"</td>"
				cMensagem+="	<td class='td_txt'>"+Alltrim(CNC->CNC_LOJA)+"</td>"
				cMensagem+="	<td class='td_txt'>"+Alltrim(SA2->A2_NOME)+"</td>"
				cMensagem+="	<td class='td_txt'>"+Alltrim(SA2->A2_CGC)+"</td>"
				cMensagem+="</tr>"
			EndIf
					
			CNC->(DbSkip())
		EndDo
	
		cMensagem+="</table>"

	EndIf	
EndIf

cMensagem+="</body>"
cMensagem+="</html>"
	 
CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lConectou     //realiza conexão com o servidor de internet
	
If lConectou
	SEND MAIL FROM cEnvia;
	TO cRecebe;
	SUBJECT 'Inclusao de Contrato' ;
	BODY EncodeUTF8(cMensagem) ;
	RESULT lEnviado
Endif
	 
DISCONNECT SMTP SERVER Result lDisConectou

Return Nil


/*Static Function AtuNDCTR()

cQuery := "" 
cQuery := "SELECT B1_FILIAL, B1_COD, B1_DESC, B1_GRUPO, R_E_C_N_O_ RECNO "
cQuery += ' FROM '+ RetSQLname("SB1")
cQuery += " WHERE D_E_L_E_T_ <> '*' "
cQuery += " AND B1_FILIAL = '"+xFilial("SB1")+ " '"
cQuery += " AND B1_GRUPO = 'ND  ' "
cQuery += " AND B1_MSBLQL <> '1' "
cQuery += " ORDER BY B1_COD+B1_DESC "
MEMOWRIT("SELSB1.SQL",cQuery)
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TMP", .F., .T.)
dbSelectArea("TMP")
DbGoTop()
    
While !Eof()
    cItem         += Iif(Empty(cItem),Alltrim(TMP->B1_COD),"/"+Alltrim(TMP->B1_COD))
	dbSelectArea("TMP")
	dbSkip()
EndDo
cItem += "/"           

dbSelectArea("TMP")
dbCloseArea("TMP")

RestArea(cAlias)      

Return*/
