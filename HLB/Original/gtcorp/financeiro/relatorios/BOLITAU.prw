#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.Ch"

#DEFINE DS_MODALFRAME   128

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±?Programa  ?BOLITAU.PRW ?Autor ?                 ?Data ?21/09/2011 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Descricao ?Impressao de Boleto Bancario do Banco Itau      com Codigo ³±?
±±?          ?de Barras, Linha Digitavel e Nosso Numero.                 ³±?
±±?          ?Baseado no Fonte BOLITAU .                                 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso       ?FINANCEIRO                                                 ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/    

/*
Funcao      : BOLITAU
Parametros  : _nOpc
Retorno     : _cRet
Objetivos   : Impressao de Boleto Bancario do Banco Itau  com Codigode Barras, Linha Digitavel e Nosso Numero.
Autor       : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 06/02/2012
Módulo      : Financeiro.
*/    

*--------------------------*
  USER FUNCTION BOLITAU(lSelAuto)     
*--------------------------*

LOCAL aCampos      	:= {{"E1_NOMCLI","Cliente","@!"},{"E1_PREFIXO","Prefixo","@!"},{"E1_NUM","Titulo","@!"},;
{"E1_PARCELA","Parcela","@!"},{"E1_VALOR","Valor","@E 9,999,999.99"},{"E1_VENCTO","Vencimento"}}
LOCAL	aPergs 		:= {}

LOCAL lExec         := .T.
LOCAL nOpc         	:= 0
LOCAL aDesc        	:= {"Este programa imprime os boletos de","cobranca bancaria de acordo com","os parametros informados"}  
Local aAreaAnt      := GetArea()
PRIVATE Exec       	:= .F.
PRIVATE cIndexName 	:= ''
PRIVATE cIndexKey  	:= ''
PRIVATE cFilter    	:= ''
Private cBanco      := ''
Private cAgencia    := ''
Private cConta      := ''
Private cSubConta   := ''
Private cCodBanco 	:= ''

//Private MV_PAR05    := 1

DEFAULT lSelAuto	:=.F.

Tamanho  := "M"
titulo   := "Impressao de Boleto Itau"
cDesc1   := "Este programa destina-se a impressao do Boleto Itau."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
wnrel    := "BOLITAU"
lEnd     := .F.
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
nLastKey := 0
dbSelectArea("SE1")

if cEmpAnt $ "Z4" .AND. !lSelAuto
	Alert("Utilize a rotina (Boleto Itau/Santander)")
	Return()
endif

//MSM - 11/02/2014 - Criado para saber se o fonte est?sendo chamado de outro que j?tenha as configurações dos parâmetros
if !lSelAuto

	cPerg     :="BLTBARITAU"
	
	Aadd(aPergs,{"Prefixo","","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"De Numero","","","mv_ch2","C",9,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aPergs,{"Ate Numero","","","mv_ch3","C",9,0,0,"G","","MV_PAR03","","","","ZZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//Alterado - MSM - 27/07/2012
	Aadd(aPergs,{"Envia Email","","","mv_ch4","N",1,0,0,"C","","MV_PAR04","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","","",""})
	//Aadd(aPergs,{"Tipo Boleto","","","mv_ch5","N",1,0,0,"C","","MV_PAR05","Itau GT","","","","","Itau KPMG","","","","","Santander","","","","","","","","","","","","","","","","","",""})
	
	AjustaSx1("BLTBARITAU",aPergs)
	
	If !Pergunte (cPerg,.T.)
		Return Nil
	EndIF

endif

/*
If Alltrim(SM0->M0_CODIGO)=="ZB"    // AUDITORES
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "193805    "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="ZF"    // CORPORATE 
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "193821    "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="ZG"    // ASSESSORIA 
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "193847    "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="Z4" .And. Alltrim(SM0->M0_CODFIL) $ "0506"  // CONSULTING E CAMPINAS
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "385609    "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="Z4"  .And. Alltrim(SM0->M0_CODFIL) $ "010203"  // BPO / RIO DE JANEIRO / PORTO ALEGRE
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "414730    "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="CH"    // TECNOLOGY 
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "301994    "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="RH"    // RH
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "309849    "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="Z8"    // CONSULTORES 
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "387985    "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="ZP"    // GESTAO 
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "296103    "
	cSubConta := "001"	
ElseIf Alltrim(SM0->M0_CODIGO)=="99"    // teste
	cBanco    := "341"
	cAgencia  := "0190 "
	cConta    := "385609    "
	cSubConta := "001"	
EndIf
*/
/*If !Empty(cBanco) .And. !Empty(cAgencia) .And. !Empty(cConta)
	DbSelectArea("SE1")
	dbSetOrder(1)
	dbGoTop()
	
	If lExec*/
		Processa({|lEnd|MontaRel(lSelAuto)})
/*	Endif
	
Else
	MsgAlert("Banco/Agencia/Conta nao encontratos","Alerta")
Endif
*/

RestArea(aAreaAnt)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±?Funcao    ?MONTAREL()  ?Autor ?                 ?Data ?21/09/2011 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Descricao ?Impressao de Boleto Bancario do Banco Santander com Codigo ³±?
±±?          ?de Barras, Linha Digitavel e Nosso Numero.                 ³±?
±±?          ?Baseado no Fonte BOLSANT de 01/08/2002 de Raimundo Pereira.³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso       ?FINANCEIRO                                                 ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION MontaRel(lSelAuto)
LOCAL oPrint
LOCAL n         := 0 
LOCAL aDadosEmp := {}
LOCAL aDadosTit
LOCAL aDadosBanco
LOCAL aDatSacado
LOCAL aBolText  := {"Após o vencimento cobrar multa de R$ ",;
					"Mora Diaria de R$ ",;
					" "}
LOCAL i         := 1
LOCAL CB_RN_NN  := {}
LOCAL nRec      := 0
LOCAL _nVlrAbat := 0
Local n, nI     := 0
Local _nRecSE1  := 0
Private aBitmap   := {	"LOGO341.bmp",;		// Banner Publicitario Itau
						"LGRL.bmp"}		// Logo da Empresa
Private aBMP      := aBitMap

Private cPortGrv	:= ""
Private cAgeGrv		:= ""
Private cContaGrv	:= ""
Private cQry:="" 

Private cEmaSoc		:= ""
Private cEmailsCp	:= ""

//Selecao de Portador
//SELPORT()
/*
cPortGrv    := cBanco
cAgeGrv     := cAgencia
cContaGrv   := cConta
cSubConta   := If(Empty(cSubConta),"001",cSubConta)
*/
//If Empty(cPortGrv) .Or. Empty(cAgeGrv) .Or. Empty(cContaGrv)
//	Aviso("Aviso","Portador não Escolhido, Boleto não ser?impresso.",{"Abandona"},2)
//	Return Nil
//EndIf

/* Alterado MSM - 27/07/2012*/




	 aDadosEmp := {SM0->M0_NOMECOM,;															  		//[1]Nome da Empresa
							SM0->M0_ENDCOB,; 																//[2]Endereço
							AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,;    //[3]Complemento
							"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3),; 			    //[4]CEP
							"PABX/FAX: "+SM0->M0_TEL,; 														//[5]Telefones
							"C.N.P.J.: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+;		     	//[6]
							Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+;							//[6]
							Subs(SM0->M0_CGC,13,2),;														//[6]CGC
							"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+;				//[7]
							Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)}						     	//[7]I.E  

if lSelAuto
	if MV_PAR05 == 2
		 aDadosEmp := {"GRANT THORNTON CONSULTING SERVICES LTDA",;											//[1]Nome da Empresa
								SM0->M0_ENDCOB,; 																//[2]Endereço
								AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,;    //[3]Complemento
								"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3),; 			    //[4]CEP
								"PABX/FAX: "+SM0->M0_TEL,; 														//[5]Telefones
								"C.N.P.J.: 05.399.964/0001-78",;												//[6]CGC
								"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+;				//[7]
								Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)}						     	//[7]I.E    
	
	EndIf      
