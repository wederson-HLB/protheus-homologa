#include "protheus.ch"

/*
Funcao      : GTOBJ004
Parametros  : 
Retorno     : objeto
Objetivos   : Classe para leitura de arquivo .ofx e disponibilizar os dados no objeto
			: 
Autor       : Matheus Massarotto
Revisão		:
Data/Hora   : 27/05/2013    10:28
Módulo      : Genérico
*/


//Classe principal
*------------------------------*
CLASS OFX
*------------------------------*
DATA CURDEF
DATA BANKACCTFROM
DATA BANKTRANLIST
DATA CCONTEUDO

DATA cArq

METHOD New() CONSTRUCTOR
METHOD LerOfx(cArq)

ENDCLASS

//Metodo principal para construção do objeto
*----*
METHOD New(cArq) CLASS OFX
*----*
::BANKACCTFROM 	:= BANKACCTFROM():New()
::BANKTRANLIST 	:= BANKTRANLIST():New()
::CURDEF		:= ""
::CCONTEUDO		:= ""

::LerOfx(cArq)

Return SELF

//Metodo para ler o arquivo .ofx e preencher o objeto com as informações
*----*
METHOD LerOfx(cArq) CLASS OFX
*----*
Local cLinha	:= ""	//Variável que contém a linha lida
Local oDados			//objeto com os dados das transações
Local lEhOfx	:= .F.	//Variável para controle se o arquivo tem a estrutura de um ofx

If File(cArq)

::cArq:= cArq

	FT_FUse(cArq)
	FT_FGOTOP()  
	
	oDados:=STMTTRN():New()
	
		While !FT_FEof()
	  	    
	  	    cLinha := FT_FReadLn()
			cLinha := strtran(cLinha,CHR(09),"") //Retiro a tabulação
			
        	::CCONTEUDO+=cLinha

        	if ALLTRIM(UPPER(cLinha))=="<OFX>"
				lEhOfx:=.T.
			endif
				
			if lEhOfx
			
				if "<CURDEF>" $ alltrim(UPPER(cLinha))
					if "</CURDEF>" $ alltrim(UPPER(cLinha))
						::CURDEF:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,AT("</",cLinha)-AT(">",cLinha)-1))
					else
						::CURDEF:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,len(cLinha)))
				    endif
				endif
				
				// <INICIO> -- Leitura dos dados do banco
				if ALLTRIM(UPPER(cLinha))=="<BANKACCTFROM>"	
			    	While alltrim(UPPER(cLinha))<>"</BANKACCTFROM>"
						if "<BANKID>" $ alltrim(UPPER(cLinha))
                        	if "</BANKID>" $ alltrim(UPPER(cLinha))
                        		::BANKACCTFROM:BANKID:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,AT("</",cLinha)-AT(">",cLinha)-1))
                        	else
                        		::BANKACCTFROM:BANKID:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,len(cLinha)))
						    endif
						elseif "<ACCTID>" $ alltrim(UPPER(cLinha))
                        	
                        	if "</ACCTID>" $ alltrim(UPPER(cLinha))
	                        	::BANKACCTFROM:ACCTID:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,AT("</",cLinha)-AT(">",cLinha)-1)) 
                        	else
                        		::BANKACCTFROM:ACCTID:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,len(cLinha))) 
						    endif
						    
						elseif "<ACCTTYPE>" $ alltrim(UPPER(cLinha))
      						if "</ACCTTYPE>" $ alltrim(UPPER(cLinha))
                        		::BANKACCTFROM:ACCTTYPE:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,AT("</",cLinha)-AT(">",cLinha)-1))
						    else 
						    	::BANKACCTFROM:ACCTTYPE:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,len(cLinha)))
						    endif
						endif
						
						FT_FSkip()
			    		
			    		cLinha := FT_FReadLn()
			    		cLinha := strtran(cLinha,CHR(09),"")  //Retiro a tabulação
			        Enddo
				endif
				// <FIM> -- Leitura dos dados do banco
				
				//<INICIO> -- Leitura da data de inicio de fim dos processamentos
				if "<DTSTART>" $ alltrim(UPPER(cLinha)) 
					if "</DTSTART>" $ alltrim(UPPER(cLinha))
						::BANKTRANLIST:DTSTART:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,AT("</",cLinha)-AT(">",cLinha)-1))
					else
						::BANKTRANLIST:DTSTART:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,len(cLinha)))
					endif
				elseif "<DTEND>" $ alltrim(UPPER(cLinha)) 
					if "</DTEND>" $ alltrim(UPPER(cLinha))
						::BANKTRANLIST:DTEND:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,AT("</",cLinha)-AT(">",cLinha)-1))
					else
						::BANKTRANLIST:DTEND:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,len(cLinha)))
					endif
				endif
				//<FIM> -- Leitura da data de inicio de fim dos processamentos
								
			    // <INICIO> -- Leitura dos itens(Creditos e Débitos realizados)
				if ALLTRIM(UPPER(cLinha))=="<STMTTRN>"	
			    	oDados:=STMTTRN():New()
			    	
			    	While alltrim(UPPER(cLinha))<>"</STMTTRN>"
			    		
			    		if "<TRNTYPE>" $ alltrim(UPPER(cLinha))
			    			cRecno:=FT_FRECNO()
			    			lSair:=.F.
			    			// Verifico se o valor é positivo ou negativo 
			    			While !lSair
			    				
			    				if "<TRNAMT>" $ alltrim(UPPER(cLinha))

						    		if val( STRTRAN(ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,len(cLinha))),",",".") )>0
						    			oDados:TRNTYPE:="CREDIT"
						    		else
						    			oDados:TRNTYPE:="DEBIT"
						    		endif
			    					
			    					lSair:=.T.
			    				endif
			    				
			    				FT_FSkip()
			    		
			    				cLinha := FT_FReadLn()
			    				cLinha := strtran(cLinha,CHR(09),"")  //Retiro a tabulação
			    				
			    				if alltrim(UPPER(cLinha))=="</STMTTRN>"
			    					lSair:=.T.
			    				endif
			    			Enddo
			    			
			    			FT_FGOTO(cRecno)
				    		//oDados:TRNTYPE:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,len(cLinha)))

			    	    elseif "<DTPOSTED>" $ alltrim(UPPER(cLinha))
				    		
				    		if "</DTPOSTED>" $ alltrim(UPPER(cLinha))
				    			oDados:DTPOSTED:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,AT("</",cLinha)-AT(">",cLinha)-1))
				    		else
					    		oDados:DTPOSTED:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,len(cLinha)))
				    		endif
				    		
			    	    elseif "<TRNAMT>" $ alltrim(UPPER(cLinha))
				    		
				    		if "</TRNAMT>" $ alltrim(UPPER(cLinha))
				    			oDados:TRNAMT:=val( STRTRAN(ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,AT("</",cLinha)-AT(">",cLinha)-1)),",",".") )
				    		else
				    			oDados:TRNAMT:=val( STRTRAN(ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,len(cLinha))),",",".") )
				    		endif
				    		
			    	    elseif "<FITID>" $ alltrim(UPPER(cLinha))
				    		
				    		if "</FITID>" $ alltrim(UPPER(cLinha))
				    			oDados:FITID:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,AT("</",cLinha)-AT(">",cLinha)-1))				    					    	    
				    		else
					    		oDados:FITID:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,len(cLinha)))				    					    	    
				    		endif
				    		
			    	    elseif "<CHECKNUM>" $ alltrim(UPPER(cLinha))
				    		
				    		if "</CHECKNUM>" $ alltrim(UPPER(cLinha))
				    			oDados:CHECKNUM:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,AT("</",cLinha)-AT(">",cLinha)-1))
				    		else
					    		oDados:CHECKNUM:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,len(cLinha)))
				    		endif
				    		
			    	    elseif "<MEMO>" $ alltrim(UPPER(cLinha))
				    		
				    		if "</MEMO>" $ alltrim(UPPER(cLinha))
				    			oDados:MEMO:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,AT("</",cLinha)-AT(">",cLinha)-1))
				    		else
				    			oDados:MEMO:=ALLTRIM(SUBSTR(cLinha,AT(">",cLinha)+1,len(cLinha)))				    		
				    		endif
				    		
			    	    endif
			    	    
			    		FT_FSkip()
			    		
			    		cLinha := FT_FReadLn()
			    		cLinha := strtran(cLinha,CHR(09),"")  //Retiro a tabulação
			    	Enddo
			    	
			    	AADD(::BANKTRANLIST:STMTTRN,oDados)
			    	
			    endif
			    // <FIM> -- Leitura dos itens(Creditos e Débitos realizados)
			    			    
			endif
			
			FT_FSkip()   
	 	Enddo 	    
	 	
	 FT_FUse() //Fecha o arquivo
