#include "rwmake.ch"
#include "protheus.ch"                      
/*
Funcao      : TTGPE001
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Payroll em Excel
Autor       : João Silva
Data/Hora   : 11/02/2016
Obs         : 
TDN         : 
Obs         : 
Cliente     : Uber, Todos
*/                 
*----------------------*
User Function TTGPE001()
*----------------------*
Private cPerg := "TTGPE001"

//Validação da empresa que esta executando a função.
//If !(cEmpAnt $ "TT")  TLM 20160802 - liberação de uso para outras empresas.
//	MsgAlert("Customização não disponivel para empresa!","HLB BRASIL")
//	Return .T.  
//EndIf
                                 
//Ajusta o arquivo de perguntes
AjustaSx1()
                  
//Carrega Pergunte em modo Oculto, pois não será tratado pela tela padrão.
Pergunte(cPerg,.F.)

Return Main()
                        
*--------------------*
Static Function Main()
*--------------------*
Local lWizArq
Local lInverte := .F.
Local nCountVar := 0
Local cAuxVerbas := ""

Private cMarca  := GetMark()
Private oWizard
Private cArqTxt := ""
Private ocDirArq
Private oMeter
Private nMeter := 0
Private oMeter2    
Private nMeter2 := 0
Private oSayTxt

Private aVerbas := {}

oWizard := APWizard():New("Relatorio", ""/*<chMsg>*/, "Payrroll Uber",;
										"Geração de arquivo Payrroll Uber",;
										 {||  .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/,,,/*<.lNoFirst.>*/)

//Painel 2
oWizard:NewPanel( "Configurações", "Selecione os Filtros a serem considerados para a Impressão!",{ ||.T.}/*<bBack>*/,;
														 {|| .T.}/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

cAno		:= IIF(EMPTY(MV_PAR01),YEAR(date()),MV_PAR01)
cFilDe		:= IIF(EMPTY(MV_PAR02),Space(TamSx3("RA_FILIAL")[1]),MV_PAR02)
cFilAte		:= IIF(EMPTY(MV_PAR03),Space(TamSx3("RA_FILIAL")[1]),MV_PAR03)
cCCDe		:= IIF(EMPTY(MV_PAR04),Space(TamSx3("CTT_CUSTO")[1]),MV_PAR04)
cCCAte		:= IIF(EMPTY(MV_PAR05),Space(TamSx3("CTT_CUSTO")[1]),MV_PAR05)
cMatDe		:= IIF(EMPTY(MV_PAR06),Space(TamSx3("RA_MAT")[1]),MV_PAR06)
cMatAte		:= IIF(EMPTY(MV_PAR07),Space(TamSx3("RA_MAT")[1]),MV_PAR07)
cSitua		:= IIF(EMPTY(MV_PAR08),fSituacao(NIL,.F.),MV_PAR08)
cCateg		:= IIF(EMPTY(MV_PAR09),fCategoria(NIL,.F.),MV_PAR09)
cConsol		:= IIF(MV_PAR10==1,"Sim","Nao")
cTotCC		:= IIF(MV_PAR11==1,"Sim","Nao")
cProvi		:= IIF(MV_PAR12==1,"Sim","Nao")
cBase		:= IIF(MV_PAR13==1,"Sim","Nao")
//Verifica quantas ordens possui para as verbas
SX1->(DbSetOrder(1))
If SX1->(DbSeek(cPerg))
	While SX1->(!EOF()) .and. ALLTRIM(SX1->X1_GRUPO) == cPerg
		If UPPER(LEFT(SX1->X1_PERGUNT,5)) == "VERBA"
			nCountVar++
		EndIf
		SX1->(DbSkip())
	EndDo
EndIf
For i:=14 to 14+nCountVar
	cAuxVerbas := &("MV_PAR"+ALLTRIM(STR(i)) )
	If !EMPTY(cAuxVerbas)
		While Len(cAuxVerbas) > 0
			aAdd(aVerbas,LEFT(cAuxVerbas,3) )
			cAuxVerbas := RIGHT(cAuxVerbas,LEN(cAuxVerbas)-3)
		EndDo
	EndIf
Next i

aItems := {"Sim","Nao"}

@ 010, 010 TO 125,280 OF oWizard:oMPanel[2] PIXEL
oSBox1 := TScrollBox():New( oWizard:oMPanel[2],009,009,124,279,.T.,.T.,.T. )

@ 21,20 SAY oSay0 VAR "Ano? " SIZE 100,10 OF oSBox1 PIXEL
ocAno	:= TGet():New(20,85,{|u| if(PCount()>0,cAno:=u,cAno)},oSBox1,50,05,'@!',{|o|},,,,,,.T.,,,,,,,,,,'cAno')
@ 41,20 SAY oSay1 VAR "Filial De ?" SIZE 100,10 OF oSBox1 PIXEL
ocFilDe	:= TGet():New(40,85,{|u| if(PCount()>0,cFilDe:=u,cFilDe)},oSBox1,50,05,'@!',{|o|},,,,,,.T.,,,,,,,,,"XMO",'cFilDe')
@ 61,20 SAY oSay2 VAR "Filial Até?" SIZE 100,10 OF oSBox1 PIXEL
ocFilAte:= TGet():New(60,85,{|u| if(PCount()>0,cFilAte:=u,cFilAte)},oSBox1,50,05,'@!',{|o|},,,,,,.T.,,,,,,,,,"XMO",'cFilAte')
@ 81,20 SAY oSay3 VAR "C.C. De ?" SIZE 100,10 OF oSBox1 PIXEL
ocCCDe	:= TGet():New(80,85,{|u| if(PCount()>0,cCCDe:=u,cCCDe)},oSBox1,50,05,'@!',{|o|},,,,,,.T.,,,,,,,,,"CTT",'cCCDe')
@ 101,20 SAY oSay4 VAR "C.C. Até?" SIZE 100,10 OF oSBox1 PIXEL
ocCCAte	:= TGet():New(100,85,{|u| if(PCount()>0,cCCAte:=u,cCCAte)},oSBox1,50,05,'@!',{|o|},,,,,,.T.,,,,,,,,,"CTT",'cCCAte')
@ 121,20 SAY oSay5 VAR "Matricula De ?" SIZE 100,10 OF oSBox1 PIXEL
ocMatDe	:= TGet():New(120,85,{|u| if(PCount()>0,cMatDe:=u,cMatDe)},oSBox1,50,05,'@!',{|o|},,,,,,.T.,,,,,,,,,"SRA",'cMatDe')
@ 141,20 SAY oSay6 VAR "Matricula Até?" SIZE 100,10 OF oSBox1 PIXEL
ocMatAte:= TGet():New(140,85,{|u| if(PCount()>0,cMatAte:=u,cMatAte)},oSBox1,50,05,'@!',{|o|},,,,,,.T.,,,,,,,,,"SRA",'cMatAte')
@ 161,20 SAY oSay7 VAR "Situacoes a Imp. ?" SIZE 100,10 OF oSBox1 PIXEL
ocSitua	:= TGet():New(160,85,{|u| if(PCount()>0,cSitua:=u,cSitua)},oSBox1,50,05,'@!',{|o| fSituacao()},,,,,,.T.,,,,,,,,,,'cSitua')
@ 181,20 SAY oSay8 VAR "Categorias a Imp.?" SIZE 100,10 OF oSBox1 PIXEL
ocCateg	:= TGet():New(180,85,{|u| if(PCount()>0,cCateg:=u,cCateg)},oSBox1,50,05,'@!',{|o| fCategoria()},,,,,,.T.,,,,,,,,,,'cCateg')
@ 201,20 SAY oSay9 VAR "Consolidado ?" SIZE 100,10 OF oSBox1 PIXEL
ocConsol := TComboBox():New(200,85,{|u|if(PCount()>0,cConsol:=u,cConsol)},aItems,50,05,oSBox1,,{||},,,,.T.,,,,,,,,,'cConsol')
@ 221,20 SAY oSay10 VAR "Tot. CC? " SIZE 100,10 OF oSBox1 PIXEL
ocTotCC := TComboBox():New(220,85,{|u|if(PCount()>0,cTotCC:=u,cTotCC)}	,aItems,50,05,oSBox1,,{||},,,,.T.,,,,,,,,,'cTotCC')
@ 241,20 SAY oSay11 VAR "Exibe Prov.?" SIZE 100,10 OF oSBox1 PIXEL
ocProvi := TComboBox():New(240,85,{|u|if(PCount()>0,cProvi:=u,cProvi)}	,aItems,50,05,oSBox1,,{||},,,,.T.,,,,,,,,,'cProvi')
@ 261,20 SAY oSay12 VAR "Exibe Base ?" SIZE 100,10 OF oSBox1 PIXEL
ocBase	:= TComboBox():New(260,85,{|u|if(PCount()>0,cBase:=u,cBase)}	,aItems,50,05,oSBox1,,{||},,,,.T.,,,,,,,,,'cBase')
oBtn1 := TButton():New(280,20,"Verbas",oSBox1,{|| SelVerbas() },115,10,,,.F.,.T.,.F.,,.F.,,,.F. )
@ 300,20 SAY oSay13 VAR "" SIZE 100,10 OF oSBox1 PIXEL
		          
//Painel 3               
oWizard:NewPanel( "Processamento", "",{ || .F.}/*<bBack>*/, /*<bNext>*/, {|| lWizArq := .T.}/*<bFinish>*/, /*<.lPanel.>*/,;
																								 {|| ProcArq()}/*<bExecute>*/ )

@ 21,20 SAY oSayTxt VAR ""  SIZE 280,10 OF oWizard:oMPanel[3] PIXEL
nMeter := 0
oMeter := TMeter():New(31,20,{|u|if(Pcount()>0,nMeter:=u,nMeter)},0,oWizard:oMPanel[3],250,34,,.T.,,,,,,,,,)
oMeter:Set(0) 

//Ativa o Wizard
oWizard:Activate( .T./*<.lCenter.>*/,/*<bValid>*/, /*<bInit>*/, /*<bWhen>*/ )

Return .t.                       

/*
Funcao      : ProcArq()
Parametros  : 
Retorno     : 
Objetivos   : Processamento do Arquivo/Relatorio.
Autor       : João Silva
Data/Hora   : 
*/
*-----------------------*
Static Function ProcArq()
*-----------------------*
Local nHdl
Local cXML 			:= ""
Local cQry			:= ""

Private lTemProf := .F.
Private cDest 		:= GetTempPath()
Private oExcel 		:= FWMSEXCEL():New()
Private cDest 		:= GetTempPath()
Private cArq 		:= "PayRoll.XLS"
Private nBytesSalvo := 0 

//Salva as definições do usuario para o filtro.
SaveProf()                 

If EMPTY(cSitua) .or. EMPTY(cCateg)
	MsgAlert("Os campos 'Categorias' e 'Situacoes' são de preenchimento obrigatorio!","HLB BRASIL")
	Return .T.
EndIf

//Gera arquivo fisico. 
IF FILE (cDest+cArq)
	FERASE (cDest+cArq)
ENDIF

nHdl 		:= FCREATE(cDest+cArq,0 )  	//Criação do Arquivo .
FWRITE(nHdl, cXML ) 					// Gravação do seu Conteudo.
fclose(nHdl) 							// Fecha o Arquivo que foi Gerado	
    
//Processamento ---------------------------------------------------------
Private aConsol 	:= {}
Private aTotCC	 	:= {}

//Busca os Dados, tabela temporaria.
cQry := GetInfo()

QRY->(DbGoTop())
If QRY->(!EOF())
    //Monta a Barra de Progresso.
	If select("CNT")>0
		CNT->(DbCloseArea())
	Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,"Select COUNT(*) AS CNT From ("+cQry+") as CNT"),"CNT",.T.,.T.)
	oMeter:NTOTAL := CNT->CNT 
	oMeter:Set(0)
	CNT->(DbCloseArea())

	//Monta em XML
	cXML := WriteXML()	
	//Abre o Excel
	GrvXML(cXML)
