#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"  
#INCLUDE "topconn.ch"

#DEFINE DS_MODALFRAME   128  

/*
Funcao      : ZJFIN001
Parametros  : 
Retorno     : 
Objetivos   : Impressao de Boleto Bancario do Banco Bradesco com Codigo de Barras, Linha Digitavel e Nosso NumeroBaseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.
Autor       : João Dos Santos Silva
Data/Hora   : 22/06/2012
TDN         : 
Revisão     : 
Data/Hora   : 
Módulo      : Financeiro.
*/ 

*-------------------------*
 USER FUNCTION ZJFIN001()
*-------------------------*

LOCAL aCampos      	:= {{"E1_NOMCLI","Cliente","@!"},{"E1_PREFIXO","Prefixo","@!"},{"E1_NUM","Titulo","@!"},;
{"E1_PARCELA","Parcela","@!"},{"E1_VALOR","Valor","@E 9,999,999.99"},{"E1_VENCTO","Vencimento"}}
LOCAL	aPergs 		:= {}

LOCAL lExec         := .T.
LOCAL nOpc         	:= 0
LOCAL aMarked      	:= {}
LOCAL aDesc        	:= {"Este programa imprime os boletos de","cobranca bancaria de acordo com","os parametros informados"}
PRIVATE Exec       	:= .F.
PRIVATE cIndexName 	:= ''
PRIVATE cIndexKey  	:= ''
PRIVATE cFilter    	:= ''

Tamanho  := "M"
titulo   := "Impressao de Boleto Bradesco
cDesc1   := "Este programa destina-se a impressao do Boleto Bradesco."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
wnrel    := "BOL237ZJ"
lEnd     := .F.
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
nLastKey := 0
dbSelectArea("SE1")

cPerg     :="BLTBARBZJ"

