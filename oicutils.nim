import parsecfg, strutils, streams, strtabs, oids, math, os, terminal, redis 


proc uid*():string =
  var sid:string = $(genOid())
  sid.delete(sid.len-2, sid.len-1)
  return sid
   
var chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" 
  
proc parseDockerHostPort*(envname, defaultHost, defaultPort:string):PStringTable =
  var varname = ""
  if existsEnv(envname):
    varname = getEnv(envname)
  echo "varname is"
  echo varname
  result = newStringTable()
  var slashPos = varname.find("//")
  if slashPos != -1:
    var colonPos = varname.find(":")
    if colonPos == -1:
      return result
    else:
      result["host"] = varname[slashPos+2..colonPos-1]
      result["port"] = varname[colonPos+1..varname.len-1]
  else:
    result["host"] = defaultHost
    result["port"] = defaultPort
    
proc makeApiKey*():string =
  randomize()  
  var apiKey = ""
  var num:int
  for i in countup(1,26):
    num = round(random(toFloat(chars.len-1)))    
    var ch = chars[num]    
    apiKey = apiKey & chars[num] 
  return apiKey
  
proc hGetAllTable*(red: TRedis, key:string):PStringTable = 
  var list = red.hGetAll key
  var strTable = newStringTable()
  if not isNil(list):
    var i = 0
    while i < list.len and not isNil(list[i]):
      strTable[list[i]] = list[i+1]
      i = i + 2
  return strTable

proc fromStringTableSerial*(queryx:string): PStringTable =
  var data = newStringTable(modeCaseInsensitive)
  var query = queryx[1..queryx.len-2]
  var fieldlist = query.split(',')
  for field in fieldlist:
    var tokens = field.split(':')
    if tokens.len > 1:
      data[strip(tokens[0])] = strip(tokens[1])
  return data
  

proc fromQueryString*(query:string): PStringTable =
  var data = newStringTable(modeCaseInsensitive)
  var fieldlist = query.split('&')
  for field in fieldlist:
    var tokens = field.split('=')
    if tokens.len > 1:
      data[tokens[0]] = tokens[1]
  return data

proc echox*(outp:string) =
  write(stdout, outp & "\n")


var progressBarWidth* = 20.0
var progressBarColor* = fgCyan

proc progress*(percent:float) =
  setForegroundColor(progressBarColor)  
  setCursorXPos(0)
  write(stdout, $round(percent))
  write(stdout, "%")  
  setCursorXPos(5)
  var blocks = round(progressBarWidth * (percent/100.0))
  for n in countup(1, blocks):
    write(stdout, "█")
  for x in countup(blocks+1,round(progressBarWidth)):
    write(stdout, "▒")
  echo()  
  write(stdout, '\0')
  FlushFile(stdout)  
  CursorUp()
  setCursorXPos(round(progressBarWidth)+5)
  if abs(percent-100.0) <= 1.0:
    ResetAttributes()
    echo()


when isMainModule:  
  echo(fromQueryString("dog=20&cat=lady"))
  echo(fromStringTableSerial("{password: pass,  newuser: ilaksh4@fastmail.fm}"))
  echo(makeApiKey())
  var theuid = uid()
  for i in 0..theuid.len-1:
    echo("uid char is *" & theuid[i] & "*")
  
