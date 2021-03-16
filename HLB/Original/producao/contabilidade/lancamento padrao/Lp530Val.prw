/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLP530VAL  บAutor  ณ ?????              บ Data ณ  09/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEste fonte ้ utilizado nos lan็amentos padr๕es do SIGAFIN   บฑฑ
ฑฑบ          ณ afim de gerar as contabiliza็๕es dos titulos               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
*------------------------*
User Function Lp530Val() 
*------------------------*      
Private _nValor:=0    
_nValor:=0

//RRP - 17/12/2013 - Verificando se a variแvel cCheque estแ carregada.
If Type("cCheque") == "U"
	cCheque := ''
EndIf

if Type("cMotBx") == "U"
	cMotBx := ""
endif

IF GetMv("MV_MCONTAB") $ "CON"   // SIGACON
	If AllTrim(FUNNAME())$ "FINA080"  
	   If! Empty(cCheque).Or.Alltrim(cMotBx) $ "DEBITO CC"   // Se o numero do cheque for <> de branco, ou se o motivo baixa <> debito cc //RRP - 18/08/2014 - Ajuste na variแvel cMotBx 
	       Do Case
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53001"
	               _nValor := IIF(ALLTRIM(SE5->E5_MOTBX)$"DAC".OR.SE2->E2_NUMBOR <>"",0,SE2->((E2_VALOR-E2_JUROS-E2_MULTA)+E2_DESCONT))
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53002" 
	               _nValor := SE2->E2_MULTA       
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53003" 
	               _nValor := IIF(SE5->E5_MOTBX$"DAC/PCC/",0,(SE2->((E2_VALLIQ+E2_PIS+E2_COFINS+E2_CSLL+E2_DESCONT)-(E2_MULTA+E2_JUROS))))
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53004"
	               _nValor := SE2->E2_JUROS
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53005" 
	               _nValor := SE2->E2_DESCONT                                                                          	
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53007"
	               _nValor := If(SE2->E2_VRETPIS>0,SE2->E2_PIS,0)
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53008" 
	               _nValor := If(SE2->E2_VRETCOF>0,SE2->E2_COFINS,0)
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53009" 
	               _nValor := If(SE2->E2_VRETCSL>0,SE2->E2_CSLL,0)
	          //Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53010" 
	               //_nValor := SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL
	          Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53011" 
	               _nValor := (SE2->E2_VALOR+SE2->E2_MULTA+SE2->E2_JUROS)-(SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL+SE2->E2_DESCONT+SE2->E2_SALDO) // ajustado para atender 030325
	          EndCase
	   Endif
	ElseIf AllTrim(FUNNAME())$ "FINA241"    
	    Do Case
	       Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53007" 
	            //_nValor := If(SE2->E2_VRETPIS>0,SE2->E2_PIS,0)
	            _nValor := If(SE2->E2_VRETPIS>0,SE2->E2_VRETPIS,0)
	       Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53008" 
	            //_nValor := If(SE2->E2_VRETCOF>0,SE2->E2_COFINS,0)
	            _nValor := If(SE2->E2_VRETCOF>0,SE2->E2_VRETCOF,0)
	       Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53009" 
	            //_nValor := If(SE2->E2_VRETCSL>0,SE2->E2_CSLL,0)
	            _nValor := If(SE2->E2_VRETCSL>0,SE2->E2_VRETCSL,0)
	       Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53010" 
	            _nValor := (SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL) //IIF(ALLTRIM(SE5->E5_MOTBX)=="PCC",SE2->E2_VALLIQ,0)
		 EndCase
	ELSEIf AllTrim(FUNNAME())$ "FINA370" 
		Do Case
	   	Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53006" 
		  	_nValor := IIF(ALLTRIM(SE5->E5_MOTBX)$"DAC",(SE2->E2_VALOR+SE2->E2_JUROS+SE2->E2_MULTA)-SE2->E2_DESCONT,0)
	    Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53007" 
	        _nValor := If(SE2->E2_VRETPIS>0,SE2->E2_PIS,0)
	    Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53008" 
	        _nValor := If(SE2->E2_VRETCOF>0,SE2->E2_COFINS,0)
	    Case AllTrim(SI5->I5_CODIGO)+AllTrim(SI5->I5_SEQUENC) $ "53009" 
	        _nValor := If(SE2->E2_VRETCSL>0,SE2->E2_CSLL,0)
	    EndCase
	Endif  

