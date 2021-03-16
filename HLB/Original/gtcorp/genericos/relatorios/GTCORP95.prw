#Include "Protheus.Ch"
#Include "TopConn.Ch"

/*
Função.............: GTCORP95
Autor..............: Leandro Diniz de Brito ( LDB )
Objetivo...........: Gerar Relatório de Clientes x Gerentes x Socios ( CT2 )   - (Carteira Cliente)
Data...............: 08/05/2015
Alterações.........:      
Observaçoes........: Query do Relatorio Elaborada por Matheus Massarotto
Modulo.............: SigaFAT\SigaGPE\SigaCTB
*/                          

*-----------------------------------------*
User Function GTCORP95
*-----------------------------------------*
Local   aArea     := GetArea()
Local   oReport

Local   cDescri   := "Este relatório imprime o Relatório de Clientes x Gerentes x Socios."
Local   cReport   := "GTCORP95"

Local   cTitulo   := "Relatório de Clientes x Gerentes x Socios"
Local   oSection

Local   cAlias    := GetNextAlias()
Local   nFields


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Cria objeto TReport³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oReport  := TReport():New( cReport, cTitulo ,, { |oReport| ReportPrint( oReport , cAlias ) } , cDescri )

oReport:SetLandscape()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Cria seção do Relatório³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oSection := TRSection():New( oReport, "Campos do relatorio" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³              Define células que serão pré carregadas na impressão³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

TRCell():New( oSection, 'COD_EMP' , cAlias , 'Empresa' )
TRCell():New( oSection, 'NOME_EMP' , cAlias , 'Nome Empresa' )
TRCell():New( oSection, 'CNPJ_EMP' , cAlias , 'CNPJ Empresa' )
TRCell():New( oSection, 'COD_CLI' , cAlias , 'Cliente' )
TRCell():New( oSection, 'LOJA_CLI' , cAlias , 'Loja' )
TRCell():New( oSection, 'NOME_CLI' , cAlias , 'Nome Cliente' )
TRCell():New( oSection, 'COD_RAMO_CLI' , cAlias , 'Cod. Ramo Cliente' )
TRCell():New( oSection, 'RAMO_CLI' , cAlias , 'Descricao Ramo' )
TRCell():New( oSection, 'COD_GER_CONTA' , cAlias , 'Cod. Ger. Conta'  )
TRCell():New( oSection, 'NOME_GER_CONTA' , cAlias , 'Nome Ger. Conta' ) 
TRCell():New( oSection, 'COD_GER_TABIL' , cAlias , 'Cod. Ger. Contabil' ) //JSS Alterado nome da coluna pois estava tranzendo dados errados e 
TRCell():New( oSection, 'NOME_GER_TABIL' , cAlias , 'Nome Ger. Contabil' )//JSS Alterado nome da coluna pois estava tranzendo dados errados e Add coluna por solicitação de Sergio F. Tsujioka
TRCell():New( oSection, 'COD_SOCIO' , cAlias , 'Cod. Socio' )
TRCell():New( oSection, 'NOME_SOCIO' , cAlias ,  'Nome Socio' )

oReport:PrintDialog()

RestArea( aArea )

Return

/*
Funcao.......: ReportPrint
Autor........: Leandro Diniz de Brito
Data.........: 05/2015
Objetivo.....: Funcao executada no botão OK na tela de parametrização ( impressão )
Cliente......: 
Observações..:
Alterações...:
*/
*---------------------------------------------------------*
Static Function ReportPrint( oReport , cAlias )
*---------------------------------------------------------*
Local oSection := oReport:Section( 1 ) 
Local cWhere 
Local cQuery
Local cCampos  := ""
Local cProc    := "SP_GTCORP95"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Inicio Execução da Query
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ      

If !TCSpExist( cProc )

	cQuery := ;
	"CREATE PROCEDURE " + cProc + " AS " + Chr( 13 ) + Chr( 10 ) + ;
	"Declare @EMP VARCHAR(2) " + Chr( 13 ) + Chr( 10 ) + ;
	"Declare @NOME_EMP VARCHAR(MAX) "  + Chr( 13 ) + Chr( 10 ) + ;
	"Declare @CNPJ_EMP VARCHAR(MAX) " + Chr( 13 ) + Chr( 10 ) + ;
	"Declare @EST_EMP VARCHAR(MAX) " + Chr( 13 ) + Chr( 10 ) + ;
	"Declare @CQUERY VARCHAR(MAX) " + Chr( 13 ) + Chr( 10 ) + ;
	"Declare @CQRYSRA VARCHAR(MAX) " + Chr( 13 ) + Chr( 10 ) + ;
	"Declare @TABAUX Table(COD_EMP VARCHAR(2),NOME_EMP VARCHAR(100),CNPJ_EMP VARCHAR(20),COD_CLI VARCHAR(6),LOJA_CLI VARCHAR(2), NOME_CLI VARCHAR(100),COD_RAMO_CLI VARCHAR(6),RAMO_CLI VARCHAR(100),COD_GER_CONTA VARCHAR(11),NOME_GER_CONTA VARCHAR(100),COD_GER_TABIL VARCHAR(11),NOME_GER_TABIL VARCHAR(100),COD_SOCIO VARCHAR(11),NOME_SOCIO VARCHAR(100)) " + Chr( 13 ) + Chr( 10 ) + ;   ////JSS Alterado nome das variaveis pois estava tranzendo dados errados e
	"Declare @TABSRA Table(RA_CIC VARCHAR(11),RA_NOME varchar(100)) " + Chr( 13 ) + Chr( 10 ) + ;
	"DECLARE cursor_emp_SRA CURSOR " + Chr( 13 ) + Chr( 10 ) + ;
	"For SELECT M0_CODIGO FROM SIGAMAT " + Chr( 13 ) + Chr( 10 ) + ;
	"GROUP BY M0_CODIGO " + Chr( 13 ) + Chr( 10 ) + ;
	"OPEN cursor_emp_SRA " + Chr( 13 ) + Chr( 10 ) + ;
	"Fetch Next From cursor_emp_SRA " + Chr( 13 ) + Chr( 10 ) + ;
	"Into @EMP " + Chr( 13 ) + Chr( 10 ) + ;
	"set @CQRYSRA = '' " + Chr( 13 ) + Chr( 10 ) + ;
	"While @@FETCH_STATUS = 0 " + Chr( 13 ) + Chr( 10 ) + ;
	"Begin " + Chr( 13 ) + Chr( 10 ) + ;
	"if len(@CQRYSRA) > 0 " + Chr( 13 ) + Chr( 10 ) + ;
	"begin " + Chr( 13 ) + Chr( 10 ) + ;
	"Set @CQRYSRA += ' UNION ' " + Chr( 13 ) + Chr( 10 ) + ;
	"end " + Chr( 13 ) + Chr( 10 ) + ;
	"Set @CQRYSRA += ' SELECT RA_CIC,RA_NOME FROM SRA'+ @EMP + '0 SRA' " + Chr( 13 ) + Chr( 10 ) + ;
	"Set @CQRYSRA += ' LEFT JOIN SRJ'+@EMP+'0 SRJ ON RJ_FUNCAO = RA_CODFUNC AND SRJ.D_E_L_E_T_='+''''+'''' " + Chr( 13 ) + Chr( 10 ) + ;
	"Set @CQRYSRA += ' WHERE (UPPER(RJ_DESC) LIKE '+''''+'%GER%'+''''+' OR UPPER(RJ_DESC) LIKE '+''''+'%SOC%'+''''+' OR UPPER(RJ_DESC) LIKE '+''''+'%DIR%'+''''+' OR UPPER(RJ_DESC) LIKE '+''''+'%EXEC%'+''''+' OR UPPER(RJ_DESC) LIKE '+''''+'%SUPER%'+''''+' OR UPPER(RJ_DESC) LIKE '+''''+'%CONS%'+''''+')' " + Chr( 13 ) + Chr( 10 ) + ;
	"Set @CQRYSRA += ' AND RA_SITFOLH NOT IN ('+''''+'D'+''''+','+''''+'T'+''''+') AND SRA.D_E_L_E_T_='+''''+'''' " + Chr( 13 ) + Chr( 10 ) + ;
	"Fetch Next From cursor_emp_SRA " + Chr( 13 ) + Chr( 10 ) + ;
	"Into @EMP " + Chr( 13 ) + Chr( 10 ) + ;
	"End " + Chr( 13 ) + Chr( 10 ) + ;
	"insert into @TABSRA exec(@CQRYSRA) " + Chr( 13 ) + Chr( 10 ) + ;
	"select * into #TABSRA from @TABSRA " + Chr( 13 ) + Chr( 10 ) + ;
	"close cursor_emp_SRA; " + Chr( 13 ) + Chr( 10 ) + ;
	"Deallocate cursor_emp_SRA; " + Chr( 13 ) + Chr( 10 ) + ;
	"DECLARE cursor_emp CURSOR " + Chr( 13 ) + Chr( 10 ) + ;
	"For --SELECT M0_CODIGO,M0_NOME,M0_CGC FROM SIGAMAT " + Chr( 13 ) + Chr( 10 ) + ;
	"SELECT " + Chr( 13 ) + Chr( 10 ) + ;
	"M0_CODIGO, M0_NOME, M0_CGC ,M0_ESTCOB " + Chr( 13 ) + Chr( 10 ) + ;
	"FROM SIGAMAT SIGA " + Chr( 13 ) + Chr( 10 ) + ;
	"OPEN cursor_emp " + Chr( 13 ) + Chr( 10 ) + ;
	"Fetch Next From cursor_emp " + Chr( 13 ) + Chr( 10 ) + ;
	"Into @EMP,@NOME_EMP,@CNPJ_EMP,@EST_EMP " + Chr( 13 ) + Chr( 10 ) + ;
	"While @@FETCH_STATUS = 0 " + Chr( 13 ) + Chr( 10 ) + ;
	"Begin " + Chr( 13 ) + Chr( 10 ) + ;
	"if CHARINDEX('/',@NOME_EMP)>0 " + Chr( 13 ) + Chr( 10 ) + ;
	"begin " + Chr( 13 ) + Chr( 10 ) + ;
	"SET @NOME_EMP = SUBSTRING(@NOME_EMP,LEN(@NOME_EMP)-CHARINDEX('/',REVERSE(@NOME_EMP))+2,LEN(@NOME_EMP)) " + Chr( 13 ) + Chr( 10 ) + ;
	"end " + Chr( 13 ) + Chr( 10 ) + ;
	"Set @CQUERY = ' SELECT '+''''+@EMP+''''+','+''''+RTRIM(@NOME_EMP)+'-'+@EST_EMP+''''+','+''''+@CNPJ_EMP+''''+',A1_COD,A1_LOJA,A1_NOME,A1_P_RMATI,A1_P_DRMAT,A1_P_GECTA,ISNULL(GECTA.RA_NOME,'+''''+''''+'),A1_P_GECTB,ISNULL(GECTB.RA_NOME,'+''''+''''+'),A1_P_SORES,ISNULL(SOC.RA_NOME,'+''''+''''+') FROM SA1' + @EMP + '0 SA1' " + Chr( 13 ) + Chr( 10 ) + ;
	"Set @CQUERY +=' LEFT JOIN  #TABSRA '  " + Chr( 13 ) + Chr( 10 ) + ;
	"Set @CQUERY +='  GECTB ON GECTB.RA_CIC = SA1.A1_P_GECTB ' " + Chr( 13 ) + Chr( 10 ) + ;
	"Set @CQUERY +=' LEFT JOIN  #TABSRA ' " + Chr( 13 ) + Chr( 10 ) + ;
	"Set @CQUERY +='  GECTA ON GECTA.RA_CIC = SA1.A1_P_GECTA ' " + Chr( 13 ) + Chr( 10 ) + ;
	"Set @CQUERY +=' LEFT JOIN  #TABSRA' " + Chr( 13 ) + Chr( 10 ) + ;
	"Set @CQUERY +='  SOC ON SOC.RA_CIC = SA1.A1_P_SORES ' " + Chr( 13 ) + Chr( 10 ) + ;
	"Set @CQUERY +=' WHERE SA1.D_E_L_E_T_='+''''+''''  " + Chr( 13 ) + Chr( 10 ) + ;
	"PRINT(@CQUERY) " + Chr( 13 ) + Chr( 10 ) + ;
	"INSERT INTO @TABAUX exec(@CQUERY) " + Chr( 13 ) + Chr( 10 ) + ;
	"Fetch Next From cursor_emp " + Chr( 13 ) + Chr( 10 ) + ;
	"Into @EMP,@NOME_EMP,@CNPJ_EMP,@EST_EMP " + Chr( 13 ) + Chr( 10 ) + ;
	"End " + Chr( 13 ) + Chr( 10 ) + ;
	"close cursor_emp; " + Chr( 13 ) + Chr( 10 ) + ;
	"Deallocate cursor_emp; " + Chr( 13 ) + Chr( 10 ) + ;
	"drop table #TABSRA " + Chr( 13 ) + Chr( 10 ) + ;
	"SELECT * FROM @TABAUX " + Chr( 13 ) + Chr( 10 ) + ;
	"GO"

	If TCSqlExec( cQuery ) < 0 
   		Alert( TCSqlError() )
	EndIf

EndIf

cQuery := "EXEC " + cProc
TCQuery cQuery ALIAS ( cAlias ) NEW 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//                     ³Imprime relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O método 'Print()' se encarrega de efetuar a impressão do relatório, ³
//³controle de linhas, salto de pagina ...                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSection:cAlias := cAlias
oSection:Print()

( cAlias )->( DbCloseArea() )

Return
