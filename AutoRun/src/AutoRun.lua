local ADDON_NAME, AR = ...

AutoRun = AutoRun or {}

SLASH_AUTO_RUN1 = "/ar"
SLASH_AUTO_RUN2 = "/autorun"

local function IsTableEmpty(t)
  for k, v in pairs(t) do
    return false
  end
  return true
end

local function IsTrueForAll(t, predicate)
  for _, v in ipairs(t) do
    if not predicate(v) then
      return false
    end
  end
  return true
end

function AutoRun.AddStartupScript(
  name,         -- string
  description,  -- string
  dependencies, -- table of strings
  source        -- string
)
  if AUTO_RUN_DB.OnLoad[name] then
    print("A script with that name already exists.")
    return
  end
  local f, err = loadstring(source)
  if not f then
    print("Compiling the script failed with the following error:")
    print(err)
    return
  end
  AUTO_RUN_DB.OnLoad[name] = {
    Name         = name;
    Description  = description;
    Dependencies = dependencies;
    Source       = source;
  }
  for _, dependency in ipairs(dependencies) do
    local deps             = AUTO_RUN_DB.Dependencies
    deps[dependency]       = deps[dependency] or {}
    deps[dependency][name] = true
  end
end

function AutoRun.RemoveStartupScript(
  name -- string
)
  if not AUTO_RUN_DB.OnLoad[name] then
    print("No script with that name exists.")
    return
  end
  AUTO_RUN_DB.OnLoad[name] = nil
  local empty_dependencies = {}
  for dependency_name, dependency in pairs(AUTO_RUN_DB.Dependencies) do
    dependency[name] = nil
    if IsTableEmpty(dependency) then
      table.insert(empty_dependencies, dependency_name)
    end    
  end
  for _, dependency_name in ipairs(empty_dependencies) do
    AUTO_RUN_DB.Dependencies[dependency_name] = nil
  end
end

function AutoRun.RunScript(name)
  local f, err = loadstring(AUTO_RUN_DB.OnLoad[name].Source)
  if f then
    f()
    return true
  end
  return false, err
end

do
  local loaded_scripts = {}

  function AR.OnLoaded()
    AUTO_RUN_DB              = AUTO_RUN_DB              or {}
    AUTO_RUN_DB.OnLoad       = AUTO_RUN_DB.OnLoad       or {}
    AUTO_RUN_DB.Dependencies = AUTO_RUN_DB.Dependencies or {}

    for name, script in pairs(AUTO_RUN_DB.OnLoad) do
      if loaded_scripts[name] then
        return
      end
      if IsTrueForAll(script.Dependencies, IsAddOnLoaded) then
        AutoRun.RunScript(name)
        loaded_scripts[name] = true
      end
    end
  end

  function AR.OnAddonLoaded(name)
    local dependent_addons = AUTO_RUN_DB.Dependencies[name]
    if not dependent_addons then
      return
    end
    for addon, _ in pairs(dependent_addons) do
      if loaded_scripts[addon] then
        return
      end
      local script = AUTO_RUN_DB.OnLoad[addon]
      if IsTrueForAll(script.Dependencies, IsAddOnLoaded) then
        AutoRun.RunScript(addon)
        loaded_scripts[addon] = true
      end
    end
  end
end

local event_frame = CreateFrame("FRAME", "AR_EventFrame")
event_frame:RegisterEvent "ADDON_LOADED"
function event_frame:OnEvent(event, arg)
  if event == "ADDON_LOADED" then
    if arg == ADDON_NAME then
      AR.OnLoaded()
    else
      AR.OnAddonLoaded(arg)
    end
    return
  end
end
event_frame:SetScript("OnEvent", event_frame.OnEvent)

SlashCmdList["AUTO_RUN"] = function(input)
  input = input:gsub("^%s*(.*)%s*$", "%1") -- Trim leading and trailing spaces
  -- TODO: add command interface
end
