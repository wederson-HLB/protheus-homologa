#include "TOPCONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"  
#include "Protheus.ch"
#include "Rwmake.ch"

//Definição de estrutura utilizada no fonte na tabela generica de beneficios.
/*
Z64_FILIAL 	Z64_TABELA 	Z64_CHAVE	Z64_DESCRI 		Z64_CONT1  		Z64_CONT2 		Z64_CONT3  		Z64_CONT4 		Z64_CONT5
*** Sequencia do numero do arquivo
			RB			SEQARQ		data			seq
*** Tabela de Beneficios da Empresa
			RB			BENEFICIO	COD				Descrição		Grupo			Sub-Grupo		Valor
*/


/*
Funcao      : GTGEN011
Parametros  : 
Retorno     : 
Objetivos   : Integração de beneficios Rb Serviços.
Autor       : Jean Victor Rocha
Data/Hora   : 31/01/2013
TDN         : 
*/
*----------------------*
User Function GTGEN011()
*----------------------*
Local oDlg
Local nOpcao	:= 0
Local oFont15	:= TFont():New("Arial",,15,,.T.,,,,.T.,.F.)         
Local aButtons	:= { }       

Private cMatde		:= Space(AvSx3("RA_MAT",3))
Private cMatate		:= Space(AvSx3("RA_MAT",3))
Private nDias		:= 22
Private cDir := "c:\"

Private bOk      	    := { || nOpcao:=1 , oDlg:End() }
Private bCancel  	    := { || nOpcao:=0 , oDlg:End() }

Private aExcFunc := {}

AADD(aButtons,{"MSGREPLY", {|| GEN011EXC()}, "Exceções","Exceções",{|| .T.}})

DEFINE MSDIALOG oDlg TITLE "HLB BRASIL. - Integração Rb Serviços" FROM 00, 00 to 300, 380 PIXEL  

@ 014,005 Say "Matricula de"	Size 40,10 FONT oFont15 COLOR RGB(0,0,155) of oDlg PIXEL
@ 014,090 Say "ate"				Size 40,10 FONT oFont15 COLOR RGB(0,0,155) of oDlg PIXEL

@ 030,005 Say "Qtd. Dias"  	   	Size 40,10 FONT oFont15 COLOR RGB(0,0,155) of oDlg PIXEL      

@ 046,005 Say "Diretorio:"      Size 40,10 FONT oFont15 COLOR RGB(0,0,155) of oDlg PIXEL      

@ 014,055 MsGet cMatde			Picture AvSx3("RA_MAT",6)		F3 "SRA"    	Size 30,6 of oDlg PIXEL
@ 014,105 MsGet cMatate			Picture AvSx3("RA_MAT",6)   	F3 "SRA"	  	Size 30,6 of oDlg PIXEL       

@ 030,055 MsGet nDias			Picture "@E 99"      							Size 30,6 of oDlg PIXEL       

@ 046,055 MsGet cDir			Picture "@!" 		  							Size 60,6 of oDlg PIXEL       

@ 046,115 Button "?"	Size 7,10 Pixel of oDlg action (GetDir())

ACTIVATE MSDIALOG oDlg CENTERED On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons)   				


IF nOpcao == 1
  Processa({|lEnd| GEN011PROC(),"Calculando"})
Endif

Return( Nil )

