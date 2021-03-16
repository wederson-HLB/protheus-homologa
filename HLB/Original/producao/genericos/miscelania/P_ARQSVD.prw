#Include "Protheus.ch"
#INCLUDE "Directry.ch"                   

/*
Funcao      : P_ARQSVD
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : FunÁ„o para manipulaÁ„o de arquivos do servidor (RootPath) 
Autor     	: Matheus Massaroto
Data     	: 13/06/11 
Obs         : A partir da vers„o 11 e a atualizaÁ„o da build em 12/11/2012 a funÁ„o aScanX foi alterada, proporcionando erros nesta rotina.
			: A alteraÁ„o se deu em - ASCANX(< xDestino >,< bSeek >,[ nInicio ]) - ao setar o nInicio ele retornava o n˙mero total atÈ aquela posiÁ„o que continha o item.
			: exemplo: Caso eu tenha no aDirectory 4 pastas(equivalentes a letra D) e um arquivo(equivalente a vazio), o arquivo na posiÁ„o 3
			:												antes      agora
			:	aScanX(aDirectory,{ |X,Y| X[5] == "D"},1) retorna 1    retorna 1
			:	aScanX(aDirectory,{ |X,Y| X[5] == "D"},2) retorna 1    retorna 2
			:	aScanX(aDirectory,{ |X,Y| X[5] == "D"},3) retorna 2    retorna 4
			:	aScanX(aDirectory,{ |X,Y| X[5] == "D"},4) retorna 1    retorna 4
			:	aScanX(aDirectory,{ |X,Y| X[5] == "D"},5) retorna 1    retorna 5
			:
			: Portanto foi necess·rio alterar a lÛgica tratada a funÁ„o aScanx -- MSM - feito em 30/11/2012

TDN         : 
Revis„o     : Tiago Luiz MendonÁa 
Data/Hora   : 14/03/2012
MÛdulo      : Generico.
*/

*-------------------------*
 User Function P_ARQSVD()
*-------------------------*

Processa({|| Carrega()},"Lendo itens do servidor...")	

Return

Static Function Carrega()

Local nCont:=1 
Local nPos:=1
Local nPos1:=1
Local nIII:=1 
Local nIII1:=1

Local nContBarra:=1

Local oButton

Private cBmp1 := "FOLDER5" //imagem de pasta fechada
Private cBmp3 := "FOLDER6" //imagem de pasta aberta
Private cBmp2 := "PMSDOC"  //imagem de arquivo     

Private cBmpDbf := "BMPCPO" //imagem para Dbf , tabelinha
Private cBmpEmp := "RESPONSA " //imagem para sigamat, 2 bonequinhos
Private cBmpIni	:= "ENGRENAGEM" //imagem para ini , engrenagem

Private cCadastro := "Arquivos Servidor"
Private oDlg
Private oDBTree

Private nAux:=1

ProcRegua(0)

aDirectory := DIRECTORY("\*.*","D")
                                                 //240,500
DEFINE MSDIALOG oDlg TITLE cCadastro FROM 0,0 TO 490,700 PIXEL

oDBTree := dbTree():New(10,10,240,240,oDlg,,,.T.)

oDBTree:SetScroll(1,.T.)  // Habilita a barra de rolagem horizontal
oDBTree:SetScroll(2,.T.) // Habilita a barra de rolagem vertical  


oDBTree:AddTree("Server"+Space(35),.T.,cBmp1,cBmp3,,,"Server|1.0"+Space(50))

//oDBTree:BeginUpdate()

//While aScanX(aDirectory,{ |X,Y| X[5] == "D"},nPos) <> 0
While aScanX(aDirectory,{ |X,Y| X[5] == "D"},nAux) <> 0
	nContBarra++
	IncProc("Processando: "+cvaltochar(nContBarra))


//nPos+=aScanX(aDirectory,{ |X,Y| X[5] == "D"},nPos)
nPos:=aScanX(aDirectory,{ |X,Y| X[5] == "D"},nAux)