Aadd(aPergs,{"De Prefixo","","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Prefixo","","","mv_ch2","C",3,0,0,"G","","MV_PAR02","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Numero","","","mv_ch3","C",9,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Numero","","","mv_ch4","C",9,0,0,"G","","MV_PAR04","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Parcela","","","mv_ch5","C",1,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Parcela","","","mv_ch6","C",1,0,0,"G","","MV_PAR06","","","","Z","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Cliente","","","mv_ch7","C",6,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","SE1","","","",""})
Aadd(aPergs,{"Ate Cliente","","","mv_ch8","C",6,0,0,"G","","MV_PAR08","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","SE1","","","",""})
Aadd(aPergs,{"De Loja","","","mv_cha","C",2,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Loja","","","mv_chb","C",2,0,0,"G","","MV_PAR10","","","","ZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Emissao","","","mv_chc","D",8,0,0,"G","","MV_PAR11","","","","01/01/80","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Emissao","","","mv_chd","D",8,0,0,"G","","MV_PAR12","","","","31/12/03","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Vencimento","","","mv_che","D",8,0,0,"G","","MV_PAR13","","","","01/01/80","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Vencimento","","","mv_chf","D",8,0,0,"G","","MV_PAR14","","","","31/12/03","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Bordero","","","mv_chg","C",6,0,0,"G","","MV_PAR15","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Bordero","","","mv_chh","C",6,0,0,"G","","MV_PAR16","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})

AjustaSx1("BLTBARBZJ",aPergs)

SET DATE FORMAT "dd/mm/yyyy"

If !Pergunte (cPerg,.T.)
	Return Nil
EndIF

If Select('SQL') > 0
	SQL->(DbCloseArea())
EndIf
/*
BeginSql Alias 'SQL'

	SELECT E1_OK,E1_PORTADO,E1_CLIENTE,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO,R_E_C_N_O_  as 'RECNUM' 
	FROM %table:SE1%
	WHERE %notDel%
	  AND E1_FILIAL = %xfilial:SE1%
	  AND E1_SALDO > 0
	  AND E1_PREFIXO >= %exp:MV_PAR01% AND E1_PREFIXO <= %exp:MV_PAR02%
	  AND E1_NUM     >= %exp:MV_PAR03% AND E1_NUM     <= %exp:MV_PAR04%
	  AND E1_PARCELA >= %exp:MV_PAR05% AND E1_PARCELA <= %exp:MV_PAR06%
	  AND E1_PORTADO >= %exp:MV_PAR07% AND E1_PORTADO <= %exp:MV_PAR08%
	  AND E1_CLIENTE >= %exp:MV_PAR09% AND E1_CLIENTE <= %exp:MV_PAR10%
	  AND E1_LOJA    >= %exp:MV_PAR11% AND E1_LOJA    <= %exp:MV_PAR12%
	  AND E1_EMISSAO >= %exp:MV_PAR13% AND E1_EMISSAO <= %exp:MV_PAR14%
	  AND E1_TIPO = 'NF'
	ORDER BY E1_PORTADO,E1_CLIENTE,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO
EndSql
*/
cQry:=" SELECT E1_OK,E1_PORTADO,E1_CLIENTE,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO,R_E_C_N_O_  as 'RECNUM' 
cQry+=" FROM "+RETSQLNAME("SE1")
cQry+=" WHERE D_E_L_E_T_=''
cQry+=" AND E1_FILIAL ='"+xFilial("SE1")+"' 
cQry+=" AND E1_SALDO > 0
cQry+=" AND E1_PREFIXO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'
cQry+=" AND E1_NUM     BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
cQry+=" AND E1_PARCELA BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
//cQry+=" AND E1_PORTADO BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'
cQry+=" AND E1_CLIENTE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'
cQry+=" AND E1_LOJA    BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'
cQry+=" AND E1_EMISSAO BETWEEN '"+DTOS(MV_PAR11)+"' AND '"+DTOS(MV_PAR12)+"'
cQry+=" AND E1_VENCTO BETWEEN '"+DTOS(MV_PAR13)+"' AND '"+DTOS(MV_PAR14)+"'
cQry+=" AND E1_NUMBOR BETWEEN '"+MV_PAR15+"' AND '"+MV_PAR16+"'
cQry+=" AND E1_TIPO IN ('NF','BOL')
cQry+=" ORDER BY E1_PORTADO,E1_CLIENTE,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO


//Memowrite('C:\HLB BRASIL\CNAB\SIRONA\CNAB.TXT',cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "SQL" ,.T.,.F.)

SQL->(dbGoTop())

If SQL->(EOF()) .or. SQL->(BOF())
	lExec := .F.
	alert("Não há dados com esses parâmetros!")
EndIf


If lExec
	Processa({|lEnd|MontaRel()})
Endif


Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ MONTAREL()  ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Banco Bradesco com Codigo ³±±
±±³           ³ de Barras, Linha Digitavel e Nosso Numero.                 ³±±
±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ FINANCEIRO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION MontaRel(aMarked)
LOCAL oPrint
LOCAL n         := 0
LOCAL aBitmap   := {	MV_PAR19,;		// Banner Publicitario
						"LGRL.bmp"}		// Logo da Empresa
/*
LOCAL aDadosEmp := {SM0->M0_NOMECOM,;																					//[1]Nome da Empresa
						SM0->M0_ENDCOB,; 																					//[2]Endereço
						AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
						"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3),; 					//[4]CEP
						"PABX/FAX: "+SM0->M0_TEL,; 																		//[5]Telefones
						"C.N.P.J.: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+;				//[6]
						Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+;								//[6]
						Subs(SM0->M0_CGC,13,2),;																		//[6]CGC
						"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+;					//[7]
						Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)}									//[7]I.E
*/
/*
LOCAL aDadosEmp := {"SIRONA DENTAL COM PROD E SIST ODONTO LTD                    ",;																					//[1]Nome da Empresa
						"RUA VITORINO JOSE LUIZ, 494							                          ",; 																					//[2]Endereço
						AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
						"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3),; 					//[4]CEP
						"PABX/FAX: "+SM0->M0_TEL,; 																		//[5]Telefones
						"C.N.P.J.: "+Subs("12483930000122",1,2)+"."+Subs("12483930000122",3,3)+"."+;				//[6]
						Subs("12483930000122",6,3)+"/"+Subs("12483930000122",9,4)+"-"+;								//[6]
						Subs("12483930000122",13,2),;																		//[6]CGC
						"I.E.: "+Subs("256190259     ",1,3)+"."+Subs("256190259     ",4,3)+"."+;					//[7]
						Subs("256190259     ",7,3)+"."+Subs("256190259     ",10,3)}									//[7]I.E						
*/	
LOCAL aDadosEmp := {"Bank Of America Merrill Lynch                       ",;	                    	//[1]Nome da Empresa																				//[1]Nome da Empresa
					SM0->M0_ENDCOB,; 															    	//[2]Endereço																					//[2]Endereço
						AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,;    //[3]Complemento
						"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3),; 			    //[4]CEP
						"PABX/FAX: "+SM0->M0_TEL,; 												     	//[5]Telefones
						"C.N.P.J.: "+Subs("62073200000121",1,2)+"."+Subs("62073200000121",3,3)+"."+;    //[6]
						Subs("62073200000121",6,3)+"/"+Subs("62073200000121",9,4)+"-"+;				    //[6]
						Subs("62073200000121",13,2),;											     	//[6]CGC
					    "I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+;            	//[7]
						Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)}	       					    //[7]I.E						
					
LOCAL aDadosTit
LOCAL aDadosBanco
LOCAL aDatSacado
//					{"Após o vencimento cobrar multa de R$ ",;

LOCAL aBolText  := {"","",""}

LOCAL aBolText  := {"",;
					"",;
			   		"TITULO SUJEITO A PROTESTO APÓS 60 DIAS DO VENCIMENTO."} //JSS - 08/09/2014 - Add mensagem para solucionar o caso 021238.

LOCAL aBMP      := aBitMap
LOCAL i         := 1
LOCAL CB_RN_NN  := {}
LOCAL nRec      := 0
LOCAL _nVlrAbat := 0

Private cPortGrv	:= ""
Private cAgeGrv		:= ""
Private cContaGrv	:= ""

//Chama tela de Selecao de Portador
//SELPORT()

If Alltrim(SM0->M0_CODIGO) $ "ZJ/4C"  
	cPortGrv    := "755"
	cAgeGrv     := "1306 "
	cContaGrv   := "10033016"

EndIf

If Empty(cPortGrv) .Or. Empty(cAgeGrv) .Or. Empty(cContaGrv)
	Aviso("Aviso","Portador não Escolhido, Boleto não será impresso.",{"Abandona"},2)
	Return Nil
EndIf

oPrint  := TMSPrinter():New("Boleto Laser")
oPrint:Setup()
oPrint:SetPortrait()			// ou SetLandscape()
oPrint:SetPaperSize(9)			// Seta para papel A4
oPrint:StartPage()				// Inicia uma nova pagina

SQL->(dbGoTop())
ProcRegua(SQL->(RecCount()))
Do While SQL->(!EOF())

	DbSelectArea("SE1")
	SE1->(DbGoTo(SQL->RECNUM))

	//Posiciona o SA6 (Bancos)
	If Empty(SE1->E1_PORTADO) //.and. Marked("E1_OK")
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
	
	If Empty(SE1->E1_PORTADO)// .or. !Marked("E1_OK")
		//SE1->(DBSKIP())
		SQL->(DBSKIP())
		LOOP
	EndIf
	
	// Posiciona o SA6 (Bancos)
	dbSelectArea("SA6")
	dbSetOrder(1)
	dbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.)
	// Posiciona na Arq de Parametros CNAB
	dbSelectArea("SEE")
	dbSetOrder(1)
	dbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)
	// Posiciona o SA1 (Cliente)
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
	// Seleciona o SE1 (Contas a Receber)
	dbSelectArea("SE1")
	
