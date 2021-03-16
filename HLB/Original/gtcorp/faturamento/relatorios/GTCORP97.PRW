#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "SHELL.ch"
#INCLUDE "TBICONN.ch"

/*
Funcao      : GTCORP97
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função para gerar relatório de reajustes
Observações : Relatorio adaptado através do fonte GTCORP67 ( faturamento mensal por cliente )
Autor       : Leandro Brito
Revisão		:
Data/Hora   : 06/07/2015
Módulo      : Faturamento
*/

/*
Funcao      : GTCORP97()
Parametros  : Nil
Retorno     : Nil
Objetivos   : Execução da rotina principal do relatório
Autor       : Leandro Brito
Data/Hora   : 06/07/2015
*/
*----------------------------*
User Function GTCORP97()
*----------------------------*
Local aAllGroup	:= FWAllGrpCompany() //Empresas
Local nLinha	:= 01	//linha inicial para apresentação do checkbox
Local nCol		:= 01	//Coluna inicial para apresentação do checkbox

Local lMacTd	:= .F.
Local oMacTd

Private lTpRel	:= .T.
Private lIncRamo:= .F.

Private dDtIni := CtoD( '' )
Private dDtFim := CtoD( '' )
Private aMeses := {}
                                  
    DEFINE DIALOG oDlg TITLE "Relatorio de Revisões - Parâmetros" FROM 180,180 TO 590,700 PIXEL
        
@ 02,03 CHECKBOX oMacTd VAR lMacTd PROMPT "Marca todos" SIZE 50, 10	OF oDlg PIXEL;
ON CLICK(MarcTodo(aAllGroup,lMacTd))
@ 02,80 SAY UPPER("Selecione a(s) empresa(s):") SIZE 100,10 OF oDlg PIXEL

// Scroll da parte superior
oScr1 := TScrollBox():New(oDlg,11,01,92,260,.T.,.T.,.T.)

// Cria painel
@ 000,000 MSPANEL oPanel OF oScr1 SIZE 400,len(aAllGroup)*10 COLOR CLR_HRED


for i:=1 to len(aAllGroup)
	
	cVar:="lCheck"+aAllGroup[i]
	cObj:="oCheck"+aAllGroup[i]
	
	&(cVar)	:= .F.                       //nome da empresa
	&(cObj)	:= TCheckBox():New(nLinha,nCol,aAllGroup[i]+" - "+FWGrpName(aAllGroup[i]),,oPanel,100,210,,,,,,,,.T.,,,)
	
	// Seta Eventos do Check
	&(cObj):bSetGet := &("{|| "+&("cVar")+"}")
	//&(cObj):bLClicked := {|| &(&("cVar")):=!&(cVar) }
	&(cObj):bLClicked := &("{|| "+&("cVar")+":= !"+&("cVar")+"}")
	nLinha+=10
	
	//tratamento para dividir as empresas em 2 colunas
	if i == INT(len(aAllGroup)/2)
		nLinha	:=01
		nCol	:=150
	endif
	
next
         
        // Usando o método Create                //82
oScr2 := TScrollBox():Create(oDlg,109,01,92,260,.T.,.T.,.T.)

aItems	:= {'Sim','Nao'}
cCombo	:= aItems[1]
cGet1	:= space(4)
cGet2	:= space(100)

//@ 07,05 SAY "Separar filial por aba?" SIZE 100,10 OF oScr2 PIXEL

//oCombo:= TComboBox():Create(oScr2,{|u|if(PCount()>0,cCombo:=u,cCombo)},05,70,aItems,100,20,,,,,,.T.,,,,,,,,,'cCombo')

//@ 25,05 SAY "Ano: " SIZE 100,10 OF oScr2 PIXEL

//oGet1:= TGet():New(23,25,{|u| if(PCount()>0,nGet1:=u,nGet1)}, oScr2,20,05,'9999',{|o|},,,,,,.T.,,,,,,,,,,'nGet1')

//@ 07,05 SAY "Ano: " SIZE 100,10 OF oScr2 PIXEL

//oGet1:= TGet():New(05,35,{|u| if(PCount()>0,cGet1:=u,cGet1)}, oScr2,20,05,'9999',{|o|},,,,,,.T.,,,,,,,,,,'cGet1')
TSay():New( 07, 05, { || 'Data Inicial' } , oScr2 ,,,,,, .T. )                                                          
TGet():New(05,45,{|u| if(PCount()>0,dDtIni:=u,dDtIni)}, oScr2,40,05,'',{|o|},,,,,,.T.,,,,,,,,,,'dDtIni')
TSay():New( 07, 87, { || 'Data Final' } , oScr2 ,,,,,, .T. )                                                          
TGet():New(05,120,{|u| if(PCount()>0,dDtFim:=u,dDtFim)}, oScr2,40,05,'',{|o|},,,,,,.T.,,,,,,,,,,'dDtFim')