nAux+=1+(nPos-nAux)

//nPosi:=nPos-1
nPosi:=nPos

	if aDirectory[nPosi][5]=='D'       

		if alltrim(aDirectory[nPosi][F_NAME])=='.' .OR. alltrim(aDirectory[nPosi][F_NAME])=='..'
			loop
		endif                   
		
		//*** ValidaÁ„o exigida, sÛ exibir pastas "BKP/SYSTEM/PATCH"
		if !(UPPER(aDirectory[nPosi][1]) $ "BKP/CERTS/SYSTEM/PATCH/RDMAKE2")
			loop
		endif
		oDBTree:AddTree(aDirectory[nPosi][1],.T.,cBmp1,cBmp3,,,"\"+aDirectory[nPosi][1]+"|"+cvaltochar(nCont)+"."+cvaltochar(nIII))
		
		//2 faixa
		aDirInt1:={}
		aDirInt1:= DIRECTORY("\"+aDirectory[nPosi][1]+"\*.*","D")
		nPos1:=1
		nAux1:=1
		//while aScanX(aDirInt1,{ |X,Y| X[5] == "D"},nPos1) <> 0
		while aScanX(aDirInt1,{ |X,Y| X[5] == "D"},nAux1) <> 0

		//nPos1+=aScanX(aDirInt1,{ |X,Y| X[5] == "D"},nPos1)	            
		nPos1:=aScanX(aDirInt1,{ |X,Y| X[5] == "D"},nAux1)
	    nAux1+=1+(nPos1-nAux1)
	    
	    //nPos1i:=nPos1-1
	    nPos1i:=nPos1
			if aDirInt1[nPos1i][5]=='D' 
			
				if !(alltrim(aDirInt1[nPos1i][F_NAME])=='.' .OR. alltrim(aDirInt1[nPos1i][F_NAME])=='..')
					
				//carrega as tabelas
				oDBTree:AddTree(aDirInt1[nPos1i][1],.T.,cBmp1,cBmp3,,,"\"+aDirectory[nPosi][1]+"\"+aDirInt1[nPos1i][1]+"|"+cvaltochar(nCont)+"."+cvaltochar(nIII)+"."+cvaltochar(nIII1))
				
				
				VerifiPasta("\"+aDirectory[nPosi][1]+"\"+aDirInt1[nPos1i][1],3,cvaltochar(nCont)+"."+cvaltochar(nIII)+"."+cvaltochar(nIII1),"\"+aDirectory[nPosi][1]+"\"+aDirInt1[nPos1i][1],4,1)
				
				oDBTree:EndTree()                                                         
				
				nIII1++
				endif
				
			endif
			//oDBTree:AddTreeItem(aDirInt1[j][F_NAME],cBmp2,,cvaltochar(nCont+1)+"."+cvaltochar(j))		
		
		enddo
        //carrega os itens das pastas
        nPos1_2:=1
        nAux2:=1
        //while aScanX(aDirInt1,{ |X,Y| X[5] <> "D"},nPos1_2) <> 0
        while aScanX(aDirInt1,{ |X,Y| X[5] <> "D"},nAux2) <> 0
			//nPos1_2+=aScanX(aDirInt1,{ |X,Y| X[5] <> "D"},nPos1_2)
	    	//nPos1i_2:=nPos1_2-1
	    	nPos1_2:=aScanX(aDirInt1,{ |X,Y| X[5] <> "D"},nAux2)
	    	nAux2+=1+(nPos1_2-nAux2)
	    	nPos1i_2:=nPos1_2
				if aDirInt1[nPos1i_2][5]<>'D' 
				                
					oDBTree:AddTreeItem(aDirInt1[nPos1i_2][1],IIF(".INI" $ UPPER(aDirInt1[nPos1i_2][1]),cBmpIni,IIF(".DBF" $ UPPER(aDirInt1[nPos1i_2][1]),cBmpDbf,IIF("SIGAMAT" $ UPPER(aDirInt1[nPos1i_2][1]),cBmpEmp,cBmp2))),,"\"+aDirectory[nPosi][1]+"\"+aDirInt1[nPos1i_2][1]+"|"+cvaltochar(nCont)+"."+cvaltochar(nIII)+"."+cvaltochar(nIII1))
					//oDBTree:AddTreeItem(aDirInt1[nPos1i_2][1],cBmp2,,"\"+aDirectory[nPosi][1]+"\"+aDirInt1[nPos1i_2][1]+"|"+cvaltochar(nCont)+"."+cvaltochar(nIII)+"."+cvaltochar(nIII1))
					nIII1++
				endif
        enddo
		
		oDBTree:EndTree()
		
	endif


  nIII++
Enddo

//carrega os itens das pastas
  nPos1_2:=1
  nAux3:=1
  //while aScanX(aDirectory,{ |X,Y| X[5] <> "D"},nPos1_2) <> 0
  while aScanX(aDirectory,{ |X,Y| X[5] <> "D"},nAux3) <> 0
	//nPos1_2+=aScanX(aDirectory,{ |X,Y| X[5] <> "D"},nPos1_2)	            
	//nPos1i_2:=nPos1_2-1
	nPos1_2:=aScanX(aDirectory,{ |X,Y| X[5] <> "D"},nAux3)
	nAux3+=1+(nPos1_2-nAux3)
	nPos1i_2:=nPos1_2
	
	if aDirectory[nPos1i_2][5]<>'D'         
		oDBTree:AddTreeItem(aDirectory[nPos1i_2][1],IIF(".INI" $ UPPER(aDirectory[nPos1i_2][1]),cBmpIni,IIF(".DBF" $ UPPER(aDirectory[nPos1i_2][1]),cBmpDbf,IIF("SIGAMAT" $ UPPER(aDirectory[nPos1i_2][1]),cBmpEmp,cBmp2))),,"\"+aDirectory[nPos1i_2][1]+"|"+cvaltochar(nCont)+"."+cvaltochar(nIII)+"."+cvaltochar(nIII1))
		nIII1++
	endif
  enddo


oDBTree:EndTree()

	
//oDBTree:EndUpdate()
	
oButton:=tButton():New(10,245,'Copiar p/ Servidor',oDlg,{||ProcServ(oDBTree:GetCargo()) },100,20,,,,.T.)
oButton:=tButton():New(40,245,'Copiar p/ Local',oDlg,{||ProcLoc(oDBTree:GetCargo())},100,20,,,,.T.)
oButton:=tButton():New(70,245,'Copiar Local p/ Servidor',oDlg,{|| ProLocServ(oDBTree:GetCargo()) },100,20,,,,.T.)
oButton:=tButton():New(100,245,'Excluir Item',oDlg,{||ProDelItem(oDBTree:GetCargo())},100,20,,,,.T.)
oButton:=tButton():New(130,245,'Renomear Arquivo',oDlg,{||RenameArq(oDBTree:GetCargo())},100,20,,,,.T.)
oButton:=tButton():New(160,245,'Criar Pasta',oDlg,{||CriaPasta(oDBTree:GetCargo())},100,20,,,,.T.)
oButton:=tButton():New(190,245,'Excluir Pasta',oDlg,{||ExcluiPasta(oDBTree:GetCargo())},100,20,,,,.T.)
oButton:=tButton():New(220,245,'Sair',oDlg,{||oDlg:end()},100,20,,,,.T.)                               


ACTIVATE MSDIALOG oDlg CENTER

Return


Static Function VerifiPasta(cDirAux,nPosicao,cContI,cDirOri,nPos4,nContJ)
                           
Local aDirAux:= {}
Local nPosAnt:=0


aDirAux:= DIRECTORY(cDirAux+"\*.*","D")            
if nPosicao<=len(aDirAux)
	//nInd:=aScanX(aDirAux,{ |X,Y| X[5] == "D"},nPosicao)
	nInd:=(aScanX(aDirAux,{ |X,Y| X[5] == "D"},nPosicao)-nPosicao)+1
else 
	nInd:=0
endif
	If nInd>0
       
		nInd+=nPosicao-1
		
		//if alltrim(aDirAux[nInd][F_NAME])=='.' .OR. alltrim(aDirAux[nInd][F_NAME])=='..'
		//	VerifiPasta(cDirAux,nPosicao+1,3)	
		//endif
		
		oDBTree:AddTree(aDirAux[nInd][1],.T.,cBmp1,cBmp3,,,cDirAux+"\"+aDirAux[nInd][1]+"|"+cContI+"."+cvaltochar(nContJ))

			aDirAux1:={}
			aDirAux1:= DIRECTORY(cDirAux+"\"+aDirAux[nInd][1]+"\*.*","D")				
		    
		    //Adicionado: aScanX(aDirAux1,{ |X,Y| X[5] == "D"})>0 no if pois o aScanx dava erro de invalid metod
			    if aScanX(aDirAux1,{ |X,Y| X[5] == "D"})>0 .AND. aScanX(aDirAux1,{ |X,Y| X[5] == "D"},3)>0
	
					//VerifiPasta(cDirAux+"\"+aDirAux[nInd][1]+"\"+aDirAux1[3][1],3,nContI+1)
					if cDirOri==cDirAux                
	                	nPos4:=nInd
					endif
	
					VerifiPasta(cDirAux+"\"+aDirAux[nInd][1],3,cContI+"."+cvaltochar(nContJ),cDirOri,nPos4,1)			
					//oDBTree:EndTree()
	
				else
					//VerifiPasta(substr(cDirAux,1,RAT("\",cDirAux)-1),3,nContI+1)			
					//nPos4+=1	
				        nPos1_2:=1
				        nAux4:=1
				        //while aScanX(aDirAux1,{ |X,Y| X[5] <> "D"},nPos1_2) <> 0
				        while aScanX(aDirAux1,{ |X,Y| X[5] <> "D"},nAux4) <> 0
							//nPos1_2+=aScanX(aDirAux1,{ |X,Y| X[5] <> "D"},nPos1_2)
					    	//nPos1i_2:=nPos1_2-1
							nPos1_2:=aScanX(aDirAux1,{ |X,Y| X[5] <> "D"},nAux4)
					    	nAux4+=1+(nPos1_2-nAux4)
					    	nPos1i_2:=nPos1_2
								if aDirAux1[nPos1i_2][5]<>'D'         
									nContJ++
									oDBTree:AddTreeItem(aDirAux1[nPos1i_2][1],IIF(".INI" $ UPPER(aDirAux1[nPos1i_2][1]),cBmpIni,IIF(".DBF" $ UPPER(aDirAux1[nPos1i_2][1]),cBmpDbf,IIF("SIGAMAT" $ UPPER(aDirAux1[nPos1i_2][1]),cBmpEmp,cBmp2))),,cDirAux+"\"+aDirAux[nInd][1]+"\"+aDirAux1[nPos1i_2][1]+"|"+cContI+"."+cvaltochar(nContJ))
									
								endif
				        enddo
				
					oDBTree:EndTree()
					if cDirOri==cDirAux                
	                	nPos4:=nInd
					endif
	
					VerifiPasta(cDirAux,nInd+1,cContI,cDirOri,nPos4,nContJ+1)			
					
	
				endif

	else

		if aScanX(aDirAux,{ |X,Y| X[5] <> "D"}) <> 0
				nPos1_2:=1
				nAux5:=1
				while aScanX(aDirAux,{ |X,Y| X[5] <> "D"},nAux5) <> 0
					//nPos1_2+=aScanX(aDirAux,{ |X,Y| X[5] <> "D"},nPos1_2)	            
				   	//nPos1i_2:=nPos1_2-1
				   	nPos1_2:=aScanX(aDirAux,{ |X,Y| X[5] <> "D"},nAux5)
				   	nAux5+=1+(nPos1_2-nAux5)
				   	nPos1i_2:=nPos1_2
						if aDirAux[nPos1i_2][5]<>'D'         
							nContJ++
							oDBTree:AddTreeItem(aDirAux[nPos1i_2][1],IIF(".INI" $ UPPER(aDirAux[nPos1i_2][1]),cBmpIni,IIF(".DBF" $ UPPER(aDirAux[nPos1i_2][1]),cBmpDbf,IIF("SIGAMAT" $ UPPER(aDirAux[nPos1i_2][1]),cBmpEmp,cBmp2))),,cDirAux+"\"+aDirAux[nPos1i_2][1]+"|"+cContI+"."+cvaltochar(nContJ))
								
						endif
				enddo
		endif
	
			if cDirOri<>cDirAux
				nPos4+=nPosAnt+1
				
					
				oDBTree:EndTree()
				VerifiPasta(substr(cDirAux,1,RAT("\",cDirAux)-1),nPos4,substr(cContI,1,RAT(".",cContI)-1),cDirOri,nPos4,nContJ-1)
			endif	
		
		

	endif

Return

/****************************************
//Copia Item para do servidor p/ Servidor
*****************************************/  

Static Function ProcServ(cCargo)

Local cDirNome:=substr(cCargo,1,RAT("|",cCargo)-1)
Local cNome:=substr(cDirNome,RAT("\",cDirNome)+1,len(cDirNome)-RAT("\",cDirNome))

Private cDir,cPath
//verfica se esta na pasta server
if alltrim(cDirNome)=='Server'
	cDirNome:="\"
endif

cDir:=cGetFile ( , 'Escolha o local',,, .F., GETF_RETDIRECTORY,.T.)

If Empty(cDir)
	Return
EndIf

if "SYSTEM" $ UPPER(cDir)
	Alert("N„o È possivel copiar arquivos para pasta SYSTEM!")
	return
endif

nHdl := fOpen(iif(alltrim(cDir)=="\","",cDir)+"\"+cNome)

If nHdl > 0
     ALERT("Arquivo "+AllTrim(cNome)+" ja existe no diretorio informado.")
     fClose(nHdl)
     Return     
EndIf

fClose(nHdl)


cPath:= AllTrim(GetTempPath()) 

if CPYS2T ( alltrim(cDirNome) , cPath , .T. )
	if CpyT2S( alltrim(cPath)+alltrim(cNome), cDir, .T.)
		msginfo("Copiado com SUCESSO!!")
	    oDlg:end()
	    
	else
		Alert("N„o foi possivel copiar!")
	endif
else
	Alert("N„o foi possivel copiar!")
endif


Return()      

/**********************************
//Copia Item do servidor para Local
***********************************/  

Static Function ProcLoc(cCargo)

Local cDirNome:=substr(cCargo,1,RAT("|",cCargo)-1)
Local cNome:=substr(cDirNome,RAT("\",cDirNome)+1,len(cDirNome)-RAT("\",cDirNome))
Private cDir,cPath


cDir:=cGetFile ( , 'Escolha o local',,, .F., GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY,.F.)

If Empty(cDir)
	Return
EndIf

nHdl := fOpen(cDir+"\"+cNome)

If nHdl > 0
     ALERT("Arquivo "+AllTrim(cNome)+" ja existe no diretorio informado.")
     fClose(nHdl)
     Return     
EndIf

fClose(nHdl)

if CPYS2T ( alltrim(cDirNome) , cDir , .T. )
		msginfo("Copiado com SUCESSO!!")
else
	Alert("N„o foi possivel copiar!")
endif

Return          
         
/**********************************
//Deleta um item
***********************************/

Static Function ProDelItem(cCargo)

Local cDirNome:=substr(cCargo,1,RAT("|",cCargo)-1)
Local cNome:=substr(cDirNome,RAT("\",cDirNome)+1,len(cDirNome)-RAT("\",cDirNome))
Private cDir,cPath

if "SYSTEM" $ UPPER(cDirNome)
	Alert("N„o È possivel manipular arquivos de SYSTEM!")
	return	
endif

if Aviso("Atencao","Deseja mesmo excluir o arquivo: "+alltrim(cNome)+"?",{"Ok","Cancelar"},2)==2
	return()	
endif

if FERASE(cDirNome)==0
	msginfo("Arquivo excluido com sucesso!")
	//oDlg:end()
	
 oDBTree:BeginUpdate( )  
 	if oDBTree:TreeSeek(cCargo)
 		oDBTree:DelItem()
 	endif
 oDBTree:EndUpdate( )  	
else
	Alert("N„o foi possivel excluir o arquivo!")
endif

Return  

/*******************************
//Copia item local para servidor
********************************/

Static Function ProLocServ(cCargo)

Local cDirNome:=alltrim(substr(cCargo,1,RAT("|",cCargo)-1))
Local cNome:=substr(cDirNome,RAT("\",cDirNome)+1,len(cDirNome)-RAT("\",cDirNome))

Private cDir,cPath

//if "SYSTEM" $ UPPER(cDirNome)
//	Alert("N„o È possivel copiar arquivos para pasta SYSTEM!")
//	return
//endif 

cDir:=cGetFile ('arquivos | *.* ' , 'Escolha o arquivo',,, .T., GETF_LOCALHARD+GETF_LOCALFLOPPY,.F.)

If Empty(cDir)
	Return
EndIf

//verfica se esta na pasta server
if alltrim(cDirNome)=='Server'
	cDirNome:="\"
endif 

if !EXISTDIR(cDirNome) 
	Alert("Diretorio n„o existe: "+cDirNome)
	return()
endif
     
cNomeArq:=Substr(cDir,RAT("\",cDir)+1,len(cDir)-RAT("\",cDir))

nHdl := fOpen(iif(alltrim(cDirNome)=="\","",cDirNome)+"\"+cNomeArq)

If nHdl > 0
     ALERT("Arquivo "+AllTrim(cNomeArq)+" ja existe no diretorio informado.")
     fClose(nHdl)
     Return     
EndIf

fClose(nHdl)

	if CpyT2S( alltrim(cDir),cDirNome, .T.)
		msginfo("Copiado com SUCESSO!!")
		//oDlg:end()

 oDBTree:BeginUpdate( )  
 	if oDBTree:TreeSeek(cCargo)	 
 		oDBTree:AddItem(cNomeArq,iif(alltrim(cDirNome)=="\","",cDirNome)+"\"+cNomeArq+"|",IIF(".INI" $ UPPER(cNomeArq),cBmpIni,IIF(".DBF" $ UPPER(cNomeArq),cBmpDbf,IIF("SIGAMAT" $ UPPER(cNomeArq),cBmpEmp,cBmp2))))	
 
 	endif
 oDBTree:EndUpdate( ) 

	else
		Alert("N„o foi possivel copiar!")
	endif

Return

/******************************* 
//FunÁ„o para criar pasta
********************************/
Static Function CriaPasta(cCargo)

Local cDirNome:=alltrim(substr(cCargo,1,RAT("|",cCargo)-1))
Local cNome:=substr(cDirNome,RAT("\",cDirNome)+1,len(cDirNome)-RAT("\",cDirNome))

Local cExtAnt:=""

Local cGet1	 := Space(25)
Local oGet1  

//verfica se esta na pasta server
if alltrim(cDirNome)=='Server'
	cDirNome:=""
endif 

if "SYSTEM" $ UPPER(cDirNome)
	Alert("N„o È possivel criar pastas em SYSTEM!")
	return
endif 

if RAT(".",cDirNome) > 0
	cExtAnt:=alltrim(substr(cDirNome,RAT(".",cDirNome),len(cDirNome)-RAT(".",cDirNome)+1))
endif

if len(cExtAnt)>=4
	Alert("Selecione somente o local!")
	return
endif


// Variaveis Private da Funcao
Private oDlgPast				// Dialog Principal


DEFINE MSDIALOG oDlgPast TITLE "Nova Pasta" FROM C(201),C(254) TO C(342),C(586) PIXEL

	// Cria as Groups do Sistema
	@ C(002),C(004) TO C(065),C(161) LABEL "Pasta" PIXEL OF oDlgPast

	// Cria Componentes Padroes do Sistema
	@ C(021),C(040) MsGet oGet1 Var cGet1 Size C(109),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPast
	@ C(023),C(016) Say "Nome:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgPast
	@ C(045),C(033) Button "Criar" action(PastaAuxi(cDirNome,cGet1,cCargo)) Size C(037),C(012) PIXEL OF oDlgPast
	@ C(045),C(096) Button "Cancelar" action(oDlgPast:end()) Size C(037),C(012) PIXEL OF oDlgPast


ACTIVATE MSDIALOG oDlgPast CENTERED 


Return 
//FunÁ„o auxiliar na criaÁ„o da pasta
Static Function PastaAuxi(cDirNome,cGet1,cCargo)

if empty(cGet1)	
	Alert("Nome da pasta n„o informado!")
	return
endif

if EXISTDIR(cDirNome+"\"+cGet1)
	Alert("DiretÛrio j· existe no local especificado!")
	return
endif  

if MontaDIR(cDirNome+"\"+cGet1)
	msginfo("Pasta criada com sucesso!")
	oDlgPast:end()
	//oDlg:end()     
	
	 oDBTree:BeginUpdate( )  
	 	if oDBTree:TreeSeek(cCargo)	 
	 		oDBTree:AddItem(cGet1,iif(alltrim(cDirNome)=="\","",cDirNome)+"\"+cGet1+"|",cBmp1,cBmp3)	
	 	endif
	 oDBTree:EndUpdate( )
else
    Alert("N„o foi possÌvel criar pasta!")	
endif

Return                           

/******************************* 
//FunÁ„o para excluir pastas
********************************/

Static Function ExcluiPasta(cCargo)
Local cDirNome:=alltrim(substr(cCargo,1,RAT("|",cCargo)-1))

Local cExtAnt:=""
Local aFiles:={}

//verfica se esta na pasta server
if alltrim(cDirNome)=='Server'
	Alert("ImpossÌvel exlcuir pasta Server!")
	return	
endif  

if "SYSTEM" $ UPPER(cDirNome)
	Alert("N„o È possivel excluir pasta SYSTEM e seus subdiretÛrios!")
	return
endif 

if RAT(".",cDirNome) > 0
	cExtAnt:=alltrim(substr(cDirNome,RAT(".",cDirNome),len(cDirNome)-RAT(".",cDirNome)+1))
endif

if len(cExtAnt)>=4
	Alert("Selecione somente o local!")
	return
endif

if DIRREMOVE(cDirNome)
	msginfo("Pasta excluida com sucesso!")
	//oDlg:end()
	oDBTree:BeginUpdate( )  
 		if oDBTree:TreeSeek(cCargo)
 			oDBTree:DelItem()
 		endif
 	oDBTree:EndUpdate( )  	
else
	Alert("ImpossÌvel exlcuir pasta!")
endif

Return

/******************************* 
//FunÁ„o para renomear arquivos
********************************/

Static Function RenameArq(cCargo)                          

Local cDirNome:=alltrim(substr(cCargo,1,RAT("|",cCargo)-1))
Local cNome:=substr(cDirNome,RAT("\",cDirNome)+1,len(cDirNome)-RAT("\",cDirNome))

Local cGet1	 := cNome
Local cGet2	 := cNome+space(10)
Local oGet1
Local oGet2

if "SYSTEM" $ UPPER(cDirNome)
	Alert("N„o È possivel manipular arquivos de SYSTEM!")
	return	
endif

// Variaveis Private da Funcao
Private oDialg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        

DEFINE MSDIALOG oDialg TITLE "Novo Nome" FROM C(201),C(252) TO C(389),C(613) PIXEL

	// Cria as Groups do Sistema
	@ C(002),C(004) TO C(089),C(174) LABEL "Renomear" PIXEL OF oDialg
	@ C(034),C(008) TO C(064),C(171) LABEL "Obs:" PIXEL OF oDialg

	// Cria Componentes Padroes do Sistema
	@ C(010),C(045) MsGet oGet1 Var cGet1 Size C(109),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDialg
	@ C(012),C(013) Say "Nome:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDialg
	@ C(024),C(045) MsGet oGet2 Var cGet2 Size C(109),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDialg
	@ C(026),C(013) Say "Novo nome:" Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDialg
	@ C(043),C(012) Say "Novo nome deve estar com a extens„o, caso contr·rio o arquivo pode ser corrompido; N„o s„o aceitos caracteres (* e/ou ?)!" Size C(152),C(016) COLOR CLR_BLACK PIXEL OF oDialg
	@ C(069),C(041) Button "Salvar" action(RenameAux(cCargo,cGet2,cCargo)) Size C(037),C(012) PIXEL OF oDialg
	@ C(069),C(092) Button "Cancelar" action(oDialg:end()) Size C(037),C(012) PIXEL OF oDialg
	
oGet1:disable()

ACTIVATE MSDIALOG oDialg CENTERED 

Return(.T.)
//funÁ„o auxiliar para renomear arquivos
Static Function RenameAux(cCargo,cGet2,cCargo)

Local cDirNome:=alltrim(substr(cCargo,1,RAT("|",cCargo)-1))
Local cDirNomeFim:=alltrim(substr(cCargo,RAT("|",cCargo),len(cCargo)-RAT("|",cCargo)))
Local cDir:=alltrim(substr(cDirNome,1,RAT("\",cDirNome)))
Local cExt:=""
Local cExtAnt:=""

if RAT(".",cGet2) > 0
	cExt:=alltrim(substr(cGet2,RAT(".",cGet2),len(cGet2)-RAT(".",cGet2)+1))
endif   
if RAT(".",cDirNome) > 0
	cExtAnt:=alltrim(substr(cDirNome,RAT(".",cDirNome),len(cDirNome)-RAT(".",cDirNome)+1))
endif

if len(cExt)<4  
	if Aviso("Atencao","Novo nome sem extens„o, deseja continuar ?",{"Ok","Cancelar"},2)==2
		return()	
	endif	
elseif cExt<>cExtAnt
	if Aviso("Atencao","Novo nome com extens„o diferente, deseja continuar ?",{"Ok","Cancelar"},2)==2
		return()	
	endif		
endif


if !FRENAME(cDirNome,cDir+cGet2) == -1
	msginfo("Nome alterado com sucesso!")
	oDialg:end()
	oDlg:end()
	
/*	oDBTree:BeginUpdate( )  
 		if oDBTree:TreeSeek(cCargo)
 			oDBTree:DelItem()
			oDBTree:AddItem(cGet2,iif(alltrim(cDirNome)=="\","",cDirNome)+"\"+alltrim(cGet2)+cDirNomeFim,IIF(".INI" $ UPPER(cGet2),cBmpIni,IIF(".DBF" $ UPPER(cGet2),cBmpDbf,IIF("SIGAMAT" $ UPPER(cGet2),cBmpEmp,cBmp2))))	 			
 		endif
 	oDBTree:EndUpdate( )
	*/
else
 	Alert("N„o foi possivel alterar o nome!")
endif

Return


/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa   ≥   C()   ≥ ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao  ≥ Funcao responsavel por manter o Layout independente da       ≥±±
±±≥           ≥ resolucao horizontal do Monitor do Usuario.                  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function C(nTam)                                                         
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø                                               
	//≥Tratamento para tema "Flat"≥                                               
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam) 