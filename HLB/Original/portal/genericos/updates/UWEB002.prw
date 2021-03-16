/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �UWEB002   �Autor  �Eduardo C. Romanini � Data �  16/01/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Update para ajuste dos ambientes das empresas cadastradas no���
���          �portal GT.                                                  ���
�������������������������������������������������������������������������͹��
���Uso       � GT                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*----------------------*
User Function UWEB002(o)
*----------------------*
If FindFunction("AVUpdate01")
   oUpd           := AVUpdate01():New()
   oUpd:aChamados := { {"FAT",{|o| UWEB002(o)}} }
   oUpd:Init(o)
Else
   MsgStop("Esse ambiente n�o est� preparado para executar este update. Favor entrar em contato com o helpdesk Average.")
EndIf
Return .T.     

*------------------------*
Static Function UWEB002(o)
*------------------------*
Local cCodEmp := ""
Local cCodFil := ""
Local cAmb    := ""

Local nCon := 0 

Local aArea := {}

//Carrega a estrutura da tabela que ser� atualizada.
o:TableStruct("ZW1",{"ZW1_CODIGO","ZW1_CODFIL","ZW1_AMB"},1)

/////////////////////
//Ajuste na tabelas//
/////////////////////
ZW1->(DbSetOrder(1))
ZW1->(DbGoTop())
While ZW1->(!EOF())
    
	cCodEmp := AllTrim(ZW1->ZW1_CODIGO)
	cCodFil := AllTrim(ZW1->ZW1_CODFIL)
	cAmb    := AllTrim(ZW1->ZW1_AMB)
    
	aArea := SaveOrd({"ZW1"})

	//Realiza a conex�o com o banco de dados GTHD.
	nCon := TCLink("MSSQL7/GTHD","10.0.30.5")

	//Inicio da Query
	BeginSql Alias 'QRY'
    	SELECT Z04_CODIGO,Z04_CODFIL,Z04_NOMECO,Z04_CNPJ,Z04_AMB,Z04_NOME,Z04_NOMFIL
	    FROM Z04010
		WHERE %notDel%
		  AND Z04_CODIGO = %exp:cCodEmp%
		  AND Z04_CODFIL = %exp:cCodFil%
	EndSql

	If QRY->(!BOF() .and. !EOF())
		
		If Upper(AllTrim(cAmb)) <> Upper(AllTrim(QRY->Z04_AMB))
			o:TableData  ("ZW1",{cCodEmp,cCodFil,AllTrim(QRY->Z04_AMB)})
		EndIf
	EndIf

	QRY->(DbCloseArea())

	//Encerra a conex�o
	TCunLink(nCon)

	RestOrd(aArea)

	ZW1->(DbSkip())
EndDo

Return Nil
   