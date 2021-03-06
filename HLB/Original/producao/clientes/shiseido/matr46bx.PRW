#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATR461Bx  �Autor  �FSW - SP     � Data �                  ���
�������������������������������������������������������������������������͹��
���Desc.     � Relatorio da CAT17 desenvolvido com conceito de T-REPORT   ���
���          � para que os valores das colunas numericas sejam impressos  ���
���          � corretamente.										      ���
�������������������������������������������������������������������������͹��
���Uso       � TOTVS                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������

/* {Protheus.doc} MATR46BX.PRX
@author  Pedro
@since 27/10/2014
@version  P11
@param
@return
@Project
@obs  rotina para extrair as informa��es para a planilha 
*/


User Function MATR46BX()       

	//��������������������������������Ŀ
	//�Seleciona Area atual do sistema �
	//����������������������������������
	Local aSv 	:= GetArea() 
	        
	Private cPerg	 :=	"MTR461"
	Private cArqTMP	 := ""        
	Private oReport 

	Private aMovimentos	:= {} 	// Movimento dos registros a serem exibidos com o novo campo produto
	
	//RRP - 20/03/2015 - Validando se �Ea empresa Shiseido.
	If !(cEmpAnt) $ "R7"
	     MsgInfo("Rotina n�o implementada para essa empresa!","HLB BRASIL")
	     Return
	EndIf
			
	//�������������������������������������������Ŀ
	//� Realiza ajuste nas perguntas do relatorio �
	//���������������������������������������������
	AjustaSX1()	

	//��������������������������������������������������������������Ŀ
	//� Executa relatorio T-REPORT                                   �
	//����������������������������������������������������������������
	
	If !Pergunte(cPerg,.T.)
	   Return
	Endif

	// Chamada para o processamento
	U_R461Imp(.T.)
                        
	
	//������������������������������������������Ŀ
	//� Apaga arquivos temporarios               �
	//��������������������������������������������
	U_xFsCatFim(cArqTMP)		//FsCat17Fim
	
		
	//��������������������������������Ŀ
	//�Restaura area inicial do sistema�
	//����������������������������������
	RestArea(aSv) 

Return     


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �R461Imp   �Autor  �                    � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     �Inicializa o processo de impressao                          ���
�������������������������������������������������������������������������͹��
���Uso       � MATR461B                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������

/* {Protheus.doc} R461Imp.PRX
@author  Pedro
@since 27/10/2014
@version  P11
@param
@return
@Project
@obs  Inicializa o processo de impressao  

*/
User Function R461Imp( lImprApur , dDataI , dDataF )		// oReport)

//�����������������������������������������������������������Ŀ
//�Declaracao de variaveis utilizadas para filtro do relatorio�
//�������������������������������������������������������������
Local aDatas	    :=	If(!Empty(dDataI) .and. !Empty(dDataF), {dDataI,dDataF}, DetDatas(mv_par01,mv_par02,3,1))

Private	lAbortPrint	:=	.F.
Private dDtIni	    :=	aDatas[01]
Private dDtFim	    :=	aDatas[02]
Private aApurMod1   := array(15,5)
Private aApurMod5   := array(19,5)

Private dDtAp5Ini   := 	CTOD("01/01/"+StrZero(Year(dDtIni),4))
Private dDtAp5Fim   :=	CTOD("31/12/"+StrZero(Year(dDtIni),4))
	
//������������������������Ŀ
//�Cria arquivo de trabalho�
//��������������������������
cArqTMP	:=	U_xFSCAT17INI(mv_Par05)					//FSCAT17INI
	
//�������������������������Ŀ
//�Monta arquivo de Trabalho�
//���������������������������
Processa({|lEnd| U_xFS17CAL(cArqTMP,dDtIni,dDtFim,mv_Par07)},"Selecionando os registros... Aguarde !!!")  	//FSCAT17CAL 
	
//��������������������������������������Ŀ
//�Ajusta os dados no Arquivo de Trabalho�
//����������������������������������������
Processa({|lEnd| U_xT17TOT(cArqTMP,aApurMod1,mv_Par07)},"Processando os registros e gerando a planilha !!!")            //FSCAT17TOT
	
//������������������
//�Imprime Apuracao�
//������������������
If lImprApur
	U_xMatr461Ap(cArqTMP,Mv_Par06)
EndIf

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Matr461Ap �Autor  �Rodrigo Aguilar     � Data �  28/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Apuracao                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MATR461B                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������  

/* {Protheus.doc} xMatr461Ap.PRX
@author  Pedro
@since 27/10/2014
@version  P11
@param
@return
@Project
@obs  Processando a rotina e gerando as informa��es

*/
User Function xMatr461Ap(cArqTMP,nApura)

