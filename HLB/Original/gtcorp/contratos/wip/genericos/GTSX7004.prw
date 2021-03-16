#Include "Protheus.ch"

/*
Funcao      : GTSX7004
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Atualizar a aba de resumo de serviços(Z54) de acordo com a descrição dos serviços(Z29) 
			: 
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 01/09/2014    11:28
Módulo      : Genérico
*/

*-------------------------*
User Function GTSX7004()
*-------------------------*
Local cTipoCtr	:= ""
Local h			:= oGetDadosZ29:oBrowse:nAt //Linha atual
Local nCol		:= 0

	/*Validação do preenchimento da GetDados*/
/*
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
*/	
	
//	 	for l:=1 to len(oGetDados:aCols)
//	 		 for c:=1 to len(oGetDados:aCols[l])-1


//	 		 next
//	 	next


	For h:=1 to len(oGetDadosZ29:aCols)
		
		For l:=1 to len(aHeaderZ29)
			if alltrim(aHeaderZ29[l][2]) $ "Z29_ITEM"
				loop
			endif
			
			
			if h==1
				
				//Localizo se existe o nome da coluna do aheaderZ29 do Z29 (Descrição dos serviços) no aHeader do Z54 (Resumo dos serviços)
				nCol:= Ascan(aHeader,{|x| alltrim(x[2]) = aHeaderZ29[l][2]})
				
				if nCol>0
					oGetDados:aCols[1][nCol]:=oGetDados:aCols[h][l]
				endif
				
			elseif alltrim(aHeaderZ29[l][2]) $ "_CUSTOT/_PRECOL/_PRELSU"
				//Localizo se existe o nome da coluna do aheaderZ29 do Z29 (Descrição dos serviços) no aHeader do Z54 (Resumo dos serviços)
				nCol:= Ascan(aHeader,{|x| alltrim(x[2]) = aHeaderZ29[l][2]})
				
				if nCol>0
					oGetDados:aCols[1][nCol]+=oGetDados:aCols[h][l]
				endif
			endif
		Next
		
	Next
		
	oGetDadosZ29:Refresh()


Return(.T.)


