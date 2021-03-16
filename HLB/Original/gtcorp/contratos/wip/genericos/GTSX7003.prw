#Include "Protheus.ch"

/*
Funcao      : GTSX7003
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Colocar vazio nos itens de serviço(divisão e natureza)
			: 
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 01/09/2014    11:28
Módulo      : Genérico
*/

*-------------------------*
User Function GTSX7003()
*-------------------------*
Local cTipoCtr	:= ""
Local h			:= oGetDadosZ29:oBrowse:nAt //Linha atual

	/*Validação do preenchimento da GetDados*/
	nPosGetDiv:=Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_CODDIV"})
	nPosGetDDi:=Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_DESCDI"})
	nPosGetNat:=Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_CODNAT"})
	nPosGetDNa:=Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_DESCNA"})	
	nPosGetTpc:=Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_TPCTR"})

	
	cTipoCtr:=oGetDadosZ29:aCols[h][nPosGetTpc]

    	if nPosGetDiv>0
			oGetDadosZ29:aCols[h][nPosGetDiv]:=SPACE(TamSX3("Z29_CODDIV")[1])
		endif         

    	if nPosGetDDi>0
			oGetDadosZ29:aCols[h][nPosGetDDi]:=SPACE(TamSX3("Z29_DESCDI")[1])
		endif         
		
    	if nPosGetNat>0
			oGetDadosZ29:aCols[h][nPosGetNat]:=SPACE(TamSX3("Z29_CODNAT")[1])
		endif
        
    	if nPosGetDNa>0
			oGetDadosZ29:aCols[h][nPosGetDNa]:=SPACE(TamSX3("Z29_DESCNA")[1])
		endif
		
	oGetDadosZ29:Refresh()
	
Return(cTipoCtr)