endif

if MV_PAR04==2
	oPrint  := TMSPrinter():New("Boleto Laser")
	oPrint:Setup()
	oPrint:SetPortrait()			// ou SetLandscape()
	oPrint:SetPaperSize(9)			// Seta para papel A4
	oPrint:StartPage()				// Inicia uma nova pagina
endif
 
Private aCols		:={}
Private aAuxAcols	:={}
Private nTipoBol    := 0
 
dbSelectArea ("SE1")
DbGotop()
ProcRegua(RecCount())
DbSetOrder(1)
DbSeek (xFilial("SE1")+mv_par01+mv_par02, .T.)
//AOA 18/02/2016 - Incluido instrução EOF para identificar final da tabela e não entrar em LOOP infinito
While !EOF() .AND. xFilial("SE1") == SE1->E1_FILIAL .AND. SE1->E1_PREFIXO == MV_PAR01 .AND. SE1->E1_NUM <= Mv_Par03 

    //cTipoBol := POSICIONE("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA, "SA1->A1_P_TPBOL")
	
	if SA1->(FieldPos("A1_P_TPBOL")>0)
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE +SE1->E1_LOJA))
			nTipoBol:= Val(SA1->A1_P_TPBOL)
		EndIf
	endif
	
	if lSelAuto 
		if nTipoBol <> MV_PAR05
			SE1->(dbSkip())
	  		Loop
		endif
	endif
		      
    If !SE1->E1_TIPO $ "NF /DP "
		SE1->(dbSkip())
  		Loop
    Endif  