/*
Funcao      : GEN011EXC
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : carrega Exceções de ferias/abonos/justificativas...
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*-------------------------*
Static Function GEN011EXC()
*-------------------------*
Local nOpc := GD_INSERT+GD_DELETE+GD_UPDATE
Local aButtons := {}
Local nOpcBut := 1

Local aCols := {}
Local aHeader := {}

SetPrvt("oDlgExc","oBrw1")

Aadd(aHeader,{"Matricula"	,"MATR","@!"		,06,00,"","","C","SRA",""})
Aadd(aHeader,{"Nome"		,"NOME",""		,25,00,"","","C","","" })
Aadd(aHeader,{"Dias"		,"NDIA","@E 99"	,02,00,"","","N","","" })

aAlter := {"MATR","NDIA"}

If Len(aExcFunc) == 0
	aCols:={{SPACE(aHeader[1,4]), SPACE(aHeader[2,4]), 0, .F. }}
Else
	aCols := aExcFunc
EndIf

oDlgExc    := MSDialog():New( 142,471,449,859,"Exceções por funcionarios.",,,.F.,,,,,,.T.,,,.T. )
oBrw1      := MsNewGetDados():New(004,004,124,184,nOpc,'AllwaysTrue()','AllwaysTrue()','',aAlter,0,999,'U_GEN011VLD()','','AllwaysTrue()',oDlgExc,aHeader,aCols )
                     
Private bOk      	    := { || (nOpcBut := 1, oDlgExc:End()) }
Private bCancel  	    := { || oDlgExc:End() }

oDlgExc:bInit := {|| EnchoiceBar(oDlgExc,bOk,bCancel,,aButtons)}
oDlgExc:lCentered := .T.
oDlgExc:Activate(,,,.T.)  

If nOpcBut == 1
	aExcFunc := {}
	For i:=1 to Len(oBrw1:aCols)
		If !oBrw1:aCols[i][LEN(oBrw1:aCols[i])]
			aAdd(aExcFunc, oBrw1:aCols[i])
		EndIf
	Next i
EndIf

Return .T.

/*
Funcao      : GEN011VLD
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Validação de campo
Autor       : Jean Victor Rocha.
Data/Hora   : 
*/
*--------------------------*
User Function GEN011VLD()
*---------------------------*
lRet := .T.

Do case
	Case __READVAR == "M->MATR"
		SRA->(DbSetOrder(1))
		If SRA->(DbSeek(xFilial("SRA")+M->MATR))
			aCols[oBrw1:NAT][aScan(aHeader,{|x| x[2] == "NOME"})] := SRA->RA_NOME
		Else
			M->MATR := SPACE(aHeader[aScan(aHeader,{|x| x[2] == "MATR"})][4])
			aCols[oBrw1:NAT][aScan(aHeader,{|x| x[2] == "NOME"})] := ""
			lRet := .F.
		EndIf
EndCase


Return lRet


/*
Funcao      : GEN011PROC
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Processamento da geração do arquivo TXT de integração.
Autor       : Jean Victor Rocha.
Data/Hora   : 31/01/2013
*/
*--------------------------*
Static Function GEN011PROC() 
*--------------------------*
Local cLinha1 := Space(400)
Local cLinha2 := Space(400)
Local cLinha3 := Space(400)
Local cLinha4 := Space(400)
Local cLinha5 := Space(400)

//Cria o Arquivo fisico.
cNomeArq := AchaNome() 
nHandle := MSFCREATE(cDir+cNomeArq+".TXT")
If FERROR() # 0 .Or. nHandle < 0
	MsgAlert("Não foi possivel a criação do arquivo" + Chr(13) + ;
	         "       Processo será abortado        ","Atenção !")
	FClose(nHandle)
	Return(.f.)
EndIf

//Linha1 - Cabeçalho
nLinha := 1
cLinha1 := Stuff(cLinha1,001,005,STRZERO(nLinha,5)) 	 		//Numero da linha
cLinha1 := Stuff(cLinha1,006,006,STRZERO(1,1)) 	   				//Identificador do registro
cLinha1 := Stuff(cLinha1,007,020,STRZERO(VAL(SM0->M0_CGC),14))  //CNPJ
cLinha1 := Stuff(cLinha1,021,100,SM0->M0_NOMECOM) 				//Razão social
cLinha1 += Chr(13)+Chr(10)
fWrite(nHandle,UPPER(cLinha1))

