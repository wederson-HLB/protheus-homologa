#Include "Protheus.ch"

/*
Funcao      : GTGEN017
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Função que busca as informações dos CNAB's das empresas através dos usuários que os utilizam
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 23/07/2013    10:28
Módulo      : Genérico
*/

*---------------------*
User function GTGEN017
*---------------------*
Local aAmbs		:= {}
Local cArqTxt	:= ""

Local aRotinas	:= {"GPM410","GPM450","AFI150","AFI420","AFI300"}
Local aDadTemp	:= {}
Local cHtml		:= ""

AADD(aDadTemp,{"AMBIENTE"	,"C",10		,0})
AADD(aDadTemp,{"EMP"		,"C",2		,0})
AADD(aDadTemp,{"USUARIO"	,"C",50		,0})
AADD(aDadTemp,{"CNAB"		,"C",80		,0})
AADD(aDadTemp,{"BANCO"		,"C",20		,0})
AADD(aDadTemp,{"TIPO"		,"C",20		,0})

//<INICIO> temporário para armazenar as informações dos CNABS

if select("DADTRB")>0
	DADTRB->(DbCloseArea())
endif

// Abertura da tabela
cNome := CriaTrab(aDadTemp,.T.)
dbUseArea(.T.,,cNome,"DADTRB",.T.,.F.)

cIndex	:=CriaTrab(Nil,.F.)

IndRegua("DADTRB",cIndex,"EMP",,,"Selecionando Registro...")  

DbSelectArea("DADTRB")
DbSetIndex(cIndex+OrdBagExt())
DbSetOrder(1)

//<FIM> TEMPORARIO

