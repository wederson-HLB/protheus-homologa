#Include "Protheus.ch"

/*
Funcao      : GTCORP10
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Importação(duplicação) dos lançamentos contábeis da filial 06 e 08 para a 05 e da filial 02 e 03 para a 01
Autor       : Matheus Massarotto
Data/Hora   : 17/04/2012    14:26
Revisão		:
Data/Hora   : 
Módulo      : Contabilidade
*/
*---------------------*
User Function GTCORP10
*---------------------*
Local cTitulo := "Lançamentos Contábeis"
Local bCondicao := {|| .T.}
// Variáveis utilizadas na seleção de categorias
Local oChkQual,lQual,oQual,cVarQ
// Carrega bitmaps
Local oOk := LoadBitmap( GetResources(), "LBOK")
Local oNo := LoadBitmap( GetResources(), "LBNO")
Local cFilQry:=""
Private oDlgx

if !cEmpAnt $ "Z4"
	alert("Empresa não autorizada!")
	return

endif

if !cFilAnt $ "05/01"
	alert("Filial não autorizada!")
	return
endif

Private aCabec:={}
Private aColsCT2:={}
Private cTitQry:=""
Private cTitArr:=""
Private cTitItem:=""
Private nCont:=1
Private nLinACol:=0
Private cFilial:=""

Private cPerg:="GTCORP10"


if cFilAnt == "05"
	cFilQry:="'06','08'"
elseif cFilAnt == "01"
	cFilQry:="'02','03'"
