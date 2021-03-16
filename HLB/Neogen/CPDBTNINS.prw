#include "protheus.ch"

User Function CPDBTNINS()

Local cCons := Alltrim(ParamIXB[1])

Local lRet := .T.
alert("ok")
// Se a consulta padrão que estiver sendo executada for a SA1 ou SB1, não apresenta o botão de inclusão.

If cCons $ "SF4|SM2|SM4|SED"    

ApMsgAlert("Usuário: "+ __cUserID + " abriu a consulta: " + cAlias + " e o botão Incluir não vai ser apresentado.")

    lRet := .F.

EndIf

Return lRet