/*
 	cBanco    := SE1->E1_PORTADO
	cAgencia  := SE1->E1_AGEDEP
	cConta    := SE1->E1_CONTA
	cSubConta := ""
*/
	If Empty(cBanco) .Or. Empty(cAgencia) .Or. Empty(cConta)

		If Alltrim(SM0->M0_CODIGO)=="ZB" .AND. SE1->E1_EMISSAO > STOD('20150629')     // AUDITORES
			cBanco    := "341"
			cAgencia  := "2938 "
		    cConta    := "272131    "       //JSS - Alterado para solucionar o caso 026169
			cSubConta := "001"	                                                        	
		ElseIf Alltrim(SM0->M0_CODIGO)=="ZB" .AND. SE1->E1_EMISSAO >= STOD('20130920') .AND. SE1->E1_EMISSAO <= STOD('20150629')// AUDITORES
			cBanco    := "341"
			cAgencia  := "0190 "
		    cConta    := "855189    "       //JSS - Antiga conta alterada para solucionar o chamado:014781 
			cSubConta := "001"	
   		ElseIf Alltrim(SM0->M0_CODIGO)=="ZB" .AND. SE1->E1_EMISSAO < STOD('20130920') // AUDITORES
			cBanco    := "341"
			cAgencia  := "0190 "
			cConta    := "272131    " // JSS Alterado para solucionar o caso 030472 . cConta    := "193805    "		//JSS - Nova conta alterada para solucionar o chamado:014781
			cSubConta := "001"  						
		ElseIf Alltrim(SM0->M0_CODIGO)=="ZF" .AND. SE1->E1_EMISSAO >= STOD('20130920') .AND. SE1->E1_EMISSAO <= STOD('20161009')  // CORPORATE 
			cBanco    := "341"
			cAgencia  := "0190 "
			cConta    := "925289    "  	    //JSS - Nova conta alterada para solucionar o chamado:014782
			cSubConta := "001"
		ElseIf Alltrim(SM0->M0_CODIGO)=="ZF" .AND. SE1->E1_EMISSAO < STOD('20130920')    // CORPORATE 
			cBanco    := "341"
			cAgencia  := "0190 "
			cConta    := "193821    "  	    //JSS - Antiga conta alterada para solucionar o chamado:014782
			cSubConta := "001"	
		ElseIf Alltrim(SM0->M0_CODIGO)=="ZG"// ASSESSORIA 
			cBanco    := "341"
			cAgencia  := "2938 "            //AOA 11/02/2016 - Alterado agencia e conta para solucionar chamado: 031948
			cConta    := "310196    "
			cSubConta := "001"
		ElseIf Alltrim(SM0->M0_CODIGO)=="Z4" .And. Alltrim(SM0->M0_CODFIL) $ "030608" .AND. SE1->E1_EMISSAO > STOD('20170117')  // GFP - 16/01/2017 - Chamado 038724
			cBanco    := "341"
			cAgencia  := "2938 "
		   	cConta    := "254469    "
			cSubConta := "001"	
		ElseIf Alltrim(SM0->M0_CODIGO)=="Z4" .And. Alltrim(SM0->M0_CODFIL) $ "060810"   // CAMPINAS
			cBanco    := "341"
			cAgencia  := "0190 "
			cConta    := "414730    "       //AOA - 02/05/2016 - Alterado a conta conforme chamado 033599 
			cSubConta := "001"
		//ElseIf Alltrim(SM0->M0_CODIGO)=="Z4" .And. Alltrim(SM0->M0_CODFIL) $ "08" .AND. SE1->E1_EMISSAO >= STOD('20130920')  // GOIANIA
		//	cBanco    := "341"
		//	cAgencia  := "0190 "             
		// 	cConta    := "922476    "       //JSS - Nova conta alterada para solucionar o chamado:014780 
		//	cSubConta := "001"	
		ElseIf Alltrim(SM0->M0_CODIGO)=="Z4" .And. Alltrim(SM0->M0_CODFIL) $ "05" .AND. SE1->E1_EMISSAO >= STOD('20150226')  // CONSULTING E CAMPINAS 
			cBanco    := "341"
			cAgencia  := "2938 "             //JSS - 20/01/2015 Alterado de 0190 para 2938 para solucionar o chamado 023774.
		   	cConta    := "254469    "       //JSS - 20/01/2015 Alterado de 922476 para 254469 para solucionar o chamado 023774. //JSS - Nova conta alterada para solucionar o chamado:014780 
			cSubConta := "001"	
		ElseIf Alltrim(SM0->M0_CODIGO)=="Z4" .And. Alltrim(SM0->M0_CODFIL) $ "05" .AND. SE1->E1_EMISSAO >= STOD('20130920') .AND. SE1->E1_EMISSAO <= STOD('20150225') // CONSULTING E CAMPINAS 
			cBanco    := "341"
			cAgencia  := "0190 "             
		   	cConta    := "922476    "       //JSS - Nova conta alterada para solucionar o chamado:014780 
			cSubConta := "001"	
		ElseIf Alltrim(SM0->M0_CODIGO)=="Z4" .And. Alltrim(SM0->M0_CODFIL) $ "05" .AND. SE1->E1_EMISSAO < STOD('20130920')  // CONSULTING E CAMPINAS
			cBanco    := "341"
			cAgencia  := "0190 "
			cConta    := "385609    "       //JSS - Antiga conta alterada para solucionar o chamado:014780 
			cSubConta := "001"
		ElseIf Alltrim(SM0->M0_CODIGO)=="Z4"  .And. Alltrim(SM0->M0_CODFIL) $ "0203"  // RIO DE JANEIRO / PORTO ALEGRE
			cBanco    := "341"
			cAgencia  := "0190 "
			cConta    := "414730    "
			cSubConta := "001"	
		ElseIf Alltrim(SM0->M0_CODIGO)=="Z4"  .And. Alltrim(SM0->M0_CODFIL) $ "01"  .And. MV_PAR05 == 4 // AOA - Boleto Sofisa
			cCodBanco := "637" //Sofisa
			cBanco    := "341"
			cAgencia  := "1248 " //Agencia no Sofisa 0019
			cConta    := "022053    " //Conta no Sofisa 433286
			cSubConta := "001"	
		ElseIf Alltrim(SM0->M0_CODIGO)=="Z4"  .And. Alltrim(SM0->M0_CODFIL) $ "01"  .AND. SE1->E1_EMISSAO < STOD('20160625') // AOA - conta antiga, chamado 034463
			cBanco    := "341"
			cAgencia  := "0190 "
			cConta    := "414730    "
			cSubConta := "001"	
		ElseIf Alltrim(SM0->M0_CODIGO)=="Z4"  .And. Alltrim(SM0->M0_CODFIL) $ "01"  // AOA - 17/06/2016 - alteração de conta - chamado 034463
   			cBanco    := "341"
			cAgencia  := "2938 "
			cConta    := "322688    "
   			cSubConta := "001"	
		ElseIf Alltrim(SM0->M0_CODIGO)=="CQ" // AOA - 20/06/2016 - Inclusão de empresa CQ- chamado 034561
			cBanco    := "341"
			cAgencia  := "2938 "
			cConta    := "322696    "
			cSubConta := "001"			
		ElseIf Alltrim(SM0->M0_CODIGO)=="CH"    // TECNOLOGY 
			cBanco    := "341"
			cAgencia  := "0190 "
			cConta    := "301994    "
			cSubConta := "001"	
		ElseIf Alltrim(SM0->M0_CODIGO)=="RH" .AND. SE1->E1_EMISSAO <= STOD('20161214')   // RH
			cBanco    := "341"
			cAgencia  := "0190 "
			cConta    := "309849    "
			cSubConta := "001"	
		ElseIf Alltrim(SM0->M0_CODIGO)=="RH" .AND. SE1->E1_EMISSAO > STOD('20161214')   // AOA - 02/12/2016 - inclusão de banco para cnab
			cBanco    := "341"
			cAgencia  := "2938 "
			cConta    := "340680    "
			cSubConta := "001"			
		ElseIf Alltrim(SM0->M0_CODIGO)=="Z8" .AND. SE1->E1_EMISSAO <= STOD('20161214')       // CONSULTORES 
			cBanco    := "341"
			cAgencia  := "0190 "
			cConta    := "387985    "
			cSubConta := "001"	
		ElseIf Alltrim(SM0->M0_CODIGO)=="Z8" .AND. SE1->E1_EMISSAO > STOD('20161214')       //AOA - 02/12/2016 - inclusão de banco para cnab
			cBanco    := "341"
			cAgencia  := "2938 "
			cConta    := "347784    "
			cSubConta := "001"
		ElseIf Alltrim(SM0->M0_CODIGO)=="MQ"    // DIRECTA AUDITORES 
			cBanco    := "341"                  // Adicionado para soluça?do chamado 016897 
			cAgencia  := "0262 "
			cConta    := "116080    "
			cSubConta := "001"	
		ElseIf Alltrim(SM0->M0_CODIGO)=="MY"    // DIRECTA CONSULTORIA FISCAL E SOCIETÁRIA
			cBanco    := "341"					// Adicionado para soluça?do chamado 016897
			cAgencia  := "0262 "
			cConta    := "115983    "
			cSubConta := "001"	
		ElseIf Alltrim(SM0->M0_CODIGO)=="MP"    // DIRECTA SERVICES 
			cBanco    := "341"                  // Adicionado para soluça?do chamado 016897
			cAgencia  := "0262 "
			cConta    := "615339    "
			cSubConta := "001"	
		ElseIf Alltrim(SM0->M0_CODIGO)=="MW"    // DIRECTA AVALIAÇÃOES 
			cBanco    := "341"                  // Adicionado para soluça?do chamado 016897
			cAgencia  := "0262 "
			cConta    := "116031    "
			cSubConta := "001"	
		ElseIf Alltrim(SM0->M0_CODIGO)=="ZP"    // GESTAO 
			cBanco    := "341"
			cAgencia  := "0190 "
			cConta    := "296103    "
			cSubConta := "001"	
		ElseIf Alltrim(SM0->M0_CODIGO)=="99"    // teste
			cBanco    := "341"
			cAgencia  := "0190 "
			cConta    := "385609    "
			cSubConta := "001"	 
  		ElseIf Alltrim(SM0->M0_CODIGO)=="8F" 
				cBanco    := "341"
				cAgencia  := "2938 "
				cConta    := "291818    "       //JSS - Para realizar o tratamento da KPMG dividindo o valor.
				cSubConta := "001"	  		
  		ElseIf Alltrim(SM0->M0_CODIGO)=="ZA"    //GT ASSESSORIA
				cBanco    := "341"				//AOA 15/02/2016 - Inclusão da empresa ZA dados para boleto chamado: 031948
				cAgencia  := "2938 "
				cConta    := "308935    "       
				cSubConta := "001"	 
		ElseIf Alltrim(SM0->M0_CODIGO)=="ZF" .AND. SE1->E1_EMISSAO > STOD('20161009') //AOA - 09/11/2016 - Inclusão da empresa ZF conforme chamado 037116
				cBanco    := "341"
				cAgencia  := "2938 "
				cConta    := "343072    "   
				cSubConta := "001"	  				 		
   		EndIf
    
		if lSelAuto
      		If Alltrim(SM0->M0_CODIGO)=="Z4" .And. MV_PAR05 == 2    // KPMG
				cBanco    := "341"
				cAgencia  := "2938 "
				cConta    := "221880    "       //JSS - Para realizar o tratamento da KPMG dividindo o valor.
				cSubConta := "001"	  	
			endif
        endif 
        
	Endif
  
	//Alterado MSM - 27/07/2012
	if MV_PAR04==1
	    oPrint  := TMSPrinter():New("Boleto Laser")
		oPrint:SetPortrait ( )			// Seta o relatório como retrato
		oPrint:SetPaperSize(9)			// Seta para papel A4
		oPrint:StartPage()				// Inicia uma nova pagina
	endif
	// Posicione parametros bancarios
	//dbSelectArea("SEE")
	//dbSetOrder(1)
	//dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubConta,.T.)

	//MSM - 28/02/2013 - Verifica qual ?a subconta de remessa    
	cQry:=" SELECT EE_SUBCTA FROM "+RETSQLNAME("SEE")
	cQry+=" WHERE EE_FILIAL='"+xFilial("SEE")+"' AND D_E_L_E_T_=''"
	cQry+=" AND EE_CODIGO='"+cBanco+"'"
	cQry+=" AND EE_AGENCIA='"+cAgencia+"'"
	cQry+=" AND EE_CONTA='"+cConta+"'"
	cQry+=" AND (EE_OPER LIKE '%REM%' OR EE_EXTEN = 'REM')"
    
	if select("QUERYTRB")>0
		QUERYTRB->(DbCloseArea())
	endif
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QUERYTRB",.T.,.T.)

	COUNT TO nRecCount
	
	if nRecCount>0
		QUERYTRB->(DbGotop())
		cSubConta:=QUERYTRB->EE_SUBCTA
    else
        SE1->(dbSkip())
        Loop		
	endif

	cPortGrv    := SE1->E1_PORTADO
	cAgeGrv     := SE1->E1_AGEDEP
	cContaGrv   := SE1->E1_CONTA
	cSubConta   := If(Empty(cSubConta),"001",cSubConta)

	// Posiciona o SA6 (Bancos)
	dbSelectArea("SA6")
	dbSetOrder(1)
	dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta,.T.)

	aDadosBanco := {SA6->A6_COD ,;								// SA6->A6_COD //[1]Numero do Banco
	"BANCO ITAU SA",;										    // [2]Nome do Banco
	SUBSTR(SA6->A6_AGENCIA,1,4),;								// [3]Agencia
	SUBSTR(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1),;	// [4]Conta Corrente
	SUBSTR(SA6->A6_NUMCON,Len(AllTrim(SA6->A6_NUMCON)),1),;	    // [5]Digito da conta corrente
	SA6->A6_CARTEIR}     										// [6]Codigo da Carteira

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
  //	IF EMPTY(SA1->A1_ENDCOB) .And. EMPTY(SA1->A1_BAIRROC) .And. EMPTY(SA1->A1_MUNC) .AND. EMPTY(SA1->A1_CEPC)
		aDatSacado := {	AllTrim(SA1->A1_NOME),;						// [1]Razao Social
		AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA,;						// [2]Codigo
		AllTrim(SA1->A1_END)+" - "+AllTrim(SA1->A1_BAIRRO),;		// [3]Endereco
		AllTrim(SA1->A1_MUN),;										// [4]Cidade
		SA1->A1_EST,;												// [5]Estado
		SA1->A1_CEP,;												// [6]CEP
		SA1->A1_CGC}												// [7]CGC
	//ELSE
	//	aDatSacado := {	AllTrim(SA1->A1_NOME),;									// [1]Razao Social
	//	AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA,;								// [2]Codigo
	//	AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),; 					// [3]Endereco
	//	AllTrim(SA1->A1_MUNC),;													// [4]Cidade
	//	SA1->A1_ESTC,;															// [5]Estado
	//	SA1->A1_CEPC,;															// [6]CEP
	 //	SA1->A1_CGC}															// [7]CGC
	//ENDIF
    dbSelectArea("SE1")	

	_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

     dbSelectArea("SE1")
	_nRecSE1  := recno()

	IF EMPTY(SE1->E1_NUMBCO)
		dbSelectArea("SEE")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("SEE")+aDadosBanco[1]+aDadosBanco[3]+" "+aDadosBanco[4]+aDadosBanco[5]+space(4)+cSubConta)
			RecLock("SEE",.F.)
			//cNroDoc			:= SUBSTR(AllTrim (SEE->EE_FAXATU),5,8) 
			cNroDoc			:= SUBSTR(AllTrim (SEE->EE_FAXATU),(LEN(AllTrim(SEE->EE_FAXATU))-7),8)
			SEE->EE_FAXATU	:= Soma1(Alltrim(SEE->EE_FAXATU))
			MsUnLock()
		EndIf
		
		DbSelectArea("SE1")
		RecLock("SE1",.f.)
		SE1->E1_NUMBCO 	:=	cNroDoc   // Nosso número (Ver fórmula para calculo)
		SE1->E1_PORTADO := SA6->A6_COD
		SE1->E1_AGEDEP  := SA6->A6_AGENCIA
		SE1->E1_CONTA   := SA6->A6_NUMCON
		MsUnlock()
	ElseIf SE1->E1_PORTADO <> SA6->A6_COD .OR. SE1->E1_CONTA <> SA6->A6_NUMCON // GFP - 18/01/2017 - Verifica se o banco já gravado no titulo é o mesmo do boleto atual
		If SE1->E1_PORTADO $ "341"
			cBancPort := "Itau"
		Else
			cBancPort := "outra conta"
		EndIf 
		MsgStop("Nosso número gerado para "+cBancPort+".","Grant Thornton" ) 
		Return .F.
	Else
		cNroDoc 	:= ALLTRIM(SE1->E1_NUMBCO)
	EndIf
	DbSelectArea("SE1")
	dbGoTo(_nRecSE1)
	
	CB_RN_NN := Ret_cBarra(aDadosBanco[1],aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],cNroDoc,(E1_VALOR-_nVlrAbat),E1_VENCREA,aDadosBanco[6])
	
	aDadosTit := {	AllTrim(E1_NUM)+AllTrim(E1_PARCELA),;	        // [1] Numero do Titulo
	E1_EMISSAO,;						                			// [2] Data da Emissao do Titulo
	Date(),;								                		// [3] Data da Emissao do Boleto
	E1_VENCREA,;										            // [4] Data do Vencimento
	(E1_SALDO - _nVlrAbat),;					                	// [5] Valor do Titulo
	CB_RN_NN[3],;	                                                // [6] Nosso Numero (Ver Formula para Calculo)
	E1_PREFIXO,;													// [7] Prefixo da NF
	"DM"}//E1_TIPO}														// [8] Tipo do Titulo
			
	// Faz o tratamento das Mensagens que serão impressas no boleto
	//aBolText := {"","","","",""}
	
	//aBolText[3] := ""//"NÃO RECEBER APÓS 30 DIAS DO VENCIMENTO. "
	//aBolText[4]	:= ""	//MV_PAR21
	//aBolText[5]	:= ""	//MV_PAR22
	
	//If Marked("E1_OK")            
	IncProc(SE1->E1_PREFIXO+"-"+SE1->E1_NUM)

	Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
	n := n + 1
	//ENDIF

    //Alterado MSM - 27/07/2012
	Ms_Flush ()	
	if MV_PAR04==1
		nI := nI + 1
		cFileODF := "\Arquivos\boletos\"+"BOLETO-"+cEmpAnt+"_"+alltrim(SE1->E1_PREFIXO)+alltrim(SE1->E1_NUM)+alltrim(SE1->E1_PARCELA)+".html"
		oPrint:SaveAsHTML( cFileODF, {1} )		
		oOk		:= LoadBitmap( GetResources(), "LBOK")
		
		
		//MSM - 20/03/2015 - Chamado: 025092, para adicionar o sócio e gerente responsável da proposta que originou este título na cópia do e-mail.
		if cEmpAnt $ "ZB/ZF"
			
			cQrySoc:=" SELECT ISNULL(Z55_SOCIO,'') AS Z55_SOCIO,ISNULL(Z42SOC.Z42_IDUSER,'') AS 'SOCIO',ISNULL(Z55_GERENT,'') AS Z55_GERENT,ISNULL(Z42GER.Z42_IDUSER,'') AS 'GERENTE' FROM "+RETSQLNAME("Z55")+" Z55
			cQrySoc+=" LEFT JOIN "+RETSQLNAME("Z42")+" Z42SOC ON Z42SOC.Z42_CPF = Z55.Z55_SOCIO AND Z42SOC.D_E_L_E_T_=''
			cQrySoc+=" LEFT JOIN "+RETSQLNAME("Z42")+" Z42GER ON Z42GER.Z42_CPF = Z55.Z55_GERENT AND Z42GER.D_E_L_E_T_=''
			cQrySoc+=" WHERE Z55.D_E_L_E_T_='' AND Z55.Z55_REVATU= '' AND Z55.Z55_FILORI+Z55.Z55_NUM =
			cQrySoc+=" (
			
			cQrySoc+=" 	SELECT CASE C5_P_NUM WHEN '' THEN CN9_FILIAL+CN9_P_NUM ELSE C5_FILIAL+C5_P_NUM END FROM "+RETSQLNAME("SC5")+" SC5
			cQrySoc+=" 	LEFT JOIN "+RETSQLNAME("CN9")+" CN9 ON CN9.D_E_L_E_T_='' AND CN9_NUMERO = SC5.C5_MDCONTR AND CN9.CN9_FILIAL = SC5.C5_FILIAL AND CN9.CN9_REVATU=''
			cQrySoc+=" 	WHERE SC5.D_E_L_E_T_='' AND SC5.C5_NUM='"+SE1->E1_PEDIDO+"' AND SC5.C5_FILIAL = '"+SE1->E1_FILORIG+"' "
			
			cQrySoc+=" )
			
			if !TCSQLExec(cQrySoc) < 0
			
				if select("QRYEMA")>0
					QRYEMA->(DbCloseArea())
				endif
					
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySoc),"QRYEMA",.T.,.T.)
				
				COUNT TO nRecCount
					
				if nRecCount>0
					QRYEMA->(DbGoTop())
	
					cEmaSoc:= alltrim(UsrRetMail(QRYEMA->SOCIO))
				    
				    if !empty(cEmaSoc) .AND. !empty(alltrim(UsrRetMail(QRYEMA->GERENTE)))
				    	cEmaSoc+=";"+alltrim(UsrRetMail(QRYEMA->GERENTE))
				    else
				    	cEmaSoc+=alltrim(UsrRetMail(QRYEMA->GERENTE))
				    endif
				    
				endif
            endif
                /*
				if SA1->(FieldPos("A1_P_SOCIO"))>0
					DbSelectArea("Z42")
					Z42->(DbSetOrder(2))
						if DbSeek(xFilial("Z42")+SA1->A1_P_SOCIO)
							cEmaSoc:= alltrim(UsrRetMail(Z42->Z42_IDUSER))
						endif
				endif
			    */
		endif

		cEmailsCp:=Alltrim(SA1->A1_P_EMAIL)
		if !empty(cEmailsCp) .AND. !empty(cEmaSoc)
        	cEmailsCp+=";"+cEmaSoc
        else
        	cEmailsCp+=cEmaSoc
        endif
        
		
		//AADD(aCols,{oOk,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_VALOR,SE1->E1_CLIENTE,AllTrim(SA1->A1_NOME),Alltrim(SA1->A1_P_EMAIC),"\Arquivos\boletos\"+cEmpAnt+"_"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+".html","",.F.})
		AADD(aCols,{oOk,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_VALOR,SE1->E1_CLIENTE,AllTrim(SA1->A1_NOME),Alltrim(SA1->A1_P_EMAIC),"\Arquivos\boletos\"+"BOLETO-"+cEmpAnt+"_"+alltrim(SE1->E1_PREFIXO)+alltrim(SE1->E1_NUM)+alltrim(SE1->E1_PARCELA)+".html","",.F.})
		AADD(aAuxAcols,{cEmailsCp,SE1->E1_EMISSAO})
    endif
        
	DbSelectArea("SE1")
	SE1->(dbSkip())
	IncProc()
	    
	//Ms_Flush ()
EndDo

/*Alterado MSM - 27/07/2012*/
if MV_PAR04==1
	U_GTCORP32(aCols,aAuxAcols)
else
	oPrint:Preview ()
	Ms_Flush ()
endif
	
RETURN nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±?Funcao    ?IMPRESS()   ?Autor ?Flavio Novaes    ?Data ?03/02/2005 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Descricao ?Impressao de Boleto Bancario do Banco Santander com Codigo ³±?
±±?          ?de Barras, Linha Digitavel e Nosso Numero.                 ³±?
±±?          ?Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso       ?FINANCEIRO                                                 ³±?
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
//RRP - 17/05/2013 Tratamento para Acrescimo e Decrescimo
Local nValor   := aDadosTit[5]-SE1->E1_DECRESC+SE1->E1_ACRESC   

// Parâmetros de TFont.New()
// 1.Nome da Fonte (Windows)
// 3.Tamanho em Pixels
// 5.Bold (T/F)
oFont8  := TFont():New("Arial",9,08,.T.,.F.,5,.T.,5,.T.,.F.)
//oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12n:= TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n:= TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24 := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
oBrush  := TBrush():New("",4)

//alterado MSM - 27/07/2012
//if MV_PAR04==2
	oPrint:StartPage()	// Inicia uma nova Pagina
//endif

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
//SayBitmap(nRow,nCol,cBitmap,nWidth,nHeight,nRaster)         
//oPrint:SayBitmap(0045,0045,aBmp[1],0150,0095)					// [2] Logo do Banco
oPrint:Say (0084,0100,aDadosBanco[2],oFont16)					// [2] Nome do Banco
oPrint:Say (0062,0567,aDadosBanco[1]+"-7",oFont24)					// [1] Numero do Banco
oPrint:Say (0084,1870,"Comprovante de Entrega",oFont10)
oPrint:Line(0150,0100,0150,2300)
oPrint:Say (0150,0100,"Beneficiário",oFont8)
If cCodBanco ='637'
	oPrint:Say (0200,0100,"Banco Sofisa S/A",oFont10)					// [1] Nome + CNPJ
Else
	oPrint:Say (0200,0100,aDadosEmp[1]	,oFont10)					// [1] Nome + CNPJ
EndIf
oPrint:Say (0150,1060,"Agência/Código Beneficiário",oFont8)
oPrint:Say (0200,1060,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10)
oPrint:Say (0150,1510,"Nro.Documento",oFont8)
oPrint:Say (0200,1510,aDadosTit[7]+aDadosTit[1],oFont10)  // [7] Prefixo + [1] Numero + Parcela
oPrint:Say (0250,0100,"Pagador",oFont8)
oPrint:Say (0300,0100,aDatSacado[1],oFont10)					// [1] Nome
oPrint:Say (0250,1060,"Vencimento",oFont8)
oPrint:Say (0300,1060,STRZERO(day(aDadosTit[4],2),2)+"/"+STRZERO(month(aDadosTit[4],2),2)+"/"+STRZERO(year(aDadosTit[4],4),4),oFont10)
//cString := STRZERO(day(aDadosTit[4],2),2)+"/"+STRZERO(month(aDadosTit[4],2),2)+"/"+STRZERO(year(aDadosTit[4],4),4)
//nCol 	 := 1900+(374-(len(cString)*22))
//oPrint:Say (0300,nCol,cString,oFont10)

oPrint:Say (0250,1510,"Valor do Documento",oFont8)
oPrint:Say (0300,1550,AllTrim(Transform(nValor,"@E 999,999,999.99")),oFont10)
//cString := AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99"))
//nCol 	 := 1900+(374-(len(cString)*22))
//oPrint:Say (0300,nCol,cString,oFont10)

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
oPrint:Say (0230,1910,"(  )Não existe n?indicado",oFont8)
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
//oPrint:SayBitmap(_nLin+0600,0005,aBmp[1],085,110)	// [2] Logo do Banco
oPrint:Say (_nLin+0644,0100,aDadosBanco[2],oFont16)	// [2]Nome do Banco
oPrint:Say (_nLin+0622,0567,aDadosBanco[1]+"-7",oFont24)	// [1]Numero do Banco
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
oPrint:Say (_nLin+0750,0100,"ATE O VENCIMENTO PAGUE PREFERENCIALMENTE NO ITAU",oFont8)
oPrint:Say (_nLin+0775,0100,"APOS O VENCIMENTO PAGUE SOMENTE NO ITAU",oFont8)
oPrint:Say (_nLin+0710,1910,"Vencimento",oFont8)
//oPrint:Say (_nLin+0750,1950,STRZERO(DAY(aDadosTit[4],2),2)+"/"+STRZERO(MONTH(aDadosTit[4],2),2)+"/"+STRZERO(YEAR(aDadosTit[4],2),4),oFont10) 
cString := STRZERO(day(aDadosTit[4],2),2)+"/"+STRZERO(month(aDadosTit[4],2),2)+"/"+STRZERO(year(aDadosTit[4],4),4)
nCol 	 := 1900+(374-(len(cString)*22))
oPrint:Say (_nLin+0750,nCol,cString,oFont10)

oPrint:Say (_nLin+0810,0100,"Beneficiário",oFont8)
If cCodBanco ='637'
	oPrint:Say (_nLin+0845,0100,"Banco Sofisa S/A",oFont10) //Nome + CNPJ 
Else
	oPrint:Say (_nLin+0835,0100,aDadosEmp[1]+"     - "+aDadosEmp[6],oFont10) //Nome + CNPJ 
	oPrint:Say (_nLin+0870,0100,AllTrim(aDadosEmp[2])+" "+AllTrim(aDadosEmp[3])+" "+AllTrim(aDadosEmp[4]),oFont10) //Nome + CNPJ
EndIf
oPrint:Say (_nLin+0810,1910,"Agência/Código Beneficiário",oFont8)
//oPrint:Say (_nLin+0850,1950,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10)
cString   := aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]
nCol   	  := 1900+(374-(len(cString)*22))
oPrint:Say (_nLin+0850,nCol,cString,oFont10)

oPrint:Say (_nLin+0910,0100,"Data do Documento",oFont8)
oPrint:Say (_nLin+0940,0100,STRZERO(day(aDadosTit[2],2),2)+"/"+STRZERO(month(aDadosTit[2],2),2)+"/"+STRZERO(year(aDadosTit[2],4),4),oFont10) // Emissao do Titulo (E1_EMISSAO)
oPrint:Say (_nLin+0910,0505,"Nro.Documento",oFont8)
oPrint:Say (_nLin+0940,0605,aDadosTit[7]+" "+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela
oPrint:Say (_nLin+0910,1005,"Espécie Doc.",oFont8)
oPrint:Say (_nLin+0940,1050,aDadosTit[8],oFont10) //Tipo do Titulo
oPrint:Say (_nLin+0910,1355,"Aceite",oFont8)
oPrint:Say (_nLin+0940,1455,"N",oFont10)
oPrint:Say (_nLin+0910,1555,"Data do Processamento",oFont8)
oPrint:Say (_nLin+0940,1655,STRZERO(DAY(aDadosTit[3],2),2)+"/"+STRZERO(MONTH(aDadosTit[3],2),2)+"/"+STRZERO(YEAR(aDadosTit[3],2),4),oFont10) // Data impressao
oPrint:Say (_nLin+0910,1910,"Nosso Número",oFont8)
//oPrint:Say (_nLin+0940,1950,aDadosbanco[6]+"/"+SUBSTR(aDadosTit[6],1,8)+"-"+SUBSTR(aDadosTit[6],9,1),oFont10)
cString   := aDadosbanco[6]+"/"+SUBSTR(aDadosTit[6],1,8)+"-"+SUBSTR(aDadosTit[6],9,1)
nCol   	  := 1900+(374-(len(cString)*22))
oPrint:Say (_nLin+0940,nCol,cString,oFont10)

//oPrint:Say (_nLin+0940,1950,aDadosTit[6],oFont10)
oPrint:Say (_nLin+0980,0100,"Uso do Banco",oFont8)
oPrint:Say (_nLin+0980,0505,"Carteira",oFont8)
oPrint:Say (_nLin+1010,0555,aDadosBanco[6],oFont10)
oPrint:Say (_nLin+0980,0755,"Espécie",oFont8)
oPrint:Say (_nLin+1010,0805,"R$",oFont10)
oPrint:Say (_nLin+0980,1005,"Quantidade",oFont8)
oPrint:Say (_nLin+0980,1555,"Valor",oFont8)
oPrint:Say (_nLin+0980,1910,"Valor do Documento",oFont8)
//oPrint:Say (_nLin+1010,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
cString   := AllTrim(Transform(nValor,"@E 999,999,999.99"))
nCol   	  := 1900+(374-(len(cString)*22))
oPrint:Say (_nLin+1010,nCol,cString,oFont10)
oPrint:Say (_nLin+1050,0100,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont8)
oPrint:Say (_nLin+1150,0100,aBolText[1]+" "+AllTrim(Transform((aDadosTit[5]*0.02),"@E 99,999.99")),oFont10) 

//oPrint:Say (_nLin+1200,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.05)/30),"@E 99,999.99")),oFont10)
//JSS - ALTERADO PARA SOLUCIONAR O CHAMADO 019604 
If Alltrim(SM0->M0_CODIGO)$("Z4/CH/PN/MP/MQ/MW/MY/RH/Z8/ZP/") 	
	oPrint:Say (_nLin+1200,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.02)/30),"@E 99,999.99")),oFont10)