endif

	
	//Monta a pergunta
	PutSx1( cPerg, "01", "Data De:", "Data De:", "Data De:", "", "D",08,00,00,"G","" , "","","","MV_PAR01")
	PutSx1( cPerg, "02", "Data Ate:", "Data Ate:", "Data Ate:", "", "D",08,00,00,"G","" , "","","","MV_PAR02")
	
	if !Pergunte(cPerg,.T.)
		Return
	endif
    
	//MSM - 05/05/2016 - Chamado: 033571, Alteração de filial solicitada pela Haidee
	if MV_PAR01 >= CTOD("01/05/2016") .OR. MV_PAR02 >= CTOD("01/05/2016")
    	if cFilAnt == "05"
    		alert("A partir de 01/05/2016 os lançamentos devem ser realizados na filial 01.")
    		Return
    	else
			cFilQry:="'02','03','04','06','08','10'"
    	endif
	endif

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("CT2")
	
	AADD(aCabec,"")
	cCab:=""
	While !Eof().And.(SX3->X3_ARQUIVO=="CT2")
		//if X3USO(SX3->X3_USADO)	    
		//CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA,CT2_MOEDLC,CT2_DC,CT2_DEBITO,CT2_ITEMD,CT2_CCD,CT2_CREDIT,CT2_ITEMC,CT2_CCC,CT2_CDC,CT2_DCC,CT2_VALOR,CT2_HIST,CT2_CLVLDB,CT2_CLVLCR,CT2_EMPORI,CT2_FILORI,CT2_SEQUEN,CT2_MANUAL,CT2_TPSALD,CT2_ORIGEM,CT2_AGLUT,CT2_ROTINA,CT2_SEQHIS,CT2_SEQLAN,CT2_LP,CT2_CRCONV,CT2_DTCV3,CT2_DTCONF,CT2_MLTSLD
		if alltrim(SX3->X3_CAMPO)=="CT2_DATA" .OR. alltrim(SX3->X3_CAMPO)=="CT2_LOTE" .OR. alltrim(SX3->X3_CAMPO)=="CT2_SBLOTE" .OR. alltrim(SX3->X3_CAMPO)=="CT2_DOC" .OR. alltrim(SX3->X3_CAMPO)=="CT2_LINHA" .OR. alltrim(SX3->X3_CAMPO)=="CT2_MOEDLC" .OR. alltrim(SX3->X3_CAMPO)=="CT2_DC" .OR. alltrim(SX3->X3_CAMPO)=="CT2_DEBITO" .OR. alltrim(SX3->X3_CAMPO)=="CT2_ITEMD" .OR. alltrim(SX3->X3_CAMPO)=="CT2_CCD" .OR. alltrim(SX3->X3_CAMPO)=="CT2_CREDIT" .OR. alltrim(SX3->X3_CAMPO)=="CT2_ITEMC" .OR. alltrim(SX3->X3_CAMPO)=="CT2_CCC" .OR. alltrim(SX3->X3_CAMPO)=="CT2_DCD" .OR. alltrim(SX3->X3_CAMPO)=="CT2_DCC" .OR. alltrim(SX3->X3_CAMPO)=="CT2_VALOR" .OR. alltrim(SX3->X3_CAMPO)=="CT2_HIST" .OR. alltrim(SX3->X3_CAMPO)=="CT2_CLVLDB" .OR. alltrim(SX3->X3_CAMPO)=="CT2_CLVLCR" .OR. alltrim(SX3->X3_CAMPO)=="CT2_EMPORI" .OR. alltrim(SX3->X3_CAMPO)=="CT2_FILORI" .OR. alltrim(SX3->X3_CAMPO)=="CT2_SEQUEN" .OR. alltrim(SX3->X3_CAMPO)=="CT2_MANUAL" .OR. alltrim(SX3->X3_CAMPO)=="CT2_TPSALD" .OR. alltrim(SX3->X3_CAMPO)=="CT2_ORIGEM" .OR. alltrim(SX3->X3_CAMPO)=="CT2_AGLUT" .OR. alltrim(SX3->X3_CAMPO)=="CT2_ROTINA" .OR. alltrim(SX3->X3_CAMPO)=="CT2_SEQHIS" .OR. alltrim(SX3->X3_CAMPO)=="CT2_SEQLAN" .OR. alltrim(SX3->X3_CAMPO)=="CT2_LP" .OR. alltrim(SX3->X3_CAMPO)=="CT2_CRCONV" .OR. alltrim(SX3->X3_CAMPO)=="CT2_DTCV3" .OR. alltrim(SX3->X3_CAMPO)=="CT2_DTCONF" .OR. alltrim(SX3->X3_CAMPO)=="CT2_MLTSLD" 
			nCont++
			AADD(aCabec,ALLTRIM(SX3->X3_CAMPO))
			cCab+='"'+ALLTRIM(SX3->X3_TITULO)+'",'
			cTitQry+=ALLTRIM(SX3->X3_CAMPO)+","
			cTitArr+="TRBQRY->"+ALLTRIM(SX3->X3_CAMPO)+","
			
			cTitItem+="aColsCT2[oQual:nAt,"+cvaltochar(nCont)+"],"
	    endif
	SX3->(DbSkip())
    enddo
    
    cTitQry:=SUBSTR(cTitQry,1,len(cTitQry)-1)+",R_E_C_N_O_"
    cTitArr:=SUBSTR(cTitArr,1,len(cTitArr)-1)
    cTitItem:=SUBSTR(cTitItem,1,len(cTitItem)-1)

	cQry:=" SELECT "+cTitQry+" FROM "+RETSQLNAME("CT2")
	cQry+=" WHERE D_E_L_E_T_='' AND CT2_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND CT2_P_DTDU='' AND CT2_FILIAL IN ("+cFilQry+")"

		if select("TRBQRY")>0
		TRBQRY->(DbCloseArea())
		endif
		
		DbUseArea( .T., "TOPCONN", TcGenqry( , , cQry), "TRBQRY", .F., .F. )
		
		DbSelectArea("TRBQRY")
		TRBQRY->(DbGoTop())
	    
		Count to nRecCount
		
		if nRecCount> 0
			TRBQRY->(DbGoTop())

			While TRBQRY->(!EOF())
				aAuxCT2:=STRTOKARR(cTitArr,",")
				AADD(aColsCT2,{})
				nLinACol++
	
				AADD(aColsCT2[nLinACol],"")							
				for i:=1 to len(aAuxCT2) 
					AADD(aColsCT2[nLinACol],&(aAuxCT2[i]))
				next
				AADD(aColsCT2[nLinACol],TRBQRY->R_E_C_N_O_)

				TRBQRY->(DbSkip())
			Enddo

		else
			alert("Não foi encontrado informações para este periodo!")
			return
		endif	
		
	for i:=1 to len(aColsCT2)
		//AINS(aColsCT2[i], 1) 
		AFILL( aColsCT2[i] , .F., 1, 1)
	next

//+--------------------------------------------------------------------+
//| Monta tela para seleção dos arquivos contidos no diretório |
//+--------------------------------------------------------------------+
//145,0 To 445,628
DEFINE MSDIALOG oDlgx TITLE cTitulo STYLE DS_MODALFRAME From 0,0 To 645,1030 PIXEL
//OF oMainWnd PIXEL
oDlgx:lEscClose := .F.
//125,300
@ 05,15 TO 320,500 LABEL "Selecione o(s) lançamento(s) contábil(eis):" OF oDlgx PIXEL

