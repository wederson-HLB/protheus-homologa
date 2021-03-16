#Include "Protheus.ch"

/*
Funcao      : GTCORP09
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Importação(duplicação) dos movimentos bancários da filial 06 para a 05 e da filial 02 e 03 para a 01
Autor       : Matheus Massarotto
Data/Hora   : 12/04/2012    14:26
Revisão		:
Data/Hora   : 
Módulo      : Financeiro
*/
*---------------------*
User Function GTCORP09
*---------------------*
Local cTitulo := "Movimento Bancário"
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
Private aColsE5:={}
Private cTitQry:=""
Private cTitArr:=""
Private cTitItem:=""
Private nCont:=1
Private nLinACol:=0
Private cFilial:=""

Private cPerg:="GTCORP09"


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
	DbSeek("SE5")
	
	AADD(aCabec,"")

	While !Eof().And.(SX3->X3_ARQUIVO=="SE5")
		//if X3USO(SX3->X3_USADO)	    
//"E5_DATA","E5_DTDIGIT","E5_DTDISPO","E5_TIPO","E5_MOEDA","E5_VALOR",E5_NATUREZ","E5_BANCO","E5_AGENCIA","E5_CONTA","E5_NUMCHEQ","E5_BENEF","E5_HISTOR","E5_DOCUMEN","E5_VENCTO","E5_RECPAG","E5_TIPODOC","E5_VLMOED2,"E5_LA","E5_SITUACA","E5_LOTE","E5_PREFIXO","E5_NUMERO","E5_PARCELA","E5_CLIFOR","E5_LOJA","E5_MOTBX","E5_RATEIO","E5_DTDISPO","E5_SEQ","E5_ARQCNAB","E5_FILORI","E5_VLCORRE","E5_VLDESCO","E5_VLJUROS","E5_VLMULTA","E5_CNABOC","E5_MODSPB","E5_CODORCA","E5_SITCOB","E5_CLIENTE","E5_FORNECE"
//"E5_DATA,E5_DTDIGIT,E5_DTDISPO,E5_TIPO,E5_MOEDA,E5_VALOR,E5_NATUREZ,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_NUMCHEQ,E5_BENEF,E5_HISTOR,E5_DOCUMEN,E5_VENCTO,E5_RECPAG,E5_TIPODOC,E5_VLMOED2,E5_LA,E5_SITUACA,E5_LOTE,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_CLIFOR,E5_LOJA,E5_MOTBX,E5_RATEIO,E5_DTDISPO,E5_SEQ,E5_ARQCNAB,E5_FILORI,E5_VLCORRE,E5_VLDESCO,E5_VLJUROS,E5_VLMULTA,E5_CNABOC,E5_MODSPB,E5_CODORCA,E5_SITCOB,E5_CLIENTE,E5_FORNECE                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
		if alltrim(SX3->X3_CAMPO)=="E5_DATA" .OR. alltrim(SX3->X3_CAMPO)=="E5_DTDIGIT" .OR. alltrim(SX3->X3_CAMPO)=="E5_DTDISPO" .OR. alltrim(SX3->X3_CAMPO)=="E5_TIPO" .OR. alltrim(SX3->X3_CAMPO)=="E5_MOEDA" .OR. alltrim(SX3->X3_CAMPO)=="E5_VALOR" .OR. alltrim(SX3->X3_CAMPO)=="E5_NATUREZ" .OR. alltrim(SX3->X3_CAMPO)=="E5_BANCO" .OR. alltrim(SX3->X3_CAMPO)=="E5_AGENCIA" .OR. alltrim(SX3->X3_CAMPO)=="E5_CONTA" .OR. alltrim(SX3->X3_CAMPO)=="E5_NUMCHEQ" .OR. alltrim(SX3->X3_CAMPO)=="E5_BENEF" .OR. alltrim(SX3->X3_CAMPO)=="E5_HISTOR" .OR. alltrim(SX3->X3_CAMPO)=="E5_DOCUMEN" .OR. alltrim(SX3->X3_CAMPO)=="E5_RECPAG" .OR. alltrim(SX3->X3_CAMPO)=="E5_TIPODOC" .OR. alltrim(SX3->X3_CAMPO)=="E5_VLMOED2" .OR. alltrim(SX3->X3_CAMPO)=="E5_LA" .OR. alltrim(SX3->X3_CAMPO)=="E5_SITUACA" .OR. alltrim(SX3->X3_CAMPO)=="E5_LOTE" .OR. alltrim(SX3->X3_CAMPO)=="E5_PREFIXO" .OR. alltrim(SX3->X3_CAMPO)=="E5_NUMERO" .OR. alltrim(SX3->X3_CAMPO)=="E5_PARCELA" .OR. alltrim(SX3->X3_CAMPO)=="E5_CLIFOR" .OR. alltrim(SX3->X3_CAMPO)=="E5_LOJA" .OR. alltrim(SX3->X3_CAMPO)=="E5_MOTBX" .OR. alltrim(SX3->X3_CAMPO)=="E5_RATEIO" .OR. alltrim(SX3->X3_CAMPO)=="E5_SEQ" .OR. alltrim(SX3->X3_CAMPO)=="E5_ARQCNAB" .OR. alltrim(SX3->X3_CAMPO)=="E5_FILORI" .OR. alltrim(SX3->X3_CAMPO)=="E5_VLCORRE" .OR. alltrim(SX3->X3_CAMPO)=="E5_VLDESCO" .OR. alltrim(SX3->X3_CAMPO)=="E5_VLJUROS" .OR. alltrim(SX3->X3_CAMPO)=="E5_VLMULTA" .OR. alltrim(SX3->X3_CAMPO)=="E5_CNABOC" .OR. alltrim(SX3->X3_CAMPO)=="E5_MODSPB" .OR. alltrim(SX3->X3_CAMPO)=="E5_CODORCA" .OR. alltrim(SX3->X3_CAMPO)=="E5_SITCOB" .OR. alltrim(SX3->X3_CAMPO)=="E5_CLIENTE" .OR. alltrim(SX3->X3_CAMPO)=="E5_FORNECE" //"E5_DATA,E5_DTDIGIT,E5_DTDISPO,E5_TIPO,E5_MOEDA,E5_VALOR,E5_NATUREZ,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_NUMCHEQ,E5_BENEF,E5_HISTOR,E5_DOCUMEN,E5_VENCTO,E5_RECPAG"
			nCont++
			AADD(aCabec,ALLTRIM(SX3->X3_TITULO))
			
			cTitQry+=ALLTRIM(SX3->X3_CAMPO)+","
			cTitArr+="TRBQRY->"+ALLTRIM(SX3->X3_CAMPO)+","
			
			cTitItem+="aColsE5[oQual:nAt,"+cvaltochar(nCont)+"],"
	    endif
	SX3->(DbSkip())
    enddo
    
    cTitQry:=SUBSTR(cTitQry,1,len(cTitQry)-1)+",R_E_C_N_O_"
    cTitArr:=SUBSTR(cTitArr,1,len(cTitArr)-1)
    cTitItem:=SUBSTR(cTitItem,1,len(cTitItem)-1)

	cQry:=" SELECT "+cTitQry+" FROM "+RETSQLNAME("SE5")
	cQry+=" WHERE D_E_L_E_T_='' AND E5_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND E5_P_DTDUP='' AND E5_FILIAL IN ("+cFilQry+")"

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
				aAuxE5:=STRTOKARR(cTitArr,",")
				AADD(aColsE5,{})
				nLinACol++
	
				AADD(aColsE5[nLinACol],"")							
				for i:=1 to len(aAuxE5) 
					AADD(aColsE5[nLinACol],&(aAuxE5[i]))
				next
				AADD(aColsE5[nLinACol],TRBQRY->R_E_C_N_O_)

				TRBQRY->(DbSkip())
			Enddo

		else
			alert("Não foi encontrado informações para este periodo!")
			return
		endif	
		
	for i:=1 to len(aColsE5)
		//AINS(aColsE5[i], 1) 
		AFILL( aColsE5[i] , .F., 1, 1)
	next

