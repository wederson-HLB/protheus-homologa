#include "TCBROWSE.CH"
#include "PROTHEUS.CH"
#include "Rwmake.ch"

/*
Funcao      : ZZZF3
Parametros  : cTPREC,cCampo,cCampoVL
Retorno     : xRet
Objetivos   : Pesquisa generica de TABELAS GENERICAS ZZY E ZZZ
Autor       : JAIRO OLIVEIRA
Data        : 09/08/2009
Obs         : 
TDN         : 
RevisЦo     : Renato Rezende
Data/Hora   : 15/05/2013
MСdulo      : GestЦo de Pessoal
Cliente     : 
*/

//#DEFINE K_OK 1

*-------------------------------------------*
USER Function ZZZF3(cTPREC,cCampo,cCampoVL) //cCampo,cNomCampo) 
*-------------------------------------------*
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL oDlgPesUsr
LOCAL nLin       := 1
Local nPos		 := 1
LOCAL oSayUsr
LOCAL nOpca      := 0
LOCAL aBrowUsr   := {}
LOCAL aVetPad    := { {"",""} }
Local aHeader    := {}
LOCAL bRefresh   := { || PLSAPUSER(aBrowUsr,aVetPad,NIL,cTpRec,@aHeader,@aRegs)} // cTpRec - tipo de registro
LOCAL bOK        := { || nLin := otitulo:nAt,nOpca := 1,lOk:=.T.,oDlgPesUsr:End() }
LOCAL bCanc      := { || nOpca := 3,oDlgPesUsr:End() }
LOCAL nReg                                   
Local i := 0
Local aTitulo	:= {}
Local aRegs		:= {}
Local oTitulo        
Local aTam		:= {}
Local aArea		:= GetArea()
LOCAL K_OK		:= 1

DEFAULT cCampoVL	:= ""

DEFAULT cCampo := ""
DEFAULT cTpRec := ""

aBrowUsr         := aClone(aVetPad)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dialogo...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды


IF !sffazheader(@aHeader,cTpRec,@aTam) // NAO TEM A TABELA NO ZZY
	MsgBox("Tabela " + cTPRec + " nЦo existe.","AtenГЦo","ALERT")
	restarea(aArea)
	return(.F.)
EndIf                    


for i := 1 to len(aHeader)
	aadd( atitulo , aHeader[i][1] )
Next


DEFINE MSDIALOG oDlgPesUsr TITLE "Pesquisa de Tab. GenИricas Customizadas" FROM 008.2,005 TO 025,090 OF GetWndDefault()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Browse...                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды


Eval(bRefresh)   
    
    oTitulo := TwBrowse():New( 020,008,316,093,,aTitulo,aTam,oDlgPesUsr,,,,{|| nLin := oTitulo:nAt},,,,,,,,.F.,,.T.,,.F.,,,)
    oTitulo:SetArray(aRegs)
    oTitulo:bLine := { || aRegs[oTitulo:nAt] }
    
    oTitulo:BLDBLCLICK := bOK
    
    nPos := ascan(aregs , {|x| x[1]=ccampoVl})
    
    oTitulo:nAT := IF(nPos=0,1,nPos)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa o Dialogo...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    ACTIVATE MSDIALOG oDlgPesUsr CENTERED ON INIT EnchoiceBar( oDlgPesUsr, {|| nOpca:=1, oDlgPesUsr:End()},;
    {|| nOpca:=0, oDlgPesUsr:End()} , .F. , {} )


If nOpca == K_OK
   If !Empty(cCampo)
      &("M->"+cCampo)    := aRegs[nLin,1]
   Endif
   nOpca := nOpca
   ZZZ->(DBSEEK(XFILIAL("ZZZ")+"01" + AREGS[nLin,1]))

Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Retorno da Funcao...                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
restarea(aArea)
Return(nOpca == K_OK)

USER FUNCTION ZZZF3RET(cCampo)
LOCAL xRet

xRet := &("M->"+cCampo)
RETURN(xRet)
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSAPUSER  Ё Autor Ё Michele Tatagiba   Ё Data Ё 06.05.02 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Pesquisa o usuario na base de dados ....                  Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
*--------------------------------------------------------------------------*
Static Function PLSAPUSER(aBrowUsr,aVetPad,oBrowUsr,cTpRec,aHEADER,aRegs)   
*--------------------------------------------------------------------------*

LOCAL aUsers   := AllUsers(.T.)
LOCAL nCont    := 1
LOCAL nOldLine := 1    
Local xAlias   := "ZZY"
Local nUsado   := 0
Local aCols    := {}
Local lInclui  := .F.
Local i        := 0
Local nTit     := 0
Local nTxt     := 0                                           
LOCAL xFilial  := XFILIAL("ZZY")
LOCAL XCODIGO  := cTPREC


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Limpa resultado...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aBrowUsr := {}                 

