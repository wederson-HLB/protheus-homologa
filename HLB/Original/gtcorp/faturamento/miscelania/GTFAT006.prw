#include "TOPCONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"  
#include "Protheus.ch"
#include "Rwmake.ch"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWBROWSE.CH"

/*
Funcao      : GTFAT006
Parametros  : 
Retorno     : 
Objetivos   : Rotina de manutencão de Anuidade/DIPJ
Autor       : Jean Victor Rocha
Data/Hora   : 20/03/2014
*/
*----------------------*
User Function GTFAT006()
*----------------------*
Local i
Local aCposVld := {"CN9_P_ANUI","CN9_P_CPAN","CN9_P_VLAN","CN9_P_DIPJ","CN9_P_CPDI","CN9_P_VLDI","CJ_P_CONTR","CJ_P_TPORC"}

CN9->(DbSetOrder(1))
CNJ->(DbSetOrder(1))

For i:=1 to Len(aCposVld)
	If FieldVld(aCposVld[i]) == 0
		MsgInfo("Ambiente não preparado para a execução da Rotina!","Grant Thornton Brasil")
		Return .T.	
	EndIf
Next i

Main()

Return .T.

/*
Funcao      : Main
Parametros  : 
Retorno     : 
Objetivos   : Rotina Principal
Autor       : Jean Victor Rocha
Data/Hora   : 20/03/2014
*/
*--------------------*
Static Function Main()
*--------------------*
Local lWizard		:= .F.

Local cCadastro		:= "Grant Thornton Brasil - DIPJ / Anuidade"
Local cTituloWiz	:= "Manutenção"
Local cTextoWiz		:= "Rotina de Manutenção de Orçamentos Gerados a partir de informações do Contrato."

Local cTitulo1		:= "Tipo de Manutenção"
Local cTexto1		:= "Informe o Tipo de Manutenção desejada."

Local cTitulo2		:= "Parametros para Manutenção"
Local cTexto2		:= "Parametros para Execução da Manutenção."

Local cTitulo3		:= "Processamento"
Local cTexto3		:= "Processamento..."

Private oWizard

Private aItens		:= {"Anuidade","DIPJ"}
Private nTipo		:= 0
Private dDtRef		:= STOD(STRZERO(YEAR(dDataBase),4)+STRZERO(11,2)+"01")
Private aItensCom1	:= {'1=Previa','2=Efetiva'}
Private cCombo1		:= aItensCom1[1]

Private aExcel		:= {}

Private nopc := 3

SetPrvt("oGet32","oSay32","oCom31","oSay31","oSBox2","oSBox1","oCbx","oSayTxt","oBrw1")

