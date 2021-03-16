#include "rwmake.ch"

/*
Funcao      : VALPROPV
Parametros  : Nenhum
Retorno     : _cProduto
Objetivos   : Consiste a digitação de Produtos idênticos no mesmo P.Venda, para acrescentar icms caso seja utilizado a tabela 007 com a condição de pagto ***
Autor       : Ronaldo Manoel Silva Data
Data        : 17/08/2001
Obs         : 
TDN         : 
Revisão     : Matheus Massarotto
Data/Hora   : 30/10/2012
Módulo      : Faturamento. 
Cliente     : Shiseido
*/

*----------------------*
User Function VALPROPV()
*----------------------*

Local _cProduto               
Local _nPosProduto
Local _cLocal
Local _nPosLocal,_nPosPrc,_nPosQtd,_nPosVal                                                

_nPosQtd     := aScan(aHeader,{|_cCpo| Alltrim(_cCpo[2]) == "C6_QTDVEN"})
_nPosVal     := aScan(aHeader,{|_cCpo| Alltrim(_cCpo[2]) == "C6_VALOR"})
_nPosPrc     := aScan(aHeader,{|_cCpo| Alltrim(_cCpo[2]) == "C6_PRCVEN"})
_nPosProduto := aScan(aHeader,{|_cCpo| Alltrim(_cCpo[2]) == "C6_PRODUTO"})
_nPosLocal   := aScan(aHeader,{|_cCpo| Alltrim(_cCpo[2]) == "C6_LOCAL"})
_nDescricao  := aScan(aHeader,{|_cCpo| Alltrim(_cCpo[2]) == "C6_DESCRI"})

_cProduto    := ACols[n,_nPosProduto]
_cLocal      := ACols[n,_nPosLocal]            

If M->C5_TABELA $ "007" .AND. M->C5_CONDPAG="***"    //Wederson L. Santana 07/03/05 --> Acrescenta ICMS no valor unitário                                          
  
   SB2->(DbSetOrder(1))
   SB2->(DbSeek(xFilial("SB2")+ACols[n,_nPosProduto]+ACols[n,_nPosLocal]))                                                            
   
   SB1->(DbSetOrder(1))
   SB1->(DbSeek(xFilial("SB1")+ACols[n,_nPosProduto]))                                                            

   aCols[n,_nPosPrc] := NoRound(SB2->B2_CM1/0.88)
   
   aCols[n,_nPosVal] := aCols[n,_nPosQtd]*aCols[n,_nPosPrc]
   
Endif   

Return(_cProduto)