Local aDados		:= {}     
Local nlI,nlY                     
Local nLinha        := 300
Local nColuna       := 1700
Local nCont			:= 0 
Local nCont2		:= 0                                   

Private	aL			:=	{}
Private	lAbortPrint	:=	.F.         

If nApura ==1  
                           
	//�������������������������������������������������������������������������������Ŀ
	//�Chamada para montar e carregar o EXCEL, levando as informa��es para a planilha:�
	//�Contemplando os campos                                                         �
	//�Codigo Produto  + Descricao + Marca                                            �
	//���������������������������������������������������������������������������������
	U_fExpExcel()
	
EndIf 

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATR46BX  �Autor  �FSW                 � Data �  10/22/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Rotina desenvolvida pela fabrica                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������

/* {Protheus.doc} fExpExcel.PRX
@author  Pedro
@since 27/10/2014
@version  P11
@param
@return
@Project
@obs  Exportando os dados para a planilha Excel

*/

User Function fExpExcel()
Local aArea		:= GetArea()                 	// retorna ambiente anterior
Local aStruct   := {}                           // estrutura
Local cDirDocs  :=  GetMV("FS_MATR46X")			//MsDocPath()
Local cPath		:= AllTrim(GetTempPath())
Local nY		:= 0                            // auxiliar do for
Local nX        := 0                            // auxiliar do for
Local cBuffer   := ""                           // recebe as variaveis de valores
Local oExcelApp := Nil                          // recebe planilha do excell
Local nHandle   := 0
Local cArquivo  := CriaTrab(,.F.)+".CSV"        // arquivo
Local xValor    := Nil                          //  valor
Local cAliasUser:= "RCA"
Local aDados	:= {}
LOcal nCont		:= 0
Local nCont2	:= 0
Local cCRLF		:= CHR(13) + CHR(10)
Local cDescProd	:= ""         

//If Empty(cDirDocs)
//	Alert("Informar o caminho no par�metro FS_MATR46X, para a gera��o da planilha EXCEL. ") 
//EndIf
	
									                      
// Carregar os dados para a exportacao para a planilha do Excel-- novo
aDados := aMovimentos