//Linha2 - Endereço de entrega
nLinha++
cLinha2 := Stuff(cLinha2,001,005,STRZERO(nLinha,5))															 		//Numero da linha
cLinha2 := Stuff(cLinha2,006,006,STRZERO(2,1))																  		//Identificador do registro
cLinha2 := Stuff(cLinha2,007,020,STRZERO(VAL(SM0->M0_CGC),14))												 		//CNPJ
cLinha2 := Stuff(cLinha2,021,023,STRZERO(1,3))																  		//Codigo endereço sequencial
cLinha2 := Stuff(cLinha2,024,031,STRZERO(VAL(SM0->M0_CEPCOB),8))											  		//CEP
cLinha2 := Stuff(cLinha2,032,091,LEFT(SM0->M0_ENDENT,AT(",",SM0->M0_ENDENT)-1))								   		//endereço
cLinha2 := Stuff(cLinha2,092,101,STRZERO(VAL(RIGHT(SM0->M0_ENDENT,LEN(SM0->M0_ENDENT)-AT(",",SM0->M0_ENDENT))),10))	//Numero endereço
cLinha2 := Stuff(cLinha2,102,131,Space(30))																		   		//Complemento endereço
cLinha2 := Stuff(cLinha2,132,171,SM0->M0_BAIRCOB)															   		//Bairro
cLinha2 := Stuff(cLinha2,172,211,SM0->M0_CIDENT)																	//Cidade
cLinha2 := Stuff(cLinha2,212,213,SM0->M0_ESTENT)																	//Estado
cLinha2 += Chr(13)+Chr(10)
fWrite(nHandle,UPPER(cLinha2))

If EMPTY(cMatAte)
	cMatAte := "ZZZZZZ"
EndIf

//Busca funcionarios.
nFunc := 0
SRA->(DbSetOrder(1))
SRA->(DbSeek(xFilial("SRA")+cMatDe,.t.))
Do While SRA->RA_FILIAL == xFilial("SRA") .and. SRA->RA_MAT <= cMatAte .and. SRA->(!Eof())
	if SRA->RA_SITFOLH <> "D"  // Não esta demitido 
	    If Select("TMPRB") > 0
			TMPRB->(DbClosearea())
		Endif     	                   
		cQuery := " SELECT Z71_FORN, Z71_COD, Z71_QTDE, Z71_VALOR, Z71_MAT "	+ Chr(13)
      	cQuery += " FROM " + RetSqlName("Z71") + " Z71 "						+ Chr(13)	
      	cQuery += " WHERE D_E_L_E_T_ = '' "     								+ Chr(13)
      	cQuery += " AND Z71_FILIAL = '" + SRA->RA_FILIAL + "' "					+ Chr(13)
      	cQuery += " AND Z71_MAT = '" + SRA->RA_MAT + "' " 						+ Chr(13)
		cQuery += " AND Z71_FORN = 'RB'"										+ Chr(13)
      	
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"TMPRB",.F.,.T.)
		
		If TMPRB->(!EoF())     
			//Linha3 - Registro funcionario
			nLinha++
			nFunc ++
			cLinha3 := Space(400)
			cLinha3 := Stuff(cLinha3,001,005,STRZERO(nLinha,5)) 	 		//Numero da linha
			cLinha3 := Stuff(cLinha3,006,006,STRZERO(3,1)) 	   				//Identificador do registro
			cLinha3 := Stuff(cLinha3,007,020,STRZERO(VAL(SM0->M0_CGC),14))	//CNPJ
			cLinha3 := Stuff(cLinha3,021,032,STRZERO(VAL(SRA->RA_MAT),12))	//Matricula
			cLinha3 := Stuff(cLinha3,033,092,SRA->RA_NOME)		   			//Nome completo
			cLinha3 := Stuff(cLinha3,093,132,SRA->RA_CC)		  			//Departamento
			cLinha3 := Stuff(cLinha3,133,172,SRA->RA_DESFUNC+SPACE(40-LEN(SRA->RA_DESFUNC)))//Cargo
			cLinha3 := Stuff(cLinha3,173,180,STRTRAN(DTOC(SRA->RA_NASC),"/",""))//Data Nascimento
			cLinha3 := Stuff(cLinha3,181,194,STRZERO(VAL(SRA->RA_CIC),14))	//CPF
			cLinha3 := Stuff(cLinha3,195,208,STRTRAN(STRTRAN(SRA->RA_RG,".",""),"-","")+SPACE(14-LEN(STRTRAN(STRTRAN(SRA->RA_RG,".",""),"-",""))))	//Numero do RG STRTRAN(STRTRAN(SRA->RA_RG,".",""),"-","")
			cLinha3 := Stuff(cLinha3,209,209,SRA->RA_SEXO)					//Sexo
			cLinha3 := Stuff(cLinha3,210,249,SRA->RA_MAE)					//Nome da Mae
			cLinha3 := Stuff(cLinha3,250,257,STRZERO(VAL(SRA->RA_CEP),8))	//CEP
			cLinha3 := Stuff(cLinha3,258,317,SRA->RA_ENDEREC+SPACE(60-LEN(SRA->RA_ENDEREC)))	//Endereço
			cLinha3 := Stuff(cLinha3,318,327,STRZERO(0,10))					//Numero do Endereço
			cLinha3 := Stuff(cLinha3,328,357,SRA->RA_COMPLEM+SPACE(30-LEN(SRA->RA_COMPLEM)))	//Complemento do endereço
			cLinha3 := Stuff(cLinha3,358,397,SRA->RA_BAIRRO+SPACE(40-LEN(SRA->RA_BAIRRO)))		//Bairro
			cLinha3 := Stuff(cLinha3,398,437,SRA->RA_MUNICIP+SPACE(40-LEN(SRA->RA_MUNICIP)))	//cidade
			cLinha3 := Stuff(cLinha3,438,449,SRA->RA_ESTADO+SPACE(2-LEN(SRA->RA_ESTADO)))		//Estado
			cLinha3 := Stuff(cLinha3,440,442,STRZERO(1,3))					//Codigo endereço para entrega, fixo baseado no SM0.
		   	cLinha3 += Chr(13)+Chr(10)
			fWrite(nHandle,UPPER(cLinha3))
		EndIf
	    If Select("TMPRB") > 0
			TMPRB->(DbClosearea())
		Endif     	          
	Endif
   	SRA->(DBSkip())