//<<<<<<<<<<<<<

                     
dbselectArea("ZZY")
dbClearFilter()
dbSetOrder(1)
dbSeek(xFilial("ZZY")+xAlias+cTpRec)

nUsado:=0
aHeader:={}
Do While !Eof() .And. ZZY->ZZY_FILIAL+xAlias+ZZY->ZZY_CODIGO == xFilial("ZZY")+xAlias+cTpRec

   nUsado++
   AADD(aHeader,{     TRIM(ZZY_TITULO)  ,;
                       ZZY_CAMPO         ,;
                       ZZY_PICTUR        ,;
                       ZZY_TAMANH        ,;
                       ZZY_DECIMA        ,;
                       ''               ,;
                       ''               ,;
                       ZZY_TIPO          ,;
                       ZZY_ARQUIV        ,;
                       ''               ,;
                       ZZY_ETIT          ,;
                       ZZY_OBRIGA            } )

   dbSkip()                 

EndDo


//Montagem do aCols
aCols  := {}
nUsado := 0
nCont  := 0
dbSelectArea("ZZZ")
dbSeek( xFilial+xCodigo )
lInclui := .T.
Do While !Eof() .And. ZZZ->ZZZ_FILIAL+ZZZ->ZZZ_TIP == xFilial+xCodigo
   nCont++
   nTit := 1
   nTxt := 1
   Aadd(aCols,{})
   For i := 1 To Len(aHeader)
       nUsado := nUsado + 1
       If aHeader[i,11] == "S"
          If aHeader[i,8] == "C"
             Aadd( aCOLS[nCont],SubStr(ZZZ->ZZZ_CODIGO,nTit,(aHeader[i,04]) ) )
          ElseIf aHeader[i,8] == "N"
             Aadd( aCOLS[nCont],Val(SubStr(ZZZ->ZZZ_CODIGO,nTit,(aHeader[i,04]))) )
          ElseIf aHeader[i,8] == "D"
             Aadd( aCOLS[nCont],Ctod(SubStr(ZZZ->ZZZ_CODIGO,nTit,(aHeader[i,04]))) )
          EndIf
          nTit += (aHeader[i,04])
       Else
          If aHeader[i,8] == "C"
             Aadd( aCOLS[nCont],SubStr(ZZZ->ZZZ_TXT,nTxt,(aHeader[i,04]))  )
          ElseIf aHeader[i,8] == "N"
             Aadd( aCOLS[nCont],Val(SubStr(ZZZ->ZZZ_TXT,nTxt,(aHeader[i,04])))  )
          ElseIf aHeader[i,8] == "D"
             Aadd( aCOLS[nCont],Ctod(SubStr(ZZZ->ZZZ_TXT,nTxt,(aHeader[i,04]))) )
          EndIf
          nTxt += (aHeader[i,04])
       EndIf
       lInclui := .F.

	       
   Next
   dbSkip()
end                      

If lInclui
   nCont++
   Aadd(aCols,{})
   For i := 1 To Len(aHeader)
       nUsado := nUsado + 1
       If aHeader[i,8] == "C"
          Aadd(aCOLS[nCont],Space(aHeader[i,4]))
       ElseIf aHeader[i,8] == "N"
          Aadd(aCOLS[nCont],0)
       ElseIf aHeader[i,8] == "D"
          Aadd(aCOLS[nCont],Ctod(Space(8)))
       EndIf
   Next
EndIf

  
//aBrowUsr := aClone(aCols)                                               
aRegs := aCLone(aCols)
//<<<<<<<<<<<<<

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(.T.)       

static function sffazheader(aHeader,cTpRec,aTam)
Local nUsado    := 0
Local nX		:= 0
Local xFilial   := xFilial("ZZY")
Local xAlias    := "ZZY"
Local lRet		:= .T.

dbselectArea("ZZY")
dbClearFilter()
dbSetOrder(1)
dbSeek(xFilial("ZZY")+xAlias+cTpRec)

nUsado:=0
aHeader:={}
Do While !Eof() .And. ZZY->ZZY_FILIAL+xAlias+ZZY->ZZY_CODIGO == xFilial("ZZY")+xAlias+cTpRec

   nUsado++
   AADD(aHeader,{     TRIM(ZZY_TITULO)  ,;
                       ZZY_CAMPO         ,;
                       ZZY_PICTUR        ,;
                       ZZY_TAMANH        ,;
                       ZZY_DECIMA        ,;
                       ''               ,;
                       ''               ,;
                       ZZY_TIPO          ,;
                       ZZY_ARQUIV        ,;
                       ''               ,;
                       ZZY_ETIT          ,;
                       ZZY_OBRIGA            } )

   dbSkip()                 
EndDo 

if nUsado > 0
	for nX := 1 to Len(aHeader)
		aadd( aTam , IF(aHeader[Nx][4]<LEN(TRIM(aHeader[nX][1])),len(TRIM(aHeader[nX][1])),aHeader[nX][4] ))
	end                             
else
	lRet := .F.
end
return(lRet)