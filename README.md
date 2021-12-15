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

## What can I do with Shide?

Shide is a multipurpose library. Extends VFP9 giving all the power of [kawix/core](https://github.com/kodhework/kawix). With a unique library you can do almost anything in VFP. If there is something harder to do native with VFP, then Shide is the solution. Here a list of current shide usages: 

- Make HTTP/HTTPS Web Requests [vfp.axios](https://github.com/FoxShell/vfp.axios)
- Send emails using SMTP [vfpmailer](https://github.com/FoxShell/vfpmailer)
- Create/Read zip files [admzip](https://github.com/FoxShell/admzip)
- The fastest JSON parser. See example: [examples/json.prg](examples/json.prg)
