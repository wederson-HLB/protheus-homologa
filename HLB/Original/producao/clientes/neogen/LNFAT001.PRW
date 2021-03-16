#include "totvs.ch" 
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#Include "rwmake.ch"
#Include "tbiconn.ch"

/*
Funcao      : LNFAT001()
Parametros  : Nenhum
Retorno     : 
Objetivos   : Gera txt das tabelas de contato, clientes, faturas e envia para FTP
Autor       : Anderson Arrais                                
Cliente 	: Neogen	
Data	    : 26/05/2017
*/
*-----------------------------*
User Function LNFAT001(aEmp)
*-----------------------------* 
Local 	nArqTrab 	:= 0

Private cPath 		:= ""
Private cDirServ	:= ""
Private lJob   		:= (Select("SX3") <= 0)
Private cNomeData	:= ""

//Verifica se a área está em uso ou precisa preparar o ambiente(job)
//If !Used()
If lJob 
	//conout(aEmp[1]+" "+aEmp[2])
	
	RpcClearEnv()
	RpcSetType( 3 )
	//PREPARE ENVIRONMENT EMPRESA aEmp[1] FILIAL aEmp[2] TABLES "SA1", "SU5", "SF2", "SD2" MODULO "FAT"
	PREPARE ENVIRONMENT EMPRESA "LN" FILIAL "01" TABLES "SA1", "SU5", "SF2", "SD2" MODULO "FAT"
	conout("Fonte LNFAT001: preparou LNFAT001")
Else
	If ( !cEmpAnt $ 'LN' )
		MsgStop( 'Empresa nao autorizada para utilizar essa rotina!',"HLB BRASIL" )
		Return
	EndIf
EndIf

cNomeData	:= GravaData(Date(),.F.,5)+SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)
//Cria a tabela temporária.
nArqTrab :=  GeraTMP()

//Grava os Dados na tabela temporária caso esteja criada com sucesso
If nArqTrab > 0
	lGrvDados := TmpRel()
EndIf         

//gera arquivo txt com os dados da tabela temporaria   
If lGrvDados
	ImpRel()
    
	//Sobe arquivos para FTP
	UP2FTP()
EndIf

//Encerra o PREPARE ENVIRONMENT
RpcClearEnv()

Return .T.

/*
Função  : GeraTMP
Retorno : nArqTrab 
Objetivo: Cria a tabela temporária que será utilizada para gerar txt.
Autor   : Anderson Arrais
Data    : 30/06/2017
*/
*--------------------------*
 Static Function GeraTMP()
*--------------------------*
Local nArqTrab := 0
Local cIndU5   := ""
Local cIndA1   := ""
Local cIndF2   := ""
Local cArqF2   := ""
Local cArqU5   := ""
Local cArqA1   := ""

Local aStrU5 := {} //temporaria da SU5
Local aStrA1 := {} //temporaria da SA1
Local aStrF2 := {} //temporaria da SA1

//Cria a tabela temporária SU5
aAdd(aStrU5,{"Accoun	","C",006,0})
aAdd(aStrU5,{"Saluta 	","C",055,0})
aAdd(aStrU5,{"Operac	","C",001,0})
aAdd(aStrU5,{"FirNan	","C",030,0})
aAdd(aStrU5,{"LasNan	","C",030,0})
aAdd(aStrU5,{"Email 	","C",040,0})
aAdd(aStrU5,{"Funcao	","C",055,0})
aAdd(aStrU5,{"Ende		","C",030,0})
aAdd(aStrU5,{"Cidade	","C",020,0})
aAdd(aStrU5,{"Cep		","C",008,0})
aAdd(aStrU5,{"Estado	","C",002,0})
aAdd(aStrU5,{"Pais		","C",025,0})
aAdd(aStrU5,{"Empfon	","C",015,0})
aAdd(aStrU5,{"Celfon	","C",015,0})
aAdd(aStrU5,{"Casfon	","C",015,0})
aAdd(aStrU5,{"faxfon	","C",015,0})

//Cria tabela temporaria SA1
aAdd(aStrA1,{"CompID	","C",008,0})
aAdd(aStrA1,{"ComNam 	","C",040,0})
aAdd(aStrA1,{"NREDUZ 	","C",020,0})
aAdd(aStrA1,{"GRPVEN 	","C",030,0})
aAdd(aStrA1,{"Operac	","C",001,0})
aAdd(aStrA1,{"CreDat	","C",008,0})
aAdd(aStrA1,{"AltDat 	","C",008,0})
aAdd(aStrA1,{"UseCod	","C",006,0})
aAdd(aStrA1,{"Vend		","C",040,0})
aAdd(aStrA1,{"Risco		","C",001,0})
aAdd(aStrA1,{"Statu		","C",001,0})
aAdd(aStrA1,{"Ende		","C",040,0})
aAdd(aStrA1,{"Comple	","C",050,0})
aAdd(aStrA1,{"Mun		","C",060,0})
aAdd(aStrA1,{"Pais		","C",025,0})
aAdd(aStrA1,{"faxfon	","C",015,0})
aAdd(aStrA1,{"Telfon	","C",018,0})
aAdd(aStrA1,{"Est		","C",002,0})
aAdd(aStrA1,{"Cep		","C",008,0})
aAdd(aStrA1,{"EndEnt	","C",040,0})
aAdd(aStrA1,{"MunE		","C",015,0})
aAdd(aStrA1,{"EstEnt	","C",002,0})
aAdd(aStrA1,{"Cepent	","C",008,0})
aAdd(aStrA1,{"LimCre	","N",014,2})
aAdd(aStrA1,{"Moed		","N",002,0})
aAdd(aStrA1,{"Valant	","N",014,2})
aAdd(aStrA1,{"Valatu	","N",014,2})
                         
//Cria tabela temporaria SF2
aAdd(aStrF2,{"CHAVE		","C",040,0})
aAdd(aStrF2,{"Operac	","C",001,0})
aAdd(aStrF2,{"CreDat	","C",008,0})
aAdd(aStrF2,{"ModDat	","C",008,0})
aAdd(aStrF2,{"AltUsr	","C",006,0})
aAdd(aStrF2,{"CodCli	","C",008,0})
aAdd(aStrF2,{"Emissao	","C",008,0})
aAdd(aStrF2,{"NumPed	","C",006,0})
aAdd(aStrF2,{"ValBrut	","N",014,2})
aAdd(aStrF2,{"Duplic	","C",009,0})
aAdd(aStrF2,{"DuplOri	","C",009,0})
aAdd(aStrF2,{"OpenDoc	","C",001,0})
aAdd(aStrF2,{"Period	","C",006,0})
aAdd(aStrF2,{"SubTotal	","N",014,2})
aAdd(aStrF2,{"TotMISC	","N",014,2})
aAdd(aStrF2,{"TotTax	","N",014,2})
aAdd(aStrF2,{"TotDisc	","N",014,2})
aAdd(aStrF2,{"BuyerID	","C",008,0})//Branco
aAdd(aStrF2,{"PedCli	","C",009,0})
aAdd(aStrF2,{"Moeda		","C",010,0})
aAdd(aStrF2,{"Emissao2	","C",008,0})
aAdd(aStrF2,{"IDEnv		","C",001,0})//Branco
aAdd(aStrF2,{"EnvEnd	","C",040,0})
aAdd(aStrF2,{"EnvEnd2	","C",040,0})
aAdd(aStrF2,{"EnvATTN	","C",008,0})//Branco
aAdd(aStrF2,{"EnvName	","C",008,0})//Branco
aAdd(aStrF2,{"EnvMunic	","C",015,0})
aAdd(aStrF2,{"EnvEst	","C",002,0})
aAdd(aStrF2,{"EnvTel	","C",008,0})//Branco
aAdd(aStrF2,{"EnvCep	","C",008,0})
aAdd(aStrF2,{"EnvPais	","C",003,0})
aAdd(aStrF2,{"VendEnd	","C",040,0})
aAdd(aStrF2,{"VendEnd2	","C",040,0})
aAdd(aStrF2,{"VendATTN	","C",008,0})//Branco
aAdd(aStrF2,{"VendName	","C",008,0})//Branco
aAdd(aStrF2,{"VendMunic	","C",015,0})
aAdd(aStrF2,{"VendEst	","C",002,0})
aAdd(aStrF2,{"VendTel	","C",008,0})//Branco
aAdd(aStrF2,{"VendCep	","C",008,0})
aAdd(aStrF2,{"VendPais	","C",003,0})
aAdd(aStrF2,{"IdVend	","C",008,0})//Branco
aAdd(aStrF2,{"Frete		","N",014,2})
aAdd(aStrF2,{"Picker	","C",008,0})//Branco
aAdd(aStrF2,{"Packer	","C",008,0})//Branco
aAdd(aStrF2,{"Mennota	","C",150,0})
aAdd(aStrF2,{"CondPag	","C",003,0})
aAdd(aStrF2,{"TpFrete	","C",001,0})
aAdd(aStrF2,{"Transp	","C",006,0})
aAdd(aStrF2,{"DescItem	","C",120,0})
aAdd(aStrF2,{"Quant		","N",013,4})
aAdd(aStrF2,{"LTotal	","N",014,2})
aAdd(aStrF2,{"Preco		","N",015,5})
aAdd(aStrF2,{"CodItem	","C",015,0})
aAdd(aStrF2,{"QtdVen	","N",013,4})
aAdd(aStrF2,{"QuantVen	","N",013,4})
aAdd(aStrF2,{"LCodCli	","C",008,0})
aAdd(aStrF2,{"Unidade	","C",002,0})
aAdd(aStrF2,{"NumItem	","C",002,0})

cArqU5 := CriaTrab(aStrU5, .T.)
cArqA1 := CriaTrab(aStrA1, .T.)
cArqF2 := CriaTrab(aStrF2, .T.)

If !EMPTY(cArqU5) .OR. !EMPTY(cArqA1)
	nArqTrab += 1	     
EndIf

//Temporario da tabela SU5
If Select("XU5") > 0 
	XU5->(DbCloseArea())
