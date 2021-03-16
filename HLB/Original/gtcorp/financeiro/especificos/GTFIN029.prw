#Include "rwmake.ch"    

/*
Funcao      : GTFIN029
Parametros  : nOpc
Retorno     : cRet
Objetivos   : Tratamento de instrução bancaria para boleto
Autor       : Anderson Arrais
TDN         : 
OBS			: 	
Data/Hora   : 08/12/2016
Módulo      : Financeiro.
*/                      

*----------------------------*
 User Function GTFIN029(nOpc)   
*----------------------------*   
Local aRet      := {}      
Local cMv931	:= ""
Local aMv931 	:= ""
Local cMv932    := ""
Local cMv933    := ""
Local cMv934    := ""

Private cInt1		:= "Após vencimento cobrar multa de "
Private cInt2		:= "Mora diaria de "
Private cInt3		:= "Título sejeito a protesto 15 dias após o vencimento"
Private cInt4		:= "Título sejeito a protesto 30 dias após o vencimento"
Private cInt5		:= "Não receber após o vencimento"
Private cInt6		:= "Título sejeito a protesto 15 dias após o vencimento"

If GETNEWPAR("MV_P_00093","N") == "N"
	Return(aRet)
EndIf

cMv931	:= &(SuperGetMv("MV_P_00093"))[1]
aMv931 	:= SEPARA(cMv931,"/")
cMv932  := &(SuperGetMv("MV_P_00093"))[2]//Informa valor?
cMv933  := &(SuperGetMv("MV_P_00093"))[3]//Taxa multa  
cMv934  := &(SuperGetMv("MV_P_00093"))[4]//Taxa juros mora 

For i:=1 to len(aMv931)
    If &(SuperGetMv("MV_P_00093"))[2] == "S" .And. "cInt"+aMv931[i] == "cInt1"
		nMultJu := nOpc*(val(cMv933)/100)
		AADD(aRet,&("cInt"+aMv931[i])+"R$ "+AllTrim(Transform((nMultJu),"@E 99,999.99")))
		
    ElseIf &(SuperGetMv("MV_P_00093"))[2] == "S" .And. "cInt"+aMv931[i] == "cInt2"
		nMultJu := nOpc*(val(cMv934)/100)
		AADD(aRet,&("cInt"+aMv931[i])+"R$ "+AllTrim(Transform((nMultJu/30),"@E 99,999.99")))
	
	Else
		If &(SuperGetMv("MV_P_00093"))[2] == "N" .And. "cInt"+aMv931[i] == "cInt1"
			AADD(aRet,&("cInt"+aMv931[i])+" "+AllTrim(cMv933)+"%")
   		ElseIf &(SuperGetMv("MV_P_00093"))[2] == "N" .And. "cInt"+aMv931[i] == "cInt2"
			AADD(aRet,&("cInt"+aMv931[i])+" "+cValToChar(VAL(cMv934)/30)+"%")
		Else
	    	AADD(aRet,&("cInt"+aMv931[i]))
	 	EndIf
    EndIf
Next i

Return(aRet)