/*	aDadosBanco := {"237",;																		//SA6->A6_COD [1]Numero do Banco
					"Bradesco",;																// [2]Nome do Banco
					SUBSTR(SA6->A6_AGENCIA,1,4)+SA6->A6_DVAGE,;										// [3]Agencia
					"0"+SUBSTR(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1),;	// [4]Conta Corrente
					SUBSTR(SA6->A6_NUMCON,Len(AllTrim(SA6->A6_NUMCON)),1),;	// [5]Digito da conta corrente                 admin
					"09"}																			// [6]Codigo da Carteira
	IF EMPTY(SA1->A1_ENDCOB)
		aDatSacado := {	AllTrim(SA1->A1_NOME),;											// [1]Razao Social
						AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA,;						// [2]Codigo
						AllTrim(SA1->A1_END)+"-"+AllTrim(SA1->A1_BAIRRO),;		// [3]Endereco
						AllTrim(SA1->A1_MUN),;												// [4]Cidade
						SA1->A1_EST,;															// [5]Estado
						SA1->A1_CEP,;															// [6]CEP
						SA1->A1_CGC}															// [7]CGC
	ELSE
		aDatSacado := {	AllTrim(SA1->A1_NOME),;											// [1]Razao Social
						AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA,;						// [2]Codigo
						AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;	// [3]Endereco
						AllTrim(SA1->A1_MUNC),;												// [4]Cidade
						SA1->A1_ESTC,;															// [5]Estado
						SA1->A1_CEPC,;															// [6]CEP
						SA1->A1_CGC}															// [7]CGC
	ENDIF
*/   
	aDadosBanco := {"237",;			 // [1]Numero do Banco
					"Bradesco",;	 // [2]Nome do Banco
					"23728",;		 // [3]Agencia
					"0008679-",;     // [4]Conta Corrente
					"7",;	         // [5]Digito da conta corrente
					"09"}			 // [6]Codigo da Carteira
	IF EMPTY(SA1->A1_ENDCOB)
		aDatSacado := {	AllTrim(SA1->A1_NOME),;											// [1]Razao Social
						AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA,;					        // [2]Codigo
						AllTrim(SA1->A1_END)+"-"+AllTrim(SA1->A1_BAIRRO),;		        // [3]Endereco
						AllTrim(SA1->A1_MUN),;											// [4]Cidade
						SA1->A1_EST,;													// [5]Estado
						SA1->A1_CEP,;													// [6]CEP
						SA1->A1_CGC}													// [7]CGC
	ELSE
		aDatSacado := {	AllTrim(SA1->A1_NOME),;											// [1]Razao Social
						AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA,;						// [2]Codigo
						AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;       	// [3]Endereco
						AllTrim(SA1->A1_MUNC),;											// [4]Cidade
						SA1->A1_ESTC,;													// [5]Estado
						SA1->A1_CEPC,;													// [6]CEP
						SA1->A1_CGC}													// [7]CGC
	ENDIF
	_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	
	IF EMPTY(SE1->E1_NUMBCO)
			cNroDoc 	:= SUBSTR(NOSSONUM(),2,11)
			cCart:="09"
			nB7:=2
			nSoma:=0
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
			
			cNroDoc+=_RETDIG
			
			DbSelectArea("SE1")
			RecLock("SE1",.f.)
				SE1->E1_NUMBCO 	:=	cNroDoc   // Nosso número (Ver fórmula para calculo)
			MsUnlock()

	Else
		cNroDoc 	:= ALLTRIM(SE1->E1_NUMBCO)
	EndIf
	
	CB_RN_NN := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",SUBSTR(aDadosBanco[3],1,4),aDadosBanco[4],aDadosBanco[5],cNroDoc,(E1_SALDO-_nVlrAbat),E1_VENCTO)
	
	aDadosTit := {	AllTrim(E1_NUM)+AllTrim(SE1->E1_PARCELA),;	 // [1] Numero do Titulo
					SE1->E1_EMISSAO,;							 // [2] Data da Emissao do Titulo
					Date(),;							    	 // [3] Data da Emissao do Boleto
					SE1->E1_VENCTO,;							 // [4] Data do Vencimento
					(SE1->E1_SALDO - _nVlrAbat),;				 // [5] Valor do Titulo
					CB_RN_NN[3],;							     // [6] Nosso Numero (Ver Formula para Calculo)
					SE1->E1_PREFIXO,;							 // [7] Prefixo da NF
					SE1->E1_TIPO,;                               // [8] Tipo do Titulo
					SE1->E1_DECRESC}							 // [9] Decrescimo
		
	Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
	n := n + 1
	
	
	SQL->(dbSkip())
	SQL->(INCPROC())
	i := i + 1
