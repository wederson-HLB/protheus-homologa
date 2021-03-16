#include "Protheus.ch"

/*
Funcao      : GTGATZ88
Parametros  : Nil
Retorno     : Nil
Objetivos   : Função auxiliar para gatilhar os itens da draft para a proposta.
Autor       : Matheus Massarotto
Data/Hora   : 29/06/2012    14:22
Revisão		:                    
Data/Hora   : 
Módulo      : Gestão de Contratos
*/
*--------------------*
User function GTGATZ88
*--------------------*
Local nSeq	:=1

DbSelectArea("Z85")
DbSetOrder(1)

if DbSeek(xFilial("Z85")+Z86->Z86_NUM)
    //Reinicializa o Acols do Getdados
	oGetDados:aCols:={}
	AADD(oGetDados:aCols,Array(len(aHeader)+1))
	
	While Z85->(!EOF()) .AND. Z85->Z85_NUM==Z86->Z86_NUM
			if nSeq==1    
				For i:=1 to len(aHeader)
														//substitui nome da tabela de Z87 por Z85
					oGetDados:aCols[1][i]:=Z85->&(STRTRAN(aHeader[i][2],"Z87","Z85"))
				Next	

				//.t. ou .f. para o campo deletado
				oGetDados:aCols[len(oGetDados:aCols)][i]:=.F.
			else    
				AADD(oGetDados:aCols,Array(len(aHeader)+1))
			
				For i:=1 to len(aHeader)
														//substitui nome da tabela de Z87 por Z85
					oGetDados:aCols[len(oGetDados:aCols)][i]:=Z85->&(STRTRAN(aHeader[i][2],"Z87","Z85"))
				Next
				//.t. ou .f. para o campo deletado
				oGetDados:aCols[len(oGetDados:aCols)][i]:=.F.
			endif			
			nSeq++
		Z85->(DbSkip())
	EndDo
	//Força atualização da getdados
	oGetDados:ForceRefresh()
endif
Return