cArqTxt	:="\profile\profile.usr"
	
	if SELECT("SSS")>0
		SSS->(DbCloseArea())
	endif
	
	//Abro o arquivo profile em um temporário
	dbUseArea( .T.,"dbfcdxads", cArqTxt,"SSS",.T., .F. )
	
		for i:=1 to len(aRotinas)
		
			SSS->(DBCLEARFILTER())
			
			//Faço um filtro na tabela de profiles para o pergunte que desejo + o task igual a pergunte
			cFiltro:="'"+aRotinas[i]+"' $ P_PROG .AND. 'PERGUNTE' $ P_TASK"
			
			bCondicao := {|| &(cFiltro)}
			cCondicao := cFiltro
				
			DbSelectArea("SSS")
			SSS->(DbSetOrder(1))
			SSS->(DbSetFilter(bCondicao,cCondicao))
			
			cEmp	:= ""
			cUser	:= ""
			cCnab	:= ""
			cBanco	:= ""
	        
	        SSS->(DbGoTop())
	        While SSS->(!EOF())
	            
	            cEmp	:= SUBSTR(SSS->P_NAME,1,2)
	            cUser	:= alltrim(SUBSTR(SSS->P_NAME,3,50))
	            cCnab	:= ""
	            cBanco	:= ""
	            ctipo	:= ""

	            if aRotinas[i] == "GPM410" .OR. aRotinas[i] == "GPM450"
	            	ctipo	:= "FOLHA"
	            endif
	            
	            if aRotinas[i] == "AFI150"
	            	ctipo	:= "RECEBER"
	            endif
	            
	            if aRotinas[i] == "AFI420" .OR. aRotinas[i] == "AFI300"
	            	ctipo	:= "PAGAR"
	            endif
	            
	            aLinha	:= separa(UPPER(SSS->P_DEFS),CHR(13))  // Sepera para vetor 
	            
				//<SX1> TEMPORARIO DO SX1
				if select("SX1TMP")>0
					SX1TMP->(DbCloseArea())
				endif
				
				//Abro o SX1(em um alias temporário) da empresa no qual desejo visualizar o cadastro
				DbUseArea(.T., "DBFCDX", "\"+CURDIR()+"SX1"+cEmp+"0.DBF", "SX1TMP", .T., .F.)
				
				DbSelectArea("SX1TMP")
				cArqInd := CriaTrab(Nil,.F.)
				IndRegua("SX1TMP",cArqInd,"X1_GRUPO+X1_ORDEM",,"","",.F.)
				
				SX1TMP->(DbSetOrder(1))
	
		        if SX1TMP->(DbSeek(aRotinas[i]))
		        	nSeqCnab:=0
		        	nSeqBco	:=0
		        	While SX1TMP->(!EOF()) .AND. alltrim(SX1TMP->X1_GRUPO)==aRotinas[i]
		        	    nSeqCnab+=1
		        	    nSeqBco+=1
		        	    
		        	    if empty(cCnab)
			        	    if ".2RE" $ UPPER(aLinha[nSeqCnab]) .OR. ".REM" $ UPPER(aLinha[nSeqCnab]) .OR. ".2PE" $ UPPER(aLinha[nSeqCnab]) .OR. ".CPE" $ UPPER(aLinha[nSeqCnab]) .OR. ".PAG" $ UPPER(aLinha[nSeqCnab])
			        	    	cCnab:=SUBSTR(aLinha[nSeqCnab],6,50)
			        	    endif
						endif
								        	    
		        	    if "BANCO" $ UPPER(X1_PERGUNTE)
		        	    	cBanco:=SUBSTR(aLinha[nSeqBco],6,50)
		        	    endif
		        	    
		        		SX1TMP->(DbSkip())
		        	Enddo
		        endif 
	
		        //<SX1> FIM TEMPORARIO DO SX1
	            
		        if !empty(cCnab) //Se existir algo preenchido no parametro do cnab gravo na temporária
			        RecLock("DADTRB",.T.)
			       		DADTRB->AMBIENTE:= SUBSTR(GetEnvServer(),1,len(GetEnvServer())-1)
			       		DADTRB->EMP		:= cEmp
			       		DADTRB->USUARIO	:= cUser
			       		DADTRB->CNAB	:= cCnab
			       		DADTRB->BANCO	:= cBanco
			       		DADTRB->TIPO	:= ctipo
			        DADTRB->(MsUnlock())
				endif
	
	           	SSS->(DbSkip())
	        Enddo
	        
		next
		

DbSelectArea("DADTRB")
DADTRB->(DbGoTop())

cHtml+="<html>"
cHtml+="<table border='1'>"

cHtml+="<td>"
cHtml+="Ambiente"
cHtml+="</td>"

cHtml+="<td>"
cHtml+="Empresa"
cHtml+="</td>"

cHtml+="<td>"
cHtml+="Usuario"
cHtml+="</td>"

cHtml+="<td>"
cHtml+="CNAB"
cHtml+="</td>"

cHtml+="<td>"
cHtml+="Banco"
cHtml+="</td>"

cHtml+="<td>"
cHtml+="Tipo"
cHtml+="</td>"

While DADTRB->(!EOF())
	cHtml+="<tr>"
	
	cHtml+="<td>"
	cHtml+=DADTRB->AMBIENTE
	cHtml+="</td>"
		
	cHtml+="<td>"
	cHtml+='="'+DADTRB->EMP+'"'
	cHtml+="</td>"
	
	cHtml+="<td>"
	cHtml+=DADTRB->USUARIO
	cHtml+="</td>"

	cHtml+="<td>"
	cHtml+=DADTRB->CNAB
	cHtml+="</td>"

	cHtml+="<td>"
	cHtml+='="'+DADTRB->BANCO+'"'
	cHtml+="</td>"
	
	cHtml+="<td>"
	cHtml+=DADTRB->TIPO
	cHtml+="</td>"
			
	cHtml+="</tr>"
	DADTRB->(DbSkip())
Enddo

cHtml+="</table>"
cHtml+="</html>"	

GExecl(cHtml)

Return

/*
Funcao      : GExecl
Parametros  : cConteu
Retorno     : 
Objetivos   : Funcao que gera o excel
Autor       : Matheus Massarotto
Data/Hora   : 23/07/2013
*/

*-------------------------------*
Static Function GExecl(cConteu)
*-------------------------------*
Private cDest :=  GetTempPath()

/***********************GERANDO EXCEL************************************/

	cArq := alltrim(CriaTrab(NIL,.F.))+".xls"
		
	IF FILE (cDest+cArq)
		FERASE (cDest+cArq)
	ENDIF

	nHdl 	:= FCREATE(cDest+cArq,0 )  //Criação do Arquivo HTML.
	nBytesSalvo := FWRITE(nHdl, cConteu ) // Gravação do seu Conteudo.
	
	if nBytesSalvo <= 0   // Verificação do arquivo (GRAVADO OU NAO) e definição de valor de Bytes retornados.
		MsgStop("Erro de gravação do Destino. Error = "+ str(ferror(),4),'Erro')
	else
		fclose(nHdl) // Fecha o Arquivo que foi Gerado
		cExt := '.xls'
		SHELLEXECUTE("open",(cDest+cArq),"","",5)   // Gera o arquivo em Excel
	endif
/***********************GERANDO EXCEL************************************/          
    sleep(5000)
	FERASE (cDest+cArq)

Return