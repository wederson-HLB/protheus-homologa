#include "protheus.ch"
#Include "Topconn.ch"
#Include "TBICONN.ch"

/*
Funcao      : GTGEN036 
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Fonte que cria e alimenta a tabela AUX_RESPON, com os responsáveis
Autor       : 
Revisão     : Matheus Massarotto
Data/Hora   : 31/07/2015
Módulo      : Configurador (Schedule)
*/

*----------------------*
User function GTGEN036
*----------------------*
Local cQuery	:= ""

if Select("SX3")<=0
	RpcClearEnv()
	RpcSetType(3)
	Prepare Environment Empresa "YY" Filial "01"
endif

cQuery+=" Declare @EMP VARCHAR(2)
cQuery+=" Declare @CQRYSRA VARCHAR(MAX)
cQuery+=" 
cQuery+=" Declare @TABSRA Table(RA_CIC VARCHAR(11),RA_NOME varchar(100),RA_EMAIL VARCHAR(200))
cQuery+=" 
cQuery+=" if (SELECT count(*) FROM sys.objects
cQuery+=" 	WHERE name = 'AUX_RESPON' AND type='U') >0
cQuery+=" 	begin
cQuery+=" 		DELETE FROM AUX_RESPON
cQuery+=" 	end
cQuery+=" else
cQuery+=" 	begin
cQuery+=" 		select * into AUX_RESPON from @TABSRA		
cQuery+=" 	end
cQuery+=" 
cQuery+=" --Parte para gerar tabela temporária com os funcionários e nomes "+CRLF
cQuery+=" DECLARE cursor_emp_SRA CURSOR
cQuery+=" 
cQuery+=" For SELECT M0_CODIGO FROM SIGAMAT
cQuery+=" WHERE M0_CODIGO IN ('Z4','4K','CH','Z8','RH','1T')
cQuery+=" GROUP BY M0_CODIGO
cQuery+=" 
cQuery+=" OPEN cursor_emp_SRA
cQuery+=" Fetch Next From cursor_emp_SRA
cQuery+=" Into @EMP
cQuery+=" 
cQuery+=" set @CQRYSRA = ''
cQuery+=" 
cQuery+=" While @@FETCH_STATUS = 0
cQuery+=" Begin
cQuery+=" 
cQuery+=" if len(@CQRYSRA) > 0
cQuery+=" begin
cQuery+=" Set @CQRYSRA += ' UNION '
cQuery+=" end
cQuery+=" 
cQuery+=" Set @CQRYSRA += ' SELECT RA_CIC,RA_NOME,RA_EMAIL FROM SRA'+ @EMP + '0 SRA'
cQuery+=" Set @CQRYSRA += ' LEFT JOIN SRJ'+@EMP+'0 SRJ ON RJ_FUNCAO = RA_CODFUNC AND SRJ.D_E_L_E_T_='+''''+''''
cQuery+=" Set @CQRYSRA += ' WHERE ((UPPER(RJ_DESC) LIKE '+''''+'%GER%'+''''+' OR UPPER(RJ_DESC) LIKE '+''''+'%SOC%'+''''+' OR UPPER(RJ_DESC) LIKE '+''''+'%DIR%'+''''+' OR UPPER(RJ_DESC) LIKE '+''''+'%EXEC%'+''''+' OR UPPER(RJ_DESC) LIKE '+''''+'%SUPER%'+''''+' OR UPPER(RJ_DESC) LIKE '+''''+'%CONSULTOR%'+''''+')'
cQuery+=" Set @CQRYSRA += ' OR RA_CIC IN ('+''''+'28522085803'+''''+')) '
cQuery+=" Set @CQRYSRA += ' AND RA_SITFOLH NOT IN ('+''''+'D'+''''+','+''''+'T'+''''+') AND SRA.D_E_L_E_T_='+''''+''''
cQuery+=" 
cQuery+=" Fetch Next From cursor_emp_SRA
cQuery+=" Into @EMP
cQuery+=" 
cQuery+=" End
cQuery+=" 
cQuery+=" insert into AUX_RESPON exec(@CQRYSRA)
cQuery+=" 
cQuery+=" close cursor_emp_SRA;
cQuery+=" Deallocate cursor_emp_SRA;

If TCSQLExec(cQuery) < 0
	conout("ERRO ----> GTGEN036 <------"+TCSQLError())
Endif

Return