EndIf
dbUseArea(.T.,__LOCALDRIVER,cArqU5,"XU5",.T.,.F.)

//Cria o índice do arquivo.
cIndU5:=CriaTrab(Nil,.F.)
IndRegua("XU5",cIndU5,"XU5->ACCOUN",,,,.F.)

DbSelectArea("XU5")
XU5->(DbSetIndex(cIndU5+OrdBagExt()))
XU5->(DbSetOrder(1))

//Temporario da tabela SA1
If Select("XA1") > 0 
	XA1->(DbCloseArea())
EndIf
dbUseArea(.T.,__LOCALDRIVER,cArqA1,"XA1",.T.,.F.)

cIndA1:=CriaTrab(Nil,.F.)
IndRegua("XA1",cIndA1,"XA1->COMPID",,,,.F.)

DbSelectArea("XA1")
XA1->(DbSetIndex(cIndA1+OrdBagExt()))
XA1->(DbSetOrder(1))

//Temporario da tabela SF2
If Select("XF2") > 0 
	XF2->(DbCloseArea())
EndIf
dbUseArea(.T.,__LOCALDRIVER,cArqF2,"XF2",.T.,.F.)

cIndF2:=CriaTrab(Nil,.F.)
IndRegua("XF2",cIndF2,"XF2->CHAVE",,,,.F.)

DbSelectArea("XF2")
XF2->(DbSetIndex(cIndF2+OrdBagExt()))
XF2->(DbSetOrder(1))

Return nArqTrab

/*
Função  : TmpRel
Retorno : lRet
Objetivo: Faz o select na base e grava na tabela temporaria criada
Autor   : Anderson Arrais
Data    : 30/06/2017
*/
*--------------------------*
 Static Function TmpRel()
*--------------------------*
Local cQry		:= ""
Local cCliFor	:= ""
Local cFinClFo	:= ""
Local cCodVend	:= ""
Local lRet		:= .F. 
Local nAno      := 0

//TABELA SU5
//Apaga o arquivo de trabalho, se existir.
If Select("SQL") > 0
	SQL->(DbCloseArea())
EndIf

cQry := "SELECT CONVERT(VARCHAR(10),CAST(DATEADD(DAY,CONVERT(INT, Convert(nvarchar(50),(ASCII(SUBSTRING(U5_USERLGI,12,1)) - 50))+ " + CRLF 
cQry += "Convert(nvarchar(50),(ASCII(SUBSTRING(U5_USERLGI,16,1)) - 50))), '1996-01-01') AS DATETIME),112 ) AS INCLUSAO, " + CRLF 
cQry += "CONVERT(VARCHAR(10), CAST(DATEADD(DAY,CONVERT(INT, Convert(nvarchar(50),(ASCII(SUBSTRING(U5_USERLGA,12,1)) - 50))+ " + CRLF 
cQry += "Convert(nvarchar(50),(ASCII(SUBSTRING(U5_USERLGA,16,1)) - 50))), '1996-01-01') AS DATETIME),112 ) AS ALTERACAO, " + CRLF 
cQry += "U5_P_DTENV,U5_CODCONT, " + CRLF 
cQry += "U5_TRATA = CASE U5_TRATA WHEN U5_TRATA THEN (SELECT X5_DESCRI FROM "+ RetSqlName("SX5")+ " WHERE X5_TABELA='AX' AND X5_CHAVE=U5_TRATA) END, " + CRLF 
cQry += "U5_CONTAT,U5_CONTAT,U5_EMAIL, " + CRLF 
cQry += "U5_FUNCAO = CASE U5_FUNCAO WHEN U5_FUNCAO THEN (SELECT UM_DESC FROM "+ RetSqlName("SUM")+ " WHERE UM_CARGO=U5_FUNCAO) END , " + CRLF 
cQry += "U5_END,U5_MUN,U5_CEP,U5_EST,U5_PAIS = CASE U5_PAIS WHEN U5_PAIS THEN (SELECT YA_DESCR FROM SYAYY0 WHERE YA_CODGI=U5_PAIS) END, " + CRLF 
cQry += "U5_FCOM1,U5_CELULAR,U5_FONE,U5_FAX " + CRLF 
cQry += "FROM " + RetSqlName("SU5")+" SU5 " + CRLF
cQry += "where D_E_L_E_T_=''  " + CRLF 
cQry += "AND (SU5.U5_P_DTENV='' OR (SU5.U5_P_DTENV<>'' AND CONVERT(VARCHAR(10), CAST(DATEADD(DAY,CONVERT(INT, Convert(nvarchar(50),(ASCII(SUBSTRING(SU5.U5_USERLGA,12,1)) - 50))+ " + CRLF 
cQry += "Convert(nvarchar(50),(ASCII(SUBSTRING(SU5.U5_USERLGA,16,1)) - 50))), '1996-01-01') AS DATETIME),112) > SU5.U5_P_DTENV)) " + CRLF  

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "SQL", .F., .T.)

dbSelectArea("SQL")
ProcRegua(RecCount())
SQL->(dbGoTop())

//Caso o select retorno resAultado
If SQL->(!Eof())
	//Retorno com registro
	lRet  := .T.
	Do While SQL->(!Eof())
			//Grava o arquivo temporário XU5
			XU5->(RecLock("XU5",.T.))
					
			XU5->ACCOUN	:= Alltrim(SQL->U5_CODCONT)
			XU5->SALUTA := Alltrim(SQL->U5_TRATA)
			XU5->OPERAC := Iif(SQL->U5_P_DTENV='',"C","U")
			XU5->FIRNAN	:= Alltrim(SUBSTR(SQL->U5_CONTAT, 1, AT(" ", SQL->U5_CONTAT) - 1))
			XU5->LASNAN	:= Alltrim(SUBSTR(SQL->U5_CONTAT, AT(" ", SQL->U5_CONTAT) + 1))
			XU5->EMAIL 	:= Alltrim(SQL->U5_EMAIL)
			XU5->FUNCAO	:= Alltrim(SQL->U5_FUNCAO)
			XU5->ENDE	:= Alltrim(SQL->U5_END)
			XU5->CIDADE	:= Alltrim(SQL->U5_MUN)
			XU5->CEP	:= Alltrim(SQL->U5_CEP)
			XU5->ESTADO	:= Alltrim(SQL->U5_EST)
			XU5->PAIS   := Alltrim(SQL->U5_PAIS)
			XU5->EMPFON	:= Alltrim(SQL->U5_FCOM1)
			XU5->CELFON	:= Alltrim(SQL->U5_CELULAR)
			XU5->CASFON	:= Alltrim(SQL->U5_FONE)
			XU5->FAXFON := Alltrim(SQL->U5_FAX)
				
			XU5->(MSUnlock())
				
		SQL->(dbSkip())
	
	EndDo
EndIf

//Não é fechado a XU5, ela será usada ainda
SQL->(dbCloseArea())

//TABELA SA1
If Select("SQL") > 0
	SQL->(DbCloseArea())
EndIf

cQry := ""
cQry := "SELECT SUBSTRING(A1_USERLGA, 11,1)+SUBSTRING(A1_USERLGA, 15,1)+SUBSTRING(A1_USERLGA, 2, 1)+SUBSTRING(A1_USERLGA, 6, 1)+ " + CRLF
cQry += "SUBSTRING(A1_USERLGA, 10,1)+SUBSTRING(A1_USERLGA, 14,1)+SUBSTRING(A1_USERLGA, 1, 1)+SUBSTRING(A1_USERLGA, 5, 1)+ " + CRLF
cQry += "SUBSTRING(A1_USERLGA, 9, 1)+SUBSTRING(A1_USERLGA, 13,1)+SUBSTRING(A1_USERLGA, 17,1)+SUBSTRING(A1_USERLGA, 4, 1)+SUBSTRING(A1_USERLGA, 8, 1) USUARIO, " + CRLF
cQry += "CAST(CASE WHEN A1_USERLGI<>'' THEN " + CRLF
cQry += "CONVERT(VARCHAR(10),CAST(DATEADD(DAY,CONVERT(INT, Convert(nvarchar(50),(ASCII(SUBSTRING(A1_USERLGI,12,1)) - 50))+ " + CRLF
cQry += "Convert(nvarchar(50),(ASCII(SUBSTRING(A1_USERLGI,16,1)) - 50))), '1996-01-01') AS DATETIME),112 ) " + CRLF 
cQry += "ELSE '19960101'	END AS CHAR) AS INCLUSAO, " + CRLF
cQry += "CAST(CASE WHEN A1_USERLGA<>'' THEN " + CRLF
cQry += "CONVERT(VARCHAR(10), CAST(DATEADD(DAY,CONVERT(INT, Convert(nvarchar(50),(ASCII(SUBSTRING(A1_USERLGA,12,1)) - 50))+ " + CRLF
cQry += "Convert(nvarchar(50),(ASCII(SUBSTRING(A1_USERLGA,16,1)) - 50))), '1996-01-01') AS DATETIME),112 ) " + CRLF 
cQry += "ELSE '19960101'	END AS CHAR)AS ALTERACAO, " + CRLF
//AOA - 27/03/2018 - Alteração para carregar valor acumulado por cliente e periodo
If MONTH(dDataBase) >= 6
	nAno := YEAR(dDataBase) + 1
Else
	nAno := YEAR(dDataBase)
