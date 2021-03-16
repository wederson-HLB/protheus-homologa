#include "PROTHEUS.CH"
       
/*
Funcao      : AFTERLOGIN
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : P.E. para Controle de acessos 
Autor     	: Jean Victor Rocha
Data     	: 18/06/09
Obs         : 
TDN         : Ao acessar pelo SIGAMDI, este ponto de entrada é chamado ao entrar na rotina. Pelo modo SIGAADV, a abertura dos SXs é executado após o login.
Módulo      : Todos
*/
*------------------------*
User Function AFTERLOGIN()
*------------------------*
//Testa para verificar se a chamada é por JOBS
If Select("SX3")<=0
	Return
EndIf			                  

If ValidaEmerg()
	ALERT("Acesso não Autorizado!")
	KillApp( .T. )         
EndIf

Return
           
/*
Funcao      : ValidaEmerg
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Controle de Acesso ao Repositorio Emergencial.
Autor     	: Jean Victor Rocha
Data     	: 14/01/2014
Obs         : 
*/
*----------------------------*
Static Function ValidaEmerg() 
*----------------------------*
Local lRet := .T.
Local nOpc := 0
        
Private cGet1 := Space(6)
//Se for Administrador não executa.
If FwIsAdmin()
	Return !lRet
EndIf

If UPPER(Right(GetEnvServer(),1)) $ "A|B|C|D|E"
	If UPPER(GetEnvServer()) == "GTHD" .OR. AT("TESTE",UPPER(GetEnvServer()) ) <> 0//Valida o unico ambiente com final 'D'.
		Return !lRet
	EndIf
    
	cMGetNew := "Acesso Restrito ao repositorio de Emergencia!"+CHR(10)+CHR(13)
	cMGetNew += "Cod. Acesso Temporaria Fornecida apenas "+CHR(10)+CHR(13)
	cMGetNew += "pela equipe de Sistemas quando for necessario."+CHR(10)+CHR(13)
	oDlg1      := MSDialog():New( 247,531,531,829,"Repositorio de Emergencia",,,.F.,,,,,,.T.,,,.T. )
	oSay1      := TSay():New( 008,004,{||"Repositorio de Emergencia: "+UPPER(Right(GetEnvServer(),1))},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,104,008)
	oSay2      := TSay():New( 016,004,{||"Usuario: "+cUserName},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,104,008)
	oSay3      := TSay():New( 024,004,{||"Data: "+DTOC(DATE())},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,104,008)
	oSay4      := TSay():New( 032,004,{||"Ambiente: "+UPPER(GetEnvServer())},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,104,008)
	oSay5      := TSay():New( 064,004,{||"Cod.Acesso"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
	oGet1      := TGet():New( 064,048,{|u| IF(PCount()>0,cGet1:=u,cGet1)},oDlg1,060,008,"@E 999999",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oSBtn1     := SButton():New( 008,116,1,{|| IF(BTNOKEMRG(),( nOpc := 1 , oDlg1:END()),) },oDlg1,,"", )
	oMManGetNew := TMultiGet():New(080,004,{|u|if(Pcount()>0,cMGetNew:=u,cMGetNew)},oDlg1,140,054,,.F.,,,,.T.,,,,,,.T.)
	oMManGetNew:EnableVScroll(.T.)
	oDlg1:Activate(,,,.T.)
	
	If nOpc == 1
		lRet := .F.
	EndIf           
Else
	Return !lRet
EndIf

Return lRet                                                                               
           
/*
Funcao      : BTNOKEMRG
Parametros  : Nenhum
Retorno     : Nenhum   
Objetivos   : Valida Botão Ok do Controle de Acesso ao Repositorio Emergencial.
Autor     	: Jean Victor Rocha
Data     	: 14/01/2014
Obs         : 
*/
*----------------------------*
Static Function BTNOKEMRG()    
*----------------------------*
Local cPort:=7894 //Tratamento para o novo top instalado em umanova porta.
lRet := .T.

If EMPTY(cGet1)
	Alert("Cod. Acesso em Branco!","Grant Thornton Brasil.")
	Return .F.
EndIf   

aArea := GetArea()
		
nCon := TCLink("MSSQL7/GTHD","10.0.30.5",cPort)
If Select("QRY") <> 0
	QRY->(DbCloseArea())
EndIf

cAmbHD := ""
If UPPER(Left(GetEnvServer(),3)) == "GTC"
	cAmbHD := "2"
ElseIf UPPER(Left(GetEnvServer(),3)) == "P11"
	cAmbHD := "1"
EndIf

cTab := "% Z14010 %"
cWhere := ""
cWhere += "% Z14_PASS = '"+AllTrim(cGet1)+"' 
cWhere += " AND Z14_AMB = '"+cAmbHD+"'
cWhere += " AND Z14_EMERG = '"+UPPER(Right(GetEnvServer(),1))+"'
cWhere += " AND Z14_DTINI <= '"+DTOS(DATE())+"'
cWhere += " AND Z14_DTFIM >= '"+DTOS(DATE())+"'
cWhere += " %"

BeginSql Alias 'QRY'
	SELECT TOP 1 Z14_CODIGO
	FROM %exp:cTab%
	WHERE 	%notDel% 
			AND %exp:cWhere%
EndSql

QRY->(DbGoTop())
If QRY->(BOF() .and. EOF())	
	Alert("Cod. Acesso Invalida ou Expirada! favor verificar.")
	lRet := .F.
EndIf                             
QRY->(DbCloseArea())

//Encerra a conexão
TCunLink(nCon)

RestArea(aArea)

Return lRet