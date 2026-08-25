-- Lance automatiquement le systeme SCRAM
if not fs.exists("/config.lua") or not fs.exists("/scram.lua") then
  printError("Installation SCRAM incomplete.")
  print("Fichiers requis : config.lua et scram.lua")
  return
end
shell.run("scram.lua")