ELSE // CONTABILIDADE GERENCIAL
Compara:=paramixb //Parโmetro passado no execblock contendo o numero do lancto e a sua sequencia.
	If AllTrim(FUNNAME())$ "FINA080/FINA090/FINA750/FINA430/INTPRYOR" .AND. !isincallstack("FINA241") //CAS - 18/01/2017, Adicionado INTPRYOR-Chamado:035412   //MSM - 17/11/2015, Adicionado pois estavam chamando a rotina de Bordero imp.(FINA241) pelo Fun็๕es de Contas a Receber  
	   If AllTrim(FUNNAME())$ "FINA090"
	      cCheque := ''
	   EndIf                          
	   //TLM 20140206 - Chamado 016859  - Variavel cMotBx nใo disponivel na fun็ใo FINA750
	   If AllTrim(FUNNAME())$ "FINA750"                                                  
		   If! Empty(cCheque) .Or. Alltrim(cMotBx) $ "DEBITO CC" .Or. cEmpAnt $ "49/3C/YH/Y6/YC/O9"  //RRP - 09/10/2014 - Ajuste chamado 021700. JSS - Add tratamento para empresa Discovery para solu็ใo do caso 031668 //MSM - 12/04/2016 - Chamado: 032910  //MSM - 25/04/2016 - Chamado: 032988

		       Do Case
		          Case Alltrim(Compara) $ "530001"
		               _nValor := IIF(ALLTRIM(SE5->E5_MOTBX)$"DAC".OR.SE2->E2_NUMBOR <>"",0,SE2->((E2_VALOR-E2_JUROS-E2_MULTA)+E2_DESCONT))
		          Case AllTrim(Compara) $ "530002" 
		               _nValor := SE2->E2_MULTA       
		          Case AllTrim(Compara) $ "530003".and. cEmpAnt $ 'B1/0H/8D/8W/NR/NS/O8/O9/O9/OF/OH/02/19/70/8G/B1/B1/BK/D5/X8/XW/ZT/1M/1N/1O/1U/6S/6Y/7A/7B/V2/2O/6A/O7/UA/48/71/3C/YC/YH/NB/P3/'//JSS - 11/02/2016 Tratamento criado para solu็ใo do caso 031934  //JSS - CHAMADO 030325
			           _nValor := IIF(SE5->E5_MOTBX$"DAC/PCC/",0,(SE2->((E2_VALLIQ+E2_PIS+E2_COFINS+E2_CSLL+E2_DESCONT+E2_ISS)-(E2_MULTA+E2_JUROS))))
			      Case AllTrim(Compara) $ "531003".and. cEmpAnt $ 'B1/0H/8D/8W/NR/NS/O8/O9/O9/OF/OH/02/19/70/8G/B1/B1/BK/D5/X8/XW/ZT/1M/1N/1O/1U/6S/6Y/7A/7B/V2/2O/6A/O7/UA/48/71/3C/YC/YH/NB/P3/'//JSS - 11/02/2016 Tratamento criado para solu็ใo do caso 031934" //JSS - CHAMADO 030325    
			           _nValor := IIF(SE5->E5_MOTBX$"DAC/PCC/",0,(SE2->((E2_VALOR+E2_PIS+E2_COFINS+E2_CSLL+E2_DESCONT+E2_ISS)-(E2_MULTA+E2_JUROS))))
		          Case AllTrim(Compara) $ "530003".and. cEmpAnt $ "7W/41/40" //AOA - 22/06/2016 - Ajuste para contabiliza็ใo correta quando houver border๔
		          		If SE2->E2_VALLIQ > 0
		           	   		_nValor := IIF(SE5->E5_MOTBX$"DAC/PCC/",0,(SE2->((E2_VALLIQ+E2_VRETPIS+E2_VRETCOF+E2_VRETCSL+E2_DESCONT)-(E2_MULTA+E2_JUROS))))
		           	   	Else
		           	   		_nValor := IIF(SE5->E5_MOTBX$"DAC/PCC/",0,(SE2->((E2_VALOR+E2_DESCONT)-(E2_MULTA+E2_JUROS))))	
		           	   	EndIf
		          Case AllTrim(Compara) $ "530003" 
		           	   _nValor := IIF(SE5->E5_MOTBX$"DAC/PCC/",0,(SE2->((E2_VALLIQ+E2_PIS+E2_COFINS+E2_CSLL+E2_DESCONT)-(E2_MULTA+E2_JUROS))))
		          Case AllTrim(Compara) $ "530004"
		               _nValor := SE2->E2_JUROS
		          Case AllTrim(Compara) $ "530005" 
		               _nValor := SE2->E2_DESCONT
		          Case AllTrim(Compara) $ "530007".and. cEmpAnt $ "B1/41/40" //JSS - CHAMADO 030325
		               _nValor := SE2->E2_PIS
		          Case AllTrim(Compara) $ "530007".and. cEmpAnt $ "7W" //AOA - 22/06/2016 - Ajuste para contabiliza็ใo correta quando houver border๔
		               _nValor := If(SE2->E2_VRETPIS>0,SE2->E2_VRETPIS,0)
		          Case AllTrim(Compara) $ "530007"
		               _nValor := If(SE2->E2_VRETPIS>0,SE2->E2_PIS,0)		               
		          Case AllTrim(Compara) $ "530008".and. cEmpAnt $ "B1/41/40" //JSS - CHAMADO 030325 
		               _nValor := SE2->E2_COFINS		               
   		          Case AllTrim(Compara) $ "530008".and. cEmpAnt $ "7W" //AOA - 22/06/2016 - Ajuste para contabiliza็ใo correta quando houver border๔
		               _nValor := If(SE2->E2_VRETCOF>0,SE2->E2_VRETCOF,0)
		          Case AllTrim(Compara) $ "530008" 
		               _nValor := If(SE2->E2_VRETCOF>0,SE2->E2_COFINS,0)
		          Case AllTrim(Compara) $ "530009".and. cEmpAnt $ "B1/41/40" //JSS - CHAMADO 030325  
		               _nValor := SE2->E2_CSLL
		          Case AllTrim(Compara) $ "530009".and. cEmpAnt $ "7W" //AOA - 22/06/2016 - Ajuste para contabiliza็ใo correta quando houver border๔
		               _nValor := If(SE2->E2_VRETCSL>0,SE2->E2_VRETCSL,0)
		          Case AllTrim(Compara) $ "530009" 
		               _nValor := If(SE2->E2_VRETCSL>0,SE2->E2_CSLL,0)
		          Case AllTrim(Compara) $ "530011" .and. cEmpAnt $ 'B1/0H/8D/8W/NR/NS/O8/O9/O9/OF/OH/02/19/70/8G/B1/B1/BK/D5/X8/XW/ZT/1M/1N/1O/1U/6S/6Y/7A/7B/V2/2O/6A/O7/UA/48/71/3C/YC/YH/NB/P3/'//JSS - 11/02/2016 Tratamento criado para solu็ใo do caso 031934 
		          	   _nValor := (SE2->E2_VALOR+SE2->E2_MULTA+SE2->E2_JUROS)-(SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL+SE2->E2_DESCONT+SE2->E2_ISS)
   		          Case AllTrim(Compara) $ "531011" .and. cEmpAnt $ 'B1/0H/8D/8W/NR/NS/O8/O9/O9/OF/OH/02/19/70/8G/B1/B1/BK/D5/X8/XW/ZT/1M/1N/1O/1U/6S/6Y/7A/7B/V2/2O/6A/O7/UA/48/71/3C/YC/YH/NB/P3/'//JSS - 11/02/2016 Tratamento criado para solu็ใo do caso 031934" 
		          	   _nValor := (SE2->E2_VALOR+SE2->E2_MULTA+SE2->E2_JUROS)-(SE2->E2_PIS+SE2->E2_COFINS+SE2->E2_CSLL+SE2->E2_DESCONT+SE2->E2_ISS)
		          Case AllTrim(Compara) $ "530011" .and. cEmpAnt $ "1Z" //Criado as linhas 82 e 83 por JSS para atender a solicita็ใo do chamado: 006738 
						// EBF - Verificar se e baixa parcial ou total, se total utilizar o E2_valor se nใo utilizar o E2_VALLIQ. Referente ao chamado:0014751
						If SE2->E2_SALDO > 0
							_nValor := (SE2->E2_VALLIQ+SE2->E2_MULTA+SE2->E2_JUROS)-(SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL+SE2->E2_DESCONT)
						Else
							_nValor := (SE2->E2_VALOR +SE2->E2_MULTA+SE2->E2_JUROS)-(SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL+SE2->E2_DESCONT)
						EndIf
		          Case AllTrim(Compara) $ "530011" .and. cEmpAnt $ "41/40" //AOA - 16/12/2016 - Acerto para JDSU
						_nValor := (SE2->E2_VALOR+SE2->E2_MULTA+SE2->E2_JUROS)-(SE2->E2_PIS+SE2->E2_COFINS+SE2->E2_CSLL+SE2->E2_DESCONT+SE2->E2_ISS)
		          Case AllTrim(Compara) $ "530011" //.and. cEmpAnt <> "40" //JSS 031931 
		               _nValor := (SE2->E2_VALOR+SE2->E2_MULTA+SE2->E2_JUROS)-(SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL+SE2->E2_DESCONT)
				  Case AllTrim(Compara) $ "530012" .and. cEmpAnt $ "49" 
		          	   _nValor := (SE2->E2_ACRESC)
   		          
		          EndCase
	   	   Else    
	   	    	 // TLM - 20140210 - K	PMG Nao preenche o numero de cCheque - Chamado 017073 
	   	   		If Substr(GetEnvServer(),1,6) $ "P11_19/P11_17"
 					Do Case
			   			Case Alltrim(Compara) $ "530001"
			      			_nValor := IIF(ALLTRIM(SE5->E5_MOTBX)$"DAC".OR.SE2->E2_NUMBOR <>"",0,SE2->((E2_VALOR-E2_JUROS-E2_MULTA)+E2_DESCONT))
			          	Case AllTrim(Compara) $ "530002" 
			           		_nValor := SE2->E2_MULTA       
		  	            Case AllTrim(Compara) $ "530003" 
			           		_nValor := IIF(SE5->E5_MOTBX$"DAC/PCC/",0,(SE2->((E2_VALLIQ+E2_PIS+E2_COFINS+E2_CSLL+E2_DESCONT)-(E2_MULTA+E2_JUROS))))
			          	Case AllTrim(Compara) $ "530004"
			               	_nValor := SE2->E2_JUROS
			          	Case AllTrim(Compara) $ "530005"                       
			               	_nValor := SE2->E2_DESCONT
			          	Case AllTrim(Compara) $ "530007"
			               	_nValor := If(SE2->E2_VRETPIS>0,SE2->E2_PIS,0)
					    Case AllTrim(Compara) $ "530008" 
			               	_nValor := If(SE2->E2_VRETCOF>0,SE2->E2_COFINS,0)
			          	Case AllTrim(Compara) $ "530009" 
			               	_nValor := If(SE2->E2_VRETCSL>0,SE2->E2_CSLL,0)
			          	Case AllTrim(Compara) $ "530013" //AOA 12/02/2016 - Soma valores do PCC em um unico lan็amento, chamado: 031183
			               	_nValor := If(SE2->E2_VRETCSL>0,SE2->E2_CSLL,0)
			               	_nValor += If(SE2->E2_VRETCOF>0,SE2->E2_COFINS,0)			               	
			               	_nValor += If(SE2->E2_VRETPIS>0,SE2->E2_PIS,0)			               	
			          	Case AllTrim(Compara) $ "530011" .and. cEmpAnt $ "1Z" //Criado as linhas 82 e 83 por JSS para atender a solicita็ใo do chamado: 006738 
							// EBF - Verificar se e baixa parcial ou total, se total utilizar o E2_valor se nใo utilizar o E2_VALLIQ. Referente ao chamado:0014751
							If SE2->E2_SALDO > 0
								_nValor := (SE2->E2_VALLIQ+SE2->E2_MULTA+SE2->E2_JUROS)-(SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL+SE2->E2_DESCONT)
							Else
								_nValor := (SE2->E2_VALOR+SE2->E2_MULTA+SE2->E2_JUROS)-(SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL+SE2->E2_DESCONT)
							EndIf
			          	Case AllTrim(Compara) $ "530011" 
			               _nValor := (SE2->E2_VALOR+SE2->E2_MULTA+SE2->E2_JUROS)-(SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL+SE2->E2_DESCONT)
				  		Case AllTrim(Compara) $ "530012" .and. cEmpAnt $ "49" 
		          	   _nValor := (SE2->E2_ACRESC)
			    		EndCase
  	   
	   	        EndIf
	       EndIf
	   Else
		   If! Empty(cCheque).Or.Alltrim(cMotBx) $ "DEBITO CC" .OR. cEmpAnt $ "3C/YH/Y6/YC/O9/85" 	//CAS - 18/01/2017, Adicionado empresa 85-Chamado:035412  //RRP - 18/08/2014 - Ajuste na variแvel cMotBx   //MSM - 12/04/2016 - Chamado: 032910 //MSM - 25/04/2016 - Chamado: 032988  
		       Do Case
		          Case Alltrim(Compara) $ "530001"
		               _nValor := IIF(ALLTRIM(SE5->E5_MOTBX)$"DAC".OR.SE2->E2_NUMBOR <>"",0,SE2->((E2_VALOR-E2_JUROS-E2_MULTA)+E2_DESCONT))
		          Case AllTrim(Compara) $ "530002" 
		               _nValor := SE2->E2_MULTA       
		          Case AllTrim(Compara) $ "530003".and. cEmpAnt $ "41/40"//AOA - inclusao do c๓digo do Gartner 
		          		If SE2->E2_VALLIQ > 0
		           	   		_nValor := IIF(SE5->E5_MOTBX$"DAC/PCC/",0,(SE2->((E2_VALLIQ+E2_VRETPIS+E2_VRETCOF+E2_VRETCSL+E2_DESCONT)-(E2_MULTA+E2_JUROS))))
		           	   	Else
		           	   		_nValor := IIF(SE5->E5_MOTBX$"DAC/PCC/",0,(SE2->((E2_VALOR+E2_DESCONT)-(E2_MULTA+E2_JUROS))))	
		           	   	EndIf		          	
		          Case AllTrim(Compara) $ "530003".and. cEmpAnt $ "7W" //AOA - 22/06/2016 - Ajuste para contabiliza็ใo correta quando houver border๔
		           	   _nValor := IIF(SE5->E5_MOTBX$"DAC/PCC/",0,(SE2->((E2_VALLIQ+E2_VRETPIS+E2_VRETCOF+E2_VRETCSL+E2_DESCONT)-(E2_MULTA+E2_JUROS))))
		          Case AllTrim(Compara) $ "530003" 
		               _nValor := IIF(SE5->E5_MOTBX$"DAC/PCC/",0,(SE2->((E2_VALLIQ+E2_PIS+E2_COFINS+E2_CSLL+E2_DESCONT)-(E2_MULTA+E2_JUROS))))
		          Case AllTrim(Compara) $ "530004"
		               _nValor := SE2->E2_JUROS
		          Case AllTrim(Compara) $ "530005" 
		               _nValor := SE2->E2_DESCONT
		          Case AllTrim(Compara) $ "530007".and. cEmpAnt $ "41/85/40" //CAS - 18/01/2017, Adicionado empresa 85-Chamado:035412  //AOA - 16/12/2016 - Acerto para JDSU
		               _nValor := SE2->E2_PIS
		          Case AllTrim(Compara) $ "530007"
		               _nValor := If(SE2->E2_VRETPIS>0,SE2->E2_PIS,0)
		          Case AllTrim(Compara) $ "530008".and. cEmpAnt $ "41/85/40" //CAS - 18/01/2017, Adicionado empresa 85-Chamado:035412  //AOA - 16/12/2016 - Acerto para JDSU
			           _nValor := SE2->E2_COFINS
		          Case AllTrim(Compara) $ "530009".and. cEmpAnt $ "41/85/40" //CAS - 18/01/2017, Adicionado empresa 85-Chamado:035412  //AOA - 16/12/2016 - Acerto para JDSU
		               _nValor := SE2->E2_CSLL
		          Case AllTrim(Compara) $ "530008" 
		               _nValor := If(SE2->E2_VRETCOF>0,SE2->E2_COFINS,0)
		          Case AllTrim(Compara) $ "530009" 
		               _nValor := If(SE2->E2_VRETCSL>0,SE2->E2_CSLL,0)
		          Case AllTrim(Compara) $ "530011" .and. cEmpAnt $ "1Z" //Criado as linhas 82 e 83 por JSS para atender a solicita็ใo do chamado: 006738 
						// EBF - Verificar se e baixa parcial ou total, se total utilizar o E2_valor se nใo utilizar o E2_VALLIQ. Referente ao chamado:0014751
						If SE2->E2_SALDO > 0
							_nValor := (SE2->E2_VALLIQ+SE2->E2_MULTA+SE2->E2_JUROS)-(SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL+SE2->E2_DESCONT)
						Else
							_nValor := (SE2->E2_VALOR+SE2->E2_MULTA+SE2->E2_JUROS)-(SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL+SE2->E2_DESCONT)
						EndIf
		          Case AllTrim(Compara) $ "530011" .and. cEmpAnt $ "41/85/40" //AOA - inclusao do c๓digo do Gartner //CAS - 18/01/2017, Adicionado empresa 85-Chamado:035412  //AOA - 16/12/2016 - Acerto para JDSU
						_nValor := (SE2->E2_VALOR+SE2->E2_MULTA+SE2->E2_JUROS)-(SE2->E2_PIS+SE2->E2_COFINS+SE2->E2_CSLL+SE2->E2_DESCONT+SE2->E2_ISS)
		          Case AllTrim(Compara) $ "530011" .and. cEmpAnt <> "40"  
		                _nValor := (SE2->E2_VALOR+SE2->E2_MULTA+SE2->E2_JUROS)-(SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL+SE2->E2_DESCONT)
		          Case AllTrim(Compara) $ "530012" .and. cEmpAnt $ "49" 
		          	   _nValor := (SE2->E2_ACRESC)
		          EndCase
		   Endif
	   EndIf
	
	ElseIf AllTrim(FUNNAME())$ "FINA241" .OR. ( AllTrim(FUNNAME())$ "FINA750" .AND. isincallstack("FINA241")) //MSM - 17/11/2015, Adicionado pois estavam chamando a rotina de Bordero imp.(FINA241) pelo Fun็๕es de Contas a Receber     
	    If cEmpAnt $ "07"                  //JSS - 26/03/2014 - Alterado para solucionar o chamado 017978.
	    	Do Case
		       Case AllTrim(Compara) $ "530007" 
		            _nValor := If(SE2->E2_VRETPIS>0,SE2->E2_PIS,0)
		            //_nValor := If(SE2->E2_VRETPIS>0,SE2->E2_VRETPIS,0)
		       Case AllTrim(Compara) $ "530008" 
		            _nValor := If(SE2->E2_VRETCOF>0,SE2->E2_COFINS,0)
		            //_nValor := If(SE2->E2_VRETCOF>0,SE2->E2_VRETCOF,0)
		       Case AllTrim(Compara) $ "530009" 
		            _nValor := If(SE2->E2_VRETCSL>0,SE2->E2_CSLL,0)
		            //_nValor := If(SE2->E2_VRETCSL>0,SE2->E2_VRETCSL,0)
		       Case AllTrim(Compara) $ "530010" 
		            _nValor := (SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL)
			 EndCase
			 
		Else
	        _nValor := 0  //AOA 11/03/2016 - Alterado para nใo gerar contabil ao gerar bordero de impostos, chamado 032252
		EndIf
	ELSEIf AllTrim(FUNNAME())$ "FINA370/FINA300"//AOA - 06/04/2016 - Incluido rotina SISPAG para ser gerado corretamente as baixas quando feita por retorno cnab 
		Do Case
          	Case AllTrim(Compara) $ "530011"//AOA - 23/05/2016 - Pegar o valor liquido por ter baixas parciais. 
               _nValor := (SE2->E2_VALLIQ+SE2->E2_MULTA+SE2->E2_JUROS+SE2->E2_ACRESC)//-(SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL+SE2->E2_DESCONT+SE2->E2_DECRESC)

        	Case AllTrim(Compara) $ "530003" .and. cEmpAnt $ "1Z" 		//CAS - 13/06/2017, Tratamento p empresa 1Z-Chamado:036812   
				_nValor := IIF(SE5->E5_MOTBX$"DAC/PCC/",0,(SE2->((E2_VALOR+E2_DESCONT)-(E2_MULTA+E2_JUROS))))
        	Case AllTrim(Compara) $ "530003" 
	            _nValor := IIF(SE5->E5_MOTBX$"DAC/PCC/",0,(SE2->((E2_VALLIQ+E2_PIS+E2_COFINS+E2_CSLL+E2_DESCONT)-(E2_MULTA+E2_JUROS+E2_ACRESC))))
	   		Case AllTrim(Compara) $ "530006" 
	      		_nValor := IIF(ALLTRIM(SE5->E5_MOTBX)$"DAC",(SE2->E2_VALOR+SE2->E2_JUROS+SE2->E2_MULTA)-SE2->E2_DESCONT,0)
			Case AllTrim(Compara) $ "530002" 
                _nValor := SE2->E2_MULTA+SE2->E2_ACRESC	     
            Case AllTrim(Compara) $ "530004"
                _nValor := SE2->E2_JUROS
	      	Case AllTrim(Compara) $ "530007" 
	         	_nValor := If(SE2->E2_VRETPIS>0,SE2->E2_PIS,0)
	      	Case AllTrim(Compara) $ "530008" 
	         	_nValor := If(SE2->E2_VRETCOF>0,SE2->E2_COFINS,0)
	      	Case AllTrim(Compara) $ "530009" 
	         	_nValor := If(SE2->E2_VRETCSL>0,SE2->E2_CSLL,0)	         	

	      EndCase
	Endif
	
ENDIF
	
Return(_nValor)