Else 
   Alltrim(SM0->M0_CODIGO)$("ZB/ZF/") 
	oPrint:Say (_nLin+1200,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.02)/30),"@E 99,999.99")),oFont10)
EndIf

oPrint:Say (_nLin+1250,0100,aBolText[3],oFont10)
oPrint:Say (_nLin+1050,1910,"(-)Desconto/Abatimento",oFont8)
oPrint:Say (_nLin+1120,1910,"(-)Outras Deduções",oFont8)
oPrint:Say (_nLin+1190,1910,"(+)Mora/Multa",oFont8)
oPrint:Say (_nLin+1260,1910,"(+)Outros Acréscimos",oFont8)
oPrint:Say (_nLin+1330,1910,"(=)Valor Cobrado",oFont8)
oPrint:Say (_nLin+1400,0100,"Pagador",oFont8)
oPrint:Say (_nLin+1400,0400,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont10)
oPrint:Say (_nLin+1430,0400,aDatSacado[3],oFont10)
oPrint:Say (_nLin+1483,0400,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado
oPrint:Say (_nLin+1536,0400,"CGC: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
//oPrint:Say (_nLin+1589,1950,aDadosBanco[6]+"/"+SUBSTR(aDadosTit[6],1,8)+"-"+SUBSTR(aDadosTit[6],9,1),oFont10)
//oPrint:Say (_nLin+1589,1950,"00"+SUBSTR(aDadosTit[6],4,8),oFont10)
oPrint:Say (_nLin+1605,0100,"Sacador/Avalista",oFont8)
If cCodBanco ='637'
	oPrint:Say (_nLin+1600,0400,aDadosEmp[1]+"         - "+aDadosEmp[6],oFont10)
EndIf
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
//oPrint:SayBitmap(_nLin+1900,0005,aBmp[1],085,110)					// [2] LOGO do Banco
oPrint:Say (_nLin+1934,0100,aDadosBanco[2],oFont16)	// [2] Nome do Banco
oPrint:Say (_nLin+1912,0567,aDadosBanco[1]+"-7",oFont24)	// [1] Numero do Banco
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
oPrint:Say (_nLin+2040,0100,"ATE O VENCIMENTO PAGUE PREFERENCIALMENTE NO ITAU",oFont8)
oPrint:Say (_nLin+2065,0100,"APOS O VENCIMENTO PAGUE SOMENTE NO ITAU",oFont8)
oPrint:Say (_nLin+2000,1910,"Vencimento",oFont8)
//oPrint:Say (_nLin+2040,1950,STRZERO(DAY(aDadosTit[4],2),2)+"/"+STRZERO(MONTH(aDadosTit[4],2),2)+"/"+STRZERO(YEAR(aDadosTit[4],2),4),oFont10)
cString := STRZERO(day(aDadosTit[4],2),2)+"/"+STRZERO(month(aDadosTit[4],2),2)+"/"+STRZERO(year(aDadosTit[4],4),4)
nCol 	 := 1900+(374-(len(cString)*22))
oPrint:Say (_nLin+2040,nCol,cString,oFont10)

oPrint:Say (_nLin+2100,0100,"Beneficiário",oFont8)
If cCodBanco ='637'
	oPrint:Say (_nLin+2135,0100,"Banco Sofisa S/A",oFont10) //Nome + CNPJ 
Else
	oPrint:Say (_nLin+2125,0100,aDadosEmp[1]+"         - "+aDadosEmp[6],oFont10) //Nome + CNPJ   
	oPrint:Say (_nLin+2160,0100,AllTrim(aDadosEmp[2])+" "+AllTrim(aDadosEmp[3])+" "+AllTrim(aDadosEmp[4]),oFont10) //Nome + CNPJ
EndIf
oPrint:Say (_nLin+2100,1910,"Agência/Código Beneficiário",oFont8)
//oPrint:Say (_nLin+2140,1950,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10)
cString   := aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]
nCol   	  := 1900+(374-(len(cString)*22))
oPrint:Say (_nLin+2140,nCol,cString,oFont10)

oPrint:Say (_nLin+2200,0100,"Data do Documento",oFont8)
oPrint:Say (_nLin+2230,0100,STRZERO(DAY(aDadosTit[2],2),2)+"/"+STRZERO(MONTH(aDadosTit[2],2),2)+"/"+STRZERO(YEAR(aDadosTit[2],2),4),oFont10)			// Emissao do Titulo (E1_EMISSAO)
oPrint:Say (_nLin+2200,0505,"Nro.Documento",oFont8)
oPrint:Say (_nLin+2230,0605,aDadosTit[7]+" "+aDadosTit[1],oFont10)	//Prefixo + Numero + Parcela
oPrint:Say (_nLin+2200,1005,"Espécie Doc.",oFont8)
oPrint:Say (_nLin+2230,1050,aDadosTit[8],oFont10)					//Tipo do Titulo
oPrint:Say (_nLin+2200,1355,"Aceite",oFont8)
oPrint:Say (_nLin+2230,1455,"N",oFont10)
oPrint:Say (_nLin+2200,1555,"Data do Processamento",oFont8)
oPrint:Say (_nLin+2230,1655,STRZERO(DAY(aDadosTit[3],2),2)+"/"+STRZERO(MONTH(aDadosTit[3],2),2)+"/"+STRZERO(YEAR(aDadosTit[3],2),4),oFont10) // Data impressao
oPrint:Say (_nLin+2200,1910,"Nosso Número",oFont8)
//oPrint:Say (_nLin+2230,1950,aDadosBanco[6]+"/"+SUBSTR(aDadosTit[6],1,8)+"-"+SUBSTR(aDadosTit[6],9,1),oFont10)
cString   := aDadosbanco[6]+"/"+SUBSTR(aDadosTit[6],1,8)+"-"+SUBSTR(aDadosTit[6],9,1)
nCol   	  := 1900+(374-(len(cString)*22))
oPrint:Say (_nLin+2230,nCol,cString,oFont10)

//oPrint:Say (_nLin+2230,1950,SUBSTR(aDadosTit[6],4),oFont10)
oPrint:Say (_nLin+2270,0100,"Uso do Banco",oFont8)
oPrint:Say (_nLin+2270,0505,"Carteira",oFont8)
oPrint:Say (_nLin+2300,0555,aDadosBanco[6],oFont10)
oPrint:Say (_nLin+2270,0755,"Espécie",oFont8)
oPrint:Say (_nLin+2300,0805,"R$",oFont10)
oPrint:Say (_nLin+2270,1005,"Quantidade",oFont8)
oPrint:Say (_nLin+2270,1555,"Valor",oFont8)
oPrint:Say (_nLin+2270,1910,"Valor do Documento",oFont8)
//oPrint:Say (_nLin+2300,1950,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
cString   := AllTrim(Transform(nValor,"@E 999,999,999.99"))
nCol   	  := 1900+(374-(len(cString)*22))
oPrint:Say (_nLin+2300,nCol,cString,oFont10)

oPrint:Say (_nLin+2340,0100,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont8)
oPrint:Say (_nLin+2440,0100,aBolText[1]+" "+AllTrim(Transform((aDadosTit[5]*0.02),"@E 99,999.99")),oFont10)

//oPrint:Say (_nLin+2490,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.05)/30),"@E 99,999.99")),oFont10)
//JSS - ALTERADO PARA SOLUCIONAR O CHAMADO 019604 
If Alltrim(SM0->M0_CODIGO)$("Z4/CH/PN/MP/MQ/MW/MY/RH/Z8/ZP/") 	
	oPrint:Say (_nLin+2490,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.02)/30),"@E 99,999.99")),oFont10)