@ 27,05 SAY "Salvar em? " SIZE 100,10 OF oScr2 PIXEL
oGet2:= TGet():New(25,35,{|u| if(PCount()>0,cGet2:=u,cGet2)}, oScr2,150,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGet2')
oTButton2 := TButton():New( 25, 190, "...",oScr2,{||AbreArq(@cGet2,oGet2)},20,10,,,.F.,.T.,.F.,,.F.,,,.F. )

oGet2:Disable()


//RRP - 17/07/2013 - Alteração para incluir a opção abaixo
//oGet3 := TCheckBox():New(47,05,'Gerar relatório detalhado',{|u| if(PCount()>0,lTpRel:=u,lTpRel)},oScr2,100,07,,,,,,,,.T.,,,)

//MSM - 03/12/2014 - Alteração para incluir a opção abaixo
//oGet4 := TCheckBox():New(57,05,'Incluir ramo de atividade',{|u| if(PCount()>0,lIncRamo:=u,lIncRamo)},oScr2,100,07,,,,,,,,.T.,,,)

oTButton1 := TButton():New( 75, 110, "Gerar",oScr2,{||Precarre(aAllGroup,cGet1,oDlg,cGet2)},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

    ACTIVATE DIALOG oDlg CENTERED

Return

Static Function Precarre(aAllGroup,cAno,oDlg,cGet2)
Local oExcel
Local cOpc		:= ""
Local cEmp		:= ""
Local lRet		:= .T.


/*
if empty(cAno)
	Alert("Informe o ano para geração do relatório!")
	return
endif
*/

If Empty( dDtIni ) .Or. Empty( dDtFim )
	Alert("Data Incial e\ou Final nao informadas!")
	return
EndIf 

If ( dDtIni > dDtFim )
	Alert("Data Inicial nao pode ser maior que a Data Final!")
	return
EndIf

/*
	** 	Leandro Brito 
    **  Periodo informado nao pode ser superior a 12 meses pois o relatorio gera 12 colunas ref. meses
*/
aMeses := {}
dDtLim := dDtIni
Aadd( aMeses , { Left( DtoS( dDtLim ) , 6 ) , MesExtenso( dDtLim ) } )
For i := 1 To 11 

	dDtLim := LastDay( dDtLim ) + 1                       

    If LastDay( dDtFim ) < LastDay( dDtLim )
		Exit    
    EndIf

   	Aadd( aMeses , { Left( DtoS( dDtLim ) , 6 ) , MesExtenso( dDtLim ) } )	

Next
dDtLim := LastDay( dDtLim )

If dDtFim > dDtLim
	Alert("Periodo nao pode ser superior a 12 meses!")
	return
EndIf

if empty(cGet2)
	Alert("Informe o diretório onde os relatórios serão salvos!")
	return
endif


For i:=1 to len(aAllGroup)
	
	cVar:="lCheck"+aAllGroup[i]
	if &(cVar)
		cEmp:=aAllGroup[i]
	else
		loop
	endif
	
	oExcel	:= FWMSEXCEL():New()
	
	aFils:=FWAllFilial(,,aAllGroup[i])
	
	if len(aFils)>1
		For j:=1 to len(aFils)
			//chama a barra de processamento
			lRet:=CarrBar(cEmp,@oExcel,cAno,aFils[j])
			
			if !lRet
				exit
			endif
		Next
	else
		lRet:=CarrBar(cEmp,@oExcel,cAno)
		if !lRet
			exit
		endif
	endif
	
	//Verifico se a planilha está ativa
	if oExcel:lActivate==NIL .OR. oExcel:lActivate
		oExcel:SetBgColorHeader("#AA92C7") //Define a cor de preenchimento do estilo do Cabeçalho
		
		oExcel:SetLineBgColor("#C2C2DC")//Define a cor de preenchimento do estilo da Linha
		
		oExcel:Set2LineBgColor("#E6E6FA") //Define a cor de preenchimento do estilo da Linha 2
		
		oExcel:Activate()
		
		//Chama a função para abrir o excel
		GExecl(oExcel,cEmp,cAno,cGet2)
		
		
	endif
	
Next

if lRet
	msginfo("Processo finalizado, verifique o local indicado nos parâmetros!")
	oDlg:End()
endif

Return


/*
Funcao      : CarrPlan()
Parametros  : cEmp,oExcel,MV_PAR02
Retorno     :
Objetivos   : Função para criar a barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 02/05/2013	11:00
*/

*---------------------------------------------*
Static Function CarrBar(cEmp,oExcel,cAno,cFil)
*---------------------------------------------*
Local oDlg1
Local oMeter
Local nMeter	:= 0
Local lRet		:= .T.

//******************Régua de processamento*******************
//retira o botão X
DEFINE DIALOG oDlg1 TITLE "Processando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL

// Montagem da régua
oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlg1,150,14,,.T.)

ACTIVATE DIALOG oDlg1 CENTERED ON INIT(lRet:=CarrPlan(cEmp,oExcel,cAno,oDlg1,oMeter,cFil))

//*************************************


Return(lRet)


/*
Funcao      : CarrPlan()
Parametros  : cEmp,oExcel,MV_PAR02,oDlg1,oMeter
Retorno     :
Objetivos   : Função preencher o objeto com as informações da planilha
Autor       : Matheus Massarotto
Data/Hora   : 02/05/2013	11:00
*/
*---------------------------------------------------------*
Static Function CarrPlan(cEmp,oExcel,cAno,oDlg1,oMeter,cFil)
*---------------------------------------------------------*
Local aArea 	:= GetArea()
Local cQry1 	:= ""
Local cNomeEmp 	:= ""
Local nCurrent	:= 0
Local nAumenta	:= 0
Local lRet		:= .T.
Local aDadTemp:={}
Local aComboSitua := RetSX3Box( GetSX3Cache( "CN9_SITUAC" , "X3_CBOX" ) ,,, Len( CN9->CN9_SITUAC ) )    
Local nTotal, nTotalPerc,nPerc,nCol

DEFAULT cEmp:=""

DbSelectArea("SM0")
SM0->(DbSetOrder(1))
if DbSeek(cEmp)
	cNomeEmp:=SM0->M0_NOME
else
	Return()
endif

AADD(aDadTemp,{"COD_CLIENT","C",TamSX3("F2_CLIENTE")[1],0})
AADD(aDadTemp,{"FILIAL","C",TamSX3("F2_FILIAL")[1],0})
AADD(aDadTemp,{"CLIENTE","C",TamSX3("A1_NOME")[1],0})
if lIncRamo //Inclui ramo de atividade
	AADD(aDadTemp,{"ATIVIDADE","C",TamSX3("A1_P_DRMAT")[1],2})
endif
AADD(aDadTemp,{"JANEIRO","N",TamSX3("F2_VALBRUT")[1],2})
AADD(aDadTemp,{"FEVEREIRO","N",TamSX3("F2_VALBRUT")[1],2})
AADD(aDadTemp,{"MARCO","N",TamSX3("F2_VALBRUT")[1],2})
AADD(aDadTemp,{"ABRIL","N",TamSX3("F2_VALBRUT")[1],2})
AADD(aDadTemp,{"MAIO","N",TamSX3("F2_VALBRUT")[1],2})
AADD(aDadTemp,{"JUNHO","N",TamSX3("F2_VALBRUT")[1],2})
AADD(aDadTemp,{"JULHO","N",TamSX3("F2_VALBRUT")[1],2})
AADD(aDadTemp,{"AGOSTO","N",TamSX3("F2_VALBRUT")[1],2})
AADD(aDadTemp,{"SETEMBRO","N",TamSX3("F2_VALBRUT")[1],2})
AADD(aDadTemp,{"OUTUBRO","N",TamSX3("F2_VALBRUT")[1],2})
AADD(aDadTemp,{"NOVEMBRO","N",TamSX3("F2_VALBRUT")[1],2})
AADD(aDadTemp,{"DEZEMBRO","N",TamSX3("F2_VALBRUT")[1],2})
AADD(aDadTemp,{"TOTAL","N",TamSX3("F2_VALBRUT")[1],2})
AADD(aDadTemp,{"N_FISCAL","C",TamSX3("F2_DOC")[1],0}) //MSM - Data: 18/11/2014 - chamado: 021598
AADD(aDadTemp,{"SERIE","C",TamSX3("F2_SERIE")[1],0})
AADD(aDadTemp,{"CONTRATO","C",TamSX3("CN9_NUMERO")[1],0})
AADD(aDadTemp,{"PROPOSTA","C",TamSX3("CN9_P_NUM")[1],0})
AADD(aDadTemp,{"SOCIO","C",TamSX3("A3_NOME")[1],0})
AADD(aDadTemp,{"GERCONTA","C",TamSX3("A1_NOME")[1],0})   //MSM - Data: 18/11/2014 - chamado: 021598

/*
if select("DADTRB")>0
	DADTRB->(DbCloseArea())
endif

cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"DADTRB",.T.,.F.)

cIndex:=CriaTrab(Nil,.F.)
IndRegua("DADTRB",cIndex,"FILIAL+CLIENTE",,,"Selecionando Registro...")

DbSelectArea("DADTRB")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)
*/   

cFieldMeses := ","
For nMeses := 1 To Len( aMeses )
	cFieldMeses += "SUM(CASE WHEN Substring(D2.D2_EMISSAO,1,6) = '" + aMeses[ nMeses ][ 1 ] + "' THEN D2_TOTAL ELSE 0 END) " + aMeses[ nMeses ][ 2 ]  + "," 
Next

//Montagem da Query
//QUERY COM OS CONTRATOS E O FINANCEIRO ATRAVÉS DO PEDIDO DE VENDA
cQry1 :=" SELECT 	D2.D2_FILIAL AS 'FILIAL',    "
cQry1 +="			D2.D2_CLIENTE AS 'COD_CLIENT', D2.D2_LOJA, A1.A1_NOME AS 'CLIENTE',"
//cQry1 +="			Substring(D2.D2_EMISSAO,1,6) AS 'MS' ,"

If cEmp $ "ZB/ZF"
	cQry1 +="			(Case When Z42.Z42_NOUSER <> '' then Z42.Z42_NOUSER else 'Nao Informado' end) AS 'SOCIO',"
Else
	cQry1 +="			SA3.A3_NOME AS 'SOCIO',"
EndIf
cQry1 +="			CN9.CN9_P_NUM AS 'PROPOSTA',"
cQry1 +="			CN9.CN9_NUMERO AS 'CONTRATO', RA_NOME AS 'GECTA'"
cQry1 += cFieldMeses
/*
if lIncRamo //Inclui ramo de atividade
	cQry1 +=" ,A1_P_DRMAT AS 'ATIVIDADE'"
endif
*/

cQry1 +="CN9_INDICE,CN9_DTREV,CN9_SITUAC,D2_COD,CN9_DTINIC,CN9_TPCTO,B1.B1_DESC,B1.B1_CC "

cQry1 +=" FROM SD2"+cEmp+"0 AS D2"
cQry1 +="	LEFT JOIN SX2"+cEmp+"0 SX2 on X2_CHAVE = 'SB1' "
cQry1 +="	LEFT JOIN SB1"+cEmp+"0 B1 ON B1.B1_COD = D2.D2_COD AND B1.B1_FILIAL = CASE WHEN SX2.X2_MODO = 'E' THEN D2.D2_FILIAL ELSE '  ' END "
cQry1 +=" 	LEFT JOIN SA1"+cEmp+"0 A1 ON A1.A1_COD = D2.D2_CLIENTE AND A1.A1_LOJA = D2.D2_LOJA"
cQry1 +=" 	LEFT JOIN TOTVS_FUNCIONARIOS FUNC ON FUNC.RA_CIC = A1.A1_P_GECTA AND FUNC.RA_SITFOLH<>'D'"
cQry1 +=" 	JOIN SC5"+cEmp+"0 AS SC5 ON SC5.C5_NUM = D2.D2_PEDIDO"
cQry1 +=" 	JOIN CN9"+cEmp+"0 AS CN9 ON SC5.C5_MDCONTR = CN9.CN9_NUMERO"
cQry1 +=" 	JOIN SA3"+cEmp+"0 AS SA3 ON CN9.CN9_P_GER=SA3.A3_COD "
If cEmp $ "ZB/ZF"
	cQry1 += " 	left Outer Join(Select * From Z55"+cEmp+"0 Where Z55_REVATU = '') as Z55 on CN9.CN9_FILIAL = Z55.Z55_FILIAL AND"
	cQry1 += " 																		 		CN9.CN9_P_NUM = Z55.Z55_NUM AND"
	cQry1 += " 											 					 				CN9.CN9_CLIENT = Z55.Z55_CLIENT AND"
	cQry1 += " 																 				CN9.CN9_LOJACL = Z55.Z55_LOJA"
	cQry1 += " 	left Outer Join(Select * From Z42"+cEmp+"0) as Z42 on Z42.Z42_CPF = Z55.Z55_SOCIO"
EndIf
cQry1 +=" WHERE D2.D2_SERIE <> 'ND' AND CN9.CN9_REVATU = '' AND"
if !empty(cFil)
	cQry1 +=" SC5.C5_FILIAL = '"+cFil+"' AND CN9.CN9_FILIAL = '"+cFil+"' AND D2.D2_FILIAL = '"+cFil+"' AND"
	cNomeEmp:="Filial "+cFil+" - "+FWFilialName(cEmp,cFil,1)
endif
cQry1 +=" A1.D_E_L_E_T_<>'*' AND CN9.D_E_L_E_T_<>'*' AND SA3.D_E_L_E_T_<>'*' AND SC5.D_E_L_E_T_<>'*' AND D2.D_E_L_E_T_ <> '*' AND B1.D_E_L_E_T_ <> '*'"
cQry1 +=" AND D2.D2_EMISSAO >= '"+DtoS(dDtini)+"' AND D2.D2_EMISSAO <= '"+DtoS( dDtFim ) + "'"

cQry1 +=" GROUP BY D2_FILIAL,  D2_CLIENTE,D2_LOJA,A1_NOME,"

If cEmp $ "ZB/ZF"
	cQry1 +="			(Case When Z42.Z42_NOUSER <> '' then Z42.Z42_NOUSER else 'Nao Informado' end),"
Else
	cQry1 +="			SA3.A3_NOME,"
EndIf
cQry1 +="CN9_P_NUM,CN9_NUMERO,RA_NOME,CN9_INDICE,CN9_DTREV,CN9_SITUAC,D2_COD,CN9_DTINIC,CN9_TPCTO,B1.B1_DESC,B1.B1_CC "


cQry1 +=" UNION All"
cQry1 +=" SELECT D2.D2_FILIAL AS 'FILIAL',     D2.D2_CLIENTE AS 'COD_CLIENT',"
cQry1 +="		D2.D2_LOJA, A1.A1_NOME AS 'CLIENTE',"

If cEmp $ "ZB/ZF"
	cQry1 +="		(Case When Z42.Z42_NOUSER <> '' then Z42.Z42_NOUSER else (Case when CN9.CN9_P_GER = '' then 'Nao Informado' else '*'+CN9.CN9_P_GER End) end) AS 'SOCIO',"
Else
	cQry1 +="		(Case when CN9.CN9_P_GER = '' then 'Nao Informado' else CN9.CN9_P_GER End)AS 'SOCIO',"
EndIf
cQry1 +="		(Case when CN9.CN9_P_NUM = '' then 'Nao Informado' else CN9.CN9_P_NUM End)AS 'PROPOSTA',"
cQry1 +="		CN9.CN9_NUMERO AS 'CONTRATO',RA_NOME AS 'GECTA'"
cQry1 += cFieldMeses
/*
if lIncRamo //Inclui ramo de atividade
	cQry1 +=" ,A1_P_DRMAT AS 'ATIVIDADE'"
endif
*/

cQry1 +="CN9_INDICE,CN9_DTREV,CN9_SITUAC,D2_COD,CN9_DTINIC,CN9_TPCTO,B1.B1_DESC,B1.B1_CC "

cQry1 +=" FROM SD2"+cEmp+"0 AS D2"
cQry1 +="	LEFT JOIN SX2"+cEmp+"0 SX2 on X2_CHAVE = 'SB1' "
cQry1 +="	LEFT JOIN SB1"+cEmp+"0 B1 ON B1.B1_COD = D2.D2_COD AND B1.B1_FILIAL = CASE WHEN SX2.X2_MODO = 'E' THEN D2.D2_FILIAL ELSE '  ' END "
cQry1 +=" 	LEFT JOIN SA1"+cEmp+"0 A1 ON A1.A1_COD = D2.D2_CLIENTE AND A1.A1_LOJA = D2.D2_LOJA"
cQry1 +=" 	LEFT JOIN TOTVS_FUNCIONARIOS FUNC ON FUNC.RA_CIC = A1.A1_P_GECTA AND FUNC.RA_SITFOLH<>'D'"
cQry1 +=" 	JOIN SC5"+cEmp+"0 AS SC5 ON SC5.C5_NUM = D2.D2_PEDIDO"
cQry1 +=" 	JOIN CN9"+cEmp+"0 AS CN9 ON SC5.C5_MDCONTR = CN9.CN9_NUMERO"
If cEmp $ "ZB/ZF"
	cQry1 += " 	left Outer Join(Select * From Z55"+cEmp+"0 Where Z55_REVATU = '') as Z55 on CN9.CN9_FILIAL = Z55.Z55_FILIAL AND"
	cQry1 += " 																		 		CN9.CN9_P_NUM = Z55.Z55_NUM AND"
	cQry1 += " 											 					 				CN9.CN9_CLIENT = Z55.Z55_CLIENT AND"
	cQry1 += " 																 				CN9.CN9_LOJACL = Z55.Z55_LOJA"
	cQry1 += " 	left Outer Join(Select * From Z42"+cEmp+"0) as Z42 on Z42.Z42_CPF = Z55.Z55_SOCIO"
EndIf
cQry1 +=" WHERE D2.D2_SERIE <> 'ND' AND CN9.CN9_REVATU = '' AND CN9.CN9_P_GER = '' AND (CN9.CN9_P_GER = '' OR CN9.CN9_P_NUM = '') AND"
if !empty(cFil)
	cQry1 +=" SC5.C5_FILIAL = '"+cFil+"' AND CN9.CN9_FILIAL = '"+cFil+"' AND D2.D2_FILIAL = '"+cFil+"' AND"
	cNomeEmp:="Filial "+cFil+" - "+FWFilialName(cEmp,cFil,1)
endif
cQry1 +=" A1.D_E_L_E_T_<>'*' AND CN9.D_E_L_E_T_<>'*' AND SC5.D_E_L_E_T_<>'*' AND D2.D_E_L_E_T_ <> '*' AND B1.D_E_L_E_T_ <> '*'"
cQry1 +=" AND D2.D2_EMISSAO >= '"+DtoS(dDtini)+"' AND D2.D2_EMISSAO <= '"+DtoS( dDtFim ) + "'"

cQry1 +=" GROUP BY D2_FILIAL,  D2_CLIENTE,D2_LOJA,A1_NOME,"

If cEmp $ "ZB/ZF"
	cQry1 +="		(Case When Z42.Z42_NOUSER <> '' then Z42.Z42_NOUSER else (Case when CN9.CN9_P_GER = '' then 'Nao Informado' else '*'+CN9.CN9_P_GER End) end),"
Else
	cQry1 +="		(Case when CN9.CN9_P_GER = '' then 'Nao Informado' else CN9.CN9_P_GER End),"
EndIf
cQry1 +="(Case when CN9.CN9_P_NUM = '' then 'Nao Informado' else CN9.CN9_P_NUM End),CN9_NUMERO,RA_NOME,CN9_INDICE,CN9_DTREV,CN9_SITUAC,D2_COD,CN9_DTINIC,CN9_TPCTO,B1.B1_DESC,B1.B1_CC"


cQry1 +=" UNION All"
cQry1 +=" SELECT D2.D2_FILIAL AS 'FILIAL',    "
cQry1 +="		D2.D2_CLIENTE AS 'COD_CLIENT', D2.D2_LOJA, A1.A1_NOME AS 'CLIENTE',"
cQry1 +="		'Nao Informado' AS 'SOCIO',"
cQry1 +="		'Nao Informado' AS 'PROPOSTA', 'Nao Informado' AS 'CONTRATO',RA_NOME AS 'GECTA'"
cQry1 += cFieldMeses
/*
if lIncRamo //Inclui ramo de atividade
	cQry1 +=" ,A1_P_DRMAT AS 'ATIVIDADE'"
endif
*/

cQry1 +="'Nao Informado' CN9_INDICE,'' CN9_DTREV,'Nao Informado' CN9_SITUAC,D2_COD,'' CN9_DTINIC,'Nao Informado' CN9_TPCTO,B1.B1_DESC,B1.B1_CC "

cQry1 +=" FROM SD2"+cEmp+"0 AS D2"
cQry1 +=" LEFT JOIN SX2"+cEmp+"0 SX2 on X2_CHAVE = 'SB1' "
cQry1 +=" LEFT JOIN SB1"+cEmp+"0 B1 ON B1.B1_COD = D2.D2_COD AND B1.B1_FILIAL = CASE WHEN SX2.X2_MODO = 'E' THEN D2.D2_FILIAL ELSE '  ' END "
cQry1 +=" LEFT JOIN SA1"+cEmp+"0 A1 ON A1.A1_COD = D2.D2_CLIENTE AND A1.A1_LOJA = D2.D2_LOJA"
cQry1 +=" LEFT JOIN TOTVS_FUNCIONARIOS FUNC ON FUNC.RA_CIC = A1.A1_P_GECTA AND FUNC.RA_SITFOLH<>'D'"
cQry1 +=" JOIN SC5"+cEmp+"0 AS SC5 ON SC5.C5_NUM = D2.D2_PEDIDO AND SC5.C5_MDCONTR = ''"
cQry1 +=" WHERE D2.D2_SERIE <> 'ND' AND"
if !empty(cFil)
	cQry1 +=" SC5.C5_FILIAL = '"+cFil+"' AND D2.D2_FILIAL = '"+cFil+"' AND"
	cNomeEmp:="Filial "+cFil+" - "+FWFilialName(cEmp,cFil,1)
endif
cQry1 +=" A1.D_E_L_E_T_<>'*' AND SC5.D_E_L_E_T_<>'*' AND D2.D_E_L_E_T_ <> '*' AND B1.D_E_L_E_T_ <> '*'"
cQry1 +=" AND D2.D2_EMISSAO >= '"+DtoS(dDtini)+"' AND D2.D2_EMISSAO <= '"+DtoS( dDtFim ) + "'"

//cQry1 += " GROUP BY D2_FILIAL,  D2_CLIENTE,D2_LOJA,A1_NOME,Substring(D2.D2_EMISSAO,1,6),SOCIO,
cQry1 +=" GROUP BY D2_FILIAL,  D2_CLIENTE,D2_LOJA,A1_NOME,RA_NOME,D2_COD,B1.B1_DESC,B1.B1_CC "

cQry1 +=" ORDER BY COD_CLIENT"


//executado através do menu
If tcsqlexec(cQry1)<0
	cError:=TCSQLError()
	
	Alert("Ocorreu um problema na busca das informações!!"+CRLF+;
	"Empresa: "+cNomeEmp+;
	CRLF+CRLF+ SUBSTR(cError,1,AT("THREAD ID",UPPER(cError))-1 ) )
	
	//Encerra a barra e o dialog da barra
	//oMeter:end()
	oDlg1:end()
	oExcel:DeActivate()
	lRet :=.F.
	return(lRet)
EndIf

if select("TRBTEMP")>0
	TRBTEMP->(DbCloseArea())
endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),"TRBTEMP",.T.,.T.)