Else
	MsgAlert("Sem dados para exibição, verificar parametros!","HLB BRASIL")
EndIF
                
oMeter:LVISIBLE := .F.
oSayTxt:CCAPTION := "Processamento finalizado, o arquivo será aberto automaticamente."
oWizard:OBACK:LVISIBLECONTROL		:= .F.
oWizard:OCANCEL:LVISIBLECONTROL		:= .F.
oWizard:ONEXT:LVISIBLECONTROL		:= .F.

//Fecha tabela Temporaria.
If select("QRY")>0
	QRY->(DbCloseArea())
Endif

If nBytesSalvo > 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
EndIf

Return .T.

/*
Funcao      : SaveProf()
Parametros  : 
Retorno     : 
Objetivos   : Salva as definições do pergunte do usuario.
Autor       : João Silva
Data/Hora   :
*/
*------------------------*
Static Function SaveProf()
*------------------------*
Local i
Local nCountVar := 0
Local nCountSpace := 0
Local cAuxVerbas := ""

//Verifica quantas ordens possui para as verbas
SX1->(DbSetOrder(1))
If SX1->(DbSeek(cPerg))
	While SX1->(!EOF()) .and. ALLTRIM(SX1->X1_GRUPO) == cPerg
		If UPPER(LEFT(SX1->X1_PERGUNT,5)) == "VERBA"
			nCountVar++
		EndIf
		SX1->(DbSkip())
	EndDo
EndIf                   

//Criação das definições para atualização por usuario.
cInfPerg := ""
cInfPerg += "C#G#"+cAno							+CHR(13)+CHR(10)//01
cInfPerg += "C#G#"+cFilDe						+CHR(13)+CHR(10)//02
cInfPerg += "C#G#"+cFilAte						+CHR(13)+CHR(10)//03
cInfPerg += "C#G#"+cCCDe						+CHR(13)+CHR(10)//04
cInfPerg += "C#G#"+cCCAte						+CHR(13)+CHR(10)//05
cInfPerg += "C#G#"+cMatDe						+CHR(13)+CHR(10)//06
cInfPerg += "C#G#"+cMatAte						+CHR(13)+CHR(10)//07
cInfPerg += "C#G#"+cSitua						+CHR(13)+CHR(10)//08
cInfPerg += "C#G#"+cCateg						+CHR(13)+CHR(10)//09
cInfPerg += "N#C#"+IIF(cConsol=="Sim","1","2")	+CHR(13)+CHR(10)//10
cInfPerg += "N#C#"+IIF(cTotCC =="Sim","1","2")	+CHR(13)+CHR(10)//11
cInfPerg += "N#C#"+IIF(cProvi =="Sim","1","2")	+CHR(13)+CHR(10)//12
cInfPerg += "N#C#"+IIF(cBase  =="Sim","1","2")	+CHR(13)+CHR(10)//13
For i:=1 to Len(aVerbas)
	If Len(cAuxVerbas) >= 60
		cInfPerg +="C#G#"+cAuxVerbas			+CHR(13)+CHR(10)//14 até ...
		cAuxVerbas := ""
	EndIf
	cAuxVerbas += aVerbas[i]
Next i
If Len(cAuxVerbas) > 0
	cInfPerg +="C#G#"+cAuxVerbas			+CHR(13)+CHR(10)//14 até ...
EndIf

//Verifica se já possui Profile
PROFALIAS->(DbSetOrder(1))
If PROFALIAS->(DBSeek(cEmpAnt+cUsername))
	While PROFALIAS->(!EOF()) .and. ALLTRIM(PROFALIAS->P_NAME) == ALLTRIM(cEmpAnt+cUsername)
		If ALLTRIM(UPPER(PROFALIAS->P_PROG)) == ALLTRIM(UPPER(cPerg)) .and.;
			ALLTRIM(PROFALIAS->P_TASK) == 'PERGUNTE' .and.;
			ALLTRIM(PROFALIAS->P_TYPE) == 'MV_PAR'
			lTemProf := .T.
			Exit
		EndIf
		PROFALIAS->(DbSkip())
	EndDo
EndIf

//Atualização do Profile do Usuario.
PROFALIAS->(RecLock("PROFALIAS",!lTemProf))
If !lTemProf                                  
	PROFALIAS->P_NAME := ALLTRIM(cEmpAnt+cUsername)
	PROFALIAS->P_PROG := ALLTRIM(UPPER(cPerg))
	PROFALIAS->P_TASK := "PERGUNTE"
	PROFALIAS->P_TYPE := "MV_PAR"
EndIf
PROFALIAS->P_DEFS := cInfPerg
PROFALIAS->(MsUnlock())

Return .T.

/*
Funcao      : AjustaSX1()
Parametros  : 
Retorno     : 
Objetivos   : Ajusta o Dicionario SX1 da empresa.
Autor       : João Silva
Data/Hora   : 
*/
*-------------------------*
Static Function AjustaSX1()
*-------------------------*
Local cQry := ""   
Local nValPerg := 0
Local i 
Local nOrdem := 1       

//Se for versão antiga, apaga e cria a nova versão.
SX1->(DbSetOrder(1))
If SX1->(DbSeek(cPerg))
	If SX1->X1_PERGUNT <> "Ano?"
		While SX1->(!EOF()) .and. SX1->X1_GRUPO == cPerg
			SX1->(RecLock("SX1",.F.))
			SX1->(DbDelete())
			SX1->(DbSkip())
		EndDo
	EndIf
EndIf

