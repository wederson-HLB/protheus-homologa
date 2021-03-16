#include "Protheus.ch"

/*
Funcao      : GTGATZ74
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função auxiliar para gatilhar os itens da draft para a proposta.
Autor       : Matheus Massarotto
Data/Hora   : 19/09/2012    14:22
Revisão		:                    
Data/Hora   : 
Módulo      : Gestão de Contratos
*/
*--------------------*
User function GTGATZ74
*--------------------*
Local nSeq	:=1

DbSelectArea("Z73")
DbSetOrder(1)

if DbSeek(xFilial("Z73")+Z74->Z74_NUM)
    //Reinicializa o Acols do Getdados
	oGetDados:aCols:={}
	AADD(oGetDados:aCols,Array(len(aHeader)+1))
	
	While Z73->(!EOF()) .AND. Z73->Z73_NUM==Z74->Z74_NUM
			if nSeq==1    
				For i:=1 to len(aHeader)
														//substitui nome da tabela de Z78 por Z73
					oGetDados:aCols[1][i]:=Z73->&(STRTRAN(aHeader[i][2],"Z78","Z73"))
				Next	

				//.t. ou .f. para o campo deletado
				oGetDados:aCols[len(oGetDados:aCols)][i]:=.F.
			else    
				AADD(oGetDados:aCols,Array(len(aHeader)+1))
			
				For i:=1 to len(aHeader)
														//substitui nome da tabela de Z78 por Z73
					oGetDados:aCols[len(oGetDados:aCols)][i]:=Z73->&(STRTRAN(aHeader[i][2],"Z78","Z73"))
				Next
				//.t. ou .f. para o campo deletado
				oGetDados:aCols[len(oGetDados:aCols)][i]:=.F.
			endif			
			nSeq++
		Z73->(DbSkip())
	EndDo
	//Força atualização da getdados
	oGetDados:ForceRefresh()
endif
Return