EndIf
//VALANT
cQry += "(SELECT SUM( ((D2_TOTAL+D2_VALFRE+D2_SEGURO+D2_DESPESA+D2_VALACRS+D2_ICMSRET+D2_VALIPI)-(D2_VALIMP6+D2_VALIMP5+D2_VALICM+D2_ICMSCOM+D2_DIFAL+D2_VFCPDIF+D2_VALIPI+D2_ICMSRET)) ) " + CRLF
cQry += "	  -ISNULL(SUM( ((D1_TOTAL-D1_VALDESC)+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_VALACRS+D1_ICMSRET+D1_VALIPI)-(D1_VALIMP5+D1_VALIMP6+D1_VALICM+D1_ICMSCOM+D1_DIFAL+D1_VFCPDIF+D1_VALIPI+D1_ICMSRET) ),0) " + CRLF 
cQry += "FROM "+ RetSqlName("SD2")+ " AS D2  " + CRLF
cQry += "LEFT JOIN "+ RetSqlName("SD1")+ " AS D1 ON D1.D_E_L_E_T_='' AND D1.D1_NFORI+D1.D1_SERIORI+D1.D1_ITEMORI = D2.D2_DOC+D2.D2_SERIE+D2.D2_ITEM AND D1.D1_FORNECE+D1.D1_LOJA=A1_COD+A1_LOJA " + CRLF
cQry += "WHERE D2.D_E_L_E_T_='' AND D2.D2_EMISSAO BETWEEN '"+cvaltochar(nAno-2)+"0601' AND '"+cvaltochar(nAno-1)+"0531' AND D2.D2_CLIENTE=A1_COD AND D2.D2_LOJA=A1_LOJA AND D2.D2_GRUPO='001' " + CRLF
cQry += "AND D2_TIPO NOT IN ('D','B','C','I','P') AND D2.D2_TES IN (SELECT F4_CODIGO FROM "+ RetSqlName("SF4")+ " WHERE F4_DUPLIC='S' AND D_E_L_E_T_='' )) AS VALANT, " + CRLF
//VALATU
cQry += "(SELECT SUM( ((D2_TOTAL+D2_VALFRE+D2_SEGURO+D2_DESPESA+D2_VALACRS+D2_ICMSRET+D2_VALIPI)-(D2_VALIMP6+D2_VALIMP5+D2_VALICM+D2_ICMSCOM+D2_DIFAL+D2_VFCPDIF+D2_VALIPI+D2_ICMSRET)) ) " + CRLF
cQry += "	  -ISNULL(SUM( ((D1_TOTAL-D1_VALDESC)+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_VALACRS+D1_ICMSRET+D1_VALIPI)-(D1_VALIMP5+D1_VALIMP6+D1_VALICM+D1_ICMSCOM+D1_DIFAL+D1_VFCPDIF+D1_VALIPI+D1_ICMSRET) ),0) " + CRLF 
cQry += "FROM "+ RetSqlName("SD2")+ " AS D2  " + CRLF
cQry += "LEFT JOIN "+ RetSqlName("SD1")+ " AS D1 ON D1.D_E_L_E_T_='' AND D1.D1_NFORI+D1.D1_SERIORI+D1.D1_ITEMORI = D2.D2_DOC+D2.D2_SERIE+D2.D2_ITEM AND D1.D1_FORNECE+D1.D1_LOJA=A1_COD+A1_LOJA " + CRLF
cQry += "WHERE D2.D_E_L_E_T_='' AND D2.D2_EMISSAO BETWEEN '"+cvaltochar(nAno-1)+"0601' AND '"+cvaltochar(nAno)+"0531' AND D2.D2_CLIENTE=A1_COD AND D2.D2_LOJA=A1_LOJA AND D2.D2_GRUPO='001' " + CRLF
cQry += "AND D2_TIPO NOT IN ('D','B','C','I','P') AND D2.D2_TES IN (SELECT F4_CODIGO FROM "+ RetSqlName("SF4")+ " WHERE F4_DUPLIC='S' AND D_E_L_E_T_='' )) AS VALATU, " + CRLF

cQry += "A1_P_DTENV,A1_COD,A1_LOJA,A1_NOME,A1_USERLGI,A1_USERLGA,A1_USERLGA,A1_VEND,A1_NREDUZ,A1_GRPVEN, " + CRLF
//cQry += "A1_VEND = CASE A1_VEND WHEN A1_VEND THEN (SELECT A3_NOME FROM "+ RetSqlName("SA3")+ " WHERE A3_COD=A1_VEND) END, " + CRLF
cQry += "GRPVEN = CASE A1_GRPVEN WHEN A1_GRPVEN THEN (SELECT ACY_DESCRI FROM "+ RetSqlName("ACY")+ " WHERE ACY_GRPVEN=A1_GRPVEN) END, " + CRLF
cQry += "A1_RISCO,A1_MSBLQL,A1_END,A1_COMPLEM,A1_MUN, " + CRLF
cQry += "A1_PAIS = CASE A1_PAIS WHEN A1_PAIS THEN (SELECT YA_DESCR FROM SYAYY0 WHERE YA_CODGI=A1_PAIS) END, " + CRLF
cQry += "A1_FAX,A1_TEL,A1_DDD,A1_EST,A1_CEP,A1_ENDENT,A1_MUNE,A1_ESTE,A1_CEPE,A1_LC,A1_MOEDALC " + CRLF
cQry += "FROM " + RetSqlName("SA1")+" SA1 " + CRLF
cQry += "WHERE D_E_L_E_T_='' " + CRLF
cQry += "AND (SA1.A1_P_DTENV='' OR (SA1.A1_P_DTENV<>'' AND CONVERT(VARCHAR(10), CAST(DATEADD(DAY,CONVERT(INT, Convert(nvarchar(50),(ASCII(SUBSTRING(SA1.A1_USERLGA,12,1)) - 50))+ " + CRLF
cQry += "Convert(nvarchar(50),(ASCII(SUBSTRING(SA1.A1_USERLGA,16,1)) - 50))), '1996-01-01') AS DATETIME),112) > SA1.A1_P_DTENV)) " + CRLF 

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "SQL", .F., .T.)

dbSelectArea("SQL")
ProcRegua(RecCount())
SQL->(dbGoTop())

//Caso o select retorno resultado
If SQL->(!Eof())
	//Retorno com registro
	lRet  := .T.
	Do While SQL->(!Eof())
			//Grava o arquivo temporário XA1
			XA1->(RecLock("XA1",.T.))
					
				XA1->COMPID := SQL->A1_COD+SQL->A1_LOJA
				XA1->COMNAM := Alltrim(SQL->A1_NOME)
				XA1->NREDUZ := Alltrim(SQL->A1_NREDUZ)
				XA1->GRPVEN := Alltrim(SQL->GRPVEN )				
				XA1->OPERAC := Iif(SQL->A1_P_DTENV='',"C","U")
				XA1->CREDAT := Alltrim(SQL->INCLUSAO)
				XA1->ALTDAT := Alltrim(SQL->ALTERACAO)
				XA1->USECOD := Alltrim(SQL->USUARIO)
				XA1->VEND	:= Alltrim(SQL->A1_VEND)
				XA1->RISCO  := Alltrim(SQL->A1_RISCO)
				XA1->STATU  := IIF(Empty(Alltrim(SQL->A1_MSBLQL)),"2",Alltrim(SQL->A1_MSBLQL))
				XA1->ENDE	:= Alltrim(SQL->A1_END)	
				XA1->COMPLE := Alltrim(SQL->A1_COMPLEM)
				XA1->MUN	:= Alltrim(SQL->A1_MUN)	
				XA1->PAIS	:= Alltrim(SQL->A1_PAIS)
				XA1->FAXFON := Alltrim(SQL->A1_FAX)
				XA1->TELFON := Alltrim(SQL->A1_DDD)+Alltrim(SQL->A1_TEL)
				XA1->EST	:= Alltrim(SQL->A1_EST)	
				XA1->CEP	:= Alltrim(SQL->A1_CEP)	
				XA1->ENDENT := Alltrim(SQL->A1_ENDENT)
				XA1->MUNE	:= Alltrim(SQL->A1_MUNE)
				XA1->ESTENT := Alltrim(SQL->A1_ESTE)
				XA1->CEPENT := Alltrim(SQL->A1_CEPE)
				XA1->LIMCRE := SQL->A1_LC
				XA1->MOED	:= SQL->A1_MOEDALC
				XA1->VALANT	:= SQL->VALANT
				XA1->VALATU	:= SQL->VALATU

			XA1->(MSUnlock())
				
		SQL->(dbSkip())
	
	EndDo
EndIf

//Não é fechado a XA1, ela será usada ainda
SQL->(dbCloseArea())

//TABELA SF2
If Select("SQL") > 0
	SQL->(DbCloseArea())
EndIf

