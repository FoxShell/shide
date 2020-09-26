# shide
Shide is a library that exposes the power of [kawix/core](https://github.com/kodhework/kawix) to VFP9

NOTE: Works on VFP9 and in VFP10 Advanced (by cheng) 32/64 bits. Its know to work on windows7+.


## Import Shide in your project 

### With installation (RECOMMENDED)


1. Install [@kawix/core](https://github.com/kodhework/kawix/blob/master/core/INSTALL.md)

2. Execute on cmd: 

```
kwcore gh+/FoxShell/packages/shide/0.0.7.kwa
```

### Without installation

1. Download the file and rename to ```shide.app```:
  - For 32 bits: [/FoxShell/packages/shide/0.0.7.x86.app](https://raw.githubusercontent.com/FoxShell/packages/master/shide/0.0.6.x86.app)
  - For 64 bits: [/FoxShell/packages/shide/0.0.7.x64.app](https://raw.githubusercontent.com/FoxShell/packages/master/shide/0.0.6.x64.app)
  
  NOTE: You can run shide 64 bits version within VFP9 32 bits. The VFP cpu architecture doesn't need match the shide cpu architecture.

2. Add to your VFP project (or copy inside executable folder, like you prefer)

3. In vfp code (at startup for example): ```do shide.app``` (the first time can take some time)


## What can I do with Shide?

Shide is a multipurpose library. Extends VFP9 giving all the power of [kawix/core](https://github.com/kodhework/kawix). With a unique library you can do almost anything in VFP. If there is something harder to do native with VFP, then Shide is the solution. Here a list of current shide usages: 

- Make HTTP/HTTPS Web Requests [vfp.axios](https://github.com/FoxShell/vfp.axios)
- Send emails using SMTP [vfpmailer](https://github.com/FoxShell/vfpmailer)
- Create/Read zip files [admzip](https://github.com/FoxShell/admzip)
- The fastest JSON parser. See example: [examples/json.prg](examples/json.prg)
