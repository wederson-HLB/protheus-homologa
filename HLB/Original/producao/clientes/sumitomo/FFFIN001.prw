#include 'totvs.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FFFIN001  ºAutor  ³Eduardo C. Romanini º Data ³  20/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Programa para criação e exportação do arquivo de informaçõesº±±
±±º          ³de contas a receber da Credinfar.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Sumitomo.                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                            


/*
Funcao      : FFFIN001
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Programa para criação e exportação do arquivo de informações de contas a receber da Credinfar
Autor     	: Eduardo C. Romanini	
Data     	: 20/09/11
Obs         : 
TDN         : 
Revisão     : Tiago Luiz Mendonça 
Data/Hora   : 15/03/2012
Módulo      : Financeiro.
*/

*----------------------*
User Function FFFIN001()
*----------------------*
Private cArquivo := ""

//Valida a empresa.
If SM0->M0_CODIGO <> 'FF'
	MsgAlert("Essa rotina é especifica para a Sumitomo.","Atenção")
	Return
EndIf

//Gera e grava o arquivo.
If TelaParam()

	cArquivo := AllTrim(cArquivo)+"INFASSOC.SIC"
	GravaArq()
EndIf	

Return Nil   

/*
Funcao      : TelaParam()
Objetivos   : Exibe a tela de parametros antes da gravação do arquivo.
Autor       : Eduardo C. Romanini
Data/Hora   : 20/09/11 10:30
*/
*-------------------------*
Static Function TelaParam()
*-------------------------*
Local lRet := .F.

Local bOk     := {|| If(!Empty(cArquivo),(lRet:= .T.,oDlg:End()),MsgInfo("Nenhum diretório selecionado.","Atenção"))}
Local bCancel := {|| lRet:=.F.,oDlg:End()}
Local bFileAction := {|| cArquivo := ChooseFile()}; cArquivo := Space(200)

DEFINE MSDIALOG oDlg TITLE "Exportação do arquivo Credinfar" FROM 1,1 To 91,376 OF oMainWnd Pixel
      
	@ 14,4 to 43,185 Label "Escolha o local de gravação do arquivo:" PIXEL
      
	@ 25,12 MsGet oArquivo Var cArquivo Size 150,07 When .F. Pixel Of oDlg
      
	@ 25,162 Button "..." Size 10,10 Pixel Action .t. Of oDlg

	oDlg:aControls[3]:bAction := bFileAction
      
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,) CENTERED


Return lRet      

/*
Funcao      : ChooseFile
Objetivos   : Tela de seleção do local de gravação.
Autor       : Eduardo C. Romanini
Data/Hora   : 22/09/11 16:00
*/
*--------------------------*
Static Function ChooseFile()
*--------------------------*
Local cTitle:= "Local de gravação"
Local cMask := ""
Local cFile := ""
Local nDefaultMask := 0
Local cDefaultDir  := "C:\"
Local nOptions:=  GETF_LOCALHARD+GETF_RETDIRECTORY

Local aArea := GetArea()

