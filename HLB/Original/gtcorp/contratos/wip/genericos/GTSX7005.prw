#Include "Protheus.ch"

/*
Funcao      : GTSX7005
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Gatilhar o sócio ou gerente da capa da proposta para a descrição dos serviços
			: 
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 07/10/2014    17:36
Módulo      : Genérico
*/

*----------------------------*
User Function GTSX7005(cTipo)
*----------------------------*
Local cRet:= ""

DEFAULT cTipo:=""

	if Upper(alltrim(cTipo)) == "SOCIO"
		nPosGet:=Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_SOCIO"})
		nPosGetDes:=Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_NOMESO"})
	
	    //Ajustado para gatilhar o tipo para o primeiro resumo de serviço
		oGetDadosZ29:aCols[1][nPosGet]:=M->Z55_SOCIO
		oGetDadosZ29:aCols[1][nPosGetDes]:=U_GTSXB002(M->Z55_SOCIO)

		cRet:= M->Z55_SOCIO
		
	elseif Upper(alltrim(cTipo)) == "GERENTE"
		nPosGet:=Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_GERENT"})
		nPosGetDes:=Ascan(aHeaderZ29,{|x| alltrim(x[2]) = "Z29_NOMEGE"})
	
	    //Ajustado para gatilhar o tipo para o primeiro resumo de serviço
		oGetDadosZ29:aCols[1][nPosGet]:=M->Z55_GERENT
		oGetDadosZ29:aCols[1][nPosGetDes]:=U_GTSXB002(M->Z55_GERENT)
		
		cRet:=M->Z55_GERENT
		
	endif
	
		
	oGetDados:Refresh()
	oGetDadosZ29:Refresh()
	
Return(cRet)