oExcel:AddworkSheet(cNomeEmp)
oExcel:AddTable (cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) )
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,"Cod. Cliente",1,1)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,"Filial",1,1)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,"Cliente",1,1)

if lIncRamo //Inclui ramo de atividade
	oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,"Atividade",1,1)
endif


oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,"Contrato",1,1)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,"Proposta",1,1)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,"Sócio",1,1)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,"Gerente Conta",1,1)

oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,"Indice Reajuste",1,3)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,"Data Revisao",1,1)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,"Situacao",1,1)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,"Produto",1,1) 
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,"Descrição",1,1) 
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,"C.Custo",1,1) 
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,"Data Inicio",1,1) 
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,"Tipo Contrato",1,1)

/*
	**	Leandro Brito - Inclui colunas dinamicamente de acordo com o range de datas informados
*/ 

For nCol := 1 To Len( aMeses )
	If nCol > 1 
		oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,'Var_Perc_' + StrZero( nCol - 1 , 2 , 0 ) ,1,2)	
	EndIf
	oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,aMeses[ nCol ][ 2 ] + "_" + Left( aMeses[ nCol ][ 1 ] , 4 ) ,1,3)
Next

oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,"Total Geral",1,3)
oExcel:AddColumn(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,"Total Variacao %",1,3)