If ApOleClient("MsExcel")
		//If (nHandle := FCreate(cDirDocs + "\"+cArquivo)) > 0
	If (nHandle := FCreate(cPath + "\"+cArquivo)) > 0

		xValor := "C�digo"
		xValor := PadR(xValor,Max(12,Len(xValor) ) )
		cBuffer += ToXlsFormat(xValor)
		cBuffer += ";"

		xValor := "Descri��o"
		xValor := PadR(xValor,Max(30,Len(xValor) ) )
		cBuffer += ToXlsFormat(xValor)
		cBuffer += ";"
		
		xValor := "Marca"
		xValor := PadR(xValor,Max(12,Len(xValor) ) )
		cBuffer += ToXlsFormat(xValor)
		cBuffer += ";"

		xValor := "Total de Base C�lculo"    				//TMP_VAL10
		xValor := PadR(xValor,Max(30,Len(xValor) ) )
		cBuffer += ToXlsFormat(xValor)
		cBuffer += ";"
                  
		xValor := "Total Apura��o Valor"					// TMP_VAL11
		xValor := PadR(xValor,Max(30,Len(xValor) ) )
		cBuffer += ToXlsFormat(xValor)
		cBuffer += ";"

		xValor := "Diferen�a BC Complementar"				// TMP_VAL12
		xValor := PadR(xValor,Max(30,Len(xValor) ) )
		cBuffer += ToXlsFormat(xValor)
		cBuffer += ";"

		xValor := "Diferen�a BC Valor Ressarcido"			// TMP_VAL13
		xValor := PadR(xValor,Max(30,Len(xValor) ) )
		cBuffer += ToXlsFormat(xValor)
		cBuffer += ";"

		xValor := "Valor do Imposto a ser Contemplado"		// TMP_VAL15
		xValor := PadR(xValor,Max(30,Len(xValor) ) )
		cBuffer += ToXlsFormat(xValor)
		cBuffer += ";"

		xValor := "Valor Imposto a ser Ressarcido"			// TMP_VAL16
		xValor := PadR(xValor,Max(30,Len(xValor) ) )
		cBuffer += ToXlsFormat(xValor)
		cBuffer += ";"

		cBuffer += cCRLF
		FWrite(nHandle, cBuffer)
	   
		For nX := 1 To Len(aDados)	 
			cBuffer	:= ""
			For nY := 1 To Len(aDados[1])
				cLinha := If(ValType(aDados[nX][nY]) == 'N', Round(aDados[nX][nY],2), aDados[nX][nY])
						
				cBuffer += ToXlsFormat(cLinha)
				cBuffer += ";"
			Next nY
			cBuffer += cCRLF
			FWrite(nHandle, cBuffer)
		Next nX

       // Parametro FS_MATR46X - tem a finalidade de apontar o local da geracao do arquivo EXCEL.
		FClose(nHandle)
		
		//CpyS2T(cDirDocs + "\" + cArquivo, cPath, .T.)   // DEVE-SE ANALISAR MELHOR POIS APRESENTA ERRO DE ACESSO 
		
		//MSGInfo("Arquivo criado com Sucesso " + cPath+ "\" + cArquivo)   //cDirDocs
		
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cPath + cArquivo)
		oExcelApp:SetVisible(.T.)
	Else
		MsgStop("Erro na criacao do arquivo na estacao local. Contate o administrador do sistema") //"Erro na criacao do arquivo na estacao local. Contate o administrador do sistema"
	EndIf
Else
	MsgStop("Microsoft Excel nao instalado.")	 //"Microsoft Excel nao instalado."
EndIf

RestArea(aArea)

Return




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AjustaSX1 �Autor  �                     � Data �            ���
�������������������������������������������������������������������������͹��
���Desc.     �Ajusta grupo de perguntas                                   ���
�������������������������������������������������������������������������͹��
���Uso       |MATR461B                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/* {Protheus.doc} AjustaSX1.PRX
@author  Pedro
@since 27/10/2014
@version  P11
@param
@return
@Project
@obs  Ajuste no dicionario de dados - SX1 ( pergunta )

*/

Static Function AjustaSX1()

Local aHelpPor :={} 
Local aHelpEng :={} 
Local aHelpSpa :={} 
Local nTamGrp:= Len(SX1->X1_GRUPO)

DbSelectArea("SX1")
DbSetOrder(1)
DbSeek(cPerg)
Do While SX1->X1_GRUPO == cPerg .And. !SX1->(Eof())
	If SX1->X1_ORDEM=="02" .And. SX1->X1_TAMANHO==2
       RecLock("SX1",.F.)
       SX1->X1_TAMANHO := 4
       DbCommit()
       MsUnlock()
    EndIf
    DbSkip()
EndDo
        
//Atualizando pergunta 04 - Modelo - incluir a opcao Modelo 4
If dbSeek(PadR("MTR461",nTamGrp)+"05") 
   If Empty(SX1->X1_DEF02)    
      RecLock("SX1",.F.)
      SX1->X1_DEF02 	:= 'Modelo 4'
      SX1->X1_DEFSPA2 	:= 'Modelo 4'
      SX1->X1_DEFENG2 	:= 'Model 4'
      MsUnLock()
   Endif
Endif
                 
//Atualizando pergunta 06 - Imprime apuracao - incluir a opcao Modelo 5
If dbSeek(PadR("MTR461",nTamGrp)+"06")
   If Empty(SX1->X1_DEF02)    
      RecLock("SX1",.F.)
      SX1->X1_DEF02 	:= 'Modelo 5'
      SX1->X1_DEFSPA2 	:= 'Modelo 5'
      SX1->X1_DEFENG2 	:= 'Model 5'
      MsUnLock()
   Endif
Endif

// mv_par02 - Ano Apuracao
aHelpPor :={}
aHelpEng :={}
aHelpSpa :={}
Aadd( aHelpPor, "Informe o ano de apura��o." )
Aadd( aHelpEng, "Informe o ano de apura��o." )
Aadd( aHelpSpa, "Informe o ano de apura��o." )

U_PUTSX1("MTR461","02","Ano Apuracao","Ano Apuracao","Ano Apuracao","mc_ch2",;
"N",4,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",;
aHelpPor,aHelpEng,aHelpSpa)

// mv_par07 - Processa CDM ?
aHelpPor :={}
aHelpEng :={}
aHelpSpa :={}
Aadd( aHelpPor, "Processa atrav�s da CDM." )
Aadd( aHelpEng, "Processa atrav�s da CDM." )
Aadd( aHelpSpa, "Processa atrav�s da CDM." )

U_PUTSX1("MTR461","07","Processa CDM","Processa CDM","Processa CDM","mc_ch7",;
"N",1,0,0,"C","","","","","mv_par07","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",;
aHelpPor,aHelpEng,aHelpSpa)

// mv_par08 - Operacoes com pauta.?
aHelpPor :={}
aHelpEng :={}
aHelpSpa :={}
Aadd( aHelpPor, "Indique Sim,para que no relat�rio sejam" )
Aadd( aHelpPor, "impresso somente os valores das  ")
Aadd( aHelpPor, "opera��es com pauta nas colunas 10 e 15." )
aHelpEng := aHelpSpa := aHelpPor

U_PUTSX1("MTR461","08","Operac�es com pauta.","Operac�es com pauta.","Operac�es com pauta.","mc_ch8",;
"N",1,0,0,"C","","","","","mv_par08","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",;
aHelpPor,aHelpEng,aHelpSpa)         
      
Return Nil