@ 15,20 CHECKBOX oChkQual VAR lQual PROMPT "Inverte Seleção" SIZE 50, 10;
OF oDlgx PIXEL;
ON CLICK (AEval(aColsCT2, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}),;
oQual:Refresh(.F.))
//273,090 "Data Lcto","Numero Lote","Sub Lote","Numero Doc","Numero Linha","Moeda Lancto","Tipo Lcto","Cta Debito","Cta Credito","Dig Cont Crd","Valor","Hist Lanc","C Custo Deb","C Custo Crd","Item Debito","Item Credito","Cl Vlr Deb","Cl Vlr Cred","Empresa Orig","Filial Orig","Tipo do Sld","Seq CTK","Lcto Manual?","Origem","Rotina","Aglutinado","Lanc Padrao","Seq Historic","Seq Auxiliar","Crit. Conver","Data Rastrea","Data Conf","Tps Saldos"
@ 30,20 LISTBOX oQual VAR cVarQ Fields HEADER "","Data Lcto","Numero Lote","Sub Lote","Numero Doc","Numero Linha","Moeda Lancto","Tipo Lcto","Cta Debito","Item Conta D","C Custo Deb","Cta Credito","Item Conta C","C Custo Cred","Dig Cont Deb","Dig Cont Crd","Valor","Hist Lanc","Cod Cl Val D","Cod Cl Val C","Empresa Orig","Filial Orig","Seq CTK","Lcto Manual?","Tipo do Sld","Origem" SIZE;
473,270 ON DBLCLICK (aColsCT2:=Troca(oQual:nAt,aColsCT2),oQual:Refresh()) NoScroll OF oDlgx PIXEL
// "","Data Lcto","Numero Lote","Sub Lote","Numero Doc","Numero Linha","Moeda Lancto","Tipo Lcto","Cta Debito","Cta Credito","Dig Cont Crd","Valor","Hist Lanc","C Custo Deb","C Custo Crd","Item Debito","Item Credito","Cl Vlr Deb","Cl Vlr Cred","Empresa Orig","Filial Orig","Tipo do Sld","Seq CTK","Lcto Manual?","Origem"
oQual:SetArray(aColsCT2)

oQual:bLine := { || {If(aColsCT2[oQual:nAt,1],oOk,oNo),;
STOD(aColsCT2[oQual:nAt,2]),aColsCT2[oQual:nAt,3],aColsCT2[oQual:nAt,4],aColsCT2[oQual:nAt,5],aColsCT2[oQual:nAt,6],aColsCT2[oQual:nAt,7],aColsCT2[oQual:nAt,8],;
aColsCT2[oQual:nAt,9],aColsCT2[oQual:nAt,10],aColsCT2[oQual:nAt,11],aColsCT2[oQual:nAt,12],aColsCT2[oQual:nAt,13],aColsCT2[oQual:nAt,14],aColsCT2[oQual:nAt,15],aColsCT2[oQual:nAt,16],alltrim(TRANSFORM(aColsCT2[oQual:nAt,17],"@E 999,999,999.99")),aColsCT2[oQual:nAt,18],aColsCT2[oQual:nAt,19],aColsCT2[oQual:nAt,20],;
aColsCT2[oQual:nAt,21],aColsCT2[oQual:nAt,22],aColsCT2[oQual:nAt,23],aColsCT2[oQual:nAt,24],aColsCT2[oQual:nAt,25],aColsCT2[oQual:nAt,26];
}}
//134,240
DEFINE SBUTTON FROM 305,440 TYPE 1 ACTION IIF(MarcaOk(aColsCT2),(GravaSCT2(Arraytrue(aColsCT2)),.T.),.F.) ENABLE OF oDlgx
//134,270
DEFINE SBUTTON FROM 305,470 TYPE 2 ACTION (oDlgx:End()) ENABLE OF oDlgx

ACTIVATE MSDIALOG oDlgx CENTERED

RETURN              

/*
Funcao      : Troca  
Parametros  : nIt,aArray
Retorno     : aArray
Objetivos   : Função para trocar a Lógica do primeiro campo, (.T. / .F.), mudando assim a imagem do check
Autor       : Matheus Massarotto
Data/Hora   : 17/04/2012
*/
*-------------------------------*
Static Function Troca(nIt,aArray)
*-------------------------------*
aArray[nIt,1] := !aArray[nIt,1]
Return aArray     

/*
Funcao      : MarcaOk()  
Parametros  : aArray
Retorno     : lRet
Objetivos   : Verifica Se existe algum CheckBox, marcado;Se não tiver nenhum marcado exibe uma msg!
Autor       : Matheus Massarotto
Data/Hora   : 17/04/2012
*/
*-----------------------------*
Static Function MarcaOk(aArray)
*-----------------------------*
Local lRet:=.F.
Local nx:=0

// Checa marcações efetuadas
For nx:=1 To Len(aArray)
	If aArray[nx,1]
		lRet:=.T.
	EndIf
Next nx

// Checa se existe algum item marcado na confirmação
If !lRet
	HELP("SELFILE",1,"HELP","Atenção","Não existem itens marcados",1,0)
EndIf
Return lRet  

