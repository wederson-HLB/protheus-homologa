#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"  
#INCLUDE "topconn.ch"
#INCLUDE "FWPrintSetup.ch" 
#INCLUDE "RPTDEF.CH"
#Include "tbiconn.ch"

#DEFINE DS_MODALFRAME   128  

/*
Funcao      : ZJFIN004
Objetivos   : Impressao de Boleto Bancario do Banco Bank of America Merrill Lynch com Codigo de Barras,
			  Linha Digitavel e Nosso Numero.
Autor       : Anderson Arrais
Data		: 09/05/2018
Módulo      : Financeiro.
*/ 
*-------------------------------------------------------------*
USER FUNCTION ZJFIN004(F2_SERIE,F2_DOC,cVer1,dEmissao,lSelAuto)
*--------------------------------------------------------------*
LOCAL aCampos      	:= {{"E1_NOMCLI","Cliente","@!"},;    		 //[01] - Codigo do cliente.
						{"E1_PREFIXO","Prefixo","@!"},;          //[02] - Prefixo da nota. 
						{"E1_NUM","Titulo","@!"},;               //[03] - Numero da nota. 
						{"E1_PARCELA","Parcela","@!"},;          //[04] - Parcela da nota.
						{"E1_VALOR","Valor","@E 9,999,999.99"},; //[05] - Valor da nota.
						{"E1_VENCREA","Vencimento"}}             //[06] - Data de vencimento.
LOCAL aPergs 		:= {}
LOCAL lExec         := .T.
LOCAL nOpc         	:= 0
LOCAL aDesc        	:= {"Este programa imprime os boletos de","cobranca bancaria de acordo com","os parametros informados"} 

PRIVATE Exec       	:= .F.
PRIVATE cIndexName 	:= ''
PRIVATE cIndexKey  	:= ''
PRIVATE cFilter    	:= ''    
PRIVATE cSerie    	:= F2_SERIE    
PRIVATE cDocF2    	:= F2_DOC    
PRIVATE dEmiss    	:= dEmissao    

DEFAULT lSelAuto	:=.F.
DEFAULT cVer1		:='S'

lEnd     := .F.
dbSelectArea("SE1")

If !lSelAuto
	cPerg     :="ZJFIN004"
	
	Aadd(aPergs,{"De Prefixo","","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"Ate Prefixo","","","mv_ch2","C",3,0,0,"G","","MV_PAR02","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"De Numero","","","mv_ch3","C",9,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"Ate Numero","","","mv_ch4","C",9,0,0,"G","","MV_PAR04","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"De Emissao","","","mv_ch5","D",8,0,0,"G","","MV_PAR05","","","","01/01/80","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"Ate Emissao","","","mv_ch6","D",8,0,0,"G","","MV_PAR06","","","","31/12/20","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	AjustaSx1("ZJFIN004",aPergs)
	
	SET DATE FORMAT "dd/mm/yyyy"
	
	If !Pergunte (cPerg,.T.)
		Return Nil
	EndIF
EndIf
	
If Select('SQL') > 0
	SQL->(DbCloseArea())
EndIf

If !lSelAuto
	cQry:=" SELECT E1_PORTADO,E1_PREFIXO,E1_NUM,E1_TIPO,E1_EMISSAO,R_E_C_N_O_  as 'RECNUM' 
	cQry+=" FROM "+RETSQLNAME("SE1")
	cQry+=" WHERE D_E_L_E_T_=''
	cQry+=" AND E1_FILIAL ='"+xFilial("SE1")+"' 
	cQry+=" AND E1_SALDO > 0
	cQry+=" AND E1_PREFIXO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'
	cQry+=" AND E1_NUM     BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	cQry+=" AND E1_EMISSAO BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"'
	cQry+=" AND E1_TIPO IN ('NF','BOL')
	cQry+=" ORDER BY E1_PORTADO,E1_PREFIXO,E1_NUM,E1_TIPO,E1_EMISSAO
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "SQL" ,.T.,.F.)
Else
	cQry:=" SELECT E1_PORTADO,E1_PREFIXO,E1_NUM,E1_TIPO,E1_EMISSAO,R_E_C_N_O_  as 'RECNUM' 
	cQry+=" FROM "+RETSQLNAME("SE1")
	cQry+=" WHERE D_E_L_E_T_=''
	cQry+=" AND E1_FILIAL ='"+xFilial("SE1")+"' 
	cQry+=" AND E1_SALDO > 0
	cQry+=" AND E1_PREFIXO = '"+cSerie+"'
	cQry+=" AND E1_NUM = '"+cDocF2+"'
	cQry+=" AND E1_EMISSAO = '"+DTOS(dEmiss)+"'
	cQry+=" AND E1_TIPO IN ('NF','BOL')
	cQry+=" ORDER BY E1_PORTADO,E1_PREFIXO,E1_NUM,E1_TIPO,E1_EMISSAO
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "SQL" ,.T.,.F.)
EndIf