//Verifica quantos campos de pergunte para tratamento de seleção de verba deve conter no pergunte.
//Cada pergunte comporta até 20 verbas. (60 caracteres)
cQry += "Select (COUNT(*)/20)+1 AS COUNT From ( 
cQry += "						   				Select RC_PD as VERBA From "+RETSQLNAME("SRC")+" Where D_E_L_E_T_ <> '*'
cQry += "										Union
cQry += " 										Select RD_PD as VERBA From "+RETSQLNAME("SRD")+" Where D_E_L_E_T_ <> '*'
cQry += "										Union
cQry += " 										Select RT_VERBA as VERBA From "+RETSQLNAME("SRT")+" Where D_E_L_E_T_ <> '*'
cQry += " 										) COUNT

If select("QRY")>0
	QRY->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRY",.T.,.T.)
nValPerg := QRY->COUNT
QRY->(DbCloseArea())

//Atualização dos Parametros
U_PUTSX1( cPerg, "01", "Ano?"						, "Ano?"  					, "Ano?"   					, "", "C",4 ,00,00,"G",'';
			, ""	,"","","MV_PAR01","","","","2015"	,"","","","","","","","","","","","")
U_PUTSX1( cPerg, "02", "Filial De ?  "	   		, "Filial De ?  " 	   		, "Filial De ?  " 	  		, "", "C",2 ,00,00,"G",'';
			, "XM0"	,"","","MV_PAR02","","","",""		,"","","","","","","","","","","","")
U_PUTSX1( cPerg, "03", "Filial Até?"	 	  		, "Filial Até?" 	  	 	, "Filial Até ?  " 	   		, "", "C",2 ,00,00,"G",'';
			, "XM0"	,"","","MV_PAR03","","","",""		,"","","","","","","","","","","","")
U_PUTSX1( cPerg, "04", "Centro de Custo De ?  "	, "Centro de Custo De ?  " 	, "Centro de Custo De ?  " 	, "", "C",9 ,00,00,"G",'';
			, "CTT"	,"","","MV_PAR04","","","",""		,"","","","","","","","","","","","")
U_PUTSX1( cPerg, "05", "Centro de Custo Até?"	 	, "Centro de Custo Até?"  	, "Centro de Custo Até ?  " , "", "C",9 ,00,00,"G",'';
			, "CTT"	,"","","MV_PAR05","","","",""		,"","","","","","","","","","","","")
U_PUTSX1( cPerg, "06", "Matricula De ?  "	   		, "Matricula De ?  " 	   	, "Matricula De ?  " 		, "", "C",6 ,00,00,"G",'';
			, "SRA" ,"","","MV_PAR06","","","",""		,"","","","","","","","","","","","")
U_PUTSX1( cPerg, "07", "Matricula Até?"	 		, "Matricula Até?" 	  	 	, "Matricula Até ?  " 		, "", "C",6 ,00,00,"G",'';
			, "SRA" ,"","","MV_PAR07","","","",""		,"","","","","","","","","","","","")
U_PUTSX1( cPerg, "08", "Situacoes a Imp. ? "	 	, "Situacoes a Imp. ? "  	, "Situacoes a Imp. ? " 	, "", "C",5 ,00,00,"G",'fSituacao';
			, "" 	,"","","MV_PAR08","","","",""		,"","","","","","","","","","","","")
U_PUTSX1( cPerg, "09", "Categorias a Imp. ?" 		, "Categorias a Imp. ? "  	, "Categorias a Imp. ?" 	, "", "C",15,00,00,"G",'fCategoria';
			, ""	,"","","MV_PAR09","","","",""		,"","","","","","","","","","","","")
U_PUTSX1( cPerg, "10", "Consolidado ?" 			, "Consolidado?"  			, "Consolidado ?"  			, "", "N",1 ,00,01,"C",'';
			, ""	,"","","MV_PAR10","Sim","","",""	,"Não","","","","","","","","","","","")
U_PUTSX1( cPerg, "11", "Total por CC ?" 			, "Total por CC ?"  		, "Total por CC ?"   		, "", "N",1 ,00,01,"C",'';
			, ""	,"","","MV_PAR11","Sim","","",""	,"Não","","","","","","","","","","","")
U_PUTSX1( cPerg, "12", "Exibe Provisão?" 			, "Exibe Provisão?"  		, "Exibe Provisão?"   		, "", "N",1 ,00,01,"C",'';
			, ""	,"","","MV_PAR12","Sim","","",""	,"Não","","","","","","","","","","","")
U_PUTSX1( cPerg, "13", "Imp. Bases?" 		  		, "Imp. Bases?"  	  		, "Imp. Bases?"   			, "", "N",1 ,00,01,"C",'';
			, ""	,"","","MV_PAR13","Sim","","",""	,"Não","","","","","","","","","","","")
For i:=1 to nValPerg
	nOrdem := 13 + i
	U_PUTSX1(cPerg,STRZERO(nOrdem,2),"Verbas","Verbas","Verbas","","C",60,00,00,"G",'', "","","","MV_PAR"+STRZERO(nOrdem,2))
Next i

Return .T.

/*
Funcao      : GrvXML()
Parametros  : 
Retorno     : 
Objetivos   : Grava a String enviada no arquivo.
Autor       : João Silva
Data/Hora   : 
*/
*--------------------------*
Static Function GrvXML(cMsg)
*--------------------------*
Local nHdl	:= Fopen(cDest+cArq)

FSeek(nHdl,0,2)
nBytesSalvo += FWRITE(nHdl, cMsg )
fclose(nHdl)

Return ""

/*
Funcao      : GetInfo()
Parametros  : 
Retorno     : 
Objetivos   : Função que executara a query na busca dos dados a serem impressos.
Autor       : João Silva
Data/Hora   : 
*/
*-----------------------*
Static Function GetInfo()
*-----------------------*
Local cQry 		:= ""
Local cVerba 	:= ""
Local cSit 		:= ""
Local cCat		:= ""

cQry += " Select SRD.RD_FILIAL as FILIAL,SRD.RD_MAT as MAT
cQry += " From "+RetSqlName("SRD")+" SRD

//Tratamento que exigem que seja verificado junto ao cadastro de funcionarios, Inner Join, SRA - Cadastro de funcionarios.
If !EMPTY(cSitua) .or. !EMPTY(cCateg)
	cQry += " inner join (Select * From "+RetSqlName("SRA")+" Where D_E_L_E_T_ <> '*'
	If !EMPTY(cSitua)//Situacoes a Imp. ?
		cSit := ""
		For nFor := 1 To Len(cSitua)
			cSit += "'"+Subs(cSitua,nFor,1)+"'"
			cSit += "," 
		Next nFor
		cSit := LEFT(cSit,LEN(cSit)-1)
		cQry += " AND RA_SITFOLH in ("+cSit+")
	EndIf
	If !EMPTY(cCateg)//Categorias a Imp. ? 
		cCat := ""
		For nFor := 1 To Len(cCateg)
			cCat += "'"+Subs(cCateg,nFor,1)+"'"
			cCat += "," 
		Next nFor
		cCat := LEFT(cCat,LEN(cCat)-1)
		cQry += " AND RA_CATFUNC in ("+cCat+")
	EndIf
	cQry += ") as SRA on SRA.RA_FILIAL = SRD.RD_FILIAL AND SRA.RA_MAT = SRD.RD_MAT" 
EndIF

cQry += " Where SRD.D_E_L_E_T_ <> '*'  
                   
//ANO
If !EMPTY(cAno)
	cQry += " AND LEFT(SRD.RD_DATARQ,4) = '"+cAno+"'
EndIF

//Tratamento de tabela compartilhada
If xFilial("SRD") <> ""
	If !EMPTY(cFilDe)//Filial De 
		cQry += " AND SRD.RD_FILIAL >= '"+cFilDe+"'
	EndIF
	If !EMPTY(cFilAte)//Filial Até?
		cQry += " AND SRD.RD_FILIAL <= '"+cFilAte+"'
	EndIF
EndIf
//Centro de Custo De ?
If !EMPTY(cCCDe)
	cQry += " AND SRD.RD_CC >= '"+cCCDe+"'
EndIF
//Centro de Custo Ate ?
If !EMPTY(cCCAte)
	cQry += " AND SRD.RD_CC <= '"+cCCAte+"'
EndIF
//Matricula De ?
If !EMPTY(cMatDe)
	cQry += " AND SRD.RD_MAT >= '"+cMatDe+"'
EndIF
//Matricula Ate ?
If !EMPTY(cMatAte)
	cQry += " AND SRD.RD_MAT <= '"+cMatAte+"'
EndIF
//Verbas
If Len(aVerbas) <> 0
	For nFor := 1 To Len(aVerbas)
		cVerba += "'"+aVerbas[nFor]+"',"
	Next nFor
	cQry += " AND SRD.RD_PD in ("+LEFT(cVerba,LEN(cVerba)-1)+")
EndIf