Count to nRecCount

//de quanto em quanto a regua deve aumentar
nAumenta:= 100/(nRecCount/100)

if nRecCount>0
	TRBTEMP->(DbGoTop())
	
	While TRBTEMP->(!EOF())
		
		//Processamento da régua
		nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da régua
		nCurrent+=nAumenta // atualiza régua
		oMeter:Set(nCurrent) //seta o valor na régua
		
		aRowTab:={}
		
		AADD(aRowTab,TRBTEMP->COD_CLIENT)
		AADD(aRowTab,TRBTEMP->FILIAL)
		AADD(aRowTab,TRBTEMP->CLIENTE)
		
		if lIncRamo //Inclui ramo de atividade
			AADD(aRowTab,TRBTEMP->ATIVIDADE)
		endif

		AADD(aRowTab,TRBTEMP->CONTRATO)
		AADD(aRowTab,TRBTEMP->PROPOSTA)
		AADD(aRowTab,TRBTEMP->SOCIO)
		AADD(aRowTab,TRBTEMP->GECTA)
		
		Aadd( aRowTab , If( !Empty( TRBTEMP->CN9_INDICE ) , Posicione( 'CN6' , 1 , xFilial( 'CN6' ) + TRBTEMP->CN9_INDICE , 'CN6_DESCRI' ) , '' ) )
		Aadd( aRowTab , DtoC( StoD( TRBTEMP->CN9_DTREV ) ) )
		If !Empty( TRBTEMP->CN9_SITUAC ) .And. ( nPosSitua := Ascan( aComboSitua , { | x | AllTrim( x[ 2 ] ) == AllTrim( TRBTEMP->CN9_SITUAC ) } ) ) > 0
			Aadd( aRowTab , aComboSitua[ nPosSitua ][ 3 ] )
		Else
		    Aadd( aRowTab , '' )
		EndIf
		Aadd( aRowTab , TRBTEMP->D2_COD ) 
		Aadd( aRowTab , TRBTEMP->B1_DESC ) 
		Aadd( aRowTab , TRBTEMP->B1_CC ) 
		Aadd( aRowTab , DtoC( StoD( TRBTEMP->CN9_DTINIC ) ) )
		Aadd( aRowTab , If( !Empty( TRBTEMP->CN9_TPCTO ) , Posicione( 'CN1' , 1 , xFilial( 'CN1' ) + TRBTEMP->CN9_TPCTO , 'CN1_DESCRI' ) , '' ) )

		nTotal := 0
		nTotalPerc := 0
		For nCol := 1 To Len( aMeses )
			nValAtu := TRBTEMP->&( aMeses[ nCol ][ 2 ] )

			If nCol > 1 
				nValAnt := TRBTEMP->&( aMeses[ nCol - 1 ][ 2 ] )
				If ( nValAtu > 0 ) .And. ( nValAnt > 0 )
					nPerc := Round( ( ( nValAtu /nValAnt ) - 1 ) * 100 , 4 ) 
					nTotalPerc += nPerc
					Aadd( aRowTab , nPerc )	
				Else
					Aadd( aRowTab ,	0 )
				EndIf	
			EndIf       
			
			Aadd( aRowTab , nValAtu ) 
			nTotal += nValAtu
		Next
		AADD(aRowTab,nTotal)
		AADD(aRowTab,nTotalPerc)	
					
		oExcel:AddRow(cNomeEmp,"Faturamento "+Capital(Alltrim(FWGrpName(cEmp))) ,aRowTab)
		
		TRBTEMP->(DbSkip())
	Enddo
