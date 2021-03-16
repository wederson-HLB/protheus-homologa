#include 'totvs.ch'

/*
Classe      : GTIntLog
Descrição   : Objeto de log de integrações de arquivos
Autor       : Eduardo C. Romanini
Data        : 19/06/2013
*/                   
*-------------*
Class GTIntLog
*-------------* 
Data lGravado

Method New() CONSTRUCTOR
Method GravaLog()

EndClass

/*
Metodo      : New
Classe      : GTIntLog
Descrição   : Contrutor da classe
Autor       : Eduardo C. Romanini
Data        : 19/06/2013
*/ 
*----------------------------------------------------------------*
Method New(cNomeArq,cContArq,cRotina,cLog,aDetInt) Class GTIntLog
*----------------------------------------------------------------*

::lGravado := Self:GravaLog(cNomeArq,cContArq,cRotina,cLog,aDetInt)

Return Self

/*
Metodo      : GravaLog
Classe      : GTIntNfServ
Descrição   : Contrutor da classe
Autor       : Eduardo C. Romanini
Data        : 06/06/2013
*/ 
*---------------------------------------------------------------------*
Method GravaLog(cNomeArq,cContArq,cRotina,cLog,aDetInt) Class GTIntLog
*---------------------------------------------------------------------*
Local cId := ""
Local nI   := 0

//Valida os parâmetros
If Empty(cNomeArq) .or.;
   Empty(cContArq) .or.;
   Empty(cRotina)  .or.;
   Empty(cLog)     .or.;
   Len(aDetInt) == 0 .or.;
   Len(aDetInt[1]) <> 4
	
	Return .F.   
   
EndIf

cId := GetSXeNum("Z59","Z59_ID")

For nI:=1 To Len(aDetInt)
	
	//Realiza a gravação
	Z59->(RecLock("Z59",.T.))

	Z59->Z59_FILIAL := xFilial("Z59")
	Z59->Z59_ID     := cId
	Z59->Z59_DATA   := dDataBase
	Z59->Z59_HORA   := Time()
	Z59->Z59_USER   := cUserName
	Z59->Z59_NOMARQ := cNomeArq
	Z59->Z59_CONARQ := cContArq
	Z59->Z59_ROTINA := cRotina
	Z59->Z59_LOG    := cLog


	Z59->Z59_SEQUEN := StrZero(nI,3)
	Z59->Z59_TABELA := aDetInt[nI][1]
	Z59->Z59_ORDEM  := aDetInt[nI][2]
	Z59->Z59_CHAVE  := aDetInt[nI][3]
	Z59->Z59_TIPO   := aDetInt[nI][4]

	Z59->(MsUnlock())

Next

Z59->(ConfirmSX8())

Return .T.