cFile := cGetFile(cMask,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

If Empty(cFile)
   Return cArquivo
EndIf

RestArea(aArea)

Return IncSpace(cFile,200,.f.)

/*
Funcao      : GravaArq()
Objetivos   : Realiza a gravação do arquivo.
Autor       : Eduardo C. Romanini
Data/Hora   : 20/09/11 10:35
*/
*------------------------*
Static Function GravaArq()
*------------------------*
Local cFile   := cArquivo
Local cBuffer := ""

Local nHandle := 0

//Carrega o texto que será gravado
Processa({|| cBuffer := GeraTxt()},"Aguarde...","Gerando arquivo...",.T.)
If Empty(cBuffer)
	MsgInfo("Erro ao gerar o arquivo.")
	Return Nil
EndIf

//Verifica se o arquivo já existe.
If File(cFile)
	fErase(cFile)
EndIf

//Cria o arquivo.
nHandle := fCreate(cFile)
If nHandle == -1
	MsgStop('Erro ao criar arquivo. Erro = '+AllTrim(Str(fError(),4)),'Erro')
	fClose(nHandle)
	Return Nil
Endif

//Grava o arquivo.
fWrite(nHandle,cBuffer)

//Fecha o arquivo.
fClose(nHandle)

MsgInfo("Exportação concluída.","Atenção")

Return Nil                                 

/*
Funcao      : GeraTxt()
Objetivos   : Gera as informações que serão gravadas no arquivo
Autor       : Eduardo C. Romanini
Data/Hora   : 20/09/11 10:50
*/
*-----------------------*
Static Function GeraTxt()
*-----------------------*
Local cTexto    := ""
Local cTpCli    := ""
Local cCnpj     := ""
Local cNomCli   := ""
Local cEndCli   := ""
Local cCidCli   := ""
Local cCepCli   := ""
Local cEstCli   := ""
Local cDtIncCli := ""
Local cDtUltCom := ""
Local cVlUltCom := ""
Local cDtMaNf   := ""
Local cVlMaNf   := ""
Local cDtMaAcu  := ""
Local cVlMaAcu  := ""
Local cLimCre   := ""
Local cMedAtr   := ""
Local cDebAtu   := ""
Local cDetVen   := ""
Local cDtComMes := ""
Local cVlComMes := ""
Local cVlVenc1  := ""
Local cVlVenc2  := ""
Local cVlVenc3  := ""
Local cDtIni    := ""
Local cDiFim    := ""

Local nVlVenc1  := 0
Local nVlVenc2  := 0
Local nVlVenc3  := 0
Local nDebVen   := 0
Local nValor    := 0
Local nVlCalc   := 0
Local nMedAtr   := 0
Local nRegua    := 0
Local nVlComMes := 0

Local aMaAcu := {}
Local aDup   := {}

Private cCodCli   := ""

//Cria query com as informações de contas a receber em aberto.
BeginSql Alias 'SQL'
	SELECT A1_CGC,SUM(E1_SALDO) AS [SALDO]
	FROM %table:SE1% SE1
	LEFT JOIN %table:SA1% SA1 ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND SA1.%notDel%
	WHERE SE1.%notDel%
	  AND E1_SALDO > 0
	  AND E1_TIPO = 'NF'
	  AND LEFT(E1_ORIGEM,3) <> 'LOJ'
	  AND LEFT(E1_ORIGEM,3) <> 'FIN'
 	  AND A1_CGC <> ' '
	GROUP BY A1_CGC
	ORDER BY A1_CGC
EndSql

//Validação de retorno da query.
SQL->(DbGoTop())
If SQL->(BOF() .or. EOF())
	SQL->(DbCloseArea())
	MsgInfo("Não existem registros de Contas a Receber em aberto.","Atenção")
	Return ""
EndIf

nRegua := SQL->(LastRec())
ProcRegua(0)

//Looping de gravação dos dados.
While SQL->(!EOF())
    
	IncProc()
	
	SA1->(DbSetOrder(3))
	If SA1->(DbSeek(xFilial("SA1")+SQL->A1_CGC))
		
        nLoop   := 1
		cCodCli := ""

		While SA1->(!EOF() .and. A1_FILIAL+A1_CGC == xFilial("SA1")+SQL->A1_CGC)
        
		    If nLoop == 1
				cTpCli    := SA1->A1_PESSOA
				cCnpj     := AllTrim(SA1->A1_CGC)
		    	cNomCli   := AllTrim(SA1->A1_NOME)
		    	cEndCli   := AllTrim(SA1->A1_END)
		    	cCidCli   := AllTrim(SA1->A1_MUN)
		    	cCepCli   := AllTrim(SA1->A1_CEP)
				cEstCli   := AllTrim(SA1->A1_EST)
					
		        If !Empty(SA1->A1_USERLGI)
					cStr     := SA1->A1_USERLGI
					cNovaStr := Embaralha(cStr, 1)
					nDias    := Load2in4(SubStr(cNovaStr,16))
					dData    := CtoD("01/01/96","DDMMYY") + nDias
					dData    := DtoS(dData)				
						
		            If DtoS(SA1->A1_PRICOM) < dData
						dData := DtoS(SA1->A1_PRICOM)            
		            EndIf 
				Else	        
		            dData := DtoS(SA1->A1_PRICOM)
		        EndIf
			
				cDtIncCli:= Substr(dData,5,2)+Left(dData,4)
					
				cLimCre   := AllTrim(Str(Int(SA1->A1_LC)))
				cCodCli := "% ('"+SA1->A1_COD+SA1->A1_LOJA+"'"
			Else
				//Verifica se é cliente duplicado.
				cCodCli += ",'"+SA1->A1_COD+SA1->A1_LOJA+"'"			
			EndIf
			
			nLoop++            

			SA1->(DbSkip())
		EndDo

		cCodCli += ") %"
    Else
		SQL->(DbSkip())
		Loop		
	EndIf

	//Informações da Associada
	cTexto += PadR("038",3) //Codigo
	cTexto += PadR("01",2) //Segmento (00:Farmaceutico, 01:Veterinario, 02:Cosmetico)
	
	//CNPJ/CPF do Cliente	
	If cTpCli == "J" //Pessoa Juridica
		cTexto += "G"                       //Tipo
		cTexto += PadR(Substr(cCnpj,1,8),8) //Numero Cliente
		cTexto += PadR(Substr(cCnpj,9,4),4) //Complemento
		cTexto += PadR(Right(cCnpj,2),2)    //Controle
	Else //Pessoa Fisica
		cTexto += PadR(Left(cCnpj,1),1)     //Tipo
		cTexto += PadR(Substr(cCnpj,2,9),8) //Numero Cliente
		cTexto += Replicate("0",4)          //Complemento
		cTexto += PadR(Right(cCnpj,2),2)    //Controle
	EndIf

	//Cadastro do Cliente
	cTexto += PadR(cNomCli  ,40) //Razao Social
	cTexto += PadR(cEndCli  ,30) //Endereço
	cTexto += PadR(cCidCli  ,20) //Cidade
	cTexto += PadR(cCepCli  ,08) //CEP
	cTexto += PadR(cEstCli  ,02) //Estado
	cTexto += PadR(cDtIncCli,06) //Data de cadastro do cliente.

	//Ultima Compra	
	BeginSql Alias 'ULTCOM'
		SELECT TOP 1 MAX(E1_EMISSAO) AS [DTULT],SUM(E1_VALOR) AS [VALOR]
		FROM %table:SE1%
		WHERE %notDel%
		  AND E1_CLIENTE+E1_LOJA IN %exp:cCodCli%
		  AND LEFT(E1_ORIGEM,3) <> 'LOJ'
		  AND E1_ORIGEM <> 'FINA074'
		GROUP BY E1_NUM,E1_EMISSAO
		ORDER BY E1_EMISSAO DESC
	EndSql	

	ULTCOM->(DbGoTop())
	If ULTCOM->(!BOF() .and. !EOF())
		cDtUltCom := Substr(ULTCOM->DTULT,5,2)+Left(ULTCOM->DTULT,4)
		cVlUltCom := AllTrim(Str(Int(ULTCOM->VALOR)))
	EndIf	

	ULTCOM->(DbCloseArea())
	
	cTexto += PadR(cDtUltCom,6)    //Data
	cTexto += StrZero(Val(cVlUltCom),9) //Valor

	//Maior Nota Fiscal dos ultimos 12 meses
	cDtMaNf := ""
	cVlMaNf := ""
	
	BeginSql Alias 'MAXNF'
		SELECT TOP 1 MAX(F2_VALFAT) AS [VALOR],F2_DOC,F2_EMISSAO
		FROM %table:SF2%
		WHERE %notDel%
		  AND F2_CLIENTE+F2_LOJA IN %exp:cCodCli%
		  AND DATEDIFF(MONTH,F2_EMISSAO, GETDATE()) <= 12
		GROUP BY F2_DOC,F2_EMISSAO
		ORDER BY [VALOR] DESC
	EndSql	

	If MAXNF->(!BOF() .and. !EOF())	
		cDtMaNf := Substr(MAXNF->F2_EMISSAO,5,2)+Left(MAXNF->F2_EMISSAO,4)
		cVlMaNf := AllTrim(Str(Int(MAXNF->VALOR)))
	EndIf

	MAXNF->(DbCloseArea())
    
	//Caso não haja Nf nos ultimos 12 meses, pega o maior valor de todas as Nfs.
	If Empty(cDtMaNf) .and. Empty(cVlMaNf)

		BeginSql Alias 'MAXNF'
			SELECT TOP 1 MAX(F2_VALFAT) AS [VALOR],F2_DOC,F2_EMISSAO
			FROM %table:SF2%
			WHERE %notDel%
			  AND F2_CLIENTE+F2_LOJA IN %exp:cCodCli%
			GROUP BY F2_DOC,F2_EMISSAO
			ORDER BY [VALOR] DESC
		EndSql

		If MAXNF->(!BOF() .and. !EOF())	
			cDtMaNf := Substr(MAXNF->F2_EMISSAO,5,2)+Left(MAXNF->F2_EMISSAO,4)
			cVlMaNf := AllTrim(Str(Int(MAXNF->VALOR)))
		EndIf
	
		MAXNF->(DbCloseArea())
	EndIf	
	
	cTexto += PadR(cDtMaNf,6)    //Data
	cTexto += StrZero(Val(cVlMaNf),9) //Valor

	//Maior Acumulo
	aMaAcu   := RetMaAcu()
	cDtMaAcu := aMaAcu[1]
	cVlMaAcu := aMaAcu[2]

	If Val(cVlMaAcu) == 0
		cDtMaAcu := DtoS(MonthSub(dDatabase,12))
	   	cDtMaAcu := Substr(cDtMaAcu,5,2)+Left(cDtMaAcu,4)

		cVlMaAcu := AllTrim(Str(Int(SQL->SALDO)))
	EndIf	

	cTexto += PadR(cDtMaAcu,6)         //Data
	cTexto += StrZero(Val(cVlMaAcu),9) //Valor

	//Limite de Credito
	cTexto += StrZero(Val(cLimCre),9)

	//Dias de Atraso dos ultimos 12 meses
	BeginSql Alias 'MEDATR'
		SELECT E1_VALOR,E1_BAIXA,E1_VENCREA,DATEDIFF(DAY,E1_VENCREA,E1_BAIXA) as [ATRASO]
		FROM %table:SE1%
		WHERE %notDel%
		  AND E1_BAIXA > E1_VENCREA
		  AND E1_TIPO = 'NF'
		  AND E1_VENCREA < %exp:dDataBase%
		  AND LEFT(E1_ORIGEM,3) <> 'LOJ'
		  AND E1_ORIGEM <> 'FINA074'
		  AND DATEDIFF(MONTH,E1_EMISSAO, GETDATE()) <= 12
		  AND E1_CLIENTE+E1_LOJA IN %exp:cCodCli%
	EndSql	
		 
	nValor  := 0
	nVlCalc := 0
    nMedAtr := 0

	MEDATR->(DbGoTop())
	If MEDATR->(!BOF() .and. !EOF())	
		While MEDATR->(!EOF())
            
			nValor  += MEDATR->E1_VALOR
			nVlCalc += MEDATR->E1_VALOR * MEDATR->ATRASO

			MEDATR->(DbSkip())		
		EndDo        
		
		nMedAtr := nVlCalc/nValor
		cMedAtr := AllTrim(Str(Int(nMedAtr)))
	EndIf	

	MEDATR->(DbCloseArea())

	cTexto += StrZero(Val(cMedAtr),3) //Dias médios de atraso.

	//Debitos
	BeginSql Alias 'DEBVEN'
		SELECT E1_SALDO,E1_VENCREA,E1_VALOR
		FROM %table:SE1%
		WHERE %notDel%
		  AND E1_SALDO > 0
		  AND E1_TIPO = 'NF'
		  AND E1_VENCREA < %exp:dDataBase%
		  AND E1_CLIENTE+E1_LOJA IN %exp:cCodCli%
		  AND LEFT(E1_ORIGEM,3) <> 'LOJ'
		  AND E1_ORIGEM <> 'FINA074'
	EndSql

	nVlVenc1 := 0
	nVlVenc2 := 0
	nVlVenc3 := 0
	nDebVen  := 0
	 
	DEBVEN->(DbGoTop())
	If DEBVEN->(!BOF() .and. !EOF())	
		While DEBVEN->(!EOF())
    
			//Vencidos  de 1 a 10 dias
			cDtIni := DtoS(DaySum(StoD(DEBVEN->E1_VENCREA),1))
			cDtFim := DtoS(DaySum(StoD(DEBVEN->E1_VENCREA),10))

			If DtoS(dDatabase) >= cDtIni .and.  DtoS(dDatabase) <= cDtFim
				nVlVenc1 += DEBVEN->E1_SALDO
			EndIf
			
			//Vencidos de 11 a 30 dias
			cDtIni := DtoS(DaySum(StoD(DEBVEN->E1_VENCREA),11))
			cDtFim := DtoS(DaySum(StoD(DEBVEN->E1_VENCREA),30))

			If DtoS(dDatabase) >= cDtIni .and.  DtoS(dDatabase) <= cDtFim
				nVlVenc2 += DEBVEN->E1_SALDO
			EndIf
			
			//Vencidos a partir de 31 dias
			cDtIni := DtoS(DaySum(StoD(DEBVEN->E1_VENCREA),31))

			If DtoS(dDatabase) >= cDtIni
				nVlVenc3 += DEBVEN->E1_SALDO
			EndIf

			nDebVen += DEBVEN->E1_SALDO
	
			DEBVEN->(DbSkip())    	
        EndDo
	EndIf		
			
	DEBVEN->(DbCloseArea())
	
	//Debito
	cDebAtu := AllTrim(Str(Int(SQL->SALDO)))
	cDebVen := AllTrim(Str(Int(nDebVen)))

	cTexto += StrZero(Val(cDebAtu),9) //Atual
	cTexto += StrZero(Val(cDebVen),9) //Vencido
	
	//Compra Mes
	cVlComMes := ""
	
	cDtComMes := DtoS(MonthSub(dDatabase,1))
	cDtComMes := Substr(cDtComMes,5,2)+Left(cDtComMes,4)

	cDtIni := Right(cDtComMes,4)+Left(cDtComMes,2)+"01"
	cDtFim := Right(cDtComMes,4)+Left(cDtComMes,2)+"31"
	
	BeginSql Alias 'COMMES'
		SELECT E1_CLIENTE,E1_LOJA,SUM(E1_VALOR) AS [VALOR]
		FROM %table:SE1%
		WHERE %notDel%
		  AND E1_TIPO = 'NF'
		  AND E1_EMISSAO >= %exp:cDtIni%
		  AND E1_EMISSAO <= %exp:cDtFim%
		  AND E1_CLIENTE+E1_LOJA IN %exp:cCodCli%
		  AND LEFT(E1_ORIGEM,3) <> 'LOJ'
		  AND E1_ORIGEM <> 'FINA074'
		GROUP BY E1_CLIENTE,E1_LOJA
	EndSql
    
    nVlComMes := 0
  
	COMMES->(DbGoTop())
	If COMMES->(!BOF() .and. !EOF())	
        While  COMMES->(!EOF())

			nVlComMes += COMMES->VALOR

		    COMMES->(DbSkip())
		EndDo

	EndIf		
   
	cVlComMes := AllTrim(Str(Int(nVlComMes)))
			
	COMMES->(DbCloseArea())

	cTexto += PadR(cDtComMes,6)    //Data
	cTexto += StrZero(Val(cVlComMes),9) //Valor
	
	//Vencidos
	cVlVenc1 := AllTrim(Str(Int(nVlVenc1)))
	cVlVenc2 := AllTrim(Str(Int(nVlVenc2)))
	cVlVenc3 := AllTrim(Str(Int(nVlVenc3)))

	cTexto += StrZero(Val(cVlVenc1),9) //1º ao 10º dia
	cTexto += StrZero(Val(cVlVenc2),9) //11º ao 30º dia
	cTexto += StrZero(Val(cVlVenc3),9) //Acima do 30º dia

	cTexto += CRLF
							
	SQL->(DbSkip())
EndDo

//Fecha a tabela temporária do SQL.
SQL->(DbCloseArea())

Return cTexto

/*
Funcao      : RetMaAcu()
Objetivos   : Retorna as informações de maior acumulo.
Autor       : Eduardo C. Romanini
Data/Hora   : 21/09/11 15:30
*/
*------------------------*
Static Function RetMaAcu()
*------------------------*
Local cArq     := ""
Local cInd     := ""
Local cDtMaAcu := ""
Local cMaAcu   := ""
Local cDtAux   := ""

Local nAcumulo := 0
Local nMaAcu   := 0 
               
Local aRet     := {"",0}
Local aAcumulo := {}
Local aStruct  := {{"DTMOV"  ,"C",8,0},;
                   {"CRED"   ,"N",20,2},;
                   {"DEB"    ,"N",20,2}}
                  
AADD(aStruct,{"FLAG","L",1,0})

cArq := CriaTrab(aStruct,.T.)
DbUseArea(.T.,__LocalDriver,cArq,"TMP",.T.,.F.)

cInd := CriaTrab(,.F.)
IndRegua("TMP",cInd,"DTMOV")

BeginSql Alias 'QRY'
	SELECT E1_EMISSAO,E5_DATA,E1_VALOR,E5_VALOR
	FROM %table:SE1% SE1
	LEFT JOIN %table:SE5% SE5 ON E5_NUMERO = E1_NUM AND E5_PARCELA = E1_PARCELA
	                    AND E5_CLIENTE = E1_CLIENTE AND E5_LOJA = E1_LOJA AND SE5.%notDel%
	WHERE SE1.%notDel%
	  AND E1_TIPO = 'NF'
      AND DATEDIFF(MONTH,E1_EMISSAO, GETDATE()) <= 12
	  AND E1_CLIENTE+E1_LOJA IN %exp:cCodCli%
	ORDER BY E1_EMISSAO
EndSql

QRY->(DbGoTop())
If QRY->(!BOF() .and. !EOF())
	While QRY->(!EOF())
        
		//Preenche o credito
        TMP->(DbSetOrder(1))
        If TMP->(DbSeek(QRY->E1_EMISSAO))
        	TMP->(RecLock("TMP",.F.))
        	TMP->CRED  := TMP->CRED + QRY->E1_VALOR        	
			TMP->(MSUnlock())
        Else	
        	TMP->(DbAppend())
        	TMP->DTMOV := QRY->E1_EMISSAO
        	TMP->CRED  := QRY->E1_VALOR
        EndIf

		//Preenche o debito
		If !Empty(QRY->E5_DATA)        
	        TMP->(DbSetOrder(1))
	        If TMP->(DbSeek(QRY->E5_DATA))
	        	TMP->(RecLock("TMP",.F.))
	        	TMP->DEB  := TMP->DEB + QRY->E5_VALOR        	
				TMP->(MSUnlock())
	        Else	
	        	TMP->(DbAppend())
	        	TMP->DTMOV := QRY->E5_DATA
				TMP->DEB   := QRY->E5_VALOR
			EndIf
		EndIf
		QRY->(DbSkip())	 
	EndDo
EndIf

//Verifica o acumulo.
TMP->(DbGoTop())
TMP->(DbSetOrder(1))
While TMP->(!EOF())
		
	If TMP->CRED > 0
		nAcumulo += TMP->CRED
		cDtAux := TMP->DTMOV 
	EndIf
	
	If TMP->DEB > 0
		
		If nAcumulo > 0
			aAdd(aAcumulo,{cDtAux,nAcumulo})
		EndIf
	
		nAcumulo -= TMP->DEB
	EndIf

	TMP->(DbSkip())
EndDo

For nI:=1 To Len(aAcumulo)
	If aAcumulo[nI][2] > nMaAcu
    	cDtMaAcu := aAcumulo[nI][1]
		nMaAcu   := aAcumulo[nI][2]
	EndIf
Next

//Tratamento, caso a ultima nota seja o maior acumulo
If nAcumulo > nMaAcu
	cDtMaAcu := cDtAux
	nMaAcu   := nAcumulo
EndIf

cDtMaAcu := Substr(cDtMaAcu,5,2)+Left(cDtMaAcu,4)
cMaAcu := AllTrim(Str(Int(nMaAcu)))

aRet := {cDtMaAcu,cMaAcu}

//Fecha as tabelas temporárias.
QRY->(DbCloseArea())
TMP->(DbCloseArea())
FErase(cArq)
FErase(cInd)

Return aRet