Else
	Alert("O arquivo especificado não existe!")
Endif

Return SELF

//Classe com a identificação do banco
*------------------------------*
CLASS BANKACCTFROM
*------------------------------*
DATA BANKID
DATA ACCTID
DATA ACCTTYPE

METHOD New() CONSTRUCTOR

ENDCLASS
*----*
METHOD New() CLASS BANKACCTFROM
*----*
::BANKID	:= ""
::ACCTID    := ""
::ACCTTYPE  := ""

Return SELF


//Classe com os registros processados no banco
*------------------------------*
CLASS BANKTRANLIST
*------------------------------*
DATA DTSTART
DATA DTEND
DATA STMTTRN

METHOD New() CONSTRUCTOR

ENDCLASS
*----*
METHOD New() CLASS BANKTRANLIST
*----*
::DTSTART	:= CTOD("//")
::DTEND    	:= CTOD("//")
::STMTTRN  	:= {}

Return SELF

//Classe contendo a descrição de cada operação
*------------------------------*
CLASS STMTTRN
*------------------------------*
DATA TRNTYPE
DATA DTPOSTED
DATA TRNAMT
DATA FITID
DATA CHECKNUM
DATA MEMO

METHOD New() CONSTRUCTOR

ENDCLASS
*----*
METHOD New() CLASS STMTTRN
*----*
::TRNTYPE	:= ""
::DTPOSTED	:= ""
::TRNAMT	:= 0
::FITID		:= ""
::CHECKNUM	:= ""
::MEMO		:= "" 

Return SELF