cQry := ""
cQry += "SELECT  SUBSTRING(F2_USERLGA, 11,1)+SUBSTRING(F2_USERLGA, 15,1)+SUBSTRING(F2_USERLGA, 2, 1)+SUBSTRING(F2_USERLGA, 6, 1)+ " + CRLF
cQry += "		SUBSTRING(F2_USERLGA, 10,1)+SUBSTRING(F2_USERLGA, 14,1)+SUBSTRING(F2_USERLGA, 1, 1)+SUBSTRING(F2_USERLGA, 5, 1)+ " + CRLF 
cQry += "		SUBSTRING(F2_USERLGA, 9, 1)+SUBSTRING(F2_USERLGA, 13,1)+SUBSTRING(F2_USERLGA, 17,1)+SUBSTRING(F2_USERLGA, 4, 1)+SUBSTRING(F2_USERLGA, 8, 1) USUARIO," + CRLF
cQry += "		 " + CRLF
cQry += "		CAST(CASE WHEN F2_USERLGI<>'' " + CRLF
cQry += "						THEN CONVERT(VARCHAR(10),CAST(DATEADD(DAY,CONVERT(INT, Convert(nvarchar(50),(ASCII(SUBSTRING(F2_USERLGI,12,1)) - 50))+ " + CRLF
cQry += "							 Convert(nvarchar(50),(ASCII(SUBSTRING(F2_USERLGI,16,1)) - 50))), '1996-01-01') AS DATETIME),112 )  " + CRLF
cQry += "						ELSE '19960101'	END AS CHAR) AS INCLUSAO," + CRLF
cQry += "" + CRLF
cQry += "		CAST(CASE WHEN F2_USERLGA<>''" + CRLF 
cQry += "						THEN CONVERT(VARCHAR(10), CAST(DATEADD(DAY,CONVERT(INT, Convert(nvarchar(50),(ASCII(SUBSTRING(F2_USERLGA,12,1)) - 50))+ " + CRLF
cQry += "							 Convert(nvarchar(50),(ASCII(SUBSTRING(F2_USERLGA,16,1)) - 50))), '1996-01-01') AS DATETIME),112 )  " + CRLF
cQry += "						ELSE '19960101'	END AS CHAR) AS ALTERACAO, F2_CLIENTE,F2_LOJA,F2_EMISSAO,F2_VALBRUT,F2_DUPL,F2_VALMERC, " + CRLF
cQry += "						F2_VALICM,F2_VALIMP5,F2_VALIMP6,F2_MOEDA,F2_EST,F2_FRETE,F2_MENNOTA,F2_COND,F2_DOC,F2_SERIE,F2_FILIAL, " + CRLF
//AOA - 01/08/2018 - Ajuste na query para pegar valores de impostos do item e somar na capa
cQry += "						(SELECT ISNULL(SUM(D2_ICMSCOM+D2_DIFAL),0) " + CRLF
cQry += "						FROM "+ RetSqlName("SD2")+ " AS D2 " + CRLF
cQry += "						WHERE D2.D2_FILIAL+D2.D2_DOC+D2.D2_SERIE+D2.D2_CLIENTE+D2.D2_LOJA=SF2.F2_FILIAL+SF2.F2_DOC+SF2.F2_SERIE+SF2.F2_CLIENTE+SF2.F2_LOJA AND D2.D_E_L_E_T_ <> '*') AS IMPITEM, " + CRLF
cQry += "						F2_COND,F2_VEND1,F2_TRANSP,F2_P_DTENV,F2_TIPO,F2_PREFIXO, " + CRLF
cQry += "						SF2.F2_FILIAL+SF2.F2_DOC+SF2.F2_SERIE+SF2.F2_CLIENTE+SF2.F2_LOJA AS CHAVE, " + CRLF
cQry += "						D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_PEDIDO,D2_QUANT,D2_TOTAL,D2_PRCVEN,D2_COD,D2_UM,D2_ITEM,B1_DESC " + CRLF
cQry += "" + CRLF
cQry += "  FROM "+RetSqlName("SF2")+" AS SF2" + CRLF
cQry += "  LEFT JOIN "+RetSqlName("SD2")+" AS SD2 ON SD2.D2_FILIAL+SD2.D2_DOC+SD2.D2_SERIE+SD2.D2_CLIENTE+SD2.D2_LOJA=SF2.F2_FILIAL+SF2.F2_DOC+SF2.F2_SERIE+SF2.F2_CLIENTE+SF2.F2_LOJA AND SD2.D_E_L_E_T_ <> '*'" + CRLF
cQry += "  LEFT JOIN "+RetSqlName("SB1")+" AS SB1 ON SB1.B1_FILIAL+SB1.B1_COD=SD2.D2_FILIAL+SD2.D2_COD AND SB1.D_E_L_E_T_ <> '*' " + CRLF
cQry += " WHERE SF2.D_E_L_E_T_ <> '*'  "/*AND SF2.R_E_C_N_O_ >= 25786 "*/ + CRLF
cQry += " AND SF2.F2_TIPO NOT IN ('D','B','C','I','P') " + CRLF
cQry += " AND SF2.F2_P_DTENV='' " + CRLF
//AOA - 08/03/2018 - Inclusão de filtros conforme proposta LN0001/2018
//cQry += " AND SD2.D2_CF NOT IN ('5908','6908','5949','6949','5910','6910','5912','6912','5911','6911','5915','6915','5913','6913','5916','6916','5901','6901','5902','6902','5903','6903') " + CRLF
cQry += " AND SD2.D2_CF IN ('5102', '5118', '5119', '5403', '5922', '6102', '6108', '6118', '6119', '6403', '6922','1202', '2202') " + CRLF
cQry += " AND SD2.D2_GRUPO='001' " + CRLF

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(RecCount())
SQL->(dbGoTop())

DbSelectArea("SA1")
SA1->(DbSetOrder(1))

DbSelectArea("SA2")
SA2->(DbSetOrder(1))

DbSelectArea("CTO")
CTO->(DbSetOrder(1))

DbSelectArea("SC6")
SC6->(DbSetOrder(1))

DbSelectArea("SC5")
SC5->(DbSetOrder(1))

//Caso o select retorno resultado
While SQL->(!Bof()).AND. SQL->(!Eof())
		lRet  := .T.
		//Tratamento para devolução ou beneficiamento
		If SQL->F2_TIPO $ "D/B"
			SA2->(DbSeek(xFilial("SA2")+SQL->F2_CLIENTE+SQL->F2_LOJA))
			cCliFor:= "SA2->A2_"
			cCodVend:= ""
		Else
			SA1->(DbSeek(xFilial("SA1")+SQL->F2_CLIENTE+SQL->F2_LOJA))
			cCliFor:= "SA1->A1_"
			cCodVend:= SA1->A1_VEND
		EndIf
		
		//Tratamento para descrição da moeda
		CTO->(DbSeek(xFilial("CTO")+Alltrim(StrZero(SQL->F2_MOEDA,2)))) 
		
		//Seek na capa do pedido
		SC5->(DbSeek(xFilial("SC5")+SQL->D2_PEDIDO))
		
		//Seek no item do pedido
		SC6->(DbSeek(xFilial("SC6")+SQL->D2_PEDIDO+SQL->D2_ITEM+SQL->D2_COD))
		 
		//Grava o arquivo temporário XF2
		XF2->(RecLock("XF2",.T.))
			XF2->CHAVE		:= Alltrim(SQL->CHAVE)
			XF2->Operac 	:= Iif(SQL->F2_P_DTENV='',"C","U")
			XF2->CreDat		:= Alltrim(SQL->INCLUSAO)
			XF2->ModDat		:= Alltrim(SQL->ALTERACAO)
			XF2->AltUsr		:= Alltrim(SQL->USUARIO)
			XF2->CodCli		:= Alltrim(SQL->F2_CLIENTE)+Alltrim(SQL->F2_LOJA)
			XF2->Emissao	:= Alltrim((SQL->F2_EMISSAO))
			XF2->NumPed		:= Alltrim((SQL->D2_PEDIDO))
			XF2->ValBrut	:= SQL->F2_VALBRUT
			XF2->Duplic		:= Alltrim(SQL->F2_DOC)
			XF2->DuplOri	:= ""
			XF2->OpenDoc	:= ConsFin()
			XF2->Period		:= ""
			XF2->SubTotal	:= SQL->F2_VALMERC - (SQL->F2_VALICM + SQL->F2_VALIMP5 + SQL->F2_VALIMP6 + SQL->IMPITEM)
			XF2->TotMISC	:= 0
			XF2->TotTax		:= SQL->F2_VALICM + SQL->F2_VALIMP5 + SQL->F2_VALIMP6 + SQL->IMPITEM
			XF2->TotDisc	:= 0
			XF2->BuyerID	:= ""//Branco
			XF2->PedCli		:= Alltrim(SC6->C6_PEDCLI)
			XF2->Moeda		:= Alltrim(CTO->CTO_SIMB)
			XF2->Emissao2	:= Alltrim((SQL->F2_EMISSAO))
			XF2->IDEnv		:= ""//Branco
			XF2->EnvEnd		:= Alltrim(&(cCliFor+"END"))
			XF2->EnvEnd2	:= ""
			XF2->EnvATTN	:= ""
			XF2->EnvName	:= ""
			XF2->EnvMunic	:= Alltrim(&(cCliFor+"MUN"))
			XF2->EnvEst		:= Alltrim(SQL->F2_EST)
			XF2->EnvTel		:= ""
			XF2->EnvCep		:= Alltrim(&(cCliFor+"CEP"))
			XF2->EnvPais	:= Alltrim(&(cCliFor+"PAIS"))
			XF2->VendEnd	:= Alltrim(&(cCliFor+"END"))
			XF2->VendEnd2	:= ""
			XF2->VendATTN	:= ""
			XF2->VendName	:= ""
			XF2->VendMunic	:= Alltrim(&(cCliFor+"MUN"))
			XF2->VendEst	:= Alltrim(SQL->F2_EST)
			XF2->VendTel	:= ""
			XF2->VendCep	:= Alltrim(&(cCliFor+"CEP"))
			XF2->VendPais	:= Alltrim(&(cCliFor+"PAIS"))
			XF2->IdVend		:= ""//Branco
			XF2->Frete		:= SQL->F2_FRETE
			XF2->Picker		:= ""//Branco
			XF2->Packer		:= "" //Branco
			XF2->Mennota	:= Alltrim(SQL->F2_MENNOTA)
			XF2->CondPag	:= Alltrim(SQL->F2_COND)
			XF2->TpFrete	:= Alltrim(SC5->C5_TPFRETE)
			XF2->Transp		:= Alltrim(SQL->F2_TRANSP)
			XF2->DescItem	:= Alltrim(SQL->B1_DESC)
			XF2->Quant		:= SQL->D2_QUANT
			XF2->LTotal		:= SQL->D2_TOTAL
			XF2->Preco		:= SQL->D2_PRCVEN
			XF2->CodItem	:= Alltrim(SQL->D2_COD)
			XF2->QtdVen		:= SC6->C6_QTDVEN
			XF2->QuantVen	:= SQL->D2_QUANT
			XF2->LCodCli	:= cCodVend
			XF2->Unidade	:= Alltrim(SQL->D2_UM)
			XF2->NumItem	:= Alltrim(SQL->D2_ITEM)

		XF2->(MSUnlock())
			
	SQL->(dbSkip())

EndDo

//Não é fechado a XF2, ela será usada ainda
SQL->(dbCloseArea())

//AOA - 09/03/2018 - Inclusão de tratamento para SF1 conforme proposta LN0001/2018
//TABELA SF1
If Select("SQL") > 0
	SQL->(DbCloseArea())
EndIf
        