SQL->(dbGoTop())

If SQL->(EOF()) .or. SQL->(BOF())
	lExec := .F.
	alert("Não há dados com esses parâmetros!")
EndIf

If lExec
	Processa({|lEnd|MontaRel(cVer1)})
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ MONTAREL()  ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Bank of America Merrill Lyn³±±
±±³           ³ ch com Codigode Barras, Linha Digitavel e Nosso Numero.    ³±±
±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ FINANCEIRO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION MontaRel(cVer1)
LOCAL oPrint
LOCAL n         := 0
LOCAL aBitmap   := "bofa.bmp"
	
LOCAL aDadosEmp := 	{	SM0->M0_NOMECOM,;	                    										//[1]Nome da Empresa																				//[1]Nome da Empresa
						SM0->M0_ENDCOB,; 															    //[2]Endereço																					//[2]Endereço
						AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,;    //[3]Complemento
						"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3),; 			    //[4]CEP
						"PABX/FAX: "+SM0->M0_TEL,; 												     	//[5]Telefones
						"C.N.P.J.: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+;    			//[6]
						Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+;				    		//[6]
						Subs(SM0->M0_CGC,13,2),;											     		//[6]CGC
					    "I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+;            	//[7]
						Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)}	       					    //[7]I.E						
					
LOCAL aDadosTit
LOCAL aDadosBanco
LOCAL aDatSacador

LOCAL aBolText  := {"","",""}

LOCAL aBMP      := aBitMap
LOCAL i         := 1
LOCAL CB_RN_NN  := {}
LOCAL nRec      := 0
LOCAL _nVlrAbat := 0
Local cFileName,cEmail,cSubject,cFile
Local cLocal      	:= GetTempPath()

Private cPortGrv	:= ""
Private cAgeGrv		:= ""
Private cContaGrv	:= ""


If Alltrim(SM0->M0_CODIGO) $ "ZJ"  
	cPortGrv    := "755"
	cAgeGrv     := "1306 "
	cContaGrv   := "10033016"
EndIf

If Empty(cPortGrv) .Or. Empty(cAgeGrv) .Or. Empty(cContaGrv)
	Aviso("Aviso","Portador não Escolhido, Boleto não será impresso.",{"Abandona"},2)
	Return Nil
EndIf

SQL->(dbGoTop())
cFileName := "Boleto_Linkedin_" + AllTrim(  SQL->E1_NUM )

If cVer1== 'N'
	oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T.,,.T.,.F.,,,,,,.F.,0)
Else 
	oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T.,,.T.,.F.,,,,,,.T.,0)
EndIf

oPrint:cPathPDF := cLocal
oPrint:SetPortrait()			// ou SetLandscape()
oPrint:StartPage()	// Inicia uma nova Pagina

ProcRegua(SQL->(RecCount()))
Do While SQL->(!EOF())

	DbSelectArea("SE1")
	SE1->(DbGoTo(SQL->RECNUM))

	//Posiciona o SA6 (Bancos)
	If Empty(SE1->E1_PORTADO) 
		DbSelectArea("SA6")
		DbSetOrder(1)
		IF DbSeek(xFilial("SA6") + cPortGrv + cAgeGrv + cContaGrv)
			RecLock("SE1",.F.)
			SE1->E1_PORTADO := SA6->A6_COD
			SE1->E1_AGEDEP  := SA6->A6_AGENCIA
			SE1->E1_CONTA   := SA6->A6_NUMCON
			MsUnLock()
		EndIf
	EndIf
	
	SQL->(DbSkip())
EndDo

