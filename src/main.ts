//import 'npm://fs-extra@8.1.0'
import fs from 'fs'
import Os from 'os'
import Path from 'path'

main()


function remove(path){

	let stat = fs.statSync(path)
	if(stat.isDirectory()){
		let files = fs.readdirSync(path)
		for(let i=0;i<files;i++){
			let file = Path.join(path, files[i])
			remove(file)
		}
		fs.rmdirSync(path)
	}else{
		fs.unlinkSync(path)
	}
}


function copy(src, dest){

	//console.info(src,dest)

	let stat = fs.statSync(src)
	
	if(stat.isDirectory()){
		if(!fs.existsSync(dest)) fs.mkdirSync(dest)
		let files = fs.readdirSync(src)

		for(let i=0;i<files.length;i++){
			let file = Path.join(src, files[i])
			let file1 = Path.join(dest, files[i])
			copy(file, file1)
		}
	}else{
		let content = fs.readFileSync(src)
		fs.writeFileSync(dest, content)
	}
}




async function main(){

	try{
		console.info("Installing shide ...")

		var kawixFolder = Path.join(Os.homedir(), "Kawix")
		var kowixFolder = Path.join(Os.homedir(), "Kowix")
		if(!fs.existsSync(kawixFolder)){
			fs.mkdirSync(kawixFolder)
		}
		if(!fs.existsSync(kowixFolder)){
			fs.symlinkSync(kawixFolder, kowixFolder, "junction")
		}


		var shideFolder = Path.join(kawixFolder, "Shide")
		var shideLibFolder = Path.join(kawixFolder, "Shide.lib")

		if(fs.existsSync(shideFolder)){
			remove(shideFolder)
		}
		if(!fs.existsSync(shideLibFolder)){
			fs.mkdirSync(shideLibFolder)
		}

		fs.symlinkSync(Path.join(__dirname, "Shide"), shideFolder, "junction")
		copy(Path.join(__dirname, "Shide.lib"), shideLibFolder)

	}catch(e){
		console.error("Failed installing shide: ", e)
	}
	
	

}