cQry := ""
cQry += "SELECT SUBSTRING(F1_USERLGA, 11,1)+SUBSTRING(F1_USERLGA, 15,1)+SUBSTRING(F1_USERLGA, 2, 1)+SUBSTRING(F1_USERLGA, 6, 1)+ " + CRLF 
cQry += "		SUBSTRING(F1_USERLGA, 10,1)+SUBSTRING(F1_USERLGA, 14,1)+SUBSTRING(F1_USERLGA, 1, 1)+SUBSTRING(F1_USERLGA, 5, 1)+ " + CRLF  
cQry += "		SUBSTRING(F1_USERLGA, 9, 1)+SUBSTRING(F1_USERLGA, 13,1)+SUBSTRING(F1_USERLGA, 17,1)+SUBSTRING(F1_USERLGA, 4, 1)+SUBSTRING(F1_USERLGA, 8, 1) USUARIO, " + CRLF
cQry += "		CAST(CASE WHEN F1_USERLGI<>''  " + CRLF
cQry += "						THEN CONVERT(VARCHAR(10),CAST(DATEADD(DAY,CONVERT(INT, Convert(nvarchar(50),(ASCII(SUBSTRING(F1_USERLGI,12,1)) - 50))+ " + CRLF 
cQry += "							 Convert(nvarchar(50),(ASCII(SUBSTRING(F1_USERLGI,16,1)) - 50))), '1996-01-01') AS DATETIME),112 )   " + CRLF
cQry += "						ELSE '19960101'	END AS CHAR) AS INCLUSAO, " + CRLF
cQry += "		CAST(CASE WHEN F1_USERLGA<>''  " + CRLF
cQry += "						THEN CONVERT(VARCHAR(10), CAST(DATEADD(DAY,CONVERT(INT, Convert(nvarchar(50),(ASCII(SUBSTRING(F1_USERLGA,12,1)) - 50))+  " + CRLF
cQry += "							 Convert(nvarchar(50),(ASCII(SUBSTRING(F1_USERLGA,16,1)) - 50))), '1996-01-01') AS DATETIME),112 )   " + CRLF
cQry += "						ELSE '19960101'	END AS CHAR) AS ALTERACAO, F1_FORNECE,F1_LOJA,F1_EMISSAO,(F1_VALBRUT)*-1 as VAL_BRUTO,F1_DUPL, " + CRLF
//AOA - 01/08/2018 - Ajuste na query para pegar valores de impostos do item e somar na capa
cQry += "						((F1_VALMERC-(F1_VALICM+F1_VALIMP5+F1_VALIMP6+(SELECT ISNULL(SUM(D1_ICMSCOM+D1_DIFAL),0)"+ CRLF
cQry += "																		FROM "+ RetSqlName("SD1")+ " AS D1  " + CRLF
cQry += "																		WHERE D1.D1_FILIAL+D1.D1_DOC+D1.D1_SERIE+D1.D1_FORNECE+D1.D1_LOJA=SF1.F1_FILIAL+SF1.F1_DOC+SF1.F1_SERIE+SF1.F1_FORNECE+SF1.F1_LOJA AND D1.D_E_L_E_T_ <> '*') " + CRLF
cQry += " 						))+F1_FRETE)*-1 as SUBTOTAL,(F1_VALICM+F1_VALIMP5+F1_VALIMP6+(SELECT ISNULL(SUM(D1_ICMSCOM+D1_DIFAL),0)"+ CRLF
cQry += "																		FROM "+ RetSqlName("SD1")+ " AS D1  " + CRLF
cQry += "																		WHERE D1.D1_FILIAL+D1.D1_DOC+D1.D1_SERIE+D1.D1_FORNECE+D1.D1_LOJA=SF1.F1_FILIAL+SF1.F1_DOC+SF1.F1_SERIE+SF1.F1_FORNECE+SF1.F1_LOJA AND D1.D_E_L_E_T_ <> '*') " + CRLF
cQry += "						)*-1 AS TOTAL_TAX,F1_MOEDA,F1_EST,(F1_FRETE)*-1 as FRETE, " + CRLF
cQry += "						F1_MENNOTA,F1_COND,F1_DOC,F1_SERIE,F1_FILIAL,F1_COND,F1_TRANSP,F1_TIPO,F1_PREFIXO,  " + CRLF
cQry += "						SF1.F1_FILIAL+SF1.F1_DOC+SF1.F1_SERIE+SF1.F1_FORNECE+SF1.F1_LOJA+SF1.F1_TIPO AS CHAVE,F1_P_DTENV, " + CRLF
cQry += "						D1_FILIAL,D1_NFORI,D1_SERIORI,D1_FORNECE,D1_LOJA,D1_PEDIDO,D1_QUANT,(D1_VUNIT)*-1 AS VLRUNIT,(D1_TOTAL)*-1 AS TOTAL,D1_COD,D1_UM,D1_ITEM,B1_DESC  " + CRLF
cQry += "  FROM "+ RetSqlName("SF1")+ " AS SF1 " + CRLF
cQry += "  LEFT JOIN "+ RetSqlName("SD1")+ " AS SD1 ON SD1.D1_FILIAL+SD1.D1_DOC+SD1.D1_SERIE+SD1.D1_FORNECE+SD1.D1_LOJA=SF1.F1_FILIAL+SF1.F1_DOC+SF1.F1_SERIE+SF1.F1_FORNECE+SF1.F1_LOJA AND SD1.D_E_L_E_T_ <> '*'  " + CRLF
cQry += "  LEFT JOIN "+ RetSqlName("SB1")+ " AS SB1 ON SB1.B1_FILIAL+SB1.B1_COD=SD1.D1_FILIAL+SD1.D1_COD AND SB1.D_E_L_E_T_ <> '*' " + CRLF
cQry += " WHERE SF1.D_E_L_E_T_ <> '*' AND SF1.F1_TIPO = 'D' " + CRLF
cQry += " AND SF1.F1_P_DTENV='' "+ CRLF

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "SQL", .F., .T.)

DbSelectArea("SQL")
ProcRegua(RecCount())
SQL->(dbGoTop())

DbSelectArea("SA1")
SA1->(DbSetOrder(1))

DbSelectArea("CTO")
CTO->(DbSetOrder(1))

//Caso o select retorno resultado
While SQL->(!Bof()).AND. SQL->(!Eof())
		lRet  := .T.
		//Tratamento para devolução
		SA1->(DbSeek(xFilial("SA1")+SQL->F1_FORNECE+SQL->F1_LOJA))
		cCliFor := "SA1->A1_"
		cCodVend:= SA1->A1_VEND
	
		//Tratamento para descrição da moeda
		CTO->(DbSeek(xFilial("CTO")+Alltrim(StrZero(SQL->F1_MOEDA,2)))) 
		
		//Grava o arquivo temporário XF2
		XF2->(RecLock("XF2",.T.))
			XF2->CHAVE		:= Alltrim(SQL->CHAVE)
			XF2->Operac 	:= Iif(SQL->F1_P_DTENV='',"C","U")
			XF2->CreDat		:= Alltrim(SQL->INCLUSAO)
			XF2->ModDat		:= Alltrim(SQL->ALTERACAO)
			XF2->AltUsr		:= Alltrim(SQL->USUARIO)
			XF2->CodCli		:= Alltrim(SQL->F1_FORNECE)+Alltrim(SQL->F1_LOJA)
			XF2->Emissao	:= Alltrim((SQL->F1_EMISSAO))
			XF2->NumPed		:= ""
			XF2->ValBrut	:= SQL->VAL_BRUTO
			XF2->Duplic		:= Alltrim(SQL->F1_DOC)
			XF2->DuplOri	:= Alltrim(SQL->D1_NFORI)
			XF2->OpenDoc	:= ""
			XF2->Period		:= ""
			XF2->SubTotal	:= SQL->SUBTOTAL
			XF2->TotMISC	:= 0
			XF2->TotTax		:= SQL->TOTAL_TAX
			XF2->TotDisc	:= 0
			XF2->BuyerID	:= ""//Branco
			XF2->PedCli		:= ""
			XF2->Moeda		:= Alltrim(CTO->CTO_SIMB)
			XF2->Emissao2	:= Alltrim((SQL->F1_EMISSAO))
			XF2->IDEnv		:= ""//Branco
			XF2->EnvEnd		:= Alltrim(&(cCliFor+"END"))
			XF2->EnvEnd2	:= ""
			XF2->EnvATTN	:= ""
			XF2->EnvName	:= ""
			XF2->EnvMunic	:= Alltrim(&(cCliFor+"MUN"))
			XF2->EnvEst		:= Alltrim(SQL->F1_EST)
			XF2->EnvTel		:= ""
			XF2->EnvCep		:= Alltrim(&(cCliFor+"CEP"))
			XF2->EnvPais	:= Alltrim(&(cCliFor+"PAIS"))
			XF2->VendEnd	:= Alltrim(&(cCliFor+"END"))
			XF2->VendEnd2	:= ""
			XF2->VendATTN	:= ""
			XF2->VendName	:= ""
			XF2->VendMunic	:= Alltrim(&(cCliFor+"MUN"))
			XF2->VendEst	:= Alltrim(SQL->F1_EST)
			XF2->VendTel	:= ""
			XF2->VendCep	:= Alltrim(&(cCliFor+"CEP"))
			XF2->VendPais	:= Alltrim(&(cCliFor+"PAIS"))
			XF2->IdVend		:= ""//Branco
			XF2->Frete		:= SQL->FRETE
			XF2->Picker		:= ""//Branco
			XF2->Packer		:= "" //Branco
			XF2->Mennota	:= Alltrim(SQL->F1_MENNOTA)
			XF2->CondPag	:= ""
			XF2->TpFrete	:= ""
			XF2->Transp		:= ""
			XF2->DescItem	:= Alltrim(SQL->B1_DESC)
			XF2->Quant		:= SQL->D1_QUANT
			XF2->LTotal		:= SQL->TOTAL
			XF2->Preco		:= SQL->VLRUNIT
			XF2->CodItem	:= Alltrim(SQL->D1_COD)
			XF2->QtdVen		:= 0
			XF2->QuantVen	:= SQL->D1_QUANT
			XF2->LCodCli	:= cCodVend
			XF2->Unidade	:= Alltrim(SQL->D1_UM)
			XF2->NumItem	:= Alltrim(SQL->D1_ITEM)

		XF2->(MSUnlock())
			
	SQL->(dbSkip())