//+--------------------------------------------------------------------+
//| Monta tela para seleção dos arquivos contidos no diretório |
//+--------------------------------------------------------------------+
//145,0 To 445,628
DEFINE MSDIALOG oDlgx TITLE cTitulo STYLE DS_MODALFRAME From 0,0 To 645,1030 PIXEL
//OF oMainWnd PIXEL
oDlgx:lEscClose := .F.
//125,300
@ 05,15 TO 320,500 LABEL "Selecione o(s) movimento(s) bancário(s):" OF oDlgx PIXEL

@ 15,20 CHECKBOX oChkQual VAR lQual PROMPT "Inverte Seleção" SIZE 50, 10;
OF oDlgx PIXEL;
ON CLICK (AEval(aColsE5, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}),;
oQual:Refresh(.F.))
//273,090
@ 30,20 LISTBOX oQual VAR cVarQ Fields HEADER "","DT Movimen","Data Digit.","Data Dispon","Tipo Titulo","Numerario","Vlr.Movim.","Natureza","Banco","Agencia","Conta Banco","Num Cheque","Beneficiario","Historico","Documento","Rec/Pag" SIZE;
473,270 ON DBLCLICK (aColsE5:=Troca(oQual:nAt,aColsE5),oQual:Refresh()) NoScroll OF oDlgx PIXEL