Else 
   Alltrim(SM0->M0_CODIGO)$("ZB/ZF/") 
	oPrint:Say (_nLin+2490,0100,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.02)/30),"@E 99,999.99")),oFont10)
EndIf

oPrint:Say (_nLin+2540,0100,aBolText[3],oFont10)
oPrint:Say (_nLin+2340,1910,"(-)Desconto/Abatimento",oFont8)
oPrint:Say (_nLin+2410,1910,"(-)Outras Deduções",oFont8)
oPrint:Say (_nLin+2480,1910,"(+)Mora/Multa",oFont8)
oPrint:Say (_nLin+2550,1910,"(+)Outros Acréscimos",oFont8)
oPrint:Say (_nLin+2620,1910,"(=)Valor Cobrado",oFont8)
oPrint:Say (_nLin+2690,0100,"Pagador",oFont8)
oPrint:Say (_nLin+2690,0400,aDatSacado[1]+" ("+aDatSacado[2]+")",oFont10)
oPrint:Say (_nLin+2720,0400,aDatSacado[3],oFont10)
oPrint:Say (_nLin+2773,0400,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10)	// CEP+Cidade+Estado
oPrint:Say (_nLin+2826,0400,"CGC: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10)	// CGC
//oPrint:Say (_nLin+2879,1950,aDadosBanco[6]+"/"+SUBSTR(aDadosTit[6],1,8)+"-"+SUBSTR(aDadosTit[6],9,1),oFont10)
//oPrint:Say (_nLin+2879,1950,"00"+SUBSTR(aDadosTit[6],4,8),oFont10)
oPrint:Say (_nLin+2895,0100,"Sacador/Avalista",oFont8)
If cCodBanco ='637'
	oPrint:Say (_nLin+2890,0400,aDadosEmp[1]+"         - "+aDadosEmp[6],oFont10)
EndIf
oPrint:Say (_nLin+2935,1500,"Autenticação Mecânica -",oFont8)
oPrint:Say (_nLin+2935,1850,"Ficha de Compensação",oFont10)
oPrint:Line(_nLin+2000,1900,_nLin+2690,1900)
oPrint:Line(_nLin+2410,1900,_nLin+2410,2300)
oPrint:Line(_nLin+2480,1900,_nLin+2480,2300)
oPrint:Line(_nLin+2550,1900,_nLin+2550,2300)
oPrint:Line(_nLin+2620,1900,_nLin+2620,2300)
oPrint:Line(_nLin+2690,0100,_nLin+2690,2300)
oPrint:Line(_nLin+2930,0100,_nLin+2930,2300)

//Alterado MSM - 27/07/2012
if MV_PAR04==2
	MSBAR("INT25"  ,27.8,1.5,CB_RN_NN[1],oPrint,.F.,,,,1.4,,,,.F.)
else
	//Na produção deixando como 27.8 cm o código sai na posição correta, na maquina local precisei colocar 13,8 cm para sair no local correto
	//MSBAR("INT25"  ,13.8,0.4,CB_RN_NN[1],oPrint,.F.,,,,1.4,,,,.F.)
	MSBAR("INT25"  ,27.8,1.5,CB_RN_NN[1],oPrint,.F.,,,,1.4,,,,.F.)
endif

/*
±±³Parametros?01 cTypeBar String com o tipo do codigo de barras           ³±?
±±?         ?				"EAN13","EAN8","UPCA" ,"SUP5"   ,"CODE128"     ³±?
±±?         ?				"INT25","MAT25,"IND25","CODABAR","CODE3_9"     ³±?
±±?         ?				"EAN128"                                       ³±?
±±?         ?02 nRow		Numero da Linha em centimentros                ³±?
±±?         ?03 nCol		Numero da coluna em centimentros			   ³±?
±±?         ?04 cCode		String com o conteudo do codigo                ³±?
±±?         ?05 oPr		Obejcto Printer                                ³±?
±±?         ?06 lcheck	Se calcula o digito de controle                ³±?
±±?         ?07 Cor 		Numero  da Cor, utilize a "common.ch"          ³±?
±±?         ?08 lHort		Se imprime na Horizontal                       ³±?
±±?         ?09 nWidth	Numero do Tamanho da barra em centimetros      ³±?
±±?         ?10 nHeigth	Numero da Altura da barra em milimetros        ³±?
±±?         ?11 lBanner	Se imprime o linha em baixo do codigo          ³±?
±±?         ?12 cFont		String com o tipo de fonte                     ³±?
±±?         ?13 cMode		String com o modo do codigo de barras CODE128  ³±?
±±?         ?14 lPrint	Logico que indica se imprime ou nao            ³±?
±±?         ?15 nPFWidth	Numero do indice de ajuste da largura da fonte ³±?
±±?         ?16 nPFHeigth Numero do indice de ajuste da altura da fonte  ³±?
*/

oPrint:EndPage ()
RETURN Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±?Funcao    ?MODULO10()  ?Autor ?Flavio Novaes    ?Data ?03/02/2005 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Descricao ?Impressao de Boleto Bancario do Banco Santander com Codigo ³±?
±±?          ?de Barras, Linha Digitavel e Nosso Numero.                 ³±?
±±?          ?Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso       ?FINANCEIRO                                                 ³±?
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
±±?Funcao    ?MODULO11()  ?Autor ?Flavio Novaes    ?Data ?03/02/2005 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Descricao ?Impressao de Boleto Bancario do Banco Santander com Codigo ³±?
±±?          ?de Barras, Linha Digitavel e Nosso Numero.                 ³±?
±±?          ?Baseado no Fonte TBOL001 de 01/08/2002 de Raimundo Pereira.³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso       ?FINANCEIRO                                                 ³±?
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
	IF P == 9
		P := 1
	ENDIF
	L := L - 1
ENDDO

D := (mod(D,11))

IF (D == 0 .Or. D == 1 .Or. D == 10 .or. D == 11)
	D := 1
ELSE
	D := 11 - (mod(D,11))	
ENDIF 


RETURN(D)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Programa  ³Ret_cBarra?Autor ?Microsiga             ?Data ?13/10/03 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ?IMPRESSAO DO BOLETO LASE DO ITAU COM CODIGO DE BARRAS      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Uso       ?Especifico para Clientes Microsiga                         ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto,cCarteira)
//Static Function Ret_cB    (cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor)

