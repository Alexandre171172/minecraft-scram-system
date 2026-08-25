local cfg = dofile("/config.lua")
local monitor = cfg.monitorSide and peripheral.wrap(cfg.monitorSide) or peripheral.find("monitor")
if not monitor then error("Aucun moniteur detecte.") end
monitor.setTextScale(cfg.textScale)

local cardValid = false
local scram = false
local deadline = 0
local lastCard = redstone.getInput(cfg.cardSide)
local lastLever = redstone.getInput(cfg.leverSide)

local function center(y, text, c)
  local w = monitor.getSize()
  monitor.setTextColor(c or colors.white)
  monitor.setCursorPos(math.max(1, math.floor((w - #text) / 2) + 1), y)
  monitor.write(text)
end

local function line(y)
  local w = monitor.getSize()
  monitor.setCursorPos(1, y)
  monitor.setTextColor(colors.gray)
  monitor.write(string.rep("-", w))
end

local function clear()
  monitor.setBackgroundColor(colors.black)
  monitor.clear()
end

local function header()
  center(1, "CENTRALE NUCLEAIRE", colors.cyan)
  center(2, "SYSTEME DE SECURITE SCRAM", colors.cyan)
  line(3)
end

local function footer()
  local _, h = monitor.getSize()
  line(h - 1)
  center(h, "SECURITY SYSTEM ONLINE", colors.cyan)
end

local function normal()
  clear(); header()
  center(6, "REACTEUR A FISSION NUCLEAIRE", colors.lime)
  center(8, "EN FONCTIONNEMENT", colors.lime)
  line(10)
  center(12, "SYSTEME SCRAM", colors.cyan)
  center(14, "INACTIF", colors.lime)
  footer()
end

local function waiting()
  clear(); header()
  center(6, "ALERTE SCRAM", colors.orange)
  center(8, "LEVIER SCRAM : ACTIVE", colors.orange)
  center(10, "VALIDATION REQUISE", colors.yellow)
  line(12)
  center(14, "PRESENTEZ UNE CARTE", colors.cyan)
  center(16, "SUR LE LECTEUR SECURITYCRAFT", colors.cyan)
  footer()
end

local function cardScreen()
  local left = math.max(0, math.ceil(deadline - os.clock()))
  clear(); header()
  center(6, "CARTE LUE", colors.yellow)
  center(8, "CARTE DE SECURITE VALIDEE", colors.lime)
  line(10)
  center(12, "UTILISEZ LE BOUTON D'URGENCE", colors.orange)
  center(14, "POUR LANCER LE SCRAM", colors.orange)
  line(16)
  center(18, "ANNULATION AUTOMATIQUE", colors.yellow)
  center(20, string.format("%02d SECONDES", left), colors.red)
  footer()
end

local function scramScreen()
  clear(); header()
  center(5, "!!! SCRAM !!!", colors.red)
  center(7, "ARRET D'URGENCE", colors.red)
  line(9)
  center(11, "REACTEUR A FISSION NUCLEAIRE", colors.red)
  center(13, "DESACTIVE MANUELLEMENT", colors.red)
  line(15)
  center(17, "SORTIE SCRAM", colors.cyan)
  center(19, "ACTIVE", colors.lime)
  footer()
end

local function output()
  redstone.setOutput(cfg.scramOutputSide, scram)
end

local function resetAll()
  cardValid = false
  scram = false
  deadline = 0
  output()
end

local function resetScram()
  scram = false
  output()
end

local function validateCard()
  cardValid = true
  deadline = os.clock() + cfg.cardTimeout
end

local function render()
  local lever = redstone.getInput(cfg.leverSide)

  if scram then
    scramScreen()
  elseif cardValid then
    cardScreen()
  elseif lever then
    waiting()
  else
    normal()
  end
end

resetAll()
render()

while true do
  local event = os.pullEvent()
  local lever = redstone.getInput(cfg.leverSide)
  local card = redstone.getInput(cfg.cardSide)

  -- Levier OFF : le SCRAM est toujours annule.
  -- Une carte lue AVANT le levier reste toutefois valide pendant 15 s.
  if not lever then
    if lastLever then
      resetAll()
    elseif scram then
      resetScram()
    end
  end

  -- Detection du front montant du Keycard Reader.
  -- Le lecteur peut rester ON quelques secondes : une seule lecture est retenue.
  if card and not lastCard then
    validateCard()
  end

  -- Les deux conditions sont reunies.
  if lever and cardValid and not scram then
    scram = true
    output()
  end

  -- Expiration de la carte apres 15 secondes.
  if cardValid and not scram and os.clock() >= deadline then
    cardValid = false
    deadline = 0
  end

  lastCard = card
  lastLever = lever

  render()

  if cardValid and not scram then
    os.startTimer(0.1)
  end
end
