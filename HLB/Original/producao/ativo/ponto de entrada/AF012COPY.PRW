#INCLUDE "PROTHEUS.CH"

User Function AF012COPY()

Local lRet  := .F.
Local cMsg0 := ""

cMsg0 := oEmToAnsi("Popula os campos chave [N1_CBASE, N1_ITEM, N1_CHAPA], ") + CRLF
cMsg0 += oEmToAnsi("do fornecedor/loja [N1_FORNEC, N1_LOJA] e") + CRLF
cMsg0 += oEmToAnsi("da nota/serie [N1_NSERIE, N1_NFISCAL] do ") + CRLF
cMsg0 += oEmToAnsi("item posicionado? ") + CRLF

If MsgYesNo(cMsg0)
 lRet  := .T.
Else
 lRet  := .F.
EndIf

Return(lRet)