Local cCarteira    := alltrim(cCarteira)//"109"
LOCAL BlDocNuFinal := cAgencia + cConta + cCarteira + Strzero(val(cNroDoc),8)

//JSS - 24/02/2014 - Ajustado para solucionar o problema do chamado 017321
LOCAL _nVlrAbat    := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
LOCAL nValor       := SE1->E1_SALDO - _nVlrAbat

//RRP - 17/05/2013 - Tratamento para o Acrescimo e Decrescimo
LOCAL blvalorfinal := Strzero((nValor-SE1->E1_DECRESC+SE1->E1_ACRESC)*100,10)
LOCAL dvnn         := 0
LOCAL dvcb         := 0
LOCAL dv           := 0
LOCAL NN           := ''
LOCAL RN           := ''
LOCAL CB           := ''
LOCAL s            := ''
LOCAL cMoeda       := "9"
Local cFator       := Strzero(SE1->E1_VENCREA - ctod("07/10/1997"),4)       
  
	
//Carteira 112 s?aceita a carteira + a conta para o calculo do dígito
if cCarteira=="112"
	BlDocNuFinal:=cCarteira + Strzero(val(cNroDoc),8)
endif

//Montagem DAC do NOSSO NUMERO
snn   := BlDocNuFinal  // Nosso Numero
dvnn  := Alltrim(Str(modulo10(snn)))  //Digito verificador no Nosso Numero
cNN   := Strzero(val(cNroDoc),8) + dvnn 
                                         
