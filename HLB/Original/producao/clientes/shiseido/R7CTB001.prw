#Include "Totvs.ch" 
/*
Funcao      : R7CTB001 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Retorna conta de acordo com o CFOP e Grupo de Produto (Ticket #12822).
Autor       : César Alves dos Santos	
Data        : 19/09/2017
TDN         : 
Módulo      : Contabilidade.
*/     
*-----------------------*
User Function R7CTB001()
*-----------------------*

SetPrvt("cConta,cCFOP")

cConta:= ''
cCFOP1   := "5910/5911/5949/6910/6911/6949/"         //Necessidade nova, Ticket #12822

If cEmpAnt $ 'R7' .AND. ALLTRIM(SD2->D2_CF) $ cCFOP1

	If ALLTRIM(SD2->D2_GRUPO) == '709'					//Amostras
		cConta := '511136365'
	ElseIf ALLTRIM(SD2->D2_GRUPO) == '716'				//Brindes
		cConta := '511136367'
	ElseIf ALLTRIM(SD2->D2_GRUPO) == '710'				//Expositores
		cConta := '511136369'
	ElseIf ALLTRIM(SD2->D2_GRUPO) == '715'				//Expositores
		cConta := '511136369'
	ElseIf ALLTRIM(SD2->D2_GRUPO) == '711'				//Brindes
		cConta := '511136367'
	ElseIf ALLTRIM(SD2->D2_GRUPO) == '741'				//Outros Mat Promocionais
		cConta := '511136368'
	ElseIf ALLTRIM(SD2->D2_GRUPO) == '705'				//Testadores
		cConta := '511136366'								
	ElseIf ALLTRIM(SD2->D2_GRUPO) == '46'				//Expositores
		cConta := '511136368'								
	ElseIf ALLTRIM(SD2->D2_GRUPO) == '737'				//Amostras
		cConta := '511136365'								
	ElseIf ALLTRIM(SD2->D2_GRUPO) == '708'				//Testadores
		cConta := '511136366'										
	ElseIf ALLTRIM(SD2->D2_GRUPO) == '727'				//Testadores
		cConta := '511136366'												
	ElseIf ALLTRIM(SD2->D2_GRUPO) == '712'				//Outros Mat Promocionais
		cConta := '511136368'				
	ElseIf ALLTRIM(SD2->D2_GRUPO) == '714'				//Outros Mat Promocionais
		cConta := '511136368' 
	Else
		cConta := '511136365'						
	EndIf 
				
Else
	cConta := '511136365'		
EndIf

Return(cConta)