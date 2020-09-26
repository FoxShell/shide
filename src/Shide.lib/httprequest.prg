Lparameters  nodeInterop, libName
if pcount() > 0
	try 
		m.nodeInterop._libs.add(CREATEOBJECT("axiosstatic"), m.libName)
	catch to ex 
	endtry 
ENDIF


* HTTP Request
* Author: Kodhe
SET PROCEDURE TO SYS(16) ADDITIVE
SET PROCEDURE TO ADDBS(JUSTPATH(SYS(16)))+"nfjsoncreate" ADDITIVE

do ADDBS(JUSTPATH(SYS(16)))+"..\Shide\interop"

FUNCTION HttpRequest(url)
	IF PCOUNT() == 0
		RETURN CREATEOBJECT('httprequest')
	ENDIF
	local num, req
	TRY
		num= _screen.nodeinterop._api.item["http.request.5"]
	CATCH TO ex
		num= "-1"
	ENDTRY
	IF VARTYPE(m.url) == "O"
		req = m.url
	ELSE
		req= CREATEOBJECT('httprequest')
		req.url= m.url
	ENDIF
	IF num == "-1"
		_Screen.nodeinterop.connect()
		TEXT TO m.code NOSHOW

		// * javascript code
		var execute= async function(){
			var request= await KModule.import("npm://request@^2.88.0")
			var resolve,reject , temp
			var promise= new Promise(function(a,b){
				resolve= a
				reject = b
			})
			params= JSON.parse(params)
			if(params.form_kv_collection && params.form_kv_collection.collectionitems){
				temp= params.form_kv_collection.collectionitems
				delete params.form_kv_collection
				params.form= {}
				for(var i= 0;i<temp.length;i++){
					params.form[temp[i].key]= temp[i].value
				}
			}

			if(params.body_kv_collection && params.body_kv_collection.collectionitems){
				temp= params.body_kv_collection.collectionitems
				delete params.body_kv_collection
				params.body= {}
				for(var i= 0;i<temp.length;i++){
					params.body[temp[i].key]= temp[i].value
				}
			}

			if(params.headers_kv_collection && params.headers_kv_collection.collectionitems){
				temp= params.headers_kv_collection.collectionitems
				delete params.headers_kv_collection
				params.headers= {}
				for(var i= 0;i<temp.length;i++){
					params.headers[temp[i].key]= temp[i].value
				}
			}
			// return JSON.stringify(params)

			request(params, function (error, response, body) {
				var parsedBody
			  if(error) return reject(error)
			  if(response && response.headers["content-type"] && response.headers["content-type"].startsWith("application/json") && body && body.length){
			  	parsedBody= JSON.parse(body)
			  }
			  return resolve({
			  	statuscode: response && response.statusCode,
			  	headers: response.headers,
			  	url: response.url,
				body: body,
				parsedBody: parsedBody
			  })
			})

			return await promise
		}
		return execute()


		ENDTEXT
		_Screen.nodeinterop.register("http.request.5", m.code)
		num= _screen.nodeinterop._api.item["http.request.5"]
	ENDIF
	RETURN _Screen.nodeinterop.execute(num, m.req.toJSON(), .t.)
ENDFUNC

DEFINE CLASS HttpRequestForm as Custom
	_form= null
	FUNCTION init()
	ENDFUNC

	FUNCTION addParameter(name, value)
		this._form.add(value,name)
	ENDFUNC
ENDDEFINE

DEFINE CLASS HttpRequestStatic as Custom 
	function create()
		local val
		val = CREATEOBJECT('HttpRequest')
		return m.val
	endfunc 
ENDDEFINE

DEFINE CLASS HttpRequest as Custom

	followRedirect= .t.

	_obj= null
	_header= null
	url= null
	method= null
	headers= null
	_form= null
	_body= null
	form= null
	body= null

	FUNCTION init()
		this._obj= CREATEOBJECT("empty")
		ADDPROPERTY(this._obj,'url','')
		ADDPROPERTY(this._obj,'followRedirect',.t.)
		ADDPROPERTY(this._obj,'method','GET')
	ENDFUNC

	FUNCTION addheader(name, value)
		IF VARTYPE(this._header)!='0'
			this._header= CREATEOBJECT('collection')
			ADDPROPERTY(this._obj, 'headers',this._header)
		ENDIF

		this._header.add(value, name)
	ENDFUNC

	FUNCTION headers_access()
		RETURN this._header
	ENDFUNC

	FUNCTION followredirect_access()
		RETURN this._obj.followredirect
	ENDFUNC
	FUNCTION followredirect_assign(value)
		this._obj.followredirect= m.value
	ENDFUNC

	FUNCTION Form_access() 
		IF VARTYPE(this._form) != 'O'
			IF VARTYPE(this._obj.form) != 'O'
				ADDPROPERTY(this._obj,'form', CREATEOBJECT('collection'))
			ENDIF
			this._form= CREATEOBJECT("Httprequestform")
			this._Form._form=this._obj.form
		ENDIF
		RETURN this._form
	ENDFUNC


	FUNCTION Body_access()
		IF VARTYPE(this._body) != 'O'
			IF VARTYPE(this._obj.body) != 'O'
				ADDPROPERTY(this._obj,'body', CREATEOBJECT('collection'))
			ENDIF
			this._body= CREATEOBJECT("Httprequestform")
			this._Body._form=this._obj.body
		ENDIF
		RETURN this._body
	ENDFUNC

	FUNCTION toJSON()
		RETURN nfjsoncreate(this._obj)
	ENDFUNC


	FUNCTION url_access()
		RETURN this._obj.url
	ENDFUNC
	FUNCTION url_assign(value)
		this._obj.url= value
	ENDFUNC

	FUNCTION method_access()
		RETURN this._obj.method
	ENDFUNC
	FUNCTION method_assign(value)
		this._obj.method= value
	ENDFUNC

	FUNCTION getResponse()
		RETURN HttpRequest(this)
	ENDFUNC

ENDDEFINE