ENDDO
oPrint:EndPage()	// Finaliza a Pagina.
oPrint:Preview()	// Visualiza antes de Imprimir.

SQL->(DbCloseArea())

RETURN nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ IMPRESS()   ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Banco Bradesco com Codigo ³±±
±±³           ³ de Barras, Linha Digitavel e Nosso Numero.                 ³±±
±±³           ³ Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ FINANCEIRO                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION Impress(oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
LOCAL oFont8
LOCAL oFont10
LOCAL oFont16
LOCAL oFont16n
LOCAL oFont14n
LOCAL oFont24
LOCAL i        := 0
LOCAL _nLin    := 200
LOCAL aCoords1 := {0150,1900,0550,2300}
LOCAL aCoords2 := {0450,1050,0550,1900}
LOCAL aCoords3 := {_nLin+0710,1900,_nLin+0810,2300}
LOCAL aCoords4 := {_nLin+0980,1900,_nLin+1050,2300}
LOCAL aCoords5 := {_nLin+1330,1900,_nLin+1400,2300}
LOCAL aCoords6 := {_nLin+2000,1900,_nLin+2100,2300}
LOCAL aCoords7 := {_nLin+2270,1900,_nLin+2340,2300}
LOCAL aCoords8 := {_nLin+2620,1900,_nLin+2690,2300}
LOCAL oBrush       
Local cBraLogo:="bradesco10.bmp"
// Parâmetros de TFont.New()
// 1.Nome da Fonte (Windows)
// 3.Tamanho em Pixels
// 5.Bold (T/F)
oFont8  := TFont():New("Arial",9,08,.T.,.F.,5,.T.,5,.T.,.F.)
//oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n:= TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24 := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
oBrush  := TBrush():New("",4)
oPrint:StartPage()	// Inicia uma nova Pagina
// "Pinta" os Campos com Cinza.
//oPrint:FillRect(aCoords1,oBrush)
//oPrint:FillRect(aCoords2,oBrush)
//oPrint:FillRect(aCoords3,oBrush)
//oPrint:FillRect(aCoords4,oBrush)
//oPrint:FillRect(aCoords5,oBrush)
//oPrint:FillRect(aCoords6,oBrush)
//oPrint:FillRect(aCoords7,oBrush)
//oPrint:FillRect(aCoords8,oBrush)

// Inicia aqui a alteracao para novo layout - RAI
oPrint:Line(0150,0560,0050,0560)
oPrint:Line(0150,0800,0050,0800)
oPrint:SayBitmap(55,0100,cBraLogo,130,75 )    	
oPrint:Say (0084,0250,aDadosBanco[2],oFont16)					// [2] Nome do Banco
oPrint:Say (0062,0567,aDadosBanco[1]+"-2",oFont24)					// [1] Numero do Banco
oPrint:Say (0084,1870,"Comprovante de Entrega",oFont10)
oPrint:Line(0150,0100,0150,2300)
oPrint:Say (0150,0100,"Beneficiário",oFont8)
oPrint:Say (0200,0100,aDadosEmp[1]	,oFont10)					// [1] Nome + CNPJ
oPrint:Say (0150,1060,"Agência/Código Beneficiário",oFont8)
oPrint:Say (0200,1060,SUBSTR(aDadosBanco[3],1,4)+"-"+SUBSTR(aDadosBanco[3],5,1)+"/"+aDadosBanco[4]+aDadosBanco[5],oFont10)
oPrint:Say (0150,1510,"Nro.Documento",oFont8)
oPrint:Say (0200,1510,aDadosTit[7]+aDadosTit[1],oFont10)	// [7] Prefixo + [1] Numero + Parcela
oPrint:Say (0250,0100,"Pagador",oFont8)
oPrint:Say (0300,0100,aDatSacado[1],oFont10)					// [1] Nome
oPrint:Say (0250,1060,"Vencimento",oFont8)
oPrint:Say (0300,1060,DTOC(aDadosTit[4]),oFont10)
oPrint:Say (0250,1510,"Valor do Documento",oFont8)
oPrint:Say (0300,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
oPrint:Say (0400,0100,"Recebi(emos) o bloqueto/título",oFont10)
oPrint:Say (0450,0100,"com as características acima.",oFont10)
oPrint:Say (0350,1060,"Data",oFont8)
oPrint:Say (0350,1410,"Assinatura",oFont8)
oPrint:Say (0450,1060,"Data",oFont8)
oPrint:Say (0450,1410,"Entregador",oFont8)
oPrint:Line(0250,0100,0250,1900)
oPrint:Line(0350,0100,0350,1900)
oPrint:Line(0450,1050,0450,1900) //---
oPrint:Line(0550,0100,0550,2300)
oPrint:Line(0550,1050,0150,1050)
oPrint:Line(0550,1400,0350,1400)
oPrint:Line(0350,1500,0150,1500) //--
oPrint:Line(0550,1900,0150,1900)
oPrint:Say (0150,1910,"(  )Mudou-se",oFont8)
oPrint:Say (0190,1910,"(  )Ausente",oFont8)
oPrint:Say (0230,1910,"(  )Não existe nº indicado",oFont8)
oPrint:Say (0270,1910,"(  )Recusado",oFont8)
oPrint:Say (0310,1910,"(  )Não procurado",oFont8)
oPrint:Say (0350,1910,"(  )Endereço insuficiente",oFont8)
oPrint:Say (0390,1910,"(  )Desconhecido",oFont8)
oPrint:Say (0430,1910,"(  )Falecido",oFont8)
oPrint:Say (0470,1910,"(  )Outros(anotar no verso)",oFont8)
FOR i := 100 TO 2300 STEP 50
	oPrint:Line(_nLin+0600,i,_nLin+0600,i+30)
NEXT i
oPrint:Line(_nLin+0710,0100,_nLin+0710,2300)
oPrint:Line(_nLin+0710,0560,_nLin+0610,0560)
oPrint:Line(_nLin+0710,0800,_nLin+0610,0800)       
oPrint:SayBitmap(_nLin+0615,0100,cBraLogo,130,75 )    	
oPrint:Say (_nLin+0644,0250,aDadosBanco[2],oFont16)	// [2]Nome do Banco
oPrint:Say (_nLin+0622,0567,aDadosBanco[1]+"-2",oFont24)	// [1]Numero do Banco
oPrint:Say (_nLin+0644,1900,"Recibo do Pagador",oFont10)
oPrint:Line(_nLin+0810,0100,_nLin+0810,2300)
oPrint:Line(_nLin+0910,0100,_nLin+0910,2300)
oPrint:Line(_nLin+0980,0100,_nLin+0980,2300)
oPrint:Line(_nLin+1050,0100,_nLin+1050,2300)
oPrint:Line(_nLin+0910,0500,_nLin+1050,0500)
oPrint:Line(_nLin+0980,0750,_nLin+1050,0750)
oPrint:Line(_nLin+0910,1000,_nLin+1050,1000)
oPrint:Line(_nLin+0910,1350,_nLin+0980,1350)
oPrint:Line(_nLin+0910,1550,_nLin+1050,1550)
oPrint:Say (_nLin+0710,0100,"Local de Pagamento",oFont8)
oPrint:Say (_nLin+0750,0100,"Pagável preferencialmente na Rede Bradesco ou Bradesco Expresso",oFont10)
oPrint:Say (_nLin+0710,1910,"Vencimento",oFont8)
oPrint:Say (_nLin+0750,1950,DTOC(aDadosTit[4]),oFont10)
oPrint:Say (_nLin+0810,0100,"Beneficiário",oFont8)
oPrint:Say (_nLin+0850,0100,aDadosEmp[1]+"                  - "+aDadosEmp[6],oFont10) //Nome + CNPJ
oPrint:Say (_nLin+0810,1910,"Agência/Código Beneficiário",oFont8)
oPrint:Say (_nLin+0850,1950,SUBSTR(aDadosBanco[3],1,4)+"-"+SUBSTR(aDadosBanco[3],5,1)+"/"+aDadosBanco[4]+aDadosBanco[5],oFont10)
oPrint:Say (_nLin+0910,0100,"Data do Documento",oFont8)
oPrint:Say (_nLin+0940,0100,DTOC(aDadosTit[2]),oFont10) // Emissao do Titulo (E1_EMISSAO)
oPrint:Say (_nLin+0910,0505,"Nro.Documento",oFont8)
oPrint:Say (_nLin+0940,0605,aDadosTit[7]+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela
oPrint:Say (_nLin+0910,1005,"Espécie Doc.",oFont8)
oPrint:Say (_nLin+0940,1050,aDadosTit[8],oFont10) //Tipo do Titulo
oPrint:Say (_nLin+0910,1355,"Aceite",oFont8)
oPrint:Say (_nLin+0940,1455,"N",oFont10)
oPrint:Say (_nLin+0910,1555,"Data do Processamento",oFont8)
oPrint:Say (_nLin+0940,1655,DTOC(aDadosTit[3]),oFont10) // Data impressao
oPrint:Say (_nLin+0910,1910,"Carteira / Nosso Número",oFont8)
oPrint:Say (_nLin+0940,1950,SUBSTR(aDadosTit[6],1,2)+"/"+SUBSTR(aDadosTit[6],3),oFont10)
oPrint:Say (_nLin+0980,0100,"Uso do Banco",oFont8)
oPrint:Say (_nLin+0980,0505,"Carteira",oFont8)
oPrint:Say (_nLin+1010,0555,aDadosBanco[6],oFont10)
oPrint:Say (_nLin+0980,0755,"Espécie",oFont8)
oPrint:Say (_nLin+1010,0805,"R$",oFont10)
oPrint:Say (_nLin+0980,1005,"Quantidade",oFont8)
oPrint:Say (_nLin+0980,1555,"Valor",oFont8)
oPrint:Say (_nLin+0980,1910,"Valor do Documento",oFont8)
oPrint:Say (_nLin+1010,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
oPrint:Say (_nLin+1050,0100,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont8)
oPrint:Say (_nLin+1150,0100,aBolText[1]+" ",oFont10)
//oPrint:Say (_nLin+1200,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.05)/30),"@E 99,999.99")),oFont10) 
oPrint:Say (_nLin+1200,0100,aBolText[2]+" ",oFont10)
oPrint:Say (_nLin+1250,0100,aBolText[3],oFont10)
oPrint:Say (_nLin+1050,1910,"(-)Desconto/Abatimento",oFont8) 
oPrint:Say (_nLin+1085,1950,AllTrim(Transform(aDadosTit[9],"@E 999,999,999.99")),oFont10)
oPrint:Say (_nLin+1120,1910,"(-)Outras Deduções",oFont8)
oPrint:Say (_nLin+1190,1910,"(+)Mora/Multa",oFont8)
oPrint:Say (_nLin+1260,1910,"(+)Outros Acréscimos",oFont8)
oPrint:Say (_nLin+1330,1910,"(=)Valor Cobrado",oFont8)
oPrint:Say (_nLin+1400,0100,"Pagador",oFont8)
oPrint:Say (_nLin+1430,0400,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont10)
oPrint:Say (_nLin+1483,0400,aDatSacado[3],oFont10)
oPrint:Say (_nLin+1536,0400,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado
//oPrint:Say (_nLin+1589,0400,"CGC: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
oPrint:Say (_nLin+1589,1950,SUBSTR(aDadosTit[6],1,2)+"/"+SUBSTR(aDadosTit[6],3,len(alltrim(aDadosTit[6]))-2),oFont10)
oPrint:Say (_nLin+1605,0100,"Pagador/Avalista",oFont8)    
oPrint:Say (_nLin+1645,0100,"LINKEDIN REPRESENTAÇÕES DO BRASIL LTDA",oFont10)
oPrint:Say (_nLin+1645,1500,"Autenticação Mecânica -",oFont8)
oPrint:Line(_nLin+0710,1900,_nLin+1400,1900)
oPrint:Line(_nLin+1120,1900,_nLin+1120,2300)
oPrint:Line(_nLin+1190,1900,_nLin+1190,2300)
oPrint:Line(_nLin+1260,1900,_nLin+1260,2300)
oPrint:Line(_nLin+1330,1900,_nLin+1330,2300)
oPrint:Line(_nLin+1400,0100,_nLin+1400,2300)
oPrint:Line(_nLin+1640,0100,_nLin+1640,2300)
FOR i := 100 TO 2300 STEP 50
	oPrint:Line(_nLin+1890,i,_nLin+1890,i+30)
NEXT i
// Encerra aqui a alteracao para o novo layout - RAI
oPrint:Line(_nLin+2000,0100,_nLin+2000,2300)
oPrint:Line(_nLin+2000,0560,_nLin+1900,0560)
oPrint:Line(_nLin+2000,0800,_nLin+1900,0800)
oPrint:SayBitmap(_nLin+1905,0100,cBraLogo,130,75 )    	
oPrint:Say (_nLin+1934,0250,aDadosBanco[2],oFont16)	// [2] Nome do Banco
oPrint:Say (_nLin+1912,0567,aDadosBanco[1]+"-2",oFont24)	// [1] Numero do Banco
oPrint:Say (_nLin+1934,0820,CB_RN_NN[2],oFont14n)		// [2] Linha Digitavel do Codigo de Barras
oPrint:Line(_nLin+2100,0100,_nLin+2100,2300)
oPrint:Line(_nLin+2200,0100,_nLin+2200,2300)
oPrint:Line(_nLin+2270,0100,_nLin+2270,2300)
oPrint:Line(_nLin+2340,0100,_nLin+2340,2300)
oPrint:Line(_nLin+2200,0500,_nLin+2340,0500)
oPrint:Line(_nLin+2270,0750,_nLin+2340,0750)
oPrint:Line(_nLin+2200,1000,_nLin+2340,1000)
oPrint:Line(_nLin+2200,1350,_nLin+2270,1350)
oPrint:Line(_nLin+2200,1550,_nLin+2340,1550)
oPrint:Say (_nLin+2000,0100,"Local de Pagamento",oFont8)
oPrint:Say (_nLin+2040,0100,"Pagável preferencialmente na Rede Bradesco ou Bradesco Expresso",oFont10)
oPrint:Say (_nLin+2000,1910,"Vencimento",oFont8)
oPrint:Say (_nLin+2040,1950,DTOC(aDadosTit[4]),oFont10)
oPrint:Say (_nLin+2100,0100,"Beneficiário",oFont8)
oPrint:Say (_nLin+2140,0100,aDadosEmp[1]+"                  - "+aDadosEmp[6],oFont10) //Nome + CNPJ
oPrint:Say (_nLin+2100,1910,"Agência/Código Beneficiário",oFont8)
oPrint:Say (_nLin+2140,1950,SUBSTR(aDadosBanco[3],1,4)+"-"+SUBSTR(aDadosBanco[3],5,1)+"/"+aDadosBanco[4]+aDadosBanco[5],oFont10)
oPrint:Say (_nLin+2200,0100,"Data do Documento",oFont8)
oPrint:Say (_nLin+2230,0100,DTOC(aDadosTit[2]),oFont10)			// Emissao do Titulo (E1_EMISSAO)
oPrint:Say (_nLin+2200,0505,"Nro.Documento",oFont8)
oPrint:Say (_nLin+2230,0605,aDadosTit[7]+aDadosTit[1],oFont10)	//Prefixo + Numero + Parcela
oPrint:Say (_nLin+2200,1005,"Espécie Doc.",oFont8)
oPrint:Say (_nLin+2230,1050,aDadosTit[8],oFont10)					//Tipo do Titulo
oPrint:Say (_nLin+2200,1355,"Aceite",oFont8)
oPrint:Say (_nLin+2230,1455,"N",oFont10)
oPrint:Say (_nLin+2200,1555,"Data do Processamento",oFont8)
oPrint:Say (_nLin+2230,1655,DTOC(aDadosTit[3]),oFont10) // Data impressao
oPrint:Say (_nLin+2200,1910,"Carteira / Nosso Número",oFont8)
oPrint:Say (_nLin+2230,1950,SUBSTR(aDadosTit[6],1,2)+"/"+SUBSTR(aDadosTit[6],3),oFont10)
oPrint:Say (_nLin+2270,0100,"Uso do Banco",oFont8)
oPrint:Say (_nLin+2270,0505,"Carteira",oFont8)
oPrint:Say (_nLin+2300,0555,aDadosBanco[6],oFont10)
oPrint:Say (_nLin+2270,0755,"Espécie",oFont8)
oPrint:Say (_nLin+2300,0805,"R$",oFont10)
oPrint:Say (_nLin+2270,1005,"Quantidade",oFont8)
oPrint:Say (_nLin+2270,1555,"Valor",oFont8)
oPrint:Say (_nLin+2270,1910,"Valor do Documento",oFont8)
oPrint:Say (_nLin+2300,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
oPrint:Say (_nLin+2340,0100,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont8)
oPrint:Say (_nLin+2440,0100,aBolText[1]+" ",oFont10)
//oPrint:Say (_nLin+2490,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.05)/30),"@E 99,999.99")),oFont10) 
oPrint:Say (_nLin+2490,0100,aBolText[2]+" ",oFont10)
oPrint:Say (_nLin+2540,0100,aBolText[3],oFont10)
oPrint:Say (_nLin+2340,1910,"(-)Desconto/Abatimento",oFont8)
oPrint:Say (_nLin+2375,1950,AllTrim(Transform(aDadosTit[9],"@E 999,999,999.99")),oFont10)
oPrint:Say (_nLin+2410,1910,"(-)Outras Deduções",oFont8)
oPrint:Say (_nLin+2480,1910,"(+)Mora/Multa",oFont8)
oPrint:Say (_nLin+2550,1910,"(+)Outros Acréscimos",oFont8)
oPrint:Say (_nLin+2620,1910,"(=)Valor Cobrado",oFont8)
oPrint:Say (_nLin+2690,0100,"Pagador",oFont8)
oPrint:Say (_nLin+2720,0400,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont10)
oPrint:Say (_nLin+2773,0400,aDatSacado[3],oFont10)
oPrint:Say (_nLin+2826,0400,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10)	// CEP+Cidade+Estado
//oPrint:Say (_nLin+2879,0400,"CGC: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10)	// CGC
oPrint:Say (_nLin+2879,1950,SUBSTR(aDadosTit[6],1,2)+"/"+SUBSTR(aDadosTit[6],3,len(alltrim(aDadosTit[6]))-2),oFont10)
oPrint:Say (_nLin+2895,0100,"Pagador/Avalista",oFont8)     
oPrint:Say (_nLin+2935,0100,"LINKEDIN REPRESENTAÇÕES DO BRASIL LTDA",oFont10)
oPrint:Say (_nLin+2935,1500,"Autenticação Mecânica -",oFont8)
oPrint:Say (_nLin+2935,1850,"Ficha de Compensação",oFont10)
oPrint:Line(_nLin+2000,1900,_nLin+2690,1900)
oPrint:Line(_nLin+2410,1900,_nLin+2410,2300)
oPrint:Line(_nLin+2480,1900,_nLin+2480,2300)
oPrint:Line(_nLin+2550,1900,_nLin+2550,2300)
oPrint:Line(_nLin+2620,1900,_nLin+2620,2300)
oPrint:Line(_nLin+2690,0100,_nLin+2690,2300)
oPrint:Line(_nLin+2930,0100,_nLin+2930,2300)

MSBAR("INT25"  ,27.8,1.5,CB_RN_NN[1],oPrint,.F.,,,,1.4,,,,.F.)
     

oPrint:EndPage()	// Finaliza a Pagina
RETURN Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ MODULO10()  ³ Autor ³ Flavio Novaes    ³ Data ³ 03/02/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Impressao de Boleto Bancario do Banco Bradesco com Codigo ³±±
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
±±³ Descricao ³ Impressao de Boleto Bancario do Banco Bradesco com Codigo ³±±
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
LOCAL cCart			:= "09"
//-----------------------------
// Definicao do NOSSO NUMERO
// ----------------------------
cS    :=  cCart + substr(alltrim(cNroDoc),1,len(alltrim(cNroDoc))-1) //19 001000012
nDvnn := modulo11(cS) // digito verifacador
cNNSD := cS //Nosso Numero sem digito
cNN   := cCart + substr(alltrim(cNroDoc),1,len(alltrim(cNroDoc))-1)+ '-' + substr(alltrim(cNroDoc),len(alltrim(cNroDoc)),1)
//----------------------------------
//	 campo livre do código de barras
//----------------------------------
cLivre 	:= Strzero(Val(cAgencia),4)+ cCart + SUBSTR(cNNSD,3,LEN(cNNSD)-2) + Strzero(Val(cConta),7) + "0"

cS		:= cBanco + cFator +  cValorFinal + cLivre // + Subs(cNN,1,11) + Subs(cNN,13,1) + cAgencia + cConta + cDacCC + '000'
nDvcb 	:= modulo11(cS)
cCB   	:= SubStr(cS, 1, 4) + AllTrim(Str(nDvcb)) + SubStr(cS,5)// + SubStr(cS,31)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCCCX		DDDDD.DDDDDY	FFFFF.FFFFFZ	K			UUUUVVVVVVVVVV

// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	B     = Codigo da moeda, sempre 9
//	CCCCC = 5 primeiros digidos do cLivre
//	X     = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS    := cBanco + Substr(cLivre,1,5)
nDv   := Mod102(cS) //1ºDAC
cRN   := SubStr(cS, 1, 5) + '.' + SubStr(cS, 6, 4) + AllTrim(Str(nDv)) + '  '

// 	CAMPO 2:
//	DDDDDDDDDD = Posição 6 a 15 do Nosso Numero
//	Y          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS 	:=Subs(cLivre,6,10)
nDv	:= Mod102(cS) //2º DAC
cRN	+= Subs(cS,1,5) +'.'+ Subs(cS,6,5) + Alltrim(Str(nDv)) + ' '

// 	CAMPO 3:
//	FFFFFFFFFF = Posição 16 a 25 do Nosso Numero
//	Z          = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
cS 	:=Subs(cLivre,16,10)
nDv	:= Mod102(cS) //3º DAC
cRN	+= Subs(cS,1,5) +'.'+ Subs(cS,6,5) + Alltrim(Str(nDv)) + ' '

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
cRN += AllTrim(Str(nDvcb)) + '  '

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
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
		
		U_PUTHelp(cKey,aHelpPor,aHelpEng,aHelpSpa)
	Endif
Next

//--------------------------------------------------------------
/*/{Protheus.doc} SELPORT
Description

@param xParam Parameter Description
@return xRet Return Description
@author  - Amedeo D. P. Filho
@since 02/03/2011
/*/
//--------------------------------------------------------------
Static Function SELPORT()

Local oFont1	:= TFont():New("MS Sans Serif",,020,,.T.,,,,,.F.,.F.)
Local nOpcA		:= 0

Private cGet1 	:= Space(TamSx3("A6_COD")[1])
Private cGet2 	:= Space(TamSx3("A6_AGENCIA")[1])
Private cGet3 	:= Space(TamSx3("A6_NUMCON")[1])

Private oGet1
Private oGet2
Private oGet3

Static oDlg

DEFINE MSDIALOG oDlg TITLE "Selecionar Portador" FROM 000, 000  TO 230, 200 COLORS 0, 16777215 PIXEL Style DS_MODALFRAME

oDlg:lEscClose	:= .F.

@ 011, 010 SAY oSay1 PROMPT "Selecione Portador" 	SIZE 080, 012 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 035, 010 SAY oSay2 PROMPT "Banco :" 				SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 050, 010 SAY oSay3 PROMPT "Agencia :" 			SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 065, 010 SAY oSay4 PROMPT "Conta :" 				SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL

@ 035, 040 MSGET oGet1 VAR cGet1 SIZE 040, 010 OF oDlg COLORS 0, 16777215 F3 "SANTAN" PIXEL Valid(VALIDBCO())
@ 050, 040 MSGET oGet2 VAR cGet2 SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL	When .F.
@ 065, 040 MSGET oGet3 VAR cGet3 SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL	When .F.

DEFINE SBUTTON oSButton1 FROM 087, 020 TYPE 01 OF oDlg ENABLE Action (nOpcA := 1, oDlg:End())
DEFINE SBUTTON oSButton2 FROM 087, 051 TYPE 02 OF oDlg ENABLE Action (oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcA == 1
	cPortGrv	:= cGet1
	cAgeGrv		:= cGet2
	cContaGrv	:= cGet3
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida Banco     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VALIDBCO()
Local lRetorno := .T.

DbSelectarea("SA6")
DbSetorder(1)
If DbSeek(xFilial("SA6") + cGet1)
	cGet2 := SA6->A6_AGENCIA
	cGet3 := SA6->A6_NUMCON
	oGet2:Refresh()
	oGet3:Refresh()
Else
	lRetorno := .F.
	Aviso("Aviso","Banco Inválido!!!",{"Retorna"})
	cGet2 	:= Space(TamSx3("A6_AGENCIA")[1])
	cGet3 	:= Space(TamSx3("A6_NUMCON")[1])
	oGet2:Refresh()
	oGet3:Refresh()
EndIf

Return lRetorno		

Static function Mod102(cData)

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