oQual:SetArray(aColsE5)

oQual:bLine := { || {If(aColsE5[oQual:nAt,1],oOk,oNo),;
STOD(aColsE5[oQual:nAt,2]),STOD(aColsE5[oQual:nAt,3]),STOD(aColsE5[oQual:nAt,4]),aColsE5[oQual:nAt,5],aColsE5[oQual:nAt,6],alltrim(TRANSFORM(aColsE5[oQual:nAt,7],"@E 999,999,999.99")),aColsE5[oQual:nAt,8],;
aColsE5[oQual:nAt,9],aColsE5[oQual:nAt,10],aColsE5[oQual:nAt,11],aColsE5[oQual:nAt,12],aColsE5[oQual:nAt,13],aColsE5[oQual:nAt,14],aColsE5[oQual:nAt,15],aColsE5[oQual:nAt,16];
}}
//134,240
DEFINE SBUTTON FROM 305,440 TYPE 1 ACTION IIF(MarcaOk(aColsE5),(GravaSE5(Arraytrue(aColsE5)),.T.),.F.) ENABLE OF oDlgx
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
Data/Hora   : 12/04/2012
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
Data/Hora   : 12/04/2012
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
Parametros  : aColsE5
Retorno     : aArray
Objetivos   : Função gera e retorna um array, só com os itens marcados.
Autor       : Matheus Massarotto
Data/Hora   : 12/04/2012
*/
*--------------------------------*
Static Function Arraytrue(aColsE5)
*--------------------------------*

Private aArray:={}

For i:=1 to len(aColsE5)
	If aColsE5[i][1]
		AADD(aArray,aColsE5[i])
	Endif 
Next

return aArray

