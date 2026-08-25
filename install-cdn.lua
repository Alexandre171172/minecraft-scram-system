local base="https://cdn.jsdelivr.net/gh/Alexandre171172/minecraft-scram-system@main/"
local files={"config.lua","scram.lua","startup.lua"}
print("=== INSTALLATION SYSTEME SCRAM ===")
if not http then error("HTTP est desactive.") end
for _,name in ipairs(files) do
  write("Telechargement "..name.."... ")
  local r=http.get(base..name)
  if not r then print("ECHEC"); error("Impossible de telecharger "..name) end
  local data=r.readAll(); r.close()
  local f=fs.open("/"..name,"w"); f.write(data); f.close()
  print("OK")
end
print("Installation terminee. Redemarrage...")
sleep(2)
os.reboot()
