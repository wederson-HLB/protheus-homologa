#include "TOPCONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"  
#include "Protheus.ch"
#include "Rwmake.ch"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWBROWSE.CH"
/*
Funcao      : GTGEN021
Parametros  : 
Retorno     : 
Objetivos   : Integração de beneficios Sodexo.
Autor       : Jean Victor Rocha
Data/Hora   : 22/10/2013
*/
*----------------------*
User Function GTGEN021()
*----------------------*
LOCAL cFiltraSRA
LOCAL aIndexSRA	:= {}
Private bFiltraBrw := {|| Nil}
PRIVATE aRotina		:= MenuDef()
Private CCADASTRO	:= OemToAnsi("Grant Thornton Brasil - Sodexo")

If !ChkVazio("SRA")
	Alert("Não foi encontrado funcionarios para manutenção.","Grant Thornton Brasil.")
	Return
Endif

//Verifica consistencia das tabelas customizadas.
If !AUTOUPD()
	Alert("Tabelas Customizadas com inconsistência, entrar em contato com o Suporte!","Grant Thornton Brasil")
	Return
EndIf

cFiltraRh := ""
bFiltraBrw 	:= {|| FilBrowse("SRA",@aIndexSRA,@cFiltraRH) }
Eval(bFiltraBrw) 
	
dbSelectArea("SRA")
mBrowse( 6, 1,22,75,"SRA",,,,,,fCriaCor() )

Return .T.       

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*-----------------------*
Static Function MenuDef()
*-----------------------*
Local aRotAdic := {}
Local aRotina :=  { { "Pesquisar" 			,"AxPesqui"		, 0 , 1 },;
					{ "Visualizar" 			,"U_GEN021V"	, 0 , 4 },;
                    { "Calculo Beneficio"	,"U_GEN021C"	, 0 , 2 },;
                    { "Manutenção"			,"U_GEN021M"	, 0 , 2 },;
                    { "Evento Especial"		,"U_GEN021E"	, 0 , 2 },;
                    { "Gerar Arquivo"		,"U_GEN021A"	, 0 , 2 },;
                    { "Desconto em Folha"	,"U_GEN021G"	, 0 , 2 },;
                    { "Relatorio Benef."	,"U_GEN021R"	, 0 , 2 },;
                    { "Legenda"	  			,"GpLegend"  	, 0 , 6, NIL, .F.}}
Return aRotina 
    
/*
Funcao     : GEN021V
Parametros : Nenhum
Retorno    : 
Objetivos  : Rotina para Visualização dos valores de beneficios.
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*---------------------*
User Function GEN021V()
*---------------------*        
Local aLegenda := {	{"BR_VERDE"   ,"Registro Ativo"},;
		   		  	{"BR_VERMELHO","Registro Deletado"}} 
Local aButtons := {{"PMSCOLOR"	,{|| BrwLegenda(cCadastro, "Legenda", aLegenda)	}	,"Legenda"	   		,"Legenda"	   		,{|| .T.}}}
Local bCondic := {|| Z33_FILIAL == xFilial("Z33") .AND. Z33_MAT == SRA->RA_MAT}
Local cCondic := 'Z33_FILIAL == xFilial("Z33") .AND. Z33_MAT == SRA->RA_MAT'

Z33->(dbSelectArea("Z33"))
Z33->(dbSetOrder(1) )
Set Delete Off
Z33->(dbSetFilter(bCondic,cCondic))
Z33->(dbGotop())

aSize := MsAdvSize()

DEFINE MSDIALOG oDlgV TITLE "Beneficios - SODEXO" FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL

	oGrp1	:= TGroup():New( 004,004,024,080,"Matricula",oDlgV,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay1   := TSay():New( 014,008,{|| SRA->RA_MAT},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)

	oGrp2	:= TGroup():New( 004,084,024,(aSize[5]/2)-4,"Nome"		,oDlgV,CLR_BLACK,CLR_WHITE,.T.,.F. )                   
	oSay2   := TSay():New( 014,088,{|| SRA->RA_NOME},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,250,008)

	oBrw1	:= MsSelect():New( "Z33","","DELETED()",/*aCampos*/,.F.,,{028,004,(aSize[6]/2)-15,(aSize[5]/2)-4},,, oDlgV) 
	     	   
ACTIVATE MSDIALOG oDlgV ON INIT EnchoiceBar(oDlgV,{|| oDlgV:End()},{|| ( oDlgV:End())},,aButtons) CENTERED
              
Set Delete On           
Z33->(DBClearFilter())


Return .T.

/*
Funcao     : GEN021M
Parametros : Nenhum
Retorno    : 
Objetivos  : Rotina para Manutençaõ dos valores de beneficios Gerados.
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*---------------------*
User Function GEN021M()
*---------------------* 
Return InWizardMan()

/*
Funcao      : InWizardMan()  
Parametros  : 
Retorno     : 
Objetivos   : Wizard inicial Manutenção de Beneficios
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------*
Static Function InWizardMan()
*---------------------------*
Local lWizMan := .F.

Private oWizMan
Private nOpc := GD_DELETE+GD_UPDATE//+GD_INSERT
Private aCoBrw1 := {}
Private aHoBrw1 := {}
Private noBrw1  := 0

oWizMan := APWizard():New("Beneficios", ""/*<chMsg>*/, "Manutenção de Beneficios",;
													"- Na rotina de Manutenção é possível alterar benefícios que já foram gerados"+CRLF+;
													"através do Calculo de Benefícios, possibilitando as tratativas de exceções "+CRLF+;
													"e/ou ajustes específicos da área."+CRLF+;
													"Obs.: Esta rotina apresenta informações apenas da empresa Logada.",;
									 {||  .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,,,/*<.lNoFirst.>*/ )
          
//Painel 2
oWizMan:NewPanel( "Parametros", "Parametros para Manutenção dos Beneficios.",{ ||.T.}/*<bBack>*/, {|| (LoadaCols("MAN",@oBrw1,@oWizMan),.T.)}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

dDtRef	:= dDataBase

@ 010, 010 TO 125,280 OF oWizMan:oMPanel[2] PIXEL
oSBox1 := TScrollBox():New( oWizMan:oMPanel[2],009,009,124,279,.T.,.T.,.T. )

@ 21,20 SAY oSay0 VAR "Dt. Ref.? " SIZE 100,10 OF oSBox1 PIXEL
odDtRef:= TGet():New(20,85,{|u| if(PCount()>0,dDtRef:=u,dDtRef)},oSBox1,50,05,'@D 99/9999',{|o|},,,,,,.T.,,,,,,,,,	 ,'dDtRef')

//--> PANEL 3
oWizMan:NewPanel( "Manutenção", "",{ ||.F.}/*<bBack>*/,/*<bNext>*/, {|| lWizMan := .T.,.T.}/*<bFinish>*/, /*<.lPanel.>*/, /*<bExecute>*/ )

//Aadd(aHoBrw1je,{Trim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"ALLWAYSTRUE()",SX3->X3_USADO, SX3->X3_TIPO,SX3->X3_F3, SX3->X3_CONTEXT,SX3->X3_CBOX } )
Aadd(aHoBrw1,{"Matricula"	,"MAT"		,"@!"		,06,00,"GTGENVLD()"	,"","C","SRA"		,""})
Aadd(aHoBrw1,{"Nome"  		,"NOME" 	,"@!"		,20,00,""			,"","C",""			,""})
Aadd(aHoBrw1,{"Forn.Benef"	,"CFBENEF"	,"@!"		,03,00,"GTGENVLD()"	,"","C","BENEFF"	,""})
Aadd(aHoBrw1,{"Nome Forn."	,"NFBENEF"	,"@!"		,20,00,""			,"","C",""			,""})
Aadd(aHoBrw1,{"Cod.Benef."	,"CBENEF"	,"@!"		,05,00,"GTGENVLD()"	,"","C","BENEFB"	,""})
Aadd(aHoBrw1,{"Desc.Benef"	,"DBENEF"	,"@!"		,35,00,""			,"","C",""			,""})
Aadd(aHoBrw1,{"Dias"		,"NDIA"		,"@E 99"	,02,00,""			,"","N",""			,""})
Aadd(aHoBrw1,{"Valor"		,"VALOR"	,"@E 999.99",08,02,""			,"","N",""			,""})
Aadd(aHoBrw1,{"Data"		,"DATA"		,""  		,08,00,""			,"","D",""			,""})
Aadd(aHoBrw1,{"Rec"			,"RECZ33"	,""  		,15,00,""			,"","N",""			,""})
noBrw1:= Len(aHoBrw1)

aAlter := {"NDIA","VALOR","DATA"}
                                                                                                 
oGrp := TGroup():New( 004,004,134,296,"Manutenção",oWizMan:oMPanel[3],,,.T.,.F. )

oBrw1 := MsNewGetDados():New(012,008,130,292,nOpc,'AllwaysTrue()','AllwaysTrue()','',aAlter,0,999,'U_VldGEN021()','','AllwaysTrue()',oGrp,aHoBrw1,aCoBrw1 )

oWizMan:Activate( .T./*<.lCenter.>*/,/*<bValid>*/, /*<bInit>*/, /*<bWhen>*/ )

If lWizMan
	For b:=1 to Len(oBrw1:ACOLS)
		If !oBrw1:ACOLS[b][Len(oBrw1:ACOLS[b])]
			If oBrw1:ACOLS[b][Len(oBrw1:ACOLS[b])-1] <> 0//Posição do Recno
				Z33->(DbSetOrder(1))
				Z33->(DbGoTo(oBrw1:ACOLS[b][Len(oBrw1:ACOLS[b])-1]))
				Z33->(RecLock("Z33",.F.))
			Else
				Z33->(RecLock("Z33",.T.))
			EndIf   
			Z33->Z33_QTDE		:= oBrw1:ACOLS[b][7]
			Z33->Z33_VALOR		:= oBrw1:ACOLS[b][8]
			Z33->Z33_DATA		:= oBrw1:ACOLS[b][9]
			Z33->(MsUnlock())
		ElseIf oBrw1:ACOLS[b][Len(oBrw1:ACOLS[b])-1] <> 0//Posição do Recno
			Z33->(DbSetOrder(1))
			Z33->(DbGoTo(oBrw1:ACOLS[b][Len(oBrw1:ACOLS[b])-1]))
			Z33->(RecLock("Z33",.F.))
			Z33->(DbDelete())
			Z33->(MsUnlock())
		EndIf
	Next i
EndIf

Return .T.  
 
//JSS - Alterado para solucionar o chamado 021231. 
/*
Funcao      : VldGEN021()
Parametros  : 
Retorno     :
Objetivos   : Função de validação de campos do Browse
Autor       : João Silva
Data/Hora   : 03/10/2014
*/
*-----------------------*
User Function VldGEN021()
*-----------------------*

If ReadVar() == "M->NDIA"
	DiaxVal()
EndIf

Return .T.

/*
Funcao      : DiaxVal()
Parametros  : 
Retorno     : nDiaxVal
Objetivos   : Função para calcular o valor do beneficio de acordo com a quantidade de dias informada.
Autor       : João Silva
Data/Hora   : 03/10/2014
*/
*-----------------------------*
Static Function DiaxVal()
*-----------------------------*
Local nDiaxVal:= 0       
	
Z71->(dbSetOrder(2)) //Z71_FILIAL+Z71_MAT+Z71_FORN+Z71_COD
Z71->(DbSeek(xFilial("Z71")+ACOLS[oBrw1:NAT][1]+ACOLS[oBrw1:NAT][3]+ACOLS[oBrw1:NAT][5]))

nDiaxVal:= M->NDIA * Z71->Z71_VALOR 
oBrw1:ACOLS[oBrw1:NAT][8] := nDiaxVal
oBrw1:ForceRefresh()

Return .t.
   
/*
Funcao     : GEN021C
Parametros : Nenhum
Retorno    : 
Objetivos  : Rotina para geração dos valores de beneficios.
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*-----------------------*
User Function GEN021C()
*-----------------------* 
Return InWizardPrc()

/*
Funcao     : GEN021R
Parametros : Nenhum
Retorno    : 
Objetivos  : Relatorio dos Beneficios Gerados.
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*-----------------------*
User Function GEN021R()
*-----------------------* 
Local nHdl		:= 0
Private cXml	:= ""
Private cDest	:= GetTempPath()
Private cArq	:= "Beneficios.XML"
Private nBytesSalvo := 0

Return InWizardRel()   

/*
Funcao     : GEN021E
Parametros : Nenhum
Retorno    : 
Objetivos  : Rotina para Inclusão de Tipos de Pedidos Diferenciados.
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*---------------------*
User Function GEN021E()
*---------------------*
Return InWizardEsp()

/*
Funcao     : GEN021G
Parametros : Nenhum
Retorno    : 
Objetivos  : Geração do desconto em folha para os beneficios calculados.
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*-----------------------*
User Function GEN021G()
*-----------------------* 
Return InWizardDes()

/*
Funcao     : GEN021A
Parametros : Nenhum
Retorno    : 
Objetivos  : Geração do arquivo baseado nos calculos.
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*-----------------------*
User Function GEN021A()
*-----------------------* 
Return InWizardArq()

/*
Funcao      : InWizardDes()  
Parametros  : 
Retorno     : 
Objetivos   : Wizard para geração de desconto em Folha.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------*
Static Function InWizardDes()
*---------------------------*
Local lWizDes := .F.

Private oWizDes
Private nOpc := GD_DELETE+GD_UPDATE//+GD_INSERT
Private aCoBrw1 := {}
Private aHoBrw1 := {}
Private noBrw1  := 0

oWizDes := APWizard():New("Beneficios", ""/*<chMsg>*/, "Desconto em Folha.",;
													"- Na Rotina de Desconto em folha será possível gerar os eventos nos lançamentos"+CRLF+;
													"mensais para cada funcionário baseado nos cálculos de benefícios realizado anteriormente."+CRLF+;
													"Possibilita também a edição de porcentagem e seus valores."+CRLF+;
													"Obs.: Esta rotina apresenta informações apenas da empresa Logada.",;
											 {||  .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,,,/*<.lNoFirst.>*/ )
          
//Painel 2
oWizDes:NewPanel( "Parametros", "Parametros para Desconto em Folha.",{ ||.T.}/*<bBack>*/, {|| (LoadaCols("DES",@oBrw1,@oWizDes),.T.)}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

dDtRef	:= dDataBase
nPercPad:= 10

@ 010, 010 TO 125,280 OF oWizDes:oMPanel[2] PIXEL
oSBox1 := TScrollBox():New( oWizDes:oMPanel[2],009,009,124,279,.T.,.T.,.T. )

@ 21,20 SAY oSay0 VAR "Dt. Ref.? " SIZE 100,10 OF oSBox1 PIXEL
odDtRef:= TGet():New(20,85,{|u| if(PCount()>0,dDtRef:=u,dDtRef)},oSBox1,50,05,'@D 99/9999',{|o|},,,,,,.T.,,,,,,,,,	 ,'dDtRef')

@ 41,20 SAY oSay0 VAR "Perc. Padrão? " SIZE 100,10 OF oSBox1 PIXEL
onPercPad:= TGet():New(40,85,{|u| if(PCount()>0,nPercPad:=u,nPercPad)},oSBox1,50,05,'@R 99',{|o|},,,,,,.T.,,,,,,,,,	 ,'nPercPad')

//--> PANEL 3
oWizDes:NewPanel( "Manutenção", "",{ ||.F.}/*<bBack>*/,/*<bNext>*/, {|| lWizDes := .T.,.T.}/*<bFinish>*/, /*<.lPanel.>*/, /*<bExecute>*/ )

//Aadd(aHoBrw1je,{Trim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"ALLWAYSTRUE()",SX3->X3_USADO, SX3->X3_TIPO,SX3->X3_F3, SX3->X3_CONTEXT,SX3->X3_CBOX } )
Aadd(aHoBrw1,{"% Desc."		,"PERC"		,"@E 99.99" ,05,02,"","","N",""			,""})
Aadd(aHoBrw1,{"Vlr. Desc"	,"VALORDES"	,"@E 999.99",06,02,"","","N",""			,""})
Aadd(aHoBrw1,{"Filial" 		,"FILRA"	,"@!"		,02,00,"","","C","SRA"		,""})
Aadd(aHoBrw1,{"Matricula"	,"MAT"		,"@!"		,06,00,"","","C","SRA"		,""})
Aadd(aHoBrw1,{"Nome"  		,"NOME" 	,"@!"		,20,00,"","","C",""			,""})
Aadd(aHoBrw1,{"Forn.Benef"	,"CFBENEF"	,"@!"		,03,00,"","","C","BENEFF"	,""})
Aadd(aHoBrw1,{"Nome Forn."	,"NFBENEF"	,"@!"		,20,00,"","","C",""			,""})
Aadd(aHoBrw1,{"Cod.Benef."	,"CBENEF"	,"@!"		,05,00,"","","C","BENEFB"	,""})
Aadd(aHoBrw1,{"Desc.Benef"	,"DBENEF"	,"@!"		,35,00,"","","C",""			,""})
Aadd(aHoBrw1,{"Dias"		,"NDIA"		,"@E 99"	,02,00,"","","N",""			,""})
Aadd(aHoBrw1,{"Valor"		,"VALOR"	,"@E 999.99",08,02,"","","N",""			,""})
Aadd(aHoBrw1,{"Data"		,"DATA"		,""  		,08,00,"","","D",""			,""})
Aadd(aHoBrw1,{"Rec"			,"RECZ33"	,""  		,15,00,"","","N",""			,""})
noBrw1:= Len(aHoBrw1)

aAlter := {"PERC","VALORDES"}
                                                                                                 
oGrp := TGroup():New( 004,004,134,296,"Manutenção",oWizDes:oMPanel[3],,,.T.,.F. )

oBrw1 := MsNewGetDados():New(012,008,130,292,nOpc,'AllwaysTrue()','AllwaysTrue()','',aAlter,0,999,'U_GTGENVLD()','','AllwaysTrue()',oGrp,aHoBrw1,aCoBrw1 )

oWizDes:Activate( .T./*<.lCenter.>*/,/*<bValid>*/, /*<bInit>*/, /*<bWhen>*/ )

If lWizDes

	//Inclui um registro inicial de Zero
	For b:=1 to Len(oBrw1:ACOLS)
		If !oBrw1:ACOLS[b][Len(oBrw1:ACOLS[b])]
			If SRA->(DbSeek(oBrw1:ACOLS[b][aScan(aHoBrw1,{|x| x[2] == "FILRA"})]+;
							oBrw1:ACOLS[b][aScan(aHoBrw1,{|x| x[2] == "MAT"})]))                                                 
				
				Z64->(DbSetOrder(1))
				If Z64->(DbSeek("  "+"SX "+"VERBA     "+oBrw1:ACOLS[b][aScan(aHoBrw1,{|x| x[2] == "CBENEF"})]))
					cVerba := ALLTRIM(Z64->Z64_CONT1)
				Else
					cVerba := "704"
				EndIf             
				
				While SRA->(!EOF()) .and.;
				   		SRA->RA_FILIAL	== oBrw1:ACOLS[b][aScan(aHoBrw1,{|x| x[2] == "FILRA"})] .and.;
				   		SRA->RA_MAT		== oBrw1:ACOLS[b][aScan(aHoBrw1,{|x| x[2] == "MAT"})]
					If EMPTY(SRA->RA_DEMISSA)
						lGrava := SRC->(DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cVerba))
						SRC->(RecLock("SRC",!lGrava))
						SRC->RC_FILIAL	:= SRA->RA_FILIAL
						SRC->RC_MAT		:= SRA->RA_MAT
						SRC->RC_PD		:= cVerba
						SRC->RC_TIPO1	:= "V"
						SRC->RC_VALOR	:= 0
						SRC->RC_DATA	:= Date()
						SRC->RC_CC		:= SRA->RA_CC
						SRC->RC_TIPO2	:= "I"
						SRC->(MsUnlock())
					EndIf
					SRA->(DbSkip())
				EndDo
			EndIf                              
		EndIf
	Next i           

	//soma os valores do desconto na verba	
	For b:=1 to Len(oBrw1:ACOLS)
		If !oBrw1:ACOLS[b][Len(oBrw1:ACOLS[b])]
			If SRA->(DbSeek(oBrw1:ACOLS[b][aScan(aHoBrw1,{|x| x[2] == "FILRA"})]+;
							oBrw1:ACOLS[b][aScan(aHoBrw1,{|x| x[2] == "MAT"})]))                                                 
				
				Z64->(DbSetOrder(1))
				If Z64->(DbSeek("  "+"SX "+"VERBA     "+oBrw1:ACOLS[b][aScan(aHoBrw1,{|x| x[2] == "CBENEF"})]))
					cVerba := ALLTRIM(Z64->Z64_CONT1)
				Else
					cVerba := "704"
				EndIf             
				
				While SRA->(!EOF()) .and.;
				   		SRA->RA_FILIAL	== oBrw1:ACOLS[b][aScan(aHoBrw1,{|x| x[2] == "FILRA"})] .and.;
				   		SRA->RA_MAT		== oBrw1:ACOLS[b][aScan(aHoBrw1,{|x| x[2] == "MAT"})]
					If EMPTY(SRA->RA_DEMISSA)
						SRC->(DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+cVerba))
						SRC->(RecLock("SRC",.F.))
						SRC->RC_VALOR += oBrw1:ACOLS[b][aScan(aHoBrw1,{|x| x[2] == "VALORDES"})]
						SRC->(MsUnlock())
					EndIf
					SRA->(DbSkip())
				EndDo
			EndIf                              
		EndIf
	Next i