SQL->(dbGoTop())
ProcRegua(SQL->(RecCount()))
WHILE SQL->(!EOF())
	
	DbSelectArea("SE1")
	SE1->(DbGoTo(SQL->RECNUM))
	
	If Empty(SE1->E1_PORTADO)
		SQL->(DBSKIP())
		LOOP
	EndIf
	
	If n > 0  //Alteração para geração de um boleto por arquivo.
		cFileName := "Boleto_Linkedin_" + AllTrim(  SQL->E1_NUM )
		If cVer1== 'N'
			oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T.,,.T.,.F.,,,,,,.F.,0)
		Else 
			oPrint:= FWMSPrinter():New(cFileName,IMP_PDF,.T.,,.T.,.F.,,,,,,.T.,0)
		EndIf
		
		oPrint:cPathPDF := cLocal
		oPrint:SetPortrait()			// ou SetLandscape()
		oPrint:StartPage()	// Inicia uma nova Pagina
			
	EndIf
	
	// Posiciona o SA6 (Bancos)
	dbSelectArea("SA6")
	dbSetOrder(1)
	dbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.)
	// Posiciona na Arq de Parametros CNAB
	dbSelectArea("SEE")
	dbSetOrder(1)
	dbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA)+"003",.T.)
	// Posiciona o SA1 (Cliente)
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
	// Seleciona o SE1 (Contas a Receber)
	dbSelectArea("SE1")
	
	aDadosBanco := {"755",;			 		// [1]Numero do Banco
					"Bank Of America",;	 	// [2]Nome do Banco
					"1306",;		 		// [3]Agencia
					"1003301-",;     		// [4]Conta Corrente
					"6",;	         		// [5]Digito da conta corrente
					"02",;			 		// [6]Codigo da Carteira
					SEE->EE_CODEMP}			// [7]Codigo da empresa.
	IF EMPTY(SA1->A1_ENDCOB)
		aDatSacador := {AllTrim(SA1->A1_NOME),;					   						// [1]Razao Social
						AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA,;					        // [2]Codigo
						AllTrim(SA1->A1_END)+"-"+AllTrim(SA1->A1_BAIRRO),;		        // [3]Endereco
						AllTrim(SA1->A1_MUN),;											// [4]Cidade
						SA1->A1_EST,;													// [5]Estado
						SA1->A1_CEP,;													// [6]CEP
						SA1->A1_CGC}													// [7]CGC
	ELSE
		aDatSacador := {	AllTrim(SA1->A1_NOME),;										// [1]Razao Social
						AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA,;						// [2]Codigo
						AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;       	// [3]Endereco
						AllTrim(SA1->A1_MUNC),;											// [4]Cidade
						SA1->A1_ESTC,;													// [5]Estado
						SA1->A1_CEPC,;													// [6]CEP
						SA1->A1_CGC}													// [7]CGC
	ENDIF
	_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	
	IF EMPTY(SE1->E1_NUMBCO)  
	   	cNroDoc := SUBSTR(NOSSONUM(),3,11)
	   	cCart	:="02"
		nB7		:=2
		nSoma	:=0
		cCartNN:=alltrim(cCart)+alltrim(cNroDoc)
		
		for i:=len(cCartNN) to 1 STEP -1
			
			if nB7==8
				nB7:=2
			endif
			nSoma+= (val(substr(cCartNN,i,1)) * nB7)
		    nB7++
		next
		_RESTO  := INT(nSoma % 11)
	 
		_DIGITO := 11 - _RESTO
		
		if _DIGITO==11 
			_RETDIG :="0"
		elseif _DIGITO==10 
			_RETDIG :="P"
		else
			_RETDIG :=alltrim(STR(_DIGITO))
		endif
		
		cNroDoc := SPACE(12-LEN(ALLTRIM(cNroDoc)+_RETDIG))+ALLTRIM(cNroDoc)+_RETDIG
		
		DbSelectArea("SE1")
		RecLock("SE1",.f.)
			SE1->E1_NUMBCO 	:=	cNroDoc   // Nosso número (Ver fórmula para calculo)
		MsUnlock()

	Else
		cNroDoc 	:= ALLTRIM(SE1->E1_NUMBCO)
	EndIf
	
	CB_RN_NN := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",SUBSTR(aDadosBanco[3],1,4),aDadosBanco[4],aDadosBanco[5],cNroDoc,(E1_SALDO-_nVlrAbat),E1_VENCREA)
	
	aDadosTit := {	AllTrim(E1_NUM)+AllTrim(E1_PARCELA),;	// [1] Numero do Titulo
					E1_EMISSAO,;							// [2] Data da Emissao do Titulo
					Date(),;								// [3] Data da Emissao do Boleto
					E1_VENCREA,;							// [4] Data do Vencimento //JSS - Alterado de E1_VENCTO para E1_VENCREA Chamado 020937
					(E1_SALDO - _nVlrAbat),;				// [5] Valor do Titulo
					CB_RN_NN[3],;							// [6] Nosso Numero (Ver Formula para Calculo)
					E1_PREFIXO,;							// [7] Prefixo da NF
					E1_TIPO,;			                    // [8] Tipo do Titulo
					SE1->E1_DECRESC}					 	// [9] Decrescimo
					
	Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacador,aBolText,CB_RN_NN)
	n := n + 1
	
	oPrint:EndPage() 
	MS_FLUSH()
	
	If File( cLocal+cFileName+".pdf" )
		FErase(cLocal+cFileName+".pdf")
	EndIf
		
	If cVer1 == 'S'
		oPrint:Preview()
	Else 
		oPrint:Print()
   		//Copia arquivo para o servidor
		lCompacta := .T.
		CpyT2S(cLocal+cFileName+".pdf","\FTP\ZJ\ZJFIN003\",lCompacta)
		cDirAnexo :=cLocal+cFileName+".pdf" 
		FErase(cDirAnexo) 
	EndIf
	
	
	SQL->(dbSkip())
	SQL->(INCPROC())
	i := i + 1
ENDDO

SQL->(DbCloseArea())

RETURN nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ IMPRESS()   ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Bank of America Merrill Lyn³±±
±±³           ³ ch com Codigo de Barras, Linha Digitavel e Nosso Numero.   ³±±
±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ FINANCEIRO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION Impress(oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacador,aBolText,CB_RN_NN)
LOCAL oFont8
LOCAL oFont10
LOCAL oFont16
LOCAL oFont16n
LOCAL oFont14n
LOCAL oFont24
LOCAL i        := 0
LOCAL _nLin    := 0//200
LOCAL aCoords1 := {0150,1900,0550,2300}
LOCAL aCoords2 := {0450,1050,0550,1900}
LOCAL aCoords3 := {_nLin+0710,1900,_nLin+0810,2300}
LOCAL aCoords4 := {_nLin+0980,1900,_nLin+1050,2300}
LOCAL aCoords5 := {_nLin+1330,1900,_nLin+1400,2300}
LOCAL aCoords6 := {_nLin+2000,1900,_nLin+2100,2300}
LOCAL aCoords7 := {_nLin+2270,1900,_nLin+2340,2300}
LOCAL aCoords8 := {_nLin+2620,1900,_nLin+2690,2300}
LOCAL oBrush
Local nSalto   := 18
Local cLogoBol:="bofa.bmp"

oFont8  := TFont():New("Arial",9,08,.T.,.F.,5,.T.,5,.T.,.F.)
oFont8n := TFont():New("Arial",9,08,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12n:= TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n:= TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14n:= TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont20 := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont24 := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
oBrush  := TBrush():New("",RGB(220,220,220))

_nLin := 200

oPrint:FillRect({_nLin+640,1495,_nLin+760 ,2200},oBrush)
oPrint:FillRect({_nLin+940,1495,_nLin+1033,2200},oBrush)
                         
//Logo
oPrint:SayBitmap(_nLin-77,0150,cLogoBol,260,80 )
oPrint:Say (_nLin-38	,1650,"Recibo do Pagador",oFont12n)

//Sacador
oPrint:Line(_nLin  		,0150,_nLin+450	,0150)//Primeira coluna
oPrint:Line(_nLin		,2200,_nLin+365	,2200)//ultima coluna                                    

oPrint:Line(_nLin  		,0150,_nLin		,2200)//primeira linha                                                              
oPrint:Say (_nLin+023	,0156,"Beneficiário"   		,oFont8)
oPrint:Say (_nLin+060	,0156,aDadosEmp[1]					,oFont10)
oPrint:Say (_nLin+090	,0156,aDadosEmp[6]					,oFont10)//CNPJ
oPrint:Say (_nLin+120	,0156,ALLTRIM(aDadosEmp[2])+" - "+aDadosEmp[4]+" - "+aDadosEmp[3]	,oFont10)

oPrint:Line(_nLin+140	,0150,_nLin+140	,2200)//Segunda Linha 
oPrint:Say (_nLin+163	,0156,"Sacador/Avalista"			,oFont8)

oPrint:Line(_nLin+280	,0150,_nLin+280	,2200)//Terceira Linha 
oPrint:Line(_nLin+280	,1050,_nLin+365	,1050)//Primeira div. Quarta linha
oPrint:Line(_nLin+280	,1430,_nLin+365	,1430)//Segunda div. Quarta linha 
oPrint:Say (_nLin+303	,0156,"Pagador"		   		,oFont8)
oPrint:Say (_nLin+345	,0156,aDatSacador[1]					,oFont8n)
oPrint:Say (_nLin+303	,1056,"Data de Vencimento"	   		,oFont8)
oPrint:Say (_nLin+345	,1196,DTOC(aDadosTit[4])   	   		,oFont10)
oPrint:Say (_nLin+303	,1436,"Valor do Documento"	   		,oFont8)
oPrint:Say (_nLin+345	,1711,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

oPrint:Line(_nLin+365	,0150,_nLin+365	,2200)//Quarta Linha
oPrint:Line(_nLin+365	,0430,_nLin+450	,0430)//Primeira div. Quinta linha
oPrint:Line(_nLin+365	,1120,_nLin+450	,1120)//Segunda div. Quinta linha 
oPrint:Say (_nLin+388	,0156,"Agência/Código do Cedente"	,oFont8)
oPrint:Say (_nLin+430	,0186,STRZERO(VAL(aDadosBanco[7]),12),oFont10)
oPrint:Say (_nLin+388	,0646,"Nosso Número"				,oFont8)
oPrint:Say (_nLin+430	,0746,aDadosTit[6],oFont10)

oPrint:Line(_nLin+450	,0150,_nLin+450	,1120)//Quinta Linha

//Autenticação mecanica
oPrint:Line(_nLin+377	,1150,_nLin+377	,2200)
oPrint:Line(_nLin+377	,1150,_nLin+420	,1150)
oPrint:Line(_nLin+377	,2200,_nLin+420	,2200)
oPrint:Say (_nLin+400	,1450,"Autenticação Mecânica",oFont8) 
                 
//Pontilhado
FOR i := 150 TO 2200 STEP 20
	oPrint:Line(_nLin+535,i,_nLin+535,i+10)
NEXT i
                                                
//Boleto
//Logo
oPrint:SayBitmap(_nLin+560,0150,cLogoBol,260,80 )
oPrint:Line(_nLin+560	,0480,_nLin+640		,0480)
oPrint:Line(_nLin+560	,0630,_nLin+640		,0630)
oPrint:Say(_nLin+605	,0480,aDadosBanco[1]+"-2"	,oFont20)// [1]Numero do Banco
oPrint:Say(_nLin+610	,0650,CB_RN_NN[2]			,oFont20)// [2] Linha Digitavel do Codigo de Barras

         
oPrint:Line(_nLin+640	,0150,_nLin+640		,2200)//Primeira linha
oPrint:Line(_nLin+640	,0150,_nLin+1730	,0150)//Primeira COluna
oPrint:Say (_nLin+663	,0156,"Local de Pagamento"	,oFont8)
oPrint:Say (_nLin+710	,0166,"PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO"	,oFont10)
oPrint:Say (_nLin+740	,0166,"APOS O VENCIMENTO ACESSE HTTP://BOLETOS.BAML.COM ",oFont10)
oPrint:Say (_nLin+663	,1501,"Vencimento"			,oFont8)
oPrint:Say (_nLin+740	,1721,DTOC(aDadosTit[4])	,oFont10)

oPrint:Line(_nLin+760	,0150,_nLin+760				,2200)
oPrint:Say (_nLin+783	,0156,"Beneficiário"		   		,oFont8)    
oPrint:Say (_nLin+830	,0166,aDadosEmp[1] + " - " + aDadosEmp[6]		,oFont10)
oPrint:Say (_nLin+783	,1501,"Agência/Código do Beneficiário",oFont8)
oPrint:Say (_nLin+810	,1531,STRZERO(VAL(aDadosBanco[7]),12),oFont10)

oPrint:Line(_nLin+850	,0150,_nLin+850		,2200)                 
oPrint:Line(_nLin+850	,0360,_nLin+940		,0360)
oPrint:Line(_nLin+850	,0630,_nLin+940		,0630)
oPrint:Line(_nLin+850	,0913,_nLin+940		,0913)
oPrint:Line(_nLin+850	,1135,_nLin+940		,1135)
oPrint:Say (_nLin+873	,0156,"Data do Documento"		,oFont8)
oPrint:Say (_nLin+920	,0186,DTOC(aDadosTit[2])		,oFont10)
oPrint:Say (_nLin+873	,0416,"Nro.Documento"			,oFont8)
oPrint:Say (_nLin+920	,0420,aDadosTit[7]+aDadosTit[1]	,oFont10)
oPrint:Say (_nLin+873	,0686,"Espécie Doc."			,oFont8) 
oPrint:Say (_nLin+920	,0706,aDadosTit[8]				,oFont10)
oPrint:Say (_nLin+873	,0969,"Aceite"			   		,oFont8)
oPrint:Say (_nLin+920	,0989,"Não"						,oFont10)
oPrint:Say (_nLin+873	,1191,"Data do Processamento"	,oFont8)
oPrint:Say (_nLin+920	,1221,DTOC(aDadosTit[3])		,oFont10)
oPrint:Say (_nLin+873	,1501,"Nosso Número"			,oFont8)
oPrint:Say (_nLin+920	,1530,aDadosTit[6],oFont10)

oPrint:Line(_nLin+940	,0150,_nLin+940		,2200)
oPrint:Line(_nLin+940	,0495,_nLin+1030	,0495)
oPrint:Line(_nLin+940	,0690,_nLin+1030	,0690)
oPrint:Line(_nLin+940	,0900,_nLin+1030	,0900)
oPrint:Line(_nLin+940	,1185,_nLin+1030	,1185)
oPrint:Say (_nLin+960	,0156,"Uso do Banco"			,oFont8)
oPrint:Say (_nLin+960	,0501,"Carteira"				,oFont8)
oPrint:Say (_nLin+1010	,0531,aDadosBanco[6]			,oFont10)
oPrint:Say (_nLin+960	,0696,"Espécie Moeda"			,oFont8)
oPrint:Say (_nLin+1010	,0726,"R$"						,oFont10)
oPrint:Say (_nLin+960	,0906,"Quantidade Moeda"		,oFont8) 
oPrint:Say (_nLin+1010	,0936,"1.00"						,oFont10)
oPrint:Say (_nLin+960	,1191,"Valor Moeda"				,oFont8) 
oPrint:Say (_nLin+990	,1220,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
oPrint:Say (_nLin+960	,1501,"Valor do Documento"		,oFont8)
oPrint:Say (_nLin+1010	,1721,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

oPrint:Line(_nLin+1030	,0150,_nLin+1030	,2200)
oPrint:Say (_nLin+1053	,0156,"Instruções (Texto de responsabilidade do Beneficiário)"				,oFont8)
oPrint:Say (_nLin+1233	,0166,"TITULO SUJEITO A PROTESTO APÓS 60 DIAS DO VENCIMENTO.",oFont10) 
                      
oPrint:Line(_nLin+1120	,1495,_nLin+1120	,2200)
oPrint:Line(_nLin+1210	,1495,_nLin+1210	,2200)
oPrint:Line(_nLin+1300	,1495,_nLin+1300	,2200)
oPrint:Line(_nLin+1390	,1495,_nLin+1390	,2200)
oPrint:Say (_nLin+1056	,1501,"(-)Desconto/Abatimento"	,oFont8)
oPrint:Say (_nLin+1100	,1721,IF(aDadosTit[9]<>0,AllTrim(Transform(aDadosTit[9],"@E 999,999,999.99")),""),oFont10)
oPrint:Say (_nLin+1146	,1501,"(-)Outras Deduções"		,oFont8)
oPrint:Say (_nLin+1236	,1501,"(+)Mora/Multa"			,oFont8)
oPrint:Say (_nLin+1326	,1501,"(+)Outros Acréscimos"	,oFont8)
oPrint:Say (_nLin+1416	,1501,"(=)Valor Cobrado"		,oFont8)

oPrint:Line(_nLin+1480	,0150,_nLin+1480	,2200)
oPrint:Say (_nLin+1503	,0156,"Pagador"					,oFont8)
oPrint:Say (_nLin+1533	,0156,aDatSacador[1]+" "+TRANSFORM(aDatSacador[7],"@R 99.999.999/9999-99")	,oFont10)
oPrint:Say (_nLin+1563	,0156,aDatSacador[3]											,oFont10)
oPrint:Say (_nLin+1593	,0156,aDatSacador[6]+"    "+aDatSacador[4]+" - "+aDatSacador[5],oFont10) // CEP+Cidade+Estado
                        
oPrint:Say (_nLin+1633	,0156,"Sacador/Avalista"		,oFont8)                                                           

oPrint:Say (_nLin+1700	,1080,"Código de Barras"			,oFont8)
oPrint:Line(_nLin+1730	,0150,_nLin+1730	,2200)//Ultima linha
oPrint:Line(_nLin+640	,2200,_nLin+1730	,2200)//Ultima Coluna
oPrint:Line(_nLin+640	,1495,_nLin+1480	,1495)//Penultima Coluna

oPrint:Say (_nLin+1753,1050,"Autenticação Mecânica"		,oFont8)
oPrint:Say (_nLin+1763,1450,"Ficha de Compensação"		,oFont12n)

cFont:="Helvetica 65 Medium"
oPrint:FWMSBAR("INT25" /*cTypeBar*/,45.3/*nRow*/ ,7/*nCol*/, CB_RN_NN[1]/*cCode*/,oPrint/*oPrint*/,.F./*lCheck*/,/*Color*/,.T./*lHorz*/,0.017/*nWidth*/,0.95/*0.8*//*nHeigth*/,.F./*lBanner*/, cFont/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)              

RETURN Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ MODULO10()  ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Bank of America Merrill Lynch com Codigo ³±±
±±³           ³ de Barras, Linha Digitavel e Nosso Numero.                 ³±±
±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ FINANCEIRO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION Modulo10(cData)
LOCAL L,D,P := 0
LOCAL B     := .F.
L := Len(cData)
B := .T.
D := 0
WHILE L > 0
	P := VAL(SUBSTR(cData, L, 1))
	IF (B)
		P := P * 2
		IF P > 9
			P := P - 9
		ENDIF
	ENDIF
	D := D + P
	L := L - 1
	B := !B
ENDDO
D := 10 - (Mod(D,10))
IF D = 10
	D := 0
ENDIF
RETURN(D)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ MODULO11()  ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Bank of America Merrill Lynch com Codigo ³±±
±±³           ³ de Barras, Linha Digitavel e Nosso Numero.                 ³±±
±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ FINANCEIRO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION Modulo11(cData)
LOCAL L, D, P := 0
L := LEN(cdata)
D := 0
P := 1
WHILE L > 0
	P := P + 1
	D := D + (VAL(SUBSTR(cData, L, 1)) * P)
	IF P = 9
		P := 1
	ENDIF
	L := L - 1
ENDDO
D := 11 - (mod(D,11))
IF (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
	D := 1
ENDIF
RETURN(D)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ret_cBarra³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASE DO ITAU COM CODIGO DE BARRAS      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto)

LOCAL cValorFinal 	:= strzero((nValor*100),10)
LOCAL nDvnn			:= 0
LOCAL nDvcb			:= 0
LOCAL nDv			:= 0
LOCAL cNN			:= ''
LOCAL cRN			:= ''
LOCAL cCB			:= ''
LOCAL cS			:= ''
LOCAL cFator      	:= Strzero(dVencto - ctod("07/10/97"),4)
LOCAL cCart			:= "02"
//-----------------------------
// Definicao do NOSSO NUMERO
// ----------------------------
cS    := cCart + substr(alltrim(cNroDoc),1,len(alltrim(cNroDoc))-1)
nDvnn := RIGHT(cNroDoc,1)//modulo11(cS) // digito verificador
cNNSD := cS //Nosso Numero sem digito
cNN   := substr(alltrim(cNroDoc),1,len(alltrim(cNroDoc))-1)+" "+cCart+"4"

//----------------------------------
//	 campo livre do código de barras
//----------------------------------
cLivre 	:= STRZERO(VAL(SEE->EE_CODEMP),12)+LEFT(cNN,10)+cCart+"4"

cS		:= cBanco + cFator +  cValorFinal + cLivre
nDvcb 	:= modulo11(cS)
cCB   	:= SubStr(cS, 1, 4) + AllTrim(Str(nDvcb)) + SubStr(cS,5)// + SubStr(cS,31)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCCCX		DDDDD.DDDDDY	FFFFF.FFFFFZ	K			UUUUVVVVVVVVVV

// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	B     = Codigo da moeda, sempre 9
//	CCCCC = as 5 primeiras posições do campo livre (posições 20 a 24 do código de barras) 
//	X     = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
cS    := cBanco + Substr(cCB,20,5)
nDv   := Mod102(cS) //1ºDAC
cRN   := SubStr(cS, 1, 5) + '.' + SubStr(cS, 6, 4) + AllTrim(Str(nDv)) + '  '

// 	CAMPO 2:
//	DDDDDDDDDD =  composto pelas posições 6 a 15 do campo livre (posições 25 a 34 do código de barras)
//	Y          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
cS 	:= Substr(cCB,25,10)
nDv	:= Mod102(cS) //2º DAC
cRN	+= Subs(cS,1,5) +'.'+ Subs(cS,6,5) + Alltrim(Str(nDv)) + ' '

// 	CAMPO 3:
//	FFFFFFFFFF = composto pelas posições 16 a 25 do campo livre (posições 35 a 44 do código de barras)
//	Z          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
cS 	:=Subs(cCB,35,10)
nDv	:= Mod102(cS) //3º DAC
cRN	+= Subs(cS,1,5) +'.'+ Subs(cS,6,5) + Alltrim(Str(nDv)) + ' '

//	CAMPO 4:
//	     K = dígito verificador geral do código de barras (posição 5 do código de barras)
cRN += AllTrim(Str(nDvcb)) + '  '

// 	CAMPO 5:
//	      UUUU = composto pelo "fator de vencimento" (posições 6 a 9 do código de barras) 
//	VVVVVVVVVV = Valor do Titulo
cRN  += cFator + StrZero((nValor * 100),14-Len(cFator))

Return({cCB,cRN,cNN})

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSx1    ³ Autor ³ Microsiga            	³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica/cria SX1 a partir de matriz para verificacao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                    	  		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1(cPerg, aPergs)

Local _sAlias	:= Alias()
Local aCposSX1	:= {}
Local nX 		:= 0
Local lAltera	:= .F.
Local cKey		:= ""
Local nJ		:= 0
Local nCondicao

cPerg := Padr(cPerg,10)

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aPergs)
	lAltera := .F.
	If MsSeek(cPerg+Right(aPergs[nX][11], 2))
		If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
			Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
			aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
			lAltera := .T.
		Endif
	Endif
	
	If ! lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]
		lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
	Endif
	
	If ! Found() .Or. lAltera
		RecLock("SX1",If(lAltera, .F., .T.))
		Replace X1_GRUPO with cPerg
		Replace X1_ORDEM with Right(aPergs[nX][11], 2)
		For nj:=1 to Len(aCposSX1)
			If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
				FieldPos(AllTrim(aCposSX1[nJ])) > 0
				Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
			Endif
		Next nj
		MsUnlock()
		cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."
		
		If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
			aHelpSpa := aPergs[nx][Len(aPergs[nx])]
		Else
			aHelpSpa := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
			aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
		Else
			aHelpEng := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
			aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
		Else
			aHelpPor := {}
		Endif
		
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	Endif
Next                         

*---------------------------*
Static function Mod102(cData)
*---------------------------*

Local nBin:=2        
Local nNum:=0
Local nTot:=0
Local nBase10:=0
Local nDig:=0

	for i:=len(alltrim(cData)) to 1 STEP -1
		nNum:=val(substr(alltrim(cData),i,1))*nBin
        	if len(alltrim(str(nNum)))>1
        		for j:=1 to len(alltrim(str(nNum)))
        			nTot+=val(substr(alltrim(str(nNum)),j,1))
        		next
        	else
        		nTot+=nNum
        	endif 
        	
		nBin:=(nBin%2)+1
	next
    
    if nTot%10==0
    	nBase10:= nTot
    else
		nBase10:= ABS((nTot%10)-10)+nTot
    endif
    
	nDig:=nBase10-nTot

Return(nDig)