//Montagem DAC do campo agencia+conta+carteira+nossonumero

if cCarteira=="112"//Carteira 112 s?aceita a carteira + a conta para o calculo do dígito
	cCod  := cCarteira + Strzero(val(cNroDoc),8)
else
	cCod  := cAgencia + cConta + cCarteira + Strzero(val(cNroDoc),8)
endif
dvCod := Alltrim(Str(modulo10(cCod)))    
     
//MONTAGEM DA LINHA DIGITAVEL 
// Montagem das DACs de Representacao Numerica do Codigo de Barras
//campo 1 
campo1  := cBanco + cMoeda + cCarteira + substr(cNN,1,2) 
dvC1    := Alltrim(Str(modulo10(campo1)))                                  
cCampo1 := campo1 + dvC1

// Montagem das DACs de Representacao Numerica do Codigo de Barras
//campo 2 
campo2  := substr(cNN,3,6) + dvCod + substr(cAgencia,1,3)  
dvC2    := Alltrim(Str(modulo10(campo2)))
cCampo2 := campo2 + dvC2   //+ substr(cNroDoc+dvnn,3,7)

// Montagem das DACs de Representacao Numerica do Codigo de Barras
//campo 3 
campo3  := substr(cAgencia,4,1) + cConta + cDacCC + "000" 
dvC3    := Alltrim(Str(modulo10(campo3)))
cCampo3 := campo3 + dvC3 //+ substr(cAgencia,4,1)