If cProvi == "Sim"
	cQry += " UNION
	cQry += " Select SRT.RT_FILIAL as FILIAL,SRT.RT_MAT as MAT
	cQry += " From "+RetSqlName("SRT")+" SRT
	//Tratamento que exigem que seja verificado junto ao cadastro de funcionarios, Inner Join, SRA - Cadastro de funcionarios.
	If !EMPTY(cSit) .or. !EMPTY(cCat)
		cQry += " inner join (Select * From "+RetSqlName("SRA")+" Where D_E_L_E_T_ <> '*'
		If !EMPTY(cSit)//Situacoes a Imp. ?
			cQry += " AND RA_SITFOLH in ("+cSit+")
		EndIf
		If !EMPTY(cCat)//Categorias a Imp. ? 
			cQry += " AND RA_CATFUNC in ("+cCat+")
		EndIf
		cQry += ") as SRA on SRA.RA_FILIAL = SRT.RT_FILIAL AND SRA.RA_MAT = SRT.RT_MAT" 
	EndIF
	
	cQry += " Where SRT.D_E_L_E_T_ <> '*'  
	//ANO
	If !EMPTY(cAno)
		cQry += " AND LEFT(SRT.RT_DATACAL,4) = '"+cAno+"'
	EndIF
	//Tratamento de tabela compartilhada
	If xFilial("SRT") <> ""
		If !EMPTY(cFilDe)//Filial De 
			cQry += " AND SRT.RT_FILIAL >= '"+cFilDe+"'
		EndIF
		If !EMPTY(cFilAte)//Filial Até?
			cQry += " AND SRT.RT_FILIAL <= '"+cFilAte+"'
		EndIF
	EndIf
	//Centro de Custo De ?
	If !EMPTY(cCCDe)
		cQry += " AND SRT.RT_CC >= '"+cCCDe+"'
	EndIF
	//Centro de Custo Ate ?
	If !EMPTY(cCCAte)
		cQry += " AND SRT.RT_CC <= '"+cCCAte+"'
	EndIF
	//Matricula De ?
	If !EMPTY(cMatDe)
		cQry += " AND SRT.RT_MAT >= '"+cMatDe+"'
	EndIF
	//Matricula Ate ?
	If !EMPTY(cMatAte)
		cQry += " AND SRT.RT_MAT <= '"+cMatAte+"'
	EndIF
	//Verbas
	If Len(aVerbas) <> 0
		cQry += " AND SRT.RT_VERBA in ("+LEFT(cVerba,LEN(cVerba)-1)+")
	EndIf         
Else
	cQry += " Group By SRD.RD_FILIAL,SRD.RD_MAT
EndIF

If select("QRY")>0
	QRY->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRY",.T.,.T.)

Return cQry

/*
Funcao      : SelVerbas()
Parametros  : 
Retorno     : 
Objetivos   : Função responsavel pela seleção das verbas a serem impresas. (tela de seleção).
Autor       : João Silva
Data/Hora   : 
*/
*-------------------------*
Static Function SelVerbas()
*-------------------------*
Local cQry := ""
Local lRet := .F.

Private cNome	:= ""          
Private cMarca := GetMark()
Private cAlias := "TEMP"
private aCpos :=  {	{"MARCA"	,,""			},;
					{"RV_COD"	,,"Cod.Verba"	},;
					{"RV_DESC"	,,"Descrição" 	},;
	   				{"RV_CODFOL",,"Id.Calc."	}}
		   				
private aCampos :=  {	{"MARCA"	,"C",2 ,0} ,;
						{"RV_COD"	,"C",TAMSX3("RV_COD"	)[1],0},;
						{"RV_DESC"	,"C",TAMSX3("RV_DESC"	)[1],0},;
		   				{"RV_CODFOL","C",TAMSX3("RV_CODFOL"	)[1],0}}

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf     

cNome := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cNome,cAlias,.F.,.F.)

If select("TMP")>0
	TMP->(DbCloseArea())
Endif                                           

cQry += " Select RV_COD,RV_DESC,RV_CODFOL
cQry += " From "+RETSQLNAME("SRV")
cQry += " Where D_E_L_E_T_ <> '*'
cQry += " AND RV_COD in (
cQry += "  				Select RC_PD as VERBA From "+RETSQLNAME("SRC")+" Where D_E_L_E_T_ <> '*'
cQry += " 	 	 		Union
cQry += " 	 	 		Select RD_PD as VERBA From "+RETSQLNAME("SRD")+" Where D_E_L_E_T_ <> '*'
cQry += " 	 	  		Union
cQry += " 	 	  		Select RT_VERBA as VERBA From "+RETSQLNAME("SRT")+" Where D_E_L_E_T_ <> '*')
cQry += " Order by RV_COD

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TMP",.T.,.T.)

nPos   := 0
TMP->(DbGoTop())
While TMP->(!EOF())
	(cAlias)->(RecLock(cAlias,.T.))
	If Len(aVerbas) == 0
		(cAlias)->MARCA	:= cMarca
	Else
		(cAlias)->MARCA	:= IIF(aScan(aVerbas,{|x| x == TMP->RV_COD})==0,"",cMarca)
	EndIf
	(cAlias)->RV_COD	:= TMP->RV_COD
	(cAlias)->RV_DESC	:= TMP->RV_DESC
	(cAlias)->RV_CODFOL	:= TMP->RV_CODFOL
	(cAlias)->(MsUnlock())
	TMP->(DbSkip())
EndDo
TMP->(DbCloseArea())

(cAlias)->(DbGoTop())

