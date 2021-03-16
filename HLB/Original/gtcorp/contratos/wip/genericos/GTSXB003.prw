#Include "Protheus.ch"

/*
Funcao      : GTSXB003
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Colocar vazio nos itens de serviço(divisão e natureza)
			: 
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 08/08/2013    10:28
Módulo      : Genérico
*/

*-------------------------*
User Function GTSXB003()
*-------------------------*
Local aArrayAux	:= {}

	nPosGetTpc:=Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_TPCTR"})

	/*Validação do preenchimento da GetDados*/

	nPosGetDiv:=Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_CODDIV"})
	nPosGetDDi:=Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_DESCDI"})
	nPosGetNat:=Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_CODNAT"})
	nPosGetDNa:=Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_DESCNA"})	
	

	
// 	for h:=1 to len(oGetDadosZ29:aCols)

    	if nPosGetDiv>0
			oGetDadosZ29:aCols[1][nPosGetDiv]:=SPACE(TamSX3("Z29_CODDIV")[1])
		endif         

    	if nPosGetDDi>0
			oGetDadosZ29:aCols[1][nPosGetDDi]:=SPACE(TamSX3("Z29_DESCDI")[1])
		endif         
		
    	if nPosGetNat>0
			oGetDadosZ29:aCols[1][nPosGetNat]:=SPACE(TamSX3("Z29_CODNAT")[1])
		endif
        
    	if nPosGetDNa>0
			oGetDadosZ29:aCols[1][nPosGetDNa]:=SPACE(TamSX3("Z29_DESCNA")[1])
		endif
		
//	next


	
//	aArrayAux:=oGetDadosZ29:aCols[1]
	


//	AADD(oGetDadosZ29:aCols,aArrayAux)
/*
	oGetDadosZ29:aCols:={}
	
	AADD(oGetDadosZ29:aCols,Array(Len(aHeaderZ29)+1))
	
	For nI := 1 To len(aHeaderZ29)
		if Alltrim(aHeaderZ29[nI,2]) == "Z29_ITEM"
			oGetDadosZ29:aCols[len(oGetDadosZ29:aCols)][nI] := "01"
		else
			oGetDadosZ29:aCols[len(oGetDadosZ29:aCols)][nI] := CriaVar(oGetDadosZ29:aHeader[nI][2])
		endif
	Next
	oGetDadosZ29:aCols[len(oGetDadosZ29:aCols)][nI] := .F.
*/    

    //Ajustado para gatilhar o tipo para o primeiro resumo de serviço
	oGetDadosZ29:aCols[1][nPosGetTpc]:=M->Z55_TPCTR
		
	oGetDados:Refresh()
	oGetDadosZ29:Refresh()
	
Return(M->Z55_TPCTR)