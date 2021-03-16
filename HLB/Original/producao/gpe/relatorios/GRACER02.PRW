#Include "FIVEWIN.CH" 

/*       
Funcao      : GRACER02
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Relacao de Horas / Valores por centro de custo
Autor       : JAIRO OLIVEIRA
Data        : 06/01/12
Obs         : 
TDN         : 
Revisão     : Renato Rezende
Data/Hora   : 13/05/2013
Módulo      : Gestão de Pessoal
Cliente     : 
*/

*-----------------------*
USER Function GRACER02()
*-----------------------*

Local oReport
PRIVATE cPERG		:= "GRACER02" 

validPerg()

If FindFunction("TRepInUse") .And. TRepInUse()
	//-- Interface de impressao
	Pergunte(CPERG,.F.)
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	Alert("Função não Criada, Favor usar personalizado SIM")
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Marco Bianchi         ³ Data ³01/06/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

*--------------------------*
Static Function ReportDef()
*--------------------------*

LOCAL CDESCSIT	:= CDESCSEX	:= CDESCEST	:= ""

Local oReport
Local oBreak1
Local oBreak2
Local oBreak3
Local cAliasQry := GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("RGRACER02","RELATORIO POR CC",CPERG, {|oReport| ReportPrint(oReport,cAliasQry)},"ESTE PROGRAMA LISTA OS FUNCIONARIOS" + " " + "DE ACORDO COM AS SELECOES PEDIDAS")	// "Relatorios de Visitas"###"Este programa ira emitir a relacao de visitas aos clientes,"###"feitas pelos vendedores."
oReport:SetPortrait() 
oReport:SetTotalInLine(.F.)
Pergunte(oReport:uParam,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oVisitas:= 	TRSection():New(oReport, "GERAL POR CC "  ,{"SRC"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Relatorios de Visitas"
oVisitas:SetTotalInLine(.F.)
                                                                      
TRCell():New(oVisitas,"RC_FILIAL"		,"SRC","FL"							,PesqPict("SRC","RC_FILIAL")		,TamSX3("RC_FILIAL")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVisitas,"RC_MAT"			,"SRC",RetTitle("RC_MAT")			,PesqPict("SRC","RC_MAT")			,TamSX3("RC_MAT")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVisitas,"RA_NOME"			,"SRA",RetTitle("RA_NOME")			,PesqPict("SRA","RA_NOME")			,TamSX3("RA_NOME")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVisitas,"RA_CATFUNC"		,"SRA",RetTitle("RA_CATFUNC")			,PesqPict("SRA","RA_CATFUNC")			,TamSX3("RA_CATFUNC")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oVisitas,"RC_CC"			,"SRC","C.Cus"						,PesqPict("SRC","RC_CC")			,TamSX3("RC_CC")[1]			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVisitas,"CTT_DESC01"		,"CTT","Centro Cust."				,/* */								,TamSX3("CTT_DESC01")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oVisitas,"RV_DESC"			,"SRV",RetTitle("RV_DESC")			,PesqPict("SRV","RV_DESC")		,TamSX3("RV_DESC")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVisitas,"RC_VALOR"		,"SRC",RetTitle("RC_VALOR")			,PesqPict("SRC","RC_VALOR")		,TamSX3("RC_VALOR")[1]	,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oVisitas,'QUANTHOR'	,'   ',"Horas"	,"@E 999999.99"	,10	   		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVisitas,'QUANTITEM'	,'   ',"TOT FUNC."	,"@E 999999"	,6	   		,/*lPixel*/,/*{|| code-block de impressao }*/)


Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ	ÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Eduardo Riera          ³ Data ³04.05.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

*----------------------------------------------*
Static Function ReportPrint(oReport,cAliasQry)
*----------------------------------------------*

Local cVend 	:= ""    
Local cWHEN		:= "%%"
Local cORDER	:= "%%"
Local aAreaSA1 	:= SA1->(GetArea())
Local lNOMES	:= .T.
Local nQuantIt	:= 0
Local nQuantHr	:= 0
Local oVisitas  := oReport:Section(1)
//Local oVisitas	:= oReport:section(1)

#IFNDEF TOP
	Local cCondicao := ""
#ENDIF


oReport:SetTitle( IF(MV_PAR04=1,"RELATORIO DE HORAS POR CC - ","RELATORIO DE VALORES POR CC - ") + SUBSTR(DTOS(MV_PAR03),5,2) + "/" + SUBSTR(DTOS(MV_PAR03),1,4) )


oBreak2 := TRBreak():New(oVisitas,oVisitas:Cell("RC_CC"),"Sub Total CC")

If oReport:nDevice != 4
	TRFunction():New(oVisitas:Cell("RC_MAT"),NIL,"COUNT",oBreak2 ,,, 				,.F.,.F.,.F.,oVisitas )
endif

IF MV_PAR04 = 1
	TRFunction():New(oVisitas:Cell("QUANTHOR"),NIL,"SUM",oBreak2 ,,, 				,.F.,.F.,.F.,oVisitas )
ELSE
	TRFunction():New(oVisitas:Cell("RC_VALOR"),NIL,"SUM",oBreak2 ,,, 				,.F.,.F.,.F.,oVisitas )
ENDIF
TRFunction():New(oVisitas:Cell("QUANTITEM"),NIL,"SUM",oBreak2 ,,, 				,.F.,.F.,.F.,oVisitas )


oBreak1 := TRBreak():New(oVISITAS,oVISITAS:Cell("RC_FILIAL"),"Sub Total filial")

IF MV_PAR04 = 1
	TRFunction():New(oVisitas:Cell("QUANTHOR"),NIL,"SUM",oBreak1)
ELSE
	TRFunction():New(oVisitas:Cell("RC_VALOR"),NIL,"SUM",oBreak1)
ENDIF
TRFunction():New(oVisitas:Cell("QUANTITEM"),NIL,"SUM",oBreak1,,, 				,.F.,.F.,.F.,oVisitas )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatório                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatório da secao 1                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	MakeSqlExpr(cPERG)
	IF SUBSTR(DTOS(MV_PAR03),1,6) == SUPERGETMV("MV_FOLMES",.F.,"      ")
		lNoMes	:= .T.
	ELSE
		MV_PAR01 := STRTRAN(MV_PAR01,"RC_","RD_")
		MV_PAR02 := STRTRAN(MV_PAR02,"RC_","RD_")
		lNoMes	:= .f.
	ENDIF
                 
	CWHEN := "%"
	IF !EMPTY(MV_PAR01)
		CWHEN := CWHEN + MV_PAR01 +  " "
	ELSE
		CWHEN := CWHEN + " SRC." + if(lnomes,"RC_","RD_" ) + "FILIAL >= '  ' "
	ENDIF                                         
	
	IF !EMPTY(MV_PAR02)
		CWHEN := CWHEN + " AND " + MV_PAR02 +  " "
	ELSE
		CWHEN := CWHEN + " AND  SRC." + if(lnomes,"RC_","RD_" ) + "CC >= '  ' "
	ENDIF                                         

	IF MV_PAR04 = 1 // HORAS
		CWHEN := CWHEN + " AND SRC."  + IF(LNOMES,"RC_","RD_") + "HORAS <> 0 "
		CWHEN := CWHEN + " AND SRV.RV_RSREL IN ('H','A') " // HORAS OU AMBOS
	ELSE
		CWHEN := CWHEN + " AND SRC."  + IF(LNOMES,"RC_","RD_") + "VALOR <> 0 "
		CWHEN := CWHEN + " AND SRV.RV_RSREL IN ('V','A') " // VALORES OU AMBOS
	ENDIF
	
	if !lNoMes
		cWhen := cWhen + " AND SRC.RD_DATARQ = '" + SUBSTR(DTOS(MV_PAR03),1,6) + "' "
	endif
	CWHEN := CWHEN + "%" 
	
	cORDER := "% RC_FILIAL,RC_CC,RC_MAT % "
	
	memowrite("C:\TEMP\JJWHEN.TXT",cWhen)  

	oReport:Section(1):BeginQuery()
	
	IF lNoMes
		BeginSql Alias cAliasQry
		SELECT RA_NOME, 
		       RA_SALARIO, 
		       RV_DESC, 
		       RV_TIPOCOD, 
		       RV_CODFOL, 
		       RA_CATFUNC, 
		       RA_HRSMES, 
		       RC_FILIAL RC_FILIAL, 
		       RC_CC     RC_CC, 
		       RC_MAT    RC_MAT, 
		       RC_PD     RC_PD, 
		       RC_TIPO1  RC_TIPO1, 
		       RC_HORAS  RC_HORAS, 
		       RC_VALOR  RC_VALOR ,
		       CTT_DESC01
		FROM   %Table:SRC% SRC, 
		       %Table:SRV% SRV, 
		       %Table:SRA% SRA, 
		       %Table:CTT% CTT 
		WHERE
		       %EXP:CWHEN%
		       AND SRV.RV_FILIAL = %xFilial:SRV%
		       AND RV_COD = RC_PD 
		       AND SRV.%notdel% 
		       AND SRC.%NOTDEL%
		       AND SRA.RA_FILIAL = SRC.RC_FILIAL 
		       AND SRA.RA_MAT = SRC.RC_MAT 
		       AND SRA.%NOTDEL%
		       AND CTT.CTT_FILIAL = SRA.RA_FILIAL 
		       AND CTT.CTT_CUSTO = SRC.RC_CC 
		       AND CTT.%NOTDEL%
		ORDER  BY RC_FILIAL,RC_CC,RC_MAT

		EndSql
	ELSE
		BeginSql Alias cAliasQry
		SELECT RA_NOME, 
		       RA_SALARIO, 
		       RV_DESC, 
		       RV_TIPOCOD, 
		       RV_CODFOL, 
		       RA_CATFUNC, 
		       RA_HRSMES, 
		       RD_FILIAL RC_FILIAL, 
		       RD_CC     RC_CC, 
		       RD_MAT    RC_MAT, 
		       RD_PD     RC_PD, 
		       RD_TIPO1  RC_TIPO1, 
		       RD_HORAS  RC_HORAS, 
		       RD_VALOR  RC_VALOR ,
		       CTT_DESC01
		FROM   %Table:SRD% SRC, 
		       %Table:SRV% SRV, 
		       %Table:SRA% SRA, 
		       %Table:CTT% CTT 
		WHERE
		       %EXP:CWHEN%
		       AND SRV.RV_FILIAL = %xFilial:SRV%
		       AND RV_COD = RD_PD 
		       AND SRV.%notdel% 
		       AND SRC.%NOTDEL%
		       AND SRA.RA_FILIAL = SRC.RD_FILIAL 
		       AND SRA.RA_MAT = SRC.RD_MAT 
		       AND SRA.%NOTDEL%
		       AND CTT.CTT_FILIAL = SRA.RA_FILIAL 
		       AND CTT.CTT_CUSTO = SRC.RD_CC 
		       AND CTT.%NOTDEL%
		ORDER  BY  RD_FILIAL,RD_CC,RD_MAT

		EndSql
	ENDIF
	
	
	
	//EndSql 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Metodo EndQuery ( Classe TRSection )                                    ³
	//³                                                                        ³
	//³Prepara o relatório para executar o Embedded SQL.                       ³
	//³                                                                        ³
	//³ExpA1 : Array com os parametros do tipo Range                           ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):EndQuery({MV_PAR01})
		
#ELSE 
/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Utilizar a funcao MakeAdvlExpr, somente quando for utilizar o range de parametros para ambiente CDX ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeAdvplExpr("MTR530P9R1")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera arquivo de trabalho para nao haver necessidade de se    ³
	//³ criar um indice por vendedor                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA1")
	dbSetOrder(1)
	cAliasQry 	:= "SA1"
	cKey 		:= "A1_VEND"
	cCondicao := "" 
	cCondicao += "A1_FILIAL='" + xFilial("SA1") + "'.AND."            
	
	If !Empty(mv_par01)
		cCondicao += +mv_par01
	EndIf
	
	oReport:Section(1):SetFilter(cCondicao,"A1_VEND") 

	DbGoTop()
*/	
#ENDIF		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatório                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cVend := (cAliasQry)->A1_VEND


cchave_ := ""
oReport:SetMeter(&(cAliasQry)->(LastRec()))
oReport:Section(1):Init()
oReport:Section(1):Cell('QUANTITEM'):HIDE()

if mv_par04 = 1 // horas
	oReport:Section(1):Cell('RC_VALOR'):disable() //HIDE()
else
	oReport:Section(1):Cell('QUANTHOR'):disable() //HIDE()
endif

While !oReport:Cancel() .And. !(cAliasQry)->(Eof())
	

	if cChave_ == (cAliasQRY)->Rc_mat 
		If oReport:nDevice != 4
			oReport:Section(1):Cell('RC_MAT'):HIDE()
			oReport:Section(1):Cell('RA_NOME'):HIDE()
		endif
		nQuantIt := 0
	else
		cChave_ := (cAliasQRY)->Rc_mat
		If oReport:nDevice != 4
			oReport:SkipLine()
			oReport:Section(1):Cell('RC_MAT'):SHOW()
			oReport:Section(1):Cell('RA_NOME'):SHOW()
		endif
		nQuantIt := 1
	endif
	
	if (cAliasQry)->RV_CODFOL = STRZERO(31,TAMSX3("RV_CODFOL")[1])//'031' // SALARIO MENSALISTA
		nQuanthr := ROUND( ( (cAliasQRY)->RA_HRSMES * (cAliasQRY)->RC_HORAS) / 30 , 2 )
	ELSE
		nQuanthr := (cAliasQry)->RC_HORAS
	ENDIF
	
	oReport:Section(1):Cell('QUANTITEM'	):SetValue(nQuantIt)	
	oReport:Section(1):Cell('QUANTHOR'	):SetValue(nQuantHr)	
	
	oReport:Section(1):PrintLine()
	dbSelectArea(cAliasQry)
	dbSkip()
		
EndDo

oReport:Section(1):Finish()
RestArea(aAreaSA1)
     
Return                      

*-------------------------------*
Static Function fDescSexo(cCod)
*-------------------------------*

Return(If(cCod =="F", "Feminino","Masculino" ))	//"Feminino"###"Masculino"

STATIC FUNCTION SFRETIN(CVAR)
LOCAL AVAR := {}
LOCAL NX := 0
LOCAL CRET := ""

FOR NX := 1 TO LEN(CVAR)
	CRET := CRET + IF( len(CRET) = 0 ,"",",") +  SUBSTR( CVAR,NX,1)
NEXT                                
RETURN( FORMATIN( CRET , ",") )

*------------------------------------*
Static function _fAtuSx1(cPerg,aRegs)
*------------------------------------*

local _nOrdSx1:=sx1->(indexord()),;
      _nRecSx1:=sx1->(recno()),_nVez,_lApaga:=.f.,_nPergs:=0

sx1->(dbsetorder(1))
// Verifica se o formato solicitado ainda e o mesmo, caso contrario,
// apaga e inclui tudo novamente
For _nVez:=1 to Len(aRegs)
  If sx1->(DbSeek(cPerg+aRegs[_nVez,2],.f.))
     _nPergs++
     if alltrim(sx1->x1_pergunt)<>alltrim(aRegs[_nVez,3])
        if len(aRegs[_nVez,3])>len(sx1->x1_pergunt)
           msgbox("Atencao, a pergunta: ["+alltrim(aRegs[_nVez,3])+"] nao cabe no campo X1_PERGUNT")
        endif   
        _lApaga:=.t.
        exit
     endif   
  endif   
next
if _nPergs<>len(aRegs).or._lApaga          
   sx1->(DbSeek(cPerg,.f.))
   do while sx1->(!eof().and.alltrim(x1_grupo)==alltrim(aRegs[1,1]))
      if sx1->(reclock(alias(),.f.))
         sx1->(dbdelete())
         sx1->(msunlock())
      endif
      sx1->(dbskip(1))
   enddo
endif

For _nVez:=1 to Len(aRegs)
  If !sx1->(DbSeek(cPerg+aRegs[_nVez,2],.f.))
    sx1->(RecLock(alias(),.T.))
    sx1->X1_GRUPO  :=aRegs[_nVez,01]
    sx1->X1_ORDEM  :=aRegs[_nVez,02]
    sx1->X1_PERGUNT:=aRegs[_nVez,03]
    
    sx1->X1_PERSPA:=aRegs[_nVez,03]
    sx1->X1_PERENG:=aRegs[_nVez,03]
    
    sx1->X1_VARIAVL:=aRegs[_nVez,04]
    sx1->X1_TIPO   :=aRegs[_nVez,05]
    sx1->X1_TAMANHO:=aRegs[_nVez,06]
    sx1->X1_DECIMAL:=aRegs[_nVez,07]
    sx1->X1_PRESEL :=aRegs[_nVez,08]
    sx1->X1_GSC    :=aRegs[_nVez,09]
    sx1->X1_VALID  :=aRegs[_nVez,10]
    sx1->X1_VAR01  :=aRegs[_nVez,11]
    sx1->X1_DEF01  :=aRegs[_nVez,12]

    sx1->X1_DEFSPA1  :=aRegs[_nVez,12]
    sx1->X1_DEFENG1  :=aRegs[_nVez,12]
    
    sx1->X1_CNT01  :=aRegs[_nVez,13]
    sx1->X1_VAR02  :=aRegs[_nVez,14]
    sx1->X1_DEF02  :=aRegs[_nVez,15]

    sx1->X1_DEFSPA2  :=aRegs[_nVez,15]
    sx1->X1_DEFENG2  :=aRegs[_nVez,15]

    sx1->X1_CNT02  :=aRegs[_nVez,16]
    sx1->X1_VAR03  :=aRegs[_nVez,17]
    sx1->X1_DEF03  :=aRegs[_nVez,18]

    sx1->X1_DEFSPA3  :=aRegs[_nVez,18]
    sx1->X1_DEFENG3  :=aRegs[_nVez,18]

    sx1->X1_CNT03  :=aRegs[_nVez,19]
    sx1->X1_VAR04  :=aRegs[_nVez,20]
    sx1->X1_DEF04  :=aRegs[_nVez,21]

    sx1->X1_DEFSPA4  :=aRegs[_nVez,21]
    sx1->X1_DEFENG4  :=aRegs[_nVez,21]

    sx1->X1_CNT04  :=aRegs[_nVez,22]
    sx1->X1_VAR05  :=aRegs[_nVez,23]
    sx1->X1_DEF05  :=aRegs[_nVez,24]

    sx1->X1_DEFSPA5  :=aRegs[_nVez,24]
    sx1->X1_DEFENG5  :=aRegs[_nVez,24]

    sx1->X1_CNT05  :=aRegs[_nVez,25]
    sx1->X1_F3     :=aRegs[_nVez,26]
    if len(aRegs[_nVez])>26
       sx1->x1_picture:=aRegs[_nVez,27]
    endif
    sx1->(MsUnlock())
  Endif
Next
sx1->(dbgoto(_nRecSx1))
sx1->(dbsetorder(_nOrdSx1))
Return

// JJ
*--------------------------*
Static Function VALIDPERG()
*--------------------------*

local aRegs:={}

            *   1    2            3                4     5   6  7 8  9  10   11        12    13 14    15    16 17 18 19 20 21 22 23 24 25  26
*+---------------------------------------------------------------------------------------------------------------------------------+
*¦G    ¦ O  ¦ PERGUNT              ¦V       ¦T  ¦T ¦D¦P¦ G ¦V ¦V         ¦ D    ¦C ¦V ¦D       ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦F    ¦
*¦ R   ¦ R  ¦                      ¦ A      ¦ I ¦A ¦E¦R¦ S ¦A ¦ A        ¦  E   ¦N ¦A ¦ E      ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦3    ¦
*¦  U  ¦ D  ¦                      ¦  R     ¦  P¦MA¦C¦E¦ C ¦ L¦  R       ¦   F  ¦ T¦ R¦  F     ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦     ¦
*¦   P ¦ E  ¦                      ¦   I    ¦  O¦NH¦ ¦S¦   ¦ I¦   0      ¦    0 ¦ 0¦ 0¦   0    ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦     ¦
*¦    O¦ M  ¦                      ¦    AVL ¦   ¦ O¦ ¦E¦   ¦ D¦    1     ¦    1 ¦ 1¦ 2¦    2   ¦ 2¦3 ¦3 ¦ 3¦4 ¦4 ¦ 4¦5 ¦5 ¦ 5¦     ¦

aadd(aRegs,{cPerg,"01","Filial ?                      ","MV_CH1","C",99,0,0,"R","","mv_par01","","RC_FILIAL","","","","","","","","","","","","","XM0"})
aadd(aRegs,{cPerg,"02","Centro de Custo ?             ","MV_CH2","C",99,0,0,"R","","mv_par02","","RC_CC","","","","","","","","","","","","","CTT"})
aadd(aRegs,{cPerg,"03","Data Referencia ?             ","mv_ch3","D",08,0,0,"G","NaoVazio","mv_par03","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg,"04","Tipo Informacao?              ","mv_cH4","N",01,0,0,"C","","mv_par04","Hora","","","Valor","","","","","","","","","","",""})

_fAtuSx1(padr(cPerg,len(sx1->x1_grupo)),aRegs)
Return