oDlg1      := MSDialog():New( 091,232,401,612,"HLB BRASIL",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 004,004,{||"Selecione as verbas a serem impressas!"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,176,008)
DbSelectArea(cAlias)

oBrw1      := MsSelect():New( cAlias,"MARCA","",aCpos,.F.,cMarca,{016,004,124,180},,,oDlg1)
oBrw1:bAval:= {||	cMark()}
oBrw1:oBrowse:lHasMark := .T.
oBrw1:oBrowse:lCanAllmark := .F.
oSBtn1     := SButton():New( 132,116,1,{|| (lret := .T. , oDlg1:END())},oDlg1,,"", )
oSBtn2     := SButton():New( 132,152,2,{|| (lret := .F. , oDlg1:END())},oDlg1,,"", )

oSBtn3 := TButton():New(126,04,"Desarca Todas",oDlg1,{|| cMarkBtn() },50,10,,,.F.,.T.,.F.,,.F.,,,.F. )                                                                                    

oDlg1:Activate(,,,.T.)

If lRet
	aVerbas := {}
	(cAlias)->(DbGoTop())
	While (cAlias)->(!EOF())
		If !EMPTY((cAlias)->MARCA)
			aAdd(aVerbas,(cAlias)->RV_COD)
		EndIf
		(cAlias)->(DbSkip())
	EndDo
EndIf

(cAlias)->(DbCloseArea())

Return .T.

*---------------------*
Static Function cMark()
*---------------------*
Local lDesMarca := (cAlias)->(IsMark("Marca", cMarca))

RecLock(cAlias, .F.)
If lDesmarca
   (cAlias)->MARCA := "  "
Else
   (cAlias)->MARCA := cMarca
Endif
(cAlias)->(MsUnlock())

Return

*------------------------*
Static Function cMarkBtn()
*------------------------*
Local lMarca := .F.

If oSBtn3:cCaption == "Marca Todos"
	oSBtn3:cCaption := "Desmarca Todos"
	lMarca := .T.
Else
	oSBtn3:cCaption := "Marca Todos"
EndIf
    
(cAlias)->(DbGoTop())
While (cAlias)->(!EOF())
	(cAlias)->(RecLock(cAlias,.F.))
	(cAlias)->MARCA := IIF(lMarca,cMarca,"")
	(cAlias)->(MsUnlock())
	(cAlias)->(DbSkip())
EndDo
(cAlias)->(DbGoTop())

Return

/*
Funcao      : WriteXML()
Parametros  : 
Retorno     : 
Objetivos   : Cria o Arquivo XMl
Autor       : João Silva
Data/Hora   : 
*/
*------------------------*
Static Function WriteXML()
*------------------------*
Local cXML := ""      
Local cQry := ""
Local cVerba := ""     
Local cFilMat:= ""
Local i
Local nMeterI:= 0

Private nRowsTable := 0

If Len(aVerbas) <> 0
	For nFor := 1 To Len(aVerbas)
		cVerba += "'"+aVerbas[nFor]+"',"
	Next nFor
	cVerba := left(cVerba,LEN(cVerba)-1)
EndIf
        
cXML += WorkXML("OPEN")
cXML += DefStyle() 

QRY->(DbGoTop())
While QRY->(!EOF())
	nMeterI ++
	oMeter:Set(nMeterI)
	oSayTxt:CCAPTION := "Carregando arquivo "+ALLTRIM(STR(nMeterI))+"/"+ALLTRIM(STR(oMeter:NTOTAL))+"..."
	
	aDados := {}
	//Busca as informações de lançamentos do funcionario.	
	cQry := " Select SRD.RD_PD as PD, SRD.RD_DATARQ+'01' as DATAPD, SRD.RD_VALOR as  VALOR, SRD.RD_CC as CC, 'SRD' as ORIGEM
	cQry += CHR(13)+CHR(10)
	cQry += " From "+RetSqlName("SRD")+" SRD
	cQry += CHR(13)+CHR(10)
	cQry += " Where SRD.D_E_L_E_T_ <> '*'
	cQry += " 	AND SRD.RD_FILIAL = '"+QRY->FILIAL+"'
	cQry += " 	AND SRD.RD_MAT 	= '"+QRY->MAT	+"'
	//ANO
	If !EMPTY(cAno)
		cQry += " 	AND LEFT(SRD.RD_DATARQ,4) = '"+cAno+"'
	EndIF
	//Centro de Custo De ?
	If !EMPTY(cCCDe)
		cQry += " 	AND SRD.RD_CC >= '"+cCCDe+"'
	EndIF
	//Centro de Custo Ate ?
	If !EMPTY(cCCAte)
		cQry += " 	AND SRD.RD_CC <= '"+cCCAte+"'
	EndIF
	//Codigos de verbas
	If Len(aVerbas) <> 0
		cQry += " 	AND SRD.RD_PD in ("+cVerba+")
	EndIf
			     
	If cProvi <> "Sim"//Impressão de Provisão ativado.
		cQry += CHR(13)+CHR(10)
		cQry += " Order By SRD.RD_PD,SRD.RD_DATARQ
	Else
		cQry+= CHR(13)+CHR(10)
		cQry += " Union All
		cQry += CHR(13)+CHR(10)                                          
		cQry += " Select SRT.RT_VERBA as PD,
		cQry += " 		SRT.RT_DATACAL as DATAPD,
		cQry += CHR(13)+CHR(10)
		cQry += " 		(	ISNULL(
		cQry += " 			(Select RT_VALOR From (Select SUM(RT_VALOR) as RT_VALOR,RT_FILIAL,RT_MAT,RT_VERBA,RT_DATACAL
		cQry += " 				From "+RetSqlName("SRT")+" SRT2VALOR
		cQry += " 				Where D_E_L_E_T_ <> '*'
		cQry += " 					AND SRT.RT_FILIAL = SRT2VALOR.RT_FILIAL
		cQry += " 					AND SRT.RT_MAT = SRT2VALOR.RT_MAT
		cQry += " 					AND SRT.RT_VERBA = SRT2VALOR.RT_VERBA
		cQry += " 					AND LEFT(SRT.RT_DATACAL,6) = LEFT(SRT2VALOR.RT_DATACAL,6) 
		cQry += " 				Group By RT_FILIAL,RT_MAT,RT_VERBA,RT_DATACAL) AS VALORa),0)
		cQry += CHR(13)+CHR(10)
		cQry += " 			-  
		cQry += CHR(13)+CHR(10)
		cQry += " 			ISNULL(
		cQry += "			(Select RT_VALOR From (Select SUM(RT_VALOR) as RT_VALOR,RT_FILIAL,RT_MAT,RT_VERBA,RT_DATACAL
		cQry += " 				From "+RetSqlName("SRT")+" SRT2DED Where D_E_L_E_T_ <> '*'
		cQry += " 								AND SRT.RT_FILIAL = SRT2DED.RT_FILIAL
		cQry += " 				  				AND SRT.RT_MAT = SRT2DED.RT_MAT
		cQry += " 				   				AND SRT.RT_VERBA = SRT2DED.RT_VERBA
		cQry += " 				   				AND LEFT(SRT2DED.RT_DATACAL,6) = LEFT(CONVERT(varchar(11),DATEADD(m,-1,SRT.RT_DATACAL),112) ,6)
		cQry += " 				Group By RT_FILIAL,RT_MAT,RT_VERBA,RT_DATACAL) AS VALORb),0)
		cQry += CHR(13)+CHR(10)
		cQry += " 		) as  VALOR,
		cQry += CHR(13)+CHR(10)
		cQry += " 		SRT.RT_CC as CC,
		cQry += " 		'SRT' as ORIGEM
		cQry += CHR(13)+CHR(10)
		cQry += " From "+RetSqlName("SRT")+" SRT  
		cQry += CHR(13)+CHR(10)
		cQry += " Where SRT.D_E_L_E_T_ <> '*'
		cQry += " 	AND SRT.RT_FILIAL = '"+QRY->FILIAL+"'
		cQry += " 	AND SRT.RT_MAT 	= '"+QRY->MAT	+"'
		cQry += CHR(13)+CHR(10)
		//ANO
		If !EMPTY(cAno)
			cQry += "	 AND LEFT(SRT.RT_DATACAL,4) = '"+cAno+"'
		EndIF
		//Centro de Custo De ?
		If !EMPTY(cCCDe)
			cQry += "	 AND SRT.RT_CC >= '"+cCCDe+"'
		EndIF
		//Centro de Custo Ate ?
		If !EMPTY(cCCAte)
			cQry += "	 AND SRT.RT_CC <= '"+cCCAte+"'
		EndIF
		//Codigos de verbas
		If Len(aVerbas) <> 0
			cQry += "	 AND SRT.RT_VERBA in ("+cVerba+")
		EndIf
		cQry += CHR(13)+CHR(10)
		cQry += " Group By RT_FILIAL,RT_MAT,RT_VERBA,RT_DATACAL,RT_CC
		cQry += " Order By PD,DATAPD	
	EndIf
	
	If select("TMP")>0
		TMP->(DbCloseArea())
	Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TMP",.T.,.T.)
	
	nPos   := 0
	TMP->(DbGoTop())
	While TMP->(!EOF())
		//Posiciona na Verba para buscar informações.
		SRV->(DbSetOrder(1))
		SRV->(DbSeek(xFilial("SRV")+TMP->PD))

		If TMP->ORIGEM == "SRT" .or. IIF(cBase=="Sim",.T.,SRV->RV_TIPOCOD<>"3")//Descarta informações de Base dependendo do parametro de filtros.
	  		If TMP->ORIGEM == "SRT" .or. SRV->RV_TIPOCOD == "1" .or. SRV->RV_TIPOCOD == "3"//Provento/base
	  			nFator := 1                                              
			ElseIf SRV->RV_TIPOCOD == "2"//Desconto
	  			nFator := -1			
			EndIf
			If (nPos := aScan(aDados, {|x| x[1] == TMP->PD}) ) <> 0
		   		aDados[npos][IIF(Month(STOD(TMP->DATAPD))==0,14,Month(STOD(TMP->DATAPD))+1)] += (TMP->VALOR*nFator)
		 	Else                       
		 		aAdd(aDados,{TMP->PD,/*JAN*/0,/*FEV*/0,/*MAR*/0,/*ABR*/0,/*MAI*/0,/*JUN*/0,/*JUL*/0,/*AGO*/0,;
		 								/*SET*/0,/*OUT*/0,/*NOV*/0,/*DEZ*/0,/*OUTROS*/0})
		 		aDados[aScan(aDados,{|x| x[1] == TMP->PD})][IIF(Month(STOD(TMP->DATAPD))==0,14,Month(STOD(TMP->DATAPD))+1)]+=(TMP->VALOR*nFator)
		 	EndIf
		 	//Carrega as informações para o Consolidado. 
		 	If cConsol=="Sim"
				If (nPos := aScan(aConsol, {|x| x[1] == TMP->PD}) ) <> 0
			   		aConsol[npos][IIF(Month(STOD(TMP->DATAPD))==0,14,Month(STOD(TMP->DATAPD))+1)] += (TMP->VALOR*nFator)
			 	Else                       
			 		aAdd(aConsol,{TMP->PD,/*JAN*/0,/*FEV*/0,/*MAR*/0,/*ABR*/0,/*MAI*/0,/*JUN*/0,/*JUL*/0,/*AGO*/0,;
			 								/*SET*/0,/*OUT*/0,/*NOV*/0,/*DEZ*/0,/*OUTROS*/0})
			 		aConsol[aScan(aConsol,{|x| x[1] == TMP->PD})][IIF(Month(STOD(TMP->DATAPD))==0,14,Month(STOD(TMP->DATAPD))+1)]+=(TMP->VALOR*nFator)
			 	EndIf
			EndIf
			//Carrega as informações para o Total por centro de custo
		 	If cTotCC=="Sim"
		 		cChave := TMP->CC +"|"+ TMP->PD +"|"+ IIF(nFator>0,"+","-")
		 		If (nPos := aScan(aTotCC, {|x| x[1] == cChave}) ) <> 0
			   		aTotCC[npos][IIF(Month(STOD(TMP->DATAPD))==0,14,Month(STOD(TMP->DATAPD))+1)] += (TMP->VALOR*nFator)
			 	Else                       
			 		aAdd(aTotCC,{cChave,/*JAN*/0,/*FEV*/0,/*MAR*/0,/*ABR*/0,/*MAI*/0,/*JUN*/0,/*JUL*/0,/*AGO*/0,;
			 								/*SET*/0,/*OUT*/0,/*NOV*/0,/*DEZ*/0,/*OUTROS*/0})
			 		aTotCC[aScan(aTotCC, {|x| x[1] == cChave})][IIF(Month(STOD(TMP->DATAPD))==0,14,Month(STOD(TMP->DATAPD))+1)] += (TMP->VALOR*nFator)
			 	EndIf
		 		
			EndIf
		EndIf
		TMP->(DbSkip())
	EndDo

	If select("TMP")>0
		TMP->(DbCloseArea())
	Endif	
    
	//Posiciona no registro do cadastro de funcionarios para utilizar informações
 	SRA->(DbSetOrder(1))
 	SRA->(DbSeek(QRY->FILIAL+QRY->MAT))

	cXML += WorkSheet("OPEN",LEFT(SRA->RA_MAT+"-"+SRA->RA_NOME,20)) 
	cXML += TableSheet("OPEN")
	cXML += RowLastTable()
	cXML += '    <Row >
	cXML += '     <Cell ss:Index="2"><Data ss:Type="String">Employee :</Data></Cell>
	cXML += '     <Cell ss:MergeAcross="6" ss:StyleID="s132"><Data ss:Type="String">'+ALLTRIM(SRA->RA_NOME)+'</Data></Cell>
	cXML += '    </Row>

	//Grava no arquivo fisico e limpa memoria da variavel
	cXML := GrvXML(cXML)
	
	cXML += HeaderTable()
	
	nRowsTable := 0	
	For i:=1 to len(aDados)
		cXML += RowTable(aDados[i])
	Next i

	cXML += TotalTable(nRowsTable)	

	cXML += TableSheet("CLOSE")
	cXML += WorkSheet("CLOSE")

	//Grava no arquivo fisico e limpa memoria da variavel
	cXML := GrvXML(cXML)
	QRY->(DbSkip())
EndDo   
 
If cConsol=="Sim"
	cXML := GrvXML(cXML)
	cXML += PrintConsol()
EndIf

If cTotCC=="Sim"
	cXML := GrvXML(cXML)
	cXML += PrintTotCC()
EndIf

cXML += WorkXML("CLOSE")       

Return cXML

/*
Funcao      : WorkXML()
Parametros  : cOpc
Retorno     : 
Objetivos   : Criação de uma nova estrutura de XML.
Autor       : João Silva
Data/Hora   : 
*/
*---------------------------*
Static Function WorkXML(cOpc)
*---------------------------* 
Local cXML := "" 

If cOpc = "OPEN" 
	cXML += '  <?xml version="1.0"?>
	cXML += '  <?mso-application progid="Excel.Sheet"?>
	cXML += '  <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
	cXML += '   xmlns:o="urn:schemas-microsoft-com:office:office"
	cXML += '   xmlns:x="urn:schemas-microsoft-com:office:excel"
	cXML += '   xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
	cXML += '   xmlns:html="http://www.w3.org/TR/REC-html40">
	cXML += CHR(13)+CHR(10)

ElseIf cOpc = "CLOSE" 
	cXML += ' </Workbook>

EndIf

Return cXML

/*
Funcao      : DefStyle()
Parametros  : cOpc
Retorno     : 
Objetivos   : Definição dos stilos que sera utilizado no XML
Autor       : João Silva
Data/Hora   : 
*/
*------------------------*
Static Function DefStyle()
*------------------------*
Local cXML := "" 

cXML += '   <Styles>
cXML += '    <Style ss:ID="Default" ss:Name="Normal">
cXML += '     <Alignment ss:Vertical="Bottom"/>
cXML += '     <Borders/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXML += '     <Interior/>
cXML += '     <NumberFormat/>
cXML += '     <Protection/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s68">
cXML += '     <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#FFFFFF" ss:Bold="1" ss:Underline="Single"/>
cXML += '     <Interior ss:Color="#16365C" ss:Pattern="Solid"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s76">
cXML += '     <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s77">
cXML += '     <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXML += '     <Borders/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s79">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s80">
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s81">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s83">
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#000000" ss:Bold="1"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s85">
cXML += '     <NumberFormat ss:Format="#,##0;[Red]\-#,##0"/>
cXML += '    </Style>           
cXML += '    <Style ss:ID="s88">
cXML += '     <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="14" ss:Color="#000000"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s91">
cXML += '     <Interior/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s92">
cXML += '     <Interior/>
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s93">
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s126">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
cXML += '     <Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s127">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '     <Interior ss:Color="#EAEAEA" ss:Pattern="Solid"/>
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s128">
cXML += '     <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXML += '     <Borders>
cXML += '      <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     </Borders>
cXML += '    </Style>
cXML += '    <Style ss:ID="s129">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
cXML += '     <Interior ss:Color="#EAEAEA" ss:Pattern="Solid"/>
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s130">
cXML += '     <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF" ss:Bold="1"/>
cXML += '     <Interior ss:Color="#16365C" ss:Pattern="Solid"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s131">
cXML += '     <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF" ss:Bold="1"/>
cXML += '     <Interior ss:Color="#16365C" ss:Pattern="Solid"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s132">
cXML += '     <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
cXML += '     <Interior ss:Color="#EAEAEA" ss:Pattern="Solid"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s133">
cXML += '     <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="14" ss:Color="#FFFFFF" ss:Bold="1" ss:Underline="Single"/>
cXML += '     <Interior ss:Color="#16365C" ss:Pattern="Solid"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s134">
cXML += '     <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#FFFFFF" ss:Bold="1" ss:Underline="Single"/>
cXML += '     <Interior ss:Color="#16365C" ss:Pattern="Solid"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s135">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '     <Borders>
cXML += '      <Border ss:Position="Bottom" ss:LineStyle="Double" ss:Weight="3"/>
cXML += '      <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     </Borders>
cXML += '     <Interior ss:Color="#BFBFBF" ss:Pattern="Solid"/>
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s136">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom" ss:Indent="2"/>
cXML += '     <Borders>
cXML += '      <Border ss:Position="Bottom" ss:LineStyle="Double" ss:Weight="3"/>
cXML += '      <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     </Borders>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#000000"/>
cXML += '     <Interior ss:Color="#BFBFBF" ss:Pattern="Solid"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s137">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
cXML += '     <Interior ss:Color="#EAEAEA" ss:Pattern="Solid"/>
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s138">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '     <Borders>
cXML += '      <Border ss:Position="Bottom" ss:LineStyle="Double" ss:Weight="3"/>
cXML += '      <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
cXML += '     </Borders>
cXML += '     <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>
cXML += '     <Interior ss:Color="#BFBFBF" ss:Pattern="Solid"/>
cXML += '     <NumberFormat ss:Format="#,##0.00;[Red]\-#,##0.00"/>
cXML += '    </Style>
cXML += '    <Style ss:ID="s139">
cXML += '     <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>
cXML += '     <Interior ss:Color="#EAEAEA" ss:Pattern="Solid"/>
cXML += '     <NumberFormat ss:Format="#,##0;[Red]\-#,##0"/>
cXML += '    </Style>
cXML += '   </Styles>
cXML += CHR(13)+CHR(10)

Return cXML

/*
Funcao      : WorkSheet()
Parametros  : cOpc
Retorno     : 
Objetivos   : Criação de uma novo WorkSheet.
Autor       : João Silva
Data/Hora   : 
*/
*----------------------------------------*
Static Function WorkSheet(cOpc,cNameSheet)
*----------------------------------------* 
Local cXML := "" 

Default cNameSheet := STRTRAN(TIME(),"",":")

If cOpc = "OPEN" 
	cXML += '   <Worksheet ss:Name="'+ALLTRIM(cNameSheet)+'">
	cXML += CHR(13)+CHR(10)

ElseIf cOpc = "CLOSE" 
	cXML += '   <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
	cXML += '    <PageSetup>
	cXML += '     <Layout x:Orientation="Landscape"/>
	cXML += '     <Header x:Margin="0.3"/>
	cXML += '     <Footer x:Margin="0.3"/>
	cXML += '     <PageMargins x:Bottom="0.75" x:Left="0.7" x:Right="0.7" x:Top="0.75"/>
	cXML += '    </PageSetup>
	cXML += '    <Print>
	cXML += '     <ValidPrinterInfo/>
	cXML += '     <PaperSizeIndex>9</PaperSizeIndex>
	cXML += '     <Scale>62</Scale>
	cXML += '     <HorizontalResolution>600</HorizontalResolution>
	cXML += '     <VerticalResolution>600</VerticalResolution>
	cXML += '    </Print>
   	If cNameSheet == "CONSOLIDATED"
		cXML += '    <TabColorIndex>53</TabColorIndex>
	ElseIf cNameSheet == "COST CENTER"
		cXML += '    <TabColorIndex>21</TabColorIndex>
	EndIf
	cXML += '    <PageBreakZoom>60</PageBreakZoom>
	cXML += '    <Selected/>
	cXML += '    <DoNotDisplayGridlines/>
	cXML += '    <FreezePanes/>
	cXML += '    <FrozenNoSplit/>
	cXML += '    <SplitHorizontal>4</SplitHorizontal>
	cXML += '    <TopRowBottomPane>4</TopRowBottomPane>
	cXML += '    <SplitVertical>5</SplitVertical>
	cXML += '    <LeftColumnRightPane>5</LeftColumnRightPane>
	cXML += '    <ActivePane>0</ActivePane>
	cXML += '    <Panes>
	cXML += '     <Pane>
	cXML += '      <Number>3</Number>
	cXML += '      <ActiveRow>2</ActiveRow>
	cXML += '      <ActiveCol>1</ActiveCol>
	cXML += '      <RangeSelection>R3C2:R3C6</RangeSelection>
	cXML += '     </Pane>
	cXML += '     <Pane>
	cXML += '      <Number>1</Number>
	cXML += '      <ActiveRow>2</ActiveRow>
	cXML += '      <ActiveCol>1</ActiveCol>
	cXML += '      <RangeSelection>R3C2:R3C6</RangeSelection>
	cXML += '     </Pane>
	cXML += '     <Pane>
	cXML += '      <Number>2</Number>
	cXML += '      <ActiveRow>2</ActiveRow>
	cXML += '      <ActiveCol>1</ActiveCol>
	cXML += '      <RangeSelection>R3C2:R3C6</RangeSelection>
	cXML += '     </Pane>
	cXML += '     <Pane>
	cXML += '      <Number>0</Number>
	cXML += '      <ActiveRow>40</ActiveRow>
	cXML += '      <ActiveCol>3</ActiveCol>
	cXML += '     </Pane>
	cXML += '    </Panes>
	cXML += '    <ProtectObjects>False</ProtectObjects>
	cXML += '    <ProtectScenarios>False</ProtectScenarios>
	cXML += '   </WorksheetOptions>
	cXML += CHR(13)+CHR(10)
	cXML += '  </Worksheet>
	cXML += CHR(13)+CHR(10)
EndIf

Return cXML

/*
Funcao      : RowLastTable()
Parametros  : 
Retorno     : 
Objetivos   : Criação de uma novo WorkSheet.
Autor       : João Silva
Data/Hora   : 
*/
*----------------------------*
Static Function RowLastTable()
*----------------------------* 
Local cXML := ""

cXML += '    <Row ss:Height="15.75">
cXML += '     <Cell ss:Index="2" ss:StyleID="s83"><Data ss:Type="String">'+AllTrim(SM0->M0_NOMECOM)+'</Data></Cell>
cXML += '    </Row>
cXML += CHR(13)+CHR(10)

Return cXML

/*
Funcao      : TableSheet()
Parametros  : 
Retorno     : 
Objetivos   : Criação da Tabela.
Autor       : João Silva
Data/Hora   : 
*/
*-----------------------------*
Static Function TableSheet(cOpc)
*-----------------------------* 
Local cXML := ""

If cOpc = "OPEN" 
	cXML += '    <Table ss:ExpandedColumnCount="48" ss:ExpandedRowCount="2000" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="6"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="57"/>
	cXML += '     <Column ss:Width="56.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="50.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="3.75"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="8" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="11" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="14" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="17" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="20" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="23" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="26" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="29" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="32" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="35" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="38" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="33" ss:Span="1"/>
	cXML += '     <Column ss:Index="41" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="36.75" ss:Span="1"/> 
	cXML += '     <Column ss:Index="44" ss:AutoFitWidth="0" ss:Width="5.25"/>
	cXML += '     <Column ss:AutoFitWidth="0" ss:Width="36.75" ss:Span="1"/>
	cXML += CHR(13)+CHR(10)

ElseIf cOpc = "CLOSE" 
	cXML += '   </Table>
	cXML += CHR(13)+CHR(10)
	
EndIf

Return cXML

/*
Funcao      : HeaderTable()
Parametros  : 
Retorno     : 
Objetivos   : Criação do cabeçalho da tabela.
Autor       : João Silva
Data/Hora   : 
*/
*-------------------------------------*
Static Function HeaderTable(cNameSheet)
*-------------------------------------*
Local cXML := ""

Default cNameSheet := ""

cXML += '    <Row ss:AutoFitHeight="0">
If cNameSheet <> "COST CENTER"
	cXML += '     <Cell ss:Index="2" ss:MergeAcross="2" ss:MergeDown="1" ss:StyleID="s133"><Data ss:Type="String">Payroll</Data></Cell>
Else
	cXML += '     <Cell ss:Index="2" ></Cell> 
EndIf
cXML += '     <Cell ss:Index="6" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">January</Data></Cell>
cXML += '     <Cell ss:Index="9" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">February</Data></Cell>
cXML += '     <Cell ss:Index="12" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">March</Data></Cell>
cXML += '     <Cell ss:Index="15" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">April</Data></Cell>
cXML += '     <Cell ss:Index="18" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">May</Data></Cell>
cXML += '     <Cell ss:Index="21" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">June</Data></Cell>
cXML += '     <Cell ss:Index="24" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">July</Data></Cell>
cXML += '     <Cell ss:Index="27" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">August</Data></Cell>
cXML += '     <Cell ss:Index="30" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">September</Data></Cell>
cXML += '     <Cell ss:Index="33" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">October</Data></Cell>
cXML += '     <Cell ss:Index="36" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">November</Data></Cell>
cXML += '     <Cell ss:Index="39" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">December</Data></Cell>
cXML += '     <Cell ss:Index="42" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">Other</Data></Cell>
cXML += '     <Cell ss:Index="45" ss:MergeAcross="1" ss:StyleID="s134"><Data ss:Type="String">Consolidated</Data></Cell>
cXML += '    </Row>
cXML += CHR(13)+CHR(10)
cXML += '   <Row ss:AutoFitHeight="0">
cXML += '    <Cell ss:Index="6" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+cAno+'</Data></Cell>
cXML += '    <Cell ss:Index="9" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+cAno+'</Data></Cell>
cXML += '    <Cell ss:Index="12" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+cAno+'</Data></Cell>
cXML += '    <Cell ss:Index="15" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+cAno+'</Data></Cell>
cXML += '    <Cell ss:Index="18" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+cAno+'</Data></Cell>
cXML += '    <Cell ss:Index="21" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+cAno+'</Data></Cell>
cXML += '    <Cell ss:Index="24" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+cAno+'</Data></Cell>
cXML += '    <Cell ss:Index="27" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+cAno+'</Data></Cell>
cXML += '    <Cell ss:Index="30" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+cAno+'</Data></Cell>
cXML += '    <Cell ss:Index="33" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+cAno+'</Data></Cell>
cXML += '    <Cell ss:Index="36" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+cAno+'</Data></Cell>
cXML += '    <Cell ss:Index="39" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+cAno+'</Data></Cell>
cXML += '    <Cell ss:Index="42" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+cAno+'</Data></Cell>
cXML += '    <Cell ss:Index="45" ss:MergeAcross="1" ss:StyleID="s68"><Data ss:Type="Number">'+cAno+'</Data></Cell>
cXML += '   </Row>
cXML += CHR(13)+CHR(10)

Return cXML

/*
Funcao      : RowTable()
Parametros  : 
Retorno     : 
Objetivos   : Criação de um novo registro no excel.
Autor       : João Silva
Data/Hora   : 
*/
*------------------------------*
Static Function RowTable(aDados)
*------------------------------*
Local cXML := ""        
Local cCod	:= ""
Local cDesc := ""

//Posiciona na Verba para buscar informações.
SRV->(DbSetOrder(1))
If SRV->(DbSeek(xFilial("SRV")+aDados[1]))
	cCod	:= SRV->RV_COD
	If SRV->(FieldPos("RV_PAYROLL")) > 0 .And.  SRV->(FieldPos("RV_DPAYROL")) > 0 .And. SRV->RV_PAYROLL
		cDesc := ALLTRIM(SRV->RV_DPAYROL)
	Else
		cDesc := ALLTRIM(SRV->RV_DESC)
	EndIf
Else
	cCod	:= ""
	cDesc := ALLTRIM(aDados[1])
EndIf

cXML += '    <Row >
cXML += '     <Cell ss:Index="2" ss:MergeAcross="2" ss:StyleID="s128"><Data ss:Type="String">'+cCod+' - '+cDesc+'</Data></Cell>
cXML += '     <Cell ss:StyleID="s76"></Cell>
cXML += '     <Cell ss:Index="6"  ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[2],"9999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="9"  ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[3],"9999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="12" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[4],"9999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="15" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[5],"9999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="18" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[6],"9999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="21" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[7],"9999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="24" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[8],"9999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="27" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[9],"9999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="30" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[10],"9999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="33" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[11],"9999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="36" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[12],"9999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="39" ss:MergeAcross="1" ss:StylwedeneID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[13],"9999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="42" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aDados[14],"9999999999.99"),",","."))+'</Data></Cell>
cXML += '     <Cell ss:Index="45" ss:MergeAcross="1" ss:StyleID="s126" ss:Formula="=SUM(RC[-39]:RC[-1])"></Cell>
cXML += '    </Row>
cXML += CHR(13)+CHR(10)
nRowsTable++

cXML += LnEmpty()
nRowsTable++

Return cXml

/*
Funcao      : TotalTable()
Parametros  : 
Retorno     : 
Objetivos   : Criação do cabeçalho da tabela.
Autor       : João Silva
Data/Hora   : 
*/
*--------------------------------------------*
Static Function TotalTable(nRowsTable,cTitulo)
*--------------------------------------------*
Local cXML := ""                           

Default cTitulo := "TOTAL"

cXML += '    <Row ss:Height="16.5">
cXML += '     <Cell ss:Index="2"  ss:MergeAcross="2" ss:StyleID="s136"><Data ss:Type="String">'+cTitulo+'</Data></Cell>
cXML += '     <Cell ss:Index="6"  ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="9"  ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="12" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="15" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="18" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="21" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="24" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="27" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="30" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="33" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="36" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="39" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="42" ss:MergeAcross="1" ss:StyleID="s135" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '     <Cell ss:Index="45" ss:MergeAcross="1" ss:StyleID="s138" ss:Formula="=SUM(R[-'+ALLTRIM(STR(nRowsTable))+']C:R[-1]C[1])"></Cell>
cXML += '    </Row>
cXML += CHR(13)+CHR(10)

Return cXml

/*
Funcao      : PrintConsol()
Parametros  : 
Retorno     : 
Objetivos   : Função responsavel pela impressão do Consolidado.
Autor       : João Silva
Data/Hora   : 
*/
*---------------------------*
Static Function PrintConsol()
*---------------------------*
Local cXML := "" 
Local i

cXML += WorkSheet("OPEN","CONSOLIDATED") 
cXML += TableSheet("OPEN")
cXML += RowLastTable()

cXML += '    <Row >
cXML += '     <Cell ss:MergeAcross="6" ss:StyleID="s132"><Data ss:Type="String">Consolidated report</Data></Cell>
cXML += '    </Row>

cXML += HeaderTable()
	
//Grava no arquivo fisico e limpa memoria da variavel
cXML := GrvXML(cXML)

//Ordena as verbas, Somente o primeiro vetor.
ASort( aConsol,,,{|x,y| x[1] < y[1]})

nRowsTable := 0		
For i:=1 to len(aConsol)
	cXML += RowTable(aConsol[i])
Next i
	
//Grava no arquivo fisico e limpa memoria da variavel
cXML := GrvXML(cXML)
	
cXML += TotalTable(nRowsTable)
	
cXML += TableSheet("CLOSE")
cXML += WorkSheet("CLOSE","CONSOLIDATED")

Return cXml

/*
Funcao      : PrintTotCC()
Parametros  : 
Retorno     : 
Objetivos   : Função responsavel pela impressão da WorkSheet com total por Centro de Custo.
Autor       : João Silva
Data/Hora   : 
*/
*--------------------------*
Static Function PrintTotCC()
*--------------------------*
Local i
Local cXML		:= "" 
Local cCc		:= ""
Local cVerba	:= ""
Local cFator	:= ""
Local cDesc		:= ""
Local nRowsTable:= 0

SRV->(DbSetOrder(1))
CTT->(DbSetOrder(1))

aTotCC := aSort(aTotCC,,, { |x, y| x[1] < y[1] })

cXML += WorkSheet("OPEN","COST CENTER") 
cXML += TableSheet("OPEN")
cXML += RowLastTable()

cXML += '    <Row >
cXML += '     <Cell ss:MergeAcross="6" ss:StyleID="s132"><Data ss:Type="String">Cost Center</Data></Cell>
cXML += '    </Row>

cXML += HeaderTable("COST CENTER")

//Grava no arquivo fisico e limpa memoria da variavel
cXML := GrvXML(cXML)

For i:=1 to len(aTotCC)
	If cCc <> Left(aTotCC[i][1],AT("|",aTotCC[i][1])-1)
  		If !EMPTY(cCc)
			cXML += TotalTable(nRowsTable)
			nRowsTable := 0
			cXML += LnEmpty()
		EndIf  

		cXML += LnEmpty()
   		CTT->(DbSeek(xFilial("CTT")+Left(aTotCC[i][1],AT("|",aTotCC[i][1])-1)))
		cXML += '    <Row >
		cXML += '     <Cell ss:Index="2" ss:MergeAcross="2" ss:StyleID="s134"><Data ss:Type="String">'+;
															CTT->CTT_CUSTO+' - '+ALLTRIM(CTT->CTT_DESC01)+'</Data></Cell>
		cXML += '     <Cell ></Cell>
		cXML += '     <Cell ss:Index="6" ></Cell>
		cXML += '     <Cell ss:Index="9" ></Cell>
		cXML += '     <Cell ss:Index="12"></Cell>
		cXML += '     <Cell ss:Index="15"></Cell>
		cXML += '     <Cell ss:Index="18"></Cell>
		cXML += '     <Cell ss:Index="21"></Cell>
		cXML += '     <Cell ss:Index="24"></Cell>
		cXML += '     <Cell ss:Index="27"></Cell>
		cXML += '     <Cell ss:Index="30"></Cell>
		cXML += '     <Cell ss:Index="33"></Cell>
		cXML += '     <Cell ss:Index="36"></Cell>
		cXML += '     <Cell ss:Index="39"></Cell>
		cXML += '     <Cell ss:Index="42"></Cell>
		cXML += '     <Cell ss:Index="45"></Cell>
		cXML += '    </Row>
		cXML += LnEmpty()	
	EndIf

	cFator	:= RIGHT(aTotCC[i][1],1)
	cVerba	:= SubStr(aTotCC[i][1],AT("|",aTotCC[i][1])+1,3)
	cCc		:= Left(aTotCC[i][1],AT("|",aTotCC[i][1])-1)

	//Posiciona na Verba para buscar informações.
	SRV->(DbSeek(xFilial("SRV")+cVerba))
	If SRV->(FieldPos("RV_PAYROLL")) > 0 .And.  SRV->(FieldPos("RV_DPAYROL")) > 0 .And. SRV->RV_PAYROLL
		cDesc := ALLTRIM(SRV->RV_DPAYROL)
	Else
		cDesc := ALLTRIM(SRV->RV_DESC)
	EndIf
	
	cXML += '    <Row >
	cXML += '     <Cell ss:Index="2" ss:MergeAcross="2" ss:StyleID="s128"><Data ss:Type="String">'+SRV->RV_COD+' - '+cDesc+'</Data></Cell>
	cXML += '     <Cell ss:StyleID="s76"></Cell>
	cXML += '     <Cell ss:Index="6"  ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][2] ,"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="9"  ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][3] ,"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="12" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][4] ,"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="15" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][5] ,"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="18" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][6] ,"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="21" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][7] ,"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="24" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][8] ,"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="27" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][9] ,"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="30" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][10],"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="33" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][11],"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="36" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][12],"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="39" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][13],"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="42" ss:MergeAcross="1" ss:StyleID="s127"><Data ss:Type="Number">'+ALLTRIM(STRTRAN(Transform(aTotCC[i][14],"9999999999.99"),",","."))+'</Data></Cell>
	cXML += '     <Cell ss:Index="45" ss:MergeAcross="1" ss:StyleID="s126" ss:Formula="=SUM(RC[-36]:RC[-1])"></Cell>
	cXML += '    </Row>

	cXML += LnEmpty()
	nRowsTable += 2
Next i                                    

cXML += TotalTable(nRowsTable)

//Grava no arquivo fisico e limpa memoria da variavel
cXML := GrvXML(cXML)

cXML += TableSheet("CLOSE")
cXML += WorkSheet("CLOSE","COST CENTER")

Return cXml

/*
Funcao      : LnEmpty()
Parametros  : 
Retorno     : 
Objetivos   : Função responsavel pela impressão de Linha em branco na WorkSheet.
Autor       : João Silva
Data/Hora   : 
*/
*------------------------------*
Static Function LnEmpty(cHeight)
*------------------------------*
Local cXml := ""

Default cHeight := "3.75"
	cXML += '    <Row ss:AutoFitHeight="0" ss:Height="'+cHeight+'">
	cXML += '     <Cell ss:Index="2" ss:StyleID="s76"></Cell>
	cXML += '     <Cell ss:StyleID="s76"></Cell>
	cXML += '     <Cell ss:StyleID="s76"></Cell>
	cXML += '     <Cell ss:StyleID="s76"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="9" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="12" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="15" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="18" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="21" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="24" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="27" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="30" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="33" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="36" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="39" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="42" ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:StyleID="s79"></Cell>
	cXML += '     <Cell ss:Index="45" ss:StyleID="s81"></Cell>
	cXML += '     <Cell ss:StyleID="s81"></Cell>
	cXML += '    </Row>

Return cXml
