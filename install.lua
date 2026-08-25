local base="https://raw.githubusercontent.com/Alexandre171172/minecraft-scram-system/main/"
local files={"config.lua","scram.lua","startup.lua"}
print("=== INSTALLATION SYSTEME SCRAM ===")
if not http then error("HTTP est desactive dans CC:Tweaked.") end
for _,name in ipairs(files) do
  write("Telechargement "..name.."... ")
  local ok,res=http.get(base..name)
  if not ok then print("ECHEC") error("Impossible de telecharger "..name) end
  local data=res.readAll(); res.close()
  local f=fs.open("/"..name,"w")
  f.write(data); f.close()
  print("OK")
end
print("Installation terminee.")
print("Redemarrage dans 3 secondes...")
sleep(3)
os.reboot()
