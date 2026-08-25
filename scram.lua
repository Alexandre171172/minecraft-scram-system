local cfg = dofile("/config.lua")
local monitor = cfg.monitorSide and peripheral.wrap(cfg.monitorSide) or peripheral.find("monitor")
if not monitor then error("Aucun moniteur detecte.") end
monitor.setTextScale(cfg.textScale)

local cardValid = false
local scram = false
local deadline = nil
local lastCard = redstone.getInput(cfg.cardSide)
local lastLever = redstone.getInput(cfg.leverSide)

local function color(c) monitor.setTextColor(c) end
local function clear() monitor.setBackgroundColor(colors.black); monitor.clear() end
local function center(y, text, c)
  color(c or colors.white)
  local w = monitor.getSize()
  monitor.setCursorPos(math.max(1, math.floor((w-#text)/2)+1), y)
  monitor.write(text)
end
local function line(y)
  local w = monitor.getSize()
  monitor.setCursorPos(1,y); color(colors.gray); monitor.write(string.rep("-",w))
end
local function header()
  center(1,"CENTRALE NUCLEAIRE",colors.cyan)
  center(2,"SYSTEME DE SECURITE SCRAM",colors.cyan)
  line(3)
end
local function footer()
  local _,h=monitor.getSize(); line(h-1); center(h,"SECURITY SYSTEM ONLINE",colors.cyan)
end
local function normal()
  clear(); header()
  center(6,"REACTEUR A FISSION NUCLEAIRE",colors.lime)
  center(8,"EN FONCTIONNEMENT",colors.lime)
  line(10); center(12,"SYSTEME SCRAM",colors.cyan); center(14,"INACTIF",colors.lime); footer()
end
local function waiting()
  clear(); header()
  center(6,"ALERTE SCRAM",colors.orange)
  center(8,"LEVIER SCRAM : ACTIVE",colors.orange)
  center(10,"VALIDATION REQUISE",colors.yellow)
  line(12); center(14,"PRESENTEZ UNE CARTE",colors.cyan); center(16,"SUR LE LECTEUR SECURITYCRAFT",colors.cyan); footer()
end
local function cardScreen(left)
  clear(); header()
  center(6,"CARTE LUE",colors.yellow)
  center(8,"CARTE DE SECURITE VALIDEE",colors.lime)
  line(10); center(12,"UTILISEZ LE BOUTON D'URGENCE",colors.orange); center(14,"POUR LANCER LE SCRAM",colors.orange)
  line(16); center(18,"ANNULATION AUTOMATIQUE",colors.yellow); center(20,string.format("%02d SECONDES",math.max(0,math.ceil(left))),colors.red); footer()
end
local function scramScreen()
  clear(); header(); center(5,"!!! SCRAM !!!",colors.red); center(7,"ARRET D'URGENCE",colors.red); line(9)
  center(11,"REACTEUR A FISSION NUCLEAIRE",colors.red); center(13,"DESACTIVE MANUELLEMENT",colors.red); line(15)
  center(17,"SORTIE SCRAM",colors.cyan); center(19,"ACTIVE",colors.lime); footer()
end
local function output() redstone.setOutput(cfg.scramOutputSide,scram) end
local function reset() cardValid=false; scram=false; deadline=nil; output() end
local function cardRead()
  cardValid=true; deadline=os.clock()+cfg.cardTimeout
end
local function refresh()
  local lever=redstone.getInput(cfg.leverSide)
  if not lever then
    if scram or cardValid then reset() end
    normal(); return
  end
  if scram then scramScreen(); return end
  if cardValid then
    local left=deadline-os.clock()
    if left<=0 then cardValid=false; deadline=nil; cardScreen(0); sleep(1); waiting(); return end
    cardScreen(left); return
  end
  waiting()
end
reset(); refresh()
while true do
  local e,p=os.pullEvent()
  local lever=redstone.getInput(cfg.leverSide)
  local card=redstone.getInput(cfg.cardSide)
  if not lever then
    if scram or cardValid then reset() end
    refresh()
  elseif e=="redstone" then
    if card and not lastCard then cardRead() end
    if lever and cardValid and not scram then scram=true; output() end
    refresh()
  elseif e=="timer" then
    refresh()
  end
  lastCard=card; lastLever=lever
  if cardValid and not scram then os.startTimer(0.1) end
end