endif

//Encerra o dialog da barra
oDlg1:end()

RestArea(aArea)
Return(lRet)

/*
Funcao      : GExecl()
Parametros  : cConteu
Retorno     :
Objetivos   : Função para abrir o excel
Autor       : Matheus Massarotto
Data/Hora   : 02/05/2013	11:10
*/
*------------------------------*
Static Function GExecl(oExcel,cEmp,cAno,cGet2)
*------------------------------*
Private cDest :=  GetTempPath()
/***********************GERANDO EXCEL************************************/

//cArq := "Faturamento_"+alltrim(CriaTrab(NIL,.F.))+".xls"

cArq := "Faturamento-"+alltrim(FWGrpName(cEmp))+".xls"


IF FILE (cGet2+cArq)
	FERASE (cGet2+cArq)
ENDIF

//oExcel:GetXMLFile(cDest+cArq) // Gera o arquivo em Excel
oExcel:GetXMLFile(cGet2+cArq) // Gera o arquivo em Excel

//SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Abre o arquivo em Excel

/***********************GERANDO EXCEL************************************/
//sleep(2000)
//FERASE (cDest+cArq)

Return

/*
Funcao      : MarcTodo()
Parametros  : aAllGroup,lMacTd
Retorno     :
Objetivos   : Função para marcar todas as empresas
Autor       : Matheus Massarotto
Data/Hora   : 02/05/2013	11:10
*/
*----------------------------------------*
Static Function MarcTodo(aAllGroup,lMacTd)
*----------------------------------------*

for j:=1 to len(aAllGroup)
	&("lCheck"+aAllGroup[j]):=lMacTd
	&("oCheck"+aAllGroup[j]):Refresh()
next

Return


/*
Funcao      : MarcTodo()
Parametros  : aAllGroup,lMacTd
Retorno     :
Objetivos   : Função para abrir tela com o selecionador do local onde será salvo
Autor       : Matheus Massarotto
Data/Hora   : 02/05/2013	11:10
*/
*----------------------------------*
Static Function AbreArq(cGet2,oGet2)
*----------------------------------*
Local cTitle:= "Salvar arquivo"
Local cFile := ""
Local cPastaTo    := ""
Local nDefaultMask := 0
Local cDefaultDir  := "C:\"
Local nOptions:= GETF_LOCALHARD+GETF_RETDIRECTORY

//Exibe tela para gravar o arquivo.
cGet2 := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

oGet2:Refresh()

Return