/*
Funcao      : GravaSE5()  
Parametros  : aColsE5T - array só com os itens marcados
Retorno     : nil
Objetivos   : executar o MSExecAuto do FinA100
Autor       : Matheus Massarotto
Data/Hora   : 12/04/2012
*/
*--------------------------------*
Static Function GravaSE5(aColsE5T)
*--------------------------------*
Local aFINA100:={}
Local lErro:=.F.
Local aGravado:={}
Local aErros:={}

	//++++++##++++++Tratamento para não exibir lançamentos contábeis++++++##++++++	
	Private cPre02
	Private cPre04
		
	DbSelectArea("SX1")
	DbSetOrder(1)
	if DbSeek("AFI100    02")
		cPre02:=SX1->X1_PRESEL
		RecLock("SX1",.F.)
			SX1->X1_PRESEL:=2
		MsUnlock()
	endif
	if DbSeek("AFI100    04")
		cPre04:=SX1->X1_PRESEL
		RecLock("SX1",.F.)
			SX1->X1_PRESEL:=2
		MsUnlock()
	endif
	//++++++##++++++Tratamento para não exibir lançamentos contábeis++++++##++++++	


for i:=1 to len(aColsE5T)

		aFINA100 :=    {;    
		{"E5_FILIAL"	,xFilial("SE5")					   				,Nil},;
		{"E5_DATA"		,STOD(aColsE5T[i][2])			   				,Nil},;
		{"E5_DTDIGIT"	,STOD(aColsE5T[i][3])  			   				,Nil},;
		{"E5_DTDISPO"	,STOD(aColsE5T[i][4])  							,Nil},;
		{"E5_TIPO"		,aColsE5T[i][5]                    				,Nil},;
		{"E5_MOEDA"		,aColsE5T[i][6]                    				,Nil},;		
  		{"E5_VALOR"     ,IIF(empty(aColsE5T[i][7]),0,aColsE5T[i][7])	,Nil},;
    	{"E5_NATUREZ"   ,aColsE5T[i][8]                    				,Nil},;
     	{"E5_BANCO"     ,aColsE5T[i][9]                     			,Nil},;
      	{"E5_AGENCIA"   ,aColsE5T[i][10]                    			,Nil},;
       	{"E5_CONTA"     ,aColsE5T[i][11]                    			,Nil},;
		{"E5_NUMCHEQ"	,aColsE5T[i][12]                    			,Nil},;                            
  		{"E5_BENEF"     ,aColsE5T[i][13]    			   				,Nil},;
    	{"E5_HISTOR"    ,aColsE5T[i][14]        						,Nil},;
		{"E5_DOCUMEN"	,aColsE5T[i][15]                    			,Nil},;
		{"E5_RECPAG"	,aColsE5T[i][16]                    			,Nil},;
		{"E5_TIPODOC"	,aColsE5T[i][17]                    			,Nil},;
		{"E5_VLMOED2"	,IIF(empty(aColsE5T[i][18]),0,aColsE5T[i][18])	,Nil},;
		{"E5_LA"		,aColsE5T[i][19]                    			,Nil},;
		{"E5_SITUACA"	,aColsE5T[i][20]                    			,Nil},;
		{"E5_LOTE"		,aColsE5T[i][21]                    			,Nil},;
		{"E5_PREFIXO"	,aColsE5T[i][22]                    			,Nil},;
		{"E5_NUMERO"	,aColsE5T[i][23]                    			,Nil},;
		{"E5_PARCELA"	,aColsE5T[i][24]                    			,Nil},;
		{"E5_CLIFOR"	,aColsE5T[i][25]                    			,Nil},;
		{"E5_LOJA"		,aColsE5T[i][26]                    			,Nil},;
		{"E5_MOTBX"		,aColsE5T[i][27]                    			,Nil},;
		{"E5_RATEIO"	,aColsE5T[i][28]                    			,Nil},;
		{"E5_SEQ"		,aColsE5T[i][29]                    			,Nil},;
		{"E5_ARQCNAB"	,aColsE5T[i][30]                    			,Nil},;
		{"E5_VLCORRE"	,IIF(empty(aColsE5T[i][31]),0,aColsE5T[i][31])	,Nil},;
		{"E5_VLDESCO"	,IIF(empty(aColsE5T[i][32]),0,aColsE5T[i][32])  ,Nil},;
		{"E5_VLJUROS"	,IIF(empty(aColsE5T[i][33]),0,aColsE5T[i][33])  ,Nil},;
		{"E5_VLMULTA"	,IIF(empty(aColsE5T[i][34]),0,aColsE5T[i][34])  ,Nil},;
		{"E5_CNABOC"	,aColsE5T[i][35]                    			,Nil},;
		{"E5_MODSPB"	,aColsE5T[i][36]                    			,Nil},;
		{"E5_CODORCA"	,aColsE5T[i][37]                    			,Nil},;
		{"E5_SITCOB"	,aColsE5T[i][38]                    			,Nil},;
		{"E5_CLIENTE"	,aColsE5T[i][39]                    			,Nil},;
		{"E5_FORNECE"	,aColsE5T[i][40]                    			,Nil},;
		{"E5_P_ROTIN"	,"GTCORP09"                    					,Nil};		
		}
