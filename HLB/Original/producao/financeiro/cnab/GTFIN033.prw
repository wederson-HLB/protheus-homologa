#Include "rwmake.ch"    

/*
Funcao      : GTFIN033
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Retorna dados do banco e convenio para Multipag Bradesco.
Autor       : 
OBS			: Layout de 240 posições contas a pagar Bradesco	
Revisão     : Anderson Arrais
Data/Hora   : 30/10/2017
Módulo      : Financeiro.
*/                      

*----------------------------*
 User Function GTFIN033(nOpc)   
*----------------------------*   

Local aArea:= GetArea()
Local cRet       := ""      
Local cContaMV   := ""

//Banco da empresa
If nOpc == 1 
    cRet 		:= StrZero(Val(&(SuperGetMv("MV_P_00108"))[1]),3,0) 
Endif

//Agencia da empresa
If nOpc == 2 
	cContaMV 	:= (&(SuperGetMv("MV_P_00108"))[2])
    cRet 		:= STRZERO(VAL(SUBSTR(cContaMV,1,Len(AllTrim(cContaMV))-1)),5)
Endif
 
//Digito da Agencia da empresa
If nOpc == 3 
	cContaMV 	:= (&(SuperGetMv("MV_P_00108"))[2])
    cRet 		:= SUBSTR(cContaMV,Len(AllTrim(cContaMV)),1)
Endif

//Conta da empresa
If nOpc == 4
	cContaMV 	:= (&(SuperGetMv("MV_P_00108"))[3])
    cRet 		:= STRZERO(VAL(SUBSTR(cContaMV,1,Len(AllTrim(cContaMV))-1)),12)
Endif

//Digito verificado conta
If nOpc == 5
	cContaMV 	:= (&(SuperGetMv("MV_P_00108"))[3])
    cRet 		:= SUBSTR(cContaMV,Len(AllTrim(cContaMV)),1)
Endif

//Convenio
If nOpc == 6 
    cRet 		:= StrZero(Val(&(SuperGetMv("MV_P_00108"))[4]),6,0) 
Endif

//Conta com digito verificador
If nOpc == 7 
    cRet 		:= StrZero(Val(&(SuperGetMv("MV_P_00108"))[3]),7,0) 
Endif

RestArea(aArea)
Return(cRet)