Enddo

If !EMPTY(cLinha3)
	MsgAlert( "Arquivo de integração Rb Serviços gerado com sucesso: '"+cDir+cNomeArq+".TXT'", "Atenção !")
   
Else
	fclose(nHandle)
	Ferase(cDir+cNomeArq+".TXT")

	Z64->(DbSeek("  "+"RB "+"SEQARQ"))
	Z64->(RecLock("Z64",.F.))
	cSeq	:= STRZERO(Val(Z64->Z64_CONT1)+1,3)
	Z64->Z64_CONT1	:= ALLTRIM(STR(Val(Z64->Z64_CONT1)-1))
   
	MsgAlert("Não existem dados para envio !!! " +Chr(13) +;
	         "Verifique os filtros selecionados", "Atenção !")
Endif

			
Z64->(DbSetOrder(1))

SRA->(DbSetOrder(1))
SRA->(DbSeek(xFilial("SRA")+cMatDe,.t.))
Do While SRA->RA_FILIAL == xFilial("SRA") .and. SRA->RA_MAT <= cMatAte .and. SRA->(!Eof())
	if SRA->RA_SITFOLH <> "D"  // Não esta demitido 
	    If Select("TMPRB") > 0
			TMPRB->(DbClosearea())
		Endif     	                   
		cQuery := " SELECT Z71_FORN, Z71_COD, Z71_QTDE, Z71_VALOR, Z71_MAT "	+ Chr(13)
      	cQuery += " FROM " + RetSqlName("Z71") + " Z71 "						+ Chr(13)	
      	cQuery += " WHERE D_E_L_E_T_ = '' "     								+ Chr(13)
      	cQuery += " AND Z71_FILIAL = '" + SRA->RA_FILIAL + "' "					+ Chr(13)
      	cQuery += " AND Z71_MAT = '" + SRA->RA_MAT + "' " 						+ Chr(13)
		cQuery += " AND Z71_FORN = 'RB'"										+ Chr(13)
