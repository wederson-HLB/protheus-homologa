#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 02/07/02

User Function Lp56201d()        // incluido pelo assistente de conversao do AP5 IDE em 02/07/02           

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//? Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//? SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//? identificando as variaveis publicas do sistema utilizadas no codigo ?
//? Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

SetPrvt("_REC,_CALIAS,_INDEX,_CHIST,_CHIST2,_CDEBITO")

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇쿑un눯o    ? LP5620D  ? Autor ? Claudio S.Oliveira    ? Data ? 02/07/02 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇쿚bjetivo  ? Posicionar o Nr. da conta d괷ito no SED  - Arq.Natureza    낢?
굇?          ?                                                            낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙?
굇? Uso      ? no Lan놹mento Padronizado nr. 562 - Movimenta눯o Banc쟲ia  낢?
굇? Uso      ?                                     a Pagar                낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
/*/

_rec    := recno()
_cAlias := Alias()
_Index  := Indexord()
_cHist := " "       
_cHist2:= " "

_cDebito := " "
// Posiciona SED  p/leitura
DbSelectArea("SED")
dbSetOrder(1)
DbSeek(xfilial()+SE5->E5_NATUREZ)

//TLM 20140228 -  Chamado 017474 
If cEmpAnt $ "LW/LX/LY"    
	If Alltrim(SE5->E5_NATUREZ)=="3705" 
		_CDEBITO:="21118004"
	Else 
		If !Eof()
    		_CDEBITO:=SED->ED_CONTA
    	EndIf
	EndIf
Else	
	If !Eof()
    	_CDEBITO:=SED->ED_CONTA
    EndIf	
EndIf

// Volta a posicao anterior
DbSelectArea(_cAlias)
DbSetOrder(_Index)
DbGoto(_rec)
// Substituido pelo assistente de conversao do AP5 IDE em 02/07/02 ==> __return(_cDebito)
Return(_cDebito)        // incluido pelo assistente de conversao do AP5 IDE em 02/07/02