/*
Funcao      : Arraytrue()  
Parametros  : aColsCT2
Retorno     : aArray
Objetivos   : Função gera e retorna um array, só com os itens marcados.
Autor       : Matheus Massarotto
Data/Hora   : 17/04/2012
*/
*--------------------------------*
Static Function Arraytrue(aColsCT2)
*--------------------------------*

Private aArray:={}

For i:=1 to len(aColsCT2)
	If aColsCT2[i][1]
		AADD(aArray,aColsCT2[i])
	Endif 
Next

return aArray

/*
Funcao      : GravaSCT2()  
Parametros  : aColsCT2T - array só com os itens marcados
Retorno     : nil
Objetivos   : executar o MSExecAuto do FinA100
Autor       : Matheus Massarotto
Data/Hora   : 17/04/2012
*/
*--------------------------------*
Static Function GravaSCT2(aColsCT2T)
*--------------------------------*
Local aFINA100:={}
Local lErro:=.F.
Local aGravado:={}
Local aErros:={}


for i:=1 to len(aColsCT2T)
//CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA,CT2_MOEDLC,CT2_DC,CT2_DEBITO,CT2_ITEMD,CT2_CCD,CT2_CREDIT,CT2_ITEMC,CT2_CCC,CT2_DCD,CT2_DCC,CT2_VALOR,CT2_HIST,CT2_CLVLDB,CT2_CLVLCR,CT2_EMPORI,CT2_FILORI,CT2_SEQUEN,CT2_MANUAL,CT2_TPSALD,CT2_ORIGEM,CT2_AGLUT,CT2_ROTINA,CT2_SEQHIS,CT2_SEQLAN,CT2_LP,CT2_CRCONV,CT2_DTCV3,CT2_DTCONF,CT2_MLTSLD

	RecLock("CT2",.T.)
		CT2->CT2_FILIAL	:=xFilial("CT2")
		CT2->CT2_DATA	:=STOD(aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_DATA"} )])
		CT2->CT2_LOTE	:=ALLTRIM(aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_FILORI"} )])+SUBSTR(aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_LOTE"} )],3,4)
		CT2->CT2_SBLOTE :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_SBLOTE"} )]
		CT2->CT2_DOC    :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_DOC"} )]
		CT2->CT2_LINHA  :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_LINHA"} )]
		CT2->CT2_MOEDLC :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_MOEDLC"} )]
		CT2->CT2_DC     :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_DC"} )]
		CT2->CT2_DEBITO :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_DEBITO"} )]
		CT2->CT2_ITEMD  :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_ITEMD"} )]
		CT2->CT2_CCD    :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_CCD"} )]
		CT2->CT2_CREDIT :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_CREDIT"} )]
		CT2->CT2_ITEMC	:=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_ITEMC"} )]
		CT2->CT2_CCC	:=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_CCC"} )]
		CT2->CT2_DCD	:=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_DCD"} )]
		CT2->CT2_DCC	:=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_DCC"} )]
		CT2->CT2_VALOR	:=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_VALOR"} )]
		CT2->CT2_HIST	:=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_HIST"} )]
		CT2->CT2_CLVLDB	:=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_CLVLDB"} )]
		CT2->CT2_CLVLCR	:=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_CLVLCR"} )]
		CT2->CT2_EMPORI :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_EMPORI"} )]
		CT2->CT2_FILORI :=xFilial("CT2")//22
		CT2->CT2_SEQUEN :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_SEQUEN"} )]
		CT2->CT2_MANUAL :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_MANUAL"} )]
		CT2->CT2_TPSALD :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_TPSALD"} )]
		CT2->CT2_ORIGEM :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_ORIGEM"} )]
		CT2->CT2_AGLUT  :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_AGLUT"} )]
		CT2->CT2_ROTINA :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_ROTINA"} )]
		CT2->CT2_SEQHIS :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_SEQHIS"} )]
		CT2->CT2_SEQLAN :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_SEQLAN"} )]
		CT2->CT2_LP     :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_LP"} )]
		CT2->CT2_CRCONV :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_CRCONV"} )]
		CT2->CT2_DTCV3  :=STOD(aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_DTCV3"} )])
		CT2->CT2_DTCONF :=STOD(aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_DTCONF"} )])
		CT2->CT2_MLTSLD :=aColsCT2T[i][aScan( aCabec, { |x| alltrim(x) == "CT2_MLTSLD"} )]
		CT2->CT2_P_ROTI	:="GTCORP10"
	MsUnlock()
			    
	//Atualiza o campo data duplicada para marcar que o registro já foi duplicado.
		DbSelectArea("CT2")
		CT2->(DbGoto(aColsCT2T[i][36]))

		RecLock("CT2",.F.)
			CT2->CT2_P_DTDUP:=date()
		MsUnlock()

	
next    


MsgInfo("Importação realizada com sucesso!")
oDlgx:end()

Return