EndDo

//Não é fechado a XF2, ela será usada ainda
SQL->(dbCloseArea())

Return lRet

/*
Funcao  : ImpRel()
Retorno : Nenhum
Objetivo: Gera arquivo txt com dados
Autor   : Anderson Arrais
Data    : 30/06/2017
*/                   
*-------------------------*
 Static Function ImpRel()
*-------------------------*
Local nHdl		:= 0
Local cMsg		:= ""
Local cDirU5	:= ""
Local cDirA1	:= ""
Local cDirF2	:= ""

cDirServ:= "\FTP\"+cEmpAnt+"\LNFAT001"

//Verifica pasta no servidor para salvar o arquivo
If ExistDir("\FTP")
	If !ExistDir("\FTP\"+cEmpAnt)
		MakeDir("\FTP\"+cEmpAnt)
		MakeDir("\FTP\"+cEmpAnt+"\LNFAT001")
		MakeDir("\FTP\"+cEmpAnt+"\LNFAT001\PROCESSADOS")
		MakeDir("\FTP\"+cEmpAnt+"\LNFAT001\LOG")
		MakeDir("\FTP\"+cEmpAnt+"\LNFAT001\LOG\ERRO")
		 
	Elseif !ExistDir("\FTP\"+cEmpAnt+"\LNFAT001")
   		MakeDir("\FTP\"+cEmpAnt+"\LNFAT001")
   		MakeDir("\FTP\"+cEmpAnt+"\LNFAT001\PROCESSADOS")
   		MakeDir("\FTP\"+cEmpAnt+"\LNFAT001\LOG")
		MakeDir("\FTP\"+cEmpAnt+"\LNFAT001\LOG\ERRO")    
		
	Elseif !ExistDir("\FTP\"+cEmpAnt+"\LNFAT001\PROCESSADOS")
		MakeDir("\FTP\"+cEmpAnt+"\LNFAT001\PROCESSADOS") 
		
	Elseif !ExistDir("\FTP\"+cEmpAnt+"\LNFAT001\LOG")
		MakeDir("\FTP\"+cEmpAnt+"\LNFAT001\LOG")
   		MakeDir("\FTP\"+cEmpAnt+"\LNFAT001\LOG\ERRO") 
   		
	Elseif !ExistDir("\FTP\"+cEmpAnt+"\LNFAT001\LOG\ERRO") 
		MakeDir("\FTP\"+cEmpAnt+"\LNFAT001\LOG\ERRO")		
	EndIf
Else
	MakeDir("\FTP")
	MakeDir("\FTP\"+cEmpAnt)
	MakeDir("\FTP\"+cEmpAnt+"\LNFAT001")
	MakeDir("\FTP\"+cEmpAnt+"\LNFAT001\PROCESSADOS")
	MakeDir("\FTP\"+cEmpAnt+"\LNFAT001\LOG")
	MakeDir("\FTP\"+cEmpAnt+"\LNFAT001\LOG\ERRO")     
EndIf
If !ExistDir("\FTP\"+cEmpAnt+"\LNFAT001")
	conout("Fonte LNFAT001: Falha ao carregar diretório FTP no Servidor!")
	Return .F.
EndIf

XU5->(DbSetOrder(1))
XU5->(DbGoTop())

//Se tiver informação na tabela inicia geração do arquivo e gravação
If XU5->(!Eof()) 
	//cDirU5 := cDirServ+"\BR_Contacts_SU5_"+cNomeData+".txt"
	cDirU5 := cDirServ+"\BR_Contacts.txt"

	//Cria arquivo txt SU5 e preenche com dados.
	nHdl := FCREATE(cDirU5,0 )  //Criação do Arquivo txt.
	If nHdl == -1 // Testa se o arquivo foi gerado 
		cMsg:="O arquivo "+cDirU5+" nao pode ser executado." 
		conout(cMsg)
		lGrvDados := .F.
		Return 
	EndIf
	
	fWrite(nHdl,"Account;Salutation;Operation;First Name;Last Name;E-mail;Job Title;Street 1;Street 2;City;ZIP/Postal Code;State/Province;Country/Region;";
				+"Marketing Emails;Business Phone;Mobile Phone;Home Phone;Fax"+Chr(13)+Chr(10);
		   		)	    

	While XU5->(!EOF()) 
		
		fWrite(nHdl,Alltrim(XU5->ACCOUN)+";";
					+Alltrim(XU5->SALUTA)+";";
					+Alltrim(XU5->OPERAC)+";";
					+Alltrim(XU5->FIRNAN)+";";
					+Alltrim(XU5->LASNAN)+";";
					+Alltrim(XU5->EMAIL) +";";
					+Alltrim(XU5->FUNCAO)+";";
					+Alltrim(XU5->ENDE)  +";";
					+";";
					+Alltrim(XU5->CIDADE)+";";
					+Alltrim(XU5->CEP)   +";";
					+Alltrim(XU5->ESTADO)+";";
					+Alltrim(XU5->PAIS)  +";";
					+";";
					+Alltrim(XU5->EMPFON)+";";
					+Alltrim(XU5->CELFON)+";";
					+Alltrim(XU5->CASFON)+";";
					+Alltrim(XU5->FAXFON)+Chr(13)+Chr(10);
	                )
	    
		XU5->(DbSkip())
	EndDo
	
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
	
EndIf


XA1->(DbSetOrder(1))
XA1->(DbGoTop())

//Se tiver informação na tabela inicia geração do arquivo e gravação
If XA1->(!Eof()) 
	//cDirA1 := cDirServ+"\BR_Customers_SA1_"+cNomeData+".txt"
	cDirA1 := cDirServ+"\BR_Customers.txt"
	
	//Cria arquivo txt SA1 e preenche com dados.
	nHdl := FCREATE(cDirA1,0 )  //Criação do Arquivo txt.
	If nHdl == -1 // Testa se o arquivo foi gerado 
		cMsg:="O arquivo "+cDirA1+" nao pode ser executado." 
		conout(cMsg)
		lGrvDados := .F.
		Return 
	EndIf
	
	fWrite(nHdl,"Company ID;Company Name;Location Name;Customer Group;Operation;CreatedDate;ModifiedDate;ModifiedBy;Salesperson;creditrule;CUS_Status;BillTo Street Address 1;";
				+"BillTo Street Address 2;BillTo ATTN:;BillTo City;BillTo Country;BillTo Fax;BillTo Name;BillTo Phone;BillTo State;BillTo Zip/Postal Code;";
				+"ShipTo Phone;ShipTo Status;ShipTo Email;PO Required;CEDI_ProphixID;CEDI_CustSpecificPrice;ShipTo Street 1;ShipTo Street2;";
				+"ShipTo Contact;ShipTo City;ShipTo Country;ShipTo Created Date;ShipTo CustID;ShipTo Fax;ShipTo Name;ShipTo_ID;ShipTo State/Province;";
				+"ShipTo Zip/Postal Code;Credit Limit;Default Currency;BillTo Country;ShipTo Country;YTDSales;Last_YTDSales"+Chr(13)+Chr(10);
				)
					    
	While XA1->(!EOF()) 
		
		fWrite(nHdl,Alltrim(XA1->COMPID) +";";
					+Alltrim(XA1->COMNAM)+";";
					+Alltrim(XA1->NREDUZ)+";";
					+Alltrim(XA1->GRPVEN)+";";
					+Alltrim(XA1->OPERAC)+";";
					+Alltrim(XA1->CREDAT)+";";
					+Alltrim(XA1->ALTDAT)+";";
					+Alltrim(XA1->USECOD)+";";
					+Alltrim(XA1->VEND)	 +";";
					+Alltrim(XA1->RISCO) +";";
					+Alltrim(XA1->STATU) +";";
					+Alltrim(XA1->ENDE)  +";";
					+Alltrim(XA1->COMPLE)+";";
					+";";
					+Alltrim(XA1->MUN)   +";";
					+Alltrim(XA1->PAIS)  +";";
					+Alltrim(XA1->FAXFON)+";";
					+";";
					+Alltrim(XA1->TELFON)+";";
					+Alltrim(XA1->EST)   +";";
					+Alltrim(XA1->CEP)   +";";
					+";;;;;;";
					+Alltrim(XA1->ENDENT)+";";
					+";;";
					+Alltrim(XA1->MUNE)  +";";
					+";;;;;;";
					+Alltrim(XA1->ESTENT)+";";
					+Alltrim(XA1->CEPENT)+";";
					+Alltrim(XA1->LIMCRE)+";";
					+Alltrim(XA1->MOED)  +";";
					+";;";
					+Alltrim(TRANSFORM((XA1->VALATU),"@E 99,999,999,999.99")) +";";
					+Alltrim(TRANSFORM((XA1->VALANT),"@E 99,999,999,999.99")) ;
					+Chr(13)+Chr(10);
	                )
	    
		XA1->(DbSkip())
	EndDo
	
	fclose(nHdl) // Fecha o Arquivo que foi Gerado

EndIf

XF2->(DbSetOrder(1))
XF2->(DbGoTop())
If XF2->(!Eof()) 
	//cDirF2 := cDirServ+"\BR_Invoices_SF2_"+cNomeData+".txt"
	cDirF2 := cDirServ+"\BR_Invoices.txt"
	
	//Cria arquivo txt SA1 e preenche com dados.
	nHdl := FCREATE(cDirF2,0 )  //Criação do Arquivo txt.
	If nHdl == -1 // Testa se o arquivo foi gerado
		cMsg:="O arquivo "+cDirF2+" nao pode ser executado."
		conout(cMsg)
		lGrvDados := .F.
		Return
	EndIf
	
	fWrite(nHdl,"operation;CreatedDate;ModifiedDate;ModifiedBy;CustID;Doc Date;Orig Order #;d_origdocamt;Original Invoice #;Invoice #;OpenDoc;Post Period;Subtotal;";
				+"Total MISC;Total Tax;Total Disc.;Buyer ID;Cust Order #;CurrencyID;Invoice Date;ShipTo ID;BillTo Street1;BillTo Street 2;";
				+"BillTo ATTN;BillTo Name;BillTo City;BillTo State/Province;BillTo Phone;BillTo Zip;BillTo Country;ShipTo Street1;ShipTo Street2;";
				+"ShipTo ATTN;ShipTo Name;ShipTo City;ShipTo State;ShipTo Phone;ShipTo Zip/Postal;ShipTo Country;CompanyID;Total Freight;Picker;";
				+"Packer;Invoice Notes;Payment Terms;Freight Terms;ShipVIA;L_Description;L_Qty;L_TotalAmount;L_UnitPrice;L_InvtID;L_QtyOrd;L_QtyShip;";
				+"L_SlsPerID;L_UnitDesc;L_LineRef"+Chr(13)+Chr(10);
				)
					    
	While XF2->(!EOF()) 
		fWrite(nHdl, Alltrim(XF2->Operac)	+";";
					+Alltrim(DtoC(StoD(XF2->CreDat)))	+";";
					+Alltrim(DtoC(StoD(XF2->ModDat)))	+";";
					+Alltrim(DtoC(StoD(XF2->AltUsr)))	+";";
					+Alltrim(XF2->CodCli)	+";";
					+Alltrim(DtoC(StoD(XF2->Emissao)))	+";";
					+Alltrim(XF2->NumPed)	+";";
					+Alltrim(TRANSFORM((XF2->ValBrut),"@E 99,999,999,999.99"))	+";";
					+Alltrim(XF2->DuplOri)	+";";
					+Alltrim(XF2->Duplic)	+";";
					+Alltrim(XF2->OpenDoc)	+";";
					+Alltrim(XF2->Period)	+";";
					+Alltrim(TRANSFORM((XF2->SubTotal),"@E 99,999,999,999.99"))	+";";
					+Alltrim(TRANSFORM((XF2->TotMISC),"@E 99,999,999,999.99"))	+";";
					+Alltrim(TRANSFORM((XF2->TotTax),"@E 99,999,999,999.99"))	+";";
					+Alltrim(TRANSFORM((XF2->TotDisc),"@E 99,999,999,999.99"))	+";";
					+Alltrim(XF2->BuyerID)	+";";
					+Alltrim(XF2->PedCli)	+";";
					+Alltrim(XF2->Moeda)	+";";
					+Alltrim(DtoC(StoD(XF2->Emissao2)))	+";";
					+Alltrim(XF2->IDEnv)	+";";
					+Alltrim(XF2->EnvEnd)	+";";
					+Alltrim(XF2->EnvEnd2)	+";";
					+Alltrim(XF2->EnvATTN)	+";";
					+Alltrim(XF2->EnvName)	+";";
					+Alltrim(XF2->EnvMunic)	+";";
					+Alltrim(XF2->EnvEst)	+";";
					+Alltrim(XF2->EnvTel)	+";";
					+Alltrim(XF2->EnvCep)	+";";
					+Alltrim(XF2->EnvPais)	+";";
					+Alltrim(XF2->VendEnd)	+";";
					+Alltrim(XF2->VendEnd2)	+";";
					+Alltrim(XF2->VendATTN)	+";";
					+Alltrim(XF2->VendName)	+";";
					+Alltrim(XF2->VendMunic)+";";
					+Alltrim(XF2->VendEst)	+";";
					+Alltrim(XF2->VendTel)	+";";
					+Alltrim(XF2->VendCep)	+";";
					+Alltrim(XF2->VendPais)	+";";
					+Alltrim(XF2->IdVend)	+";";
					+Alltrim(TRANSFORM((XF2->Frete),"@E 99,999,999,999.99"))	+";";
					+Alltrim(XF2->Picker)	+";";
					+Alltrim(XF2->Packer)	+";";
					+Alltrim(StrTran(XF2->Mennota,";"," "))	+";";
					+Alltrim(XF2->CondPag)	+";";
					+Alltrim(XF2->TpFrete)	+";";
					+Alltrim(XF2->Transp)	+";";
					+Alltrim(XF2->DescItem)	+";";
					+Alltrim(TRANSFORM((XF2->Quant),"@E 99999999.99"))	+";";
					+Alltrim(TRANSFORM((XF2->LTotal),"@E 99,999,999,999.99"))	+";";
					+Alltrim(TRANSFORM((XF2->Preco),"@E 99,999,999,999.99"))	+";";
					+Alltrim(XF2->CodItem)	+";";
					+Alltrim(TRANSFORM((XF2->QtdVen),"@E 99999999.99"))	+";";
					+Alltrim(TRANSFORM((XF2->QuantVen),"@E 99999999.99"))	+";";
					+Alltrim(XF2->LCodCli)	+";";
					+Alltrim(XF2->Unidade)	+";";
					+Alltrim(XF2->NumItem)+Chr(13)+Chr(10);
					)	
		XF2->(DbSkip())
	EndDo
	
	fclose(nHdl) // Fecha o Arquivo que foi Gerado
EndIf

Return


/*
Funcao		: UP2FTP
Objetivo	: Envio o arquivo txt para o FTP
Autor     	: Anderson Arrais	
Data     	: 29/05/2017
*/
*------------------------------*
Static Function UP2FTP()
*------------------------------*
Local lRetFTP := .F.

aArqs := Directory(cDirServ+"\*.txt")

//Faz o upload do arquivo e coloca na pasta processados
conout("Fonte LNFAT001: Up FTP")

//Envia para o FTP.
lRetFTP:= EnvFtps(aArqs)

For i:=1 to Len(aArqs)
	If lRetFTP
		//Copia para a pasta processados
		frename(cDirServ + "\" +alltrim(aArqs[i][1]), cDirServ + "\processados\" +cNomeData+"_"+Alltrim(aArqs[i][1]))
	EndIf
	//Exclui da raiz	
	FERASE(cDirServ+"\"+alltrim(aArqs[i][1]))
Next i

//Compacta a pasta processados
If lRetFTP
	If Compacta( cDirServ + "\processados\*.txt" , cDirServ + "\processados\processados.rar" )
		conout("Pasta Zipada "+cDirServ+"\processados\")
	EndIf
//Erro ao enviar ao FTP Neogen
Else
	XU5->(DbCloseArea())
	SU5->(DbCloseArea())
	XF2->(DbCloseArea())
	SF2->(DbCloseArea())
	XA1->(DbCloseArea())
	SA1->(DbCloseArea())
	Return .F.
EndIf               

//Pega as informações da tabela temporaria ainda aberta e grava P_DTENV confirmando assim que foi enviado para o ftp
//Contatos
XU5->(DbSetOrder(1))
XU5->(DbGoTop())

DbSelectArea("SU5")

While XU5->(!EOF())              

	SU5->(DbSetOrder(1))
	SU5->(DbGoTop())
	SU5->(DbSeek(xFilial("SU5")+XU5->ACCOUN))
	RecLock("SU5",.F.)
		SU5->U5_P_DTENV := date()
	SU5->(MsUnlock())
	
	XU5->(DbSkip())
EndDo

XU5->(DbCloseArea())
SU5->(DbCloseArea())

//Clientes
XA1->(DbSetOrder(1))
XA1->(DbGoTop())

DbSelectArea("SA1")

While XA1->(!EOF())              

	SA1->(DbSetOrder(1))
	SA1->(DbGoTop())
	SA1->(DbSeek(xFilial("SA1")+XA1->COMPID))
	RecLock("SA1",.F.)
		SA1->A1_P_DTENV := date()
	SA1->(MsUnlock())
	
	XA1->(DbSkip())
EndDo

//Fecha as tabelas temporarias
XA1->(DbCloseArea())
SA1->(DbCloseArea())

DbSelectArea("SF2")
DbSelectArea("SF1")

XF2->(DbSetOrder(1))
XF2->(DbGoTop())

While XF2->(!EOF())              

	SF2->(DbSetOrder(1))
	SF2->(DbGoTop())
	SF1->(DbSetOrder(1))
	SF1->(DbGoTop())
	If SF2->(DbSeek(Alltrim(XF2->CHAVE)))
		RecLock("SF2",.F.)
			SF2->F2_P_DTENV := date()
		SF2->(MsUnlock())
	ElseIf SF1->(DbSeek(Alltrim(XF2->CHAVE)))
		RecLock("SF1",.F.)
			SF1->F1_P_DTENV := date()
		SF1->(MsUnlock())	
	EndIf

	XF2->(DbSkip())
EndDo

//Fecha as tabelas temporarias
XF2->(DbCloseArea())
SF2->(DbCloseArea())
SF1->(DbCloseArea())

	
Return .T.

/*
Funcao      : compacta
Parametros  : cArquivo,cArqRar
Retorno     : lRet
Objetivos   : Função para compactar arquivo
Autor       : Renato Rezende
Data/Hora   : 
*/
*--------------------------------------------------*
 Static Function compacta(cArquivo,cArqRar)
*--------------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:= GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .F.
Local cPath     := 'C:\Program Files\WinRAR\'

cCommand 	:= 'C:\Program Files\WinRAR\WinRAR.exe m -ep1 -o+ "'+cRootPath+cArqRar+'" "'+cRootPath+cArquivo+'"' 

lRet := WaitRunSrv( cCommand , lWait , cPath )

Return(lRet)

/*
Funcao      : ConsFin
Parametros  : 
Retorno     : cStatus
Objetivos   : Consulta título no financeiro
Autor       : Renato Rezende
*/
*-----------------------------------------------------*
 Static Function ConsFin()
*-----------------------------------------------------*
Local cStatus	:= "0"
Local cQuery	:= ""
Local cAlias	:= ""
Local cCliFor	:= ""
Local cForCli	:= ""
Local nResult	:= 0

//Tratamento para devolução ou beneficiamento
If SQL->F2_TIPO $ "D/B"
	cCliFor:= "E2"
	cForCli:= "E2_FORNECE"
Else
	cCliFor:= "E1"
	cForCli:= "E1_CLIENTE"
EndIf

If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf

cQuery := " SELECT "+cCliFor+"_FILIAL, "+cForCli+", "+cCliFor+"_LOJA, "+cCliFor+"_PREFIXO, "+cCliFor+"_NUM, "+cCliFor+"_PARCELA, "+cCliFor+"_TIPO, "+cCliFor+"_BAIXA, "+cCliFor+"_EMISSAO " + CRLF
cQuery += "   FROM "+RETSQLNAME("S"+cCliFor)
cQuery += "  WHERE "+cCliFor+"_FILORIG+"+cForCli+"+"+cCliFor+"_LOJA+"+cCliFor+"_PREFIXO+"+cCliFor+"_NUM+"+cCliFor+"_TIPO = '"+SQL->F2_FILIAL+SQL->F2_CLIENTE+SQL->F2_LOJA+SQL->F2_PREFIXO+SQL->F2_DOC+"NF'  " + CRLF
cQuery += "   AND D_E_L_E_T_ <> '*' " + CRLF

DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY",.F.,.T.)

Count to nRecCount

QRY->(DbGoTop())

If nRecCount > 0
	While QRY->(!Eof())
		If !Empty(&("QRY->"+cCliFor+"_BAIXA")) .OR. nRecCount == 1
			nResult++
		EndIf	
		QRY->(dbSkip())
	EndDo

Else
	cStatus:= "0"
EndIf

If nRecCount == nResult .AND. nRecCount > 0
	cStatus:= "1"
EndIf

Return cStatus

/*
Funcao      : EnvFtps
Parametros  : aArqs
Retorno     : lRet
Objetivos   : Função para enviar o arquivo ao FTP
Autor       : Renato Rezende
Data/Hora   : 
*/
*--------------------------------------------------*
 Static Function EnvFtps(aArqs)
*--------------------------------------------------*
Local lRet		:=.F.
Local cRootPath	:= GetSrvProfString("RootPath", "\undefined")//retorna o caminho do rootpath
Local cCommand 	:= ""
Local lWait  	:= .T.
Local cPath     := 'C:\Program Files (x86)\WinSCP\'
Local cBatWscp	:= ""
Local cArqLogEr := ""

cBatWscp := cDirServ+"\wiscpconnect2.bat"
cArqLogEr:= '\ftp\ln\lnfat001\log\ERRO\WinSCPconnect_'+DtoS(dDataBase)+'.log

//Cria arquivo bat para subir arquivo no FTP.
nHdl := FCREATE(cBatWscp,0 )  //Criação do Arquivo txt.
If nHdl == -1 // Testa se o arquivo foi gerado 
	cMsg:="O bat "+cBatWscp+" nao pode ser executado." 
	conout(cMsg)
	Return lRet
EndIf

cCommand:= '@echo off' +CRLF
cCommand+= CRLF
cCommand+= 'set dateenv='+DtoS(dDataBase)+CRLF
cCommand+= CRLF
cCommand+= '"C:\Program Files (x86)\WinSCP\WinSCP.com" ^'+CRLF
cCommand+= '  /log="'+cRootPath+'\ftp\ln\lnfat001\log\WinSCPconnect_%dateenv%.log" /ini=nul ^'+CRLF
cCommand+= '  /command ^'+CRLF
//cCommand+= '    "open ftpes://atrioftp:VDu7F0kevnA9Wveaf@216.157.208.188/ -explicit -certificate="*"" ^'+CRLF
cCommand+= '    "open ftps://atrioftp:VDu7F0kevnA9Wveaf@216.157.208.188/ -certificate="*"" ^'+CRLF
For nR:= 1 to Len(aArqs)
	cCommand+= '    "put ""'+cRootPath+cDirServ+"\"+alltrim(aArqs[nR][1])+'""" ^'+CRLF
Next nR
cCommand+= '    "exit"' +CRLF
cCommand+= CRLF
cCommand+= 'set WINSCP_RESULT=%ERRORLEVEL%'+CRLF
cCommand+= 'if %WINSCP_RESULT% equ 0 ('+CRLF
cCommand+= '  echo Success'+CRLF
cCommand+= ') else ('+CRLF
cCommand+= '  echo Error'+CRLF
cCommand+= '  Move '+cRootPath+'\ftp\ln\lnfat001\log\WinSCPconnect_%dateenv%.log '+cRootPath+'\ftp\ln\lnfat001\log\ERRO\WinSCPconnect_%dateenv%.log'+CRLF
cCommand+= ')'+CRLF
cCommand+= CRLF
cCommand+= 'exit /b %WINSCP_RESULT%'+CRLF

fWrite(nHdl,cCommand)//Escreve no arquivo
fclose(nHdl)//Fecha o arquivo

lRet := WaitRunSrv( @cRootPath+cBatWscp , @lWait , @cPath )

fErase(cBatWscp)//Apaga o .Bat

If File(UPPER(cArqLogEr)) .AND. lRet
	MailLog(cArqLogEr,lRet)
	lRet:= .F.             
ElseIf !lRet
	MailLog(cArqLogEr,lRet)	
EndIf

Return(lRet)

/*
Funcao      : MailLog
Objetivos   : Envia email de Erro
Autor       : Renato Rezende
*/
*-------------------------------------------*
 Static Function MailLog(cArqLogEr,lRetEnv)
*-------------------------------------------*
Local cFrom			:= AllTrim(SuperGetMv("MV_RELFROM",.F., ""))//Email de origem
Local cPassword 	:= AllTrim(SuperGetMv("MV_RELPSW" ,.F., ""))
Local lAutentica	:= SuperGetMv("MV_RELAUTH",.F.,.F.)//Determina se o Servidor de Email necessita de Autenticação
Local cUserAut  	:= Alltrim(SuperGetMv("MV_RELAUSR",.F., ""))//Usuário para Autenticação no Servidor de Email
Local cPassAut  	:= Alltrim(SuperGetMv("MV_RELAPSW",.F., ""))//Senha para Autenticação no Servidor de Email
Local cAccount		:= AllTrim(SuperGetMv("MV_RELACNT",.F.,	""))
Local cServer		:= AllTrim(SuperGetMv("MV_RELSERV",.F.,	""))
Local cTo 			:= AllTrim(SuperGetMv("MV_P_00106",.F., ""))//Email que será enviado o log de processamento.
Local cCC			:= ""
Local cToOculto		:= ""
Local cAttachment 	:= ""
Local cArqMail 		:= ""
Local cSubject		:= "Erro envio ao FTP Neogen - CRM - "+DtoC(Date())

Private cMsg  := ""
Private cDate := DtoC(Date())
Private cTime := SubStr(Time(),1,5)
Private cUser := UsrFullName(RetCodUsr())

If Empty(cServer)
	ConOut("Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'")
	Return .F.
EndIf

If Empty(cAccount)
	ConOut("Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'")
	Return .F.
EndIf

cAttachment	:= UPPER(cArqLogEr) 

//Corpo do Email
cMsg := Email(lRetEnv)

//Conexão com o servidor de email
CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

If !lOK
	ConOut("Falha na Conexão com Servidor de E-Mail")
	Return .F.
Else
	If lAutentica
		If !MailAuth(cUserAut,cPassAut)
			ConOut("Falha na Autenticacao do Usuario")
			DISCONNECT SMTP SERVER RESULT lOk          
			Return .F.
		EndIf
	EndIf
	
	//Envio do email
	SEND MAIL FROM cFrom TO cTo CC cCC BCC cToOculto;
	SUBJECT cSubject BODY cMsg ATTACHMENT cAttachment RESULT lOK

	If !lOK
		ConOut("Falha no Envio do E-Mail: "+Alltrim(cTo))
		DISCONNECT SMTP SERVER
		Return .F.
	EndIf
EndIf

DISCONNECT SMTP SERVER

Return .T.

/*
Funcao      : Email
Retorno     : cHtml
Objetivos   : Criar corpo do email de notificação
Autor       : Renato Rezende
*/
*---------------------------------*
 Static Function Email(lRetEnv)
*---------------------------------*
Local cHtml := ""

cHtml += '<html>
cHtml += '	<head>
cHtml += '	<title>Modelo-Email</title>
cHtml += '	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
cHtml += '	</head>
cHtml += '	<body bgcolor="#FFFFFF" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
cHtml += '		<table id="Tabela_01" width="631" height="342" border="0" cellpadding="0" cellspacing="0">
cHtml += '			<tr><td width="631" height="10"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="1" bgcolor="#8064A1"></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25"> <font size="2" face="tahoma" color="#551A8B"><b>ERRO WORKFLOW PROCESSAMENTO NEOGEN</b></font>   </td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">DATE: '+ALLTRIM(cDate)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">TIME: '+ALLTRIM(cTime)+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="25" bgcolor="#E5DFEB"><font size="2" face="tahoma" color="#8064A1">USER: '+IIF(Empty(ALLTRIM(cUser)),"JOB", Alltrim(cUser))+'</font></td>
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr>
If lRetEnv
	cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">ARQUIVO LOG ANEXO COM ERRO</font></td>
Else
	cHtml += '				<td width="631" height="26"><font size="2" face="tahoma" color="#8064A1">ERRO INTERNO - SERVIDOR</font></td>
EndIf
cHtml += '			</tr>
cHtml += '			<tr><td width="631" height="1" bgcolor="#8064A1"></td></tr>
cHtml += '			<tr><td width="631" height="20"></td></tr>
cHtml += '			<tr>
cHtml += '				<td width="631" height="20"><p align=center>Mensagem automatica, nao responder.</p></td>
cHtml += '			</tr>
cHtml += '		</table>
cHtml += '	</body>
cHtml += '</html>

Return cHtml