//		cQuery += " AND Z71_COD = '"+LEFT(cCmbTpPed,3)+"'"						+ Chr(13)
     	
		dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"TMPRB",.F.,.T.)
		
		Do While TMPRB->(!EoF())     
			//Linha4 - Beneficios Funcionario
			nLinha++
			
			nQtdeDias := nDias
			If (nPos:=aScan(aExcFunc, {|x| x[1]==SRA->RA_MAT} )) <> 0
				nQtdeDias := aExcFunc[nPos][3]
			EndIf
			
			cLinha4 := Space(400)
			cLinha4 := Stuff(cLinha4,001,005,STRZERO(nLinha,5)) 	 		//Numero da linha
			cLinha4 := Stuff(cLinha4,006,006,STRZERO(4,1)) 	   				//Identificador do registro
			cLinha4 := Stuff(cLinha4,007,020,STRZERO(VAL(SM0->M0_CGC),14))	//CNPJ
			cLinha4 := Stuff(cLinha4,021,032,STRZERO(VAL(SRA->RA_MAT),12))	//MATRICULA
			cLinha4 := Stuff(cLinha4,033,044,STRZERO(VAL(TMPRB->Z71_COD),12))	//Codigo do beneficio
			Z64->(DbSeek("  "+"RB "+"BENEFICIO "+TMPRB->Z71_COD))
			cLinha4 := Stuff(cLinha4,045,104,ALLTRIM(Z64->Z64_CONT1)) 		//Descrição do Beneficio
			cLinha4 := Stuff(cLinha4,105,108,STRZERO(TMPRB->Z71_QTDE*nQtdeDias,4))//Quantidade
			cLinha4 := Stuff(cLinha4,109,113,STRZERO(VAL(STRTRAN(TRANSFORM(VAL(STRTRAN(Z64->Z64_CONT4,",",".")),"@E 999999.99"),",","")),8))//Valor
			cLinha4 += Chr(13)+Chr(10)
			fWrite(nHandle,UPPER(cLinha4))
			TMPRB->(DBSkip())
		Enddo
	    If Select("TMPRB") > 0
			TMPRB->(DbClosearea())
		Endif     	          
	Endif
   	SRA->(DBSkip())
Enddo

//Linha5 - Rodapé
nLInha++
cLinha5 := Stuff(cLinha5,001,005,STRZERO(nLinha,5))				//Numero da linha
cLinha5 := Stuff(cLinha5,006,006,STRZERO(7,1)) 	   				//Identificador do registro
cLinha5 := Stuff(cLinha5,007,020,STRZERO(VAL(SM0->M0_CGC),14))  //CNPJ
cLinha5 := Stuff(cLinha5,021,025,STRZERO(nFunc,5))				//Numero de funcionarios
cLinha5 += Chr(13)+Chr(10)
fWrite(nHandle,UPPER(cLinha5))
		        
FClose(nHandle)

Return .t.

/*
Funcao      : GetDir
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Busca de diretorio.
Autor       : Jean Victor Rocha.
Data/Hora   : 31/01/2013
*/
*---------------------------*
Static Function GetDir()
*---------------------------*
Local cTitle:= "Salvar arquivo"
Local cFile := ""
Local nDefaultMask := 0
Local cDefaultDir  := cDir
Local nOptions:= GETF_NETWORKDRIVE+GETF_RETDIRECTORY+GETF_LOCALHARD

cDir := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

Return 

/*
Funcao      : GTGEN011
Parametros  : 
Retorno     : 
Objetivos   : Busca o nome do arquivo a ser utilizado
Autor       : Jean Victor Rocha
Data/Hora   : 31/01/2013
TDN         : 
*/
*-------------------------*
Static Function AchaNome()
*-------------------------*
Local cSeq := ""
Local cArq := ALLTRIM(STRZERO(DAY(DATE()),2))+ALLTRIM(STRZERO(MONTH(DATE()),2))+ALLTRIM(STR(YEAR(DATE())))

Z64->(DbSetOrder(1))
If Z64->(DbSeek("  "+"RB "+"SEQARQ"))
	If STOD(Z64->Z64_DESCRI) <> Date()
		Z64->(RecLock("Z64",.F.))
		Z64->Z64_DESCRI	:= DTOS(DATE())
		Z64->Z64_CONT1	:= "1"
		cSeq	:= "001"
	Else
		Z64->(RecLock("Z64",.F.))
		cSeq	:= STRZERO(Val(Z64->Z64_CONT1),3)
		Z64->Z64_CONT1	:= ALLTRIM(STR(Val(Z64->Z64_CONT1)+1))
	EndIf
	Z64->(MsUnlock())
EndIf

cArq += cSeq

Return(cArq)