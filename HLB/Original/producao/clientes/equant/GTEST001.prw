#Include "Protheus.ch"

//Rotina para importar .csv com as informações do PO
*--------------------*
User Function GTEST001
*--------------------*
Local cGet2		:= space(200)	                                  

    DEFINE DIALOG oDlg TITLE "Parâmetros" FROM 180,180 TO 350,700 PIXEL
        
        // Usando o método Create                //82
		oScr2 := TScrollBox():Create(oDlg,05,01,72,260,.T.,.T.,.T.)

		@ 07,05 SAY "Rotina para importar PO, selecione o arquivo .csv com as informações." SIZE 250,20 OF oScr2 PIXEL
						
		@ 27,05 SAY "Arquivo: " SIZE 100,10 OF oScr2 PIXEL
		oGet2:= TGet():New(25,35,{|u| if(PCount()>0,cGet2:=u,cGet2)}, oScr2,150,05,'',{|o|},,,,,,.T.,,,,,,,,,,'cGet2')
		oTButton2 := TButton():New( 25, 190, "...",oScr2,{||AbreArq(@cGet2,oGet2)},20,10,,,.F.,.T.,.F.,,.F.,,,.F. )		

		oGet2:Disable()
		
		oTButton1 := TButton():New( 56, 110, "Importar",oScr2,{|| IIF(BarAtu(cGet2),oDlg:end(),)},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

    ACTIVATE DIALOG oDlg CENTERED 

Return


/*
Funcao      : AbreArq()
Parametros  : aAllGroup
Retorno     : 
Objetivos   : Função para abrir tela com o selecionador do local onde será salvo
Autor       : Matheus Massarotto
Data/Hora   : 25/09/2013	11:10
*/
*----------------------------------*
Static Function AbreArq(cGet2,oGet2)
*----------------------------------*
Local cTitle:= "Salvar arquivo"
Local cFile := "Arq.csv  | *.CSV"
Local cPastaTo    := ""
Local nDefaultMask := 1
Local cDefaultDir  := "C:\"
Local nOptions:= GETF_LOCALHARD + GETF_LOCALFLOPPY

//Exibe tela para gravar o arquivo.
cGet2 := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

oGet2:Refresh()

Return

Return



/*
Funcao      : BarAtuXK()
Parametros  : 
Retorno     : 
Objetivos   : Função para carregar a barra de processamento
Autor       : Matheus Massarotto
Data/Hora   : 09/10/2013	15:14
*/
*-------------------------*
Static Function BarAtu(cArq)
*-------------------------*
Local lTemMark	:= .F.
Local oDlg2
Local oMeter
Local nMeter	:= 0
Local nTotMeter	:= 0
Local lRet		:= .T.

if empty(cArq)
	Alert("Por favor, selecione um arquivo para importação.")
	Return(.F.)
endif
	
	FT_FUse(cArq)
    nTotMeter:=FT_FLASTREC()
	
	//******************Régua de processamento*******************
	                                           //retira o botão X
	  DEFINE DIALOG oDlg2 TITLE "Importando..." STYLE DS_MODALFRAME FROM 10,10 TO 50,320 PIXEL
	                                          
	    // Montagem da régua
	    nMeter := 0
	    

	    oMeter := TMeter():New(02,02,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotMeter,oDlg2,150,14,,.T.)

	  ACTIVATE DIALOG oDlg2 CENTERED ON INIT(lRet:=Process(cArq,oMeter,oDlg2))
	  
	//***********************************************************

Return(lRet)

*---------------------------*
Static Function Process(cArq,oMeter,oDlg2)
*---------------------------*
Local aCabec	:= {'PO_Ref','Acct','CC','Ent','Req_Type','Categ','Categ_Descr','Supplier','Req_Nbr','Req_Descr','Req_ECY','Req_ECY_Price','Req_ECY_Amount','PO_Cancelled?','PO_ECY','PO_ECY_Price','PO_ECY_Amount','ECY_Billed_Amount','PO_Closed_Reason','PC','Country','Req_Date','PO_Date','Req_Status','Req_Dis','Email Address','Last Name','First Name','Req Catalog Type'}
Local lLayout	:= .T.
Local cCampos	:= ""
Local lOk		:= .T.

//Inicia a régua
oMeter:Set(0)

	FT_FUse(cArq) // Abre o arquivo
	FT_FGOTOP()      // Posiciona no inicio do arquivo
	nPos:=FT_FRECNO()

	While !FT_FEof()
	
   	//Processamento da régua
	nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da régua
	nCurrent+=2 	// atualiza régua
	oMeter:Set(nCurrent) //seta o valor na régua
   		
   		cLinha := FT_FReadln()        // Le a linha
 		aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
		
		//if len(aLinha)<>len(aCabec)
		//	lLayout:=.F.	
		//	exit
		//endif
		
		//Faz a verificação somente se for a primeira linha do arquivo
		if nPos==FT_FRECNO()
			//Verifica se o arquivo tem a estrura de campos correta para importação
			for n1Lin:=1 to len(aCabec)

				cCampos+=alltrim(aCabec[n1Lin])+','

				if alltrim(UPPER(aLinha[n1Lin]))<>alltrim(UPPER(aCabec[n1Lin]))
			    	lLayout:=.F.	
				endif

		 	next

		 	if !lLayout
		 		exit
		 	endif

		 	FT_FSkip() // Proxima linha
		 	cLinha := FT_FReadln()        // Le a linha
 			aLinha := separa(UPPER(cLinha),";")  // Sepera para vetor 
	 	endif

	 	Begin Transaction	

	 		DbSelectArea("ZX0")
	 		ZX0->(DbSetOrder(1))
	 		if ZX0->(DbSeek(xFilial("ZX0")+aLinha[1]))
            	lInc:= .F.    
			else
				lInc:= .T.
			endif

	 		    RecLock("ZX0",lInc)

	 		    	ZX0->ZX0_PO		:= alltrim(aLinha[1])
		 		    ZX0->ZX0_ACC	:= alltrim(aLinha[2])
		 		    ZX0->ZX0_CC		:= alltrim(aLinha[3])
		 		    ZX0->ZX0_ENT	:= alltrim(aLinha[4])
		 		    ZX0->ZX0_TYPE	:= alltrim(aLinha[5])
		 		    ZX0->ZX0_CATE	:= alltrim(aLinha[6])
		 		    ZX0->ZX0_DESCAT	:= alltrim(aLinha[7])
		 		    ZX0->ZX0_SUPPLI	:= alltrim(aLinha[8])
		 		    ZX0->ZX0_REQNBR	:= alltrim(aLinha[9])
		 		    ZX0->ZX0_REQDES	:= alltrim(aLinha[10])
		 		    ZX0->ZX0_REQECY	:= alltrim(aLinha[11])
		 		    ZX0->ZX0_REQPRI	:= val(alltrim(aLinha[12]))
		 		    ZX0->ZX0_REQAMO	:= val(alltrim(aLinha[13]))
		 		    ZX0->ZX0_CANCEL	:= alltrim(aLinha[14])
		 		    ZX0->ZX0_POECY	:= alltrim(aLinha[15])
		 		    ZX0->ZX0_POPRI	:= val(alltrim(aLinha[16]))
		 		    ZX0->ZX0_POAMO	:= val(alltrim(aLinha[17]))
		 		    ZX0->ZX0_BILLAM	:= val(alltrim(aLinha[18]))
		 		    ZX0->ZX0_CLOREA	:= alltrim(aLinha[19])
		 		    ZX0->ZX0_PC		:= alltrim(aLinha[20])
		 		    ZX0->ZX0_COUNTR	:= alltrim(aLinha[21])
		 		    ZX0->ZX0_REQDT	:= CTOD(alltrim(aLinha[22]))
		 		    ZX0->ZX0_PODT	:= CTOD(alltrim(aLinha[23]))
		 		    ZX0->ZX0_REQSTA	:= alltrim(aLinha[24])

	 		    MsUnLock()

	 		
	 	End Transaction
	
		FT_FSkip() // Proxima linha 	
	Enddo
	
	//Retiro a virgula final
	cCampos:= SUBSTR(cCampos,1,len(cCampos)-1 )
	
	if !lLayout
		Alert("Arquivo selecionado não possui a estrutura de campos : "+CRLF+cCampos)
		FT_FUse()
		lOk:=.F.
		//Return
	endif	

//Encerra a barra
oDlg2:end()

Return(lOk)