// Montagem das DACs do Codigo de Barras
//campo 4
campo4  := cBanco + cMoeda + cFator + blvalorfinal + cCarteira + cNroDoc+dvnn + cAgencia + cConta + cDacCC + "000"
cDacCB  := Alltrim(Str(Modulo11(campo4)))
cCampo4 := cDacCB

// Montagem 
//campo 5
cCampo5  := cFator + blvalorfinal
////////////////////////////////////////////////////////////////////////////

cCB      := cBanco + cMoeda + cDacCB + cFator + blvalorfinal + cCarteira + cNroDoc+dvnn + cAgencia + cConta + cDacCC + "000" // codigo de barras

////////////////////////////////////////////////////////////////////////////
//MONTAGEM DA LINHA DIGITAVEL 

cRN := substr(cCampo1,1,5)+"."+substr(cCampo1,6,5)+space(2)+ substr(cCampo2,1,5)+"."+substr(cCampo2,6,6)+space(2)+ substr(cCampo3,1,5)+"."+substr(cCampo3,6,6)+space(2) + cCampo4 + space(2)+ cCampo5 

Return({cCB,cRN,cNN})

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡…o    ?AjustaSx1    ?Autor ?Microsiga            	?Data ?13/10/03 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡…o ?Verifica/cria SX1 a partir de matriz para verificacao          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Uso       ?Especifico para Clientes Microsiga                    	  		³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
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
Return
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
//?Valida Banco     ?
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
