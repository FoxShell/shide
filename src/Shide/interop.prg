* node.interop
SET PROCEDURE TO SYS(16) ADDITIVE
if(VARTYPE(_screen.nodeInterop) != "O")
	_screen.AddProperty ("nodeInterop", CREATEOBJECT('nodeinterop'))
ENDIF

DEFINE class heartbeat as Timer
	_nodec= null
	FUNCTION init()
		this.Interval= 120000
		this.Enabled= .t.
		BINDEVENT(this, "timer",this,"_timer")
	ENDFUNC
	FUNCTION SET(node)
		this._nodec= node
	ENDFUNC
	FUNCTION _timer()
		if(!ISNULL(this._nodec))
			TRY
				this._nodec.stdin.write("heartbeat:"+CHR(10))
			CATCH TO ex
			ENDTRY
		ENDIF
	ENDFUNC
ENDDEFINE

DEFINE CLASS NodeInterop as Custom
	_node = null
	_api= null
	_nodec= null
	_beat= null
	_num= 0
	_connected= .f.
	_libs = null 

	DIMENSION _array[1]
	FUNCTION init()
		this._api= CREATEOBJECT('collection')
		this._libs= CREATEOBJECT('collection')
		this._beat= CREATEOBJECT('heartbeat')
		
		
		
		
	ENDFUNC

	function loadRemoteLibrary(url)
		local num, id
		id= "load.remote.1"
		TRY 
			num= _screen.nodeinterop._api.item[m.id]
		CATCH TO ex 
			num= "-1"
		ENDTRY 


		IF num == "-1"
			_Screen.nodeinterop.connect()
			TEXT TO m.code NOSHOW 
			
			async function module1(){
				let os = await KModule.import("os")
				let path = await KModule.import("path")
				let fs = await KModule.import("fs")
				let parts = params.split("|")
				let name = parts[1]
				let fileout = path.join(os.homedir(),"Kawix","Shide.lib", name + ".PRG")
				let fileerr = path.join(os.homedir(),"Kawix","Shide.lib", name + ".ERR")
				if(fs.existsSync(fileerr)){
					fs.unlinkSync(fileout)
					fs.unlinkSync(fileerr)
				}
				if(!fs.existsSync(fileout)){
						
					let url = parts[0]
					if(url.startsWith("gh+")){
						let reg = /gh\+\/([A-Za-z0-9]+)\/([A-Za-z0-9]+)(\@[A-Za-z0-9]+)?\/(.*)/i
						let par = undefined;
						url .replace(reg, function(_,owner,mod,version,file){
							version = version || "master"
							par = {owner,mod,version,file}
						})
						url = "https://raw.githubusercontent.com/" + par.owner + "/"+par.mod+"/"+par.version+"/" + par.file
					}
					
					// download ?? 
					let axios = await KModule.import("npm://axios@0.18.0")
					let response = await axios({
						method:'GET',
						url,
						responseType:'arraybuffer'
					})
					let content = Buffer.from(response.data)
					fs.writeFileSync(fileout, content.toString('latin1'))					
				}
				return {
					path: fileout,
					name
				}
			}
			return module1()
			
			
			ENDTEXT
			_Screen.nodeinterop.register(m.id, m.code)
			num= _screen.nodeinterop._api.item[m.id]

		ENDIF
		oValue= _Screen.nodeinterop.execute(m.num, m.url, .t.)
		return this.loadLibrary(oValue.name)

	endfunc


	FUNCTION loadLibrary(name)

		

		local value 
		value = null 
		try 
			value = this._libs[m.name]
		catch to ex 
		endtry 

		if !isnull(m.value)
			return m.value 
		endif 


		local file
		file = GETENV("USERPROFILE") + "\\Kawix\\Shide.lib\\" + m.name + ".prg"
		do (m.file) with this, m.name 

		try 
			value = this._libs[m.name]
		catch to ex 
		endtry 

		if isnull(m.value)
			error "Failed to load library with name " + m.name
		endif 
		return m.value 
	endfunc 


	FUNCTION connect()
		IF this._connected
		RETURN
		ENDIF
		this._node= CREATEOBJECT('wscript.shell')
		path1= ADDBS(GETENV("USERPROFILE"))+ "Kawix\\Shide\\Shide.exe " + ALLTRIM(STR(_vfp.ProcessId))
		this._nodec=this._node.exec(path1)
		this._beat.set(this._nodec)
		this._connected= .t.
	ENDFUNC

	FUNCTION split(cString, cSeparator )

		nWords = occurs(cSeparator, cString) + 1
		dimension this._array(nWords)

		nWordNo = 1
		do while nWordNo < nWords
		   nPos = at(cSeparator, cString)
		   this._array(nWordNo) = left(cString, nPos - 1)
		   cString = substr(cString, nPos + 1)
		   nWordNo = nWordNo + 1
		enddo
		this._array(nWordNo) = cString
		RETURN @this._array
	ENDFUNC
	FUNCTION destroy()
		IF this._connected
			TRY
				this._nodec.stdin.write("exit:"+CHR(10))
			CATCH TO ex
			ENDTRY
		ENDIF
	ENDFUNC

	FUNCTION execute(name, params, useindex)
		LOCAL num, value, line, data, i, params1, icount
		icount = 0
		
		num= this._num +1
		this._num= this._num +1
		IF !useindex
			value= this._api.item[name]
		ELSE
			value= name
		ENDIF
		IF ISNULL(params)
			params= ''
		ENDIF

		params1= STRCONV(params,13)
		this._nodec.stdin.write("execute:" + value + ":" + STR(num) + ":" + params1 + CHR(10))
		line= this._nodec.stdout.readline()
		DO WHILE SUBSTR(line,1,1) != "#"
			*?line
			line= this._nodec.stdout.readline()
			if line == "."
				icount = icount + 1
			endif
			if icount >= 20
				ERROR "Timedout waiting response from Shide node.interop "
			endif
		ENDDO
		parts= this.split(m.line, ":")
		*?m.line
		IF parts[1] == "#result"
			data= parts[3]
			data= STRCONV(data,14)

			* execute code

			* THIS SOLUTION TO EXECUTE IS FASTER
			LOCAL retorno , als[1], co
			ALINES(m.als, data)
			FOR i = 1 TO ALEN(m.als)
				co= m.als[i]
 				&co
			ENDFOR

			* THIS SOLUTIONS ALSO WORKS, BUT IS SLOWER THAN PREVIOUS
			*local retorno 
			*retorno = execscript(m.data + chr(13) + chr(10) + "return m.retorno")


			IF VARTYPE(m.retorno) == "O" AND VARTYPE(m.retorno.exception) == "O"
				ERROR m.retorno.exception.message
			ENDIF
			RETURN m.retorno
		ENDIF
		IF m.parts[1] == "#error"
			ERROR m.parts[2]
		ENDIF

	ENDFUNC

	FUNCTION register(name, str)
		local line
		this._nodec.stdin.write("register:"+ STRCONV(m.str, 13)+CHR(10))
		line= this._nodec.stdout.readline()
		DO WHILE SUBSTR(line,1,1) != "#"
			line= this._nodec.stdout.readline()
		ENDDO

		parts= this.split(m.line,":")
		*?parts[1]
		IF parts[1] == "#function"
			num= parts[2]
			this._api.add(num, name)
		ENDIF

	ENDFUNC


ENDDEFINE
