#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 02/07/02

User Function Lp5101d()        // incluido pelo assistente de conversao do AP5 IDE em 02/07/02

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_REC,_CALIAS,_INDEX,_CHIST,_CHIST2,_CDEBITO")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ LP5620D  ³ Autor ³ Claudio S.Oliveira    ³ Data ³ 02/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Objetivo  ³ Posicionar o Nr. da conta d‚bito no SED  - Arq.Natureza    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ no Lan‡amento Padronizado nr. 562 - Movimenta‡Æo Banc ria  ³±±
±±³ Uso      ³                                     a Pagar                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/    

//JSS 19/11/2014 -  Alterado para solucionar caso 022701
//Inicio-
If cEmpAnt $ "40" 
	If AllTrim(FUNNAME())$ "FINA370"  
		_cDebito:= '21101001'
		Return(_cDebito) 
	EndIf
EndIf		
//Fim
_rec    := recno()
_cAlias := Alias()
_Index  := Indexord()
_cHist := " "       
_cHist2:= " "

_cDebito := " "
// Posiciona SED  p/leitura
DbSelectArea("SED")
dbSetOrder(1)
DbSeek(xfilial()+SE2->E2_NATUREZ)
If !Eof()
    _CDEBITO:=SED->ED_CONTA
    
EndIf

// Volta a posicao anterior
DbSelectArea(_cAlias)
DbSetOrder(_Index)
DbGoto(_rec)
// Substituido pelo assistente de conversao do AP5
// IDE em 02/07/02 ==> __return(_cDebito)
Return(_cDebito)        // incluido pelo assistente de conversao do AP5 IDE em 02/07/02