oWizard := APWizard():New(cCadastro, ""/*<chMsg>*/, cTituloWiz,cTextoWiz,{|| .T.}/*<bNext>*/,{|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,,,/*<.lNoFirst.>*/ )

//Painel 2
oWizard:NewPanel( cTitulo1, cTexto1,{ ||.T.}/*<bBack>*/,;
												{|| IIF(nTipo<>0,AtuTela('cCombo1'),(MsgInfo("Selecione uma opção!","Grant Thornton Brasil"),.F.))}/*<bNext>*/,;
												{|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )
oSBox2 := TScrollBox():New( oWizard:oMPanel[2],010,010,125,280,.F.,.F.,.T. )
oCbx:= TRadMenu():New( 028,020,aItens,,oSBox2,,,CLR_BLACK,CLR_WHITE,"",,,140,32,,.F.,.F.,.T. )
oCbx:bSetGet := {|u| If(PCount()==0,nTipo,nTipo:=u)}

//Painel 3
oWizard:NewPanel( cTitulo2, cTexto2,{ ||.F.}/*<bBack>*/,{|| .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, /*<bExecute>*/ )
oSBox3 := TScrollBox():New( oWizard:oMPanel[3],010,010,125,280,.F.,.F.,.T. )

oSay31 := TSay():New(21,20,{|| "Tp. Processamento"},oSBox3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
oCom31 := tComboBox():New(20,100,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aItensCom1,100,20,oSBox3,,{|| AtuTela('cCombo1')},,,,.T.,,,,,,,,,'cCombo1')

oSay32 := TSay():New(41,20,{|| "Dt. Ref."},oSBox3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
oSay32B:= TSay():New(41,100,{|| STRZERO(MONTH(dDtRef),2)+"/"+STRZERO(YEAR(dDtRef),4)},oSBox3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,068,008)
//oGet32 := TGet():New(40,100,{|u| if(PCount()>0,dDtRef:=u,dDtRef)},oSBox3,50,05,'99/9999',{|o|},,,,,,.T.,,,,,,,.T.,,,'dDtRef')

//Painel 4
oWizard:NewPanel( cTitulo3, cTexto3,{ ||.F.}/*<bBack>*/,/*<bNext>*/, {|| lWizard := .T.,.T.}/*<bFinish>*/, /*<.lPanel.>*/,{|| ProcMain(@oWizard)}/*<bExecute>*/ )

@ 11,20 SAY oSayTxt VAR ""  SIZE 100,10 OF oWizard:oMPanel[4] PIXEL
nMeter := 0
oMeter := TMeter():New(20,20,{|u|if(Pcount()>0,nMeter:=u,nMeter)},0,oWizard:oMPanel[4],250,34,,.T.,,,,,,,,,)
oMeter:Set(0) 

oBtn31 := TButton():New( 06,240,"Gerar Excel",oWizard:oMPanel[4],{|| ImpExcel()},037,012,,,,.T.,,"",,,,.F. )

aAlter	:= {}
aHoBrw1 := {}
aCoBrw1 := {}
Aadd(aHoBrw1,{"Cod.Cli"		,"CN9_CLIENT"	,"",TamSX3("CN9_CLIENT")[1],TamSX3("CN9_CLIENT")[2],"","",TamSX3("CN9_CLIENT")[3],"",""})
Aadd(aHoBrw1,{"Lj.Cli"  	,"CN9_LOJACL"	,"",TamSX3("CN9_LOJACL")[1],TamSX3("CN9_LOJACL")[2],"","",TamSX3("CN9_LOJACL")[3],"",""})
Aadd(aHoBrw1,{"Nome Cli"	,"CN9_P_NOME"	,"",TamSX3("CN9_P_NOME")[1],TamSX3("CN9_P_NOME")[2],"","",TamSX3("CN9_P_NOME")[3],"",""})
Aadd(aHoBrw1,{"Valor"  		,"VALOR" 		,"",16,02,"","","N","",""})
Aadd(aHoBrw1,{"N.Contra."	,"CN9_NUMERO" 	,"",TamSX3("CN9_NUMERO")[1],TamSX3("CN9_NUMERO")[2],"","",TamSX3("CN9_NUMERO")[3],"",""})
Aadd(aHoBrw1,{"Cond.Pag."	,"CN9_CONDPG" 	,"",TamSX3("CN9_CONDPG")[1],TamSX3("CN9_CONDPG")[2],"","",TamSX3("CN9_CONDPG")[3],"",""})
Aadd(aHoBrw1,{"Status"		,"STATUS" 		,"",60,00,"","","C","",""})

oGrp := TGroup():New( 024,004,138,296,"",oWizard:oMPanel[4],,,.T.,.F. )                
oBrw1 := MsNewGetDados():New(030,008,134,292,nOpc,'AllwaysTrue()','AllwaysTrue()','',aAlter,0,99999,'AllwaysTrue()','','AllwaysTrue()',oGrp,aHoBrw1,aCoBrw1 )

oWizard:Activate( .T./*<.lCenter.>*/,/*<bValid>*/, /*<bInit>*/, /*<bWhen>*/ )

Return .T.

/*
Funcao      : AtuTela
Parametros  : 
Retorno     : 
Objetivos   : Função auxiliar para atualizaçaõ de informações da Tela, wizard.
Autor       : Jean Victor Rocha
Data/Hora   : 20/03/2014
*/
*-------------------------------*
Static Function ProcMain(oWizard)
*-------------------------------*
Local cQuery := ""
Local nCount := 0
Local cNumOrc := ""
Local lNumOrc := .F. 
Local cOperName:= ""

cQuery += " Select * From "+RETSQLNAME("CN9")+" CN9
If nTipo == 1//Anuidade
	cQuery += " Where CN9.D_E_L_E_T_ <> '*' AND CN9.CN9_P_ANUI <> '' AND CN9.CN9_P_ANUI <> '1' AND CN9_SITUAC = '05' "// JSS - 01/04/2015 Add a condição AND CN9_SITUAC = '05'  devido solicitação do Ricardo Souza, enviada por e-mail pelo Tiago Mendonça.
ElseIf nTipo == 2
	cQuery += " Where CN9.D_E_L_E_T_ <> '*' AND CN9.CN9_P_DIPJ <> '' AND CN9.CN9_P_DIPJ <> '1' AND CN9_SITUAC = '05' "// JSS - 01/04/2015 Add a condição AND CN9_SITUAC = '05'  devido solicitação do Ricardo Souza, enviada por e-mail pelo Tiago Mendonça.
EndIf  

If Select("QRY") > 0
	QRY->(DbClosearea())
Endif     	             	
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

Count to nCount

If nCount == 0
	oSayTxt:CCAPTION				:= "Sem Informações a serem processadas!"	
	oMeter:LVISIBLE					:= .F. 
	oWizard:OBACK:LVISIBLECONTROL	:= .T.
	oWizard:OCANCEL:LVISIBLECONTROL	:= .T.
	oWizard:ONEXT:LVISIBLECONTROL	:= .T.
	oWizard:OFINISH:LVISIBLECONTROL	:= .T.
	oBtn31:LVISIBLE := .F.
	oBrw1:OBROWSE:LVISIBLECONTROL	:= .F.
	oBrw1:OWND:LVISIBLECONTROL		:= .F.
	Return .T.
Else
	oSayTxt:CCAPTION				:= "Aguarde..."	
	oMeter:LVISIBLE					:= .T. 
	oWizard:OBACK:LVISIBLECONTROL	:= .F.
	oWizard:OCANCEL:LVISIBLECONTROL	:= .F.
	oWizard:ONEXT:LVISIBLECONTROL	:= .F.
	oWizard:OFINISH:LVISIBLECONTROL	:= .F. 
	oBtn31:LVISIBLE := .F.
	oBrw1:OBROWSE:LVISIBLECONTROL	:= .F.
	oBrw1:OWND:LVISIBLECONTROL		:= .F.
EndIf

oMeter:NTOTAL := nCount
nRec := 0        
QRY->(DbGoTop())
While QRY->(!EOF())               
	nRec++
	oMeter:Set(nRec)      
	//Definição do Valor.		//JSS ALTERADO
/*
	If nTipo == 1//Anuidade
		If QRY->CN9_P_ANUI $ "2/3"
			nValor := QRY->CN9_P_VLAN
		ElseIf QRY->CN9_P_ANUI $ "4"
			nValor := GETMEDIA()
		EndIf
		cCondPag := QRY->CN9_P_CPAN
	ElseIf nTipo == 2
		If QRY->CN9_P_DIPJ $ "2/3"	
			nValor := QRY->CN9_P_VLDI
		ElseIf QRY->CN9_P_DIPJ $ "4"	
			nValor := GETMEDIA()
		EndIf
		cCondPag := QRY->CN9_P_CPDI
	EndIf 
*/     
	If nTipo == 1//Anuidade
		If QRY->CN9_P_ANUI     $ "1"
			nValor := QRY->CN9_P_VLAN
			cOperName:= "Inativo"
		ElseIf QRY->CN9_P_ANUI $ "2"
			nValor := QRY->CN9_P_VLAN
			cOperName:= "Fixo"
		ElseIf QRY->CN9_P_ANUI $ "3"
			nValor := QRY->CN9_P_VLAN
			cOperName:= "Negociado"			
		ElseIf QRY->CN9_P_ANUI $ "4"
			nValor := GETMEDIA()
			cOperName:= "Media Trimestral"
		EndIf
		cCondPag := QRY->CN9_P_CPAN
	ElseIf nTipo == 2
		If QRY->CN9_P_DIPJ 	   $ "1"	
			nValor := QRY->CN9_P_VLDI
			cOperName:= "Inativo" 
		ElseIf QRY->CN9_P_DIPJ $ "2"	
			nValor := QRY->CN9_P_VLDI
			cOperName:= "Fixo"
		ElseIf QRY->CN9_P_DIPJ $ "3"	
			nValor := QRY->CN9_P_VLDI
			cOperName:= "Negociado"
		ElseIf QRY->CN9_P_DIPJ $ "4"	
			nValor := GETMEDIA()
			cOperName:= "Media Trimestral"
		EndIf
		cCondPag := QRY->CN9_P_CPDI
	EndIf 
	aAdd(aCoBrw1,{	QRY->CN9_CLIENT,;
					QRY->CN9_LOJACL,;
					QRY->CN9_P_NOME,;
					TRANSFORM(nValor,"@R 999999999.99"),;
					QRY->CN9_NUMERO,;
					cCondPag,;
					QRY->CN9_FILIAL,;//JSS 01/04/2015 Add a campo QRY->CN9_FILIAL devido solicitação do Ricardo Souza, enviada por e-mail pelo Tiago Mendonça.
					cOperName,;
					"",;
					.F.})//Deletado

	If nValor == 0
		aCoBrw1[Len(aCoBrw1)][Len(aCoBrw1[Len(aCoBrw1)])-1] := "Valor igual a zero!"
		aCoBrw1[Len(aCoBrw1)][Len(aCoBrw1[Len(aCoBrw1)])] := .T.
		QRY->(DbSkip())
		Loop
	EndIf	

	cQryTmp := "Select SCK.CK_NUMPV,SCJ.R_E_C_N_O_ AS SCJ,SCK.R_E_C_N_O_ AS SCK 
	cQryTmp += " From "+RetSQLName("SCJ")+" SCJ
	cQryTmp += " 		Join "+RetSQLName("SCK")+" as SCK on SCJ.CJ_FILIAL = SCK.CK_FILIAL AND SCJ.CJ_NUM = SCK.CK_NUM
	cQryTmp += " Where SCK.D_E_L_E_T_ <> '*'
	cQryTmp += " 		AND SCJ.D_E_L_E_T_ <> '*'
	cQryTmp += " 		AND SCJ.CJ_FILIAL = '"+xFilial("SCJ")+"' 
	cQryTmp += " 		AND SCJ.CJ_P_CONTR = '"+QRY->CN9_NUMERO+"'
	cQryTmp += " 		AND SUBSTRING(SCJ.CJ_EMISSAO,1,4) = '"+STRZERO(YEAR(dDataBase),4)+"'"
	If Select("TMP") > 0
		TMP->(DbClosearea())
	Endif     	             	
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQryTmp),"TMP",.F.,.T.)    

	TMP->(DbGoTop())
	lTemPv := .F.
	lNumOrc := .F.
	While TMP->(!EOF())
		If EMPTY(TMP->CK_NUMPV)
			If cCombo1 <> LEFT(aItensCom1[1],1)//Diferente de Previa
				SCJ->(DbGoTo(TMP->SCJ))
				cNumOrc := SCJ->CJ_NUM//Salva o Numero do Orçamento
				lNumOrc := .T.
				SCJ->(RecLock("SCJ",.F.))
				SCJ->(DbDelete())
				SCJ->(MsUnLock())
	
				SCK->(DbGoTo(TMP->SCK))
				SCK->(RecLock("SCK",.F.))
				SCK->(DbDelete())
				SCK->(MsUnLock())
				aCoBrw1[Len(aCoBrw1)][Len(aCoBrw1[Len(aCoBrw1)])-1] := "Orcamento Sobrescrito!  /  "
			Else
				aCoBrw1[Len(aCoBrw1)][Len(aCoBrw1[Len(aCoBrw1)])-1] := "Orcamento sera Sobrescrito!  /  "
			EndIf
		Else
			lTemPv := .T.
		EndIf
		TMP->(DbSkip())
	EndDo
	
	If lTemPv
		aCoBrw1[Len(aCoBrw1)][Len(aCoBrw1[Len(aCoBrw1)])-1] := "Ja possui Orcamento utilizado, nao sera reprocessado!"
		aCoBrw1[Len(aCoBrw1)][Len(aCoBrw1[Len(aCoBrw1)])] := .T.
		QRY->(DbSkip())
		Loop
	EndIf

	If cCombo1 <> LEFT(aItensCom1[1],1)//Diferente de Previa
		SA1->(DbSetOrder(1))
		If !SA1->(DbSeek(xFilial("SA1")+QRY->CN9_CLIENT+QRY->CN9_LOJACL))
			aCoBrw1[Len(aCoBrw1)][Len(aCoBrw1[Len(aCoBrw1)])-1] += "Cliente '"+QRY->CN9_CLIENT+"-"+QRY->CN9_LOJACL+"' nao localizado!"
			aCoBrw1[Len(aCoBrw1)][Len(aCoBrw1[Len(aCoBrw1)])] := .T.
			QRY->(DbSkip())
			Loop
		EndIf
		
		SB1->(DbSetOrder(1))
		cProd := ""
		If SA1->A1_EST <> "EX"
			If nTipo == 1//Anuidade
				cProd := "300010"
			Else
				cProd := "300005"
			EndIf
		Else
			If nTipo == 1//Anuidade
				cProd := "400010"
			Else
				cProd := "400005"
			EndIf			
		EndIf
		If !SB1->(DbSeek(xFilial("SB1")+cProd))
			aCoBrw1[Len(aCoBrw1)][Len(aCoBrw1[Len(aCoBrw1)])-1] += "Produto '"+cProd+"' nao encontrado!"
			aCoBrw1[Len(aCoBrw1)][Len(aCoBrw1[Len(aCoBrw1)])] := .T.
			QRY->(DbSkip())
			Loop
		EndIf
		
		aCab := {}
		aIte := {}
		
		If !lNumOrc
			cNumOrc := GetSxeNum("SCJ","CJ_NUM")
		EndIf
		aadd(aCab,{"CJ_FILIAL"	,QRY->CN9_FILIAL})//JSS 01/04/2015 Add a condição  xFilial("SCJ")}) devido solicitação do Ricardo Souza, enviada por e-mail pelo Tiago Mendonça.
		aadd(aCab,{"CJ_NUM"		,cNumOrc})
		aadd(aCab,{"CJ_EMISSAO"	,dDataBase})
		aadd(aCab,{"CJ_CLIENTE"	,QRY->CN9_CLIENT})
		aadd(aCab,{"CJ_LOJA"	,QRY->CN9_LOJACL})
		aadd(aCab,{"CJ_CONDPAG"	,"001"})
		aadd(aCab,{"CJ_CLIENT"	,QRY->CN9_CLIENT})
		aadd(aCab,{"CJ_LOJAENT"	,QRY->CN9_LOJACL})
		aadd(aCab,{"CJ_TIPLIB"	,"1"})//Tipo de Liberação
		aadd(aCab,{"CJ_TPCARGA"	,"2"})//Tipo de Carga
		aadd(aCab,{"CJ_STATUS"	,"A"})
		aadd(aCab,{"CJ_USERLGI"	,cUsername	})
		aadd(aCab,{"CJ_P_CONTR" ,QRY->CN9_NUMERO})
		aadd(aCab,{"CJ_P_TPORC" ,ALLTRIM(STR(nTipo))})

		aadd(aIte,{"CK_FILIAL"	,QRY->CN9_FILIAL}) //JSS 01/04/2015 Add a condição  xFilial("SCK")}) devido solicitação do Ricardo Souza, enviada por e-mail pelo Tiago Mendonça.
		aadd(aIte,{"CK_FILVEN"	,QRY->CN9_FILIAL}) //JSS 01/04/2015 Add a condição  xFilial("SCK")}) devido solicitação do Ricardo Souza, enviada por e-mail pelo Tiago Mendonça.
		aadd(aIte,{"CK_FILENT"	,QRY->CN9_FILIAL}) //JSS 01/04/2015 Add a condição  xFilial("SCK")}) devido solicitação do Ricardo Souza, enviada por e-mail pelo Tiago Mendonça.
		aadd(aIte,{"CK_ITEM" 	,StrZero(1,2)})
		aadd(aIte,{"CK_QTDVEN"	,1})
		aadd(aIte,{"CK_PRCVEN"	,nValor})
		aadd(aIte,{"CK_VALOR"	,nValor})
		aadd(aIte,{"CK_CLIENTE"	,QRY->CN9_CLIENT})
		aadd(aIte,{"CK_LOJA"	,QRY->CN9_LOJACL})
		aadd(aIte,{"CK_NUM"		,cNumOrc})
		aadd(aIte,{"CK_PRODUTO"	,SB1->B1_COD})
		aadd(aIte,{"CK_DESCRI"	,LEFT(SB1->B1_DESC,30)})
		aadd(aIte,{"CK_TES"		,SB1->B1_TS})
		
		SCJ->(RecLock("SCJ",.T.))
		For i:=1 to Len(aCab)
			&("SCJ->("+aCab[i][1]+")") := aCab[i][2]
		Next i
		SCJ->(MsUnLock())
		
		SCK->(RecLock("SCK",.T.))
		For i:=1 to Len(aIte)
			&("SCK->("+aIte[i][1]+")") := aIte[i][2]
		Next i
		SCK->(MsUnLock())

		If !lNumOrc
			ConfirmSX8()
		EndIf
	EndIf
	QRY->(DbSkip())
EndDo

aExcel := aCoBrw1
oBrw1:ACOLS := aCoBrw1

oBrw1:OBROWSE:LVISIBLECONTROL	:= .T.
oBrw1:OWND:LVISIBLECONTROL		:= .T.
oSayTxt:CCAPTION				:= "Finalizado!"	
oMeter:LVISIBLE					:= .F. 
oWizard:OFINISH:LVISIBLECONTROL	:= .T. 
oBtn31:LVISIBLE := .T.

Return .T.

/*
Funcao      : ImpExcel
Parametros  : 
Retorno     : 
Objetivos   : Imprime em excel o array aExcel
Autor       : Jean Victor Rocha
Data/Hora   : 21/03/2014
*/
*------------------------*
Static Function ImpExcel()
*------------------------*
Local cDest := GetTempPath()+"\"
Local cArq  := IIF(nTipo==1,"ANUIDADE","DIPJ")+".XML"
Local cXml  := ""
Private nHdl := 0

If LEN(aExcel) <> 0
	//Inicializa o Arquivo
	If FILE(cDest+cArq)
		FERASE(cDest+cArq)
	EndIf
	nHdl 		:= FCREATE(cDest+cArq,0 )  	//Criação do Arquivo .
	nBytesSalvo := FWRITE(nHdl, cXml ) 		// Gravação do seu Conteudo.
	fclose(nHdl)						// Fecha o Arquivo que foi Gerado

	MontaXML(cDest,cArq)

	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
Else
	MsgInfo("Sem Dados para serem exibidos!")
EndIf

Return .T.

/*
Funcao      : GETMEDIA
Parametros  : 
Retorno     : 
Objetivos   : Retorna a Media dos ultimos 3 meses de lançamentos com base na dDtRef
Autor       : Jean Victor Rocha
Data/Hora   : 21/03/2014
*/
*------------------------*
Static Function GETMEDIA()
*------------------------*
Local nRet := 0
Local cQuery := ""
Local cDtRefIni := LEFT(DTOS(monthsub(dDtRef,3)),6)
Local cDtRefFim := LEFT(DTOS(monthsub(dDtRef,1)),6)

cQuery += "Select SUM(E1_VALOR)/3 as VALOR From "+RetSQLName("SE1")
cQuery += " Where E1_CLIENTE = '"+QRY->CN9_CLIENT+"' AND E1_LOJA = '"+QRY->CN9_LOJACL+"'
cQuery += " AND SUBSTRING(E1_EMISSAO,1,6) >= '"+cDtRefIni+"'
cQuery += " AND SUBSTRING(E1_EMISSAO,1,6) <= '"+cDtRefFim+"'

If Select("MEDIA") > 0
	MEDIA->(DbClosearea())
Endif     	             	
dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"MEDIA",.F.,.T.)

MEDIA->(DbGoTop())
If MEDIA->(!EOF()) .and. MEDIA->(!BOF())
	nRet := MEDIA->VALOR
EndIf

Return nRet

/*
Funcao      : AtuTela
Parametros  : 
Retorno     : 
Objetivos   : Função auxiliar para atualizaçaõ de informações da Tela, wizard.
Autor       : Jean Victor Rocha
Data/Hora   : 20/03/2014
*/
*----------------------------*
Static Function AtuTela(cInfo)
*----------------------------*
cInfo := UPPER(cInfo)

Do Case
	Case cInfo == "CCOMBO1"
//		If cCombo1 == LEFT(aItensCom1[1],1)
//			dDtRef := STOD(STRZERO(YEAR(dDataBase),4)+STRZERO(MONTH(dDataBase),2)+"01")
//			oSay32B:CCAPTION := STRZERO(MONTH(dDtRef),2)+"/"+STRZERO(YEAR(dDtRef),4)
//		Else
			If nTipo == 1//Anuidade
				dDtRef := STOD(STRZERO(YEAR(Date()),4)+STRZERO(11,2)+"01")
				oSay32B:CCAPTION := STRZERO(11,2)+"/"+STRZERO(YEAR(Date()),4)
			Else//DIPJ                                                          
				dDtRef := STOD(STRZERO(YEAR(Date()),4)+STRZERO(3,2)+"01")
				oSay32B:CCAPTION := STRZERO(3,2)+"/"+STRZERO(YEAR(Date()),4)
			EndIf
//		EndIf
EndCase

Return .T.

/*
Funcao      : FieldVld
Parametros  : cCampo
Retorno     : 
Objetivos   : Validação de campo na base.
Autor       : Jean Victor Rocha
Data/Hora   : 20/03/2014
*/
*------------------------------*
Static Function FieldVld(cCampo)
*------------------------------*
Local nRet := 0

SX3->(DbSetorder(2))
If SX3->(DbSeek(cCampo))
	nRet := (SX3->X3_ARQUIVO)->(FieldPos(cCampo))
EndIf

Return nRet

/*
Funcao      : MontaXML
Parametros  : cCampo
Retorno     : 
Objetivos   : Cria o arquivo XML
Autor       : Jean Victor Rocha
Data/Hora   : 21/03/2014
*/
*------------------------*
Static Function MontaXML(cDest,cArq)
*------------------------*
Local cXml := ""

cXml += '<?xml version="1.0"?>
cXml += '<?mso-application progid="Excel.Sheet"?>
cXml += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
cXml += ' xmlns:o="urn:schemas-microsoft-com:office:office"
cXml += ' xmlns:x="urn:schemas-microsoft-com:office:excel"
cXml += ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
cXml += ' xmlns:html="http://www.w3.org/TR/REC-html40">
cXml += ' <Styles>
cXml += '  <Style ss:ID="Default" ss:Name="Normal">
cXml += '   <Alignment ss:Vertical="Bottom"/>
cXml += '   <Borders/>
cXml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXml += '   <Interior/>
cXml += '   <NumberFormat/>
cXml += '   <Protection/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s63">
cXml += '   <Alignment ss:Vertical="Bottom"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s64">
cXml += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s65">
cXml += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml += '   <NumberFormat ss:Format="Short Date"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s66">
cXml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF" ss:Bold="1"/>
cXml += '   <Interior ss:Color="#7030A0" ss:Pattern="Solid"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s67">
cXml += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml += '   <NumberFormat ss:Format="@"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s68">
cXml += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml += '   <NumberFormat ss:Format="Currency"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s69">
cXml += '   <Alignment ss:Vertical="Bottom"/>
cXml += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s70">
cXml += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s71">
cXml += '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="14" ss:Color="#000000" ss:Bold="1"/>
cXml += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml += '  </Style>
cXml += ' </Styles>

cXml += '<Worksheet ss:Name="'+cEmpAnt+cFilAnt+'">
cXml += '  <Names>
cXml += '   <NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=Z801!R5C1:R5C7" ss:Hidden="1"/>
cXml += '  </Names>
cXml += '  <Table ss:ExpandedColumnCount="13" ss:ExpandedRowCount="200000" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">
cXml += '   <Column ss:Width="70.5"/>
cXml += '   <Column ss:Width="59.25"/>
cXml += '   <Column ss:AutoFitWidth="0" ss:Width="288"/>
cXml += '   <Column ss:AutoFitWidth="0" ss:Width="117"/>
cXml += '   <Column ss:Width="84.75"/>
cXml += '   <Column ss:Width="63.75"/>
cXml += '   <Column ss:AutoFitWidth="0" ss:Width="262.5"/>
cXml += '   <Column ss:StyleID="s70" ss:AutoFitWidth="0" ss:Width="36"/>
cXml += '   <Row ss:AutoFitHeight="0" ss:Height="18.75">
cXml += '    <Cell ss:MergeAcross="6" ss:StyleID="s71"><Data ss:Type="String">Relatorio '+IIF(nTipo==1,"Anuidade","DIPJ")+'</Data></Cell>
cXml += '    <Cell ss:StyleID="s63"/>
cXml += '    <Cell ss:StyleID="s63"/>
cXml += '    <Cell ss:StyleID="s63"/>
cXml += '    <Cell ss:StyleID="s63"/>
cXml += '    <Cell ss:StyleID="s63"/>
cXml += '    <Cell ss:StyleID="s63"/>
cXml += '   </Row>
cXml += '   <Row ss:AutoFitHeight="0">
cXml += '    <Cell ss:StyleID="s64"><Data ss:Type="String">Data:</Data></Cell>
cXml += '    <Cell ss:StyleID="s65"><Data ss:Type="DateTime">
cXml += STRZERO(YEAR(DATE()),4)+'-'+STRZERO(MONTH(DATE()),2)+'-'+STRZERO(DAY(DATE()),2)+'T00:00:00.000</Data></Cell>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '   </Row>
cXml += '   <Row ss:AutoFitHeight="0">
cXml += '    <Cell ss:StyleID="s64"><Data ss:Type="String">Tipo:</Data></Cell>
cXml += '    <Cell ss:StyleID="s64"><Data ss:Type="String">'+IIF(cCombo1==LEFT(aItensCom1[1],1),"Previa","Efetiva")+'</Data></Cell>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s65"/>
cXml += '   </Row>
cXml += '   <Row ss:AutoFitHeight="0">
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '   </Row>
cXml += '   <Row ss:AutoFitHeight="0">
cXml += '    <Cell ss:StyleID="s66"><Data ss:Type="String">Filial 		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cXml += '    <Cell ss:StyleID="s66"><Data ss:Type="String">Cliente 		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cXml += '    <Cell ss:StyleID="s66"><Data ss:Type="String">Loja			</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cXml += '    <Cell ss:StyleID="s66"><Data ss:Type="String">Descricao	</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cXml += '    <Cell ss:StyleID="s66"><Data ss:Type="String">'+IIF(nTipo==1,"Anuidade","DIPJ")+'</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cXml += '    <Cell ss:StyleID="s66"><Data ss:Type="String">Valor		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cXml += '    <Cell ss:StyleID="s66"><Data ss:Type="String">N.Contrato	</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cXml += '    <Cell ss:StyleID="s66"><Data ss:Type="String">Cond.Pag.	</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cXml += '    <Cell ss:StyleID="s66"><Data ss:Type="String">Log			</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
cXml += '   </Row>
cXml := GrvInfo(cXml,cDest,cArq)

For i:=1 to Len(aExcel)
	cXml += ' <Row ss:AutoFitHeight="0">
	cXml += '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+aExcel[i][7]+'</Data></Cell>
	cXml += '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+aExcel[i][1]+'</Data></Cell>
	cXml += '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+aExcel[i][2]+'</Data></Cell>
	cXml += '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+aExcel[i][3]+'</Data></Cell>
	cXml += '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+aExcel[i][8]+'</Data></Cell>
	cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="Number">'+ALLTRIM(aExcel[i][4])+'</Data></Cell>
	cXml += '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+aExcel[i][5]+'</Data></Cell>
	cXml += '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+aExcel[i][6]+'</Data></Cell>
	cXml += '    <Cell ss:StyleID="s67"><Data ss:Type="String">'+aExcel[i][9]+'</Data></Cell>
	cXml += '   </Row>
Next i
cXml += '<Row ss:AutoFitHeight="0">
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '   </Row>
cXml += '   <Row ss:AutoFitHeight="0">
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '    <Cell ss:StyleID="s64"/>
cXml += '   </Row>
cXml += '  </Table>
cXml += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
cXml += '   <PageSetup>
cXml += '    <Layout x:Orientation="Landscape"/>
cXml += '    <Header x:Margin="0.3"/>
cXml += '    <Footer x:Margin="0.3"/>
cXml += '    <PageMargins x:Bottom="0.75" x:Left="0.25" x:Right="0.25" x:Top="0.75"/>
cXml += '   </PageSetup>
cXml += '   <Unsynced/>
cXml += '   <Print>
cXml += '    <ValidPrinterInfo/>
cXml += '    <PaperSizeIndex>9</PaperSizeIndex>
cXml += '	 <Scale>76</Scale>
cXml += '   </Print>
cXml += '   <ShowPageBreakZoom/>
cXml += '   <PageBreakZoom>100</PageBreakZoom>
cXml += '   <Selected/>
cXml += '  </WorksheetOptions>
cXml += '  <AutoFilter x:Range="R5C1:R5C7" xmlns="urn:schemas-microsoft-com:office:excel"></AutoFilter>
cXml += ' </Worksheet>
cXml += '</Workbook>

cXml := GrvInfo(cXml,cDest,cArq)

Return .T.



/*
Funcao      : GrvInfo()
Parametros  : 
Retorno     : 
Objetivos   : Grava a String enviada no arquivo.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------------*
Static Function GrvInfo(cMsg,cDest,cArq)
*--------------------------------------*
Local nHdl		:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""