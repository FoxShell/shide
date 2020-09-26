Lparameters  nodeInterop, libName
if pcount() > 0
	try 
		m.nodeInterop._libs.add(CREATEOBJECT("JSON"), m.libName)
	catch to ex 
	endtry 
ENDIF


function __parse(str)
    local num, id
	id= "json.parse.1"
	TRY 
		num= _screen.nodeinterop._api.item[m.id]
	CATCH TO ex 
		num= "-1"
	ENDTRY 


    IF num == "-1"
		_Screen.nodeinterop.connect()
		TEXT TO m.code NOSHOW 
        return JSON.parse(params)
        ENDTEXT
        _Screen.nodeinterop.register(m.id, m.code)
		num= _screen.nodeinterop._api.item[m.id]

    ENDIF
    RETURN _Screen.nodeinterop.execute(m.num, m.str, .t.)

endfunc


* JSON.Parse for VFP9

* HTTP Request
* Author: Kodhe
SET PROCEDURE TO SYS(16) ADDITIVE 

DEFINE CLASS JSON as Custom 
	function parse(str)
		return __parse(m.str)
	endfunc 
ENDDEFINE