//		{"E5_VENCTO"	,STOD(aColsE5T[i][16])             				,Nil},;
		nRecPag:= IIF(ALLTRIM(aColsE5T[i][16])=="R",4,3)

	Private lMsErroAuto:= .f.
	Private lMSHelpAuto := .F.
	Private lAutoErrNoFile := .T.
	
	        MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,nRecPag)
	
			If lMsErroAuto         
				ROLLBACKSXE()
			    //MOSTRAERRO() // tela de erro do msexecauto mostra campo com o erro
		
				aAutoErro := GETAUTOGRLOG()
			    cErroCon:=XLOG(aAutoErro) 
				
			    AADD(aErros,{"Erro",STRTRAN(cErroCon,CHR(13)+CHR(10)),STOD(aColsE5T[i][2]),STOD(aColsE5T[i][3]),STOD(aColsE5T[i][4]),aColsE5T[i][5],aColsE5T[i][6],IIF(empty(aColsE5T[i][7]),0,aColsE5T[i][7]),aColsE5T[i][8],aColsE5T[i][9],aColsE5T[i][10],aColsE5T[i][11],aColsE5T[i][12],aColsE5T[i][13],aColsE5T[i][14],aColsE5T[i][15],aColsE5T[i][16]})
		
			    lErro:=.T.
		
			    DisarmTransaction()
			Else
				ConfirmSx8()
				AADD(aGravado,{"Ok","Inserido",STOD(aColsE5T[i][2]),STOD(aColsE5T[i][3]),STOD(aColsE5T[i][4]),aColsE5T[i][5],aColsE5T[i][6],IIF(empty(aColsE5T[i][7]),0,aColsE5T[i][7]),aColsE5T[i][8],aColsE5T[i][9],aColsE5T[i][10],aColsE5T[i][11],aColsE5T[i][12],aColsE5T[i][13],aColsE5T[i][14],aColsE5T[i][15],aColsE5T[i][16]})
				    
					//Atualiza o campo data duplicada para marcar que o registro já foi duplicado.
					DbSelectArea("SE5")
					SE5->(DbGoto(aColsE5T[i][41]))
					RecLock("SE5",.F.)
						SE5->E5_P_DTDUP:=date()
					MsUnlock()
			EndIF 
	
next    

	//++++++##++++++Tratamento para não exibir lançamentos contábeis++++++##++++++			
	DbSelectArea("SX1")
	DbSetOrder(1)
	if DbSeek("AFI100    02")
		RecLock("SX1",.F.)
			SX1->X1_PRESEL:=cPre02
		MsUnlock()
	endif
	if DbSeek("AFI100    04")
		RecLock("SX1",.F.)
			SX1->X1_PRESEL:=cPre04
		MsUnlock()
	endif
	//++++++##++++++Tratamento para não exibir lançamentos contábeis++++++##++++++	

If lErro
	
	Situacao(aErros,aGravado)
	
Else
	MsgInfo("Importação realizada com sucesso!")
	oDlgx:end()
EndIf

Return


