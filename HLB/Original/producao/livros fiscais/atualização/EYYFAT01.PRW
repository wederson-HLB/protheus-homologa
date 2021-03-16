#INCLUDE "rwmake.ch"

/*
Funcao      : EYYFAT01 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Vinculo de TES x Empresas  
Autor       : 
Data/Hora   : 11/12/02
Obs         : Validação
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 18/07/2012
Obs         :
Módulo      : Livros Fiscais.
Cliente     : Todas	
*/

*-------------------------*
  User Function EYYFAT01()
*-------------------------*
//hfpok 

local _cTES   
local cConhec  :=""    
local cFuncName:=FUNNAME() 

_cTES:=&(READVAR())     //Para pegar o valor do campo independente da rotina que fez a chamada

if cFuncName == "MATA103"
   cConhec:=BuscaCols("D1_CONHEC")
endIf

IF _cTES == "71C" .AND. SA1->A1_EST == "SP"     // VENDA A NAO CONTRIBUINTE
//	MSGINFO("A tes 71C não pode ser usada para clientes de SP.")
	RETURN .F.
ENDIF

dbSelectArea("SZ2")
dbSetOrder(3)
//if dbseek(xfilial("SZ2")+SM0->M0_CODIGO+SM0->M0_CODFIL+_CTES) //RRP - 20/10/2014 - Ajuste. Chamado 022054.
if dbseek(xfilial("SZ2")+cEmpAnt+cFilAnt+_CTES)	
	if(!empty(Alltrim(cConhec))) 
    	
    	DbSelectArea("SF4")
    	DbSetOrder(1)
    	if(DbSeek(xFilial("SF4")+_CTES))
    		if SF4->F4_AGREG $ 'B/b/C/c' 
    			RETURN .T.
    		else
    			alert("TES informada não é de importação.")
    			RETURN .F.
    		endif
    	else    	   
    		RETURN .T.    	
    	endif
	else
	   return .T.
	endif             

endIf

Help("",1,"Comp. TES x EMP")

Return .F.