EndIf

Return .T.

/*
Funcao      : InWizardArq()  
Parametros  : 
Retorno     : 
Objetivos   : Wizard para geração do Arquivo de integração do Fornecedor.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------*
Static Function InWizardArq()
*---------------------------*
Local lWizArq
Local lInverte := .F.

Private cMarca  := GetMark()
Private oWizArq
Private cArqTxt := ""
Private ocDirArq
Private oMeter
Private nMeter := 0
Private oMeter2    
Private nMeter2 := 0
Private oSayTxt

oWizArq := APWizard():New("Beneficios", ""/*<chMsg>*/, "Geração de Arquivo.",;
												"Na rotina de Geração de Arquivo, será montado o arquivo no Layout do Fornecedor "+CRLF+;
												"de acordo com as informações processadas nos cálculos de Benefícios "+CRLF+;
												"e os filtros selecionados.",;
												 {||  .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,,,/*<.lNoFirst.>*/)

//Painel 2
oWizArq:NewPanel( "Empresas", "Selecione as empresas que serão impressas!",{ ||.T.}/*<bBack>*/, {|| .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

//Msselect da Empresas
aCpEmp := {	{"WKMARCA"  ,"C",01,0},;
			{"M0_CODIGO","C",02,0},;
	    	{"M0_CODFIL","C",02,0},;
			{"M0_FILIAL","C",15,0},;
			{"M0_NOME"  ,"C",15,0},;
			{"M0_CGC"   ,"C",14,0}}

If Select("TMPEMP") > 0
	TMPEMP->(DbClosearea())
Endif     	      

cArqTmp := CriaTrab(aCpEmp,.T.)
DbUseArea(.T.,"DBDCDX",cArqTmp,"TMPEMP",.T.,.F.)
 
SM0->(DbGoTop())
While SM0->(!EOF())
	TMPEMP->(DbAppend())
	TMPEMP->WKMARCA   := "1"//cMarca
	TMPEMP->M0_CODIGO := SM0->M0_CODIGO
	TMPEMP->M0_CODFIL := SM0->M0_CODFIL
	TMPEMP->M0_FILIAL := SM0->M0_FILIAL
	TMPEMP->M0_NOME   := SM0->M0_NOME	        
    TMPEMP->M0_CGC    := SM0->M0_CGC
	
	SM0->(DbSkip())	
EndDo

oGrp := TGroup():New( 004,004,134,296,"Marque as empresas/filiais",oWizArq:oMPanel[2],,,.T.,.F. )

DEFINE FWBROWSE oBrowEmp DATA TABLE ALIAS "TMPEMP" OF oGrp

ADD MARKCOLUMN oColumn DATA { || If(WKMARCA=="1",'LBOK',IIF(WKMARCA=="2",'LBNO',)) } DOUBLECLICK { |oBrowEmp| MarcBroEmp()} HEADERCLICK { |oBrowEmp| MarcBroAll("TMPEMP")} OF oBrowEmp		
ADD COLUMN oColumn DATA { || M0_NOME	} TITLE "Empresa"  			DOUBLECLICK  {||  }  SIZE 15 OF oBrowEmp 
ADD COLUMN oColumn DATA { || M0_FILIAL 	} TITLE "Filial"  		  	DOUBLECLICK  {||  }  SIZE 15 OF oBrowEmp 
ADD COLUMN oColumn DATA { || M0_CGC 	} TITLE "CGC" PICTURE "@R 99.999.999/9999-99"	DOUBLECLICK  {||  }  SIZE 14 OF oBrowEmp 

oBrowEmp:LOPTIONCONFIG := .F.
oBrowEmp:LOPTIONREPORT := .F.
oBrowEmp:LLOCATE := .F.
ACTIVATE FWBROWSE oBrowEmp
                                

//Painel 3
oWizArq:NewPanel( "Configurações", "Selecione os Filtros a serem considerados para a Impressão!",{ ||.T.}/*<bBack>*/, {|| .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

dDtRef	:= dDataBase                         
cMatDe	:= Space(6)
cMatAte	:= Space(6)
cDirArq := "c:\"+Space(100)
aItens1	:= {'1= Ped. Normais + Eventos','2= Apenas Ped. Normais','3= Apenas Eventos ','4= Apenas Complementar'}
cCombo1	:= aItens1[1]
aItens2	:= {'Sim','Não'}
cCombo2 := aItens1[2]
             
@ 010, 010 TO 125,280 OF oWizArq:oMPanel[3] PIXEL
oSBox1 := TScrollBox():New( oWizArq:oMPanel[3],009,009,124,279,.T.,.T.,.T. )

@ 21,20 SAY oSay0 VAR "Dt. Ref.? " SIZE 100,10 OF oSBox1 PIXEL
odDtRef:= TGet():New(20,85,{|u| if(PCount()>0,dDtRef:=u,dDtRef)},oSBox1,50,05,'@D 99/9999',{|o|},,,,,,.T.,,,,,,,,,	 ,'dDtRef')

@ 41,20 SAY oSay1 VAR "Mat. De? " SIZE 100,10 OF oSBox1 PIXEL
ocMatDe:= TGet():New(40,85,{|u| If(PCount()>0,cMatDe:=u,cMatDe)},oSBox1,50,05,'',{|o|},,,,,,.T.,,,,,,,,,"SRA",'cMatDe')

@ 61,20 SAY oSay2 VAR "Mat. Ate? " SIZE 100,10 OF oSBox1 PIXEL
ocMatAte:= TGet():New(60,85,{|u| If(PCount()>0,cMatAte:=u,cMatAte)},oSBox1,50,05,'',{|o|},,,,,,.T.,,,,,,,,,"SRA",'cMatAte')

@ 81,20 SAY oSay3 VAR "Diretorio? " SIZE 100,10 OF oSBox1 PIXEL
ocDirArq:= TGet():New(80,85,{|u| If(PCount()>0,cDirArq:=u,cDirArq)},oSBox1,43,05,'',{|o|},,,,,,.T.,,,,,,,,,"",'cDirArq')
@ 80,127.5 Button "..."	Size 7,10 Pixel of oSBox1 action (GetDir())

@ 101,20 SAY oSay3 VAR "Tipos de Eventos? " SIZE 100,10 OF oSBox1 PIXEL 
oCombo1:= tComboBox():New(100,85,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aItens1,100,20,oSBox1,,{||},,,,.T.,,,,,,,,,'cCombo1')

@ 121,20 SAY oSay6 VAR "Imprime Com Travas? " SIZE 100,10 OF oSBox1 PIXEL 
oCombo2:= tComboBox():New(120,85,{|u|if(PCount()>0,cCombo2:=u,cCombo2)},aItens2,100,20,oSBox1,,{||},,,,.T.,,,,,,,,,'cCombo2')

//Painel 4               
oWizArq:NewPanel( "Processamento", "",{ ||.T.}/*<bBack>*/, /*<bNext>*/, {|| lWizArq := .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| ProcArq(@oWizArq)}/*<bExecute>*/ )

@ 21,20 SAY oSayTxt VAR ""  SIZE 100,10 OF oWizArq:oMPanel[4] PIXEL
nMeter := 0
oMeter := TMeter():New(31,20,{|u|if(Pcount()>0,nMeter:=u,nMeter)},0,oWizArq:oMPanel[4],250,34,,.T.,,,,,,,,,)
oMeter:Set(0) 

nMeter2 := 0
oMeter2 := TMeter():New(51,20,{|u|if(Pcount()>0,nMeter2:=u,nMeter2)},0,oWizArq:oMPanel[4],250,34,,.T.,,,,,,,,,)
oMeter2:Set(0)

//Ativa o Wizard
oWizArq:Activate( .T./*<.lCenter.>*/,/*<bValid>*/, /*<bInit>*/, /*<bWhen>*/ )

Return .T.

/*
Funcao     : ProcArq
Parametros : Nenhum
Retorno    : 
Objetivos  : Cria o Arquivo no layout do fornecedor.
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*------------------------------*
Static Function ProcArq(oWizArq)
*------------------------------*
Local cTXT := ""
Local nPos	:= 0
Local aEmpProc := {}
Local lDados := .F.

Private nBytesSalvo
                          
Z64->(DbSetOrder(1))
If !Z64->(DbSeek("  "+"SX "+"NOMEARQ   "))
	MsgInfo("Não Foi possivel carregar o nome do arquivo a ser gerado!","Grant Thornton Brasil")
	Return .F.
EndIf        
        
cDirArq := ALLTRIM(cDirArq)
cArqTxt := ALLTRIM(Z64->Z64_DESCRI)+STRZERO(YEAR(dDtRef),4)+STRZERO(MONTH(dDtRef),2)+".TXT"
                    
//Inicializa o Arquivo
IF FILE (cDirArq+cArqTxt)
	FERASE (cDirArq+cArqTxt)
ENDIF

nHdl 		:= FCREATE(cDirArq+cArqTxt,0 )  	//Criação do Arquivo .
nBytesSalvo := FWRITE(nHdl, cTXT ) 		// Gravação do seu Conteudo.
fclose(nHdl)						// Fecha o Arquivo que foi Gerado	
                                              
TMPEMP->(DbGoTop())
While TMPEMP->(!EOF())
	If TMPEMP->WKMARCA == "1"//cMarca                                                             
		aAdd(aEmpProc,{TMPEMP->M0_CODIGO,TMPEMP->M0_CODFIL,TMPEMP->M0_NOME,TMPEMP->(RECNO())})
	EndIf 
	TMPEMP->(DbSkip())
EndDo
 
If Len(aEmpProc) == 0
	oSayTxt:CCAPTION := "Não Foi possivel carregar empresas!"	
	oMeter:LVISIBLE := .F. 
	oMeter2:LVISIBLE := .F.
	oWizArq:OBACK:LVISIBLECONTROL		:= .T.
	oWizArq:OCANCEL:LVISIBLECONTROL	:= .T.
	oWizArq:ONEXT:LVISIBLECONTROL		:= .T.
	oWizArq:OFINISH:LVISIBLECONTROL	:= .T.
	Return .T. 
Else
	oSayTxt:CCAPTION := "Aguarde..."
	oMeter:LVISIBLE := .T.
	oMeter2:LVISIBLE := .T.
	oWizArq:OBACK:LVISIBLECONTROL		:= .F.
	oWizArq:OCANCEL:LVISIBLECONTROL	:= .F.
	oWizArq:ONEXT:LVISIBLECONTROL		:= .F.
	oWizArq:OFINISH:LVISIBLECONTROL	:= .F.
EndIf

oMeter:NTOTAL := Len(aEmpProc)
     
//Ordena o Array com as Empresas
aSort(aEmpProc)                                          

aTpPedidos := {}   

If Left(cCombo1,1) == "1" .or.;//Lançamentos + Eventos
	Left(cCombo1,1) == "2"//Apenas Lançamentos
	aAdd(aTpPedidos,'  1')//Normal
EndIf

If Left(cCombo1,1) == "1" .or.;//Lançamentos + Eventos
	Left(cCombo1,1) == "3"//Apenas Eventos
	aAdd(aTpPedidos,'  7')//Seg. Via - Cartão Danificado;
	aAdd(aTpPedidos,' 11')//Cancelamento por demissão;
	aAdd(aTpPedidos,' 12')//Seg. Via - Erro no nome impresso no cartão.;
	aAdd(aTpPedidos,' 21')//Seg. via - perda ou roubo;
	aAdd(aTpPedidos,' 23')//Primeira via S/ Crédito"
EndIf

If Left(cCombo1,1) == "4"//Complementar
	aAdd(aTpPedidos,'  C')//Complemento
EndIf

For x:=1 to len(aTpPedidos)//Executa por tipo de pedido.
	For i:=1 to Len(aEmpProc)
		oMeter:Set(i)
		If TcCanOpen("Z33"+aEmpProc[i][1]+"0")	
			
			TMPEMP->(DbGoTo(aEmpProc[i][4]))

			oMeter2:Set(0)
			nMeter2 := 0
			
			cQuery := ""     //Select Esta Abaixo.
			cQuery += " From "+"SRA"+aEmpProc[i][1]+"0"+" SRA 
			cQuery += " 			Join (	Select * 
			cQuery += " 							From "+"Z33"+aEmpProc[i][1]+"0"+" 
			cQuery += " 							Where D_E_L_E_T_ <> '*' AND 
			If !EMPTY(dDtRef)
				cQuery += " 											 	Z33_DATA >= '"+STRZERO(YEAR(dDtRef),4)+STRZERO(MONTH(dDtRef),2)+"01' AND 
				cQuery += " 												Z33_DATA <= '"+STRZERO(YEAR(dDtRef),4)+STRZERO(MONTH(dDtRef),2)+"31' AND
			EndIf                                                                              
			cQuery += " 													Z33_TIPO = '"+aTpPedidos[x]+"'
			If aItens2[2] == cCombo2
				cQuery += "													AND Z33_TRAVA = ''
			EndIf
			cQuery += " 													AND Z33_FORN = 'SX') as Z33 
			cQuery += " 																			on 	SRA.RA_FILIAL = Z33.Z33_FILIAL
			cQuery += " 																	   			AND SRA.RA_MAT = Z33.Z33_MAT
			//If aTpPedidos[x] == aTpPedidos[1]
				cQuery += " 		Join (	Select *  		  						
				cQuery += " 				From Z64YY0  								
				cQuery += " 				Where D_E_L_E_T_ <> '*'
				cQuery += " 				AND Z64_TABELA = 'SX'
				cQuery += " 				AND Z64_CHAVE = 'CONTRATO'
				cQuery += " 				AND Z64_DESCRI = '"+aEmpProc[i][1]+aEmpProc[i][2]+"') as Z64 on	Z64.Z64_CONT2 like '%'+RTRIM(Z33.Z33_COD)+'%'
			//EndIf
			cQuery += " Where SRA.D_E_L_E_T_ <> '*'
			cQuery += " AND SRA.RA_FILIAL = '"+aEmpProc[i][2]+"'
			
			If !EMPTY(cMatDe)   
				cQuery += " AND SRA.RA_MAT >= '"+ALLTRIM(cMatDe)+"' 
			EndIf
			If !EMPTY(cMatAte)  
				cQuery += " AND SRA.RA_MAT <= '"+ALLTRIM(cMatAte)+"' 
			EndIf 
			cQuery += " AND SRA.RA_DEMISSA = ''
	
	   		cUpdate := "Update "+"Z33"+aEmpProc[i][1]+"0"+" Set Z33_TRAVA = 'S' Where R_E_C_N_O_ in ( Select Z33.R_E_C_N_O_ "+cQuery+")"         
	   		
			//Contador de Registros
			If Select("QRY") > 0
				QRY->(DbClosearea())
			Endif     	       
			dbUseArea(.T.,"TOPCONN", TCGENQRY(,,"Select COUNT(*) as COUNT "+cQuery),"QRY",.F.,.T.)
			
			oMeter2:NTOTAL := QRY->COUNT
	        
	        //Query de Busca das informações  
			cQuery:= "Select *,Z33.D_E_L_E_T_ as DEL "+cQuery
			If Select("QRY") > 0
				QRY->(DbClosearea())
			Endif     	             	
			dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

			QRY->(DbGoTop())
			If QRY->(EOF()) .and. QRY->(BOF())//Controle de Conteudo da tabela.
				Loop
			EndIf
   			QRY->(DbGoTop())                                               
			
			cTipoPed := Alltrim(aTpPedidos[x])
			If cTipoPed == "C"//troca o tipo de complemento para normal no layout.
				cTipoPed := "1"
			EndIf
			
			//REGISTRO TIPO “0” – Identificação da Empresa e do Tipo de Pedido
			cTXT := Space(629)
			cTXT := Stuff(cTXT,001,001, '0'											  				)//TIPO DE REGISTRO
			cTXT := Stuff(cTXT,002,009, STRZERO(VAL(QRY->Z64_CONT1),8)								)//CÓDIGO DO CLIENTE
			cTXT := Stuff(cTXT,010,049, LEFT(TMPEMP->M0_NOME,40)									)//RAZAO SOCIAL DO CLIENTE
			cTXT := Stuff(cTXT,050,055, LEFT(STRTRAN(TIME(),":",""),6)								)//NUM. PEDIDO CLIENTE
			cTXT := Stuff(cTXT,056,061, STRZERO(MONTH(dDtRef),2)+STRZERO(YEAR(dDtRef),4)			)//PERIODO DE REFERENCIA 
			cTXT := Stuff(cTXT,062,064, '005'														)//ADMINISTRADORA
			cTXT := Stuff(cTXT,065,067, Space(3-Len(cTipoPed))+cTipoPed  							)//TIPO DE PEDIDO
			cTXT := Stuff(cTXT,068,068, Space(1)													)//FILLER
			cTXT := Stuff(cTXT,069,076, STRZERO(DAY(dDataBase    ),2)+STRZERO(MONTH(dDataBase    ),2)+STRZERO(YEAR(dDataBase    ),4))//DATA DE GERACAO DO ARQUIVO
			cTXT := Stuff(cTXT,077,084, STRZERO(DAY(STOD(QRY->Z33_DATA)),2)+STRZERO(MONTH(STOD(QRY->Z33_DATA)),2)+STRZERO(YEAR(STOD(QRY->Z33_DATA)),4))//DATA DE ENTREGA DO PEDIDO
			cTXT := Stuff(cTXT,085,092, STRZERO(DAY(STOD(QRY->Z33_DATA)),2)+STRZERO(MONTH(STOD(QRY->Z33_DATA)),2)+STRZERO(YEAR(STOD(QRY->Z33_DATA)),4))//DATA PARA CREDITO NO CARTÃO
			cTXT := Stuff(cTXT,093,098, REPLICATE("0",6)											)//NUM. SEQUENCIAL ARQUIVO
			cTXT := Stuff(cTXT,099,100, REPLICATE("0",2)											)//NUMERO DE VERSAO ARQ.
			cTXT := Stuff(cTXT,101,629, Space(529)													)//FILLER
			cTXT += CHR(13)+CHR(10)
	
			cTXT := GrvInfo(cTXT,cDirArq,cArqTxt)		

            cAux		:= AllTrim(QRY->Z64_CONT4)
			cTpLogra	:= SubStr(cAux,1,AT("-",cAux)-1); cAux := SubStr(cAux,AT("-",cAux)+1,Len(cAux))
			cLogra		:= SubStr(cAux,1,AT("-",cAux)-1); cAux := SubStr(cAux,AT("-",cAux)+1,Len(cAux))
			cNumero		:= SubStr(cAux,1,AT("-",cAux)-1); cAux := SubStr(cAux,AT("-",cAux)+1,Len(cAux))
			cComplem	:= SubStr(cAux,1,AT("-",cAux)-1); cAux := SubStr(cAux,AT("-",cAux)+1,Len(cAux))
			cAux		:= AllTrim(QRY->Z64_CONT5)
			cBairro		:= SubStr(cAux,1,AT("-",cAux)-1); cAux := SubStr(cAux,AT("-",cAux)+1,Len(cAux))
			cCidade		:= SubStr(cAux,1,AT("-",cAux)-1); cAux := SubStr(cAux,AT("-",cAux)+1,Len(cAux))
			cEstado		:= SubStr(cAux,1,AT("-",cAux)-1); cAux := SubStr(cAux,AT("-",cAux)+1,Len(cAux))
			cCEP		:= SubStr(cAux,1,AT("-",cAux)-1); cAux := SubStr(cAux,AT("-",cAux)+1,Len(cAux))
	
	        //REGISTRO TIPO “3” – Informações para Entrega   
	        cTXT := Space(629)
			cTXT := Stuff(cTXT,001,001, '3'																			)//TIPO DE REGISTRO
			cTXT := Stuff(cTXT,002,007, Space(6)																	)//FILLER
			cTXT := Stuff(cTXT,008,025, Space(16)+"RH"																)//CÓDIGO DEPTO
			cTXT := Stuff(cTXT,026,037, Space(12)																	)//FILLER
			cTXT := Stuff(cTXT,038,072, Space(25)+'RH PARAISO'												  		)//NOME DEPTO
			cTXT := Stuff(cTXT,073,077, Space(5)																	)//FILLER
			cTXT := Stuff(cTXT,078,097, Space(20-MAX(Len(ALLTRIM(QRY->Z64_CONT3)),0))+ALLTRIM(QRY->Z64_CONT3)		)//NOME RESP. DEPTO
			cTXT := Stuff(cTXT,098,111, Space(14)																	)//FILLER
			cTXT := Stuff(cTXT,112,117, Space(06-MAX(Len(cTpLogra),0))+cTpLogra										)//TIPO DE LOGRADOURO
			cTXT := Stuff(cTXT,118,157, Space(40-MAX(Len(cLogra),0))+cLogra											)//DESCRIÇÃO DO LOGRADOURO
			cTXT := Stuff(cTXT,158,165, Space(08-MAX(Len(cNumero),0))+cNumero										)//NUMERO
			cTXT := Stuff(cTXT,166,185, Space(20-MAX(Len(cComplem),0))+cComplem										)//COMPLEMENTO
			cTXT := Stuff(cTXT,186,200, Space(15-MAX(Len(cBairro),0))+cBairro										)//BAIRRO
			cTXT := Stuff(cTXT,201,205, Space(5)																	)//FILLER
			cTXT := Stuff(cTXT,206,225, Space(20-MAX(Len(cCidade),0))+cCidade										)//CIDADE
			cTXT := Stuff(cTXT,226,235, Space(10)																	)//FILLER
			cTXT := Stuff(cTXT,236,237, Space(02-MAX(Len(cEstado),0))+cEstado										)//ESTADO
			cTXT := Stuff(cTXT,238,245, STRZERO(VAL(cCEP),8)														)//CEP
			cTXT := Stuff(cTXT,246,629, Space(384)																	)//FILLER
			cTXT += CHR(13)+CHR(10)
	        
			cTXT := GrvInfo(cTXT,cDirArq,cArqTxt)
	        
			n:=0	
			QRY->(DbGoTop())
			While QRY->(!EOF())
				n++
				oMeter2:Set(n)
				
				lDados := .T.
		
		       	//REGISTRO TIPO “4” – Informações do Colaborador e Benefícios Solicitados   
		        cTXT := Space(1000)
				cTXT := Stuff(cTXT,001,001, '4')//TIPO DE REGISTRO
				cTXT := Stuff(cTXT,002,037, Space(36))//FILLER
				cTXT := Stuff(cTXT,038,047, Space(10-Len(QRY->RA_MAT))+QRY->RA_MAT)//MATRÍCULA DO COLABORADOR / FUNCIONÁRIO
				cTXT := Stuff(cTXT,048,087, Space(40-Len(QRY->RA_NOME))+QRY->RA_NOME)//NOME DO COLABORADOR / FUNCIONÁRIO
				cTXT := Stuff(cTXT,088,088, Space(1))//FILLER
				cTXT := Stuff(cTXT,089,096, STRZERO(DAY(STOD(QRY->RA_NASC)),2)+STRZERO(MONTH(STOD(QRY->RA_NASC)),2)+STRZERO(YEAR(STOD(QRY->RA_NASC)),4))//DATA NASCIMENTO
				cTXT := Stuff(cTXT,097,107, STRZERO(VAL(QRY->RA_CIC),11))//CPF TITULAR
				cTXT := Stuff(cTXT,108,108, QRY->RA_SEXO)//SEXO
				cTXT := Stuff(cTXT,109,111, QRY->Z33_COD)//CÓDIGO PRODUTO
				//DE X PARA para FORMA de acordo com a Tabela do Fornecedor.
				Z64->(DbSetOrder(1))
				Z64->(DbSeek("  "+"SX "+"FORMA     "+QRY->Z33_COD))
				cTXT := Stuff(cTXT,112,114, ALLTRIM(Z64->Z64_CONT1))//CÓDIGO FORMA
				cTXT := Stuff(cTXT,115,119, REPLICATE("0",5))//QTDE TALÕES
				cTXT := Stuff(cTXT,120,121, REPLICATE("0",2))//QTDE CHEQUES POR TALÃO
				cTXT := Stuff(cTXT,122,133, STRZERO(VAL(STRTRAN(ALLTRIM(TRANSFORM(QRY->Z33_VALOR,"@R 9999999999.99")),".","") ),12))//VALOR FACIAL / CREDITO
				cTXT := Stuff(cTXT,134,147, Space(14))//FILLER
				cTXT := Stuff(cTXT,148,171, Space(24))//NOME DO COLABORADOR PARA IMPRESSÃO NO CARTÃO..
				cTXT := Stuff(cTXT,172,241, Space(70))//FILLER
	
				//TODAS AS INFORMAÇÕES ABAIXO SÃO PARA O PRODUTO VALE TRANSPORTE, PARA OS DEMAIS PRODUTOS PREENCHER COM BRANCOS.
				cTXT := Stuff(cTXT,0242,0251, '')//NUMERO DO RG
				cTXT := Stuff(cTXT,0252,0253, '')//DÍGITO DO RG
				cTXT := Stuff(cTXT,0254,0255, '')//UF EMISSORA DO RG
				cTXT := Stuff(cTXT,0256,0263, '')//DATA EMISSÃO DO RG
				cTXT := Stuff(cTXT,0264,0269, '')//ORGÃO EMISSOR DO RG
				cTXT := Stuff(cTXT,0270,0283, '')//FILLER
				cTXT := Stuff(cTXT,0284,0289, '')//TIPO DE LOGRADOURO. (endereço do funcionário)
				cTXT := Stuff(cTXT,0290,0329, '')//DESCRIÇÃO DO LOGRADOURO
				cTXT := Stuff(cTXT,0330,0336, '')//NUMERO
				cTXT := Stuff(cTXT,0337,0356, '')//COMPLEMENTO
				cTXT := Stuff(cTXT,0357,0371, '')//BAIRRO
				cTXT := Stuff(cTXT,0372,0376, '')//FILLER
				cTXT := Stuff(cTXT,0377,0396, '')//CIDADE
				cTXT := Stuff(cTXT,0397,0406, '')//FILLER
				cTXT := Stuff(cTXT,0407,0408, '')//ESTADO
				cTXT := Stuff(cTXT,0409,0416, '')//CEP
				cTXT := Stuff(cTXT,0417,0456, '')//NOME DA MAE DO FUNCIONÁRIO
				cTXT := Stuff(cTXT,0457,0457, '')//ESTADO CIVIL
				cTXT := Stuff(cTXT,0458,0507, '')//E-mail do Beneficiário
				cTXT := Stuff(cTXT,0508,0511, '')//DDD do telefone do Beneficiário
				cTXT := Stuff(cTXT,0512,0519, '')//TELEFONE DO BENEFICIÁRIO
				cTXT := Stuff(cTXT,0520,0559, '')//CARGO DO BENEFICIARIO
				cTXT := Stuff(cTXT,0560,0575, '')//NÚMERO DO SIC-CURITIBA DO BENEFICIÁRIO
				cTXT := Stuff(cTXT,0576,0703, '')//FILLER
				cTXT := Stuff(cTXT,0704,0706, '')//QUANT. DIAS UTEIS
				cTXT := Stuff(cTXT,0707,0710, '')//CÓDIGO.OPERADORA 1
				cTXT := Stuff(cTXT,0711,0715, '')//CÓDIGO LINHA 1
				cTXT := Stuff(cTXT,0716,0719, '')//QUANT. DE PASSES POR DIA 1
				cTXT := Stuff(cTXT,0720,0730, '')//VALOR DO BILHETE 1
				cTXT := Stuff(cTXT,0731,0746, '')//NÚMERO CARTÃO/CQ 1
				cTXT := Stuff(cTXT,0747,0750, '')//CÓDIGO.OPERADORA 2
				cTXT := Stuff(cTXT,0751,0755, '')//CÓDIGO LINHA 2
				cTXT := Stuff(cTXT,0756,0759, '')//QUANT. DE PASSES POR DIA 2
				cTXT := Stuff(cTXT,0760,0770, '')//VALOR DO BILHETE 2
				cTXT := Stuff(cTXT,0771,0786, '')//NÚMERO CARTÃO/CQ 2
				cTXT := Stuff(cTXT,0787,0790, '')//CÓDIGO.OPERADORA 3
				cTXT := Stuff(cTXT,0791,0795, '')//CÓDIGO LINHA 3
				cTXT := Stuff(cTXT,0796,0799, '')//QUANT. DE PASSES POR DIA 3
				cTXT := Stuff(cTXT,0800,0810, '')//VALOR DO BILHETE 3
				cTXT := Stuff(cTXT,0811,0826, '')//NÚMERO CARTÃO/CQ 3
				cTXT := Stuff(cTXT,0827,0830, '')//CÓDIGO.OPERADORA 4
				cTXT := Stuff(cTXT,0831,0835, '')//CÓDIGO LINHA 4
				cTXT := Stuff(cTXT,0836,0839, '')//QUANT. DE PASSES POR DIA 4
				cTXT := Stuff(cTXT,0840,0850, '')//VALOR DO BILHETE 4
				cTXT := Stuff(cTXT,0851,0866, '')//NÚMERO CARTÃO/CQ 4
				cTXT := Stuff(cTXT,0867,0870, '')//CÓDIGO.OPERADORA 5
				cTXT := Stuff(cTXT,0871,0875, '')//CÓDIGO LINHA 5
				cTXT := Stuff(cTXT,0876,0879, '')//QUANT. DE PASSES POR DIA 5
				cTXT := Stuff(cTXT,0880,0890, '')//VALOR DO BILHETE 5
				cTXT := Stuff(cTXT,0891,0906, '')//NÚMERO CARTÃO/CQ 5
				cTXT := Stuff(cTXT,0907,1000, '')//FILLER
				cTXT += CHR(13)+CHR(10)
	
				cTXT := GrvInfo(cTXT,cDirArq,cArqTxt)
	
				QRY->(DbSkip())
			EndDo 
			
			//REGISTRO TIPO “9” – FINALIZADOR do Pedido 
		 	cTXT := Space(629)
			cTXT := Stuff(cTXT,001,001, '9')//TIPO DE REGISTRO
			cTXT := Stuff(cTXT,002,629, Space(628))//FILLER
			cTXT += CHR(13)+CHR(10)
	        
			cTXT := GrvInfo(cTXT,cDirArq,cArqTxt)		

			TCSQLExec(cUpdate)//Update na Trava
		EndIf
	Next i
Next x	
oSayTxt:CCAPTION := "FINALIZADO! clique em 'Finalizar'."
oWizArq:OFINISH:LVISIBLECONTROL	:= .T.
                   
If !lDados
	MsgInfo("Sem dados a serem Gerados!","Grant Thornton Brasil")
	FERASE (cDirArq+cArqTxt)
	Return .T.
EndIf

If nBytesSalvo >= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
	MsgInfo("Arquivo(s) Gerado(s) com sucesso na Pasta: '"+ALLTRIM(cDirArq)+"'","Grant Thornton Brasil")
Else
	MsgInfo("Nenhum Arquivo Gerado!","Grant Thornton Brasil")
Endif

Return .T.

/*
Funcao      : GetDir
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Busca de diretorio.
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*---------------------------*
Static Function GetDir()
*---------------------------*
Local cTitle:= "Salvar arquivo"
Local cFile := ""
Local nDefaultMask := 0
Local cDefaultDir  := ALLTRIM(cDirArq)
Local nOptions:= GETF_NETWORKDRIVE+GETF_RETDIRECTORY+GETF_LOCALHARD

cDirArq := ALLTRIM(cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.))

Return 


/*
Funcao      : inWizardRel()  
Parametros  : 
Retorno     : 
Objetivos   : Wizard para impressão de Relatorio.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------*
Static Function inWizardRel()
*--------------------------*
Local lRet := .F.
Local lWizRel := .F.
Local oSelRel

Local lInverte := .F.

Private oWizRel
Private cMarca  := GetMark()
Private oMeter
Private nMeter := 0
Private oMeter2    
Private nMeter2 := 0
Private oSayTxt

oWizRel := APWizard():New("Beneficios", ""/*<chMsg>*/, "Relatorio Beneficios.",;
												"No Relatorio de Beneficios será possivel gerar um Excel das informações geradas pela"+CRLF+;
												"rotina de integração. Possibilitando um acompanhamento dos processamentos"+CRLF+;
												"gerados para os funcionarios e seus historicos.",;
									 {||  .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,,,/*<.lNoFirst.>*/)

//Painel 2
oWizRel:NewPanel( "Empresas", "Selecione as empresas que serão impressas!",{ ||.T.}/*<bBack>*/, {|| .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

//Msselect da Empresas
aCpEmp := {	{"WKMARCA"  ,"C",02,0},;
			{"M0_CODIGO","C",02,0},;
	    	{"M0_CODFIL","C",02,0},;
			{"M0_FILIAL","C",15,0},;
			{"M0_NOME"  ,"C",15,0},;
			{"M0_CGC"   ,"C",14,0}}

If Select("TMPEMP") > 0
	TMPEMP->(DbClosearea())
Endif     	      

cArqTmp := CriaTrab(aCpEmp,.T.)
DbUseArea(.T.,"DBDCDX",cArqTmp,"TMPEMP",.T.,.F.)
 
SM0->(DbGoTop())
While SM0->(!EOF())
	TMPEMP->(DbAppend())
	TMPEMP->WKMARCA   := cMarca
	TMPEMP->M0_CODIGO := SM0->M0_CODIGO
	TMPEMP->M0_CODFIL := SM0->M0_CODFIL
	TMPEMP->M0_FILIAL := SM0->M0_FILIAL
	TMPEMP->M0_NOME   := SM0->M0_NOME	        
    TMPEMP->M0_CGC    := SM0->M0_CGC
	
	SM0->(DbSkip())	
EndDo

aExibe  := {{"WKMARCA"  ,,""       ,""  },;
			{"M0_NOME"  ,,"Empresa","@!"},;
			{"M0_FILIAL",,"Filial" ,"@!"},;
			{"M0_CGC"   ,,"CNPJ"   ,"@R 99.999.999/9999-99"}}

oGrp := TGroup():New( 004,004,134,296,"Marque as empresas/filiais",oWizRel:oMPanel[2],,,.T.,.F. )

TMPEMP->(DbGoTop())
oSelRel:= MsSelect():New("TMPEMP","WKMARCA","",aExibe,@lInverte,@cMarca,{012,008,130,292},,, oGrp ) 
oSelRel:oBrowse:lHasMark := .T.
oSelRel:oBrowse:lCanAllMark:=.T.
oSelRel:oBrowse:bAllMark := {|| MarkAll("TMPEMP",cMarca,@oWizRel:oMPanel[2])}
          
//Painel 3
oWizRel:NewPanel( "Configurações", "Selecione os Filtros a serem considerados para a Impressão!",{ ||.T.}/*<bBack>*/, {|| .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

dDtRef	:= dDataBase                         
cMatDe	:= Space(6)
cMatAte	:= Space(6)
aItens1	:= {'Sim','Não'}
cCombo1	:= aItens1[1]
aItens2	:= {'1=Separado Por Abas','2=Agrupado na Planilha'}
cCombo2	:= aItens2[1]
             
@ 010, 010 TO 125,280 OF oWizRel:oMPanel[3] PIXEL
oSBox1 := TScrollBox():New( oWizRel:oMPanel[3],009,009,124,279,.T.,.T.,.T. )

@ 21,20 SAY oSay0 VAR "Dt. Ref.? " SIZE 100,10 OF oSBox1 PIXEL
odDtRef:= TGet():New(20,85,{|u| if(PCount()>0,dDtRef:=u,dDtRef)},oSBox1,50,05,'@D 99/9999',{|o|},,,,,,.T.,,,,,,,,,	 ,'dDtRef')

@ 41,20 SAY oSay1 VAR "Mat. De? " SIZE 100,10 OF oSBox1 PIXEL
ocMatDe:= TGet():New(40,85,{|u| If(PCount()>0,cMatDe:=u,cMatDe)},oSBox1,50,05,'',{|o|},,,,,,.T.,,,,,,,,,"SRA",'cMatDe')

@ 61,20 SAY oSay2 VAR "Mat. Ate? " SIZE 100,10 OF oSBox1 PIXEL
ocMatAte:= TGet():New(60,85,{|u| If(PCount()>0,cMatAte:=u,cMatAte)},oSBox1,50,05,'',{|o|},,,,,,.T.,,,,,,,,,"SRA",'cMatAte')

@ 81,20 SAY oSay3 VAR "Exibe Deletados? " SIZE 100,10 OF oSBox1 PIXEL 
oCombo1:= tComboBox():New(80,85,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aItens1,100,20,oSBox1,,{||},,,,.T.,,,,,,,,,'cCombo1')

@ 101,20 SAY oSay3 VAR "Modo Exibir Emp.? " SIZE 100,10 OF oSBox1 PIXEL 
oCombo1:= tComboBox():New(100,85,{|u|if(PCount()>0,cCombo2:=u,cCombo2)},aItens2,100,20,oSBox1,,{||},,,,.T.,,,,,,,,,'cCombo2')

//Painel 4
oWizRel:NewPanel( "Processamento", "",{ ||.T.}/*<bBack>*/, /*<bNext>*/, {|| lWizRel := .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| ProcXML(@oWizRel)}/*<bExecute>*/ )

@ 21,20 SAY oSayTxt VAR ""  SIZE 100,10 OF oWizRel:oMPanel[4] PIXEL
nMeter := 0
oMeter := TMeter():New(31,20,{|u|if(Pcount()>0,nMeter:=u,nMeter)},0,oWizRel:oMPanel[4],250,34,,.T.,,,,,,,,,)
oMeter:Set(0) 

nMeter2 := 0
oMeter2 := TMeter():New(51,20,{|u|if(Pcount()>0,nMeter2:=u,nMeter2)},0,oWizRel:oMPanel[4],250,34,,.T.,,,,,,,,,)
oMeter2:Set(0)

//Ativa o Wizard
oWizRel:Activate( .T./*<.lCenter.>*/,/*<bValid>*/, /*<bInit>*/, /*<bWhen>*/ )

If lWizRel
	If nBytesSalvo >= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
		SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
	endif
EndIf

Return lRet  

*--------------------------------------------*
Static Function MarkAll(cAlias, cMarca, oDlg)
*--------------------------------------------*
Local nReg := RecNo()

(cAlias)->(dbGoTop())
dbEval({|| (cAlias)->(RecLock(cAlias,.F.)),(cAlias)->WKMARCA := If(Empty((cAlias)->WKMARCA), cMarca, "  "),(cAlias)->(MsUnlock())})
(cAlias)->(dbGoto(nReg))

oDlg:Refresh()

Return Nil        
           
/*
Funcao      : InWizardPrc()  
Parametros  : 
Retorno     : 
Objetivos   : Wizard inicial para o usuário informar os dados básicos para o processamento
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------*
Static Function InWizardPrc()
*---------------------------*
Local lWiz	:= .F.
Local lInverte := .F.         

Private oNo 		:= LoadBitmap( GetResources(), "LBNO" )
Private oOk 		:= LoadBitmap( GetResources(), "LBTIK" )

Private cMarca  := GetMark()
Private oWizBenef
Private oMeter
Private nMeter := 0
Private oMeter2    
Private nMeter2 := 0
Private oSayTxt
                      
oWizBenef := APWizard():New("Beneficios", ""/*<chMsg>*/, "Processamento de Beneficios",;
														"Na rotina de Calculo de Benefícios será possível efetuar o calculo dos "+CRLF+;
														"benefícios para os funcionários previamente cadastrados na rotina de Func. X Beneficios."+CRLF+;
														"Possibilidade de apontar a data de credito do beneficio, quantidade de dias, e funcionários.",;
												 {||  .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,,,/*<.lNoFirst.>*/ )

bNext2 := {|| MsgYesNo("A opção de "+IIF(lCheck1,;
												"'Pedido Normal' sobrescreve o pedido em aberto do mês que será informado",;
												"'Complemento de pedido' gera um novo pedido para o mês que será informado")+;
						", Afetando diretamente o desconto em folha. Deseja continuar?","Grant Thornton Brasil")}

//Painel 2
oWizBenef:NewPanel( "Empresas", "Tipo de calculo",{ ||.T.}/*<bBack>*/, bNext2/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

@ 010, 010 TO 125,280 OF oWizBenef:oMPanel[2] PIXEL
oSBox1 := TScrollBox():New( oWizBenef:oMPanel[2],009,009,124,279,.T.,.T.,.T. )

lCheck1 := .T.
lCheck2 := .F.

oCBox1 := TCheckBox():New( 041,020,"Pedido Normal"			,,oSBox1,096,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCBox2 := TCheckBox():New( 061,020,"Complemento de pedido."	,,oSBox1,096,012,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )

oCBox1:bSetGet := {|| lCheck1 }
oCBox1:bLClicked := {|| (lCheck2:=!(lCheck1:=!lCheck1), oCBox2:CtrlRefresh() ) }
oCBox1:bWhen := {|| .T. }

oCBox2:bSetGet := {|| lCheck2 }
oCBox2:bLClicked := {|| (lCheck1:=!(lCheck2:=!lCheck2), oCBox1:CtrlRefresh() ) }
oCBox2:bWhen := {|| .T. }

//Painel 3                                	
oWizBenef:NewPanel( "Empresas", "Selecione as empresas que serão impressas!",{ ||.T.}/*<bBack>*/, {|| .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

//Msselect da Empresas
aCpEmp := {	{"WKMARCA"  ,"C",01,0},;
			{"M0_CODIGO","C",02,0},;
	    	{"M0_CODFIL","C",02,0},;
			{"M0_FILIAL","C",15,0},;
			{"M0_NOME"  ,"C",15,0},;
			{"M0_CGC"   ,"C",14,0}}

If Select("TMPEMP") > 0
	TMPEMP->(DbClosearea())
Endif     	      

cArqTmp := CriaTrab(aCpEmp,.T.)
DbUseArea(.T.,"DBDCDX",cArqTmp,"TMPEMP",.T.,.F.)
 
SM0->(DbGoTop())
While SM0->(!EOF())
	TMPEMP->(DbAppend())
	TMPEMP->WKMARCA   := "1"//cMarca
	TMPEMP->M0_CODIGO := SM0->M0_CODIGO
	TMPEMP->M0_CODFIL := SM0->M0_CODFIL
	TMPEMP->M0_FILIAL := SM0->M0_FILIAL
	TMPEMP->M0_NOME   := SM0->M0_NOME	        
    TMPEMP->M0_CGC    := SM0->M0_CGC
	
	SM0->(DbSkip())	
EndDo

oGrp := TGroup():New( 004,004,134,296,"Marque as empresas/filiais",oWizBenef:oMPanel[3],,,.T.,.F. )

DEFINE FWBROWSE oBrowEmp DATA TABLE ALIAS "TMPEMP" OF oGrp

ADD MARKCOLUMN oColumn DATA { || If(WKMARCA=="1",'LBOK',IIF(WKMARCA=="2",'LBNO',)) } DOUBLECLICK { |oBrowEmp| MarcBroEmp()} HEADERCLICK { |oBrowEmp| MarcBroAll("TMPEMP")} OF oBrowEmp		
ADD COLUMN oColumn DATA { || M0_NOME	} TITLE "Empresa"  			DOUBLECLICK  {||  }  SIZE 15 OF oBrowEmp 
ADD COLUMN oColumn DATA { || M0_FILIAL 	} TITLE "Filial"  		  	DOUBLECLICK  {||  }  SIZE 15 OF oBrowEmp 
ADD COLUMN oColumn DATA { || M0_CGC 	} TITLE "CGC" PICTURE "@R 99.999.999/9999-99"	DOUBLECLICK  {||  }  SIZE 14 OF oBrowEmp 

oBrowEmp:LOPTIONCONFIG := .F.
oBrowEmp:LOPTIONREPORT := .F.
oBrowEmp:LLOCATE := .F.
ACTIVATE FWBROWSE oBrowEmp
             
//--> PANEL 4
oWizBenef:NewPanel( "Parametros", "Parametros para calculo dos Beneficios.",{ ||.T.}/*<bBack>*/, {|| .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )
dDtRef	:= dDataBase
nDias	:= 22
cMatDe	:= Space(6)
cMatAte	:= Space(6)
aItens1	:= {'Sim','Não'}
cCombo1	:= aItens1[1]
cCombo2 := aItens1[2]
             
//Carrega sugestão de quantidade de dias.
RCF->(DbSetOrder(1))
If RCF->(DbSeek(xFilial("RCF")+STRZERO(YEAR(dDtRef),4)+STRZERO(MONTH(dDtRef),2)))
	nDias := RCF->RCF_DIATRA
EndIf

@ 010, 010 TO 125,280 OF oWizBenef:oMPanel[4] PIXEL
oSBox1 := TScrollBox():New( oWizBenef:oMPanel[4],009,009,124,279,.T.,.T.,.T. )

@ 21,20 SAY oSay0 VAR "Dt. Ref.? " SIZE 100,10 OF oSBox1 PIXEL
odDtRef:= TGet():New(20,85,{|u| if(PCount()>0,dDtRef:=u,dDtRef)},oSBox1,50,05,'@D 99/9999',{|o|},,,,,,.T.,,,,,,,,,	 ,'dDtRef')

@ 41,20 SAY oSay1 VAR "Dias? " SIZE 100,10 OF oSBox1 PIXEL
onDias:= TGet():New(40,85,{|u| if(PCount()>0,nDias:=u,nDias)},oSBox1,50,05,'@R 99',{|o|},,,,,,.T.,,,,,,,,,	 ,'nDias')

@ 61,20 SAY oSay2 VAR "Mat. De? " SIZE 100,10 OF oSBox1 PIXEL
ocMatDe:= TGet():New(60,85,{|u| If(PCount()>0,cMatDe:=u,cMatDe)},oSBox1,50,05,'',{|o|},,,,,,.T.,,,,,,,,,"SRA",'cMatDe')

@ 81,20 SAY oSay3 VAR "Mat. Ate? " SIZE 100,10 OF oSBox1 PIXEL
ocMatAte:= TGet():New(80,85,{|u| If(PCount()>0,cMatAte:=u,cMatAte)},oSBox1,50,05,'',{|o|},,,,,,.T.,,,,,,,,,"SRA",'cMatAte')
                                       
@ 101,20 SAY oSay5 VAR "Força Recalc? " SIZE 100,10 OF oSBox1 PIXEL 
oCombo1:= tComboBox():New(100,85,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aItens1,100,20,oSBox1,,{||},,,,.T.,,,,,,,,,'cCombo1')

@ 121,20 SAY oSay6 VAR "Recalc c/ Travas? " SIZE 100,10 OF oSBox1 PIXEL 
oCombo1:= tComboBox():New(120,85,{|u|if(PCount()>0,cCombo2:=u,cCombo2)},aItens1,100,20,oSBox1,,{||},,,,.T.,,,,,,,,,'cCombo2')
      

//--> PANEL 5
oWizBenef:NewPanel( "Parametros", "Selecione os Beneficios.",{ ||.T.}/*<bBack>*/, {|| ValSel()}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

oGrpBen := TGroup():New( 004,004,134,296,"Marque os Beneficios para Calculo",oWizBenef:oMPanel[5],,,.T.,.F. )
                              
aCpBen := {	{"WKMARCA" 	,"C",01,0},;
			{"CODIGO"	,"C",03,0},;
	    	{"NOME"		,"C",20,0}}
       
If Select("TMPBEN") > 0
	TMPBEN->(DbClosearea())
Endif     	      

cArqTmp := CriaTrab(aCpBen,.T.)
DbUseArea(.T.,"DBDCDX",cArqTmp,"TMPBEN",.T.,.F.)
 
Z64->(DbGoTop())
While Z64->(!EOF())
	If ALLTRIM(Z64->Z64_TABELA) == "SX" .and. ALLTRIM(Z64->Z64_CHAVE) == "BENEFICIO"
		TMPBEN->(DbAppend())
		TMPBEN->WKMARCA	:= "1"
		TMPBEN->CODIGO 	:= Z64->Z64_DESCRI
		TMPBEN->NOME 	:= Z64->Z64_CONT1
		TMPBEN->(MsUnLock())
	EndIf
	Z64->(DbSkip())	
EndDo
       
DEFINE FWBROWSE oBrowAux DATA TABLE ALIAS "TMPBEN" OF oGrpBen

ADD MARKCOLUMN oColumn DATA { || If(WKMARCA=="1",'LBOK',IIF(WKMARCA=="2",'LBNO',)) } DOUBLECLICK { |oBrowAux| MarcBro()}  HEADERCLICK { |oBrowEmp| MarcBroAll("TMPBEN")} OF oBrowAux		
ADD COLUMN oColumn DATA { || CODIGO	} TITLE "Codigo"  			DOUBLECLICK  {||  }  SIZE 03 OF oBrowAux 
ADD COLUMN oColumn DATA { || NOME 	} TITLE "Nome"  		  	DOUBLECLICK  {||  }  SIZE 20 OF oBrowAux 

oBrowAux:LOPTIONCONFIG := .F.
oBrowAux:LOPTIONREPORT := .F.
oBrowAux:LLOCATE := .F.

ACTIVATE FWBROWSE oBrowAux
                                                                                              
//--> PANEL 6
oWizBenef:NewPanel( "Processamento", "",{ ||.T.}/*<bBack>*/, /*<bNext>*/, /*<bFinish>*/, /*<.lPanel.>*/, {|| MainProc(@oWizBenef)}/*<bExecute>*/ )

@ 21,20 SAY oSayTxt VAR ""  SIZE 100,10 OF oWizBenef:oMPanel[6] PIXEL
nMeter := 0
oMeter := TMeter():New(31,20,{|u|if(Pcount()>0,nMeter:=u,nMeter)},0,oWizBenef:oMPanel[6],250,34,,.T.,,,,,,,,,)
oMeter:Set(0) 

nMeter2 := 0
oMeter2 := TMeter():New(51,20,{|u|if(Pcount()>0,nMeter2:=u,nMeter2)},0,oWizBenef:oMPanel[6],250,34,,.T.,,,,,,,,,)
oMeter2:Set(0)

oWizBenef:Activate( .T./*<.lCenter.>*/,/*<bValid>*/, /*<bInit>*/, /*<bWhen>*/ )

Return	                   

/*
Funcao      : MarcBro()  
Parametros  : 
Retorno     : 
Objetivos   : Marca tela de Beneficios
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------*
Static function MarcBro()
*--------------------------------*
Local cRec	:= TMPBEN->(RECNO())

TMPBEN->(DbGoTo(cRec))

RecLock("TMPBEN",.F.)
	TMPBEN->WKMARCA:=IIF(TMPBEN->WKMARCA=="1","2","1") 
TMPBEN->(MsUnlock())

Return .T.

/*
Funcao      : MarcBroEmp()  
Parametros  : 
Retorno     : 
Objetivos   : Marca tela de Empresas.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------*
Static function MarcBroEmp()
*--------------------------------*
Local cRec	:= TMPEMP->(RECNO())

TMPEMP->(DbGoTo(cRec))

RecLock("TMPEMP",.F.)
	TMPEMP->WKMARCA:=IIF(TMPEMP->WKMARCA=="1","2","1") 
TMPEMP->(MsUnlock())

Return .T.

/*
Funcao      : MarcBroAll()  
Parametros  : 
Retorno     : 
Objetivos   : Marca /Desmarca Todos FwBrowse
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*--------------------------------*
Static function MarcBroAll(cAlias)
*--------------------------------*
Local cAux := ""
(cAlias)->(DbGoTop())

cAux := IIF((cAlias)->WKMARCA=="1","2","1")

While (cAlias)->(!EOF())
	(cAlias)->(RecLock(cAlias,.F.))
	(cAlias)->WKMARCA := cAux 
	(cAlias)->(MsUnlock())

	(cAlias)->(DbSkip())
EndDo

If Type("oBrowAux") == "O"
	oBrowAux:Refresh(.T.)
EndIf                    
If Type("oBrowEmp") == "O"
	oBrowEmp:Refresh(.T.)
EndIf

Return .T.

/*
Funcao      : ValSel()  
Parametros  : 
Retorno     : 
Objetivos   : Valida Beneficios Selecionados.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------*
Static Function ValSel()     
*----------------------*
Local lRet := .F.
                     
TMPBEN->(DbGoTop())
While TMPBEN->(!EOF()) .And. !lRet
	If TMPBEN->WKMARCA == "1"
		lRet := .T.
	EndIf 
	TMPBEN->(DbSkip())
EndDo
TMPBEN->(DbGoTop())

If !lRet
	MsgInfo("Selecione ao menos um beneficio para processamento!","Grant Thornton Brasil")
EndIf

Return lRet
      
/*
Funcao      : InWizardEsp()  
Parametros  : 
Retorno     : 
Objetivos   : Wizard inicial Inclusão de Evento Especial
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*---------------------------*
Static Function InWizardEsp()
*---------------------------*
Local lWizEsp := .F.

Private oWizEsp
Private nOpc := GD_INSERT+GD_DELETE+GD_UPDATE
Private aCoBrw1 := {}
Private aHoBrw1 := {}
Private noBrw1  := 0

oWizEsp := APWizard():New("Beneficios", ""/*<chMsg>*/, "Manutenção de Eventos especiais.",;
													"Na rotina de Evento Especial é possível  incluir e/ou alterar solicitações especiais"+CRLF+;
													"especiais ao fornecedor Sodexo, bem como novas vias de cartões, cancelamentos "+CRLF+;
													"ou outros serviços disponíveis."+CRLF+;
													"Obs.: Esta rotina apresenta informações apenas da empresa Logada.",;
												 {||  .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,,,/*<.lNoFirst.>*/ )
          
//Painel 2
oWizEsp:NewPanel( "Parametros", "Parametros para calculo dos Beneficios.",{ ||.T.}/*<bBack>*/, {|| (LoadaCols("ESP",@oBrw1,@oWizEsp),.T.)}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

dDtRef	:= dDataBase

@ 010, 010 TO 125,280 OF oWizEsp:oMPanel[2] PIXEL
oSBox1 := TScrollBox():New( oWizEsp:oMPanel[2],009,009,124,279,.T.,.T.,.T. )

@ 21,20 SAY oSay0 VAR "Dt. Ref.? " SIZE 100,10 OF oSBox1 PIXEL
odDtRef:= TGet():New(20,85,{|u| if(PCount()>0,dDtRef:=u,dDtRef)},oSBox1,50,05,'@D 99/9999',{|o|},,,,,,.T.,,,,,,,,,	 ,'dDtRef')

                                                                                          
//--> PANEL 3
oWizEsp:NewPanel( "Manutenção", "",{ ||.F.}/*<bBack>*/,/*<bNext>*/, {|| lWizEsp := .T.,.T.}/*<bFinish>*/, /*<.lPanel.>*/, /*<bExecute>*/ )

//Aadd(aHoBrw1je,{Trim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"ALLWAYSTRUE()",SX3->X3_USADO, SX3->X3_TIPO,SX3->X3_F3, SX3->X3_CONTEXT,SX3->X3_CBOX } )
Aadd(aHoBrw1,{"Matricula"	,"MAT" 		,"@!",06,0,"","","C","SRA"		, "" } )     
Aadd(aHoBrw1,{"Nome"  		,"NOME" 	,"@!",20,0,"","","C",""			,""})
Aadd(aHoBrw1,{"Forn.Benef"	,"CFBENEF"	,"@!",03,0,"","","C","BENEFF"	, "" } )
Aadd(aHoBrw1,{"Nome Forn."	,"NFBENEF"	,"@!",20,0,"","","C",""			, "" } )
Aadd(aHoBrw1,{"Cod.Benef."	,"CBENEF"	,"@!",05,0,"","","C","BENEFB"	, "" } )
Aadd(aHoBrw1,{"Desc.Benef"	,"DBENEF"	,"@!",35,0,"","","C",""			, "" } )
Aadd(aHoBrw1,{"Tp groo"		,"TPEV"		,"@!",03,0,"","","C",""			, "","007=Seg. Via - Cartão Danificado;011=Cancelamento por demissão;012=Seg. Via - Erro no nome impresso no cartão.;021=Seg. via - perda ou roubo;023=Primeira via S/ Crédito" } )
Aadd(aHoBrw1,{"Data"		,"DATA"		,""  ,08,0,"","","D",""			, "" } )
Aadd(aHoBrw1,{"Rec"			,"RECZ33"	,""  ,15,0,"","","N",""			, "" } )
noBrw1:= Len(aHoBrw1)

aAlter := {"MAT","CFBENEF","CBENEF","TPEV","DATA"}
                                                                                                 
oGrp := TGroup():New( 004,004,134,296,"Informe os Eventos!",oWizEsp:oMPanel[3],,,.T.,.F. )

oBrw1 := MsNewGetDados():New(012,008,130,292,nOpc,'AllwaysTrue()','AllwaysTrue()','',aAlter,0,999,'U_GTGENVLD()','','AllwaysTrue()',oGrp,aHoBrw1,aCoBrw1 )

oWizEsp:Activate( .T./*<.lCenter.>*/,/*<bValid>*/, /*<bInit>*/, /*<bWhen>*/ )

If lWizEsp
	For b:=1 to Len(oBrw1:ACOLS)
		If !oBrw1:ACOLS[b][Len(oBrw1:ACOLS[b])]
			If oBrw1:ACOLS[b][Len(oBrw1:ACOLS[b])-1] <> 0//Posição do Recno
				Z33->(DbSetOrder(1))
				Z33->(DbGoTo(oBrw1:ACOLS[b][Len(oBrw1:ACOLS[b])-1]))
				Z33->(RecLock("Z33",.F.))
			Else
				Z33->(RecLock("Z33",.T.))
			EndIf 
			Z33->Z33_FILIAL		:= xFilial("Z33")
			Z33->Z33_MAT 		:= oBrw1:ACOLS[b][1]
			Z33->Z33_FORN 		:= oBrw1:ACOLS[b][3]
			Z33->Z33_COD 		:= oBrw1:ACOLS[b][5]
			Z33->Z33_DESCR 		:= oBrw1:ACOLS[b][6]
			Z33->Z33_TIPO 		:= STRTRAN(oBrw1:ACOLS[b][7],"0"," ")
			Z33->Z33_DATA 		:= oBrw1:ACOLS[b][8]
			Z33->Z33_DTHR  		:= DTOC(dDataBase)+"-"+LEFT(TIME(),5)    
			Z33->Z33_USER		:= LEFT(cUserName,20)

			Z33->(MsUnlock())
		ElseIf oBrw1:ACOLS[b][Len(oBrw1:ACOLS[b])-1] <> 0//Posição do Recno
			Z33->(DbSetOrder(1))
			Z33->(DbGoTo(oBrw1:ACOLS[b][Len(oBrw1:ACOLS[b])-1]))
			Z33->(RecLock("Z33",.F.))
			Z33->(DbDelete())
			Z33->(MsUnlock())
		EndIf
	Next i
EndIf

Return .T.   

/*
Funcao      : GTGENVLD
Parametros  : 
Retorno     : 
Objetivos   : validar campo do getdados
Autor       : Jean Victor Rocha
Data/Hora   : 
TDN         : 
*/
*-------------------------------*
User Function GTGENVLD()
*-------------------------------*
Local lRet := .T.
Local i

Do case               
	Case __READVAR == "M->PERC"
		nValor := aCols[oBrw1:NAT][aScan(aHoBrw1,{|x| x[2] == "VALOR"})]
		aCols[oBrw1:NAT][aScan(aHoBrw1,{|x| x[2] == "VALORDES"})] := (nValor*M->PERC)/100
		
	Case __READVAR == "M->VALORDES"
		nValor := aCols[oBrw1:NAT][aScan(aHoBrw1,{|x| x[2] == "VALOR"})]
		aCols[oBrw1:NAT][aScan(aHoBrw1,{|x| x[2] == "PERC"})] := (M->VALORDES*100)/nValor

	Case __READVAR == "M->MAT"
		aOrd:= SaveOrd({"SRA"})
		SRA->(DbSetOrder(1))//RA_FILIAL+RA_MAT
		If SRA->(DbSeek(xFilial("SRA")+M->MAT))
			aCols[oBrw1:NAT][aScan(aHoBrw1,{|x| x[2] == "NOME"})] := SRA->RA_NOME
	    Else
			M->MAT := SPACE(aHoBrw1[aScan(aHoBrw1,{|x| x[2] == "MAT"})][4])
			lRet := .F.
	    EndIf
		RestOrd(aOrd)

	Case __READVAR == "M->CFBENEF"
		Z64->(DbSetOrder(2))//Z64_FILIAL+Z64_TABELA+Z64_CHAVE+Z64_CONT1
		If Z64->(DbSeek("  "+"COD"+M->CFBENEF))
			aCols[oBrw1:NAT][aScan(aHoBrw1,{|x| x[2] == "NFBENEF"})] := Z64->Z64_DESCRI
		Else
			M->CFBENEF := SPACE(aHoBrw1[aScan(aHoBrw1,{|x| x[2] == "CFBENEF"})][4])
			lRet := .F.
		EndIf

	Case __READVAR == "M->CBENEF"
		Z64->(DbSetOrder(1))//Z64_FILIAL+Z64_TABELA+Z64_CHAVE+Z64_DESCRI
		If Z64->(DbSeek("  "+aCols[oBrw1:NAT][aScan(aHoBrw1,{|x| x[2] == "CFBENEF"})]+"BENEFICIO "+M->CBENEF))
			aCols[oBrw1:NAT][aScan(aHoBrw1,{|x| x[2] == "DBENEF"})] := Z64->Z64_CONT1
		Else
			M->CBENEF := SPACE(aHoBrw1[aScan(aHoBrw1,{|x| x[2] == "CBENEF"})][4])
			aCols[oBrw1:NAT][aScan(aHoBrw1,{|x| x[2] == "DBENEF"})] := SPACE(aHoBrw1[aScan(aHoBrw1,{|x| x[2] == "DBENEF"})][4])
			lRet := .F.
		EndIf
EndCase
Return lRet

/*
Funcao     : LoadaCols
Parametros : Nenhum
Retorno    : 
Objetivos  : Carregar Informações do aCols
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*-------------------------------------------*
Static Function LoadaCols(cRot,oBrw1,oWizXXX)        
*-------------------------------------------*

	If !TcCanOpen(RetSQLName("Z64"))
		MsgInfo("Falha na Abertura da tabela 'Z64'!","Grant Thornton Brasil")
		oWizXXX:ODLG:END()
		Return .T.
	EndIf

	oWizXXX:OBACK:LVISIBLECONTROL		:= .F.
	oWizXXX:OCANCEL:BACTION := {|| IIF(MSGYESNO("Deseja sair e perder as alterações?","Grant Thornton Brasil") ,oWizXXX:ODLG:END(),) }
	                    
	cQuery:= "Select *
	cQuery += " From "+RetSQLName("SRA")+" SRA 
	cQuery += " 			Left Outer Join (	Select *,R_E_C_N_O_ as RECZ33 
	cQuery += " 		  						From "+RetSQLName("Z33")
	cQuery += " 								Where D_E_L_E_T_ <> '*' AND 
	If !EMPTY(dDtRef)
		cQuery += " 												 	Z33_DATA >= '"+STRZERO(YEAR(dDtRef),4)+STRZERO(MONTH(dDtRef),2)+"01' AND 
		cQuery += " 													Z33_DATA <= '"+STRZERO(YEAR(dDtRef),4)+STRZERO(MONTH(dDtRef),2)+"31' AND
	EndIf
	cQuery += " 														Z33_FORN = 'SX') as Z33 
	cQuery += " 																				on 	SRA.RA_FILIAL = Z33.Z33_FILIAL
	cQuery += " 																		   			AND SRA.RA_MAT = Z33.Z33_MAT
	cQuery += " 			Left Outer Join (Select * 
	cQuery += " 							From "+RetSQLName("Z64")
	cQuery += " 							Where D_E_L_E_T_ <> '*' AND
	cQuery += " 								Z64_TABELA = 'COD') as Z64
	cQuery += " 													On Z33.Z33_FORN = Z64.Z64_CHAVE
	cQuery += " Where SRA.D_E_L_E_T_ <> '*'
	cQuery += " AND Z33.Z33_FORN <> ''
	If cRot == "ESP"
		cQuery += " AND Z33.Z33_TIPO <> '  1' AND Z33.Z33_TIPO <> '  C'
	Else
		cQuery += " AND (Z33.Z33_TIPO = '  1' OR Z33.Z33_TIPO = '  C' )
	EndIf                         
	If cRot <> "DES"         
		cQuery += " AND Z33.Z33_TRAVA <> 'S'
		cQuery += " AND SRA.RA_FILIAL = '"+xFilial("Z33")+"'
	EndIF
	cQuery += " AND SRA.RA_DEMISSA = ''
	                   
	If Select("QRY") > 0
		QRY->(DbClosearea())
	Endif     	             	
	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
	        
	QRY->(DbGoTop())
	While QRY->(!EOF())               
		If cRot == "ESP"
			aAdd(aCoBrw1,{	QRY->Z33_MAT,;		//"Matricula"
							QRY->RA_NOME,;		//"Nome
							QRY->Z33_FORN,;		//"Fornec
							QRY->Z64_DESCRI,;	//"Descr."
							QRY->Z33_COD,;		//"Benef
							QRY->Z33_DESCR,;	//"Descr."
							STRTRAN(QRY->Z33_TIPO," ","0"),;//"Tp Evento"
							STOD(QRY->Z33_DATA),;//"Data"
							QRY->RECZ33,;		//Recno
							.F.})				//DELET
		ElseIf cRot == "MAN"
			aAdd(aCoBrw1,{	QRY->Z33_MAT,;		//"Matricula"
							QRY->RA_NOME,;		//"Nome
							QRY->Z33_FORN,;		//"Fornec
							QRY->Z64_DESCRI,;	//"Descr."
							QRY->Z33_COD,;		//"Benef
							QRY->Z33_DESCR,;	//"Descr."
							QRY->Z33_QTDE,;		//"Dias"
							QRY->Z33_VALOR,;	//"Valor"
							STOD(QRY->Z33_DATA),;//"Data"
							QRY->RECZ33,;		//Recno
							.F.})				//DELET
		ElseIf cRot == "DES"
			aAdd(aCoBrw1,{	nPercPad,;		//"Percentual"
							(QRY->Z33_VALOR*nPercPad)/100,;		//"Valor desconto"
							QRY->RA_FILIAL,;	//"Filial"
							QRY->Z33_MAT,;		//"Matricula"
							QRY->RA_NOME,;		//"Nome
							QRY->Z33_FORN,;		//"Fornec
							QRY->Z64_DESCRI,;	//"Descr."
							QRY->Z33_COD,;		//"Benef
							QRY->Z33_DESCR,;	//"Descr."
							QRY->Z33_QTDE,;		//"Dias"
							QRY->Z33_VALOR,;	//"Valor"
							STOD(QRY->Z33_DATA),;//"Data"
							QRY->RECZ33,;		//Recno
							.F.})				//DELET
		EndIf

	
		QRY->(DbSkip())		
	EndDo

	If Len(aCoBrw1) == 0 .And. cRot == "ESP"
		aAdd(aCoBrw1,{	Space(aHoBrw1[1][4]),;//"Matricula"
						Space(aHoBrw1[2][4]),;//"Nome
						"SX ",;//"Fornec
						"Sodexo",;//"Descr."
						Space(aHoBrw1[5][4]),;//"Benef
						Space(aHoBrw1[6][4]),;//"Descr."
						Space(aHoBrw1[7][4]),;//"Tp Evento"
						dDtRef,;//"Data"
						0,;//Recno
						.F.})	//DELET
	ElseIf Len(aCoBrw1) == 0
		MsgInfo("Sem Dados!","Grant Thornton Brasil")
	EndIf
	
	oBrw1:ACOLS := aCoBrw1
	
Return .T.

/*
Funcao     : MainProc
Parametros : Nenhum
Retorno    : 
Objetivos  : Processamento de Calculo de Beneficios.
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*---------------------------------*
Static Function MainProc(oWizBenef)
*---------------------------------*
Local cLog := ""
Local nMsgErro := ""
Local cQuery := ""        
Local oFont := TFont():New("Courier New",09,15)
Local aEmpProc := {}

cLog += "Log de processamento de Calculo Sodexo: "+CHR(13)+CHR(10)

oWizBenef:OBACK:LVISIBLECONTROL		:= .F.
oWizBenef:OCANCEL:LVISIBLECONTROL	:= .F.
oWizBenef:ONEXT:LVISIBLECONTROL		:= .F.
oWizBenef:OFINISH:LVISIBLECONTROL	:= .F.

TMPEMP->(DbGoTop())
While TMPEMP->(!EOF())
	If TMPEMP->WKMARCA == "1"//cMarca
		If (nPos := aScan(aEmpProc, {|x| x[1] == TMPEMP->M0_CODIGO})) <> 0
			aAdd(aEmpProc[nPos][2],TMPEMP->M0_CODFIL)
		Else
			aAdd(aEmpProc,{TMPEMP->M0_CODIGO,{TMPEMP->M0_CODFIL},TMPEMP->M0_NOME})
		EndIf
	EndIf 
	TMPEMP->(DbSkip())
EndDo

If Len(aEmpProc) == 0
	oSayTxt:CCAPTION := "Não Foi possivel carregar empresas!"	
	oMeter:LVISIBLE := .F. 
	oMeter2:LVISIBLE := .F.
	oWizBenef:OBACK:LVISIBLECONTROL		:= .T.
	oWizBenef:OCANCEL:LVISIBLECONTROL	:= .T.
	oWizBenef:ONEXT:LVISIBLECONTROL		:= .T.
	oWizBenef:OFINISH:LVISIBLECONTROL	:= .T.
	Return .T. 
Else
	oSayTxt:CCAPTION := "Aguarde..."
	oMeter:LVISIBLE := .T.
	oMeter2:LVISIBLE := .T.
	oWizBenef:OBACK:LVISIBLECONTROL		:= .F.
	oWizBenef:OCANCEL:LVISIBLECONTROL	:= .F.
	oWizBenef:ONEXT:LVISIBLECONTROL		:= .F.
	oWizBenef:OFINISH:LVISIBLECONTROL	:= .F.
EndIf

oMeter:NTOTAL := Len(aEmpProc)
     
//Ordena o Array com as Empresas
aSort(aEmpProc)
                         
For i:=1 to Len(aEmpProc)
	oMeter:Set(i)

    cLog +=CHR(13)+CHR(10)
    cLog += "*** Empresa: "+aEmpProc[i][1]+"-"+ALLTRIM(aEmpProc[i][3])+CHR(13)+CHR(10)
    
    If !TcCanOpen("Z71"+aEmpProc[i][1]+"0")
		cLog += "Tabela Z71"+aEmpProc[i][1]+"0 não encontrada, execute a rotina na Empresa para Criação!"+CHR(13)+CHR(10)
		Loop
    EndIf
    
    If !TcCanOpen("Z33"+aEmpProc[i][1]+"0")
		cLog += "Tabela Z33"+aEmpProc[i][1]+"0 não encontrada, execute a rotina na Empresa para Criação!"+CHR(13)+CHR(10)
		Loop
    EndIf

	TMPBEN->(DbGoTop())
	While TMPBEN->(!EOF())
		
		If TMPBEN->WKMARCA == "2"
			TMPBEN->(DbSkip())
			Loop		
		EndIf   

	    cLog += " # Beneficio: '"+TMPBEN->CODIGO+"'"+CHR(13)+CHR(10)
		
		cQuery := ""
		cQuery += " From SRA"+aEmpProc[i][1]+"0"+" SRA 
		cQuery += " 			Left Outer Join (	Select * 
		cQuery += " 		  						From Z71"+aEmpProc[i][1]+"0 
		cQuery += " 								Where D_E_L_E_T_ <> '*' AND Z71_FORN = 'SX'
		cQuery += "															AND Z71_COD = '"+TMPBEN->CODIGO+"'
		cQuery += "								) as Z71 on 	SRA.RA_FILIAL = Z71.Z71_FILIAL
		cQuery += " 											AND SRA.RA_MAT = Z71.Z71_MAT
		If aItens1[2] == cCombo2 .and. lCheck1
			cQuery += "			Left outer Join (Select *  		  						
			cQuery += "							From Z33"+aEmpProc[i][1]+"0
			cQuery += "							Where D_E_L_E_T_ <> '*' 
			cQuery += "									AND Z33_DATA >= '"+STRZERO(YEAR(dDtRef),4)+STRZERO(MONTH(dDtRef),2)+"01'
			cQuery += "									AND Z33_DATA <= '"+STRZERO(YEAR(dDtRef),4)+STRZERO(MONTH(dDtRef),2)+"31'
			cQuery += "							) as Z33 On SRA.RA_FILIAL = Z33.Z33_FILIAL 																		   			
			cQuery += "										AND SRA.RA_MAT = Z33.Z33_MAT
			cQuery += "										AND Z71.Z71_FORN = Z33.Z33_FORN 
		EndIf
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
		cQuery += " AND Z71.Z71_FORN <> ''
	
		//Filiais Selecionadas na Tela de Empresas.
		cQuery += " AND ( 		
		for j:=1 to Len(aEmpProc[i][2])
			cQuery += " SRA.RA_FILIAL = '"+aEmpProc[i][2][j]+"' OR
		Next j
		cQuery := LEFT(cQuery,LEN(cQuery)-2)//Retira o OR
		cQuery += " )
		If !EMPTY(cMatDe)   
			cQuery += " AND SRA.RA_MAT >= '"+ALLTRIM(cMatDe)+"' 
		EndIf
		If !EMPTY(cMatAte)  
			cQuery += " AND SRA.RA_MAT <= '"+ALLTRIM(cMatAte)+"' 
		EndIf  
		
		If aItens1[2] == cCombo2 .and. lCheck1
			cQuery += " AND (Z33.Z33_TRAVA <> 'S' OR Z33.Z33_TRAVA is Null)
		EndIf  
		cQuery += " AND SRA.RA_DEMISSA = ''
		
		//Contagem de Registros:
		If Select("QRY") > 0
			QRY->(DbClosearea())
		Endif     	       
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,"Select COUNT(*) as COUNT "+cQuery),"QRY",.F.,.T.)

		If QRY->COUNT == 0
			cLog += " - Sem Dados para processamento!"+CHR(13)+CHR(10)
			TMPBEN->(DbSkip())
			loop
		EndIf

		nRegs := QRY->COUNT
		oMeter2:NTOTAL := QRY->COUNT
		
		cQuery:= "Select * "+cQuery+" Order By SRA.RA_FILIAL,SRA.RA_MAT
		
		//Criação do Arquivo temporario com os Registros.
		If Select("QRY") > 0
			QRY->(DbClosearea())
		Endif     	             	
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
		  
		Z33->(DbSetOrder(1))//Z33_FILIAL+Z33_MAT+DTOS(Z33_DATA)
		
		nReg	:= nReproc	:= nGrav	:= 0//Contadores para o While
		nTotal	:= nMax		:= 0			//ACumuladores para o While
		nMin 	:= 99999					//ACumuladores para o While
		n := 0
		While QRY->(!EOF())
			nReg++
			n++
			oMeter2:Set(n)
			lSeek := .F.
	
			If Select("TMP") > 0
				TMP->(DbClosearea())
			Endif
	
			cQry := ""
			cQry += " Where D_E_L_E_T_ <> '*'
			cQry += "		AND Z33_FILIAL = '"+QRY->RA_FILIAL+"'
			cQry += " 		AND Z33_MAT = '"+QRY->RA_MAT+"'
			cQry += " 	    AND Z33_TIPO = '  1'
			cQry += "		AND Z33_COD = '"+TMPBEN->CODIGO+"'
			cQry += "		AND Z33_DATA >= '"+STRZERO(YEAR(dDtRef),4)+STRZERO(MONTH(dDtRef),2)+"01'
			cQry += " 		AND Z33_DATA <= '"+STRZERO(YEAR(dDtRef),4)+STRZERO(MONTH(dDtRef),2)+"31'
	
			dbUseArea(.T.,"TOPCONN", TCGENQRY(,,"Select COUNT(*) as COUNT From Z33"+aEmpProc[i][1]+"0 "+cQry),"TMP",.F.,.T.)
	                                                            
			If TMP->COUNT <> 0 .and. lCheck1
				lSeek := .T.                    
				If aItens1[1] == cCombo1
					TCSQLExec("Update Z33"+aEmpProc[i][1]+"0 Set D_E_L_E_T_ = '*' "+cQry)
					nReproc += TMP->COUNT
				EndIf
			EndIf		
	        
	   		If (lSeek .And. aItens1[1] == cCombo1) .or. !lSeek
				If Select("TMP") > 0
					TMP->(DbClosearea())
				Endif
				cQry := " Select ISNULL(MAX(R_E_C_N_O_)+1,1) AS NEWREC From Z33"+aEmpProc[i][1]+"0
				dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQry),"TMP",.F.,.T.)			
	
				cQry := " Insert into Z33"+aEmpProc[i][1]+"0
				cQry += " (Z33_FILIAL,Z33_MAT,Z33_FORN,Z33_COD,Z33_DESCR,Z33_DATA,Z33_QTDE,Z33_VALOR,Z33_DTHR,Z33_USER,Z33_TIPO,R_E_C_N_O_)
				cQry += " Values (	  '"+QRY->RA_FILIAL	+"','"+QRY->RA_MAT+"','"+QRY->Z71_FORN+"','"+ALLTRIM(QRY->Z71_COD)+"','"+ALLTRIM(QRY->Z71_DESCR)+"'"+;
									",'"+DTOS(dDtRef)	+"',"+ALLTRIM(STR(nDias))+",'"+ALLTRIM(STR(QRY->Z71_VALOR*QRY->Z71_QTDE*nDias))+"'"+;
									",'"+DTOC(dDataBase)+"-"+LEFT(TIME(),5)+"','"+LEFT(cUserName,20)+"','  "+IIF(lCheck1,"1","C")+"',"+;
									ALLTRIM(STR(TMP->NEWREC))+")
	        
				nLog := TCSQLExec(cQry)
				If nLog <0
					conout("ERRO INSERT GTGEN021:"+TCSQLError())
					cLog += " > Falha no Processamento < "+CHR(13)+CHR(10)+TCSQLError()+CHR(13)+CHR(10)
				EndIf
			
				nTotal 	+= 			QRY->Z71_VALOR * QRY->Z71_QTDE * nDias
				nMin 	:= MIN(nMin,QRY->Z71_VALOR * QRY->Z71_QTDE * nDias)
				nMax 	:= MAX(nMax,QRY->Z71_VALOR * QRY->Z71_QTDE * nDias)
				nGrav++
			EndIf
			QRY->(DbSkip())
		EndDo              
		cLog += " - Registros processados: "+ALLTRIM(STR(nReg))+"/"+ALLTRIM(STR(nRegs))+CHR(13)+CHR(10)
		cLog += " - Registros Gravados: "+ALLTRIM(STR(nGrav))+CHR(13)+CHR(10)
		cLog += " - Registros Deletados(reprocessamento): "+ALLTRIM(STR(nReproc))+CHR(13)+CHR(10)
		cLog += " - Valor Total do Calculo: "+Transform(nTotal, "@R 99,999,999.99")+CHR(13)+CHR(10)		
		TMPBEN->(DbSkip())
	EndDo

Next i

oSayTxt:CCAPTION := "Processamento Finalizado!"

@ 30,20 Get oMemo Var cLog MEMO HSCROLL FONT oFont Size 265,108 READONLY Of oWizBenef:oMPanel[5]  Pixel
oMemo:lWordWrap := .F.
oMemo:EnableVScroll(.t.)
oMemo:EnableHScroll(.t.)

oMeter:LVISIBLE := .F. 
oMeter2:LVISIBLE := .F.

oWizBenef:OFINISH:LVISIBLECONTROL	:= .T.

Return .T.                      

/*
Funcao     : ProcXML
Parametros : Nenhum
Retorno    : 
Objetivos  : Cria o Arquivo XML para impressão do Relatorio.
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*------------------------------*
Static Function ProcXML(oWizRel)
*------------------------------*
Local cXml := ""
Local nPos	:= 0
Local aEmpProc := {}
                    
//Inicializa o Arquivo
IF FILE (cDest+cArq)
	FERASE (cDest+cArq)
ENDIF

nHdl 		:= FCREATE(cDest+cArq,0 )  	//Criação do Arquivo .
nBytesSalvo := FWRITE(nHdl, cXML ) 		// Gravação do seu Conteudo.
fclose(nHdl)						// Fecha o Arquivo que foi Gerado	
                                              
TMPEMP->(DbGoTop())
While TMPEMP->(!EOF())
	If TMPEMP->WKMARCA == cMarca
		If (nPos := aScan(aEmpProc, {|x| x[1] == TMPEMP->M0_CODIGO})) <> 0
			aAdd(aEmpProc[nPos][2],TMPEMP->M0_CODFIL)
		Else
			aAdd(aEmpProc,{TMPEMP->M0_CODIGO,{TMPEMP->M0_CODFIL},TMPEMP->M0_FILIAL})
		EndIf
	EndIf 
	TMPEMP->(DbSkip())
EndDo
 
If Len(aEmpProc) == 0
	oSayTxt:CCAPTION := "Não Foi possivel carregar empresas!"	
	oMeter:LVISIBLE := .F. 
	oMeter2:LVISIBLE := .F.
	oWizRel:OBACK:LVISIBLECONTROL		:= .T.
	oWizRel:OCANCEL:LVISIBLECONTROL	:= .T.
	oWizRel:ONEXT:LVISIBLECONTROL		:= .T.
	oWizRel:OFINISH:LVISIBLECONTROL	:= .T.
	Return .T. 
Else
	oSayTxt:CCAPTION := "Aguarde..."
	oMeter:LVISIBLE := .T.
	oMeter2:LVISIBLE := .T.
	oWizRel:OBACK:LVISIBLECONTROL		:= .F.
	oWizRel:OCANCEL:LVISIBLECONTROL	:= .F.
	oWizRel:ONEXT:LVISIBLECONTROL		:= .F.
	oWizRel:OFINISH:LVISIBLECONTROL	:= .F.
EndIf

oMeter:NTOTAL := Len(aEmpProc)
     
//Ordena o Array com as Empresas
aSort(aEmpProc)

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
cXml += '  <Style ss:ID="s62">
cXml += '   <NumberFormat ss:Format="@"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s63">
cXml += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml += '   <NumberFormat ss:Format="@"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s64">
cXml += '   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXml += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml += '   <NumberFormat ss:Format="@"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s66">
cXml += '   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#000000" ss:Bold="1"/>
cXml += '   <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
cXml += '   <NumberFormat ss:Format="@"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s67">
cXml += '   <Borders>
cXml += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#7030A0"/>
cXml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#7030A0"/>
cXml += '   </Borders>
cXml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF" ss:Bold="1"/>
cXml += '   <Interior ss:Color="#7030A0" ss:Pattern="Solid"/>
cXml += '   <NumberFormat ss:Format="@"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s68">
cXml += '   <Borders>
cXml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#7030A0"/>
cXml += '   </Borders>
cXml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF" ss:Bold="1"/>
cXml += '   <Interior ss:Color="#7030A0" ss:Pattern="Solid"/>
cXml += '   <NumberFormat ss:Format="@"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s69">
cXml += '   <Borders>
cXml += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#7030A0"/>
cXml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#7030A0"/>
cXml += '   </Borders>
cXml += '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF" ss:Bold="1"/>
cXml += '   <Interior ss:Color="#7030A0" ss:Pattern="Solid"/>
cXml += '   <NumberFormat ss:Format="@"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s70">
cXml += '   <Borders>
cXml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#7030A0"/>
cXml += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#7030A0"/>
cXml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#7030A0"/>
cXml += '   </Borders>
cXml += '   <NumberFormat ss:Format="@"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s71">
cXml += '   <Borders>
cXml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#7030A0"/>
cXml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#7030A0"/>
cXml += '   </Borders>
cXml += '   <NumberFormat ss:Format="@"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s72">
cXml += '   <Borders>
cXml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#7030A0"/>
cXml += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#7030A0"/>
cXml += '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#7030A0"/>
cXml += '   </Borders>
cXml += '   <NumberFormat ss:Format="@"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s73">
cXml += '   <Borders>
cXml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#7030A0"/>
cXml += '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#7030A0"/>
cXml += '   </Borders>
cXml += '   <NumberFormat ss:Format="@"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s74">
cXml += '   <Borders>
cXml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#7030A0"/>
cXml += '   </Borders>
cXml += '   <NumberFormat ss:Format="@"/>
cXml += '  </Style>
cXml += '  <Style ss:ID="s75">
cXml += '   <Borders>
cXml += '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#7030A0"/>
cXml += '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#7030A0"/>
cXml += '   </Borders>
cXml += '   <NumberFormat ss:Format="@"/>
cXml += '  </Style>
cXml += ' </Styles>

lFirst := .T.
For i:=1 to Len(aEmpProc)
	oMeter:Set(i)
	If TcCanOpen("Z33"+aEmpProc[i][1]+"0")	
		oMeter2:Set(0)
		nMeter2 := 0
		
		cQuery := ""     //Select Esta Abaixo.
		cQuery += " From SRA"+aEmpProc[i][1]+"0"+" SRA 
		cQuery += " 			Left Outer Join (	Select * 
		cQuery += " 		  						From Z33"+aEmpProc[i][1]+"0 
		cQuery += " 								Where
		If  aItens1[2] == cCombo1
			cQuery += " 										D_E_L_E_T_ <> '*' AND 
		EndIF
		If !EMPTY(dDtRef)
			cQuery += " 												 	Z33_DATA >= '"+STRZERO(YEAR(dDtRef),4)+STRZERO(MONTH(dDtRef),2)+"01' AND 
			cQuery += " 													Z33_DATA <= '"+STRZERO(YEAR(dDtRef),4)+STRZERO(MONTH(dDtRef),2)+"31' AND
		EndIf
		cQuery += " 														Z33_FORN = 'SX') as Z33 
		cQuery += " 																				on 	SRA.RA_FILIAL = Z33.Z33_FILIAL
		cQuery += " 																		   			AND SRA.RA_MAT = Z33.Z33_MAT
		cQuery += " Where SRA.D_E_L_E_T_ <> '*'
		cQuery += " AND Z33.Z33_FORN <> ''
				
		cQuery += " AND ( 		
			for j:=1 to Len(aEmpProc[i][2])
				cQuery += " SRA.RA_FILIAL = '"+aEmpProc[i][2][j]+"' OR
			Next j
		cQuery := LEFT(cQuery,LEN(cQuery)-2)//Retira o OR
		cQuery += " )
		
		If !EMPTY(cMatDe)   
			cQuery += " AND SRA.RA_MAT >= '"+ALLTRIM(cMatDe)+"' 
		EndIf
		If !EMPTY(cMatAte)  
			cQuery += " AND SRA.RA_MAT <= '"+ALLTRIM(cMatAte)+"' 
		EndIf 

		cQuery += " AND SRA.RA_DEMISSA = ''

		//Contador de Registros
		If Select("QRY") > 0
			QRY->(DbClosearea())
		Endif     	       
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,"Select COUNT(*) as COUNT "+cQuery),"QRY",.F.,.T.)
		
		oMeter2:NTOTAL := QRY->COUNT
                   
		cQuery:= "Select *,Z33.D_E_L_E_T_ as DEL "+cQuery
		If Select("QRY") > 0
			QRY->(DbClosearea())
		Endif     	             	
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)
		
		If LEFT(cCombo2,1) == "1"//Separado Por Abas
			cXml += ' <Worksheet ss:Name="'+ALLTRIM(aEmpProc[i][3])+'">
			cXml += '  <Names>
			cXml += '   <NamedRange ss:Name="_FilterDatabase" ss:RefersTo="='+ALLTRIM(aEmpProc[i][3])+'!R4C1:R4C11" ss:Hidden="1"/>
			cXml += '  </Names>
			cXml += '  <Table ss:ExpandedColumnCount="22" ss:ExpandedRowCount="20000" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">
			cXml += '   <Column ss:StyleID="s62" ss:Width="39.75"/>
			cXml += '   <Column ss:StyleID="s62" ss:Width="61.5"/>
			cXml += '   <Column ss:StyleID="s62" ss:Width="160"/>
			cXml += '   <Column ss:StyleID="s62" ss:Width="70.5"/>
			cXml += '   <Column ss:StyleID="s62" ss:Width="85.5"/>
			cXml += '   <Column ss:StyleID="s62" ss:Width="108"/>
			cXml += '   <Column ss:StyleID="s62" ss:Width="47.25"/>
			cXml += '   <Column ss:StyleID="s62" ss:Width="87.75"/>
			cXml += '   <Column ss:StyleID="s62" ss:Width="89.25"/>
			cXml += '   <Column ss:StyleID="s62" ss:Width="81.75"/>
			cXml += '   <Column ss:StyleID="s62" ss:Width="81.75"/>
			cXml += '   <Column ss:StyleID="s62" ss:Width="71.25"/>
			cXml += '   <Column ss:StyleID="s62" ss:Width="65.25"/>
			cXml += '   <Column ss:StyleID="s62" ss:Width="65.25"/>
			cXml += '   <Row ss:AutoFitHeight="0">
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s64"><Data ss:Type="String">'+CharXml("extração:")+'</Data></Cell>
			cXml += '    <Cell ss:StyleID="s63"><Data ss:Type="String">'+DTOC(dDataBase)+'</Data></Cell>
			cXml += '   </Row>
			cXml += '   <Row ss:AutoFitHeight="0" ss:Height="15.75">
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:MergeAcross="3" ss:StyleID="s66"><Data ss:Type="String">Relatorio de Calculo de Beneficios</Data></Cell>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"><Data ss:Type="String">'+LEFT(cUserName,20)+'</Data></Cell>
			cXml += '   </Row>
			cXml += '   <Row ss:AutoFitHeight="0">
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '    <Cell ss:StyleID="s63"/>
			cXml += '   </Row>
			cXml += '   <Row ss:AutoFitHeight="0">
			cXml += '    <Cell ss:StyleID="s67"><Data ss:Type="String">Filial	  		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
			cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Matricula  		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
			cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Nome		  		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
			cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Fornecedor  		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
			cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Cod. Beneficio	</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
			cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Descricao   		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
			cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Data	   			</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
			cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Qtde Beneficio	</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
			cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Valor Beneficio	</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
			cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Tipo				</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
			cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Data Hora log	</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
			cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Usuario Log		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
			cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Detelado?   		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
			cXml += '    <Cell ss:StyleID="s69"><Data ss:Type="String">Arq. Gerado?		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
			cXml += '   </Row>

		ElseIf LEFT(cCombo2,1) == "2"//Em Mesma Planilha
			If lFirst
				lFirst := .F.
				cXml += ' <Worksheet ss:Name="Beneficios">
				cXml += '  <Names>
				cXml += '   <NamedRange ss:Name="_FilterDatabase" ss:RefersTo="=Technology!R4C1:R4C11" ss:Hidden="1"/>
				cXml += '  </Names>
				cXml += '  <Table ss:ExpandedColumnCount="22" ss:ExpandedRowCount="20000" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">
				cXml += '   <Column ss:StyleID="s62" ss:Width="39.75"/>
				cXml += '   <Column ss:StyleID="s62" ss:Width="80.75"/>
				cXml += '   <Column ss:StyleID="s62" ss:Width="61.5"/>
				cXml += '   <Column ss:StyleID="s62" ss:Width="160"/>
				cXml += '   <Column ss:StyleID="s62" ss:Width="70.5"/>
				cXml += '   <Column ss:StyleID="s62" ss:Width="85.5"/>
				cXml += '   <Column ss:StyleID="s62" ss:Width="60"/>
				cXml += '   <Column ss:StyleID="s62" ss:Width="47.25"/>
				cXml += '   <Column ss:StyleID="s62" ss:Width="87.75"/>
				cXml += '   <Column ss:StyleID="s62" ss:Width="89.25"/>
				cXml += '   <Column ss:StyleID="s62" ss:Width="81.75"/>
				cXml += '   <Column ss:StyleID="s62" ss:Width="81.75"/>
				cXml += '   <Column ss:StyleID="s62" ss:Width="71.25"/>
				cXml += '   <Column ss:StyleID="s62" ss:Width="65.25"/>
				cXml += '   <Column ss:StyleID="s62" ss:Width="65.25"/>
				cXml += '   <Row ss:AutoFitHeight="0">
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s64"><Data ss:Type="String">'+CharXml("extração:")+'</Data></Cell>
				cXml += '    <Cell ss:StyleID="s63"><Data ss:Type="String">'+DTOC(dDataBase)+'</Data></Cell>
				cXml += '   </Row>
				cXml += '   <Row ss:AutoFitHeight="0" ss:Height="15.75">
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:MergeAcross="3" ss:StyleID="s66"><Data ss:Type="String">Relatorio de Calculo de Beneficios</Data></Cell>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"><Data ss:Type="String">'+cUserName+'</Data></Cell>
				cXml += '   </Row>
				cXml += '   <Row ss:AutoFitHeight="0">
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '    <Cell ss:StyleID="s63"/>
				cXml += '   </Row>
				cXml += '   <Row ss:AutoFitHeight="0">
				cXml += '    <Cell ss:StyleID="s67"><Data ss:Type="String">Empresa	  		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
				cXml += '    <Cell ss:StyleID="s67"><Data ss:Type="String">Filial	  		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
				cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Matricula  		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
				cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Nome		  		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
				cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Fornecedor  		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
				cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Cod. Beneficio	</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
				cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Descricao   		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
				cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Data	   			</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
				cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Qtde Beneficio	</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
				cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Valor Beneficio	</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
				cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Tipo				</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
				cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Data Hora log	</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
				cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Usuario Log		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
				cXml += '    <Cell ss:StyleID="s68"><Data ss:Type="String">Detelado?   		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
				cXml += '    <Cell ss:StyleID="s69"><Data ss:Type="String">Arq. Gerado?		</Data><NamedCell ss:Name="_FilterDatabase"/></Cell>
				cXml += '   </Row>	
			EndIf
		EndIF                               
		cXml := GrvInfo(cXml,cDest,cArq)
			
		n:=0	
		QRY->(DbGoTop())
		While QRY->(!EOF())
			n++
			oMeter2:Set(n)
			cXml += '   <Row ss:AutoFitHeight="0">
			If LEFT(cCombo2,1) == "2"//Em Mesma Planilha			
				cXml += '    <Cell ss:StyleID="s70"><Data ss:Type="String">'+ALLTRIM(aEmpProc[i][3])+'</Data></Cell>
			EndIf 
			
			cTipo := ""
			Do Case
				Case QRY->Z33_TIPO == '  1'//Normal
					cTipo := "Normal"
				Case QRY->Z33_TIPO == '  7'//Seg. Via - Cartão Danificado
					cTipo := "Seg. Via - Cartao Danificado"
				Case QRY->Z33_TIPO == ' 11'//Cancelamento por demissão
					cTipo := "Cancelamento por demissao"
				Case QRY->Z33_TIPO == ' 12'//Seg. Via - Erro no nome impresso no cartão.
					cTipo := "Seg. Via - Erro no nome impresso no cartao."
				Case QRY->Z33_TIPO == ' 21'//Seg. via - perda ou roubo
					cTipo := "Seg. via - perda ou roubo"
				Case QRY->Z33_TIPO == ' 23'//Primeira via S/ Crédito
					cTipo := "Primeira via S/ Credito"
				Case QRY->Z33_TIPO == '  C'//Complemento
					cTipo := "Complemento"
			EndCase			                                                       
			cXml += '    <Cell ss:StyleID="s70"><Data ss:Type="String">'+QRY->RA_FILIAL+'</Data></Cell>
			cXml += '    <Cell ss:StyleID="s71"><Data ss:Type="String">'+QRY->RA_MAT+'</Data></Cell>
			cXml += '    <Cell ss:StyleID="s71"><Data ss:Type="String">'+CharXml(QRY->RA_NOME)+'</Data></Cell>
			cXml += '    <Cell ss:StyleID="s71"><Data ss:Type="String">'+ALLTRIM(QRY->Z33_FORN)+'</Data></Cell>
			cXml += '    <Cell ss:StyleID="s71"><Data ss:Type="String">'+ALLTRIM(QRY->Z33_COD)+'</Data></Cell>
			cXml += '    <Cell ss:StyleID="s71"><Data ss:Type="String">'+ALLTRIM(QRY->Z33_DESCR)+'</Data></Cell>
			cXml += '    <Cell ss:StyleID="s71"><Data ss:Type="String">'+DTOC(STOD(QRY->Z33_DATA))+'</Data></Cell>
			cXml += '    <Cell ss:StyleID="s71"><Data ss:Type="String">'+ALLTRIM(STRTRAN(Transform(QRY->Z33_QTDE,"9999"),",","."))+'</Data></Cell>
			cXml += '    <Cell ss:StyleID="s71"><Data ss:Type="String">'+ALLTRIM(STRTRAN(Transform(QRY->Z33_VALOR,"9999999999.99"),",","."))+'</Data></Cell>
			cXml += '    <Cell ss:StyleID="s71"><Data ss:Type="String">'+ALLTRIM(cTipo)+'</Data></Cell>
			cXml += '    <Cell ss:StyleID="s71"><Data ss:Type="String">'+ALLTRIM(QRY->Z33_DTHR)+'</Data></Cell>
			cXml += '    <Cell ss:StyleID="s71"><Data ss:Type="String">'+ALLTRIM(QRY->Z33_USER)+'</Data></Cell>
			cXml += '    <Cell ss:StyleID="s71"><Data ss:Type="String">'+IIF(!EMPTY(QRY->DEL),"SIM","")+'</Data></Cell>
			cXml += '    <Cell ss:StyleID="s72"><Data ss:Type="String">'+IIF(QRY->Z33_TRAVA=="S","SIM","")+'</Data></Cell>
			cXml += '   </Row>
			cXml := GrvInfo(cXml,cDest,cArq)			
			QRY->(DbSkip())
		EndDo
		
		If LEFT(cCombo2,1) == "1"//Separado Por Abas
			cXml += '  </Table>
			cXml += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
			cXml += '   <DoNotDisplayGridlines/>
			cXml += '  </WorksheetOptions>
			cXml += '  <AutoFilter x:Range="R4C1:R4C13"
			cXml += '   xmlns="urn:schemas-microsoft-com:office:excel">
			cXml += '  </AutoFilter>
			cXml += ' </Worksheet>
		EndIF
	EndIf
Next i
If LEFT(cCombo2,1) == "2"//Em Mesma Planilha
	cXml += '  </Table>
	cXml += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
	cXml += '   <DoNotDisplayGridlines/>
	cXml += '  </WorksheetOptions>
	cXml += '  <AutoFilter x:Range="R4C1:R4C14"
	cXml += '   xmlns="urn:schemas-microsoft-com:office:excel">
	cXml += '  </AutoFilter>
	cXml += ' </Worksheet>	
EndIf
cXml += '</Workbook>

cXml := GrvInfo(cXml,cDest,cArq)                

oSayTxt:CCAPTION := "FINALIZADO! clique em 'Finalizar' para exibir o arquivo."
oWizRel:OFINISH:LVISIBLECONTROL	:= .T.

Return cXml

/*
Funcao      : GrvInfo()
Parametros  : 
Retorno     : 
Objetivos   : Grava a String enviada no arquivo.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static Function GrvInfo(cMsg,cDest,cArq)
*------------------------------*
Local nHdl		:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""                                 

/*
Funcao      : CharXml()
Parametros  : 
Retorno     : 
Objetivos   : Troca caracteres speciais por comandos XML.
Autor       : Jean Victor Rocha
Data/Hora   : 
*/
*------------------------------*
Static Function CharXml(cData)
*------------------------------*                         
Local aChar := {{"&","&amp;"},;//Executar primeiro a busca pelo &
				{'Á','&Aacute;'},{'á','&aacute;'},{'Â','&Acirc;'} ,{'â','&acirc;'} ,{'À','&Agrave;'},{'à','&agrave;'},;
				{'Å','&Aring;'} ,{'å','&aring;'} ,{'Ã','&Atilde;'},{'ã','&atilde;'},{'Ä','&Auml;'}  ,{'ä','&auml;'}  ,;
				{'Æ','&AElig;'} ,{'æ','&aelig;'} ,{'É','&Eacute;'},{'é','&eacute;'},{'Ê','&Ecirc;'} ,{'ê','&ecirc;'} ,;
				{'È','&Egrave;'},{'è','&egrave;'},{'Ë','&Euml;'}  ,{'ë','&euml;'}  ,{'Ð','&ETH;'}   ,{'ð','&eth;'}   ,;
				{'Í','&Iacute;'},{'í','&iacute;'},{'Î','&Icirc;'} ,{'î','&icirc;'} ,{'Ì','&Igrave;'},{'ì','&igrave;'},;
				{'Ï','&Iuml;'}  ,{'ï','&iuml;'}  ,{'Ó','&Oacute;'},{'ó','&oacute;'},{'Ô','&Ocirc;'} ,{'ô','&ocirc;'} ,;
				{'Ò','&Ograve;'},{'ò','&ograve;'},{'Ø','&Oslash;'},{'ø','&oslash;'},{'Õ','&Otilde;'},{'õ','&otilde;'},;
				{'Ö','&Ouml;'}  ,{'ö','&ouml;'}  ,{'Ú','&Uacute;'},{'ú','&uacute;'},{'Û','&Ucirc;'} ,{'û','&ucirc;'} ,;
				{'Ù','&Ugrave;'},{'ù','&ugrave;'},{'Ü','&Uuml;'}  ,{'ü','&uuml;'}  ,{'Ç','&Ccedil;'},{'ç','&ccedil;'},;
				{'Ñ','&Ntilde;'},{'ñ','&ntilde;'},{'Ý','&Yacute;'},{'ý','&yacute;'},{'"','&quot;'}  ,{'<','&lt;'}    ,;
				{'>','&gt;'}    ,{'®','&reg;'}   ,{'©','&copy;'}  ,{'Þ','&THORN;'} ,{'þ','&thorn;'} ,{'ß','&szlig;'}  ;
			   }

For x := 1 to len(aChar)
	cData := STRTRAN(cData,aChar[x][1],aChar[x][2])
Next x

Return ALLTRIM(cData)

/* ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Funcao     : AUTOUPD
Parametros : Nenhum
Retorno    : 
Objetivos  : Verifica se as tabelas necessarias existem, caso não cria.
Autor      : Jean Victor Rocha
Data/Hora  : 
*/
*-----------------------*
Static Function AUTOUPD()
*-----------------------*
Local lRet := .F.
Local cReserv := cUsado := cNaoUsado := cRrvNUsado	:= 	cObrgNUsado	:=	""
Local ASX2 := {}
Local ASX3 := {}
Local ASIX := {}

If TcCanOpen(RetSqlName("Z33"))
	lRet := .T.     
Else      
	//Atualização de Dicionarios de Dados Caso Necessario.
	aSX2Estrut := 	{"X2_CHAVE","X2_PATH","X2_ARQUIVO","X2_NOME","X2_NOMESPA","X2_NOMEENG","X2_ROTINA","X2_MODO","X2_TTS","X2_UNICO","X2_PYME","X2_MODULO"}
	Aadd(aSX2,{"Z33","\SYSTEM\","Z33"+SM0->M0_CODIGO+"0","Pedidos Beneficios"	,"Pedidos Beneficios"	,"Pedidos Beneficios"	,"","E","","","S",7})

	SX2->(DbSetOrder(1))	
	For i:= 1 To Len(aSX2)
		If !Empty(aSX2[i][1])
			If !SX2->(DbSeek(aSX2[i,1]))
				RecLock("SX2",.T.)
				For j:=1 To Len(aSX2[i])
					If FieldPos(aSX2Estrut[j])>0 .And. aSX2[i,j] != Nil
						FieldPut(FieldPos(aSX2Estrut[j]),aSX2[i,j])
					EndIf
			    Next j
			    DbCommit()
			    MsUnlock()
			EndIf
		EndIf
	Next i

	aEstrut:= { "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL","X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
				"X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
				"X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
				"X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"	}
	
	DbSelectArea("SX3") //X3_RESERV e X3_USADO de um campo Usado
	SX3->(DbSetOrder(2))     
	If SX3->(DBSEEK("RA_NOME" ))
		cReserv := SX3->X3_RESERV
		cUsado  := SX3->X3_USADO
		cObrg	:= SX3->X3_OBRIGAT
	EndIf
	IF SX3->(DBSEEK("W6_FILIAL"))//X3_USADO de um campo nao Usado.
		cNaoUsado	:=	SX3->X3_USADO
		cRrvNUsado	:=	SX3->X3_RESERV
		cObrgNUsado	:=	SX3->X3_OBRIGAT
	EndIf
	IF SX3->(DBSEEK("RA_DEMISSA"))//X3_USADO de um campo nao Usado.
		cNReserv := SX3->X3_RESERV
		cNUsado  := SX3->X3_USADO
		cNObrg	 :=	SX3->X3_OBRIGAT
	EndIf

	aAdd(aSX3,{"Z33","01","Z33_FILIAL","C",02,0,"Filial"    ,"Filial"    ,"Filial"    ,"Filial"       ,"Filial"       ,"Filial"       ,""			,'',cNaoUsado,""       ,""      ,1,cRrvNUsado,"","","U","S","A","R",cObrgNUsado	  ,"",""       ,"","","","","","","","N"})
	aAdd(aSX3,{"Z33","02","Z33_MAT"   ,"C",06,0,"Matricula" ,"Matricula" ,"Matricula" ,"Matricula"    ,"Matricula"    ,"Matricula"    ,"@!"			,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})   
	aAdd(aSX3,{"Z33","03","Z33_FORN"  ,"C",03,0,"Forn.Benef","Forn.Benef","Forn.Benef","Forn.Benef"   ,"Forn.Benef"   ,"Forn.Benef"   ,"@!"			,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})   
	aAdd(aSX3,{"Z33","04","Z33_COD"   ,"C",10,0,"Cod.Benef.","Cod.Benef.","Cod.Benef.","Cod.Benef."   ,"Cod.Benef."   ,"Cod.Benef."   ,"@!"			,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})   
	aAdd(aSX3,{"Z33","05","Z33_DESCR" ,"C",35,0,"Desc.Benef","Desc.Benef","Desc.Benef","Desc.Benef"   ,"Desc.Benef"   ,"Desc.Benef"   ,"@!"			,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})
	aAdd(aSX3,{"Z33","06","Z33_DATA"  ,"D",08,0,"Dt. Benef" ,"Dt. Benef" ,"Dt. Benef" ,"Dt. Benef"    ,"Dt. Benef"    ,"Dt. Benef"    ,"@D"			,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})
	aAdd(aSX3,{"Z33","07","Z33_QTDE"  ,"N",02,0,"Qtde.Benef","Qtde.Benef","Qtde.Benef","Qtde.Benef"   ,"Qtde.Benef"   ,"Qtde.Benef"   ,"@E 99"		,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})
	aAdd(aSX3,{"Z33","08","Z33_VALOR" ,"N",08,2,"Valor B."  ,"Valor B."  ,"Valor B."  ,"Valor B."     ,"Valor B."     ,"Valor B."     ,"@E 999.99"	,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})
	aAdd(aSX3,{"Z33","09","Z33_DTHR"  ,"C",16,0,"Dt.Hr.Log" ,"Dt.Hr.Log" ,"Dt.Hr.Log" ,"Dt.Hr.Log"    ,"Dt.Hr.Log"    ,"Dt.Hr.Log"    ,"@!"			,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})
	aAdd(aSX3,{"Z33","10","Z33_USER"  ,"C",20,0,"User Log"  ,"User Log"  ,"User Log"  ,"User Log"     ,"User Log"     ,"User Log"     ,"@!"			,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})
	aAdd(aSX3,{"Z33","11","Z33_TIPO"  ,"C",03,0,"Tp. Pedido","Tp. Pedido","Tp. Pedido","Tp. Pedido"   ,"Tp. Pedido"   ,"Tp. Pedido"   ,"@!"			,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","S","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})
	aAdd(aSX3,{"Z33","12","Z33_TRAVA" ,"C",01,0,"Trava"		,"Trava"     ,"Trava"	  ,"Trava"		  ,"Trava"		  ,"Trava"		  ,"@!"			,'',cNUsado  ,""       ,""      ,1,cNReserv  ,"","","U","N","A","R",cNObrg        ,"",""       ,"","","","","","","","N"})
	
	For i:= 1 To Len(aSX3)
		If !Empty(aSX3[i][1])
			If SX3->(!DbSeek(aSX3[i,3]))
				SX3->(RecLock("SX3",.T.))
				For j:=1 To Len(aSX3[i])
					If SX3->(FieldPos(aEstrut[j])) > 0 .And. aSX3[i,j] != Nil
						SX3->(FieldPut(FieldPos(aEstrut[j]),aSX3[i,j]))
					EndIf
				Next j
				SX3->(DbCommit())
				SX3->(MsUnlock())
			EndIf
		EndIf
	Next i


	aSIXEstrut:= {"INDICE","ORDEM","CHAVE"				 				,"DESCRICAO"	 			,"DESCSPA"	  			,"DESCENG"		  		,"PROPRI","F3","NICKNAME","SHOWPESQ"}	
	aadd(aSIX,	 {"Z33"   ,"1"    ,"Z33_FILIAL+Z33_MAT+DTOS(Z33_DATA)"	,"Filial +Maricula+Data"	,"Filial +Maricula+Data","Filial +Maricula+Data","U"     ,""  ,""		 ,"S"       })

	dbSelectArea("SIX")
	SIX->(DbSetOrder(1))	
	For i:= 1 To Len(aSIX)
		If !SIX->(DbSeek(aSIX[i,1]+aSIX[i,2]))
			RecLock("SIX",.T.)
			For j:=1 To Len(aSIX[i])
				If FieldPos(aSIXEstrut[j])>0
					FieldPut(FieldPos(aSIXEstrut[j]),aSIX[i,j])
				EndIf
			Next j
			DbCommit()
			MsUnlock()
		EndIf
	Next i

	//Criar Tabela.
	If chkFile("Z33")
		MsgInfo("Criado tabelas Customizadas!","Grant Thornton Brasil.")
		lRet := .T.
	EndIf
		
EndIf
Return lRet