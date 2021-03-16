#Include "Totvs.ch" 
/*
Funcao      : 40CTB001() 
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Retorna conta de acorde com o produto.
Autor       : Anderson Arrais	
Data        : 15/03/2017
TDN         : 
Módulo      : Contabilidade.
*/     
*-----------------------*
User Function 40CTB001()
*-----------------------*
Local cConta:= ''

If cEmpAnt $ '40'
	If ALLTRIM(SD2->D2_COD) == '03093'
		cConta := '31102008'
	ElseIf ALLTRIM(SD2->D2_COD) == '03093 EX'
		cConta := '31102014'
	ElseIf ALLTRIM(SD2->D2_COD) == '03093 IC'
		cConta := '31102015'		
	ElseIf ALLTRIM(SD2->D2_COD) == '03093 IRLANDA'
		cConta := '31102016'				
	ElseIf ALLTRIM(SD2->D2_COD) == '03093 SPCC'
		cConta := '31102008'
	ElseIf ALLTRIM(SD2->D2_COD) == '03093(ORG.PUBL)'
		cConta := '31102008'
		
	ElseIf ALLTRIM(SD2->D2_COD) == '07161 (IRNAC)'
		cConta := '31102011'		
	ElseIf ALLTRIM(SD2->D2_COD) == '07161(IRNAC) EX'
		cConta := '31102009'
	ElseIf ALLTRIM(SD2->D2_COD) == '07161(ORG.PUBL)'
		cConta := '31102010'
	ElseIf ALLTRIM(SD2->D2_COD) == '0761 IC'
		cConta := '31102012'
	ElseIf ALLTRIM(SD2->D2_COD) == '0761 IRLANDA'
		cConta := '31102013'

	ElseIf ALLTRIM(SD2->D2_COD) == '08176'
		cConta := '31102010'
	ElseIf ALLTRIM(SD2->D2_COD) == '08176 EX'
		cConta := '31102014'		
	ElseIf ALLTRIM(SD2->D2_COD) == '08176 EXME'
		cConta := '31102017'
	ElseIf ALLTRIM(SD2->D2_COD) == '08176 IC'
		cConta := '31102018'
	ElseIf ALLTRIM(SD2->D2_COD) == '08176 IRLANDA'
		cConta := '31102019'
	ElseIf ALLTRIM(SD2->D2_COD) == '08176(ORG.PUBL)'
		cConta := '31102010'		
	Else
		cConta := '11201001'		
	EndIf
EndIf

Return(cConta)