/*
Funcao      : XLOG()  
Parametros  : aAutoErro
Retorno     : cRet
Objetivos   : Busca o erro gerado no msexecauto
Autor       : Matheus Massarotto
Data/Hora   : 12/04/2012
*/
*-----------------------------*
Static Function XLOG(aAutoErro)
*-----------------------------*
    LOCAL cRet := ""
    LOCAL nX := 1
 	FOR nX := 1 to Len(aAutoErro)
 		If nX==1
 			cRet+=substr(aAutoErro[nX],at(CHR(13)+CHR(10),aAutoErro[nX]),len(aAutoErro[nX]))+"; "
    	else
    		If at("Invalido",aAutoErro[nX])>0
    			cRet += alltrim(aAutoErro[nX])+"; "
            EndIf
       		If at("Erro",aAutoErro[nX])>0
    			cRet += alltrim(aAutoErro[nX])+"; "
            EndIf
        EndIf
    NEXT nX
RETURN cRet


/*
Funcao      : Situacao()  
Parametros  : aErros,aGravado
Retorno     : Nil
Objetivos   : Gera um Dialog com ListBox, com arquivos que deram ERRO, e OK
Autor       : Matheus Massarotto
Data/Hora   : 12/04/2012
*/
*---------------------------------------*
Static Function Situacao(aErros,aGravado)
*---------------------------------------*
Private _oDlg,oListBox
Private aListBox:={}

DEFINE MSDIALOG _oDlg TITLE "Problemas" STYLE DS_MODALFRAME From 0,0 To 645,1030 PIXEL

_oDlg:lEscClose := .F.

@ 05,15 TO 320,500 LABEL "Problema na inserção do(s) movimento(s) bancário(s):" OF _oDlg PIXEL

@ 30,20 LISTBOX oListBox VAR cVarQ Fields HEADER "Status","Descrição","DT Movimen","Data Digit.","Data Dispon","Tipo Titulo","Numerario","Vlr.Movim.","Natureza","Banco","Agencia","Conta Banco","Num Cheque","Beneficiario","Historico","Documento","Vencimento","Rec/Pag" SIZE;
473,270 OF _oDlg PIXEL


			For i:=1 to len(aErros)
				Aadd(aListBox,{aErros[i][1],aErros[i][2],aErros[i][3],aErros[i][4],aErros[i][5],aErros[i][6],aErros[i][7],aErros[i][8],aErros[i][9],aErros[i][10],aErros[i][11],aErros[i][12],aErros[i][13],aErros[i][14],aErros[i][15],aErros[i][16],aErros[i][17]})
			Next
            
			For i:=1 to len(aGravado)
				Aadd(aListBox,{aGravado[i][1],aGravado[i][2],aGravado[i][3],aGravado[i][4],aGravado[i][5],aGravado[i][6],aGravado[i][7],aGravado[i][8],aGravado[i][9],aGravado[i][10],aGravado[i][11],aGravado[i][12],aGravado[i][13],aGravado[i][14],aGravado[i][15],aGravado[i][16],aGravado[i][17]})
			Next

oListBox:SetArray(aListBox)

oListBox:bLine := { || {aListBox[oListBox:nAt,1],aListBox[oListBox:nAt,2],;
aListBox[oListBox:nAt,3],aListBox[oListBox:nAt,4],aListBox[oListBox:nAt,5],aListBox[oListBox:nAt,6],aListBox[oListBox:nAt,7],aListBox[oListBox:nAt,8],aListBox[oListBox:nAt,9],;
aListBox[oListBox:nAt,10],aListBox[oListBox:nAt,11],aListBox[oListBox:nAt,12],aListBox[oListBox:nAt,13],aListBox[oListBox:nAt,14],aListBox[oListBox:nAt,15],aListBox[oListBox:nAt,16],aListBox[oListBox:nAt,17];
}}

DEFINE SBUTTON FROM 305,470 TYPE 2 ACTION (_oDlg:end(),oDlgx:end()) ENABLE OF _oDlg

ACTIVATE MSDIALOG _oDlg CENTERED

Return
