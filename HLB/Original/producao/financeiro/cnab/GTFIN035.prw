#Include "rwmake.ch"    

/*
Funcao      : GTFIN035
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Retorna dados do banco para CitiBank.
Autor       : 
OBS			: Layout de 240 posições	
Revisão     : Anderson Arrais
Data/Hora   : 18/12/2017
Módulo      : Financeiro.
*/                      

*----------------------------*
 User Function GTFIN035(nOpc)   
*----------------------------*   

Local aArea:= GetArea()
Local cRet       := ""      
Local cContaMV   := ""

//Banco da empresa
If nOpc == 1 
    cRet 		:= StrZero(Val(&(SuperGetMv("MV_P_00112"))[1]),3,0) 
Endif

//Agencia da empresa
If nOpc == 2 
    cRet 		:= STRZERO(VAL(&(SuperGetMv("MV_P_00112"))[2]),5,0)
Endif

//Conta da empresa
If nOpc == 3
	cContaMV 	:= (&(SuperGetMv("MV_P_00112"))[3])
    cRet 		:= STRZERO(VAL(SUBSTR(cContaMV,1,Len(AllTrim(cContaMV))-1)),12)
Endif

//Digito verificado conta
If nOpc == 4
	cContaMV 	:= (&(SuperGetMv("MV_P_00112"))[3])
    cRet 		:= SUBSTR(cContaMV,Len(AllTrim(cContaMV)),1)
Endif

//Conta com digito verificador
If nOpc == 5
    cRet 		:= StrZero(Val(&(SuperGetMv("MV_P_00112"))[3]),12,0) 
Endif

RestArea(aArea)
Return(cRet)